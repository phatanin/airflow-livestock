from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import requests
import pandas as pd
from sqlalchemy import create_engine
import os

# resource_ids ของแต่ละสัตว์
resource_ids = {
    "cow": "ecf31b91-5042-4908-b3d2-689343a421e1",
    "pig": "d39fc22e-625b-4e89-8ca4-843fc52f9783",
    "egg": "10ebc3b6-d5ba-4025-b5f3-261b71a6458c",
    "shrimp": "e78db1eb-672b-44d9-8500-4848446fe73f",
    "chicken": "8d6439a5-ddab-4744-b530-a464499ad8f5"
}

DATA_DIR = "/opt/airflow/data"
os.makedirs(DATA_DIR, exist_ok=True)
BASE_URL = "https://catalog.oae.go.th/api/3/action/datastore_search"

# PostgreSQL connection string สำหรับ Docker environment (ระบุ schema=livestock)
DB_USER = "airflow"
DB_PASSWORD = "airflow123"  
DB_HOST = "livestock_db"  # ชื่อ service ใน docker-compose
DB_NAME = "livestock"
engine = create_engine(f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}?options=-csearch_path%3Dlivestock")

def extract_api(**context):
    all_data = {}
    for name, rid in resource_ids.items():
        url = f"{BASE_URL}?resource_id={rid}&limit=1000"
        resp = requests.get(url).json()
        records = resp.get("result", {}).get("records", [])
        all_data[name] = records
        print(f"✅ Extracted {len(records)} rows for {name}")
    
    # Push ข้อมูลไปยัง XCom
    context['ti'].xcom_push(key='api_data', value=all_data)
    return all_data

def transform_load(**context):
    # ดึงข้อมูลจาก XCom 
    all_data = context['ti'].xcom_pull(task_ids='extract_task', key='api_data')
    
    # ตรวจสอบว่าได้ข้อมูลหรือไม่
    if all_data is None:
        raise ValueError("No data received from extract_task!")
    
    for name, records in all_data.items():
        df = pd.DataFrame(records)

        # Cleansing
        df = df.dropna()  # ลบ missing values
        # แปลง column วันที่เป็น datetime ถ้ามี
        for col in df.columns:
            if "date" in col.lower() or "เดือน" in col.lower() or "ปี" in col.lower():
                df[col] = pd.to_datetime(df[col], errors="coerce")
        df = df.dropna()  # ลบแถวที่วันที่ไม่ถูกต้อง

        # Save CSV in 2 versions: UTF-8 (standard) and UTF-8 BOM (Excel)
        # Standard UTF-8 version
        csv_path = os.path.join(DATA_DIR, f"clean_{name}.csv")
        df.to_csv(csv_path, index=False, encoding='utf-8')
        print(f"✅ Saved {csv_path} (UTF-8)")
        
        # Excel-compatible version with BOM
        excel_csv_path = os.path.join(DATA_DIR, f"clean_{name}_excel.csv")
        df.to_csv(excel_csv_path, index=False, encoding='utf-8-sig')
        print(f"✅ Saved {excel_csv_path} (UTF-8 BOM for Excel)")

        # Load เข้า PostgreSQL (ระบุ schema='livestock' อย่างชัดเจน)
        table_name = f"livestock_{name}"
        df.to_sql(table_name, con=engine, if_exists='replace', index=False, schema='livestock')
        print(f"✅ Loaded {len(df)} rows into PostgreSQL table {table_name}")

# DAG configuration
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'start_date': datetime(2025, 1, 1)
}

with DAG(
    'etl_livestock_api_postgresql',
    default_args=default_args,
    description='ETL ราคาสัตว์ OAE API → Clean CSV → Load PostgreSQL',
    schedule_interval='@daily',
    catchup=False
) as dag:

    extract_task = PythonOperator(
        task_id='extract_task',
        python_callable=extract_api,
        provide_context=True
    )

    transform_load_task = PythonOperator(
        task_id='transform_load_task',
        python_callable=transform_load,
        provide_context=True
    )

    extract_task >> transform_load_task
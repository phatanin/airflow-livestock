# 🐄 Airflow Livestock Price ETL Pipeline

ETL Pipeline สำหรับดึงข้อมูลราคาสัตว์เศรษฐกิจไทยจาก OAE API โดยใช้ Apache Airflow และ PostgreSQL

## 📋 ข้อมูลที่ดึง

- **โคเนื้อ** - ราคาโคเนื้อรายเดือน
- **สุกร** - ราคาสุกรรายเดือน
- **ไข่ไก่** - ราคาไข่ไก่รายเดือน
- **กุ้งขาวแวนนาไม** - ราคากุ้งรายเดือน
- **ไก่เนื้อ** - ราคาไก่เนื้อรายเดือน

**ข้อมูล:** 44 records ต่อสัตว์ (ครอบคลุมปี 2565-2568)

## 🛠 เทคโนโลยีที่ใช้

- **Apache Airflow 2.7.3** - ETL Orchestration
- **PostgreSQL 13** - Database
- **Docker & Docker Compose** - Containerization
- **Python** - Data Processing
- **Pandas** - Data Manipulation
- **SQLAlchemy** - Database ORM

## 🚀 วิธีติดตั้งและใช้งาน

### ข้อกำหนดระบบ

- **Docker Desktop** (รองรับ Windows, macOS, Linux)
- **RAM:** อย่างน้อย 4GB
- **Disk Space:** อย่างน้อย 10GB

### 1. Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/airflow-livestock.git
cd airflow-livestock
```

### 2. เริ่มต้นระบบ

```bash
# เริ่ม Airflow และ PostgreSQL
docker compose up -d

# รอให้ services เริ่มต้นเสร็จ (2-3 นาที)
docker ps
```

### 3. เข้าใช้งาน Airflow Web UI

1. เปิดเบราว์เซอร์ไปที่: **http://localhost:8080**
2. เข้าสู่ระบบด้วย:
   - **Username:** `admin`
   - **Password:** `admin123`

### 4. รัน ETL Pipeline

1. หา DAG ชื่อ **`etl_livestock_api_postgresql`**
2. เปิดใช้งาน DAG (toggle เป็นสีเขียว)
3. คลิกปุ่ม **▶️ Trigger DAG** เพื่อรันทันที

### 5. ตรวจสอบผลลัพธ์

**📁 ไฟล์ CSV** (ใน folder `data/`):

```
data/
├── clean_cow.csv (UTF-8)
├── clean_cow_excel.csv (UTF-8 BOM สำหรับ Excel)
├── clean_pig.csv
├── clean_pig_excel.csv
├── clean_egg.csv
├── clean_egg_excel.csv
├── clean_shrimp.csv
├── clean_shrimp_excel.csv
├── clean_chicken.csv
└── clean_chicken_excel.csv
```

**🗄️ Database Tables** (PostgreSQL):

- **Host:** localhost:5433
- **Database:** livestock
- **Schema:** livestock
- **Username:** airflow
- **Password:** airflow123

## 🔧 การเชื่อมต่อฐานข้อมูล

### ใช้ DBeaver

1. **New Connection** → **PostgreSQL**
2. **Connection Settings:**
   ```
   Host: localhost
   Port: 5433
   Database: livestock
   Username: airflow
   Password: airflow123
   ```
3. **Test Connection** → **Finish**

### ใช้ Python

```python
import pandas as pd
from sqlalchemy import create_engine

# เชื่อมต่อฐานข้อมูล
engine = create_engine('postgresql+psycopg2://airflow:airflow123@localhost:5433/livestock')

# ดึงข้อมูล
df = pd.read_sql('SELECT * FROM livestock.livestock_cow', engine)
print(df.head())
```

## 📊 ตัวอย่าง SQL Queries

```sql
-- ดูข้อมูลทั้งหมดในตาราง
SELECT * FROM livestock.livestock_cow LIMIT 10;

-- ราคาเฉลี่ยของแต่ละสัตว์ในปี 2568
SELECT
    'โคเนื้อ' as animal_type,
    AVG(value) as avg_price
FROM livestock.livestock_cow
WHERE year = 2568
UNION ALL
SELECT 'สุกร', AVG(value) FROM livestock.livestock_pig WHERE year = 2568
UNION ALL
SELECT 'ไข่ไก่', AVG(value) FROM livestock.livestock_egg WHERE year = 2568
UNION ALL
SELECT 'กุ้ง', AVG(value) FROM livestock.livestock_shrimp WHERE year = 2568
UNION ALL
SELECT 'ไก่เนื้อ', AVG(value) FROM livestock.livestock_chicken WHERE year = 2568;

-- แนวโน้มราคาโคเนื้อตามเดือน
SELECT
    year, month, value
FROM livestock.livestock_cow
ORDER BY year, month;
```

## ⚙️ การจัดการระบบ

### หยุดระบบ

```bash
docker compose down
```

### เริ่มระบบใหม่

```bash
docker compose up -d
```

### ดู logs

```bash
# ดู logs ทั้งหมด
docker compose logs -f

# ดู logs เฉพาะ service
docker compose logs -f airflow-webserver
```

### ตรวจสอบสถานะ

```bash
# ดู containers ที่รันอยู่
docker ps

# ดูการใช้ resources
docker stats
```

## 📅 การตั้งเวลาอัตโนมัติ

ETL Pipeline จะรันอัตโนมัติ **ทุกวัน** ตามการตั้งค่า `schedule_interval='@daily'`

**แก้ไขตารางเวลา:**

1. แก้ไขไฟล์ `dags/etl_livestock_api_postgresql.py`
2. เปลี่ยนค่า `schedule_interval`:

   ```python
   # รันทุกชั่วโมง
   schedule_interval='@hourly'

   # รันทุกวันจันทร์
   schedule_interval='0 0 * * 1'

   # ไม่รันอัตโนมัติ (Manual เท่านั้น)
   schedule_interval=None
   ```

## 🗂 โครงสร้างโปรเจค

```
airflow-livestock/
├── dags/
│   └── etl_livestock_api_postgresql.py    # ETL Pipeline code
├── data/                                   # CSV output files
├── config/                                 # Airflow configuration
├── docker-compose.yaml                     # Docker services definition
├── Dockerfile                              # Custom Airflow image
├── requirements.txt                        # Python dependencies
├── .env                                   # Environment variables
├── create_tables_postgresql.sql           # Database schema
├── livestock_complete_dump.sql            # Complete database backup
├── livestock_data_dump.sql               # Data-only backup
└── README.md                              # This file
```

## 🔍 การติดตาม ETL Pipeline

### ใน Airflow Web UI:

1. **DAGs Page** - ดูสถานะ DAG ทั้งหมด
2. **Graph View** - ดู flow ของ tasks
3. **Tree View** - ดูประวัติการรัน
4. **Logs** - ดู logs แต่ละ task

### ผ่าน Command Line:

```bash
# ทดสอบ task แค่ task เดียว
docker compose exec airflow-webserver airflow tasks test etl_livestock_api_postgresql extract_task 2024-01-01

# ดูสถานะ DAG
docker compose exec airflow-webserver airflow dags state etl_livestock_api_postgresql
```

## 🐛 การแก้ไขปัญหา

### 1. Airflow ไม่เริ่มต้น

```bash
# ตรวจสอบ logs
docker compose logs airflow-init

# เคลียร์และเริ่มใหม่
docker compose down -v
docker compose up airflow-init
docker compose up -d
```

### 2. DAG ไม่แสดงใน Web UI

```bash
# ตรวจสอบ syntax error
docker compose exec airflow-webserver python /opt/airflow/dags/etl_livestock_api_postgresql.py

# Restart scheduler
docker compose restart airflow-scheduler
```

### 3. Database connection ล้มเหลว

```bash
# ตรวจสอบ PostgreSQL container
docker compose logs postgres livestock_db

# ทดสอบ connection
docker compose exec postgres psql -U airflow -d livestock -c "\dt livestock.*"
```

### 4. ไม่มี CSV files

- ตรวจสอบว่า folder `data/` มีสิทธิ์เขียนได้
- ดู logs ของ transform_load_task
- ตรวจสอบ volume mapping ใน docker-compose.yaml

## 📝 การปรับแต่ง

### เปลี่ยน API Resource IDs:

แก้ไขในไฟล์ `dags/etl_livestock_api_postgresql.py`:

```python
resource_ids = {
    "cow": "ecf31b91-5042-4908-b3d2-689343a421e1",
    "pig": "d39fc22e-625b-4e89-8ca4-843fc52f9783",
    # เพิ่มสัตว์ประเภทใหม่
    "fish": "YOUR_RESOURCE_ID_HERE"
}
```

### เปลี่ยน Database Settings:

แก้ไขในไฟล์ `.env`:

```bash
POSTGRES_USER=your_username
POSTGRES_PASSWORD=your_password
POSTGRES_DB=your_database
```

## 📊 ข้อมูลเพิ่มเติม

- **แหล่งข้อมูล:** [OAE Open Data](https://catalog.oae.go.th/)
- **ความถี่:** รายเดือน
- **ช่วงเวลา:** มกราคม 2565 - สิงหาคม 2568
- **หน่วย:** บาท/กิโลกรัม, บาท/ร้อยฟอง (ไข่)

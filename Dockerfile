FROM apache/airflow:2.7.3
COPY requirements_simple.txt .
RUN pip install -r requirements_simple.txt
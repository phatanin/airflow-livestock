# การใช้งานฐานข้อมูล Livestock Price Data

## วิธีการ Import ข้อมูลใน DBeaver

### วิธี 1: ใช้ SQL Dump File

1. **เปิด DBeaver** และสร้าง connection ใหม่ไปยัง PostgreSQL
2. **ข้อมูลการเชื่อมต่อ:**

   - Host: localhost
   - Port: 5434 (หรือ 5433 ถ้าใช้ Airflow stack)
   - Database: livestock
   - Username: airflow
   - Password: airflow123

3. **Import ข้อมูล:**
   - คลิกขวาที่ database → SQL Editor → Open SQL Console
   - เปิดไฟล์ `livestock_complete_dump.sql`
   - Execute SQL เพื่อสร้าง schema และข้อมูล

### วิธี 2: ใช้ CSV Files

1. **สร้าง Tables ก่อน** (ใช้ไฟล์ `create_tables_postgresql.sql`)
2. **Import CSV:**
   - คลิกขวาที่แต่ละ table → Import Data
   - เลือกไฟล์ CSV ที่ต้องการ
   - ไฟล์ `clean_*_excel.csv` = UTF-8 BOM (สำหรับ Excel)
   - ไฟล์ `clean_*.csv` = UTF-8 ธรรมดา

### วิธี 3: ใช้ Docker (แนะนำ)

```bash
# Clone repository
git clone <repository-url>
cd airflow-livestock

# รัน standalone database
docker-compose -f docker-compose-standalone-db.yml up -d

# เชื่อมต่อผ่าน DBeaver
# Host: localhost, Port: 5434, DB: livestock
# User: airflow, Password: airflow123
```

## โครงสร้างข้อมูล

### Schema: `livestock`

**Tables:**

- `livestock_cow` - ราคาโคเนื้อ (44 records)
- `livestock_pig` - ราคาสุกร (44 records)
- `livestock_egg` - ราคาไข่ไก่ (44 records)
- `livestock_shrimp` - ราคากุ้งขาวแวนนาไม (44 records)
- `livestock_chicken` - ราคาไก่เนื้อ (44 records)

**Columns:**

- `_id` - ID ลำดับ
- `year` - ปี (พ.ศ.)
- `month` - เดือน
- `regional_name` - ชื่อภูมิภาค (ประเทศไทย)
- `commod` - ประเภทสินค้า
- `product_name` - ชื่อผลิตภัณฑ์
- `value` - ราคา/ค่า

## ตัวอย่าง SQL Queries

```sql
-- ดูข้อมูลทั้งหมดในแต่ละตาราง
SELECT * FROM livestock.livestock_cow LIMIT 10;

-- ราคาเฉลี่ยของแต่ละสัตว์ในปี 2568
SELECT
    'โคเนื้อ' as animal_type,
    AVG(value) as avg_price
FROM livestock.livestock_cow
WHERE year = 2568
UNION ALL
SELECT 'สุกร', AVG("Value") FROM livestock.livestock_pig WHERE year = 2568
UNION ALL
SELECT 'ไข่ไก่', AVG(value) FROM livestock.livestock_egg WHERE year = 2568
UNION ALL
SELECT 'กุ้ง', AVG(value) FROM livestock.livestock_shrimp WHERE year = 2568
UNION ALL
SELECT 'ไก่เนื้อ', AVG(value) FROM livestock.livestock_chicken WHERE year = 2568;

-- ติดตามแนวโน้มราคาตามเดือน
SELECT
    year, month, value
FROM livestock.livestock_cow
ORDER BY year, month;
```

## ข้อมูลเพิ่มเติม

- **แหล่งข้อมูล:** OAE API (catalog.oae.go.th)
- **ความถี่ในการอัพเดท:** รายเดือน
- **ช่วงเวลา:** 2565-2568 (44 เดือน)
- **หน่วย:** บาท/กก., บาท/ร้อยฟอง (ไข่)

## การแก้ไขปัญหา

### หากไม่สามารถเชื่อมต่อได้:

1. ตรวจสอบว่า PostgreSQL container ทำงานอยู่: `docker ps`
2. ตรวจสอบ port ที่ใช้: 5434 (standalone) หรือ 5433 (Airflow)
3. ตรวจสอบ firewall และ network settings

### หากพบปัญหาการ encoding:

- ใช้ไฟล์ `*_excel.csv` สำหรับ Excel/Windows
- ใช้ไฟล์ `*.csv` สำหรับระบบอื่น ๆ

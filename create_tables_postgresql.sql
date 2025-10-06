-- สร้างตารางสำหรับข้อมูลสัตว์ปีก (สุกร, ไข่ไก่, กุ้ง, ไก่) สำหรับ PostgreSQL
-- โครงสร้างมี 7 columns: year, month, regional_name, commod, product_name, Value, unit

CREATE TABLE livestock_pig (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    regional_name VARCHAR(255),
    commod VARCHAR(255),
    product_name VARCHAR(255),
    value NUMERIC(15,2),
    unit VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE livestock_egg (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    regional_name VARCHAR(255),
    commod VARCHAR(255),
    product_name VARCHAR(255),
    value NUMERIC(15,2),
    unit VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE livestock_shrimp (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    regional_name VARCHAR(255),
    commod VARCHAR(255),
    product_name VARCHAR(255),
    value NUMERIC(15,2),
    unit VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE livestock_chicken (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    regional_name VARCHAR(255),
    commod VARCHAR(255),
    product_name VARCHAR(255),
    value NUMERIC(15,2),
    unit VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- สร้างตารางสำหรับข้อมูลโค (6 columns: year, month, regional_name, commod, product_name, value)
CREATE TABLE livestock_cow (
    id SERIAL PRIMARY KEY,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    regional_name VARCHAR(255),
    commod VARCHAR(255),
    product_name VARCHAR(255),
    value NUMERIC(15,2),  -- ใช้ 'value' ตัวเล็ก (ไม่มี 'unit' column)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- สร้าง indexes สำหรับ performance
CREATE INDEX idx_pig_year_month ON livestock_pig (year, month);
CREATE INDEX idx_pig_regional ON livestock_pig (regional_name);
CREATE INDEX idx_pig_product ON livestock_pig (product_name);

CREATE INDEX idx_egg_year_month ON livestock_egg (year, month);
CREATE INDEX idx_egg_regional ON livestock_egg (regional_name);
CREATE INDEX idx_egg_product ON livestock_egg (product_name);

CREATE INDEX idx_shrimp_year_month ON livestock_shrimp (year, month);
CREATE INDEX idx_shrimp_regional ON livestock_shrimp (regional_name);
CREATE INDEX idx_shrimp_product ON livestock_shrimp (product_name);

CREATE INDEX idx_chicken_year_month ON livestock_chicken (year, month);
CREATE INDEX idx_chicken_regional ON livestock_chicken (regional_name);
CREATE INDEX idx_chicken_product ON livestock_chicken (product_name);

CREATE INDEX idx_cow_year_month ON livestock_cow (year, month);
CREATE INDEX idx_cow_regional ON livestock_cow (regional_name);
CREATE INDEX idx_cow_product ON livestock_cow (product_name);

-- ตรวจสอบตารางที่สร้าง
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name LIKE 'livestock_%';

-- ดูโครงสร้างของแต่ละตาราง
\d livestock_pig;
\d livestock_egg;  
\d livestock_shrimp;
\d livestock_chicken;
\d livestock_cow;
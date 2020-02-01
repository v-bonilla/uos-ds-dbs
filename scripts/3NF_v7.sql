-- 3NF
-- To execute this script restore database 'AssignmentPart1_no_nulls_v2.bak'

-- Create database --------------------------------------------------------------------
USE master;
GO
IF DB_ID (N'mumsnet') IS NULL
CREATE DATABASE mumsnet COLLATE Latin1_General_CI_AS;
GO
-- Verify the database files and sizes
SELECT name, size, size*1.0/128 AS [Size in MBs]
FROM sys.master_files
WHERE name = N'mytest';
GO

-- Create schema by inserting data ---------------------------------------------------
USE mumsnet;
GO
-- Table product
SELECT
	t1.ProductCode AS p_code,
	t1.Features AS p_features,
	t1.[Description] AS p_description, 
	t1.[Length] AS p_length, 
	t1.Material AS p_material, 
	t1.Measures AS p_measures,
	t1.[Name] as p_name
INTO mumsnet.dbo.product
FROM AssignmentPart1.dbo.Product t1;
GO
-- Table product_name
SELECT
	t1.[Name] as pn_name,
	t1.Washing AS pn_washing,
	t1.Lining AS pn_lining,
	t1.Age AS pn_age 
INTO mumsnet.dbo.product_name
FROM AssignmentPart1.dbo.Product t1;
GO
-- Table item
SELECT
	t1.VariantCode AS i_variant_code, 
	t1.ProductGroup AS i_product_group,
	t1.ProductCode AS i_product_code,
	t1.LegLength AS i_leg_length, 
	t1.Colour AS i_colour, 
	t1.Price AS i_price
INTO mumsnet.dbo.item
FROM AssignmentPart1.dbo.Product t1;
GO
-- Table customer
SELECT
	t1.Id AS cus_id, 
	t1.FirstName AS cus_first_name,
	t1.LastName AS cus_last_name,
	t1.DateRegistered AS cus_date_registered, 
	t1.City AS cus_city
INTO mumsnet.dbo.customer
FROM AssignmentPart1.dbo.CustomerCity t1;
GO
-- Table city
SELECT
	t1.City AS ci_city, 
	t1.County AS ci_county
INTO mumsnet.dbo.city
FROM AssignmentPart1.dbo.CustomerCity t1;
GO
-- Table county
SELECT
	t1.County AS co_county, 
	t1.Region AS co_region
INTO mumsnet.dbo.county
FROM AssignmentPart1.dbo.CustomerCity t1;
GO
-- Table region
SELECT
	t1.Region AS r_region, 
	t1.Country AS r_country
INTO mumsnet.dbo.region
FROM AssignmentPart1.dbo.CustomerCity t1;
GO
-- Table order_item
SELECT
	t1.OrderItemNumber AS oi_number, 
	t1.VariantCode AS oi_variant_code,
	t1.ProductGroup AS oi_product_group,
	t1.Quantity AS oi_quantity, 
	t1.LineItemTotal AS oi_line_item_total,
	t1.OrderNumber AS oi_order_number
INTO mumsnet.dbo.order_item
FROM AssignmentPart1.dbo.OrderItem t1;
GO
-- Table order
SELECT
	t1.OrderNumber AS o_number, 
	t1.OrderCreateDate AS o_create_date,
	t1.OrderStatusCode AS o_status_code,
	t1.CustomerCityId AS o_customer_id, 
	t1.BillingCurrency AS o_billing_currency
INTO mumsnet.dbo.[order]
FROM AssignmentPart1.dbo.OrderItem t1;
GO

-- Modify schema ------------------------------------------------------------------
USE mumsnet;
GO
-- From table Product we got 3 tables: Product, ProductName and Item
ALTER TABLE dbo.product ALTER COLUMN p_code NVARCHAR(50) NOT NULL;
ALTER TABLE dbo.product ALTER COLUMN p_features NVARCHAR(3600) NOT NULL;
ALTER TABLE dbo.product ALTER COLUMN p_description NVARCHAR(3600) NOT NULL;
ALTER TABLE dbo.product ALTER COLUMN p_length NVARCHAR(256) NOT NULL;
ALTER TABLE dbo.product ALTER COLUMN p_material NVARCHAR(256) NOT NULL;
ALTER TABLE dbo.product ALTER COLUMN p_measures NVARCHAR(256) NOT NULL;
ALTER TABLE dbo.product ALTER COLUMN p_name NVARCHAR(256) NOT NULL;
GO
ALTER TABLE dbo.product_name ALTER COLUMN pn_name NVARCHAR(256) NOT NULL;
ALTER TABLE dbo.product_name ALTER COLUMN pn_washing NVARCHAR(256) NOT NULL;
ALTER TABLE dbo.product_name ALTER COLUMN pn_lining NVARCHAR(256) NOT NULL;
ALTER TABLE dbo.product_name ALTER COLUMN pn_age NVARCHAR(256) NOT NULL;
GO
ALTER TABLE dbo.item ALTER COLUMN i_variant_code NVARCHAR(50) NOT NULL;
ALTER TABLE dbo.item ALTER COLUMN i_product_group NVARCHAR(128) NOT NULL;
ALTER TABLE dbo.item ALTER COLUMN i_product_code NVARCHAR(50) NOT NULL;
ALTER TABLE dbo.item ALTER COLUMN i_leg_length NVARCHAR(256) NOT NULL;
ALTER TABLE dbo.item ALTER COLUMN i_colour NVARCHAR(256) NOT NULL;
ALTER TABLE dbo.item ALTER COLUMN i_price MONEY NOT NULL;
GO

-- From table CustomerCity we got 4 tables: Customer, City, County, Region
ALTER TABLE dbo.customer ALTER COLUMN cus_id BIGINT NOT NULL;
ALTER TABLE dbo.customer ALTER COLUMN cus_first_name NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.customer ALTER COLUMN cus_last_name NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.customer ALTER COLUMN cus_date_registered DATETIME NOT NULL;
ALTER TABLE dbo.customer ALTER COLUMN cus_city NVARCHAR(255) NOT NULL;
GO
ALTER TABLE dbo.city ALTER COLUMN ci_city NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.city ALTER COLUMN ci_county NVARCHAR(255) NOT NULL;
GO
ALTER TABLE dbo.county ALTER COLUMN co_county NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.county ALTER COLUMN co_region NVARCHAR(255) NOT NULL;
GO
ALTER TABLE dbo.region ALTER COLUMN r_region NVARCHAR(255) NOT NULL;
ALTER TABLE dbo.region ALTER COLUMN r_country NVARCHAR(255) NOT NULL;
GO

-- From table OrderItem we got 3 tables: OrderItem, Order and Item (already created)
ALTER TABLE dbo.order_item ALTER COLUMN oi_number NVARCHAR(32) NOT NULL;
ALTER TABLE dbo.order_item ALTER COLUMN oi_variant_code NVARCHAR(50) NOT NULL;
ALTER TABLE dbo.order_item ALTER COLUMN oi_product_group NVARCHAR(128) NOT NULL;
ALTER TABLE dbo.order_item ALTER COLUMN oi_quantity INT NOT NULL;
ALTER TABLE dbo.order_item ALTER COLUMN oi_line_item_total MONEY NOT NULL;
ALTER TABLE dbo.order_item ALTER COLUMN oi_order_number NVARCHAR(50) NOT NULL;
GO
ALTER TABLE dbo.[order] ALTER COLUMN o_number NVARCHAR(50) NOT NULL;
ALTER TABLE dbo.[order] ALTER COLUMN o_create_date DATETIME NOT NULL;
ALTER TABLE dbo.[order] ALTER COLUMN o_status_code INT NOT NULL;
ALTER TABLE dbo.[order] ALTER COLUMN o_customer_id BIGINT NOT NULL;
ALTER TABLE dbo.[order] ALTER COLUMN o_billing_currency NVARCHAR(8) NOT NULL;
GO
-- Check result
SELECT * FROM INFORMATION_SCHEMA.COLUMNS;

-- Check duplicates in new tables before creating PKs and FKs --------------------------------------------
USE mumsnet;
GO
-- Table product. PK: p_code. Duplicates PKs: 603
SELECT p_code, COUNT(p_code) AS duplicates
FROM product
GROUP BY p_code
HAVING COUNT(p_code) > 1;
GO

SELECT * FROM product WHERE p_code = '11011'
GO

WITH duplicates AS(
   SELECT p_code,
       RN = ROW_NUMBER()OVER(PARTITION BY p_code ORDER BY p_code)
   FROM product
)
DELETE FROM duplicates WHERE RN > 1
GO

SELECT * FROM product WHERE p_code = '11011'
GO

-- Table product_name. PK: pn_name. Duplicates PKs: 583
SELECT pn_name, COUNT(pn_name) AS duplicates
FROM product_name
GROUP BY pn_name
HAVING COUNT(pn_name) > 1;
GO

SELECT * FROM product_name WHERE pn_name = '100% Organic Cotton Sleepsuit'
GO

WITH duplicates AS(
   SELECT pn_name,
       RN = ROW_NUMBER()OVER(PARTITION BY pn_name ORDER BY pn_name)
   FROM product_name
)
DELETE FROM duplicates WHERE RN > 1
GO

SELECT * FROM product_name WHERE pn_name = '100% Organic Cotton Sleepsuit'
GO

-- Table item. PK: i_variant_code, i_product_group. Duplicates PKs: 0
SELECT i_variant_code, i_product_group, COUNT(*) AS duplicates
FROM item
GROUP BY i_variant_code, i_product_group
HAVING COUNT(*) > 1;
GO

-- Table customer. PK: cus_id. Duplicates PKs: 0
SELECT cus_id, COUNT(cus_id) AS duplicates
FROM customer
GROUP BY cus_id
HAVING COUNT(cus_id) > 1;
GO

-- Table city. PK: ci_city. Duplicates PKs: 1298
SELECT ci_city, COUNT(ci_city) AS duplicates
FROM city
GROUP BY ci_city
HAVING COUNT(ci_city) > 1;
GO

SELECT * FROM city WHERE ci_city = 'Cheltenham'
GO

WITH duplicates AS(
   SELECT ci_city,
       RN = ROW_NUMBER()OVER(PARTITION BY ci_city ORDER BY ci_city)
   FROM city
)
DELETE FROM duplicates WHERE RN > 1
GO

SELECT * FROM city WHERE ci_city = 'Cheltenham'
GO

-- Table county. PK: co_county. Duplicates PKs: 111
SELECT co_county, COUNT(co_county) AS duplicates
FROM county
GROUP BY co_county
HAVING COUNT(co_county) > 1;
GO

SELECT * FROM county WHERE co_county = 'Leicestershire'
GO

WITH duplicates AS(
   SELECT co_county,
       RN = ROW_NUMBER()OVER(PARTITION BY co_county ORDER BY co_county)
   FROM county
)
DELETE FROM duplicates WHERE RN > 1
GO

SELECT * FROM county WHERE co_county = 'Leicestershire'
GO

-- Table region. PK: r_region. Duplicates PKs: 16
SELECT r_region, COUNT(r_region) AS duplicates
FROM region
GROUP BY r_region
HAVING COUNT(r_region) > 1;
GO

SELECT * FROM region WHERE r_region = 'Leinster'
GO

WITH duplicates AS(
   SELECT r_region,
       RN = ROW_NUMBER()OVER(PARTITION BY r_region ORDER BY r_region)
   FROM region
)
DELETE FROM duplicates WHERE RN > 1
GO

SELECT * FROM region WHERE r_region = 'Leinster'
GO

-- Table order_item. PK: oi_number. Duplicates PKs: 0
SELECT oi_number, COUNT(oi_number) AS duplicates
FROM order_item
GROUP BY oi_number
HAVING COUNT(oi_number) > 1;
GO

-- Table order. PK: o_number. Duplicates PKs: 12,541
SELECT o_number, COUNT(o_number) AS duplicates
FROM [order]
GROUP BY o_number
HAVING COUNT(o_number) > 1;
GO

SELECT * FROM [order] WHERE o_number = 'OR\18112005\01'
GO

WITH duplicates AS(
   SELECT o_number,
       RN = ROW_NUMBER()OVER(PARTITION BY o_number ORDER BY o_number)
   FROM [order]
)
DELETE FROM duplicates WHERE RN > 1
GO

SELECT * FROM [order] WHERE o_number = 'OR\18112005\01'
GO

-- Adding constraints -----------------------------------------------------------------
USE mumsnet;
GO
-- PKs
-- Table product
ALTER TABLE dbo.product
ADD CONSTRAINT pk_product PRIMARY KEY  (p_code);
GO
-- Table product_name
ALTER TABLE dbo.product_name
ADD CONSTRAINT pk_product_name PRIMARY KEY (pn_name);
GO
-- Table item
ALTER TABLE dbo.item
ADD CONSTRAINT pk_item PRIMARY KEY (i_variant_code, i_product_group);
GO
-- Table customer
ALTER TABLE dbo.customer
ADD CONSTRAINT pk_customer PRIMARY KEY (cus_id);
GO
-- Table city
ALTER TABLE dbo.city
ADD CONSTRAINT pk_city PRIMARY KEY (ci_city);
GO
-- Table county
ALTER TABLE dbo.county
ADD CONSTRAINT pk_county PRIMARY KEY (co_county);
GO
-- Table region
ALTER TABLE dbo.region
ADD CONSTRAINT pk_region PRIMARY KEY (r_region);
GO
-- Table order_item
ALTER TABLE dbo.order_item
ADD CONSTRAINT pk_order_item PRIMARY KEY CLUSTERED (oi_number);
GO
-- Table order
ALTER TABLE dbo.[order]
ADD CONSTRAINT pk_order PRIMARY KEY CLUSTERED (o_number);
GO

-- FKs
-- Table product
ALTER TABLE dbo.product
ADD CONSTRAINT fk_product_to_name FOREIGN KEY (p_name) REFERENCES dbo.product_name (pn_name);
GO
-- Table item
ALTER TABLE dbo.item
ADD CONSTRAINT fk_item_to_product FOREIGN KEY (i_product_code) REFERENCES dbo.product (p_code);
GO
-- Table customer
ALTER TABLE dbo.customer
ADD CONSTRAINT fk_customer_to_city FOREIGN KEY (cus_city) REFERENCES dbo.city (ci_city);
GO
-- Table city
ALTER TABLE dbo.city
ADD CONSTRAINT fk_city_to_county FOREIGN KEY (ci_county) REFERENCES dbo.county (co_county);
GO
-- Table county
ALTER TABLE dbo.county
ADD CONSTRAINT fk_county_to_region FOREIGN KEY (co_region) REFERENCES dbo.region (r_region);
GO
-- Table order_item
ALTER TABLE dbo.order_item
ADD CONSTRAINT fk_order_item_to_item FOREIGN KEY (oi_variant_code, oi_product_group) REFERENCES dbo.item (i_variant_code, i_product_group);
GO
ALTER TABLE dbo.order_item
ADD CONSTRAINT fk_order_item_to_order FOREIGN KEY (oi_order_number) REFERENCES dbo.[order] (o_number);
GO
-- Table order
ALTER TABLE dbo.[order]
ADD CONSTRAINT fk_order_to_customer FOREIGN KEY (o_customer_id) REFERENCES dbo.customer (cus_id);
GO

-- Default constraints
-- Table Customer
ALTER TABLE dbo.customer
ADD CONSTRAINT df_customer_date_registered DEFAULT (CURRENT_TIMESTAMP) FOR cus_date_registered;
GO
-- Table order
ALTER TABLE dbo.[order]
ADD CONSTRAINT df_order_create_date DEFAULT (CURRENT_TIMESTAMP) FOR o_create_date;
GO

-- Check constraints
-- Table item
ALTER TABLE dbo.item
ADD CONSTRAINT ck_price CHECK (i_price > 0);
GO
--Table order_item
ALTER TABLE dbo.order_item
ADD CONSTRAINT ck_quantity CHECK (oi_quantity > 0);
GO
ALTER TABLE dbo.order_item
ADD CONSTRAINT ck_line_item_total CHECK (oi_line_item_total > 0);
GO
--Table order
ALTER TABLE dbo.[order]
ADD CONSTRAINT ck_status_code CHECK (o_status_code >= 0 AND o_status_code <= 4);
GO

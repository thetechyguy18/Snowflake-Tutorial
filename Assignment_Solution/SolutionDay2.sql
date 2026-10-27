--> Phase-1: Table Types (Permanent, Transient, Temporary)

-- 1st on Permanent Table Creation

-- Task 1:
-- Create or replace a permanent table PERM_ORDERS with ORDER_ID (INT) and ORDER_AMT (NUMBER) inside ASSIGNMENT_DB.STAGING
CREATE OR REPLACE TABLE ASSIGNMENT_DB.STAGING.PERM_ORDERS (
    ORDER_ID INT,
    ORDER_AMT NUMBER
);

-- 2nd on Transient Table Creation

-- Task 2:
-- Create or replace a transient table TRANSIENT_ORDERS with ORDER_ID (INT) and ORDER_AMT (NUMBER) inside ASSIGNMENT_DB.STAGING
CREATE OR REPLACE TRANSIENT TABLE ASSIGNMENT_DB.STAGING.TRANSIENT_ORDERS (
    ORDER_ID INT,
    ORDER_AMT NUMBER
);

-- 3rd on Temporary Table Creation

-- Task 3:
-- Create or replace a temporary table TEMP_SESSION_LOG with SESSION_ID (STRING) and LOG_TIME (TIMESTAMP) inside ASSIGNMENT_DB.STAGING
CREATE OR REPLACE TEMPORARY TABLE ASSIGNMENT_DB.STAGING.TEMP_SESSION_LOG (
    SESSION_ID STRING,
    LOG_TIME TIMESTAMP
);

-- 4th on Table Inspection

-- Task 4:
-- Show all tables created inside the schema ASSIGNMENT_DB.STAGING and inspect their table types (kind)
SHOW TABLES IN SCHEMA ASSIGNMENT_DB.STAGING;

--> Phase-2: Data Ingestion and Verification

-- 1st on Transient Table Ingestion

-- Task 1:
-- Insert 6 sample records into ASSIGNMENT_DB.STAGING.TRANSIENT_ORDERS
INSERT INTO ASSIGNMENT_DB.STAGING.TRANSIENT_ORDERS (ORDER_ID, ORDER_AMT) VALUES
(1, 140),
(2, 343),
(3, 234),
(4, 245),
(5, 321),
(6, 231);

-- Task 2:
-- Query all records from ASSIGNMENT_DB.STAGING.TRANSIENT_ORDERS to verify the data
SELECT * FROM ASSIGNMENT_DB.STAGING.TRANSIENT_ORDERS;

-- 2nd on Temporary Table Ingestion

-- Task 3:
-- Insert 2 session log records into ASSIGNMENT_DB.STAGING.TEMP_SESSION_LOG using CURRENT_TIMESTAMP()
INSERT INTO ASSIGNMENT_DB.STAGING.TEMP_SESSION_LOG (SESSION_ID, LOG_TIME) VALUES
('1001', CURRENT_TIMESTAMP()),
('1002', CURRENT_TIMESTAMP());

-- Task 4:
-- Query all records from ASSIGNMENT_DB.STAGING.TEMP_SESSION_LOG to verify the data
SELECT * FROM ASSIGNMENT_DB.STAGING.TEMP_SESSION_LOG;

--> Phase-3: Views (Standard, Secure, and Materialized)

-- 1st on Standard View

-- Task 1:
-- Create or replace a standard view V_ORDERS_FILTERED that selects all columns from TRANSIENT_ORDERS where ORDER_AMT > 200
CREATE OR REPLACE VIEW ASSIGNMENT_DB.STAGING.V_ORDERS_FILTERED AS
SELECT * FROM ASSIGNMENT_DB.STAGING.TRANSIENT_ORDERS
WHERE ORDER_AMT > 200;

-- Task 2:
-- Query V_ORDERS_FILTERED to verify the filtered output
SELECT * FROM ASSIGNMENT_DB.STAGING.V_ORDERS_FILTERED;

-- 2nd on Secure View

-- Task 3:
-- Create or replace a secure view V_ORDERS_SECURE exposing ORDER_ID and ORDER_AMT from TRANSIENT_ORDERS where ORDER_AMT > 300 to hide view definitions from unauthorized users
CREATE OR REPLACE SECURE VIEW ASSIGNMENT_DB.STAGING.V_ORDERS_SECURE AS
SELECT ORDER_ID, ORDER_AMT FROM ASSIGNMENT_DB.STAGING.TRANSIENT_ORDERS
WHERE ORDER_AMT > 300;

-- Task 4:
-- Query V_ORDERS_SECURE to verify the result
SELECT * FROM ASSIGNMENT_DB.STAGING.V_ORDERS_SECURE;

-- 3rd on Materialized View

-- Task 5:
-- Create or replace a materialized view MV_TOTAL_ORDERS_AMT computing the sum of ORDER_AMT as TOTAL_AMT from TRANSIENT_ORDERS
CREATE OR REPLACE MATERIALIZED VIEW ASSIGNMENT_DB.STAGING.MV_TOTAL_ORDERS_AMT AS
SELECT SUM(ORDER_AMT) AS TOTAL_AMT FROM ASSIGNMENT_DB.STAGING.TRANSIENT_ORDERS;

-- Task 6:
-- Query the materialized view MV_TOTAL_ORDERS_AMT to verify the pre-computed aggregate
SELECT * FROM ASSIGNMENT_DB.STAGING.MV_TOTAL_ORDERS_AMT;

--> Phase-4: Micro-Partitions and Clustering Inspection

-- Task 1:
-- Check clustering metadata and micro-partition depth for ASSIGNMENT_DB.STAGING.PERM_ORDERS using the system function SYSTEM$CLUSTERING_INFORMATION
SELECT SYSTEM$CLUSTERING_INFORMATION('ASSIGNMENT_DB.STAGING.PERM_ORDERS');

```
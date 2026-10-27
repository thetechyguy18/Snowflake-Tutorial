--> Phase-1: File Format Management

-- 1st on Delimited File Format Creation

-- Task 1:
-- Create or replace a CSV file format named CSV_FF inside ASSIGNMENT_DB.STAGING with comma delimiter, skipping 1 header row, and handling NULL strings
CREATE OR REPLACE FILE FORMAT ASSIGNMENT_DB.STAGING.CSV_FF
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    NULL_IF = ('NULL', 'null');

-- 2nd on Semi-Structured File Formats

-- Task 2:
-- Create or replace a JSON file format named JSON_FF inside ASSIGNMENT_DB.STAGING
CREATE OR REPLACE FILE FORMAT ASSIGNMENT_DB.STAGING.JSON_FF
    TYPE = 'JSON';

-- Task 3:
-- Create or replace a PARQUET file format named PARQUET_FF inside ASSIGNMENT_DB.STAGING
CREATE OR REPLACE FILE FORMAT ASSIGNMENT_DB.STAGING.PARQUET_FF
    TYPE = 'PARQUET';

-- 3rd on File Format Inspection

-- Task 4:
-- Show all file formats available inside the schema ASSIGNMENT_DB.STAGING
SHOW FILE FORMATS IN SCHEMA ASSIGNMENT_DB.STAGING;

--> Phase-2: External Stage Creation using Credentials (SAS Token)

-- 1st on SAS Token External Stage Creation

-- Task 1:
-- Create or replace an external stage named AZURE_SAS_STAGE in ASSIGNMENT_DB.STAGING pointing to Azure Blob Storage using a SAS token and attaching the file format CSV_FF
CREATE OR REPLACE STAGE ASSIGNMENT_DB.STAGING.AZURE_SAS_STAGE
    URL = 'azure://snowflake1808.blob.core.windows.net/salescontainer/'
    CREDENTIALS = (AZURE_SAS_TOKEN = '?sp=racwdlmeop&st=2026-09-24T17:44:54Z&se=2026-09-25T01:59:54Z&spr=https&sv=2026-02-06&sr=c&sig=%2BB63WW%2FdYItcwbqOCKeeRu1hh1d%2BrTE%2FG29br2N5IvY%3D')
    FILE_FORMAT = ASSIGNMENT_DB.STAGING.CSV_FF;

-- 2nd on Stage Inspection

-- Task 2:
-- List all files currently present in the external stage ASSIGNMENT_DB.STAGING.AZURE_SAS_STAGE
LIST @ASSIGNMENT_DB.STAGING.AZURE_SAS_STAGE;

--> Phase-3: Data Ingestion with COPY INTO

-- 1st on Target Table Creation

-- Task 1:
-- Create or replace a target staging table STG_ORDERS with ORDER_DATE (DATE), REGION (STRING), ITEM (STRING), and ORDER_QTY (INT) inside ASSIGNMENT_DB.STAGING
CREATE OR REPLACE TABLE ASSIGNMENT_DB.STAGING.STG_ORDERS (
    ORDER_DATE DATE,
    REGION STRING,
    ITEM STRING,
    ORDER_QTY INT
);

-- 2nd on Pattern-Based Loading

-- Task 2:
-- Load data into STG_ORDERS from AZURE_SAS_STAGE matching regex pattern '.*ORDERS.*\.csv' and handle parsing errors using ON_ERROR = 'CONTINUE'
COPY INTO ASSIGNMENT_DB.STAGING.STG_ORDERS
FROM @ASSIGNMENT_DB.STAGING.AZURE_SAS_STAGE
PATTERN = '.*ORDERS.*\.csv'
ON_ERROR = 'CONTINUE';

-- Task 3:
-- Check the total record count loaded into ASSIGNMENT_DB.STAGING.STG_ORDERS
SELECT COUNT(*) FROM ASSIGNMENT_DB.STAGING.STG_ORDERS;

-- 3rd on Loading Duplicate/Previously Loaded Files

-- Task 4:
-- Re-run the COPY INTO command on STG_ORDERS using the FORCE = TRUE option to reload already ingested files
COPY INTO ASSIGNMENT_DB.STAGING.STG_ORDERS
FROM @ASSIGNMENT_DB.STAGING.AZURE_SAS_STAGE
PATTERN = '.*ORDERS.*\.csv'
FORCE = TRUE;

-- 4th on Specific File Loading

-- Task 5:
-- Load only a specific file named 'ORDERS_2024.CSV' from the stage into STG_ORDERS
COPY INTO ASSIGNMENT_DB.STAGING.STG_ORDERS
FROM @ASSIGNMENT_DB.STAGING.AZURE_SAS_STAGE
FILES = ('ORDERS_2024.CSV');

--> Phase-4: Secure Storage Integration with Azure

-- 1st on Storage Integration Creation

-- Task 1:
-- Create or replace a storage integration named AZURE_STORAGE_INT of type EXTERNAL_STAGE for Azure provider with your tenant ID and allowed storage locations
CREATE OR REPLACE STORAGE INTEGRATION AZURE_STORAGE_INT
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = AZURE
    ENABLED = TRUE
    AZURE_TENANT_ID = 'b5516084-f1d0-49ae-baa0-1d1b1dffcb0c'
    STORAGE_ALLOWED_LOCATIONS = (
        'azure://snowflake1808.blob.core.windows.net/salescontainer/'
    );

-- 2nd on Integration Verification and Cloud Handshake

-- Task 2:
-- Describe the storage integration AZURE_STORAGE_INT to retrieve AZURE_CONSENT_URL and AZURE_MULTI_TENANT_APP_NAME
DESC STORAGE INTEGRATION AZURE_STORAGE_INT;

--> Phase-5: External Stage Creation using Storage Integration

-- 1st on Secure Stage Creation

-- Task 1:
-- Create or replace an external stage named AZURE_ORDERS_STAGE in ASSIGNMENT_DB.STAGING referencing the storage integration AZURE_STORAGE_INT
CREATE OR REPLACE STAGE ASSIGNMENT_DB.STAGING.AZURE_ORDERS_STAGE
    URL = 'azure://snowflake1808.blob.core.windows.net/salescontainer/'
    STORAGE_INTEGRATION = AZURE_STORAGE_INT
    FILE_FORMAT = ASSIGNMENT_DB.STAGING.CSV_FF;

-- 2nd on Stage Verification

-- Task 2:
-- List all files available in the secure stage ASSIGNMENT_DB.STAGING.AZURE_ORDERS_STAGE
LIST @ASSIGNMENT_DB.STAGING.AZURE_ORDERS_STAGE;

-- Task 3:
-- Execute a COPY INTO statement to load data from the secure stage ASSIGNMENT_DB.STAGING.AZURE_ORDERS_STAGE into STG_ORDERS
COPY INTO ASSIGNMENT_DB.STAGING.STG_ORDERS
FROM @ASSIGNMENT_DB.STAGING.AZURE_ORDERS_STAGE
PATTERN = '.*ORDERS.*\.csv'
ON_ERROR = 'CONTINUE';

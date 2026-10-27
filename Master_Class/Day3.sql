-- Create a File Format, It is how Snowflake interpret the data files.

create or replace File format demo_db.raw.CSV_FF
TYPE = 'CSV',
FIELD_DELIMITER = ','
SKIP_HEADER = 1
NULL_IF = ('NULL','null');

-- With Json 
create or replace file format demo_db.raw.JSON_FF 
TYPE = 'JSON'

-- WITH PARQUET 
CREATE OR REPLACE FILE FORMAT DEMO_DB.RAW.PARQUET_FF
TYPE = 'PARQUET'
-- checking the file format 

show file formats in schema demo_db.raw

-- Creating a External Stage using the SAS Token 

-- A Stage a location, snowflake uses to access the files for loading into or unloading from tables.
-- Not useful in production 

-- NOTE Don't give the whole SAS url it shoud start with ?sp= and provide permission while generating the token
create or replace stage demo_db.raw.AZURE_STAGE
URL = 'azure://snowflake1808.blob.core.windows.net/salescontainer/'
CREDENTIALS = (AZURE_SAS_TOKEN = '?sp=racwdlmeop&st=2026-09-24T17:44:54Z&se=2026-09-25T01:59:54Z&spr=https&sv=2026-02-06&sr=c&sig=%2BB63WW%2FdYItcwbqOCKeeRu1hh1d%2BrTE%2FG29br2N5IvY%3D')
FILE_FORMAT = demo_db.raw.CSV_FF

-- Inspect the files
list @demo_db.raw.AZURE_STAGE

-- Create a target table 

CREATE OR REPLACE TABLE DEMO_DB.RAW.STG_SALES(
DATE DATE,
COUNTRY STRING,
PRODUCT STRING,
SALES INT 
)

COPY INTO DEMO_DB.RAW.STG_SALES
FROM @DEMO_DB.RAW.AZURE_STAGE
PATTERN = '.*SALES.*\.csv'
ON_ERROR = 'CONTINUE';

SELECT COUNT(*) FROM DEMO_DB.RAW.STG_SALES

-- Snowflake recogines the files it has loaded so it won't load these again.

-- But if you wish you can use the FORCE command to load the file, it tells snowflake to load the files again.
COPY INTO DEMO_DB.RAW.STG_SALES
FROM @DEMO_DB.RAW.AZURE_STAGE
force = true

-- loading specific files, useful when we require to laod a specific files.  

copy into demo_db.raw.stg_sales
from @demo_db.raw.azure_stage
files = ('SALES2010.CSV')

--- Remember
-- FILE FORMAT = How to Read?
-- STAGE = Where? 
-- copy into = where to store?

-- Now we shoudl a Stoage Integration instead of using SAS Token 
-- "Snowflake is allowed to authenticate with Azure and access this specific Azure storage location.
-- Creating Storage Integration

CREATE OR REPLACE STORAGE INTEGRATION AZURE_ADLS_INT
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = AZURE
  ENABLED = TRUE
  AZURE_TENANT_ID = 'b5516084-f1d0-49ae-baa0-1d1b1dffcb0c'
  STORAGE_ALLOWED_LOCATIONS = (
    'azure://snowflake1808.blob.core.windows.net/salescontainer/'
  );
-- check and Authenticate 


DESC STORAGE INTEGRATION AZURE_ADLS_INT;



--Here Find the Azure_Consent_url and open that link in new tab and accept 
-- With this Trust relationship is builded between Snowflake and azure 

-- Find the AZURE_MULTI_TENANT_APP_NAME and grant the permission for this inside IAM Azure DataLake
-- Storage Account → Access Control (IAM) → Add role assignment 
-- Choose role Storage Blob Data Contributor role to service principle remember 
-- only add till _ value like mjbgnqsnowflakepacint not (mjbgnqsnowflakepacint_1790275730240)

-- Now Create a new stage 

CREATE OR REPLACE STAGE DEMO_DB.RAW.AZURE_SALES_STAGE
  URL = 'azure://snowflake1808.blob.core.windows.net/salescontainer/'
  STORAGE_INTEGRATION = AZURE_ADLS_INT;

list @DEMO_DB.RAW.AZURE_SALES_STAGE

-- Now we can run copy into fromt this stage as well.
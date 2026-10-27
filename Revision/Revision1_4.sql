-- This Lab is for the Revision, till Day 4 

-- Create DataBase 

Create Database Revision;

-- Create Schema

Create Schema Revision.practice

-- Create a table 

Create or replace table revision.practice.emp(
id int,
name string
) ;

select * from revision.practice.emp

-- Use the Database now 
use revision

-- use schema 

use revision.practice


-- insert some records now 

insert into emp
values (1, 'raj'),
(2,'vansh'),
(3,'mohit')


select * from emp;


-- Create a warehouse 

Create WAREHOUSE IF NOT EXISTS Revision_wh 
WITH 
    WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 200
    AUTO_RESUME = TRUE 
    INITIALLY_SUSPENDED = TRUE 

USE WAREHOUSE REVISION_WH


-- Create Transient & Temporary Table Just repalce keywords

Create or Replace TEMPORARY Table Temp_Data(
id int, 
name string 
) 


insert into temp_data 
values 
(2,'Raj'),(3,'fjs')

select * from temp_data 
-- This only exists in a session Do it yourself for transient data 

-- Create Views 

create or replace secure view secure_view_Customer_india 
as 
    select customerid, firstname,lastname,email, from 
    Transient_Customer
    where country = 'India'

select * from secure_view_Customer_india

-- Create File Formats 

Create or Replace File Format CSV_FF
type = 'csv'
field_delimiter = ','
skip_header = 1
null_if = ('NULL','null')

-- Create Other FF on your own for Parequet & Json 

-- Creating a storage Integration 


CREATE or replace Storage INTEGRATION Revision_STORAGE_IN
TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'AZURE'
  ENABLED = TRUE
  AZURE_TENANT_ID = 'b5516084-f1d0-49ae-baa0-1d1b1dffcb0c'
  STORAGE_ALLOWED_LOCATIONS = ('azure://snowflakepractice18.blob.core.windows.net/containerforpractice/');

-- Give permision Azure side 

desc storage integration Revision_STORAGE_IN

-- Open AZURE_CONSENT_URL and click yes

-- Click on AZURE_MULTI_TENANT_APP_NAME and give permission in IAM blob data contributor

-- Now you can create a stage 

create or replace stage stage_practice_emp
url = 'azure://snowflakepractice18.blob.core.windows.net/containerforpractice/EmployeeData/'
storage_integration = Revision_STORAGE_IN

list @stage_practice_emp

-- Create Table Customers & copy this data 

Create or REPLACE TRANSIENT Table Transient_Customer(
CustomerID string,
CustomerNumber string,
FirstName string,
LastName string,
FullName string,
Gender string,
DateOfBirth string,
Email string,
PhoneNumber string,
AddressLine1 string,
AddressLine2 string,
City string,
StateProvince string,
PostalCode int,
Country string,
CustomerSegment string,
CustomerCategory string,
RegistrationDate string,
PreferredLanguage string,
PreferredCurrency  string,
LoyaltyProgramID  string,
LoyaltyPoints string,
MarketingOptIn boolean,
EmailOptIn  boolean,
SMSOptIn  boolean,
CustomerStatus string
);

copy into Transient_Customer
from @stage_practice_emp
file_format = CSV_FF


select * from Transient_Customer




-- Create a Notification Integration 

-- Add a queue and Event 

create or replace notification integration Snowpipe_Notification_Integration
    ENABLED = TRUE
    TYPE = queue 
    notification_provider = azure_storage_queue
    Azure_storage_queue_primary_uri ='https://snowflakepractice18.queue.core.windows.net/praticequeue'
    azure_tenant_id = 'b5516084-f1d0-49ae-baa0-1d1b1dffcb0c'

desc notification integration Snowpipe_Notification_Integration

-- Give Permission AZURE_CONSENT_URL
-- Add role for AZURE_MULTI_TENANT_APP_NAME

-- Create a file format json 

create or replace file format json_ff
type = 'json'

-- Create a Stage 
CREATE OR REPLACE STAGE json_stage
  STORAGE_INTEGRATION = Revision_STORAGE_IN
  URL = 'azure://snowflakepractice18.blob.core.windows.net/containerforpractice/JsonData'
  FILE_FORMAT = json_ff

list @json_stage

  -- Create a Table 
  create or replace table employee_json(
  payload VARIANT
  )

  -- Snow - pipe Creation 

  create or replace pipe employee_json_pipe
      AUTO_INGEST = TRUE
    INTEGRATION = Snowpipe_Notification_Integration
AS
    COPY INTO employee_json
    FROM @json_stage
    FILE_FORMAT = json_ff
    ON_ERROR = 'CONTINUE';

select
    payload:EmployeeKey::Int as Id,
    payload:EmpName::String as Name,
    payload:Contact::String as contact
from employee_json



ALTER PIPE employee_json_pipe REFRESH;
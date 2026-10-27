-- Create a Database
-- A database is basically a logical grouping of schema, while schema is a logical grouping of objects.
Create database if not exists demo_db 

-- Use Database 
Use database demo_db

-- Create a Schema 
create schema if not exists demo_db.raw;

-- Use Schema 
use schema raw -- or use schema demo_db.raw.

-- By the use of Data & Schema we can directly write 
select * from Employees -- instead of select * from demo_db.raw.employees;

-- This is because snowflake knows Current Base is Demo_Db i.e select current_database()
-- And the current schema is raw i.e select current_schema()

-- Creating a warehouse from SQL Query 

Create warehouse if not exists TTG_WH 
WITH 
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE 
    INITIALLY_SUSPENDED = TRUE;

-- USE THE CREATED WAREHOUSE
USE WAREHOUSE TTG_WH

-- CHECK THE CURRENT WAREHOUSE USING BELOW QUERY 

SELECT CURRENT_WAREHOUSE()

-- Now check the all important objects we just created or already exists 

select current_user() -- wil return the current user
select current_role()  -- wil return the current role
select current_database() -- wil return the current Database
select current_schema() -- wil return the current Schema
select current_warehouse() -- wil return the current Warehouse

    
-- Alter the warehouse 

ALTER Warehouse TTG_WH 
SET WAREHOUSE_SIZE = 'LARGE'

Alter Warehouse TTG_WH
set auto-suspend = False 

-- Manlly Resume the warehouse 

Alter Warehosue TTG_WH RESUME 

Alter Warehouse TTG_WH RESUME IF SUSPENDED

-- Check the Warehouse states/meta-data

show warehouses 

-- Suspend Warehouse After Work Done. 

Alter warehouse TTG_WH suspend;

-- Commands to Monitor Warehouse State 
Show warehouses

desc warehouse ttg_wh

show warehouses like 'ttg_wh'

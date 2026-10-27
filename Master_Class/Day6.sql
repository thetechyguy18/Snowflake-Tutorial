-- Time Travel (before & AT)
-- Basically it allows us to access the historical version of data, and recover certain dropped/changed objects

-- At allows to query a table at a specific point. 
-- Before allow to query a table before at metioned point 

select * from merge_target_sales
at (offset => -60 * 34) -- At this particular time, we didn't inserted those 4 records 
order by id desc


-- With TimeStamp 

select * from stg_sales
at (
TIMESTAMP => '2026-09-27 01:00:20'::TIMESTAMP) -- At this particular time, we didn't inserted those 4 records 

-- Using Before 

SELECT * 
FROM tv_products 
BEFORE (TIMESTAMP => '2026-09-28 00:54:00'::timestamp);


-- Drop Table 

drop table tv_products

-- check for the table 

select * from tv_products

undrop table tv_products

-- Drop vs Delete Major Difference


-- Zero Copy Cloning 
-- It has refers / points to same micropartitions, when data changes it creates a new Partitions 

--Lets create two Schema DEV & PROD 

create schema demo_db.dev 

create schema demo_db.prod

-- Now we will copy the data from prod to Dev 

Create or replace table demo_db.prod.prod_sales
clone demo_db.raw.stg_sales;

-- Here Partitions of stg_sales are points to prod sales 

select * from demo_db.prod.prod_sales

-- Now Creating in dev too 

Create or replace table demo_db.dev.dev_sales
clone demo_db.prod.prod_sales;


-- Check the data 

select count(*) from demo_db.dev.dev_sales;

select count(*) from demo_db.prod.prod_sales;


-- Insert or delete the data in Dev 

delete FROM demo_db.dev.dev_sales
where product = 'TAB'

-- 
-- Verify the data 

select count(*) from demo_db.dev.dev_sales;

select count(*) from demo_db.prod.prod_sales;

-- Note: Clone doesn't mean same privlpeges suppose Prod table is accessibleto 10 users but In dev there is no such 

-- We can also do copy clone + Time Travel 

create or replace table demo_db.dev.new_table
clone demo_db.prod.prod_sales
at (offset => -60 * 4) -- 4 minutes before


select count(*) from  demo_db.dev.new_table


-- RBACs Role Based Accesss Control ( Extremely Important)

-- Basically Instead of giving the permission to user's we create a like Data_Analyst, Data_Engineer then add user to this particular role 

-- Role Vs Privilege 
-- Role is a container that holds group of permission like Analyst_Role 
-- Privilege is a specific permsission Select, Update, Insert, Delete, Create Table, Ownership 

-- Lets Create a Role 

Use role ACCOUNTADMIN

-- Creating a role here 
create role Analyst_Role


-- Adding a privilege to the role.
GRANT USAGE 
ON DATABASE DEMO_DB -- This role only has access to use its Database not the schema and Tables 
TO ROLE ANALYST_ROLE; 

-- Adding SELECT for SCHEMA
GRANT USAGE 
ON schema DEMO_DB.raw -- This role only has access to use schema not Tables 
TO ROLE ANALYST_ROLE; 


-- Now adding for all the tabes 

GRANT select 
ON ALL TABLES in SCHEMA DEMO_DB.RAW -- This gives access to use all Tables inside mention scheam 
TO ROLE ANALYST_ROLE; 

-- But this role can query only existing tables, means only the tables which Just Existed at the time of Query

-- Now for Future tables, you again need to add privilege

grant select 
on future tables in schema demo_db.raw
to role analyst_role;

-- Also SnowFlake allows role to be granted to other roles 

GRANT ROLE ANALYST_ROLE 
TO ROLE SYSADMIN; -- Here System Admin Inherits the Analyst Role

-- Now We can grant/add users to specific role 

GRANT ROLE ANALYST_ROLE 
TO USER john_DataAnaylst -- Reffer User_Creation Notebook for the Creation of roles

-- Then user can activate a role with use role Analyst_Role 

-- Ownership: is from diff from select, if a role owns the ownership it can perform alter/drop and manage grant privileges to RBAC

use role ANALYST_ROLE

drop table demo_db.raw.stg_sales

undrop table demo_db.raw.stg_sales

select * from demo_db.raw.stg_sales


-- Create Table using new role 

Create or replace table demo_db.raw.check_role(
id int
);
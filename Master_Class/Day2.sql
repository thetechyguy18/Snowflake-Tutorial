-- Creating a permanent table

Create or replace table demo_db.raw.Per_sales(
id int, 
AMT NUMBER
);

-- Creating Transient table 

Create or replace transient table demo_db.raw.transient_sales(
id int, 
amt number
);

-- Creating Temporary Table 

Create or replace temporary table demo_db.raw.temp_sales(
Session_id string,
log_time timestamp
);
-- viewing all tables in a specific schema 

show tables in schema demo_db.raw

-- Inserting some data into the Transient Table 

Insert into demo_db.raw.transient_sales(id, AMT) VALUES
(1,140),
(2,343),
(3,234),
(4,245),
(5,321),
(6,231)

SELECT * FROM DEMO_DB.RAW.TRANSIENT_SALES

-- Inserting some data into the Temporary Table 
insert into demo_db.raw.temp_sales
values 
('1001',current_timestamp()),
('1002',current_timestamp());

select * from demo_db.raw.temp_sales

-- Views 
-- A View is basically a logical defination of a query. Think Table -> Query -> View 
-- A Standard view does not normally store a separate copy of the query results.

Create or replace view demo_db.raw.V_Sales AS 
select * from demo_db.raw.transient_sales 
where AMT > 200

select * from demo_db.raw.V_SALES;


-- Creating a Secure View 
-- Designed for situations where you want to expose the data while protecing the information about 
--underlying view or Designed to prevent users from accessing sensitive information about the view.

-- Syntax 
Create or REPLACE secure view demo_db.raw.V_SALES_Secure as 
select ID, AMT from demo_db.raw.transient_sales 
where AMT > 300

select * from demo_db.raw.v_sales_secure


-- Materliazed View 
-- Unlike normal View, this stoes the data/ query result in storage and it is fast when used.

CREATE OR REPLACE MATERIALIZED VIEW demo_db.raw.V_Sales_Materliazed as 
select sum(amt) as total_AMT from demo_db.raw.transient_sales

select * from demo_db.raw.v_sales_materliazed 

-- What is Micro-Partitions, How do you manage it 
-- To do show one table which is having 20k records then see the results

select SYSTEM$CLUSTERING_INFORMATION(
'demo_db.raw.per_sales'
)

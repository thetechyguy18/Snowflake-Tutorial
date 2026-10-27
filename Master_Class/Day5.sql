-- CTAS 
-- It is a expression to create the table on the go. 

create or replace table  total_sales_products
as
select product, sum(sales) as product_sales from stg_sales
group by product


-- Qualify 
-- it filter the rows based on windows functions i.e it executes after window-function


select 
    product, product_sales, 
    Rank() over( order by product_sales desc) as rank 
from total_sales_products
-- here I can't use where directly to filter the rank 
qualify rank > 3

-- Merge 
-- When Matched Updates records when not matched insert records 



-- crate a staging table for merge 
create or replace table merge_staging_sales 
as 
select row_number() over (order by date) id,* from stg_sales


-- Creataing a target table from the stg_sales

create or replace table merge_target_sales 
as 
select row_number() over (order by date) id,* from stg_sales
where 1 =2 
-- Always false So, only table defination will get create 

-- Empty table 
select * from merge_target_sales

-- Step 1: Add the column to the table, So records can be tracked 
ALTER TABLE merge_target_sales ADD COLUMN updated_at TIMESTAMP_NTZ;


-- Merge Code IMP 

merge into merge_target_sales as target 
using merge_staging_sales as source 
on source.id = target.id 
when matched then update 
    set
        target.date = source.date,
        target.country = source.country,
        target.product = source.product,
        target.sales = source.sales,
        target.updated_at = current_timestamp 
when not matched then 
    INSERT(id,date,country,product,sales,updated_at)
    values(
        SOURCE.ID,
        SOURCE.DATE,
        SOURCE.COUNTRY,
        SOURCE.PRODUCT,
        SOURCE.sales,
        current_timestamp
    );
        

-- Check the loaded data 

select * from merge_target_sales

-- updating some records 
UPDATE merge_staging_sales SET sales = 700 WHERE id = 1;
UPDATE merge_staging_sales SET sales = 820 WHERE id = 2;
UPDATE merge_staging_sales SET sales = 860 WHERE id = 3;

-- Confirm the updates 
select * from merge_staging_sales where id in (1,2,3)


-- Now run the same merge code here 

merge into merge_target_sales as target 
using merge_staging_sales as source 
on source.id = target.id 
when matched then update 
    set
        target.date = source.date,
        target.country = source.country,
        target.product = source.product,
        target.sales = source.sales,
        target.updated_at = current_timestamp 
when not matched then 
    INSERT(id,date,country,product,sales,updated_at)
    values(
        SOURCE.ID,
        SOURCE.DATE,
        SOURCE.COUNTRY,
        SOURCE.PRODUCT,
        SOURCE.sales,
        current_timestamp
    );

    -- you will see all the data is updating, not the new entries bcoz it is a refresh 

select * from merge_staging_sales

-- Now Insert some records
    insert into merge_staging_sales(id,date,country,product,sales)
    values
    (3789,'2026-09-28','Australia','Tab',789),
    (3790,'2026-09-18','Indiaa','phone',23432),
    (3791,'2026-09-19','Germany','Speaker',8999),
    (3792,'2026-09-27','France','TV',78999)


    -- Now try to run the Merge command it will insert records and do the refresh as well.

    
merge into merge_target_sales as target 
using merge_staging_sales as source 
on source.id = target.id 
when matched then update 
    set
        target.date = source.date,
        target.country = source.country,
        target.product = source.product,
        target.sales = source.sales,
        target.updated_at = current_timestamp 
when not matched then 
    INSERT(id,date,country,product,sales,updated_at)
    values(
        SOURCE.ID,
        SOURCE.DATE,
        SOURCE.COUNTRY,
        SOURCE.PRODUCT,
        SOURCE.sales,
        current_timestamp
    );

select * from merge_target_sales
order by id desc, updated_at desc

-- Also You can avoid update if you won't just insert the records 

-- Insert overwrite 
-- Use to replace the data which is already present in the table 

create or replace table TV_products
AS
select * from stg_sales
where product = 'TAB'


-- Check the data of this table 

select * from tv_products

-- Lets not focus on table name but try to perform the insert overwrite with this same table 

insert overwrite into tv_products
select * from stg_sales
where product = 'TV'

-- Check the table now, you will not find any data of Tab, it is kind of truncate insert, but In interview only say it overwrite the new query results. Biggest diff it is a single transaction while trunc + insert = 2 transactions. 

select * from tv_products

-- Clustering 
-- It is not a indexing in DB but it tries to co-locate the data with-in same micro-partition using the key column

create or replace table clustered_sales 
cluster by (country)
as 
select * from stg_sales



-- See the overview and partiiton data, but we do not need to create cluster for a small column as it add a cost. 

SELECT SYSTEM$CLUSTERING_INFORMATION('clustered_sales');

-- Cache 
-- Meaning Showing/Using pre-computed results 

-- 3 Types of Caches are there in snowflake

-- 1st Query Cache Results Cache, It is not fixex totally dynamic based on Query lets see this on Query History 24hrs if not logout

select product, sum(sales) as sales from stg_sales
group by product;

-- 2nd Warehouse Cache 
-- It caches the tables most used in a WH, until it is not suspended, Once it is suspended then Caches are Vanished 

-- 3rd MetaData Cache
-- Stores structual Data & Statics about DB objects 
-- like rows count, max, min of table, partiotion info locations. Table Structure detail.

-- This Completes are Day 5 




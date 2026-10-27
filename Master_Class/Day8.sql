-- Stream provides change-tracking information for a supported source object 

-- Creating a Stream

Create or REPLACE stream demo_db.raw.sales_stream 
on table demo_db.raw.tv_products

-- Creating Target 
Create table if not exists stream_target_sales
(
    date date,
    country string, 
    product string,
    sales int,
    updated_at timestamp
)


-- Task: A Task Automatically executes the sql script/ procedure logic according to schedules or dependencies 
-- Why use Task & Stream together stream identifies the changes and task process the changes 
--Create Task 

create or replace task demo_db.raw.process_sales_task
warehouse = Compute_wh 
schedule = '1 minute'
when system$stream_has_data(
    'demo_db.raw.sales_stream'
)
as 
    insert into demo_db.raw.stream_target_sales(
    date,country,product,sales,updated_at
    )
    select date, country, product,sales,current_timestamp from demo_db.raw.sales_stream
    where metadata$action = 'INSERT'

    -- Resume Task 

    alter task demo_db.raw.process_sales_task 
    resume;

insert into demo_db.raw.tv_products
values(
 '2026-09-03','India','Jeep',3466
)

SELECT *
FROM demo_db.raw.sales_stream;

SELECT SYSTEM$STREAM_HAS_DATA('demo_db.raw.sales_stream');

SHOW TASKS LIKE 'PROCESS_SALES_TASK';

select * from demo_db.raw.stream_target_sales where sales = 3457

show tasks
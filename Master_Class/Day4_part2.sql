-- Before Creating Snow Pipe, You should have the Storage Integration + Notification Integration 

LIST @demo_db.raw.Azure_sales_stage

-- Now coming to Notification Integration 

      -- Now configure the Azure Event grid 
      -- Step 1 Go to Queues Under Storage Account and create a queue 
    -- Step 2 Storage Account => Events => Event Subscription => create Event Susbscription 
    -- give the name and inside endpoint type select storage queue, inside endpoint configuration 
    -- choose the storage Account and the queue which we just created 

-- Now run this 
CREATE OR REPLACE NOTIFICATION INTEGRATION snowpipe_event
  ENABLED = true
  TYPE = queue
  NOTIFICATION_PROVIDER = azure_storage_queue
  AZURE_STORAGE_QUEUE_PRIMARY_URI = 'https://snowflake1808.queue.core.windows.net/snowpipequeue' -- queue url
  AZURE_TENANT_ID = 'b5516084-f1d0-49ae-baa0-1d1b1dffcb0c';

desc notification integration snowpipe_event
-- Go to Azure Consent Url and give permission 
-- Go to IAM and give permission to AZURE_MULTI_TENANT_APP_NAME for the stoage Queue Data Contributor

-- Now Setup is ready to Create a SnowPipe 


 
-- SnowPipe automatically loads new files into Snowflake as they arrive, instead of manually running COPY INTO every time.

-- Verify if you able to or not query from stage 
Select $1,$2,$3,$4 from @demo_db.raw.azure_sales_stage



-- Create a table 
CREATE OR REPLACE TABLE DEMO_DB.RAW.SALES_PIPELINE (
    date date,
    country String, 
    product string, 
    sales integer
);

select * from 
demo_db.raw.sales_pipeline

-- Create a file format if not have 
show file formats in demo_db.raw

-- Create a Snow-Pipe syntax below 
-- Remember Snowflale doesn't track/continously scan ADLs instead it recieves notification from event grid.


CREATE OR REPLACE PIPE demo_db.raw.sales_pipe
    AUTO_INGEST = TRUE
    INTEGRATION = SNOWPIPE_EVENT
AS
    COPY INTO demo_db.raw.sales_pipeline
    FROM @demo_db.raw.azure_sales_stage
    FILE_FORMAT = demo_db.raw.csv_ff
    ON_ERROR = 'CONTINUE';

-- Upload file & check the data 

select count(*) from demo_db.raw.sales_pipeline





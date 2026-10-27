-- Agenda Semi Structured Data + Snow Pipe.

-- Creating a Table for Json data 

Create or replace table demo_db.raw.raw_Events(
payload variant 
);
-- Initially we are storing the payload

-- Parse json it converts a JSON-formatted string into a Snowflake Semi-Structured value.

insert into demo_db.raw.raw_events
select parse_json(
'{
  "event_id": 101,
  "user": {
    "id": "U321",
    "region": "US"
  },
  "items": [
    {
      "sku": "A1",
      "price": 10
    },
    {
      "sku": "B2",
      "price": 20
    }
  ]
}'
)

select * from demo_db.raw.raw_events

-- Now Extrating data from this above table 

select payload:event_id -- go inside the payload and get the event_id 
from demo_db.raw.raw_events

-- Now Extracting the Nested Data 
select payload:user.id 
from demo_db.raw.raw_events

-- Casting the Json Values 
select payload:user.id::String  -- USE :: double colon 2 times after fetching the path 
from demo_db.raw.raw_events

-- Similarly we can fetch the items inside this Json

select payload:items[0].price::int 
from demo_db.raw.raw_events

-- Direct Extractions 

select payload:event_id::INT as event_id, payload:user.id::String user_id, payload:user.region::String as User_region
from demo_db.raw.raw_events

-- The problem is with Arays becoz we can only extract items, the below query will return arrays only  

select payload:items
from demo_db.raw.raw_events

-- But To convert this into a rows & cols we need Flatten()

-- Flatten converts elements of an array/object into individual rows.

-- Syntax 


from demo_db.raw.raw_events, -- this comma (,) is imp
Lateral flatten(input => payload:items) f -- input = Tells Snowflake what needs to be flatten 
-- Now F is the alias for flatten & f.value represents each individual items.


select * from demo_db.raw.raw_events

-- Complete query

select 
    payload:event_id::INT as Event_id, 
    f.value:sku::String as item_Sku,
    f.value:price::INT AS item_PRICE,
    payload:user.id::String as User_id,
    payload:user.region::String as User_region
from demo_db.raw.raw_events,
Lateral flatten(input => payload:items) f

-- Flatten also has some other useful columns 

select 
   f.*
from demo_db.raw.raw_events,
Lateral flatten(input => payload:items) f

-- Flatten with Index 

select 
    payload:event_id::String as Event_id,
    f.index as item_number, 
    f.value:sku as item_sku,
    f.value:price as item_price
from demo_db.raw.raw_events, 
lateral flatten(input => payload:items) f



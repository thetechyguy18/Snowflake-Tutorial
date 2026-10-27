-- Advanced Security, Data Sharing & Dynamic Tables 

-- Dynamic Data Masking meaning hiding sensitive data from users in a Table 
-- Masking happens when data is accessed, not by permanently changing the stored value.

-- Creating a Masking policy 

SELECT * FROM STG_SALES

-- Drop if exists 

drop MASKING POLICY MASK_PII  

Create MASKING POLICY MASK_PII -- creating a policy that determines how a column should be displayed 
AS (val string)   -- The policy accepts a value as val 
returns string ->  -- output of policy is String 
case 
    WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN') -- Checking the CurrentRikle 
    THEN val 
    else '***MASKED***'
end;


-- Applying the Masking policy on a Table 
Alter table stg_sales
modify column product
set masking policy mask_pii

ALTER TABLE stg_sales
MODIFY COLUMN product UNSET MASKING POLICY;

select * from stg_sales

-- IMP Masking not update the data it just shows a dumy value 

-- Dynamic Data Masking & Encryption both are different.

-- Row Access Policies 

select * from target_sales

-- Suppose a US manager wants to access above table, but other data is ir-relevant to him 
-- So we can create a Row Access Policy 

Create or replace row access policy COUNTRY_sales
as (COUNTRY_VALUE STRING) 
returnS boolean ->
    case 
        when current_role() ='ACCOUNTADMIN'
            then true
        when current_role() = 'US_MANAGER' AND COUNTRY_VALUE = 'US'
            then true
        when current_role() = 'India_Manager' and country_value = 'INDIA'
            THEN TRUE
        ELSE FALSE
    END;

ALTER TABLE TARGET_SALES
ADD ROW ACCESS POLICY COUNTRY_sales
ON (COUNTRY)


-- Masking: what column value user can see 
-- Row policy which rows user can see


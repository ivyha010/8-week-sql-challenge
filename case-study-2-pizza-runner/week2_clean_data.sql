-- Data cleaning: 
/*
1. CLEAN CUSTOMER_ORDERS TABLE: 
	1.1. Data issues identified: 
	The "exlusions" and "extras" columns contains inconsistent values: 
		- NULL values
        - the string "null"
        - empty string 
        - whitespace
		- values with inconsistent spacing (e.g. "1, 5")
	1.2. Cleaning objectives:
		- Standardize all missing values to NULL 
        - Remove unwanted whitespace 
        - Ensure consistant comma-separated formatting 
*/
DROP TABLE IF EXISTS customer_orders_clean;
CREATE TABLE customer_orders_clean AS
SELECT 
	order_id, 
    customer_id, 
    pizza_id, 
    CASE 
		WHEN exclusions IN ('null', '') THEN NULL 
        ELSE REPLACE(exclusions, ' ', '')
    END AS exclusions, 
    CASE
		WHEN extras IN ('null', '') THEN NULL 
        ELSE REPLACE(extras, ' ', '')
    END AS extras, 
    order_time
FROM customer_orders; 


/*
2. CLEAN RUNNER_ORDERS TABLE
2.1. Data issues identified: 
	- "pickup_time" contains the string "null"
    - "distance" includes text (e.g. "km") and the string "null"
    - "duration" includes text (e.g. "mins", "minute", "minutes") and the string "null"
    - "cancellation" contains NULL, the string 'null', and empty strings
2.2. Cleaning objectives: 
	- Convert string "null" values to proper NULL
	- Convert "pickup_time" to DATETIME data type
	- Remove text units from "distance" and convert to numeric (kilometres)
	- Remove text units from "duration" and convert to numeric (minutes)
	- Standardise "cancellation" values and ensure consistent NULL handling
*/
DROP TABLE IF EXISTS runner_orders_clean;
CREATE TABLE runner_orders_clean AS 
SELECT 
	order_id, 
    runner_id, 
    CAST(CASE
		WHEN pickup_time = 'null' THEN NULL 
        ELSE pickup_time
    END AS DATETIME) AS pickup_time, 
    CASE
		WHEN distance = 'null' THEN NULL 
        ELSE CAST(REPLACE(distance, 'km', '') AS DECIMAL(5,2))
    END AS distance, 
    CASE
		WHEN duration = 'null' THEN NULL 
        ELSE CAST(TRIM(REPLACE(REPLACE(REPLACE(duration, 'mins', ''), 'minutes', ''), 'minute', '')) AS UNSIGNED)
    END AS duration,
    CASE
		WHEN cancellation = 'null' OR cancellation = '' OR cancellation = ' ' THEN NULL
        ELSE TRIM(cancellation)
    END AS cancellation
FROM runner_orders;




































-- 1. Handle the NULL values in the "customer_orders" table 
SELECT *
FROM customer_orders; 

SET sql_safe_updates = 0;

-- Handle the NULL values in the "exclusions" column of the "customer_orders" table 
UPDATE customer_orders
SET exclusions = ''
WHERE exclusions = 'null' OR exclusions IS NULL;

-- Handle the NULL values in the "extras" column of the "customer_orders" table 
UPDATE customer_orders 
SET extras = ''
WHERE extras = 'null' OR extras IS NULL;

SELECT *
FROM customer_orders; 

-- 2. Handle the NULL in the "runner_orders" table 
SELECT * 
FROM runner_orders; 

-- Handle the NULL values in the "pickup_time" column of the "runner_orders" table 
SET sql_safe_updates = 0; 

UPDATE runner_orders 
SET pickup_time = ''
WHERE pickup_time = 'null' OR pickup_time IS NULL;

-- Handle the NULL values in the "distance" column of the "runner_orders" table 
UPDATE runner_orders 
SET distance = ''
WHERE distance = 'null' OR distance IS NULL; 

-- Handle the NULL values in the "duration" column of the "runner_orders" table 
UPDATE runner_orders 
SET duration = ''
WHERE duration = 'null' OR duration IS NULL; 

-- Handle the NULL values in the "cancellation" column of the "runner_orders" table 
UPDATE runner_orders 
SET cancellation = ''
WHERE cancellation = 'null' OR cancellation IS NULL; 


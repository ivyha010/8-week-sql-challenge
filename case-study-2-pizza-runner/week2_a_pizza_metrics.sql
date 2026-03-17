/*
A. Pizza Metrics
How many pizzas were ordered?
How many unique customer orders were made?
How many successful orders were delivered by each runner?
How many of each type of pizza was delivered?
How many Vegetarian and Meatlovers were ordered by each customer?
What was the maximum number of pizzas delivered in a single order?
For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
How many pizzas were delivered that had both exclusions and extras?
What was the total volume of pizzas ordered for each hour of the day?
What was the volume of orders for each day of the week?
*/
-- 1. How many pizzas were ordered?
-- Each row represents one pizza.
-- Expected result: 14
SELECT COUNT(*) AS total_pizzas 
FROM customer_orders_clean; 

-- 2. How many unique customer orders were made? 
-- An order may include multiple pizzas, so we count DISTINCT order_id
-- Expected result: 10 
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM customer_orders_clean; 

-- 3. How many successful orders were delivered by each runner?
-- Delivered orders are defined as cancellation is NULL 
-- Expected result: 
-- Runner 1: 4
-- Runner 2: 3
-- Runner 3: 1

SELECT 
	runner_id, 
	COUNT(order_id) AS num_orders
FROM runner_orders_clean 
WHERE cancellation IS NULL 
GROUP BY runner_id
ORDER BY runner_id;

-- 4. How many of each type of pizza was delivered?
-- Only delivered orders (cancellation is NULL) are included
-- Expected result: 
-- Meatlovers: 9 
-- Vegetarian: 3 

SELECT 
	pn.pizza_name, 
    COUNT(ro.order_id) AS num_pizzas
FROM runner_orders_clean AS ro
INNER JOIN customer_orders_clean AS co
ON ro.order_id = co.order_id
INNER JOIN pizza_names AS pn
ON co.pizza_id = pn.pizza_id
WHERE ro.cancellation IS NULL
GROUP BY pn.pizza_name; 

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
-- Each row in customer_orders_clean represents one pizza (pizza-level data).
-- pizza_id = 1 → Meatlovers
-- pizza_id = 2 → Vegetarian
-- This query uses conditional aggregation to count each pizza type per customer.
-- customer_id   num_meat  num_veg
-- 	101				2		  1
-- 	102				2		  1
-- 	103	            3	      1
-- 	104	            3	      0
-- 	105	            0         1

SELECT 
    customer_id,
    SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS num_meat,
    SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS num_veg
FROM customer_orders_clean
GROUP BY customer_id
ORDER BY customer_id;


-- 6. What was the maximum number of pizzas delivered in a single order?
-- Only delivered orders are included (cancellation IS NULL).
-- Step 1: Count pizzas per delivered order.
-- Step 2: Return the maximum pizza count.
-- Expected result: 3 

WITH count_CTE AS (
	SELECT 
		ro.order_id, 
		COUNT(*) AS num_pizzas
	FROM runner_orders_clean AS ro 
	INNER JOIN customer_orders_clean AS co
	ON ro.order_id = co.order_id
	WHERE ro.cancellation IS NULL 
	GROUP BY ro.order_id)

SELECT 
	MAX(num_pizzas) AS max_num
FROM count_CTE;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- A change is defined as having at least one exclusion OR extra.
-- Only delivered orders are included (cancellation IS NULL).
-- Expected result: 
-- customer_id    no_changes   with_changes 
--    101	          2	           0
--    102	          3	           0
--    103	          0	           3
--    104	          1            2
--    105	          0	           1

WITH CTE_join AS (SELECT 
	co.customer_id, 
    co.pizza_id, 
    ro.cancellation, 
    co.exclusions, 
    co.extras
FROM customer_orders_clean AS co 
INNER JOIN runner_orders_clean AS ro
ON co.order_id = ro.order_id 
WHERE ro.cancellation IS NULL) 

SELECT 
	customer_id, 
    SUM(CASE
		WHEN exclusions IS NULL AND extras IS NULL THEN 1 
        ELSE 0
    END) AS no_changes, 
    SUM(CASE 
		WHEN exclusions IS NOT NULL OR extras IS NOT NULL THEN 1 
        ELSE 0
    END) AS with_changes
FROM CTE_join 
GROUP BY customer_id
ORDER BY customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
-- Only delivered pizzas are included (cancellation IS NULL).
-- A qualifying pizza must have: exclusions IS NOT NULL AND extras IS NOT NULL
-- Expected result: 1
SELECT 
	COUNT(*) AS num_pizzas
FROM customer_orders_clean AS co 
INNER JOIN runner_orders_clean AS ro 
ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL 
	AND co.exclusions IS NOT NULL 
    AND co.extras IS NOT NULL;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
-- Each row represents one pizza.
-- HOUR(order_time) extracts the hour (0–23).
-- Includes all orders (delivered + cancelled).
-- Expected result: 
-- Order_hour   volume
--     11	       1
--     13          3
--     18	       3
--     19	       1
--     21	       3
--     23	       3

SELECT 
	HOUR(order_time) AS order_hour, 
    COUNT(*) AS volume
FROm customer_orders_clean
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time);

-- 10. What was the volume of orders for each day of the week?
-- Expected result: 
-- day of week  order_volume
-- Wednesday		5
-- Thursday	    	2
-- Friday	   		1
-- Saturday	        2

SELECT 
	dayname(order_time) AS day_of_week, 
    COUNT(DISTINCT order_id) AS order_volume
FROM customer_orders_clean
GROUP BY day_of_week
ORDER BY field(day_of_week, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');
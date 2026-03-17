/* B. Runner and Customer Experience
1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?
*/
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
-- Week starts 2021-01-01 
-- Expected result: 
-- week_start  num_runners
-- 2021-01-01	2
-- 2021-01-08	1
-- 2021-01-15	1

SELECT 
    DATE_ADD('2021-01-01',
        INTERVAL FLOOR(DATEDIFF(registration_date, '2021-01-01') / 7) * 7 DAY
    ) AS week_start,
    COUNT(*) AS num_runners
FROM runners
GROUP BY week_start
ORDER BY week_start;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- Join order-level pickup_time with DISTINCT order_time to avoid pizza-level duplication
-- Calculate time difference using TIMESTAMPDIFF and average per runner
-- Expected result: 
-- runner_id   avg_pickup_minutes
-- 	1			 	14.00
-- 	2			 	19.67
-- 	3			 	10.00
SELECT 
    ro.runner_id, 
    ROUND(AVG(timestampdiff(minute, order_time, pickup_time)), 2) AS avg_pickup_minutes
FROM runner_orders_clean AS ro
INNER JOIN 
	(SELECT 
		DISTINCT order_id, order_time
	FROM customer_orders_clean
    ) AS co
ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL
GROUP BY ro.runner_id 
ORDER BY ro.runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- Aggregate pizzas to order-level, join with pickup_time, calculate preparation time using TIMESTAMPDIFF, and include only successful deliveries.
-- num_pizzas  avg_prep_time_minutes
--   1				12.00
--   2              18.00
-- 	 3				29.00

SELECT 
    co.num_pizzas,
    ROUND(AVG(timestampdiff(minute, co.order_time, ro.pickup_time)),2) AS avg_prep_time_minutes
FROM runner_orders_clean AS ro
INNER JOIN (
	SELECT 
		order_id, 
		COUNT(*) AS num_pizzas,
		MIN(order_time) AS order_time
	FROM customer_orders_clean
	GROUP BY order_id
	) AS co
ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL
GROUP BY num_pizzas 
ORDER BY num_pizzas; 

-- 4. What was the average distance travelled for each customer?
-- Join runner_orders with DISTINCT order_id and customer_id to avoid pizza-level duplication
-- Include only successful deliveries (distance IS NOT NULL)
-- Calculate average delivery distance per customer

SELECT 
    co.customer_id,
    ROUND(AVG(ro.distance), 2) AS avg_distance
FROM runner_orders_clean AS ro
INNER JOIN (
    SELECT 
		DISTINCT order_id, customer_id
    FROM customer_orders_clean
) AS co
ON ro.order_id = co.order_id
WHERE ro.distance IS NOT NULL
GROUP BY co.customer_id
ORDER BY co.customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
-- Expected result: 30 minutes
SELECT 
	MAX(duration) AS longest_delivery, 
    MIN(duration) AS shortest_delivery,
	MAX(duration) - MIN(duration) AS delivery_difference
FROM runner_orders_clean
WHERE cancellation IS NULL;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- The average speed (km/h) for each runner for each delivery:
SELECT 
	runner_id, 
    order_id,
    ROUND((distance/duration) *60, 2) AS avg_speed
FROM runner_orders_clean
WHERE cancellation IS NULL
ORDER BY runner_id, order_id;

-- Analyze the trend by computing the average speed per runner and the total distance covered per runner:
-- Speeds vary significantly between deliveries
-- Longer deliveries show higher calculated average speeds, likely because fixed overhead time (such as traffic light, finding the customer, navigating building entrances, ...) affects shorter deliveries more significantly
-- The reason might be the data inconsistancy, or the small sample size. 
SELECT 
	runner_id, 
    SUM(distance) AS total_distance,
    ROUND(AVG((distance/duration) *60), 2) AS avg_speed
FROM runner_orders_clean
WHERE cancellation IS NULL
GROUP BY runner_id
ORDER BY avg_speed;

-- 7. What is the successful delivery percentage for each runner?
-- Expected result: 
-- runner_id  successful_percentage 
--      1	        100.00
--      2	        75.00
--      3	        50.00

SELECT 
	runner_id, 
    ROUND(100 * SUM(CASE 
		WHEN cancellation IS NULL THEN 1
        ELSE 0 
    END)/COUNT(*), 2) AS successful_percentage
FROM runner_orders_clean
GROUP BY runner_id
ORDER BY runner_id;





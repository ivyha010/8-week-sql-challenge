/*
D. Pricing and Ratings
1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
*/


-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
-- Calculate total revenue from delivered pizzas
-- Meat Lovers: $12
-- Vegetarian: $10
-- No extra charges for exclusions or extras
-- Expected result: $138

SELECT 
	SUM(CASE co.pizza_id
		WHEN 1 THEN 12 
        WHEN 2 THEN 10
    END) AS total_revenue
FROM runner_orders_clean AS ro
INNER JOIN customer_orders_clean AS co 
ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL; 

-- 2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra
-- Add $1 for each extra topping
-- Number of extras = number of commas + 1
-- Example: '1,4' → 2 extras
-- Expected result: 142

SELECT 
	SUM(
        CASE co.pizza_id
            WHEN 1 THEN 12 
            WHEN 2 THEN 10
        END
        +
        COALESCE(
            LENGTH(co.extras) - LENGTH(REPLACE(co.extras, ',', '')) + 1,
            0
        )
    ) AS total_revenue
FROM runner_orders_clean ro
JOIN customer_orders_clean co
    ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL;


-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
-- how would you design an additional table for this new dataset - 
-- generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

SHOW INDEX FROM runner_orders_clean; 

ALTER TABLE runner_orders_clean 
ADD PRIMARY KEY (order_id); 


CREATE TABLE IF NOT EXISTS runner_ratings( 
rating_id INT AUTO_INCREMENT PRIMARY KEY, 
order_id INT NOT NULL, 
runner_id iNT NOT NULL, 
rating TINYINT NOT NULL CHECK (rating between 1 AND 5), 
rating_time DATETIME DEFAULT CURRENT_TIMESTAMP, 
FOREIGN KEY(order_id) REFERENCES runner_orders_clean(order_id) 
);

INSERT INTO runner_ratings(order_id, runner_id, rating) 
VALUES
(1, 1, 5),
(2, 1, 3), 
(3, 1, 4),
(4, 2, 5), 
(5, 3, 2), 
(6, 3, 5), 
(7, 2, 2),
(8, 2, 4), 
(9, 2, 5), 
(10, 1, 4);

SELECT * 
FROM runner_ratings; 

-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas
SELECT 
	co.customer_id, 
    co.order_id, 
    ro.runner_id, 
    rr.rating, 
    co.order_time, 
    ro.pickup_time,
	TIMEDIFF(ro.pickup_time, co.order_time) AS time_order_pickup, 
    ro.duration,
    ROUND(ro.distance / NULLIF(ro.duration, 0) * 60, 2) AS average_speed_kmph, 
    COUNT(co.pizza_id) AS total_pizzas 
FROM customer_orders_clean AS co 
INNER JOIN runner_orders_clean AS ro 
ON co.order_id = ro.order_id
INNER JOIN runner_ratings AS rr
ON co.order_id = rr.order_id
WHERE ro.cancellation IS NULL
GROUP BY 
	co.customer_id, 
    co.order_id, 
    ro.runner_id, 
    rr.rating, 
    co.order_time, 
    ro.pickup_time,
    ro.duration
ORDER BY co.customer_id;

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras 
-- and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

WITH order_summary AS (
    SELECT 
        ro.order_id,
        -- revenue per order (sum of pizzas)
        SUM(
            CASE co.pizza_id
                WHEN 1 THEN 12
                WHEN 2 THEN 10
            END
        ) AS revenue,
        -- cost per order (distance × 0.3)
        MAX(ro.distance) * 0.3 AS cost
        
    FROM runner_orders_clean AS ro
	JOIN customer_orders_clean As co
	ON ro.order_id = co.order_id
    WHERE ro.cancellation IS NULL
    GROUP BY ro.order_id
)

SELECT 
    SUM(revenue) - SUM(cost) AS profit
FROM order_summary;









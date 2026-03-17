/*C. Ingredient Optimisation
1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
*/

-- 1. What are the standard ingredients for each pizza?
WITH RECURSIVE split_toppings AS (
	SELECT 
		pizza_id, 
        TRIM(SUBSTRING_INDEX(toppings, ',', 1)) AS topping_id, 
        SUBSTRING(toppings, LENGTH(SUBSTRING_INDEX(toppings, ',', 1)) + 2) AS remaining
    FROM pizza_recipes 
    
    UNION ALL 
    
    SELECT 
		pizza_id, 
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)), 
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_toppings
    WHERE remaining IS NOT NULL 
	AND remaining <> ''
)

SELECT 
    pn.pizza_name,
    GROUP_CONCAT(DISTINCT pt.topping_name ORDER BY pt.topping_name SEPARATOR ', ') AS ingredients
FROM split_toppings AS st
JOIN pizza_toppings AS pt
    ON CAST(st.topping_id AS UNSIGNED) = pt.topping_id
JOIN pizza_names AS pn
    ON st.pizza_id = pn.pizza_id
GROUP BY pn.pizza_name;


-- 2. What was the most commonly added extra?
WITH RECURSIVE split_extras AS (
	SELECT 
		TRIM(SUBSTRING_INDEX(extras, ',', 1)) AS extra, 
        SUBSTRING(extras, LENGTH(SUBSTRING_INDEX(extras, ',', 1)) + 2) AS remaining
    FROM customer_orders_clean
    WHERE extras IS NOT NULL
    
    UNION ALL 
    
    SELECT 
		TRIM(SUBSTRING_INDEX(remaining, ',', 1)), 
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_extras
    WHERE remaining IS NOT NULL 
    AND remaining <> ''
)

SELECT 
	pt.topping_name, 
    COUNT(*) AS extra_count
FROM split_extras AS se
INNER JOIN pizza_toppings AS pt
	ON CAST(se.extra AS UNSIGNED) = pt.topping_id
-- WHERE extra IS NOT NULL 
GROUP BY pt.topping_id
ORDER BY extra_count DESC
LIMIT 1;

-- 3. What was the most common exclusion?
-- Splitting the exclusions column and counting occurrences
-- Expected result: Cheese 

WITH RECURSIVE split_exclusions AS (
	SELECT 
		TRIM(SUBSTRING_INDEX(exclusions, ',', 1)) AS exclusion, 
        SUBSTRING(exclusions, LENGTH(SUBSTRING_INDEX(exclusions, ',', 1)) + 2) AS remaining 
    FROM customer_orders_clean
    WHERE exclusions IS NOT NULL 
    
    UNION ALL 
    SELECT 
		TRIM(SUBSTRING_INDEX(remaining, ',', 1)), 
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
	FROM split_exclusions
    WHERE remaining IS NOT NULL 
    AND remaining <> ''    
)

SELECT 
	pt.topping_name, 
    COUNT(*) AS count_exclusions
FROM split_exclusions AS se
INNER JOIN pizza_toppings AS pt
ON CAST(se.exclusion AS UNSIGNED) = pt.topping_id
GROUP BY pt.topping_name
ORDER BY count_exclusions DESC 
LIMIT 1; 

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH RECURSIVE orders AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY order_id, pizza_id) AS row_id
    FROM customer_orders_clean
),

split_exclusions AS (
    SELECT
        row_id,
        TRIM(SUBSTRING_INDEX(exclusions, ',', 1)) AS exclusion,
        SUBSTRING(exclusions, LENGTH(SUBSTRING_INDEX(exclusions, ',', 1)) + 2) AS remaining
    FROM orders
    WHERE exclusions IS NOT NULL

    UNION ALL

    SELECT
        row_id,
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)),
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_exclusions
    WHERE remaining IS NOT NULL
      AND remaining <> ''
),

split_extras AS (
    SELECT
        row_id,
        TRIM(SUBSTRING_INDEX(extras, ',', 1)) AS extra,
        SUBSTRING(extras, LENGTH(SUBSTRING_INDEX(extras, ',', 1)) + 2) AS remaining
    FROM orders
    WHERE extras IS NOT NULL

    UNION ALL

    SELECT
        row_id,
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)),
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_extras
    WHERE remaining IS NOT NULL
      AND remaining <> ''
),

exclusion_names AS (
    SELECT
        se.row_id,
        GROUP_CONCAT(pt.topping_name ORDER BY pt.topping_name SEPARATOR ', ') AS exclusions
    FROM split_exclusions AS se
    LEFT JOIN pizza_toppings AS pt
        ON CAST(se.exclusion AS UNSIGNED) = pt.topping_id
    GROUP BY se.row_id
),

extra_names AS (
    SELECT
        se.row_id,
        GROUP_CONCAT(pt.topping_name ORDER BY pt.topping_name SEPARATOR ', ') AS extras
    FROM split_extras AS se
    LEFT JOIN pizza_toppings AS pt
        ON CAST(se.extra AS UNSIGNED) = pt.topping_id
    GROUP BY se.row_id
)


SELECT
    o.row_id,
    o.order_id,
    o.customer_id,
    o.pizza_id,
    o.order_time,
    CASE
        WHEN en.exclusions IS NULL AND ex.extras IS NULL
            THEN pn.pizza_name
        WHEN en.exclusions IS NOT NULL AND ex.extras IS NULL
            THEN CONCAT(pn.pizza_name, ' - Exclude ', en.exclusions)
        WHEN en.exclusions IS NULL AND ex.extras IS NOT NULL
            THEN CONCAT(pn.pizza_name, ' - Extra ', ex.extras)
        ELSE CONCAT(pn.pizza_name, ' - Exclude ', en.exclusions, ' - Extra ', ex.extras)
    END AS order_item
FROM orders AS o
LEFT JOIN pizza_names AS pn
    ON o.pizza_id = pn.pizza_id
LEFT JOIN exclusion_names AS en
    ON o.row_id = en.row_id
LEFT JOIN extra_names AS ex
    ON o.row_id = ex.row_id;

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH RECURSIVE orders AS (
	SELECT 
		*, 
        ROW_NUMBER() OVER(ORDER BY order_id, pizza_id) AS row_id
	FROM customer_orders_clean
), 

split_exclusions AS (
	SELECT 
		row_id, 
        TRIM(SUBSTRING_INDEX(exclusions, ',', 1)) AS exclusion, 
        SUBSTRING(exclusions, LENGTH(SUBSTRING_INDEX(exclusions, ',', 1)) + 2) AS remaining 
    FROM orders
    WHERE exclusions IS NOT NULL
    
    UNION ALL 
	
    SELECT
		row_id, 
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)), 
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_exclusions
    WHERE remaining IS NOT NULL 
		AND remaining <> ''
),

split_extras AS (
	SELECT 
		row_id, 
        TRIM(SUBSTRING_INDEX(extras, ',', 1)) AS extra, 
        SUBSTRING(extras, LENGTH(SUBSTRING_INDEX(extras, ',', 1)) + 2) AS remaining
	FROM orders 
    WHERE extras IS NOT NULL
    
    UNION ALL 
    
    SELECT 
		row_id, 
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)), 
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_extras
    WHERE remaining IS NOT NULL 
		AND remaining <> ''
), 

split_toppings AS (
	SELECT 
		pizza_id, 
        TRIM(SUBSTRING_INDEX(toppings, ',', 1)) AS topping_id, 
        SUBSTRING(toppings, LENGTH(SUBSTRING_INDEX(toppings, ',', 1)) + 2) AS remaining
    FROM pizza_recipes
    
    UNION ALL 
    
    SELECT 
		pizza_id, 
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)), 
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_toppings 
    WHERE remaining <> ''
), 

base_toppings AS (
	SELECT 
		o.row_id, 
        o.pizza_id, 
        st.topping_id
    FROM orders AS o 
    INNER JOIN split_toppings AS st
    ON o.pizza_id = st.pizza_id
), 

remove_exclusions AS (
	SELECT * 
    FROM base_toppings AS bt 
    WHERE NOT EXISTS (
		SELECT 1 
        FROM split_exclusions AS e 
        WHERE bt.row_id = e.row_id 
			AND bt.topping_id = e.exclusion
    )
), 

add_extras AS (
	SELECT 
		row_id, 
        pizza_id, 
        topping_id
    FROM remove_exclusions
    
    UNION ALL 
    
    SELECT 
		row_id, 
        NULL AS pizza_id, 
        extra
    FROM split_extras
), 

count_toppings AS (
	SELECT 
		ae.row_id, 
        pt.topping_name, 
        COUNT(ae.topping_id) AS count_topping, 
        CASE 
			WHEN COUNT(ae.topping_id) = 1 THEN pt.topping_name
            ELSE CONCAT(CONVERT(COUNT(ae.topping_id), char), 'x', pt.topping_name)
        END AS n_toppings
    FROM add_extras AS ae
    INNER JOIN pizza_toppings AS pt
    ON ae.topping_id = pt.topping_id
    GROUP BY ae.row_id, pt.topping_name
), 

ingredient_list AS (
	SELECT 
		row_id, 
		GROUP_CONCAT(n_toppings ORDER BY topping_name SEPARATOR ', ') AS ingr_list 
    FROM count_toppings 
    GROUP BY row_id
)

SELECT 
	o.*, 
    CONCAT(pn.pizza_name, ': ', ingr_list) AS ingredients
FROM orders AS o 
INNER JOIN ingredient_list AS il 
ON o.row_id = il.row_id
INNER JOIN pizza_names AS pn 
ON o.pizza_id = pn.pizza_id; 

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
WITH RECURSIVE delivered_orders AS (
	SELECT 
		ROW_NUMBER() OVER(ORDER BY ro.order_id, co.pizza_id) AS row_id,
		ro.order_id, 
		co.pizza_id, 
		co.exclusions, 
		co.extras
	FROM runner_orders_clean AS ro
	INNER JOIN customer_orders_clean AS co 
	ON ro.order_id = co.order_id 
	AND ro.cancellation IS NULL
), 

split_exclusions AS (
	SELECT 
		row_id,
		pizza_id, 
        TRIM(SUBSTRING_INDEX(exclusions, ',', 1)) AS exclusion_id, 
        SUBSTRING(exclusions, LENGTH(SUBSTRING_INDEX(exclusions, ',', 1)) + 2) AS remaining
    FROM delivered_orders
    WHERE exclusions IS NOT NULL 
    
    UNION ALL 
    SELECT 
		row_id,
		pizza_id, 
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)),
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_exclusions 
    WHERE remaining IS NOT NULL 
		AND remaining <> ''
), 

split_extras AS (
	SELECT 
		row_id,
		pizza_id, 
        TRIM(SUBSTRING_INDEX(extras, ',', 1)) AS extra_id, 
        SUBSTRING(extras, LENGTH(SUBSTRING_INDEX(extras, ',', 1)) + 2) AS remaining
    FROM delivered_orders
    WHERE extras IS NOT NULL 
    
    UNION ALL 
    SELECT 
		row_id,
		pizza_id, 
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)),
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_extras
    WHERE remaining IS NOT NULL 
		AND remaining <> ''
), 

split_toppings AS (
	SELECT 
		pizza_id, 
        TRIM(SUBSTRING_INDEX(toppings, ',', 1)) AS topping_id, 
        SUBSTRING(toppings, LENGTH(SUBSTRING_INDEX(toppings, ',', 1)) + 2) AS remaining
    FROM pizza_recipes
    
    UNION ALL 
    SELECT 
		pizza_id, 
        TRIM(SUBSTRING_INDEX(remaining, ',', 1)),
        SUBSTRING(remaining, LENGTH(SUBSTRING_INDEX(remaining, ',', 1)) + 2)
    FROM split_toppings
    WHERE remaining <> ''
    ), 
    
base_toppings AS (
	SELECT 
		deo.*, 
		st.topping_id 
    FROM delivered_orders AS deo 
    INNER JOIN split_toppings AS st 
    ON deo.pizza_id = st.pizza_id
), 

filtered_orders AS (
	SELECT * 
    FROM base_toppings AS bt
    WHERE NOT EXISTS (
		SELECT 1 
        FROM split_exclusions AS se
        WHERE bt.row_id = se.row_id
			AND bt.topping_id = se.exclusion_id
    )
), 

filtered_orders_add AS (
	SELECT 
		fo.row_id, 
        fo.pizza_id, 
        fo.topping_id
    FROM filtered_orders AS fo
    
    UNION ALL 
    
    SELECT 
		se.row_id, 
        se.pizza_id, 
        se.extra_id
    FROM split_extras AS se
), 

count_ingredients AS (
	SELECT 
		topping_id, 
        COUNT(*) AS total_quantity
	FROM filtered_orders_add 
    GROUP BY topping_id 
)

SELECT 
    pt.topping_name, 
    ci.total_quantity
FROM count_ingredients AS ci
INNER JOIN pizza_toppings AS pt
ON ci.topping_id = pt.topping_id
ORDER BY ci.total_quantity DESC; 





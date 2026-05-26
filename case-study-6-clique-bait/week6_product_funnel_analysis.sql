/*
3. Product Funnel Analysis
Using a single SQL query - create a new output table which has the following details:

1. How many times was each product viewed?
2. How many times was each product added to cart?
3. How many times was each product added to a cart but not purchased (abandoned)?
4. How many times was each product purchased?

Additionally, create another table which further aggregates the data for the above points but this time for each product category 
instead of individual products.

Use your 2 new output tables - answer the following questions:

Which product had the most views, cart adds and purchases?
Which product was most likely to be abandoned?
Which product had the highest view to purchase percentage?
What is the average conversion rate from view to cart add?
What is the average conversion rate from cart add to purchase? 
*/

-- 1. How many times was each product viewed?
-- 2. How many times was each product added to cart?
-- 3. How many times was each product added to a cart but not purchased (abandoned)?
-- 4. How many times was each product purchased?

-- Results: 
-- product_id     product_name     num_views    num_cart_adds      num_abandoned    num_purchases 
-- 1				Salmon			1559			938					227				711
-- 2				Kingfish		1559			920					213				707
-- 3				Tuna			1515			931					234				697
-- 4				Russian Caviar	1563			946					249				697
-- 5				Black Truffle	1469			924					217				707
-- 6				Abalone			1525			932					233				699
-- 7				Lobster			1547			968					214				754
-- 8				Crab			1564			949					230				719
-- 9				Oyster			1568			943					217				726

SELECT 
	ph.product_id, 
    ph.page_name, 
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS num_views, 
	SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS num_cart_adds, 
	SUM(CASE WHEN e.event_type = 2 AND e.visit_id NOT IN (SELECT visit_id FROM events WHERE events.event_type = 3) THEN 1 ELSE 0 END) AS num_abandoned,
	SUM(CASE WHEN e.event_type = 2 AND e.visit_id IN (SELECT visit_id FROM events WHERE events.event_type = 3) THEN 1 ELSE 0 END) AS num_purchases
 FROM events AS e
 INNER JOIN page_hierarchy AS ph 
 ON e.page_id = ph.page_id
 WHERE ph.product_id IS NOT NULL
 GROUP BY ph.product_id, ph.page_name
 ORDER BY ph.product_id; 

-- The above points for each product category instead of individual products
-- product_category    num_views    num_cart_adds      num_abandoned    num_purchases 
-- Fish  	  			  4633			2789				674 			2115
-- Luxury	    		  3032			1870				466	   			1404
-- Shellfish			  6204			3792				894	  			2898

SELECT 
	ph.product_category, 
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS num_views, 
	SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS num_cart_adds, 
	SUM(CASE WHEN e.event_type = 2 AND e.visit_id NOT IN (SELECT visit_id FROM events WHERE events.event_type = 3) THEN 1 ELSE 0 END) AS num_abandoned,
	SUM(CASE WHEN e.event_type = 2 AND e.visit_id IN (SELECT visit_id FROM events WHERE events.event_type = 3) THEN 1 ELSE 0 END) AS num_purchases
 FROM events AS e
 INNER JOIN page_hierarchy AS ph 
 ON e.page_id = ph.page_id
 WHERE ph.product_category IS NOT NULL 
 GROUP BY ph.product_category
 ORDER BY ph.product_category; 

-- Insights: 
-- 1. Which product had the most views, cart adds and purchases? 
	-- Answer: Oyster (1568 views), Lobster (968 cart adds), Lobster (754 purchases)
-- 2. Which product was most likely to be abandoned? 
	-- Answer: Russian Caviar (249 cart adds but not purchases)
    
    
-- Create a view before calculating conversion rates 
CREATE VIEW info AS (
	SELECT 
	ph.product_id, 
    ph.page_name, 
    SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS num_views, 
	SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS num_cart_adds, 
	SUM(CASE WHEN e.event_type = 2 AND e.visit_id NOT IN (SELECT visit_id FROM events WHERE events.event_type = 3) THEN 1 ELSE 0 END) AS num_abandoned,
	SUM(CASE WHEN e.event_type = 2 AND e.visit_id IN (SELECT visit_id FROM events WHERE events.event_type = 3) THEN 1 ELSE 0 END) AS num_purchases
 FROM events AS e
 INNER JOIN page_hierarchy AS ph 
 ON e.page_id = ph.page_id
 WHERE ph.product_id IS NOT NULL
 GROUP BY ph.product_id, ph.page_name
 ORDER BY ph.product_id
);

-- 3. Which product had the highest view to purchase percentage? 
	-- Answer: Lobster (48.74%)

SELECT
	product_id, 
    page_name, 
    num_views, 
    num_cart_adds, 
    num_abandoned, 
    num_purchases, 
	ROUND(num_purchases * 100.0 / num_views, 2) AS view_to_purchase
FROM info
ORDER BY view_to_purchase DESC; 
    
-- 4. What is the average conversion rate from view to cart add?
-- Answer: 60.95% 
SELECT 
	ROUND(AVG(num_cart_adds *100.0 / num_views), 2) AS avg_conv_view_to_cart
FROM info; 
 
-- 5. What is the average conversion rate from cart add to purchase? 
-- Answer: 75.93%
SELECT 
	ROUND(AVG(num_purchases *100.0 / num_cart_adds), 2) AS avg_conv_cart_to_purchase
 FROM info; 

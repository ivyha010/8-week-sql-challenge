/*
2. Digital Analysis
Using the available datasets - answer the following questions using a single query for each one:
1. How many users are there?
2. How many cookies does each user have on average?
3. What is the unique number of visits by all users per month?
4. What is the number of events for each event type?
5. What is the percentage of visits which have a purchase event?
6. What is the percentage of visits which view the checkout page but do not have a purchase event?
7. What are the top 3 pages by number of views?
8. What is the number of views and cart adds for each product category?
9. What are the top 3 products by purchases?
*/ 

-- 1. How many users are there?
-- Results: 500 
SELECT 
	COUNT(DISTINCT user_id) AS num_users
FROM users; 

-- 2. How many cookies does each user have on average?
-- Results: 3.56
SELECT 
	COUNT(DISTINCT user_id) AS num_users, 
    COUNT(DISTINCT cookie_id) AS num_cookies, 
    ROUND(COUNT(DISTINCT cookie_id) * 1.0 / COUNT(DISTINCT user_id), 2) AS avg_num_cookies
FROM users; 

-- 3. What is the unique number of visits by all users per month?
SELECT 
    YEAR(event_time) AS visit_year, 
    MONTH(event_time) AS visit_month, 
	COUNT(DISTINCT visit_id) AS num_visits
FROM events
GROUP BY visit_year, visit_month
ORDER BY visit_year, visit_month; 

-- 4. What is the number of events for each event type?
SELECT 
	e.event_type, 
    ei.event_name,
	COUNT(*) AS num_events
FROM events AS e
INNER JOIN event_identifier AS ei
ON e.event_type = ei.event_type
GROUP BY e.event_type, ei.event_name
ORDER BY e.event_type; 

-- 5. What is the percentage of visits which have a purchase event?
-- Result: 49.86%
SELECT 
	COUNT(DISTINCT e.visit_id) AS total_visits, 
    COUNT(DISTINCT CASE WHEN ei.event_name = 'PURCHASE' THEN e.visit_id END) AS num_purchases, 
    ROUND (COUNT(DISTINCT CASE WHEN ei.event_name = 'PURCHASE' THEN e.visit_id END)* 100/COUNT(DISTINCT e.visit_id), 2) AS percentage
FROM events AS e
INNER JOIN event_identifier AS ei
ON e.event_type = ei.event_type; 

-- 6. What is the percentage of visits which view the checkout page but do not have a purchase event?
-- Result: 9.15%
SELECT 
    COUNT(DISTINCT e.visit_id) AS total_visits, 
    COUNT(DISTINCT CASE WHEN ph.page_name = 'Confirmation' AND ei.event_name = 'Purchase' THEN e.visit_id END) AS num_purchases, 
    COUNT(DISTINCT CASE WHEN ph.page_name = 'Checkout' THEN e.visit_id END) AS num_checkout_views,
	(COUNT(DISTINCT CASE WHEN ph.page_name = 'Checkout' THEN e.visit_id END) 
		- COUNT(DISTINCT CASE WHEN ph.page_name = 'Confirmation' AND ei.event_name = 'Purchase' THEN e.visit_id END)
	) AS checkout_no_purchase, 
	ROUND(
		(COUNT(DISTINCT CASE WHEN ph.page_name = 'Checkout' THEN e.visit_id END) 
			- COUNT(DISTINCT CASE WHEN ph.page_name = 'Confirmation' AND ei.event_name = 'Purchase' THEN e.visit_id END)) * 100.0
		/
		COUNT(DISTINCT e.visit_id), 
		2
	) AS percentage
FROM events AS e
INNER JOIN page_hierarchy AS ph 
	ON e.page_id = ph.page_id
INNER JOIN event_identifier AS ei 
	ON e.event_type = ei.event_type; 

-- 7. What are the top 3 pages by number of views?
-- Result: 
-- page_name      num_views 
-- All Products	    3174
-- Checkout	        2103
-- Home Page	    1782

SELECT 
    ph.page_name, 
   COUNT(*) AS num_views
FROM events AS e
INNER JOIN page_hierarchy AS ph
	ON e.page_id = ph.page_id
INNER JOIN event_identifier AS ei
	ON e.event_type = ei.event_type
WHERE ei.event_name = 'Page View'
GROUP BY ph.page_name
ORDER BY num_views DESC
LIMIT 3; 

-- 8. What is the number of views and cart adds for each product category?
-- Result: 
-- product_category   num_views   num_cart_adds
-- Shellfish	        6204	      3792
-- Fish	                4633	      2789
-- Luxury	            3032	      1870

SELECT 
	ph.product_category, 
    SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS num_views, 
	SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS num_cart_adds
FROM events AS e 
INNER JOIN page_hierarchy AS ph 
	ON e.page_id = ph.page_id 
INNER JOIN event_identifier AS ei 
	ON e.event_type = ei.event_type
WHERE ei.event_name IN ('Page View', 'Add to Cart')
	AND ph.product_category IS NOT NULL
GROUP BY ph.product_category
ORDER BY num_cart_adds DESC; 

-- 9. What are the top 3 products by purchases?
-- Results: 
-- page_name num_purchases
-- Lobster	     754
-- Oyster	     726
-- Crab	         719

SELECT 
	ph.page_name, 
    COUNT(*) AS num_purchases
FROM events AS e 
INNER JOIN page_hierarchy AS ph 
	ON e.page_id = ph.page_id
WHERE e.event_type = 2
AND ph.product_id IS NOT NULL
AND visit_id IN (
	SELECT visit_id
	FROM events 
    WHERE events.event_type = 3
)
GROUP BY ph.page_name
ORDER BY num_purchases DESC
LIMIT 3; 

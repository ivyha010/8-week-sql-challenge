/*
A. Customer Nodes Exploration
1. How many unique nodes are there on the Data Bank system?
2. What is the number of nodes per region?
3. How many customers are allocated to each region?
4. How many days on average are customers reallocated to a different node?
5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
*/

-- 1. How many unique nodes are there on the Data Bank system?
-- Results: 5
SELECT 
	COUNT(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;

-- 2. What is the number of nodes per region?
-- Results: 
-- region_id     region_name    num_nodes
-- 1			  Australia	     5
-- 2	          America	     5
-- 3	          Africa	     5
-- 4	          Asia	         5
-- 5	          Europe	     5

SELECT 
	c.region_id,
    r.region_name, 
	COUNT(DISTINCT c.node_id) AS num_nodes
FROM customer_nodes AS c
INNER JOIN regions AS r
	ON c.region_id = r.region_id
GROUP BY c.region_id
ORDER BY c.region_id; 

-- 3. How many customers are allocated to each region?
-- Results: 
-- region_id     region_name  	num_customers
-- 1	          Australia     	110
-- 2	          America	        105
-- 3	          Africa	        102
-- 4	          Asia	            95
-- 5	          Europe	        88

SELECT 
	c.region_id, 
    r.region_name,
	COUNT(DISTINCT c.customer_id) AS num_customers
FROM customer_nodes AS c
INNER JOIN regions AS r
	ON c.region_id = r.region_id
GROUP BY c.region_id, r.region_name
ORDER BY c.region_id; 

-- 4. How many days on average are customers reallocated to a different node?
-- Results: 14.63 
SELECT 
    ROUND(AVG(DATEDIFF(end_date, start_date)), 2) AS avg_days
FROM customer_nodes
WHERE YEAR(end_date) != 9999;

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
-- region_id 	region_name 	median     p80     p95
-- 1			 Australia	      15	    23	    28
-- 2	         America	      15	    23	    28
-- 3	         Africa           15	    24	    28
-- 4	         Asia	          15	    23	    28
-- 5	         Europe	          15	    24	    28

WITH cum_dis AS (
	SELECT 
		c.region_id,
		r.region_name,
		DATEDIFF(c.end_date, c.start_date) AS num_days, 
		CUME_DIST() OVER(PARTITION BY c.region_id ORDER BY DATEDIFF(c.end_date, c.start_date) ASC) AS p
	FROM customer_nodes AS c
	INNER JOIN regions AS r
		ON c.region_id = r.region_id
	WHERE YEAR(c.end_date) != 9999
)

SELECT 
	region_id, 
    region_name, 
    MIN(CASE WHEN p >= 0.5 THEN num_days END) AS median, 
    MIN(CASE WHEN p >= 0.8 THEN num_days END) AS p80, 
    MIN(CASE WHEN p >= 0.95 THEN num_days END) AS p95
FROM cum_dis
GROUP BY region_id, region_name
ORDER BY region_id; 


/*
Transaction Analysis
1. How many unique transactions were there?
2. What is the average unique products purchased in each transaction?
3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
4. What is the average discount value per transaction?
5. What is the percentage split of all transactions for members vs non-members?
6. What is the average revenue for member transactions and non-member transactions?
*/

-- 1. How many unique transactions were there?
-- Results: 2500 
SELECT
	COUNT(DISTINCT txn_id) AS num_transactions
FROM sales;

-- 2. What is the average unique products purchased in each transaction?
-- Results: 6.04 
SELECT 
	ROUND(AVG(num_uniq_products), 2) AS avg_unique_products
FROM (
	SELECT 
		txn_id, 
		COUNT(DISTINCT prod_id) AS num_uniq_products
	FROM sales
	GROUP BY txn_id
) AS info; 

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
-- Results: 
-- percentile_25 	percentile_50 	percentile_75 
--    326.18			441.00			572.75
SELECT 
	MIN(CASE WHEN p >= 0.25 THEN revenue END) AS percentile_25, 
    MIN(CASE WHEN p >= 0.50 THEN revenue END) AS percentile_50,
    MIN(CASE WHEN p >= 0.75 THEN revenue END) AS percentile_75
FROM (SELECT 
		txn_id,
        ROUND(SUM(qty * price * (1.0- discount/100.0)), 2) AS revenue, 
		CUME_DIST() OVER(ORDER BY SUM(qty * price * (1.0- discount/100.0)) ASC) AS p
	FROM sales
    GROUP BY txn_id)
AS cum_dist; 

-- 4. What is the average discount value per transaction?
-- Result: 62.49
SELECT 
    ROUND(AVG(txn_discount), 2) AS avg_discount
FROM (
    SELECT 
        txn_id,
        SUM(qty * price * discount / 100.0) AS txn_discount
    FROM sales
    GROUP BY txn_id
) AS t;

-- 5. What is the percentage split of all transactions for members vs non-members?
-- Results: 
-- member_		num_txn		pct_transactions
-- f			  995			39.80
-- t			 1505			60.20

SELECT 
	member_, 
	COUNT(DISTINCT txn_id) AS num_txn, 
    ROUND(COUNT(DISTINCT txn_id) * 100.0 / SUM(COUNT(DISTINCT txn_id)) OVER(), 2) AS pct_transactions
FROM sales
GROUP BY member_; 

-- 6. What is the average revenue for member transactions and non-member transactions?
-- Results: 
-- member_		avg_txn_revenue
--   t			   454.14
--   f	      	   452.01

SELECT 
	member_, 
    ROUND(AVG(revenue), 2) AS avg_txn_revenue
FROM (
	SELECT 
		txn_id, 
		member_, 
		SUM(qty * price * (1.0 - discount/100.0)) AS revenue 
	FROM sales
	GROUP BY txn_id, member_) AS t
GROUP BY member_; 
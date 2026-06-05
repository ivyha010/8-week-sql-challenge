DROP PROCEDURE IF EXISTS monthly_report; 
DROP TEMPORARY TABLE IF EXISTS monthly_sales; 
DROP TEMPORARY TABLE IF EXISTS in1; 
DROP TEMPORARY TABLE IF EXISTS in2; 
DROP TEMPORARY TABLE IF EXISTS in3; 
DROP TEMPORARY TABLE IF EXISTS id_name; 
DROP TEMPORARY TABLE IF EXISTS monthly_sales;

DELIMITER // 
CREATE PROCEDURE monthly_report (IN report_month DATE)
BEGIN 

	-- Monthly sales table 
	CREATE TEMPORARY TABLE monthly_sales AS (
		SELECT * 
        FROM sales 
        WHERE DATE_FORMAT(start_txn_time, '%Y-%m') = DATE_FORMAT(report_month, '%Y-%m')
    ); 
    
    /* =========================================================
		High Level Sales Analysis
	============================================================ */ 
    -- 1. What was the total quantity sold for all products?
	SELECT 
		'Sales analysis - Q1:' AS report_section, 
		SUM(qty) AS total_quantity
	FROM monthly_sales; 

	-- 2. What is the total generated revenue for all products before discounts?
	SELECT 
		'Sales analysis - Q2:' AS report_section, 
		SUM(qty * price) AS total_revenue
	FROM monthly_sales; 

	-- 3. What was the total discount amount for all products?
	SELECT 
		'Sales analysis - Q3:' AS report_section, 
		ROUND(SUM(qty * price * discount / 100.0), 2) AS total_discount
	FROM monthly_sales; 
	
    /* ========================================================
		Transaction Analysis
    ========================================================= */
    -- 1. How many unique transactions were there?
	SELECT
		'Transaction analysis - Q1:' AS report_section, 
		COUNT(DISTINCT txn_id) AS num_transactions
	FROM monthly_sales;

	-- 2. What is the average unique products purchased in each transaction?
	SELECT 
		'Transaction analysis - Q2:' AS report_section, 
		ROUND(AVG(num_uniq_products), 2) AS avg_unique_products
	FROM (
		SELECT 
			txn_id, 
			COUNT(DISTINCT prod_id) AS num_uniq_products
		FROM monthly_sales
		GROUP BY txn_id
	) AS info; 

	-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
	SELECT 
		'Transaction analysis - Q3:' AS report_section, 
		MIN(CASE WHEN p >= 0.25 THEN revenue END) AS percentile_25, 
		MIN(CASE WHEN p >= 0.50 THEN revenue END) AS percentile_50,
		MIN(CASE WHEN p >= 0.75 THEN revenue END) AS percentile_75
	FROM (SELECT 
			txn_id,
			ROUND(SUM(qty * price * (1.0- discount/100.0)), 2) AS revenue, 
			CUME_DIST() OVER(ORDER BY SUM(qty * price * (1.0- discount/100.0)) ASC) AS p
		FROM monthly_sales
		GROUP BY txn_id)
	AS cum_dist; 

	-- 4. What is the average discount value per transaction?
	SELECT 
		'Transaction analysis - Q4:' AS report_section, 
		ROUND(AVG(txn_discount), 2) AS avg_discount
	FROM (
		SELECT 
			txn_id,
			SUM(qty * price * discount / 100.0) AS txn_discount
		FROM monthly_sales
		GROUP BY txn_id
	) AS t;

	-- 5. What is the percentage split of all transactions for members vs non-members?
	SELECT 
		'Transaction analysis - Q5:' AS report_section, 
		member_, 
		COUNT(DISTINCT txn_id) AS num_txn, 
		ROUND(COUNT(DISTINCT txn_id) * 100.0 / SUM(COUNT(DISTINCT txn_id)) OVER(), 2) AS pct_transactions
	FROM monthly_sales
	GROUP BY member_; 

	-- 6. What is the average revenue for member transactions and non-member transactions?
	SELECT 
		'Transaction analysis - Q6:' AS report_section, 
		member_, 
		ROUND(AVG(revenue), 2) AS avg_txn_revenue
	FROM (
		SELECT 
			txn_id, 
			member_, 
			SUM(qty * price * (1.0 - discount/100.0)) AS revenue 
		FROM monthly_sales
		GROUP BY txn_id, member_) AS t
	GROUP BY member_; 

	/* ======================================================
		Product Analysis
    ======================================================== */
	-- 1. What are the top 3 products by total revenue before discount?
	SELECT 
		'Product Analysis: Q1' AS report_section, 
		s.prod_id, 
		pd.product_name, 
		SUM(s.qty * s.price) AS revenue
	FROM monthly_sales AS s
	INNER JOIN product_details AS pd
		ON s.prod_id = pd.product_id
	GROUP BY s.prod_id, pd.product_name
	ORDER BY revenue DESC
	LIMIT 3; 

	-- 2. What is the total quantity, revenue and discount for each segment?
	SELECT 
		'Product Analysis: Q2' AS report_section, 
		pd.segment_id, 
		pd.segment_name, 
		SUM(s.qty) AS total_quantity, 
		ROUND(SUM(s.qty * s.price * (1.0 - s.discount/100.0)), 2) AS total_revenue, 
		ROUND(SUM(s.qty * s.price * s.discount/100.0), 2) AS total_discount
	FROM monthly_sales AS s
	INNER JOIN product_details AS pd 
		ON s.prod_id = pd.product_id
	GROUP BY pd.segment_id, pd.segment_name
	ORDER BY segment_id; 

	-- 3. What is the top selling product for each segment?
	SELECT 
		'Product Analysis: Q3' AS report_section, 
		segment_id, 
		segment_name, 
		prod_id, 
		product_name, 
		quantity
	FROM (
		SELECT 
			pd.segment_id, 
			pd.segment_name, 
			s.prod_id, 
			pd.product_name,
			SUM(s.qty) AS quantity, 
			RANK() OVER(PARTITION BY segment_id ORDER BY SUM(s.qty) DESC) AS ranking
		FROM monthly_sales AS s 
		INNER JOIN product_details AS pd 
			ON s.prod_id = pd.product_id
		GROUP BY pd.segment_id, pd.segment_name, s.prod_id, pd.product_name) AS t
	WHERE ranking = 1; 

	-- 4. What is the total quantity, revenue and discount for each category?    
	SELECT 
	'Product Analysis: Q4' AS report_section, 
	pd.category_id, 
	pd.category_name, 
	SUM(s.qty) AS total_quantity, 
	ROUND(SUM(s.qty * s.price * (1.0 - s.discount / 100.0)), 2) AS total_revenue, 
	ROUND(SUM(s.qty * s.price * s.discount / 100.0), 2) AS total_discount
	FROM monthly_sales AS s 
	INNER JOIN product_details AS pd 
		ON s.prod_id = pd.product_id
	GROUP BY pd.category_id, pd.category_name
	ORDER BY pd.category_id; 

	-- 5. What is the top selling product for each category?
	SELECT 
		'Product Analysis: Q5' AS report_section, 
		category_id, 
		category_name, 
		prod_id, 
		product_name, 
		total_quantity
	FROM (
		SELECT 
		pd.category_id, 
		pd.category_name, 
		s.prod_id, 
		pd.product_name, 
		SUM(s.qty) AS total_quantity, 
		RANK() OVER(PARTITION BY pd.category_id ORDER BY SUM(s.qty) DESC) AS ranking 
		FROM monthly_sales AS s 
		INNER JOIN product_details AS pd 
			ON s.prod_id = pd.product_id
		GROUP BY s.prod_id, pd.product_name, pd.category_id, pd.category_name) AS t
	WHERE ranking = 1 
	ORDER BY category_id; 

	-- 6. What is the percentage split of revenue by product for each segment?
	SELECT 
		'Product Analysis: Q6' AS report_section, 
		pd.segment_id, 
		pd.segment_name, 
		pd.product_id, 
		pd.product_name, 
		ROUND(SUM(s.qty * s.price * (1.0 - s.discount / 100.0)), 2) AS product_revenue, 
		ROUND(
			SUM(s.qty * s.price * (1.0 - s.discount / 100.0)) * 100.0
			/ 
			SUM(SUM(s.qty * s.price * (1.0 - s.discount / 100.0))) OVER(PARTITION BY pd.segment_id),
			2
		) AS percentage
	FROM monthly_sales AS s 
	INNER JOIN product_details AS pd 
		ON s.prod_id = pd.product_id
	GROUP BY pd.segment_id, pd.segment_name, pd.product_id, pd.product_name
	ORDER BY segment_id, percentage DESC;


	-- 7. What is the percentage split of revenue by segment for each category?
	SELECT 
		'Product Analysis: Q7' AS report_section, 
		pd.category_id,
		pd.category_name,
		pd.segment_id,
		pd.segment_name,
		ROUND(SUM(s.qty * s.price * (1 - s.discount / 100.0)), 2) AS segment_revenue,
		ROUND(
			SUM(s.qty * s.price * (1 - s.discount / 100.0)) * 100.0
			/ 
			SUM(SUM(s.qty * s.price * (1 - s.discount / 100.0))) OVER (PARTITION BY pd.category_id),
			2
		) AS percentage
	FROM monthly_sales AS s
	JOIN product_details AS pd
		ON s.prod_id = pd.product_id
	GROUP BY pd.category_id, pd.category_name, pd.segment_id, pd.segment_name;
		
		
	-- 8. What is the percentage split of total revenue by category?
	SELECT 
		'Product Analysis: Q8' AS report_section, 
		pd.category_id, 
		pd.category_name, 
		ROUND(SUM(s.qty * s.price * (1 - s.discount/100.0)), 2) AS revenue, 
		ROUND(
			SUM(s.qty * s.price * (1 - s.discount/100.0)) * 100.0 
			/
			SUM(SUM(s.qty * s.price * (1 - s.discount/100.0)))  OVER(), 
			2
		) AS percentage
	FROM monthly_sales AS s 
	INNER JOIN product_details AS pd 
		ON s.prod_id = pd.product_id
	GROUP BY pd.category_id, pd.category_name; 

	-- 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where 
	-- at least 1 quantity of a product was purchased divided by total number of transactions)
	SELECT 
		'Product Analysis: Q9' AS report_section, 
		s.prod_id, 
		pd.product_name, 
		COUNT(DISTINCT s.txn_id) AS num_txn, 
		ROUND(
			COUNT(DISTINCT s.txn_id) * 100.0 
			/ (SELECT COUNT(DISTINCT txn_id) FROM sales),
			2
		) AS txn_penetration
	FROM monthly_sales AS s 
	INNER JOIN product_details AS pd
		ON s.prod_id = pd.product_id
	GROUP BY prod_id, pd.product_name; 

	-- 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
	CREATE TEMPORARY TABLE id_name AS (
		SELECT 
			s.prod_id,
			pd.product_name,
			s.qty,
			s.txn_id
		FROM monthly_sales AS s
		INNER JOIN product_details AS pd
			ON s.prod_id = pd.product_id
		WHERE s.qty >= 1);
	
    -- Create temporary table 
	CREATE TEMPORARY TABLE in1 AS
    SELECT * FROM id_name;

    CREATE TEMPORARY TABLE in2 AS
    SELECT * FROM id_name;

    CREATE TEMPORARY TABLE in3 AS
    SELECT * FROM id_name;
    
    SELECT
        'Product Analysis: Q10' AS report_section,
        in1.product_name AS product1,
        in2.product_name AS product2,
        in3.product_name AS product3,
        COUNT(*) AS num_txn
    FROM in1
    INNER JOIN in2
        ON in1.txn_id = in2.txn_id AND in1.prod_id < in2.prod_id
    JOIN in3
        ON in2.txn_id = in3.txn_id AND in2.prod_id < in3.prod_id
    GROUP BY
        product1,
        product2,
        product3
    ORDER BY num_txn DESC;
    
    -- Drop temporary tables
	DROP TEMPORARY TABLE in1;
    DROP TEMPORARY TABLE in2;
    DROP TEMPORARY TABLE in3; 
    DROP TEMPORARY TABLE id_name;
    DROP TEMPORARY TABLE monthly_sales;
END 
// DELIMITER ; 

CALL monthly_report('2021-01-31'); 
-- CALL monthly_report('2021-02-28'); 
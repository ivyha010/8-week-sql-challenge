/* B. Customer Transactions
1. What is the unique count and total amount for each transaction type?
2. What is the average total historical deposit counts and amounts for all customers?
3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
4. What is the closing balance for each customer at the end of the month?
5. What is the percentage of customers who increase their closing balance by more than 5%?
*/

-- 1. What is the unique count and total amount for each transaction type?
-- txn_type    txn_count	total_amount
-- deposit	    2671		  1359168
-- withdrawal	1580		  793003
-- purchase	    1617		  806537

SELECT 
	txn_type,
	COUNT(*) AS transaction_count, 
    SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type; 

-- 2. What is the average total historical deposit counts and amounts for all customers?
-- Results: 
-- avg_deposit_count 	avg_deposit_amount 
-- 		5.34     			2718.34

WITH customer_deposits AS (
    SELECT 
        customer_id,
        COUNT(*) AS deposit_count,
        SUM(txn_amount) AS total_amount
    FROM customer_transactions
    WHERE txn_type = 'deposit'
    GROUP BY customer_id
)

SELECT 
    ROUND(AVG(deposit_count), 2) AS avg_deposit_count,
    ROUND(AVG(total_amount), 2) AS avg_deposit_amount
FROM customer_deposits;

-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
-- Results: 
--  month 	num_customers
-- 2020-01		168
-- 2020-02		181
-- 2020-03		192
-- 2020-04		70

WITH dpw AS (
	SELECT 
		customer_id, 
		DATE_FORMAT(txn_date, '%Y-%m') AS m, 
		SUM(CASE WHEN txn_type = 'deposit' THEN 1  ELSE 0 END) AS num_d, 
		SUM(CASE WHEN txn_type IN ('purchase', 'withdrawal')  THEN 1 ELSE 0 END) AS num_p_w
	FROM customer_transactions
	GROUP BY customer_id, m)
    
SELECT
	m, 
    COUNT(customer_id) AS num_customers
FROM dpw
WHERE num_d > 1 AND num_p_w >= 1
GROUP BY m
ORDER BY m; 


-- 4. What is the closing balance for each customer at the end of the month?
WITH RECURSIVE mdf AS (
	SELECT 
		customer_id, 
		CAST(DATE_FORMAT(txn_date, '%Y-%m-01') AS DATE) AS m_date, 
		SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE (-1) * txn_amount END) AS m_amount
	FROM customer_transactions
    GROUP BY customer_id, m_date
), 

mdf_lead AS (
	SELECT 
		*, 
        LEAD(m_date) OVER(PARTITION BY customer_id ORDER BY m_date) AS next_date
	FROM mdf
), 

update_months AS (
	SELECT
		customer_id, 
        m_date, 
        m_amount, 
        next_date
	FROM mdf_lead
    
    UNION ALL 
    
    SELECT 
		customer_id, 
        DATE_ADD(m_date, INTERVAL 1 MONTH), 
        0, 
        next_date
    FROM update_months 
    WHERE (next_date IS NOT NULL) AND (DATE_ADD(m_date, INTERVAL 1 MONTH) < next_date)
)

SELECT 
	customer_id, 
    DATE_FORMAT(m_date, '%Y-%m') AS month_end, 
    SUM(m_amount) OVER(PARTITION BY customer_id ORDER BY m_date) AS closing_balance
FROM update_months
ORDER BY customer_id, month_end; 


-- 5. What is the percentage of customers who increase their closing balance by more than 5%?
-- Results: 75.80%

WITH monthly_balance AS (
    SELECT 
        customer_id,
        DATE_FORMAT(txn_date, '%Y-%m') AS m,
        SUM(CASE 
            WHEN txn_type = 'deposit' THEN txn_amount 
            ELSE -txn_amount 
        END) AS net_amount
    FROM customer_transactions
    GROUP BY customer_id, m
),

closing_balance AS (
    SELECT 
        customer_id,
        m,
        SUM(net_amount) OVER (PARTITION BY customer_id ORDER BY m) AS balance
    FROM monthly_balance
),

pct_change AS (
    SELECT 
        customer_id,
        balance,
        LAG(balance) OVER (PARTITION BY customer_id ORDER BY m) AS prev_balance
    FROM closing_balance
),

flagged AS (
    SELECT DISTINCT customer_id
    FROM pct_change
    WHERE prev_balance IS NOT NULL
      AND (balance - prev_balance) / NULLIF(prev_balance, 0) > 0.05
)

SELECT 
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM customer_transactions), 2) AS pct_customers
FROM flagged;

/*
D. Extra Challenge: COMPOUNDING INTEREST
*/

WITH RECURSIVE changes AS (
    SELECT 
        customer_id,
        txn_date,
        SUM(CASE 
            WHEN txn_type = 'deposit' THEN txn_amount
            ELSE -txn_amount
        END) AS d_change
    FROM customer_transactions
    GROUP BY customer_id, txn_date
), 

lead_changes AS (
    SELECT 
        *, 
        LEAD(txn_date) OVER (PARTITION BY customer_id ORDER BY txn_date) AS next_txn_date
    FROM changes 
), 

max_lead_changes AS (
    SELECT 
        customer_id, 
        txn_date, 
        d_change, 
        COALESCE(next_txn_date, (SELECT DATE_ADD(MAX(txn_date), INTERVAL 1 DAY) FROM customer_transactions)) AS next_txn_date
    FROM lead_changes 
), 

daily_changes AS (
    SELECT 
        customer_id, 
        txn_date,
        d_change, 
        next_txn_date
    FROM max_lead_changes
    
    UNION ALL 
    
    SELECT 
        customer_id, 
        DATE_ADD(txn_date, INTERVAL 1 DAY), 
        0, 
        next_txn_date
    FROM daily_changes 
    WHERE DATE_ADD(txn_date, INTERVAL 1 DAY) < next_txn_date
), 

-- daily compounding interest calculation: 
daily_compound AS (
    -- base case (first day per customer)
    SELECT 
        customer_id, 
        txn_date, 
        d_change, 
        GREATEST(d_change, 0) * 0.06 / 365 AS interest, 
        d_change + GREATEST(d_change, 0) * 0.06 / 365 AS balance 
    FROM daily_changes
    WHERE (customer_id, txn_date) IN (SELECT customer_id, MIN(txn_date) FROM daily_changes GROUP BY customer_id)
    
    UNION ALL 
    
   SELECT 
    d.customer_id, 
    d.txn_date, 
    d.d_change, 
    GREATEST(pre.balance + d.d_change, 0) * 0.06 / 365 AS interest, 
    (pre.balance + d.d_change) + GREATEST(pre.balance + d.d_change, 0) * 0.06 / 365 AS balance
	FROM daily_compound AS pre
	INNER JOIN daily_changes AS d
		ON d.customer_id = pre.customer_id
		AND d.txn_date = DATE_ADD(pre.txn_date, INTERVAL 1 DAY)
)

-- Total compounding interest calculation
SELECT 
	DATE_FORMAT(txn_date, '%Y-%m') AS m, 
    ROUND(SUM(interest), 2) AS total_interest
FROM daily_compound
GROUP BY m
ORDER BY m;
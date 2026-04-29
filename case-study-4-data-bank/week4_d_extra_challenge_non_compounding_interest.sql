/*
D. Extra Challenge
Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data growth using an interest
 calculation, just like in a traditional savings account you might have with a bank.

If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by increasing their data allocation 
based off the interest calculated on a daily basis at the end of each day, how much data would be required for this option on 
a monthly basis?

Special notes:

Data Bank wants an initial calculation which does not allow for compounding interest, however they may also be interested in a daily 
compounding interest calculation so you can try to perform this calculation if you have the stamina!
*/

-- NON-COMPOUNDING INTEREST: 

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

daily_balance AS (
	SELECT 
		customer_id, 
		txn_date, 
		d_change,
		SUM(d_change) OVER(PARTITION BY customer_id ORDER BY txn_date) AS balance
	FROM daily_changes
), 

-- daily non_compounding interest calculation: 
daily_non_compound AS (
	SELECT 
		customer_id, 
        txn_date, 
        GREATEST(balance, 0) * 0.06/365 AS interest
    FROM daily_balance
)

-- Total non-compounding interest calculation
SELECT 
	DATE_FORMAT(txn_date, '%Y-%m') AS m, 
    ROUND(SUM(interest), 2) AS total_interest
FROM daily_non_compound 
GROUP BY m
ORDER BY m;

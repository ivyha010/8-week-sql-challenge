/*
C. Data Allocation Challenge
To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be 
allocated data using 3 different options:

- Option 1: data is allocated based off the amount of money at the end of the previous month
- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
- Option 3: data is updated real-time

For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate 
how much data will need to be provisioned for each option:

running customer balance column that includes the impact of each transaction
customer balance at the end of each month
minimum, average and maximum values of the running balance for each customer
Using all of the data available - how much data would have been required for each option on a monthly basis?
*/

-- running customer balance column that includes the impact of each transaction
WITH RECURSIVE running_balance AS (
	SELECT 
		customer_id,
		txn_date,
		txn_type,
		txn_amount,
		SUM(CASE 
				WHEN txn_type = 'deposit' THEN txn_amount
				ELSE -txn_amount
			END) OVER (PARTITION BY customer_id ORDER BY txn_date) AS balance
FROM customer_transactions), 


-- Option 1: data is allocated based off the amount of money at the end of the previous month (End-of-month balance)

month_end AS (
	SELECT DISTINCT
		customer_id,
		DATE_FORMAT(txn_date, '%Y-%m') AS m,
		LAST_VALUE(balance) OVER (
			PARTITION BY customer_id, DATE_FORMAT(txn_date, '%Y-%m')
			ORDER BY txn_date
			ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
		) AS closing_balance
	FROM running_balance
), 

-- minimum, average and maximum values of the running balance for each customer

balance_stats AS (
	SELECT 
		customer_id, 
        MIN(balance) AS min_balance, 
        MAX(balance) AS max_balance, 
        ROUND(AVG(balance), 2) AS avg_balance
    FROM running_balance
    GROUP BY customer_id
), 

-- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days (Average balance)

date_series AS (
	SELECT 
		MIN(txn_date) AS dt 
    FROM customer_transactions
    UNION ALL 
    SELECT 
		DATE_ADD(dt, INTERVAL 1 DAY)
    FROM date_series 
    WHERE dt < (SELECT MAX(txn_date) FROM customer_transactions)
), 

customers AS (
	SELECT 
		DISTINCT customer_id
    FROM customer_transactions 
), 

customer_days AS (
	SELECT 
		c.customer_id, 
        ds.dt
    FROM customers AS c
    CROSS JOIN date_series AS ds
), 

joined AS (   
	SELECT 
		cd.customer_id, 
        cd.dt, 
        rb.balance
    FROM customer_days AS cd
    LEFT JOIN running_balance AS rb 
    ON cd.customer_id = rb.customer_id 
		AND rb.txn_date <= cd.dt
), 

rn_correct AS (
	SELECT 
		customer_id, 
        dt, 
        balance, 
        ROW_NUMBER() OVER( PARTITION BY customer_id, dt ORDER BY dt DESC) AS rn 
    FROM joined
), 

daily_balance AS (
	SELECT 
		customer_id, 
		dt, 
		balance
	FROM rn_correct
	WHERE rn = 1
),

avg_30d AS (
	SELECT 
		customer_id, 
        dt, 
        AVG(balance) OVER(PARTITION BY customer_id ORDER BY dt ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS avg_30d_balance
    FROM daily_balance
), 

avg_monthly AS (
	SELECT 
		customer_id, 
        DATE_FORMAT(dt, '%Y-%m') AS m, 
        AVG(avg_30d_balance) AS avg_monthly_balance
    FROM avg_30d 
    GROUP BY customer_id, m
), 

-- Option 3: Real-time balance 
realtime AS (
	SELECT 
		customer_id, 
        DATE_FORMAT(txn_date, '%Y-%m') AS m, 
        MAX(balance) AS max_balance
	FROM running_balance
    GROUP BY customer_id, m
)

SELECT 
	me.m, 
    ROUND(SUM(me.closing_balance), 2) AS opt1_month_end, 
    ROUND(SUM(am.avg_monthly_balance), 2) AS opt2_avg_monthly, 
    ROUND(SUM(r.max_balance), 2) AS opt3_realtime_peak
FROM month_end AS me 
INNER JOIN avg_monthly AS am 
ON me.customer_id = am.customer_id AND me.m = am.m
INNER JOIN realtime AS r
ON me.customer_id = r.customer_id AND me.m = r.m
GROUP BY me.m
ORDER BY me.m; 



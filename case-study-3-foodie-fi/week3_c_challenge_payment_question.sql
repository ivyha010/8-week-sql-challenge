/*
C. Challenge Payment Question
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:
- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments
*/

WITH RECURSIVE base AS (
    SELECT 
        s.customer_id,
        s.plan_id,
        p.plan_name,
        p.price,
        s.start_date,
        LEAD(s.start_date) OVER (PARTITION BY s.customer_id ORDER BY s.start_date) AS next_date
    FROM subscriptions AS s
    INNER JOIN plans AS p 
        ON s.plan_id = p.plan_id
),

paid_plans AS (
    SELECT *
    FROM base
    WHERE plan_id NOT IN (0, 4) 
),

recursive_payments AS (
    -- first payment
    SELECT
        customer_id,
        plan_id,
        plan_name,
        price,
        start_date AS payment_date,
        COALESCE(next_date, '2021-01-01') AS next_date
    FROM paid_plans

    UNION ALL

    -- monthly recurrence
    SELECT
        customer_id,
        plan_id,
        plan_name,
        price,
        DATE_ADD(payment_date, INTERVAL 1 MONTH),
        next_date
    FROM recursive_payments
    WHERE plan_id IN (1,2) -- basic or pro monthly
      AND DATE_ADD(payment_date, INTERVAL 1 MONTH) < next_date
      AND DATE_ADD(payment_date, INTERVAL 1 MONTH) <= '2020-12-31'
), 

with_history AS (
    SELECT 
        rp.*,
        LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY payment_date) AS prev_plan_id,
        LAG(price) OVER (PARTITION BY customer_id ORDER BY payment_date) AS prev_price,
        LAG(payment_date) OVER (PARTITION BY customer_id ORDER BY payment_date) AS prev_payment_date
    FROM recursive_payments AS rp
), 

final_payments AS (
    SELECT 
        customer_id,
        plan_id,
        plan_name,
        CASE 
            -- pro monthly --> pro annual: shift to end of last monthly cycle
            WHEN plan_id = 3 AND prev_plan_id = 2 THEN DATE_ADD(prev_payment_date, INTERVAL 1 MONTH)
            ELSE payment_date
        END AS payment_date,
        CASE 
            -- basic --> monthly or pro: pay difference immediately
            WHEN plan_id IN (2,3) AND prev_plan_id = 1 
                THEN price - prev_price
            ELSE price
        END AS amount
    FROM with_history
)

SELECT 
    customer_id,
    plan_id,
    plan_name,
    payment_date,
    amount,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM final_payments
WHERE YEAR(payment_date) = 2020
ORDER BY customer_id, payment_date;
/*
B. Data Analysis Questions
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
*/

-- 1. How many customers has Foodie-Fi ever had?
-- Expected result: 1000 

SELECT  
	COUNT(DISTINCT customer_id) AS num_customers 
FROM subscriptions; 

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT 
	DATE_FORMAT(start_date, '%Y-%m-01') AS month_start, 
    COUNT(*) AS num_customers
FROM subscriptions
WHERE plan_id = 0
GROUP BY month_start
ORDER BY month_start;  

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT 
    p.plan_name,
    COUNT(*) As num_events 
FROM subscriptions AS s 
INNER JOIN plans As p 
ON s.plan_id = p.plan_id
WHERE YEAR(start_date) > 2020
GROUP BY p.plan_name
ORDER BY p.plan_name; 
 
-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT 
	COUNT(DISTINCT customer_id) AS num_customers, 
    ROUND(
		COUNT(DISTINCT customer_id) * 100.0 / 
        (SELECT COUNT(DISTINCT s.customer_id) FROM subscriptions AS s), 
        1
        ) AS percentage
FROM subscriptions
WHERE plan_id = 4; 

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
-- Expected result: 92 customers (9%)
SELECT 
	COUNT(*) AS num_customers, 
    ROUND(
			COUNT(*) * 100.0 / 
			(SELECT 
				COUNT(customer_id)
			 FROM subscriptions 
             WHERE plan_id = 0
			)
        ) AS percentage 
FROM (
	SELECT 
		customer_id,
        plan_id, 
		LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan
	FROM subscriptions
    ) AS next_table
WHERE plan_id = 0 
AND next_plan = 4; 

-- 6. What is the number and percentage of customer plans after their initial free trial?
WITH num_perc AS (
	SELECT 
		next_plan, 
		COUNT(*) AS num_customers, 
		ROUND(
			COUNT(*) * 100.0/ 
			(
			SELECT
				COUNT(customer_id)
			FROM subscriptions
            WHERE plan_id = 0 
			),
		2
		) AS percentage 
	FROM 
		(SELECT 
			customer_id, 
			plan_id, 
			LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan 
		FROM subscriptions) AS np
	WHERE plan_id = 0 
	GROUP BY next_plan
)

SELECT 
	p.plan_name, 
	np.num_customers, 
    np.percentage 
FROM num_perc AS np
INNER JOIN plans AS p 
ON np.next_plan = p.plan_id
ORDER BY np.next_plan; 

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH diff_cte AS (
	SELECT
		s.customer_id,
        s.plan_id, 
        p.plan_name,
        ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.start_date DESC) AS rn
	FROM subscriptions AS s
    INNER JOIN plans AS p 
    ON s.plan_id = p.plan_id
	WHERE s.start_date <= '2020-12-31'
) 

SELECT 
	plan_id, 
    plan_name,
    COUNT(*) AS num_customers, 
    ROUND(
		COUNT(*) * 100.0/ 
        (
			SELECT 
				COUNT(DISTINCT customer_id)
            FROM subscriptions 
        ), 
        2
    ) AS percentage
FROM diff_cte
WHERE rn = 1
GROUP BY plan_id, plan_name
ORDER BY plan_id; 

-- 8. How many customers have upgraded to an annual plan in 2020?
-- Expected result: 195

WITH latest_plan AS (
	SELECT 
		customer_id, 
		plan_id, 
		start_date, 
		LAG(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS prev_plan
	FROM subscriptions
)

SELECT 
	COUNT(DISTINCT customer_id) AS num_customers
FROM latest_plan
WHERE plan_id = 3 
AND YEAR(start_date) = 2020
AND prev_plan <> 3; 

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
-- Expected result: 104.62
WITH plans_date AS( 
	SELECT 
		customer_id, 
		MIN(CASE WHEN plan_id = 0 THEN start_date END) AS tp_date,  
        MIN(CASE WHEN plan_id = 3 THEN start_date END) AS ap_date 
	FROM subscriptions
    GROUP BY customer_id 
)

SELECT 
	ROUND(AVG(DATEDIFF(ap_date, tp_date)), 2) AS avg_days
FROM plans_date
WHERE ap_date IS NOT NULL; 

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH plans_date AS( 
	SELECT 
		customer_id, 
		MIN(CASE WHEN plan_id = 0 THEN start_date END) AS tp_date,  
        MIN(CASE WHEN plan_id = 3 THEN start_date END) AS ap_date 
	FROM subscriptions
    GROUP BY customer_id 
), 

count_days AS (
	SELECT
		customer_id, 
		DATEDIFF(ap_date, tp_date) AS diff, 
		CASE 
			WHEN DATEDIFF(ap_date, tp_date) BETWEEN 0 AND 30 THEN '0-30 days'
			WHEN DATEDIFF(ap_date, tp_date) BETWEEN 31 AND 60 THEN '31-60 days'
			WHEN DATEDIFF(ap_date, tp_date) BETWEEN 61 AND 90 THEN '61-90 days'
			ELSE 'More than 90 days'
		END AS nd
	FROM plans_date
	WHERE ap_date IS NOT NULL
	)

SELECT 
	nd, 
    COUNT(*) AS num_customers
FROM count_days
GROUP BY nd
ORDER BY 
	CASE 
        WHEN nd = '0-30 days' THEN 1
        WHEN nd = '31-60 days' THEN 2
        WHEN nd = '61-90 days' THEN 3
        ELSE 4
    END; 
    
-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
-- Expected result: 0 
WITH pre_plan AS (
	SELECT 
		customer_id, 
		plan_id, 
		start_date, 
		LAG(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS pp_id
	FROM subscriptions
)

SELECT 
	COUNT(DISTINCT customer_id) AS num_customers
FROM pre_plan
WHERE plan_id = 1
AND pp_id = 2
AND YEAR(start_date) = 2020; 
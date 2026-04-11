/*
D. Outside The Box Questions
The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!
1. How would you calculate the rate of growth for Foodie-Fi?
2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?
*/

/*
1. How would you calculate the rate of growth for Foodie-Fi?
- Customer Growth: Track net new subscribers (sign-ups minus churn) month-over-month or year-over-year
- Revenue Growth: Compare subscription revenue across periods, factoring in upgrades/downgrades
*/

-- Calculate the customer net growth month-over-month
WITH monthly_metrics AS (
	SELECT 
        DATE_FORMAT(start_date, '%Y-%m-01') AS m, 
		SUM(CASE WHEN plan_id = 0 THEN 1 ELSE 0 END) AS signups, 
		SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) AS churns, 
        SUM(CASE WHEN plan_id = 0 THEN 1 ELSE 0 END) - SUM(CASE WHEN plan_id = 4 THEN 1 ELSE 0 END) AS net_new
	FROM subscriptions
	GROUP BY m
	
), 

with_lag AS (
	SELECT 
		m, 
        signups, 
        churns,
        net_new, 
        LAG(net_new) OVER (ORDER BY STR_TO_DATE(m, '%Y-%m-%d')) AS prev_net
    FROM monthly_metrics
)

SELECT 
	m,  
    signups, 
    churns,
    net_new, 
    ROUND((net_new - prev_net) * 100.0/ NULLIF(prev_net, 0), 2)  AS growth_rate_pct
FROM with_lag
ORDER BY STR_TO_DATE(m, '%Y-%m-%d'); 



-- Calculating the revenue growth (monthly recurring revenue) till 2021-12-31: 
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

-- expand each subscription into active months
expanded AS (
    SELECT 
        customer_id,
        plan_id,
        plan_name,
        price,
        start_date,
        COALESCE(next_date, '2022-01-01') AS end_date
    FROM base
    WHERE plan_id NOT IN (0,4)
), 

-- generate month spine
months AS (
    SELECT DATE('2020-01-01') AS m
    UNION ALL
    SELECT DATE_ADD(m, INTERVAL 1 MONTH)
    FROM months
    WHERE m < '2021-12-01'
), 

-- active subscriptions per month
active_subs AS (
    SELECT 
        mo.m,
        e.customer_id,
        e.plan_id,
        e.plan_name,
        CASE 
            WHEN e.plan_id = 3 THEN e.price / 12  -- annual -->  monthly
            ELSE e.price
        END AS mrr_value, 
        e.start_date, 
        e.end_date 
    FROM months AS mo
    INNER JOIN expanded AS e
	ON mo.m >= DATE_FORMAT(e.start_date, '%Y-%m-01')
	AND mo.m < DATE_FORMAT(e.end_date, '%Y-%m-01')
),

monthly_mrr AS (
    SELECT 
        m,
        SUM(mrr_value) AS mrr
    FROM active_subs
    GROUP BY m
), 

final AS (
    SELECT 
        m,
        mrr,
        LAG(mrr) OVER (ORDER BY m) AS prev_mrr
    FROM monthly_mrr
)

SELECT 
    m,
    ROUND(mrr, 2) AS mrr,
    ROUND((mrr - prev_mrr) * 100.0 / NULLIF(prev_mrr, 0), 2) AS mrr_growth_pct
FROM final
ORDER BY m;

-- 2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
/*
1. Weekly Metrics:
- New Subscribers and Churn: Spot short-term shifts in customer behavior
- Plan Upgrades/Downgrades: Detect early signals of satisfaction or dissatisfaction
2. Monthly Metrics: 
- Monthly Recurring Revenue (MRR): Core financial health indicator
- Average Revenue Per User (ARPU): Tracks revenue efficiency
- Retention Rate: Evaluates customer loyalty
3. Quarterly Metrics
- Customer Lifetime Value (CLV): Longer-term profitability measure
- Revenue Growth Rate: Strategic scaling progress
*/

-- 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
-- Churn rate: churned customers / active customers
-- Upgrade/Downgrade behavior: track how customers move between plans 
-- 3.1. Churn rate: 
WITH n_churns AS (
	SELECT 
		DATE_FORMAT(start_date, '%Y-%m-01') AS m, 
		COUNT(DISTINCT customer_id) AS num_churns
	FROM subscriptions
	WHERE plan_id = 4
	GROUP BY m
	ORDER BY m
), 

n_active AS (
	SELECT 
		DATE_FORMAT(start_date, '%Y-%m-01') AS m, 
		COUNT(DISTINCT customer_id) AS num_active
	FROM subscriptions
	WHERE plan_id != 4
	GROUP BY m
	ORDER BY m
)

SELECT 
	a.m, 
    c.num_churns, 
    a.num_active, 
    ROUND(c.num_churns * 100.0/ NULLIF(a.num_active, 0), 2) AS churn_rate
FROM n_active AS a
LEFT JOIN n_churns AS c
ON a.m = c.m
GROUP BY a.m
ORDER BY a.m; 

-- 3.2. Upgrade/Downgrade behavior 
WITH transitions AS (
	SELECT 
		customer_id, 
		plan_id, 
		LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date ASC) AS next_plan 
	FROM subscriptions
)
SELECT 
	plan_id AS from_plan, 
    next_plan AS to_plan, 
    COUNT(*) AS num_transactions
FROM transitions
WHERE next_plan IS NOT NULL
GROUP BY from_plan, to_plan
ORDER BY num_transactions DESC; 

-- 4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
-- 4.1. Primary reason for cancellation: What is the main reason you are cancelling your subscription? (with options such as: too expensive, not enough value/content, 
-- found a better alternative, temporary use only, technical issues, poor user experience, other) 
-- 4.2. Pricing and value perception: 
-- How would you rate the value for money of you plan? (from Very poor to Excellent)
-- Would you consider staying at a lower price? (Yes or No)
-- 4.3. Product and content fit: What was missing from your experience? (More variety, better recommendations, more premium features, easier navigation, other)
-- 4.4. User experience issues: Did you encounter any issues when using the platform? 
-- 4.5. Usage and engagement: How often did you use Foodie-Fi? 
-- 4.6. Competitive insight: Are you switching to anothe service? Yes/No (and which one if the anwer is Yes)
-- 4.7. Save opportunity: What could we have done to keep you? 
-- 4.8. Reengagement permission: Would you like us to notify you about future improvemnets or offers? 	  

-- 5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?
-- 5.1. Pricing and packaging levers: offer discounts before cancellation, introduce a lower-tier/flexible plan, promote annual plans
-- 5.2. Product and content improvements: improve content variety/recommendations, add premium features to increase perceived value, personalize user experience
-- 5.3. Onboarding optimization: better onboarding flow (guided setup, tutorials), highlight key features early, reduce time-to-value
-- 5.4. Engagement and retention tatics: email/push notifications for inactive users, weekly content recommendations, habit-forming features (e.g., reminders)
-- How to validate effectiveness: A/B testing, Pre vs Post analysis (comparing churn rate before vs after change), 
-- cohort analysis (track users by signup month, plan type, feature usage to see if newer cohorts retain better after changes), 
-- revenue impact check (MRR: monthly recurring revenue, ARPU: average revenue per user, customer lifetime value - the total revenue you expect from a customer over their lifetime: LTV = ARPU × Average Customer Lifetime)

-- Retention cohort analysis: 
WITH cohort AS (
    SELECT 
        customer_id,
        DATE_FORMAT(MIN(start_date), '%Y-%m-01') AS cohort_month
    FROM subscriptions
    GROUP BY customer_id
), 

activity AS (
    SELECT 
        customer_id,
        DATE_FORMAT(start_date, '%Y-%m-01') AS activity_month
    FROM subscriptions
    WHERE plan_id != 4  -- exclude churn events
), 

cohort_activity AS (
    SELECT 
        c.cohort_month,
        a.activity_month,
        COUNT(DISTINCT a.customer_id) AS active_users
    FROM cohort AS c
    INNER JOIN activity AS a 
        ON c.customer_id = a.customer_id
       AND a.activity_month >= c.cohort_month
    GROUP BY c.cohort_month, a.activity_month
), 

cohort_size AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_id) AS total_users
    FROM cohort
    GROUP BY cohort_month
)

SELECT 
    ca.cohort_month,
    ca.activity_month,
    ca.active_users,
    cs.total_users,
    ROUND(ca.active_users * 100.0 / cs.total_users, 2) AS retention_rate
FROM cohort_activity AS ca
JOIN cohort_size AS cs 
    ON ca.cohort_month = cs.cohort_month
ORDER BY ca.cohort_month, ca.activity_month;


-- Churn rate over time: 
WITH churned AS (
    SELECT 
        DATE_FORMAT(start_date, '%Y-%m-01') AS mon,
        COUNT(DISTINCT customer_id) AS churns
    FROM subscriptions
    WHERE plan_id = 4
    GROUP BY mon
), 

active_u AS (
    SELECT 
        DATE_FORMAT(start_date, '%Y-%m-01') AS mon,
        COUNT(DISTINCT customer_id) AS active_users
    FROM subscriptions
    WHERE plan_id != 4
    GROUP BY mon
)

SELECT 
    a.mon,
    churns,
    active_users,
    ROUND(churns * 100.0 / NULLIF(active_users, 0), 2) AS churn_rate
FROM active_u AS a
LEFT JOIN churned AS c 
    ON a.mon = c.mon;
    
    
-- Before and after a business change (implemented on '2020-07-01')
SELECT 
    CASE 
        WHEN start_date < '2020-07-01' THEN 'before'
        ELSE 'after'
    END AS period,
    ROUND(COUNT(CASE WHEN plan_id = 4 THEN 1 END) * 100.0 
    / COUNT(DISTINCT customer_id), 2) AS churn_rate
FROM subscriptions
GROUP BY period;
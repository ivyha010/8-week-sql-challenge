/* 
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
Answer: 
Customer 1: trial --> basic monthly 
Customer 2: trial --> pro annual
Customer 3: trial --> basic monthly
Customer 4: trial --> basic monthly --> churn 
Customer 5: trial --> basic monthly
Customer 6: trial --> basic monthly --> churn 
Customer 7: trial --> basic monthly --> pro monthly 
Customer 8: trial --> basic monthly --> pro monthly 
*/

SELECT 
	s.customer_id, 
    GROUP_CONCAT(p.plan_name ORDER BY s.start_date  SEPARATOR ', ') AS onboarding_journey
FROM subscriptions AS s 
INNER JOIN plans AS p 
ON s.plan_id = p.plan_id
GROUP BY s.customer_id
-- ORDER BY s.start_date
LIMIT 8; 
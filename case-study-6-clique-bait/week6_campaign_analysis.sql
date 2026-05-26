/*
Generate a table that has 1 single row for every unique visit_id record and has the following columns:

user_id
visit_id
visit_start_time: the earliest event_time for each visit
page_views: count of page views for each visit
cart_adds: count of product cart add events for each visit
purchase: 1/0 flag if a purchase event exists for each visit
campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
impression: count of ad impressions for each visit
click: count of ad clicks for each visit
(Optional column) cart_products: a comma separated text value with products added to the cart sorted by the order they were added 
to the cart (hint: use the sequence_number)

Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - bonus: prepare a single A4 infographic that 
the team can use for their management reporting sessions, be sure to emphasise the most important points from your findings.

Some ideas you might want to investigate further include:

Identifying users who have received impressions during each campaign period and comparing each metric with other users who did not have an impression event
Does clicking on an impression lead to higher purchase rates?
What is the uplift in purchase rate when comparing users who click on a campaign impression versus users who do not receive an impression? What if we compare them with users who just an impression but do not click?
What metrics can you use to quantify the success or failure of each campaign compared to eachother?
*/

CREATE VIEW campaign_analysis AS (
	WITH cte1 AS (
	SELECT 
		u.user_id, 
		e.visit_id, 
		MIN(e.event_time) AS visit_start_time, 
		SUM(CASE WHEN e.event_type = 1 THEN 1 ELSE 0 END) AS num_page_views, 
		SUM(CASE WHEN e.event_type = 2 THEN 1 ELSE 0 END) AS num_cart_adds, 
		(CASE WHEN SUM(CASE WHEN e.event_type = 3 THEN 1 ELSE 0 END) >= 1 THEN 1 ELSE 0 END) AS purchase, 
		SUM(CASE WHEN e.event_type = 4 THEN 1 ELSE 0 END) AS num_ad_impressions, 
		SUM(CASE WHEN e.event_type = 5 THEN 1 ELSE 0 END) AS num_ad_clicks
	FROM events AS e
	INNER JOIN users AS u
	ON e.cookie_id = u.cookie_id
	GROUP BY u.user_id, e.visit_id
	), 

	cte2 AS (
	SELECT 
		cte1.*, 
		ci.campaign_name
	FROM cte1 
	LEFT JOIN campaign_identifier AS ci
		ON cte1.visit_start_time BETWEEN ci.start_date AND ci.end_date
	), 

	cte3 AS (
		SELECT 
			e.visit_id,
			GROUP_CONCAT(ph.page_name ORDER BY e.sequence_number SEPARATOR ', ') AS cart_products
		FROM events AS e 
		INNER JOIN page_hierarchy AS ph 
			ON e.page_id = ph.page_id
		WHERE ph.product_id IS NOT NULL AND e.event_type = 2
		GROUP BY e.visit_id
	)

	SELECT 
		cte2.*, 
		cte3.cart_products
	FROM cte2 
	LEFT JOIN cte3
		ON cte2.visit_id = cte3.visit_id
	ORDER BY cte2.user_id, cte2.visit_id
);

SELECT * 
FROM campaign_analysis; 


-- Some insights: 
-- 1. The "Half Off - Treat Your Shellf(ish)" campaign generated the highest number of impressions and clicks, indicating the widest customer reach
-- 2. Visits exposed to advertisements had a significantly higher purchase rate (84.13%) than non-exposed visits (38.69%), suggesting campaign visibility positively 
-- influences customer conversion
-- 3. Users who clicked advertisements converted at a substantially higher rate (88.89%) the non-click group (40.29%), indicating strong purchase intent among engaged users.
-- 4. The "Half Off - Treat Your Shellf(ish)" campaign generated the highest browsing activity (13897 views), cart adds (5592) and purchases (1180)
-- 5. The "Half Off - Treat Your Shellf(ish)" campaign drove strong add-to-cart behavior but experienced elevated abandonment rates
-- 6. Purchase rates increased progressively from users with no impression exposure (38.69 %), to impression-only users (64.94%), and were highest among users who clicked campaign ads (88.89%), demonstrating measurable marketing uplift.
-- ------------------------

-- 1. Total visits:  3564, Total purchases:  1777, Overall conversion rate (purchase rate): 49.86%, Total ad clicks: 702
SELECT 
	COUNT(*) AS total_visits, 
    SUM(purchase) AS total_purchases, 
	ROUND(SUM(purchase) * 100.0 / COUNT(*), 2) AS conversion_rate, 
    SUM(num_ad_clicks) AS total_ad_clicks
FROM campaign_analysis; 


-- 1. Campaign reach: How many users/visists were exposed to each campaign? 
-- Results: 
-- campaign_name 						num_users   num_visits   total_impressions   total_clicks    click_through_rate    purchase_rate
-- Half Off - Treat Your Shellf(ish)	449  		 2388			 578    			463				80.10				  	49.41 
-- Null 								183		     512			 129				103				79.84					52.34 
-- 25% Off - Living The Lux Life	    160	         404			 104				81				77.88					50.00
-- BOGOF - Fishing For Compliments	    103	         1260			 65					55				84.62					48.85

 SELECT 
	campaign_name, 
    COUNT(DISTINCT user_id) AS num_users, 
    COUNT(visit_id) AS num_visits, 
    SUM(num_ad_impressions) AS total_impressions, 
    SUM(num_ad_clicks) AS total_clicks, 
    ROUND(SUM(num_ad_clicks) * 100.0 / SUM(num_ad_impressions), 2) AS click_through_rate, 
    SUM(purchase) AS total_purchases, 
    ROUND(AVG(purchase) * 100.0, 2) AS purchase_rate
FROM campaign_analysis
GROUP BY campaign_name 
ORDER BY num_users DESC; 

-- 2. Uplift analysis: Compare "No impression", "Impression Only" (e.i. impression but no clicks), and "Clicked impression" (e.i. impression and click)
-- Results: 
-- impression_group    visits   purchase_rate
-- No Impression		2688	38.69
-- Clicked Impression	702		88.89
-- Impression Only		174		64.94

 SELECT 
	CASE 
		WHEN num_ad_impressions = 0 THEN 'No Impression'
        WHEN num_ad_impressions > 0 AND num_ad_clicks = 0 THEN 'Impression Only'
        WHEN num_ad_impressions > 0 AND num_ad_clicks > 0 THEN 'Clicked Impression'
    END AS impression_group, 
    COUNT(*) AS visits, 
    ROUND(AVG(purchase)*100, 2) AS purchase_rate
 FROM campaign_analysis
 GROUP BY impression_group; 
 
 
-- 3. Click vs no-click convertion rate: Does engagement with ads drive conversion?
-- click_group		visits 		 purchase_rate
-- No click			2862			40.29
-- Click			702				88.89 
SELECT 
	CASE 
		WHEN num_ad_clicks > 0 THEN 'Click' 
        ELSE 'No click' 
    END AS click_group, 
    COUNT(*) AS visits, 
    ROUND(AVG(purchase) * 100, 2) AS purchase_rate 
FROM  campaign_analysis
GROUP BY click_group; 

-- 4. Funnel analysis: views - cart adds - purchases
-- Results: 
-- campaign_name 						 views  cart_adds   purchases
-- Half Off - Treat Your Shellf(ish)	 13897	   5592	     1180
-- 25% Off - Living The Lux Life	     2434	   991	     202
-- BOGOF - Fishing For Compliments	     1536	   625	     127
-- NULL                                  3061	   1243	     268

SELECT 
	campaign_name, 
    SUM(num_page_views) AS views,
    SUM(num_cart_adds) AS cart_adds, 
    SUM(purchase) AS purchases
FROM campaign_analysis
GROUP BY campaign_name; 

-- 5. Cart abandonment analysis: Which campaigns have the worst abandonment?
-- campaign_name   					  cart_adds	 abandoned_visit 
-- Half Off - Treat Your Shellf(ish)	5592   		495
-- 25% Off - Living The Lux Life		991			85
-- BOGOF - Fishing For Compliments		625			53
-- NULL 							   1243	   		100

SELECT 
	campaign_name, 
    SUM(num_cart_adds) AS cart_adds,
    SUM(
		CASE 
			WHEN num_cart_adds > 0 AND purchase = 0 THEN 1 ELSE 0 
        END
    ) AS abandoned_visits 
FROM campaign_analysis
GROUP BY campaign_name; 


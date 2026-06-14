/*
Segment Analysis
1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests 
which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep 
the corresponding month_year
2. Which 5 interests had the lowest average ranking value?
3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and 
its corresponding year_month value? Can you describe what is happening for these 5 interests?
5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services 
should we show to these customers and what should we avoid?
*/

-- 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests 
-- which have the largest composition values in any month_year? Only use the maximum composition value for each interest but you must keep 
-- the corresponding month_year
-- Results: 
--  top_10  	interest_id		month_year		composition 	
-- 					21057		2018-12-01		21.2
-- 					6284		2018-07-01		18.82
-- 					39			2018-07-01		17.44
-- 					77			2018-07-01		17.19
-- 					12133		2018-10-01		15.15
-- 					5969		2018-12-01		15.05
-- 					171			2018-07-01		14.91
-- 					4898		2018-07-01		14.23
-- 					6286		2018-07-01		14.1
-- 					4			2018-07-01		13.97

--  bottom_10  	 interest_id		month_year		composition 	
-- 					33958			2018-08-01			1.88
-- 					37412			2018-10-01			1.94
-- 					19599			2019-03-01			1.97
-- 					19635			2018-07-01			2.05
-- 					19591			2018-10-01			2.08
-- 					37421			2019-08-01			2.09
-- 					42011			2019-01-01			2.09
-- 					22408			2018-07-01			2.12
-- 					34085			2019-08-01			2.14
-- 					36138			2019-02-01			2.18

CREATE TEMPORARY TABLE max_composition AS (
	WITH count_months AS (
		SELECT 
			interest_id, 
			COUNT(DISTINCT month_year) AS total_months 
		FROM interest_metrics
		WHERE month_year IS NOT NULL
		GROUP BY interest_id
	) 

	SELECT 
		im.month_year, 
		im.interest_id, 
        im.composition, 
		ROW_NUMBER() OVER(PARTITION BY im.interest_id ORDER BY im.composition DESC) AS ranking
	FROM interest_metrics AS im 
	INNER JOIN count_months AS cm
		ON im.interest_id = cm.interest_id
	WHERE im.month_year IS NOT NULL 
		AND cm.total_months >= 6
);

-- Top 10 of interests that have the largest composition values
SELECT 
	'' AS top_10,
	interest_id, 
	month_year, 
	composition 
FROM max_composition
WHERE ranking = 1
ORDER BY composition DESC
LIMIT 10; 

-- Bottom 10 of interests that have the largest composition values
SELECT 
	'' AS bottom_10,
	interest_id, 
	month_year, 
	composition 
FROM max_composition
WHERE ranking = 1
ORDER BY composition ASC
LIMIT 10; 

-- 2. Which 5 interests had the lowest average ranking value?
-- Results: 
--   interest_id 	 avg_ranking
-- 		41548			1.00
-- 		42203			4.11
-- 		115				5.93
-- 		48154			7.80
-- 		171				9.36

SELECT 
	interest_id, 
    ROUND(AVG(ranking), 2) AS avg_ranking
FROM interest_metrics
WHERE month_year IS NOT NULL
GROUP BY interest_id
ORDER BY avg_ranking ASC
LIMIT 5; 

-- 3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
-- Results: 
-- interest_id 		std_dev
-- 	6260			41.27
--  131	  			30.72
--  150				30.36
--  23				30.18
--  20764			28.97

SELECT 
	interest_id, 
    ROUND(STDDEV_SAMP(percentile_ranking), 2) AS std_dev
FROM interest_metrics
WHERE month_year IS NOT NULL
GROUP BY interest_id
ORDER BY std_dev DESC
LIMIT 5; 

-- 4. For the 5 interests found in the previous question - what was minimum and maximum percentile_ranking values for each interest and 
-- its corresponding year_month value? Can you describe what is happening for these 5 interests?
-- Results: 
-- max_pct_ranking		interest_id 	month_year 		percentile_ranking 
-- 							131			2018-07-01			75.03
-- 							150			2018-07-01			93.28
-- 							20764		2018-07-01			86.15
-- 							23			2018-07-01			86.69
-- 							6260		2018-07-01			60.63

-- min_pct_ranking		interest_id 	month_year 		percentile_ranking 
-- 							131			2019-03-01			4.84
-- 							150			2019-08-01			10.01
-- 							20764		2019-08-01			11.23
-- 							23			2019-08-01			7.92
-- 							6260		2019-08-01			2.26

-- The 5 interests experienced very large declines in percentile_ranking over time, indicating highly volatile and unstable performance. 
-- Most of them achieved very high rankings in 2018-07-01 but dropped sharply by 2019-03-01 or 2019-08-01, suggesting that these interests 
-- may have been driven by temporary trends, seasonal behavior, or short-term consumer engagement rather than consistent long-term popularity.

CREATE TEMPORARY TABLE ranking AS(
	WITH std_CTE AS (
		SELECT 
			interest_id, 
			ROUND(STDDEV_SAMP(percentile_ranking), 2) AS std_dev
		FROM interest_metrics
		WHERE month_year IS NOT NULL
		GROUP BY interest_id
		ORDER BY std_dev DESC
		LIMIT 5
	) 
    
    SELECT
	im.month_year, 
    im.interest_id, 
    im.percentile_ranking, 
    RANK() OVER(PARTITION BY im.interest_id ORDER BY percentile_ranking DESC) AS max_rnk, 
    RANK() OVER(PARTITION BY im.interest_id ORDER BY percentile_ranking ASC) AS min_rnk
FROM interest_metrics AS im
INNER JOIN std_CTE
	ON im.interest_id = std_CTE.interest_id
); 

-- Maximum percentile_ranking values for each interest
SELECT 
	'' AS max_pct_ranking, 
	interest_id, 
	month_year, 
    percentile_ranking
FROM ranking
WHERE max_rnk = 1; 

-- Minimum percentile_ranking values for each interest
SELECT 
	'' AS min_pct_ranking, 
	interest_id, 
	month_year, 
    percentile_ranking
FROM ranking
WHERE min_rnk = 1; 

-- 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services 
-- should we show to these customers and what should we avoid?
-- Answer: Customers in this segment appear to be highly trend-sensitive and responsive to short-term changes, as shown by the strong fluctuations
--  in composition and percentile ranking values over time. During peak periods, these interests became highly dominant within the customer base, 
-- but their popularity declined quickly afterward, suggesting that these customers are influenced by seasonal trends, viral topics, promotions,
-- or changing consumer preferences rather than stable long-term habits.

-- These customers would likely respond well to trend-driven or seasonal products, limited-time promotions, entertainment, fashion, 
-- lifestyle related offerings

-- Companies should avoid focusing heavily on news subscriptions, review-centric services, automotive comparison platforms, 
-- or niche gaming trend products, as these offerings are less likely to generate strong or sustained customer interest within this segment.

SELECT 
	im.*, 
    mp.interest_name, 
    mp.interest_summary
FROM interest_metrics AS im 
INNER JOIN interest_map AS mp
ON im.interest_id = mp.id
ORDER BY ranking ASC; 

SELECT 
	im.*, 
    mp.interest_name, 
    mp.interest_summary
FROM interest_metrics AS im 
INNER JOIN interest_map AS mp
ON im.interest_id = mp.id
ORDER BY ranking DESC; 
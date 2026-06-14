/*
Interest Analysis
1. Which interests have been present in all month_year dates in our dataset?
2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?
3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - how many total data points would we be removing?
4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.
5. After removing these interests - how many unique interests are there for each month?
*/

-- 1. Which interests have been present in all month_year dates in our dataset?
SELECT 
	interest_id
FROM interest_metrics 
WHERE month_year IS NOT NULL 
GROUP BY interest_id 
	HAVING COUNT(DISTINCT month_year) = (SELECT COUNT(DISTINCT im.month_year) FROM interest_metrics AS im WHERE im.month_year IS NOT NULL); 

-- 2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months -
-- which total_months value passes the 90% cumulative percentage value?
-- Result: the total_months value that passes the 90% cumulative percentage value is 6
-- total_months 	total_ids 	  cum_num 	 pct
-- 14					480			480		39.93
-- 13					82			562		46.76
-- 12					65			627		52.16
-- 11					94			721		59.98
-- 10					86			807		67.14
-- 9					95			902		75.04
-- 8					67			969		80.62
-- 7					90			1059	88.10
-- 6					33			1092	90.85
-- 5					38			1130	94.01
-- 4					32			1162	96.67
-- 3					15			1177	97.92
-- 2					12			1189	98.92
-- 1					13			1202	100.00


WITH count_months AS (
	SELECT 
		interest_id, 
		COUNT(DISTINCT month_year) AS total_months
	FROM interest_metrics
	WHERE month_year IS NOT NULL
	GROUP BY interest_id
), 

grp_num_months AS (
	SELECT
		total_months, 
        COUNT(*) AS total_ids
    FROM count_months 
    GROUP BY total_months
)

SELECT 
	*, 
    SUM(total_ids) OVER(ORDER BY total_months DESC) AS cum_sum, 
    ROUND(100.0 * SUM(total_ids) OVER(ORDER BY total_months DESC) / SUM(total_ids) OVER(), 2) AS pct
FROM grp_num_months
ORDER BY total_months DESC;

-- 3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question - 
-- how many total data points would we be removing?
-- Results: 400

WITH count_months AS (
	SELECT 
		interest_id, 
		COUNT(DISTINCT month_year) AS total_months
	FROM interest_metrics
	WHERE month_year IS NOT NULL
	GROUP BY interest_id
)

SELECT 
	COUNT(*) AS num_data_points
FROM interest_metrics
WHERE interest_id IN (
	SELECT 
		interest_id 
    FROM count_months
    WHERE total_months < 6
); 

-- 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months 
-- present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.
-- Answer: Yes. Removing interests with fewer than 6 months of observations makes sense from a business perspective because it filters out 
-- unstable or short-lived segments and ensures the analysis focuses on consistent and reliable consumer interests. However, it may also 
-- exclude emerging trends, so the decision depends on whether the business prioritises stability or early trend detection.

-- 5. After removing these interests - how many unique interests are there for each month?
-- Results: 
-- month_year	num_interests
-- 2018-07-01		709
-- 2018-08-01		752
-- 2018-09-01		774
-- 2018-10-01		853
-- 2018-11-01		925
-- 2018-12-01		986
-- 2019-01-01		966
-- 2019-02-01		1072
-- 2019-03-01		1078
-- 2019-04-01		1035
-- 2019-05-01		827
-- 2019-06-01		804
-- 2019-07-01		836
-- 2019-08-01		1062

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
    COUNT(DISTINCT im.interest_id) AS num_interests
FROM interest_metrics AS im
INNER JOIN count_months AS cm 
	ON im.interest_id = cm.interest_id
WHERE im.month_year IS NOT NULL 
	AND cm.total_months >= 6
GROUP BY im.month_year
ORDER BY im.month_year ASC; 


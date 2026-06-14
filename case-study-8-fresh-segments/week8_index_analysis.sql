/*
Index Analysis
The index_value is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the composition column by the index_value column rounded to 2 decimal places.

1. What is the top 10 interests by the average composition for each month?
2. For all of these top 10 interests - which interest appears the most often?
3. What is the average of the average composition for the top 10 interests for each month?
4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.
5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right 
-- with the overall business model for Fresh Segments?
*/

-- 1. What is the top 10 interests by the average composition for each month?
CREATE TEMPORARY TABLE top10 AS (
	SELECT 
		*
	FROM (
		SELECT 
		month_year,
		interest_id,  
		ROUND(composition / index_value, 2) AS avg_composition, 
		ROW_NUMBER() OVER(PARTITION BY month_year ORDER BY ROUND(composition / index_value, 2) DESC) AS ranking
		FROM interest_metrics
		WHERE month_year IS NOT NULL
		) AS t
	WHERE ranking <= 10
); 

SELECT * 
FROM top10; 

-- 2. For all of these top 10 interests - which interest appears the most often?
-- Results: 
-- interest_id		appearance_count 
-- 7541					10
-- 5969					10
-- 6065					10

SELECT 
	interest_id, 
    COUNT(*) AS appearance_count
FROM top10
GROUP BY interest_id
ORDER BY appearance_count DESC; 

-- 3. What is the average of the average composition for the top 10 interests for each month?
-- Results: 
-- month_year		avg-avg
-- 2018-07-01		6.04
-- 2018-08-01		5.94
-- 2018-09-01		6.89
-- 2018-10-01		7.07
-- 2018-11-01		6.62
-- 2018-12-01		6.65
-- 2019-01-01	 	6.4
-- 2019-02-01		6.58
-- 2019-03-01		6.17
-- 2019-04-01		5.75
-- 2019-05-01		3.54
-- 2019-06-01		2.43
-- 2019-07-01		2.76
-- 2019-08-01		2.63

SELECT
	month_year, 
	ROUND(AVG(avg_composition), 2) AS avg_avg
FROM top10
GROUP BY month_year
ORDER BY month_year ASC; 

-- 4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 
-- and include the previous top ranking interests in the same output shown below.

WITH avg_composition AS (
	SELECT 
		month_year, 
		interest_id, 
		ROUND(composition / index_value, 2) AS avg_comp, 
		ROW_NUMBER() OVER(PARTITION BY month_year ORDER BY ROUND(composition / index_value, 2) DESC) AS rn
	FROM interest_metrics
	WHERE month_year IS NOT NULL
), 

max_comp AS (
	SELECT 
		ac.month_year, 
		ac.interest_id, 
		ac.avg_comp AS max_index_composition, 
        mp.interest_name 
	FROM avg_composition AS ac
    INNER JOIN interest_map AS mp
		ON ac.interest_id = mp.id
	WHERE rn = 1
), 

lag_data AS (
	SELECT 
		month_year,
		interest_name, 
		max_index_composition, 
		LAG(interest_name) OVER(ORDER BY month_year) AS interest_name_1ma, 
		LAG(max_index_composition) OVER(ORDER BY month_year) AS mic_1ma, 
		LAG(interest_name, 2) OVER(ORDER BY month_year) AS interest_name_2ma, 
		LAG(max_index_composition, 2) OVER(ORDER BY month_year) AS mic_2ma
	FROM max_comp
)

SELECT 
	month_year, 
    interest_name, 
    max_index_composition, 
    ROUND((max_index_composition + mic_1ma + mic_2ma)/3, 2) AS three_month_moving_avg, 
    CONCAT(interest_name_1ma, ' ', mic_1ma) AS one_month_ago, 
	CONCAT(interest_name_2ma, ' ', mic_2ma) AS two_month_ago
FROM lag_data
WHERE month_year BETWEEN '2018-09-01' AND '2019-08-01'; 

-- 5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right 
-- with the overall business model for Fresh Segments?
-- Answer: The maximum average composition may change from month to month because customer interests and behaviors naturally evolve over time 
-- due to seasonality, market trends, marketing campaigns, economic conditions, or external events. Changes in the composition of Fresh Segments'
-- client base could also affect which interests are most dominant in a given month. However, the sharp decline in the maximum average composition 
-- values observed during 2019 may indicate that customer interests are becoming less concentrated in a few high-performing segments. 
-- This could suggest increasing audience fragmentation or a weakening ability of Fresh Segments to identify highly distinctive customer 
-- segments. If this trend continues, it may raise concerns about the effectiveness of the segmentation model and its ability to deliver clear, 
-- actionable insights to clients.
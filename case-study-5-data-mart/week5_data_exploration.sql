/*
2. Data Exploration
1. What day of the week is used for each week_date value?
2. What range of week numbers are missing from the dataset?
3. How many total transactions were there for each year in the dataset?
4. What is the total sales for each region for each month?
5. What is the total count of transactions for each platform
6. What is the percentage of sales for Retail vs Shopify for each month?
7. What is the percentage of sales by demographic for each year in the dataset?
8. Which age_band and demographic values contribute the most to Retail sales?
9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
*/

-- 1. What day of the week is used for each week_date value?
-- Result: Monday
SELECT 
	DISTINCT DAYNAME(week_date) AS day_of_week
FROM clean_weekly_sales;

-- 2. What range of week numbers are missing from the dataset?
WITH RECURSIVE all_weeks AS (
	SELECT 1 AS week_number 
    
    UNION ALL 

    SELECT 
		week_number + 1 
    FROM all_weeks
    WHERE week_number < 52
)

SELECT 
	DISTINCT aw.week_number AS missing_week
FROM all_weeks AS aw
LEFT JOIN clean_weekly_sales AS ws
	ON aw.week_number = ws.week_number
WHERE ws.week_number IS NULL
ORDER BY aw.week_number; 

-- 3. How many total transactions were there for each year in the dataset?
-- Result: 
-- calendar_year  total_transactions 
-- 		2018		346406460
-- 		2019		365639285
-- 		2020		375813651

SELECT 
	calendar_year,
	SUM(transactions) AS total_transactions 
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year; 

-- 4. What is the total sales for each region for each month?
SELECT 
    calendar_year, 
    month_number,
	region, 
	SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY calendar_year, month_number, region
ORDER BY calendar_year, month_number, region; 

-- 5. What is the total count of transactions for each platform
-- Result: 
-- platform   total_transactions
-- Retail	     1081934227
-- Shopify	      5925169
SELECT 
	platform, 
    SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform
ORDER BY total_transactions DESC; 

-- 6. What is the percentage of sales for Retail vs Shopify for each month?
SELECT 
	calendar_year, 
    month_number, 
    platform, 
    SUM(sales) AS total_sales, 
    ROUND(SUM(sales) * 100.0 / NULLIF(SUM(SUM(sales)) OVER(PARTITION BY calendar_year, month_number), 0)
    ,
    2
    ) AS percentage
FROM clean_weekly_sales
GROUP BY calendar_year, month_number, platform
ORDER BY calendar_year, month_number, platform; 

-- 7. What is the percentage of sales by demographic for each year in the dataset?
SELECT 
	calendar_year, 
    demographic, 
    SUM(sales) AS total_sales, 
    ROUND(
		SUM(sales) * 100.0 / NULLIF(SUM(SUM(sales)) OVER(PARTITION BY calendar_year), 0), 
		2) AS sales_percentage
FROM clean_weekly_sales
GROUP BY calendar_year, demographic
ORDER BY calendar_year, demographic; 

-- 8. Which age_band and demographic values contribute the most to Retail sales?
-- Result: 
--  age_band     demographic      total_sales      sales_percentage 
-- 	unknown	      unknown	     16067285533	       40.52

SELECT 
	age_band, 
    demographic, 
    SUM(sales) AS total_sales, 
    ROUND(SUM(sales) * 100.0/ NULLIF(SUM(SUM(sales)) OVER(), 0),
    2) AS sales_percentage
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY total_sales DESC; 

-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? 
-- If not - how would you calculate it instead?
-- Answer: No. If we do so, we calculate average of averages, which is statistically incorrect because different rows 
-- have different transaction volumes, and it ignores weighting. 
SELECT 
	calendar_year, 
    platform, 
    SUM(transactions) AS total_transactions, 
    SUM(sales) AS total_sales, 
    ROUND(SUM(sales) / NULLIF(SUM(transactions), 0), 2) AS avg_transaction_size
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform; 

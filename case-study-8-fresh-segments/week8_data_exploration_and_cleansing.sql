/*
Data Exploration and Cleansing
1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month
2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order (earliest to latest) with the null values appearing first?
3. What do you think we should do with these null values in the fresh_segments.interest_metrics
4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? What about the other way around?
5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.
7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? Do you think these values are valid and why?
*/

-- 1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

SET SQL_SAFE_UPDATES = 0; 

ALTER TABLE interest_metrics 
MODIFY COLUMN month_year VARCHAR(10); 

UPDATE interest_metrics 
SET month_year = DATE_FORMAT(STR_TO_DATE(CONCAT('01-', month_year), '%d-%m-%Y'), '%Y-%m-%d'); 

ALTER TABLE interest_metrics 
MODIFY COLUMN month_year DATE; 

-- 2. What is count of records in the fresh_segments.interest_metrics for each month_year value sorted in chronological order 
-- (earliest to latest) with the null values appearing first?
SELECT 
	month_year, 
    COUNT(*) AS record_count
FROM interest_metrics
GROUP BY month_year
ORDER BY 
	CASE WHEN month_year IS NULL THEN 0 ELSE 1 END, 
	month_year ASC; 

-- 3. What do you think we should do with these null values in the fresh_segments.interest_metrics
-- Answer: We should not treat NULL as a real month, exclude it from time-based aggregations, 
-- and optionally report it separately as part of data quality checks.

-- 4. How many interest_id values exist in the fresh_segments.interest_metrics table but not in the fresh_segments.interest_map table? 
-- What about the other way around?
-- Results: No interest_id values exist in the interest_metrics table but not in the interest_map table.  
-- 7 id values exist in the interest_map table but not in the interest_metrics table. 

SELECT 
	COUNT(DISTINCT me.interest_id) AS num_id_me
FROM interest_metrics AS me 
LEFT JOIN interest_map AS mp 
	ON me.interest_id = mp.id
WHERE mp.id IS NULL; 

SELECT 
	COUNT(DISTINCT mp.id) AS num_id_mp
FROM interest_map AS mp 
LEFT JOIN interest_metrics AS me 
	ON mp.id = me.interest_id
WHERE me.interest_id IS NULL; 

-- 5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table
SELECT 
	id, 
    COUNT(*) AS record_count
FROM interest_map
GROUP BY id
ORDER BY record_count DESC;

-- 6. What sort of table join should we perform for our analysis and why? Check your logic by checking the rows 
-- where interest_id = 21246 in your joined output and include all columns from fresh_segments.interest_metrics and 
-- all columns from fresh_segments.interest_map except from the id column.
-- Answer: We should use an INNER JOIN because the analysis only requires records with matching interest_id values 
-- in both interest_metrics and interest_map. This ensures that each metric record has valid corresponding interest metadata 
-- and avoids including unmatched or incomplete records from either table.

SELECT 
me.*, 
mp.interest_name, 
mp.interest_summary, 
mp.created_at, 
mp.last_modified
FROM interest_metrics AS me 
INNER JOIN interest_map AS mp 
	ON me.interest_id = mp.id
WHERE me.interest_id = 21246;
 
-- 7. Are there any records in your joined table where the month_year value is before the created_at value from the 
-- fresh_segments.interest_map table? Do you think these values are valid and why?
-- Answer: Yes, there are records where the month_year value occurs before the created_at date in interest_map. 
-- These records are likely invalid because an interest should not have metric data before it officially existed in the mapping table. 
-- This may indicate data quality issues, delayed metadata updates, incorrect creation timestamps, or inconsistencies between the two tables.

SELECT 
me.*, 
mp.interest_name, 
mp.interest_summary, 
mp.created_at, 
mp.last_modified
FROM interest_metrics AS me 
INNER JOIN interest_map AS mp 
	ON me.interest_id = mp.id
WHERE me.month_year < mp.created_at; 

SELECT 
	COUNT(*)
FROM (
SELECT 
me.*, 
mp.interest_name, 
mp.interest_summary, 
mp.created_at, 
mp.last_modified
FROM interest_metrics AS me 
INNER JOIN interest_map AS mp 
	ON me.interest_id = mp.id
WHERE me.month_year < mp.created_at) AS t; 
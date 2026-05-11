CREATE TABLE clean_weekly_sales AS (
SELECT 
	STR_TO_DATE(week_date, '%d/%m/%y') AS week_date, 
	WEEKOFYEAR(STR_TO_DATE(week_date, '%d/%m/%y')) AS week_number, 
    MONTH(STR_TO_DATE(week_date, '%d/%m/%y')) AS month_number, 
    YEAR(STR_TO_DATE(week_date, '%d/%m/%y')) AS calendar_year, 
    CASE  
		WHEN SUBSTRING(segment, 2, 1) = '1' THEN 'Young Adults'
        WHEN SUBSTRING(segment, 2, 1) = '2' THEN 'Middle Aged'
        WHEN SUBSTRING(segment, 2, 1) IN ('3', '4') THEN 'Retirees'
        ELSE 'unknown' 
    END AS age_band, 
    CASE 
		WHEN SUBSTRING(segment, 1, 1) = 'C' THEN 'Couples'
        WHEN SUBSTRING(segment, 1, 1) = 'F' THEN 'Families'
        ELSE 'unknown'
    END AS demographic, 
    region, 
    platform, 
    CASE 
		WHEN segment = 'null' THEN 'unknown'
        ELSE segment
    END AS segment, 
    customer_type, 
    transactions, 
    sales, 
    ROUND(sales * 1.0 / NULLIF(transactions, 0), 2) AS avg_transaction
FROM weekly_sales
); 
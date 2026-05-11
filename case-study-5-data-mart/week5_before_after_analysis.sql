/*
3. Before & After Analysis
This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point 
in time.
Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values 
would be before
Using this analysis approach - answer the following questions:
1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and 
percentage of sales?
2. What about the entire 12 weeks before and after?
3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
*/

-- 1.  What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and 
-- percentage of sales?
-- total_sales_before     total_sales_after     sales_change     percentage_change 
-- 		2345878357			2318994169			 -26884188			-1.15

DELIMITER // 
	CREATE PROCEDURE before_after (IN ref_date DATE, IN num_weeks INT)
	BEGIN 
		SELECT 
			total_sales_before, 
            total_sales_after, 
            total_sales_after - total_sales_before AS sales_change, 
             ROUND((total_sales_after - total_sales_before) * 100.0 / NULLIF(total_sales_before, 0), 2) AS percentage_change
        FROM (
			SELECT 
				SUM(CASE 
					WHEN week_date >= DATE_SUB(ref_date, INTERVAL num_weeks WEEK) AND week_date < ref_date THEN sales
					ELSE 0 
				END) AS total_sales_before, 
				SUM(CASE 
					WHEN week_date >= ref_date AND week_date < DATE_ADD(ref_date, INTERVAL num_weeks WEEK) THEN sales
					ELSE 0
				END) AS total_sales_after
			FROM clean_weekly_sales) AS total_sales;
    END // 
DELIMITER ; 

CALL before_after('2020-06-15', 4); 

-- 2.  What about the entire 12 weeks before and after?
-- total_sales_before     total_sales_after     sales_change     percentage_change 
--    7126273147         	6973947753	         -152325394            -2.14

CALL before_after('2020-06-15', 12); 

-- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
-- 3.1. 4 weeks before and after '2018-06-15': 
-- total_sales_before     total_sales_after     sales_change     percentage_change 
--     2125140809	             2129242914	       4102105	           0.19

-- 12 weeks before and after '2018-06-15': 
-- total_sales_before     total_sales_after     sales_change     percentage_change 
--     6396562317	          6500818510	      104256193	           1.63

CALL before_after('2018-06-15', 4);
CALL before_after('2018-06-15', 12);

-- 3.2. 4 weeks before and after '2019-06-15': 
-- total_sales_before     total_sales_after     sales_change     percentage_change 
--     2249989796	          2252326390	       2336594	           0.10

-- 12 weeks before and after '2019-06-15': 
-- 	total_sales_before	     total_sales_after	      sales_change       	percentage_change
--    	6883386397	            6862646103           	-20740294            	-0.30

-- => The sustained decline in sales following the June 2020 change, contrasted with stable or positive trends 
-- in prior years, indicates that the packaging update may have negatively affected customer purchasing behavior.

CALL before_after('2019-06-15', 4);
CALL before_after('2019-06-15', 12);
/*
4. Bonus Question
Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week 
before and after period?
region
platform
age_band
demographic
customer_type
Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?
*/

DELIMITER //

CREATE PROCEDURE factor(
    IN ref_date DATE,
    IN num_weeks INT,
    IN factor_name VARCHAR(20)
)

BEGIN
    IF factor_name NOT IN (
        'region',
        'platform',
        'age_band',
        'demographic',
        'customer_type'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid factor name';
    END IF;

    SET @sql = CONCAT(
    'SELECT 
        factor_value,
        total_sales_before,
        total_sales_after,

        total_sales_after - total_sales_before AS sales_change,

        ROUND(
            (total_sales_after - total_sales_before) * 100.0
            / NULLIF(total_sales_before, 0),
            2
        ) AS percentage_change,

        RANK() OVER (
            ORDER BY (total_sales_after - total_sales_before) ASC
        ) AS absolute_impact_rank,

        RANK() OVER (
            ORDER BY 
            (
                (total_sales_after - total_sales_before) * 100.0
                / NULLIF(total_sales_before, 0)
            ) ASC
        ) AS percentage_impact_rank

    FROM (

        SELECT 
            ', factor_name, ' AS factor_value,
            
            SUM(
                CASE 
                    WHEN week_date >= DATE_SUB(''', ref_date, ''', INTERVAL ', num_weeks, ' WEEK)
                     AND week_date < ''', ref_date, '''
                    THEN sales
                    ELSE 0
                END
            ) AS total_sales_before,

            SUM(
                CASE
                    WHEN week_date >= ''', ref_date, '''
                     AND week_date < DATE_ADD(''', ref_date, ''', INTERVAL ', num_weeks, ' WEEK)
                    THEN sales
                    ELSE 0
                END
            ) AS total_sales_after

        FROM clean_weekly_sales

        GROUP BY ', factor_name, '

    ) AS sales_comparison

    ORDER BY percentage_change ASC'

    );

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END //

DELIMITER ;

CALL factor('2020-06-15', 12, 'region'); 
CALL factor('2020-06-15', 12, 'platform'); 
CALL factor('2020-06-15', 12, 'age_band');  -- 
CALL factor('2020-06-15', 12, 'demographic'); 
CALL factor('2020-06-15', 12, 'customer_type'); 

-- 1. Region
-- Oceania experienced the largest absolute revenue decline ($71,321,100 decrease, -3.03%), indicating the greatest financial impact overall
-- Asia recorded the steepest proportional decline ($53,436,845 decrease, -3.26%), suggesting stronger relative deterioration in sales performance
-- Europe was the only region to show growth ($5,152,392 increase, +4.73%)

-- 2. Platform
-- Retail sales declined ($168,083,834 decrease, -2.43%), making it the primary driver of the overall business downturn
-- Shopify sales increased ($15,758,440 increase, +7.18%), indicating stronger online channel performance during the period

-- 3. Age Band
-- All age bands experienced a decline in sales performance after the intervention period
-- The unknown age band recorded the largest decline ($92,393,021 decrease, -3.34%)
-- Young Adults were the least impacted segment ($7,388,560 decrease, -0.92%)

-- 4. Demographic group
-- Sales declined across all demographic groups
-- The unknown demographic category experienced the largest revenue decline ($92,393,021 decrease, -3.34%)
-- Couples showed the smallest decline ($17,612,358 decrease, -0.87%)

-- 5. Customer Type
-- Guest and Existing customers both experienced declining sales performance:
-- Guest customers: $77,202,666 decrease (-3.00%)
-- Existing customers: $83,872,973 decrease (-2.27%)
-- New customers were the only segment to record growth ($8,750,245 increase, +1.01%)


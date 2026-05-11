##**Case Study \#5: Data Mart**

## *Problem:*

Data Mart is an international retail business that recently introduced a sustainability initiative by no longer providing free plastic bags. The business wants to evaluate how this intervention impacted sales performance across different customer segments, platforms, and regions.

The objective is to analyze pre- and post-intervention sales data to measure the business impact of the policy change and identify which segments were most affected.

Key analytical objectives included:

* Evaluating overall sales performance before and after the intervention

* Analyzing regional and platform-level sales impact

* Assessing customer behavior across age bands and demographic groups

* Measuring sales performance by customer type

* Identifying segments most resilient or vulnerable to the business change


## *Approach:*

The analysis was conducted using transactional sales data containing:

* Regional and platform-level sales information

* Customer demographic and age band segmentation

* Customer type classification (Guest, Existing, New)

* Pre- and post-intervention sales period

To derive insights, I:

* Aggregated sales metrics across multiple customer dimensions

* Compared revenue performance before and after the intervention period

* Calculated absolute and percentage sales changes by segment

* Segmented customer behavior across regions, demographics, and platforms

* Identified top-performing and underperforming segments based on sales trends

* Structured queries using CTEs for modular and scalable analysis


## *Key Insights:*

* Regional Performance: 

- Oceania experienced the largest absolute revenue decline with a $71.3M decrease (-3.03%), indicating the greatest overall financial impact

- Asia recorded the steepest proportional decline with a $53.4M decrease (-3.26%), suggesting stronger relative deterioration in sales performance

- Europe was the only region to achieve growth, increasing by $5.15M (+4.73%)

* Platform Performance: 

- Retail sales declined significantly by $168.1M (-2.43%), making it the primary driver of the overall downturn

- Shopify sales increased by $15.8M (+7.18%), highlighting stronger online channel performance during the intervention period

* Customer Segmentation: 

- All age bands experienced declining sales performance after the intervention

- The Unknown age band recorded the largest decline ($92.4M, -3.34%), while Young Adults were the least impacted ($7.39M, -0.92%)

* Demographic Performance: 

- Sales declined across all demographic groups

- The Unknown demographic category experienced the largest revenue decline ($92.4M, -3.34%)

- Couples showed the smallest decline ($17.6M, -0.87%)

* Customer Type Performance: 

- Guest customers declined by $77.2M (-3.00%)

- Existing customers declined by $83.9M (-2.27%)

- New customers were the only segment to achieve growth, increasing by $8.75M (+1.01%)


## *Business Impact:*

This analysis provides actionable insights to support strategic decision-making, including:

* Regional performance evaluation to identify markets most affected by the intervention

* Channel optimization opportunities through strong Shopify growth relative to retail decline

* Customer segmentation analysis to understand which demographics are most sensitive to operational changes

* Retention and acquisition insights based on differing performance between guest, existing, and new customers

* Policy impact assessment to evaluate how sustainability initiatives influence customer purchasing behavior

From a technical perspective, this project demonstrates:

* Time-based comparative analysis

* Customer and demographic segmentation

* KPI development using absolute and percentage variance calculations

* Multi-dimensional aggregation across business categories

* Structured SQL query design using CTEs and modular logic


## *Tools:*

MySQL Workbench


## *Project Files:*

week5_data.sql - table creation and data setup
week5_data_cleaning.sql - data cleaning and preprocessing
week5_data_exploration.sql - exploratory analysis of sales and customer data
week5_before_after_analysis.sql - comparative analysis of pre- and post-intervention sales performance
week5_bonus_question.sql - extended analysis of business impact across customer segments and regions

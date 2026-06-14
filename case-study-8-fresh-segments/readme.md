## **Case Study \#8: Fresh Segments**
 
## **Problem **

Fresh Segments is a customer segmentation platform that helps businesses better understand consumer interests and behaviors. The company wants to evaluate the quality and stability of its audience segments by analyzing interest composition, ranking changes, and segment performance over time.

The objective is to uncover trends in customer interests, identify high-performing segments, and assess whether the segmentation model continues to generate meaningful and actionable audience insights.

Key analytical objectives included:

* Evaluating the distribution and performance of customer interests

* Identifying top-ranked audience segments over time

* Analyzing changes in interest composition across monthly periods

* Measuring segment concentration and stability

* Assessing the effectiveness of the overall segmentation model

## ** Approach ** 

The analysis was conducted using audience interest and composition data, including:

* Interest metadata and mapping information

* Monthly audience composition metrics

* Segment rankings and performance measures

* Historical interest trends across time periods

To derive insights, I:

* Cleaned and standardized interest-related datasets

* Aggregated composition metrics across monthly reporting periods

* Identified top-performing interests using ranking and window functions

* Analyzed changes in segment composition over time

* Calculated rolling averages and trend metrics to evaluate segment stability

* Structured queries using CTEs and window functions for modular and scalable analysis

## ** Key Insights **

* Interest Performance and Composition

- Interest rankings and composition values varied significantly across reporting periods, reflecting evolving customer behaviors and preferences

- Top-performing interests changed over time, suggesting that audience engagement is influenced by seasonality, market conditions, and external events

- Rolling-average analysis highlighted fluctuations in segment performance rather than consistent long-term dominance by a single interest group.

## ** Segment Stability Analysis **

- Changes in maximum average composition indicate that audience concentration within specific segments is not static.

- Monthly shifts may be driven by seasonal customer behavior, marketing campaigns, economic conditions, changes in client acquisition and audience mix, emerging consumer trends

- A noticeable decline in maximum average composition values during 2019 suggests that customer interests may be becoming less concentrated in highly distinctive segments. This trend could indicate increasing audience fragmentation, making it more difficult to identify strongly differentiated customer groups. If sustained, declining segment concentration may reduce the effectiveness of Fresh Segments' value proposition and limit the ability to deliver clear, actionable audience insights to clients.

## ** Business Impact ** 

This analysis provides strategic insights to support the continuous improvement of Fresh Segments' audience intelligence platform, including:

* Segment quality monitoring through ongoing evaluation of interest composition and ranking changes

* Audience trend detection by identifying emerging and declining customer interests

* Model effectiveness assessment through analysis of segment concentration and stability over time

* Client value optimization by ensuring customer segments remain meaningful, differentiated, and actionable

* Risk identification through early detection of audience fragmentation and weakening segment distinctiveness

From a technical perspective, this project demonstrates:

* Data quality assessment and exploratory analysis

* Time-series and trend analysis using SQL

* Advanced aggregation and rolling-average calculations

* Window functions for ranking and performance tracking

* Translation of analytical findings into strategic business recommendations

## ** Tools ** 

MySQL Workbench

## ** Project Files **

week8_data.sql - table creation and data setup

week8_data_exploration_and_cleansing.sql - exploratory analysis and validation of interest data quality

week8_interest_analysis.sql - analysis of interest rankings, composition metrics, and segment performance

week8_segment_analysis.sql - analysis of segment trends, concentration, and stability over time

week8_index_analysis.sql - analysis of average composition metrics, interest rankings, rolling-average trends, and segment concentration using index-based calculations

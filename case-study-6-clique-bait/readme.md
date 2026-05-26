## **Case Study \#6: Clique Bait**

## *Problem:*

Clique Bait is an online seafood retailer that uses digital campaigns to drive customer engagement and purchases. The business wants to evaluate website funnel performance, advertising effectiveness, and campaign-level conversion behavior.

The objective is to analyze customer interactions across the purchase funnel to identify high-performing campaigns, measure conversion efficiency, and uncover opportunities to reduce cart abandonment.

Key analytical objectives included:

* Analyzing customer conversion behavior across the purchase funnel

* Evaluating campaign performance using click and conversion metrics

* Measuring cart abandonment and purchase completion rates

* Identifying campaigns with the strongest engagement and conversion efficiency

* Assessing the impact of ad clicks on customer purchasing behavior


## *Approach:* 

The analysis was conducted using web event and campaign interaction data, including:

* users - user identifiers, cookie identifiers, and session start dates
* events - visit-level event tracking and customer interactions
* event_identifier - mapping of event types to event names
* page_hierarchy - page metadata and product information
* campaign_identifier - campaign details

The entity relationship diagram (ERD) for these datasets is shown below:

![Entity Relationship Diagram](https://github.com/ivyha010/8-week-sql-challenge/blob/main/case-study-6-clique_bait/ERD_week6.png) 

To derive insights, I:

* Tracked customer progression through the conversion funnel

* Calculated conversion rates across page views, cart additions, and purchases

* Measured campaign performance using click-through and purchase behavior metrics

* Compared conversion performance between ad clickers and non-clickers

* Calculated cart abandonment rates to identify drop-off points in the purchase journey

* Structured queries using CTEs for modular and scalable analysis


## *Key Insights:*

### *Funnel Performance*
* Total visits: 3,564
* Total purchases: 1,777
* Overall conversion rate: 49.86%
* Average conversion rate from page view to cart add: 60.95%
* Average conversion rate from cart add to purchase: 75.93%

### *Advertising Effectiveness*
* Total ad clicks: 702

* Customers who clicked ads converted at 88.89%, more than 2x higher than non-clickers (40.29%). Although only a subset of visits interacted with ads, ad clickers demonstrated exceptionally strong purchase intent.

### *Campaign Performance*
* "Half Off - Treat Your Shellf(ish)" campaign generated the highest visits, impressions, clicks, and purchases

* "BOGOF - Fishing For Compliments" and "Half Off - Treat Your Shellf(ish)" achieved the highest click-through rates (CTR)

* Despite strong engagement, "Half Off - Treat Your Shellf(ish)" also recorded the highest cart abandonment volume with 495 abandoned visits.

## *Business Impact*

This analysis provides actionable insights to improve marketing efficiency and conversion performance, including:

* Funnel optimization through analysis of conversion drop-off and cart abandonment behavior

* Campaign performance evaluation using CTR, click conversion, and purchase metrics

* Advertising effectiveness measurement by comparing conversion behavior between ad clickers and non-clickers

* Customer journey analysis to identify high-intent users and improve purchase completion rates

* Marketing strategy optimization by prioritizing high-performing campaigns and refining underperforming funnel stages

From a technical perspective, this project demonstrates:

* Funnel and conversion analysis using event-level data

* KPI development including conversion rate, CTR, and abandonment metrics

* Campaign-level performance segmentation

* Behavioral analysis across customer interaction stages

* Structured SQL query design using CTEs and modular logic

## *Tools*
MySQL Workbench

## *Project Files*

* week6_data.sql - table creation and data setup

* week6_digital_analysis.sql - analysis of customer behavior 

* week6_product_funnel_analysis.sql - analysis of product-level conversion and abandonment metrics

* week6_campaigns_analysis.sql - campaign performance analysis using impressions, clicks, CTR, and purchase metrics

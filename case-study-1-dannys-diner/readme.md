#**Case Study \#1: Danny's Dinner**

## **Problem:**

Danny owns a restaurant serving three products: ramen, curry, and sushi. He wants to evaluate customer behavior and loyalty program effectiveness using transactional data collected during the restaurant’s early months.

The objective is to transform relational sales data into actionable customer- and product-level insights that support data-driven decision-making around revenue, retention, and promotions.

Key analytical objectives included:

* Analyzing customer revenue contribution and visit frequency

* Identifying top-performing products overall and per customer

* Evaluating purchasing behavior before and after loyalty membership

* Modeling loyalty point calculations under promotional rules


## **Approach:**

The analysis was conducted using three relational tables:

* sales – transaction-level purchase data

* menu – product metadata and pricing

* members – loyalty program enrollment dates


The entity relationship diagram (ERD) for these datasets is shown below:

![Entity Relationship Diagram](https://github.com/ivyha010/8-week-sql-challenge/blob/main/case-study-1-dannys-diner/ERD_week1.png) 


To generate actionable insights, I:

* Joined the fact table (sales) with dimension tables (menu, members) using primary–foreign key relationships

* Calculated customer-level revenue and visit frequency using aggregation functions

* Segmented transactions based on membership join dates to compare pre- and post-membership behavior

* Applied window functions to identify first purchases and product popularity

* Implemented business rules for loyalty point calculations using CASE expressions

* Structured queries with CTEs to enhance modularity, clarity, and maintainability


## **Key Insights:**

* Customer revenue contribution is unevenly distributed, enabling identification of higher-value customers for targeted engagement strategies.

* Sushi is the top-performing product by purchase frequency, indicating strong product-market fit and revenue-driving potential.

* Clear first-purchase patterns emerge across customers, providing insight into initial product preferences and onboarding behavior.

* Purchase frequency increases after loyalty enrollment, suggesting a positive behavioral shift associated with membership participation.

* Promotional point multipliers significantly affect total rewards accumulation, demonstrating how incentive structures can influence perceived customer value.


## **Business Impact:**

This analysis provides actionable insights to support data-driven decision-making, including:

* Customer segmentation based on revenue contribution and visit frequency to prioritize retention strategies

* Product performance evaluation to identify revenue-driving menu items and inform promotional focus

* Loyalty program assessment by measuring behavioral changes before and after membership enrollment

* Promotion optimization through analysis of point multipliers and incentive structures


## **Tools:**

MySQL Workbench – query development, execution, and result validation


## **Project Files:**

* data_week1.sql - SQL script for table creation and data population

* queries_week1.sql - Complete set of analytical queries addressing all business objectives, including bonus tasks

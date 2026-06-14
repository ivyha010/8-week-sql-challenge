## **Case Study \#1: Danny's Dinner**

## **Problem:**

Danny owns a restaurant serving three products: ramen, curry, and sushi. He wants to evaluate customer behavior and loyalty program effectiveness using transactional data collected during the restaurant’s early months.

The objective is to transform relational sales data into actionable customer- and product-level insights that support data-driven decision making around revenue, retention, and promotions.

Key analytical objectives included:

* Analyzing customer revenue contribution and visit frequency

* Identifying top-performing products overall and per customer

* Evaluating purchasing behavior before and after loyalty membership

* Modeling loyalty point calculations under promotional rules


## **Approach:**

The analysis was conducted using three relational tables:

* sales - transaction level purchase data

* menu - product metadata and pricing

* members - loyalty program enrollment dates


The entity relationship diagram (ERD) for these datasets is shown below:

![Entity Relationship Diagram](https://github.com/ivyha010/8-week-sql-challenge/blob/main/case-study-1-dannys-diner/ERD_week1.png) 


To generate actionable insights, I:

* Joined the fact table (sales) with dimension tables (menu, members) using primary - foreign key relationships

* Calculated customer level revenue and visit frequency using aggregation functions

* Segmented transactions based on membership join dates to compare pre- and post-membership behavior

* Applied window functions to identify first purchases and product popularity

* Implemented business rules for loyalty point calculations using CASE expressions

* Structured queries with CTEs to enhance modularity, clarity, and maintainability


## **Key Insights:**

* Customer A generated the highest revenue ($76), closely followed by Customer B ($74), while Customer C spent significantly less ($36), highlighting differences in customer value and spending behavior
 
* Ramen was the most purchased menu item with 8 orders, making it the restaurant's most popular product overall.
  
* Customer preferences varied across the customer base, with ramen emerging as the most popular item for multiple customers.

* Membership enrollment appears to influence purchasing behavior, with members continuing to make purchases after joining and generating additional revenue through repeat visits.

*Loyalty rewards can materially impact customer value perception, with Customer A accumulating the highest reward balance (1,370 points) under the promotional points structure despite only slightly outspending Customer B.


## **Business Impact:**

This analysis provides actionable insights to support data driven decision making, including:

* Customer segmentation based on revenue contribution and visit frequency to prioritize retention strategies

* Product performance evaluation to identify revenue driving menu items and inform promotional focus

* Loyalty program assessment by measuring behavioral changes before and after membership enrollment

* Promotion optimization through analysis of point multipliers and incentive structures


## **Tools:**

MySQL Workbench - query development, execution, and result validation


## **Project Files:**

* data_week1.sql - SQL script for table creation and data population

* queries_week1.sql - Complete set of analytical queries addressing all business objectives, including bonus tasks

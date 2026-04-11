## **Case Study \#3: Foodie-Fi**

## *Problem:*

Foodie-Fi is a subscription-based streaming service offering food-related content. The business aims to understand customer subscription behavior, including trial conversions, plan upgrades, churn, and revenue growth.

The objective is to analyze subscription data to generate insights into customer lifecycle, retention, and revenue performance.

Key analytical objectives included:

* Analyzing customer growth and subscription trends over time

* Evaluating trial conversion and churn rates

* Tracking customer plan upgrades and downgrades

* Measuring revenue distribution across subscription plans

* Understanding customer lifecycle and retention behavior

## *Approach:*

The analysis was conducted using subscription and plan data:

subscriptions: customer subscription history and plan changes
plans: plan details including pricing and tier

To derive insights, I:

* Joined subscription and plan data to enrich customer activity with pricing and plan metadata

* Tracked customer lifecycle stages (trial, active, churned) using date-based logic

* Calculated conversion and churn rates using aggregation and conditional logic

* Analyzed plan transitions (upgrades/downgrades) with window functions

* Aggregated revenue by plan and time period

* Structured queries using CTEs for modular and readable analysis

## *Key Insights:*

* A significant proportion of users convert from trial to paid plans, indicating effective onboarding

* Churn is concentrated after initial subscription periods, highlighting early retention challenges

* Customers tend to upgrade plans over time, contributing to revenue growth

* Monthly plans drive the majority of subscriptions, while annual plans contribute higher per-customer revenue

* Customer lifecycle analysis reveals distinct stages from trial to churn, enabling targeted retention strategies.


## *Business Impact:*

This analysis supports strategic decision-making across growth and retention, including:

* Conversion optimization by identifying drop-off points from trial to paid plans

* Churn reduction strategies through early-stage customer behavior analysis

* Revenue optimization by understanding plan distribution and upgrade patterns

* Customer lifecycle management to improve retention and long-term value

From a technical perspective, this project demonstrates:

* Time-based analysis of subscription data

* Use of window functions to track customer transitions

* Calculation of business KPIs (conversion rate, churn rate, revenue)

* Aggregation and segmentation of customer behavior

* Structured SQL design using CTEs


## *Tools:*

MySQL Workbench


## *Project Files:*

week3_data.sql - table creation and setup 
week3_a_customer_journey.sql - analysis of customer onboarding journeys, tracking individual subscription paths and plan transitions
week3_b_data_analysis_questions.sql - analysis of customer growth, subscription trends, churn rates, and plan transitions across the customer lifecycle
week3_c_challenge_payment_question.sql - payment modeling and revenue calculation based on subscription rules, including upgrades, billing cycles, and churn behavior
week3_d_outside_the_box_questions.sql - exploratory analysis of strategic business questions, including growth rate estimation, KPI recommendations, customer journey analysis, and churn reduction strategies

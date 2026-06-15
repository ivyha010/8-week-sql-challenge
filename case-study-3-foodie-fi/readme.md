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

* Foodie-Fi acquired 1,000 customers during the analysis period, providing a substantial user base for subscription and retention analysis
  
* Only 9% of customers (92 users) churned immediately after the free trial, indicating that the trial program was effective at converting most users into paid subscriptions
  
* Annual plans attracted 195 customers in 2020, demonstrating a meaningful willingness among users to commit to long-term subscriptions
  
* Customers who upgraded to an annual plan took an average of 104.6 days from initial signup, suggesting that plan upgrades typically occur after several months of product usage and engagement
  
* No customers downgraded from a Pro Monthly plan to a Basic Monthly plan during 2020, indicating strong retention among higher-tier subscribers


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

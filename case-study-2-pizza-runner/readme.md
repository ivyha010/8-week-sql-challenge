## **Case Study \#2: Pizza Runner**

## *Problem:*

Pizza Runner is a food delivery business that combines pizza ordering with a network of delivery runners. Danny wants to analyze operational and customer data to improve delivery performance, optimize order processing, and better understand customer preferences.

The challenge is to clean and transform semi-structured order data, then generate insights across order volume, delivery performance, and customer behavior.

Key analytical objectives included:

* Analyzing order volume and delivery success rates

* Evaluating runner performance and delivery times

* Identifying popular pizzas and common customizations

* Assessing the impact of exclusions and extras on orders

* Measuring operational efficiency across the delivery process

## *Approach:*

The analysis was conducted using multiple relational tables, including:

* customer_orders: order level details with exclusions and extras

* runner_orders: delivery status, timestamps, distance and duration data

* pizza_names: pizza menu

* pizza_recipes: standard ingredients per pizza

* pizza_toppings: topping reference data

* runners: registration date of runners 

To prepare and analyze the data, I:

* Cleaned inconsistent values (e.g., 'null', empty strings, whitespace) and standardized formats

* Parsed and normalized comma-separated fields (exclusions, extras) for accurate analysis

* Joined order and delivery datasets to link customer behavior with runner performance

* Filtered successful deliveries by excluding cancelled orders

* Aggregated order volume, delivery metrics, and customer activity

* Calculated delivery durations, distances, and average speeds

* Analyzed pizza popularity and customization patterns

* Structured queries using CTEs for clarity and modularity


## *Key Insights:*

* A portion of orders were cancelled or not delivered, impacting overall operational efficiency

* Delivery times and distances vary across runners, highlighting performance differences

* Certain pizzas are consistently more popular, driving the majority of orders

* Customers frequently customize orders through exclusions and extras, increasing order complexity

* Successful deliveries provide a clearer view of true customer demand and runner performance


## *Business Impact:*

This analysis supports operational and business improvements, including:

* Delivery performance monitoring to identify inefficiencies and optimize runner allocation

* Menu optimization based on popular pizzas and customization trends

* Data quality improvements through standardized handling of semi-structured fields

* Operational efficiency analysis by distinguishing successful and cancelled orders

From a technical perspective, this project demonstrates:

* Data cleaning and preprocessing of messy, real-world datasets

* Handling of semi-structured data within SQL

* Integration of multiple datasets for end-to-end analysis

* Application of aggregation, filtering, and conditional logic

* Structured and scalable SQL query design
  

## *Tools:*

MySQL Workbench


## *Project Files:*

week2_data.sql - table creation and initial data setup

week2_clean_data.sql - data cleaning and preprocessing

week2_a_pizza_metrics.sql - analysis of order volume, delivery performance, preferences, and trends

week2_b_runner_and_customer_experience.sql - analysis of runner performance, delivery efficiency, and customer experience

week2_c_ingredient_optimization.sql - analysis of ingredient usage, customizations, and order composition

week2_d_pricing_and_ratings.sql - pricing analysis and development of a rating system

week2_e_bonus_questions.sql - additional analysis exploring menu expansion scenarios



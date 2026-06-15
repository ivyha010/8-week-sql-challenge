## **Case Study \#4: Data Bank**

## *Problem:*

Data Bank is a digital banking platform that allocates customer data across a distributed network of nodes. The business aims to optimize how data is stored and managed while balancing cost, performance, and scalability.

The objective is to analyze customer transactions, node allocation behavior, and balance growth to support decisions around data allocation strategies and infrastructure design.

Key analytical objectives included:

* Analyzing customer transaction behavior and balance growth

* Evaluating node allocation patterns and reallocation frequency

* Assessing different data allocation strategies (cost vs responsiveness)

* Measuring customer engagement through balance changes over time

* Supporting infrastructure and strategic decision-making

## *Approach:*

The analysis was conducted using multiple relational datasets, including:

* customer_transactions - deposits, withdrawals, and purchases
* customer_nodes - node allocation history
* regions - regional node distribution

The entity relationship diagram (ERD) for these datasets is shown below:

![Entity Relationship Diagram](https://github.com/ivyha010/8-week-sql-challenge/blob/main/case-study-4-data-bank/ERD_week4.png) 

To derive insights, I:

* Joined transactional and node allocation data to link customer activity with infrastructure usage

* Calculated metrics such as transaction volumes, balance growth, and reallocation frequency

* Analyzed customer balance changes using window functions and time-based aggregation

* Evaluated allocation strategies using historical and rolling balance calculations

* Segmented data by region to assess distribution and system design

* Structured queries using CTEs for modular and scalable analysis

## **Key insights:**

* Customers are reallocated approximately every ~14.6 days, indicating a highly dynamic and load-balanced node system

* ~75.8% of customers increase their balance by more than 5% monthly, highlighting strong engagement and consistent deposit behavior

* Deposits dominate transaction activity, confirming that the platform experiences strong inflow and growth-oriented usage patterns 

* The system operates across multiple regions and nodes, supporting scalability, fault tolerance, and reduced single-point failure risk 

* Different data allocation methods present clear trade-offs between cost, accuracy, and responsiveness, requiring strategic optimization 

## **Business Impact:**

This analysis supports strategic and operational decision-making, including:

* Infrastructure optimization by understanding node reallocation patterns and system scalability

* Customer engagement insights through balance growth and transaction behavior analysis

* Data allocation strategy selection by evaluating trade-offs between cost and responsiveness

* Performance and cost efficiency improvements through optimized data distribution models


From a strategic perspective, the analysis recommends:

* Adopting a 30-day average allocation model (Option 2) to balance cost and responsiveness

* Incorporating compounding incentives to drive customer balance growth and retention

* Avoiding full real-time allocation due to high infrastructure costs


From a technical standpoint, this project demonstrates:

* Advanced SQL for time-based and windowed analysis

* Integration of transactional and infrastructure-level data

* KPI development (e.g., reallocation frequency, balance growth rate)

* Analytical thinking applied to system design and business strategy

## **Tools:**

MySQL Workbench

## **Project files:**

week4_data.sql - table creation and data setup

week4_a_customer_nodes_exploration.sql - analysis of node allocation and reallocation patterns

week4_b_customer_transactions.sql - analysis of transaction behavior and balance growth

week4_c_data_allocation_challenge.sql - evaluation of data allocation methods and trade-offs

week4_d_extra_challenge_non_compounding_interest.sql - balance growth analysis using a non-compounding interest model

week4_d_extra_challenge_compounding_interest.sql - balance growth analysis using a compounding interest model

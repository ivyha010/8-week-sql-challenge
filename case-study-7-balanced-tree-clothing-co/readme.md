#**Case Study \#7: Balanced Tree Clothing Co.**


## *Problem*

Balanced Tree Clothing Co. is a fashion retailer seeking to better understand its sales performance, customer purchasing behavior, and product trends. The business wants to evaluate transaction patterns, product performance, and membership behavior to support merchandising and revenue optimization strategies.

The objective is to analyze transactional sales data to generate insights into revenue distribution, customer behavior, product demand, and purchasing patterns.

Key analytical objectives included:

* Evaluating overall sales and discount performance

* Analyzing customer transaction and membership behavior

* Identifying top-performing products, segments, and categories

* Measuring revenue contribution across product segments

* Discovering common product combinations and purchasing patterns

## *Approach*

The analysis was conducted using transactional sales and product hierarchy data, including:

* Sales transactions and revenue metrics

* Product categories, segments, and product details

* Membership and transaction-level purchase behavior

* Discounts and product quantity information

To derive insights, I:

* Aggregated revenue, quantity, and discount metrics across products and categories

* Analyzed transaction behavior using averages and percentile calculations

* Compared purchasing patterns between members and non-members

* Identified top-selling products by category and segment

* Calculated revenue contribution percentages across segments and categories

* Performed basket analysis to identify common product combinations

* Structured queries using CTEs and window functions for modular and scalable analysis

## *Key Insights*

### *High-Level Sales Performance*

* Total quantity sold: 45,216 products

* Total revenue before discounts: $1,289,453

* Total discount amount: $156,229.14

### *Transaction Analysis*

* Total unique transactions: 2,500

* Customers purchased an average of 6.04 unique products per transaction

* Revenue per transaction distribution:
    25th percentile: $326.18
    50th percentile (median): $441.00
    75th percentile: $572.75

* Average discount per transaction: $62.49

* 60.20% of transactions were made by members, compared to 39.80% by non-members

* Member transactions generated a slightly higher average revenue ($454.14) than non-member transactions ($452.01)

### *Product and Category Performance*

* Top 3 products by revenue:
    Blue Polo Shirt - Mens
    Grey Fashion Jacket - Womens
    White Tee Shirt - Mens

* Shirts generated the highest segment revenue at $356,548.73, followed by Jackets at $322,705.54

* Mens products contributed 55.37% of total revenue, outperforming Womens products at 44.63% 

* Top-selling products by category:
Mens: Blue Polo Shirt - Mens (3,819 units)
Womens: Grey Fashion Jacket - Womens (3,876 units)

### *Basket Analysis*

The most common 3-product combination: White Tee Shirt - Mens, Grey Fashion Jacket - Womens, Teal Button Up Shirt - Mens, appearing together in 352 transactions.

## *Business Impact*

This analysis provides actionable insights to support merchandising and sales strategy decisions, including:

* Revenue optimization through identification of high-performing products and categories

* Customer behavior analysis using transaction patterns and membership segmentation

* Product mix evaluation to understand category and segment contribution to revenue

* Discount strategy assessment through transaction-level discount analysis

* Cross-selling opportunities using product combination and basket analysis insights

From a technical perspective, this project demonstrates:

* Advanced aggregation and revenue analysis

* Percentile and transaction distribution analysis

* Product hierarchy and segmentation analysis

* Basket analysis for identifying purchasing patterns

* Structured SQL query design using CTEs and window functions

## *Tools*

MySQL Workbench

## *Project Files*

* week7_data.sql - table creation and data setup

* week7_high_level_sales_analysis.sql - analysis of overall sales, revenue, and discount performance

* week7_transaction_analysis.sql - analysis of transaction behavior, purchasing patterns, and membership performance

* week7_product_analysis.sql - analysis of product performance, category contribution, and basket combinations

* week7_reporting_challenge.sql - combination of all previous questions into a scheduled report

* week7_bonus_challenge.sql - transformation of the product_hierarchy and product_prices datasets to the product_details table using a single query

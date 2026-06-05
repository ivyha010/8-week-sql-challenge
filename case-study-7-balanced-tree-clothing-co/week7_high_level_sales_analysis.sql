/*
High Level Sales Analysis
1. What was the total quantity sold for all products?
2. What is the total generated revenue for all products before discounts?
3. What was the total discount amount for all products?
*/ 

-- 1. What was the total quantity sold for all products?
-- Results: 45216 
SELECT 
	SUM(qty) AS total_quantity
FROM sales; 

-- 2. What is the total generated revenue for all products before discounts?
-- Result: 1289453
SELECT 
	SUM(qty * price) AS total_revenue
FROM sales; 

-- 3. What was the total discount amount for all products?
-- Result: 156229.14
SELECT 
	ROUND(SUM(qty * price * discount / 100.0), 2) AS total_discount
FROM sales; 
/*
Product Analysis
1. What are the top 3 products by total revenue before discount?
2. What is the total quantity, revenue and discount for each segment?
3. What is the top selling product for each segment?
4. What is the total quantity, revenue and discount for each category?
5. What is the top selling product for each category?
6. What is the percentage split of revenue by product for each segment?
7. What is the percentage split of revenue by segment for each category?
8. What is the percentage split of total revenue by category?
9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
*/

-- 1. What are the top 3 products by total revenue before discount?
-- Results: 
-- prod_id				 product_name 				revenue 
-- 2a2353			Blue Polo Shirt - Mens			217683
-- 9ec847		Grey Fashion Jacket - Womens		209304
-- 5d267b			White Tee Shirt - Mens			152000

SELECT 
	s.prod_id, 
    pd.product_name, 
    SUM(s.qty * s.price) AS revenue
FROM sales AS s
INNER JOIN product_details AS pd
	ON s.prod_id = pd.product_id
GROUP BY s.prod_id, pd.product_name
ORDER BY revenue DESC
LIMIT 3; 

-- 2. What is the total quantity, revenue and discount for each segment?
-- segment_id 		segment_name 		total_quantity		total_revenue		total_discount
-- 		3				Jeans				11349				183006.03			25343.97
-- 		4				Jacket				11385				322705.54			44277.46
-- 		5				Shirt				11265				356548.73			49594.27
-- 		6				Socks				11217				270963.56			37013.44

SELECT 
	pd.segment_id, 
    pd.segment_name, 
    SUM(s.qty) AS total_quantity, 
    ROUND(SUM(s.qty * s.price * (1.0 - s.discount/100.0)), 2) AS total_revenue, 
	ROUND(SUM(s.qty * s.price * s.discount/100.0), 2) AS total_discount
FROM sales AS s
INNER JOIN product_details AS pd 
	ON s.prod_id = pd.product_id
GROUP BY pd.segment_id, pd.segment_name
ORDER BY segment_id; 

-- 3. What is the top selling product for each segment?
-- Results: 
-- segment_id 		segment_name 		prod_id 			product_name				quantity 
-- 		3				Jeans			c4a632		Navy Oversized Jeans - Womens		  3856
-- 		4				Jacket			9ec847		Grey Fashion Jacket - Womens		  3876
-- 		5				Shirt			2a2353		Blue Polo Shirt - Mens				  3819
--      6				Socks			f084eb		Navy Solid Socks - Mens				  3792

SELECT 
	segment_id, 
    segment_name, 
    prod_id, 
    product_name, 
    quantity
FROM (
	SELECT 
		pd.segment_id, 
		pd.segment_name, 
		s.prod_id, 
		pd.product_name,
		SUM(s.qty) AS quantity, 
		RANK() OVER(PARTITION BY segment_id ORDER BY SUM(s.qty) DESC) AS ranking
	FROM sales AS s 
	INNER JOIN product_details AS pd 
		ON s.prod_id = pd.product_id
	GROUP BY pd.segment_id, pd.segment_name, s.prod_id, pd.product_name) AS t
WHERE ranking = 1; 

-- 4. What is the total quantity, revenue and discount for each category?
-- Results: 
-- category_id		category_name		total_quantity		total_revenue		total_discount
-- 		1				Womens				22734			  505711.57				69621.43
-- 		2				Mens				22482			  627512.29				86607.71

SELECT 
pd.category_id, 
pd.category_name, 
SUM(s.qty) AS total_quantity, 
ROUND(SUM(s.qty * s.price * (1.0 - s.discount / 100.0)), 2) AS total_revenue, 
ROUND(SUM(s.qty * s.price * s.discount / 100.0), 2) AS total_discount
FROM sales AS s 
INNER JOIN product_details AS pd 
    ON s.prod_id = pd.product_id
GROUP BY pd.category_id, pd.category_name
ORDER BY pd.category_id; 

-- 5. What is the top selling product for each category?
-- Results:
-- category_id 		category_name		prod_id			product_name				total_quantity
-- 		1				Womens			9ec847		Grey Fashion Jacket - Womens		3876
-- 		2				Mens			2a2353		Blue Polo Shirt - Mens				3819

SELECT 
	category_id, 
	category_name, 
	prod_id, 
	product_name, 
	total_quantity
FROM (
	SELECT 
	pd.category_id, 
	pd.category_name, 
	s.prod_id, 
	pd.product_name, 
	SUM(s.qty) AS total_quantity, 
	RANK() OVER(PARTITION BY pd.category_id ORDER BY SUM(s.qty) DESC) AS ranking 
	FROM sales AS s 
	INNER JOIN product_details AS pd 
		ON s.prod_id = pd.product_id
	GROUP BY s.prod_id, pd.product_name, pd.category_id, pd.category_name) AS t
WHERE ranking = 1 
ORDER BY category_id; 

-- 6. What is the percentage split of revenue by product for each segment?
-- Results: 
-- segment_id		segment_name		pd.product_id 			product_name				product_revenue 	percentage 
-- 		3				Jeans				e83aa3			Black Straight Jeans - Womens		106407.04		  58.14
-- 		3				Jeans				c4a632			Navy Oversized Jeans - Womens		43992.39		  24.04
-- 		3				Jeans				e31d39			Cream Relaxed Jeans - Womens		32606.60		  17.82
-- 		4				Jacket				9ec847			Grey Fashion Jacket - Womens		183912.12		  56.99
-- 		4				Jacket				d5e9a6			Khaki Suit Jacket - Womens			76052.95		  23.57
-- 		4				Jacket				72f5d4			Indigo Rain Jacket - Womens			62740.47		  19.44
-- 		5				Shirt				2a2353			Blue Polo Shirt - Mens				190863.93		  53.53
-- 		5				Shirt				5d267b			White Tee Shirt - Mens				133622.40		  37.48
-- 		5				Shirt				c8d436			Teal Button Up Shirt - Mens			32062.40		  8.99
-- 		6				Socks				f084eb			Navy Solid Socks - Mens				119861.64		  44.24
-- 		6				Socks				2feb6b			Pink Fluro Polkadot Socks - Mens	96377.73		  35.57
--  	6				Socks				b9a74d			White Striped Socks - Mens			54724.19		  20.20

SELECT 
	pd.segment_id, 
	pd.segment_name, 
	pd.product_id, 
	pd.product_name, 
	ROUND(SUM(s.qty * s.price * (1.0 - s.discount / 100.0)), 2) AS product_revenue, 
	ROUND(
		SUM(s.qty * s.price * (1.0 - s.discount / 100.0)) * 100.0
		/ 
		SUM(SUM(s.qty * s.price * (1.0 - s.discount / 100.0))) OVER(PARTITION BY pd.segment_id),
		2
	) AS percentage
FROM sales AS s 
INNER JOIN product_details AS pd 
	ON s.prod_id = pd.product_id
GROUP BY pd.segment_id, pd.segment_name, pd.product_id, pd.product_name
ORDER BY segment_id, percentage DESC;


-- 7. What is the percentage split of revenue by segment for each category?
-- Results: 
-- category_id		category_name		pd.segment_id		pd.segment_name 		segment_revenue		percentage
-- 		1				Womens				3					Jeans				183006.03			  36.19
-- 		1				Womens				4					Jacket				322705.54			  63.81
-- 		2				Mens	 			5					Shirt				356548.73			  56.82
-- 		2	            Mens	            6	                Socks	            270963.56	          43.18

SELECT 
    pd.category_id,
    pd.category_name,
    pd.segment_id,
    pd.segment_name,
    ROUND(SUM(s.qty * s.price * (1 - s.discount / 100.0)), 2) AS segment_revenue,
    ROUND(
        SUM(s.qty * s.price * (1 - s.discount / 100.0)) * 100.0
        / 
        SUM(SUM(s.qty * s.price * (1 - s.discount / 100.0))) OVER (PARTITION BY pd.category_id),
        2
    ) AS percentage
FROM sales AS s
JOIN product_details AS pd
    ON s.prod_id = pd.product_id
GROUP BY pd.category_id, pd.category_name, pd.segment_id, pd.segment_name;
    
    
-- 8. What is the percentage split of total revenue by category?
-- Results: 
-- category_id		category_name		revenue			percentage
-- 		1				Womens		  505711.57			  44.63
-- 		2				Mens		  627512.29			  55.37

SELECT 
	pd.category_id, 
    pd.category_name, 
    ROUND(SUM(s.qty * s.price * (1 - s.discount/100.0)), 2) AS revenue, 
    ROUND(
		SUM(s.qty * s.price * (1 - s.discount/100.0)) * 100.0 
		/
        SUM(SUM(s.qty * s.price * (1 - s.discount/100.0)))  OVER(), 
        2
	) AS percentage
FROM sales AS s 
INNER JOIN product_details AS pd 
	ON s.prod_id = pd.product_id
GROUP BY pd.category_id, pd.category_name; 

-- 9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where 
-- at least 1 quantity of a product was purchased divided by total number of transactions)
-- Results: 
-- prod_id	product_name						num_txn		txn_penetration
-- 2a2353	Blue Polo Shirt - Mens				1268		50.72
-- 2feb6b	Pink Fluro Polkadot Socks - Mens	1258		50.32
-- 5d267b	White Tee Shirt - Mens				1268		50.72
-- 72f5d4	Indigo Rain Jacket - Womens			1250		50.00
-- 9ec847	Grey Fashion Jacket - Womens		1275		51.00
-- b9a74d	White Striped Socks - Mens			1243		49.72
-- c4a632	Navy Oversized Jeans - Womens		1274		50.96
-- c8d436	Teal Button Up Shirt - Mens			1242		49.68
-- d5e9a6	Khaki Suit Jacket - Womens			1247		49.88
-- e31d39	Cream Relaxed Jeans - Womens		1243		49.72
-- e83aa3	Black Straight Jeans - Womens		1246		49.84
-- f084eb	Navy Solid Socks - Mens				1281		51.24

SELECT 
	s.prod_id, 
    pd.product_name, 
    COUNT(DISTINCT s.txn_id) AS num_txn, 
    ROUND(
		COUNT(DISTINCT s.txn_id) * 100.0 
        / (SELECT COUNT(DISTINCT txn_id) FROM sales),
        2
	) AS txn_penetration
FROM sales AS s 
INNER JOIN product_details AS pd
	ON s.prod_id = pd.product_id
GROUP BY prod_id, pd.product_name; 

-- 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
-- Results: 
-- 			product1 				product2  							product3			  num_txn
-- White Tee Shirt - Mens	Grey Fashion Jacket - Womens	Teal Button Up Shirt - Mens			352

WITH id_name AS (
	SELECT 
		s.prod_id, 
		pd.product_name, 
		s.qty, 
		s.txn_id
	FROM sales AS s
	INNER JOIN product_details AS pd 
		ON s.prod_id = pd.product_id
	WHERE s.qty >= 1
), 

join_products AS (
	SELECT 
		DISTINCT in1.txn_id, 
		in1.product_name AS product1, 
        in2.product_name AS product2, 
        in3.product_name AS product3
    FROM id_name AS in1
    INNER JOIN id_name AS in2 
		ON in1.txn_id = in2.txn_id
	INNER JOIN id_name AS in3
		ON in1.txn_id = in3.txn_id
	WHERE in1.prod_id < in2.prod_id AND in2.prod_id < in3.prod_id
)

SELECT
	product1, 
    product2, 
    product3, 
	COUNT(*) AS num_txn
FROM join_products
GROUP BY product1, product2, product3
ORDER BY num_txn DESC; 
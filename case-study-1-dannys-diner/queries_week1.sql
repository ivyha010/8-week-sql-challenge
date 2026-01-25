/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Solution:
-- 1. What is the total amount each customer spent at the restaurant?
SELECT sales.customer_id, SUM(menu.price) AS total_amount_spent
FROM sales 
INNER JOIN menu 
ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) AS number_days 
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH rank_CTE AS (
	SELECT 
		s.customer_id, 
        s.order_date, 
        mn.product_name,
		RANK() OVER(PARTITION BY customer_id ORDER BY order_date ASC) AS ranking
	FROM sales AS s 
	INNER JOIN menu AS mn 
	ON s.product_id = mn.product_id)
    
SELECT 
	customer_id, 
    product_name
FROM rank_CTE
WHERE ranking = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
WITH rank_CTE AS (
	SELECT 
		mn.product_name, 
		COUNT(s.order_date) AS times, 
		RANK() OVER(ORDER BY COUNT(s.order_date) DESC) AS ranking
	FROM sales AS s
	INNER JOIN menu AS mn 
	ON s.product_id = mn.product_id
	GROUP BY mn.product_name)

SELECT 
	product_name, 
    times
FROM rank_CTE
WHERE ranking = 1;



-- 5. Which item was the most popular for each customer?
WITH rank_table AS (
SELECT *, 
	RANK() OVER (PARTITION BY t_table.customer_id ORDER BY t_table.count_purchase DESC) AS ranking
FROM 
	(SELECT s.customer_id, s.product_id, m.product_name, COUNT(s.product_id) AS count_purchase
	FROM sales AS s
	INNER JOIN menu AS m
	ON s.product_id = m.product_id
	GROUP BY s.customer_id, s.product_id) AS t_table
)

SELECT customer_id, product_name AS most_popular_item
FROM rank_table
WHERE ranking = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH rank_CTE AS (
	SELECT 
		s.customer_id, 
		s.order_date, 
		m.join_date, 
		mn.product_name, 
		RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS ranking
	FROM sales AS s 
	INNER JOIN members AS m
	ON s.customer_id = m.customer_id
	INNER JOIN menu AS mn
	ON s.product_id = mn.product_id
	WHERE s.order_date >= m.join_date)

SELECT 
	customer_id,
    product_name 
FROM rank_CTE
WHERE ranking = 1;


 -- 7. Which item was purchased just before the customer became a member?
 WITH rank_CTE AS (
	 SELECT 
		s.customer_id,
		mn.product_name,
		RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) AS ranking
	 FROM sales AS s 
	 INNER JOIN members AS m
	 ON s.customer_id = m.customer_id
	 INNER JOIN menu AS mn 
	 ON s.product_id = mn.product_id
	 WHERE s.order_date < m.join_date)

SELECT 
	customer_id, 
    product_name
FROM rank_CTE
WHERE ranking = 1;
 

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
	s.customer_id, 
    COUNT(s.product_id) AS total_items,
    SUM(price) AS total_spend
FROM sales AS s 
INNER JOIN members AS m
ON s.customer_id = m.customer_id
INNER JOIN menu AS mn 
ON s.product_id = mn.product_id
WHERE order_date < join_date
GROUP BY s.customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
	s.customer_id, 
    SUM(CASE mn.product_name
		WHEN 'sushi' THEN 2 * 10 * price
        ELSE 10 * price
    END) AS num_points
FROM sales AS s 
INNER JOIN menu as mn 
ON s.product_id = mn.product_id
GROUP BY s.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH joined_table AS (
	SELECT 
		m.customer_id, 
		m.join_date, 
		s.order_date, 
		s.product_id, 
		mn.product_name, 
		mn.price, 
		datediff(s.order_date, m.join_date), 
		CASE 
			WHEN  ((datediff(s.order_date, m.join_date) >= 0) AND (datediff(s.order_date, m.join_date) <= 6)) OR mn.product_name = 'sushi' THEN 2
			ELSE 1
		END AS multiplier 
	FROM members AS m 
	INNER JOIN sales AS s
	ON m.customer_id = s.customer_id
	INNER JOIN menu AS mn
	ON s.product_id = mn.product_id
	WHERE MONTH(order_date) <= 1 AND YEAR(order_date) = 2021)
    
SELECT 
	customer_id, 
    SUM(price * multiplier * 10) AS total_points 
FROM joined_table
GROUP BY customer_id;

-- Bonus question 1: Join All The Things
SELECT 
	s.customer_id, 
    s.order_date, 
    mn.product_name, 
    mn.price, 
    CASE
		WHEN (s.order_date < m.join_date) OR m.join_date IS NULL  THEN 'N'
        ELSE 'Y'
    END AS member 
FROM sales AS s 
INNER JOIN menu AS mn 
ON s.product_id = mn.product_id 
LEFT JOIN members AS m 
ON s.customer_id = m.customer_id
ORDER BY s.customer_id, s.order_date;

-- Bonus question 2: Rank all the things
WITH yn_CTE AS (
	SELECT 
	s.customer_id, 
    s.order_date, 
    mn.product_name, 
    mn.price, 
    CASE
		WHEN (s.order_date < m.join_date) OR m.join_date IS NULL  THEN 'N'
        ELSE 'Y'
    END AS member_yn 
	FROM sales AS s 
	INNER JOIN menu AS mn 
	ON s.product_id = mn.product_id 
	LEFT JOIN members AS m 
	ON s.customer_id = m.customer_id
	ORDER BY s.customer_id, s.order_date)

SELECT *, 
	CASE member_yn 
		WHEN 'N' THEN NULL 
        ELSE RANK() OVER(PARTITION BY customer_id, member_yn ORDER BY order_date)
    END AS ranking
FROM yn_CTE;

-- Creating the database

CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT *
FROM dbo.members;

SELECT *
FROM dbo.menu;

SELECT *
FROM dbo.sales;

-------------------------
-- CASE STUDY QUESTIONS
-------------------------


--1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(price) AS total_expenditure
FROM dbo.sales s
JOIN dbo.menu m ON
	s.product_id = m.product_id
GROUP BY customer_id

--------------------------------------------------------------------------

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) AS visit_count
FROM dbo.sales
GROUP BY customer_id

--------------------------------------------------------------------------

-- 3. What was the first item from the menu purchased by each customer?
WITH CTE_Orders AS
( SELECT s.customer_id, s.order_date, m.product_name,
	ROW_NUMBER() OVER (PARTITION BY s.customer_id
			ORDER BY s.order_date) AS row_num
FROM dbo.sales s
JOIN dbo.menu m
ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM CTE_Orders
WHERE row_num = 1

--------------------------------------------------------------------------

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP (1) m.product_name, COUNT(m.product_id) AS purchase_count
FROM dbo.sales s
JOIN dbo.menu m ON
	s.product_id = m.product_id
GROUP BY product_name
ORDER BY purchase_count DESC

--------------------------------------------------------------------------

-- 5. Which item was the most popular for each customer?
WITH CTE_popular_item AS
(SELECT s.customer_id, m.product_name, COUNT(s.product_id) AS order_count,
	DENSE_RANK() OVER (PARTITION BY s.customer_id
			ORDER BY COUNT(s.product_id) DESC) AS row_num
FROM dbo.sales s
JOIN dbo.menu m ON
	s.product_id = m.product_id
GROUP BY customer_id, product_name

)
SELECT customer_id, product_name, order_count
FROM CTE_popular_item
WHERE row_num = 1

--------------------------------------------------------------------------
-- 6. Which item was purchased first by the customer after they became a member?
WITH CTE_first_order AS
(SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
	DENSE_RANK() OVER (PARTITION BY s.customer_id
				ORDER BY s.order_date) as d_rank
FROM dbo.sales s
JOIN dbo.members m
ON s.customer_id= m.customer_id
WHERE s.order_date >= m.join_date
)
SELECT customer_id, order_date, m.product_name
FROM CTE_first_order o
JOIN menu m
 ON o.product_id = m.product_id
WHERE d_rank = 1

--------------------------------------------------------------------------
-- 7. Which item was purchased just before the customer became a member?
WITH CTE_first_order AS
(SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
	DENSE_RANK() OVER (PARTITION BY s.customer_id
				ORDER BY s.order_date DESC) as d_rank
FROM dbo.sales s
JOIN dbo.members m
ON s.customer_id= m.customer_id
WHERE s.order_date < m.join_date
)
SELECT o.customer_id, m.product_name, o.join_date, o.order_date
FROM CTE_first_order o
JOIN menu m
ON o.product_id = m.product_id
WHERE d_rank = 1

--------------------------------------------------------------------------
-- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, COUNT(s.product_id) AS product_count, SUM(m2.price) AS total_expenditure
FROM sales s
JOIN members m
ON s.customer_id = m.customer_id
JOIN menu m2
ON s.product_id = m2.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id

--------------------------------------------------------------------------
-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH CTE_points AS
(SELECT *,
	CASE WHEN product_name = 'sushi' THEN price * 20
		ELSE price * 10
		END
		AS points
	FROM menu
)
SELECT s.customer_id, SUM(p.points) as total_points
FROM CTE_points p
JOIN sales s
on p.product_id = s.product_id
GROUP BY s.customer_id

--------------------------------------------------------------------------
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH CTE_dates AS
( SELECT *, DATEADD(DAY, 6, join_date) as valid_date,
			EOMONTH('2021-01-31')  AS last_date
FROM members
)
SELECT d.customer_id,
	SUM (
		CASE WHEN m.product_name = 'sushi' THEN 20 * m.price
			WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 20 * m.price
			ELSE 10 * m.price
			END
	) AS total_points
FROM CTE_dates d
JOIN sales s
	ON d.customer_id = s.customer_id
JOIN menu m
	ON s.product_id = m.product_id
WHERE s.order_date <= d.last_date
GROUP BY d.customer_id

--------------------------------------------------------------------------

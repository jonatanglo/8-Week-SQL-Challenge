USE DATABASE DANNYS_DINER;
USE SCHEMA DANNYS_DINNER;   

-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
    S.CUSTOMER_ID,
    SUM(M.PRICE) AS TOTAL_AMOUNT 
FROM SALES AS S
INNER JOIN MENU AS M
    ON S.PRODUCT_ID = M.PRODUCT_ID
GROUP BY CUSTOMER_ID 
ORDER BY CUSTOMER_ID ASC;

-- 2.How many days has each customer visited the restaurant?
SELECT 
customer_id, 
COUNT( DISTINCT order_date) AS visited_days
FROM sales
GROUP BY customer_id;

-- 3.What was the first item from the menu purchased by each customer?
With ranking_orders AS (
    SELECT
    DISTINCT s.customer_id,
    m.product_name,
    RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS ranking
    FROM sales AS s
    INNER JOIN menu AS m
        ON s.product_id = m.product_id
)

SELECT 
    customer_id,
    product_name
FROM ranking_orders
WHERE ranking = 1
ORDER BY customer_id ASC;

-- 4.What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
    m.product_name ,
    COUNT(s.product_id) AS number_of_orders
FROM menu AS m
INNER JOIN sales AS s
    ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY number_of_orders DESC
LIMIT 1;

-- 5.Which item was the most popular for each customer?
With ranking_orders AS (
SELECT
    s.customer_id,
    m.product_name,
    COUNT(*) AS orders,
    RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS ranking
FROM sales AS s
LEFT JOIN menu AS m
    ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
)

SELECT
    customer_id,
    product_name,
    orders
FROM ranking_orders
WHERE ranking = 1;

-- 6.Which item was purchased first by the customer after they became a member?
WITH ranking_items AS (
    SELECT
    s.customer_id,
    men.product_name,
    RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS ranking
    FROM sales AS s
    LEFT JOIN menu AS men
        ON s.product_id = men.product_id
    LEFT JOIN members AS mem
        ON s.customer_id = mem.customer_id
    WHERE order_date >= join_date
)

SELECT 
    customer_id,
    product_name
FROM ranking_items
WHERE ranking = 1;

-- 8.What is the total items and amount spent for each member before they became a member?

SELECT
    s.customer_id,
    COUNT(*) AS total_items,
    SUM(men.price) AS amount
FROM sales AS s
LEFT JOIN members AS mem
    ON s.customer_id = mem.customer_id
LEFT JOIN menu AS men
    ON s.product_id = men.product_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT
    s.customer_id,
    SUM (CASE
        WHEN m.product_name = 'sushi' THEN m.price*10*2
        ELSE m.price*10
    END ) AS score 
FROM sales AS s
LEFT JOIN menu AS m
    ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

With points_scored AS (
    SELECT
        s.customer_id,
        SUM (CASE
            WHEN s.order_date >= mem.join_date AND MONTH(s.order_date) = 1 THEN men.price * 10 * 2
            ELSE men.price * 10 
            END) AS score
    FROM sales AS s
    LEFT JOIN menu AS men
        ON s.product_id = men.product_id
    LEFT JOIN members AS mem
        ON s.customer_id = mem.customer_id
    WHERE MONTH(order_date) = 1
    GROUP BY s.customer_id
)

SELECT
    *
FROM points_scored
WHERE customer_id IN('A', 'B')
ORDER BY customer_id;

--BONUS
With ranking_order AS (
SELECT 
sales.customer_id,
sales.order_date,
menu.product_name,
menu.price,
CASE
    WHEN order_date >= join_date THEN 'Y'
    ELSE 'N'
END AS member
FROM sales
LEFT JOIN members
    ON sales.customer_id = members.customer_id
LEFT JOIN menu
    ON sales.product_id = menu.product_id
)

SELECT
*,
CASE 
    WHEN member = 'N' THEN null
    ELSE RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
END AS ranking
FROM ranking_order;

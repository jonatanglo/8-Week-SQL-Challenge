I decided to practise my SQL skills so I joined to Danny's Ma #8WeekSQLChallenge where I can deal with real business cases and solve them. I post my journey at my GitHub portfolio. You can find Danny's materials [here](https://8weeksqlchallenge.com/).

# <p align="center"> Case Study #1 - Danny's Diner </p>
<p align="center"><img  height="300" alt="8weeksqlchallenge - taste of success" src="https://github.com/user-attachments/assets/6e85fef3-2a14-4ae8-a3ec-4de1dc8c72db" /></p>

---
## Table of Contest:

- [Business Case](#business-case)
- [Relationship diagram](#relationship-diagram)
- [Dataset](#dataset)
- [Case Study Questions](#case-study-questions)

## Business Case:
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

## Relationship diagram

<img width="557" height="280" alt="image" src="https://github.com/user-attachments/assets/07907706-e0c4-4c42-bcbe-0ed3dec3dd81" />

## Dataset 

<details><summary>
    Existing tables.
  </summary>

### Table 1: sales
customer_id | order_date |	product_id
-- | -- | --
A |	2021-01-01 | 1
A	| 2021-01-01 | 2
A	| 2021-01-07 | 2
A	| 2021-01-10 | 3
A	| 2021-01-11 | 3
A	| 2021-01-11 | 3
B	| 2021-01-01 | 2
B	| 2021-01-02 | 2
B	| 2021-01-04 | 1
B	| 2021-01-11 | 1
B	| 2021-01-16 | 3
B	| 2021-02-01 | 3
C	| 2021-01-01 | 3
C	| 2021-01-01 | 3
C	| 2021-01-07 | 3

## Table 2: menu
product_id | product_name |	price
-- | -- | --
1	| sushi |	10
2	| curry	| 15
3	| ramen |	12

## Table 3: members
customer_id	| join_date
-- | --
A	| 2021-01-07
B	| 2021-01-09

</details>

## Case Study Questions

### 1. What is the total amount each customer spent at the restaurant?

```` sql
SELECT 
  s.customer_id,
  SUM(m.price) AS total_amount 
FROM sales AS s
INNER JOIN menu AS m
  ON s.product_id = m.product_id
GROUP BY customer_id 
ORDER BY customer_id ASC
````

#### Steps: 
* Use **JOIN** to merge `sales` and `menu` tables, where `customer_id` comes from `sales` table, and `price` comes from `menu` table.
* Use **SUM** to calculate `total_amount`.
* Aggregate `customer_id` results using **GROUP BY**.
* Sort  `customer_id` alphabetically with **ORDER BY ASC**.
  
#### Result:
customer_id | total_amount
-- | --
A	| 76
B	| 74
C	| 36

* Customer **A** spent 76$ at the restaurant.
* Customer **B** spent 74$ at the restaurant.
* Customer **C** spent 36$ at the restaurant.

### 2. How many days has each customer visited the restaurant?

```` sql
SELECT 
customer_id, 
COUNT(DISTINCT order_date) AS visited_days
FROM sales
GROUP BY customer_id
````
#### Steps:
* Use **COUNT(DISTINCT `order_date`)** to count unique days in which customers placed orders.
* Aggregate `customer_id` results using **GROUP BY**.

#### Result:
customer_id | visited_days
-- | --
A	| 4
B	| 6
C	| 2

* Customer **A** visited 4 times the restaurant.
* Customer **B** visited 6 times the restaurant.
* Customer **C** visited 2 times the restaurant.

### 3. What was the first item from the menu purchased by each customer?

```` sql
With ranking_orders AS (
    SELECT
        DISTINCT s.customer_id,
        m.product_name,
        RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS ranking
    FROM sales AS s
    LEFT JOIN menu AS m
        ON s.product_id = m.product_id
)

SELECT 
    customer_id,
    product_name
FROM ranking_orders
WHERE ranking = 1
ORDER BY customer_id ASC
````

#### Steps:
* Use **With AS** to create temporary table.
* Use **DISTINCT** to select only unique rows.
* Rank order dates with **RANK()** and aggregate by `customer_id` using **OVER(PARTITION BY `customer_id`)**.
* Merge tables `sales` and `menu` with **LEFT JOIN**.
* Use reference to table `ranking_orders` with **FROM `ranking_orders`**.
* Filter only first orders with **WHERE `ranking` = 1**.

#### Result:
customer_id | product_name
-- | --
A | sushi
A | curry
B | curry
C | ramen

* Customer **A** as first purchased sushi and curry.
* Customer **B** as first purchased curry.
* Customer **C** as first purchased ramen.

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

```` sql
SELECT 
    m.product_name ,
    COUNT(s.product_id) AS number_of_orders
FROM menu AS m
INNER JOIN sales AS s
    ON m.product_id = s.product_id
GROUP BY m.product_name
ORDER BY number_of_orders DESC
LIMIT 1
````
#### Steps:
* Use **COUNT** to calculate numer of orders.
* Use **INNER JOIN** to merge tables `sales` and `menu` on `product_id` column.
* Aggregate `product_name` results using **GROUP BY**.
* Sort  `number_of_orders` decreasing with **ORDER BY DESC**.
* Return only one result with **LIMIT 1**.

#### Result:
product_name | number_of_orders
-- | --
ramen | 8

* The most purchased item on the menu is **ramen** and it was purchased **8 times**.


### 5. Which item was the most popular for each customer?

```` sql
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
WHERE ranking = 1
````

#### Steps:
* Use **With AS** to create temporary table with ranking purchased items for each customer.
* Filter the most purchased items with **WHERE `ranking` = 1**.

#### Result:
customer_id | product_name | orders
-- | -- | --
A | ramen | 3
B | sushi | 2
B | ramen | 2
B | curry | 2
C | ramen | 3

* For customer **A** the most popular item was **ramen**. 
* For customer **B** the most popular items were **sushi**, **ramen** and **curry**. 
* For customer **C** the most popular item was **ramen**. 


### 6. Which item was purchased first by the customer after they became a member?

```` sql
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
WHERE ranking = 1
````

#### Steps:
* Use **With AS** to create temporary table with ranking items for each customer.
* Fiter `order_dates` greater or equal than `join_date` (join date of membership) for orders placed beeing a member.
* Filter first order with **WHERE `ranking` = 1**.

#### Result:
customer_id | product_name
-- | --
A | curry
B | sushi

* Customer **A** purchased **curry** firt after he became a member.
* Customer **B** purchased **sushi** firt after he became a member.

### 7. Which item was purchased just before the customer became a member?
### 8. What is the total items and amount spent for each member before they became a member?
### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


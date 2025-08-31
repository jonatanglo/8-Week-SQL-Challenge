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
* Fiter `order_date` greater or equal than `join_date` (join date of membership) for orders placed beeing a member.
* Filter first order with **WHERE `ranking` = 1**.

#### Result:
customer_id | product_name
-- | --
A | curry
B | sushi

* Customer **A** purchased **curry** firt after he became a member.
* Customer **B** purchased **sushi** firt after he became a member.

### 7. Which item was purchased just before the customer became a member?

```` sql
WITH ranking_items AS (
    SELECT
        s.customer_id,
        s.product_id,
        RANK() OVER(PARTITION BY s.customer_id ORDER BY order_date DESC) AS ranking
    FROM sales AS s
    LEFT JOIN members AS mem
        ON s.customer_id = mem.customer_id
    WHERE s.order_date < mem.join_date    
)

SELECT
    customer_id,
    men.product_name
FROM ranking_items AS ri
LEFT JOIN menu AS men
    ON ri.product_id = men.product_id
WHERE ranking = 1
````

#### Steps:
* Use **With AS** to create temporary table with ranking items for each customer.
* Fiter `order_date` less than `join_date` (join date of membership) for orders placed before beeing a member.
* Sort `order_date` descending for lastest order befor beeing a member.
* Filter first order with **WHERE `ranking` = 1**.

#### Result:
customer_id | product_name
-- | --
A | curry
A | sushi
B | sushi

* Customer **A** purchased **curry** and **sushi** just before becoming a member.
* Customer **B** purchased **sushi** just before becoming a member.

### 8. What is the total items and amount spent for each member before they became a member?

```` sql
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
GROUP BY s.customer_id
ORDER BY s.customer_id ASC
````

#### Steps:
* **COUNT** and **SUM** rows
* Filter orders where `order_date` is less than `join_date`
* Aggregate `customer_id` using **GROUP BY**

#### Result:
customer_id | total_items | amount
-- | -- | --
A | 2 | 25
B | 3 | 40

* Customer **A** before becoming a member ordered **2** items and spent **25**.
* Customer **B** before becoming a member ordered **3** items and spent **40**.


### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

```` sql
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
ORDER BY s.customer_id
````

#### Steps:
* With **CASE** set conditional to 'sushi' for `price` * 10 * 2 and for all another `price` * 10.
* Use **GROUP BY** to agregate table with `customer_id`.

#### Result:
cusotmer_id | score
-- | --
A | 860
B | 940
C | 360

* Customer **A** score **860 points**.
* Cusotmer **B** score **940 points**.
* Customer **B** score **360 points**.

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

```` sql
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
ORDER BY customer_id
````

#### Steps:
* In temporary table `points_scored` **SELECT** `customer_id` and **SUM** points **WHEN** `order_date` is after `join_date` and `order_date` is January **THEN** double points.
* Use **LEFT JOIN** to merge tables `sales` and `menu` on `product_id` column and `sales` and `members on `customer_id`.
* With **WHERE MONTH(order_date) = 1** filter orders placed only in January
* Filter only Customer A and Customer B

#### Result:
customer_id | score
-- | --
A | 1020
B | 440

* Customer **A** scored **1020** points.
* Customer **B** scored **440** points.

### Bonus Questions. Danny requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

```` sql
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
FROM ranking_order
````

#### Result:
customer_id | order_date | product_name | price | member | ranking
-- | -- | -- | -- | -- | --
A | 2021-01-01 | sushi | 10 | N | null	
A | 2021-01-01 | curry | 15 | N | null
A | 2021-01-07 | curry | 15 | Y | 1
A | 2021-01-10 | ramen | 12 | Y | 2
A | 2021-01-11 | ramen | 12	| Y | 3
A | 2021-01-11 | ramen | 12 | Y | 3
B | 2021-01-01 | curry | 15 | N | null
B | 2021-01-02 | curry | 15 | N | null	
B | 2021-01-04 | sushi | 10 | N | null
B | 2021-01-11 | sushi | 10 | Y | 1
B | 2021-01-16 | ramen | 12 | Y | 2
B | 2021-02-01 | ramen | 12 | Y | 3
C | 2021-01-01 | ramen | 12 | N | null
C | 2021-01-01 | ramen | 12 | N | null
C | 2021-01-07 | ramen | 12 | N | null




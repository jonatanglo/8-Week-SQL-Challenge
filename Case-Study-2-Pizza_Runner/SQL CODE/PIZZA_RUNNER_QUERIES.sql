USE DATABASE PIZZA_RUNNER;
USE SCHEMA PIZZA_RUNNER;
SELECT
    *
FROM CUSTOMER_ORDERS;

SELECT * FROM runner_orders;

--1.How many pizzas were ordered?
SELECT 
COUNT(*) AS ordered_pizzas
FROM CUSTOMER_ORDERS;

--2.How many unique customer orders were made?
SELECT  COUNT(DISTINCT order_id) FROM CUSTOMER_ORDERS;

--3.How many successful orders were delivered by each runner?
SELECT 
    runner_id,
    COUNT(*) AS orders
FROM runner_orders
WHERE pickup_time IS NOT null
GROUP BY runner_id
ORDER BY runner_id;

--4.How many of each type of pizza was delivered?
SELECT * FROM PIZZA_NAMES;

SELECT * FROM CUSTOMER_ORDERS;

SELECT * FROM RUNNER_ORDERS;

SELECT 
    pizza_name,
    COUNT (*) AS amount
FROM CUSTOMER_ORDERS
LEFT JOIN PIZZA_NAMES
    ON CUSTOMER_ORDERS.pizza_id = PIZZA_NAMES.pizza_id
LEFT JOIN RUNNER_ORDERS
    ON CUSTOMER_ORDERS.order_id = RUNNER_ORDERS.order_id
WHERE pickup_time IS NOT NULL
GROUP BY pizza_name;

--5.How many Vegetarian and Meatlovers were ordered by each customer?

SELECT * FROM CUSTOMER_ORDERS;

SELECT 
customer_id,
pizza_id,
count(pizza_id)
from customer_orders
group by customer_id, pizza_id
order by customer_id, pizza_id; 

--6.What was the maximum number of pizzas delivered in a single order?
SELECT *FROM CUSTOMER_ORDERS;

SELECT
    order_id,
    COUNT(*) AS number_of_pizzas
FROM CUSTOMER_ORDERS
GROUP BY order_id
ORDER BY number_of_pizzas DESC
LIMIT 1;

--7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT * FROM CUSTOMER_ORDERS;

WITH AT_LEAST_1_CHANGE AS (
SELECT
*
FROM CUSTOMER_ORDERS
WHERE EXCLUSIONS IS NOT NULL OR EXTRAS IS NOT NULL
)


SELECT 
CUSTOMER_ORDERS.customer_id,
COUNT(AT_LEAST_1_CHANGE.*) AS at_least_1_change,

FROM CUSTOMER_ORDERS
LEFT JOIN AT_LEAST_1_CHANGE
    ON CUSTOMER_ORDERS.customer_id = AT_LEAST_1_CHANGE.customer_id

group by CUSTOMER_ORDERS.customer_id;

--8.How many pizzas were delivered that had both exclusions and extras?
SELECT * FROM CUSTOMER_ORDERS;

SELECT 
    COUNT(*)
FROM CUSTOMER_ORDERS
LEFT JOIN RUNNER_ORDERS
    ON CUSTOMER_ORDERS.ORDER_ID = RUNNER_ORDERS.ORDER_ID
WHERE EXCLUSIONS IS NOT NULL AND EXTRAS IS NOT NULL AND CANCELLATION IS NULL;


    
--9.What was the total volume of pizzas ordered for each hour of the day?
SELECT 
    DISTINCT HOUR(ORDER_TIME) AS hour, 
    COUNT(*) AS numer_of_pizzas
FROM CUSTOMER_ORDERS
GROUP BY hour
ORDER BY hour;

--10.What was the volume of orders for each day of the week?
SELECT * FROM CUSTOMER_ORDERS;

SELECT
--    WEEKDAY(CAST (ORDER_TIME AS DATE)) AS weekday,
    DAYOFWEEK(ORDER_TIME) AS weekday,
    COUNT(*) AS orders
FROM CUSTOMER_ORDERS
GROUP BY weekday
ORDER BY weekday;

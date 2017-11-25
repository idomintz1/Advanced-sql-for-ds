--Advanced SQL for dataScience


#How many orders did we have? 

SELECT count(*) FROM orders;

SELECT count (distinct date(strftime('%Y-%m-%d',orderdate), 'weekday 1')) AS weeks
FROM orders;


# How many orders for each employee?
SELECT employeeid, 
       count (*) AS orders
FROM orders
GROUP BY 1
ORDER BY 2 DESC ;

# What is the earliest and latest order date for each employee? 
# What is the ratio of orders / weeks for each employee?

WITH orders_for_employee AS (
  SELECT employeeid,
         min(orderdate) AS min_order,
         max(orderdate) max_order,
         count (*) AS orders, 
         count (distinct date(strftime('%Y-%m-%d',orderdate), 'weekday 1')) AS weeks
  FROM [orders]
  GROUP BY 1
  ORDER BY 4 DESC  )

SELECT o.*,
      cast(orders AS real)/weeks AS orders_per_week,
      LastName,FirstName
FROM orders_for_employee o
JOIN employees e using (employeeID)

  

# Who was the customer in each employee’s last order?

WITH orders_for_employee AS (
  SELECT employeeid, max(orderID) max_order
  FROM orders
  GROUP BY 1),


last_order AS(
 SELECT e.employeeid, e.firstName, e.LastName,
 		    oe.max_order, 
        o.orderDate, o.customerid
 FROM employees e
  LEFT JOIN orders_for_employee oe using (employeeid)
  LEFT JOIN orders o 
   ON e.employeeid= o.employeeid 
   AND oe.max_order = o.orderID )

SELECT * FROM last_order;


# For each week , the number of orders we had until that point

WITH orders_2 AS (
  SELECT  *,
          date(strftime('%Y-%m-%d',orderdate), 'weekday 1') AS week
    FROM [orders]
)

SELECT w.week,
       count(o.orderid) AS orders_to_week
  FROM orders_2 w
  JOIN orders_2 o
    ON w.week >= o.week
GROUP BY  w.week
ORDER BY 1

#For each week, what is the rolling average orders of the last month?
WITH orders_2 AS (
  SELECT  *,
          date(strftime('%Y-%m-%d',orderdate), 'weekday 1') AS week
    FROM [orders]
)

SELECT w.week,
       avg(o.orderid) AS orders_to_week
  FROM orders_2 w
  JOIN orders_2 o
    ON w.week >= o.week
    AND w.week <= date(o.week, '+1 month')
GROUP BY  w.week
ORDER BY 1



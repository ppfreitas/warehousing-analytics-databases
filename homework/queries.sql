--- Get the top 3 product types that have proven most profitable
SELECT product_code, SUM(quantity_ordered * profit) AS total_profit
FROM facts
GROUP BY product_code
ORDER BY total_profit DESC
LIMIT 3;

--- Get the top 3 products by most items sold
SELECT product_code, SUM(quantity_ordered) AS total_sold
FROM facts
GROUP BY product_code
ORDER BY total_sold DESC
LIMIT 3;

--- Get the top 3 products by items sold per country of customer for: USA, Spain, Belgium
(SELECT c.country, f.product_code, SUM(f.quantity_ordered) AS total_ordered
FROM facts AS f INNER JOIN dim_customers AS c 
ON f.customer_number = c.customer_number
WHERE country = 'USA' GROUP BY c.country, f.product_code
ORDER BY total_ordered DESC LIMIT 3)
UNION ALL
(SELECT c.country, f.product_code, SUM(f.quantity_ordered) AS total_ordered
FROM facts AS f INNER JOIN dim_customers AS c 
ON f.customer_number = c.customer_number
WHERE country = 'Spain' GROUP BY c.country, f.product_code
ORDER BY total_ordered DESC LIMIT 3)
UNION ALL
(SELECT c.country, f.product_code, SUM(f.quantity_ordered) AS total_ordered
FROM facts AS f INNER JOIN dim_customers AS c 
ON f.customer_number = c.customer_number
WHERE country = 'Belgium' GROUP BY c.country, f.product_code
ORDER BY total_ordered DESC LIMIT 3);

--- Get the most profitable day of the week
SELECT day_week, SUM(quantity_ordered * profit) AS total_profit
FROM facts AS f
INNER JOIN dim_dates AS d
ON f.order_date = d.date_day
GROUP BY day_week 
ORDER BY total_profit DESC
LIMIT 1;

--- Get the top 3 city-quarters with the highest average profit margin in their sales
SELECT e.city, d.quarter, d.year, SUM(f.quantity_ordered * f.profit)/SUM(f.quantity_ordered * f.price_each) AS avg_margin
FROM facts AS f
INNER JOIN dim_employees AS e
	ON f.sales_rep_number = e.employee_number
INNER JOIN dim_dates AS d
	ON f.order_date = d.date_day
GROUP BY e.city, d.quarter, d.year
ORDER BY avg_margin DESC
LIMIT 3;

-- List the employees who have sold more goods (in $ amount) than the average employee.
SELECT e.first_name, f.sales_rep_number, SUM(f.quantity_ordered*f.price_each) AS total_sold
FROM facts AS f
INNER JOIN dim_employees AS e 
ON f.sales_rep_number = e.employee_number
GROUP BY e.first_name, f.sales_rep_number
HAVING SUM(f.quantity_ordered*f.price_each) > (SELECT SUM(f.quantity_ordered*f.price_each)/COUNT(DISTINCT e.employee_number)
					FROM facts AS f INNER JOIN dim_employees AS e
					ON f.sales_rep_number = e.employee_number)
ORDER BY total_sold DESC;

-- List all the orders where the sales amount in the order is in the top 10% of all order sales amounts (BONUS: Add the employee number)
SELECT f.order_number, e.employee_number, SUM(f.quantity_ordered*f.price_each) AS sales_amount
FROM facts AS f INNER JOIN dim_employees AS e 
ON f.sales_rep_number = e.employee_number
GROUP BY f.order_number, e.employee_number
ORDER BY sales_amount DESC
LIMIT (SELECT COUNT(DISTINCT order_number) FROM facts)*0.1;
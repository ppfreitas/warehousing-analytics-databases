-- author: pedro freitas NIS: 173976

DROP DATABASE hw2;
CREATE DATABASE hw2;
\c hw2


CREATE TABLE dim_dates (
	date_day date PRIMARY KEY,
	day_week text,
	month integer,
	quarter integer,
	year integer
	);

CREATE TABLE dim_products (
	product_line text,
	product_code text PRIMARY KEY,
	product_name text,
	product_scale text,
	product_vendor text,
	product_description text,
	quantity_in_stock integer,
	buy_price NUMERIC,
	_m_s_r_p text,
	html_description text
	);

CREATE TABLE dim_employees (
	employee_number integer PRIMARY KEY,
	first_name text,
	last_name text,
	reports_to text,
	job_title text,
	office_code integer,
	city text,
	state text,
	country text,
	office_location text
	);

CREATE TABLE dim_customers (
	customer_number integer PRIMARY KEY,
	customer_name text,
	contact_last_name text,
	contact_first_name text,
	city text,
	state text,
	country text,
	sales_rep_employee_number integer REFERENCES dim_employees(employee_number),
	credit_limit integer,
	customer_location text
	);

CREATE TABLE facts (
	order_number integer,
	order_line integer,
	product_code text REFERENCES dim_products (product_code),
	quantity_ordered integer,
	price_each NUMERIC,
	customer_number integer REFERENCES dim_customers (customer_number),
	order_date date REFERENCES dim_dates (date_day),
	required_date date,
	shipped_date text,
	status text,
	comments text,
	buy_price NUMERIC,
	sales_rep_number integer REFERENCES dim_employees (employee_number),
	profit NUMERIC,
	PRIMARY KEY (order_number, order_line)
	);


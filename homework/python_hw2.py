#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 14 18:41:44 2019

@author: pedro
"""

#Import packages
import pandas as pd
import psycopg2
import os

#Coonect to database hw1
conn = psycopg2.connect("dbname=hw1 user=postgres host=localhost")
cur = conn.cursor()

#Read tables from operational database
cur.execute("SELECT * FROM customers;")
cust_data = pd.DataFrame(cur.fetchall(), columns = [desc[0] for desc in cur.description])

cur.execute("SELECT * FROM offices;")
office_data = pd.DataFrame(cur.fetchall(), columns = [desc[0] for desc in cur.description])

cur.execute("SELECT * FROM employees;")
emp_data = pd.DataFrame(cur.fetchall(), columns = [desc[0] for desc in cur.description])

cur.execute("SELECT * FROM products;")
prod_data = pd.DataFrame(cur.fetchall(), columns = [desc[0] for desc in cur.description])

cur.execute("SELECT * FROM order_info;")
oinfo_data = pd.DataFrame(cur.fetchall(), columns = [desc[0] for desc in cur.description])

cur.execute("SELECT * FROM order_products;")
oprod_data = pd.DataFrame(cur.fetchall(), columns = [desc[0] for desc in cur.description])

#Create facts table
facts1 = pd.merge(oprod_data, oinfo_data, on ='order_number')
facts2 = pd.merge(facts1, prod_data[['product_code','buy_price']], on = 'product_code')
facts = pd.merge(facts2, cust_data[['customer_number','sales_rep_employee_number']], on = 'customer_number')
facts['profit'] = facts['price_each'] - facts['buy_price']

#Create dimension tables
def create_date_table(start='2000-01-01', end='2020-12-31'):
    df = pd.DataFrame({"Date": pd.date_range(start, end)})
    df["Day"] = df.Date.dt.weekday_name
    df["Month"] = df.Date.dt.month
    df["Quarter"] = df.Date.dt.quarter
    df["Year"] = df.Date.dt.year
    return df

dim_dates = create_date_table()
dim_employees = pd.merge(emp_data, office_data, on = 'office_code')
dim_customers = cust_data.copy()
dim_products = prod_data.copy()

cur.close()
conn.close()

#Modify dataframes to list of tuples, so psycopg2 can read them
dim_products_tuple = list(map(tuple, dim_products.itertuples(index=False)))
dim_dates_tuple = list(map(tuple, dim_dates.itertuples(index=False)))
dim_employees_tuple = list(map(tuple, dim_employees.itertuples(index=False)))
dim_customers_tuple = list(map(tuple, dim_customers.itertuples(index=False)))
facts_tuple = list(map(tuple, facts.itertuples(index=False)))

#Connect to analytics database
conn = psycopg2.connect("dbname=hw2 user=postgres host=localhost")
cur = conn.cursor()

#Load tables into analytics database
for i in dim_products_tuple:   
    cur.execute("INSERT INTO dim_products VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", i)

for i in dim_dates_tuple:   
    cur.execute("INSERT INTO dim_dates VALUES (%s, %s, %s, %s, %s)", i)

for i in dim_employees_tuple:   
    cur.execute("INSERT INTO dim_employees VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", i)

for i in dim_customers_tuple:   
    cur.execute("INSERT INTO dim_customers VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", i)

for i in facts_tuple:   
    cur.execute("INSERT INTO facts VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)", i)

conn.commit()
cur.close()
conn.close()


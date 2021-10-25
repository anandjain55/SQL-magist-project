/*
SQL JOIN
------------------------------------------------------------------------------------------------
HOW TO GET THE SCHEMA OF A DATABASE: 
* Windows/Linux: Ctrl + r
* MacOS: Cmd + r
*/
USE publications; 

-- AS 
# Change the column name qty to Quantity into the sales table
# https://www.w3schools.com/sql/sql_alias.asp
SELECT *, qty as 'Quantity'
FROM sales;
# Assign a new name into the table sales, and call the column order number using the table alias
SELECT s.ord_num
FROM sales AS s;

-- JOINS
# https://www.w3schools.com/sql/sql_join.asp
-- LEFT JOIN
SELECT * 
FROM stores s 
LEFT JOIN discounts d ON d.stor_id = s.stor_id;
-- RIGHT JOIN
SELECT * 
FROM stores s 
RIGHT JOIN discounts d ON d.stor_id = s.stor_id;
-- INNER JOIN
SELECT * 
FROM stores s 
INNER JOIN discounts d ON d.stor_id = s.stor_id;

-- CHALLENGES: 
# In which cities has "Is Anger the Enemy?" been sold?
# HINT: you can add WHERE function after the joins
SELECT DISTINCT( st.city )
FROM titles AS t
LEFT JOIN sales AS s ON t.title_id = s.title_id
LEFT JOIN stores AS st ON s.stor_id = st.stor_id
WHERE t.title = "Is Anger the Enemy?";
# Select all the books (and show their title) where the employee
# Howard Snyder had work.
SELECT t.title, e.fname, e.lname
FROM employee e 
RIGHT JOIN titles t ON e.pub_id = t.pub_id
WHERE e.fname = "Howard" AND e.lname = "Snyder";
# Select all the authors that have work (directly or indirectly)
# with the employee Howard Snyder
SELECT a.au_lname, a.au_fname, e.fname, e.lname
FROM authors a
INNER JOIN titleauthor ta ON a.au_id = ta.au_id
INNER JOIN titles t ON ta.title_id = t.title_id
INNER JOIN publishers p ON t.pub_id = p.pub_id
INNER JOIN employee e ON p.pub_id = e.pub_id
WHERE e.fname = "Howard" AND e.lname = "Snyder";
# Select the book title with higher number of sales (qty)
SELECT s.title_id, t.title, SUM(s.qty) AS qty
FROM sales AS s
RIGHT JOIN titles AS t ON s.title_id = t.title_id
GROUP BY s.title_id, t.title
ORDER BY SUM(s.qty) DESC
LIMIT 1;
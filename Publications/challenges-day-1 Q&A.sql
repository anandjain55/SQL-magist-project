/*
INTRODUCTION TO SQL
------------------------------------------------------------------------------------------------
1. Load the publications.sql file as a database into you local server
2. Understand the schemas
HOW TO GET THE SCHEMA OF A DATABASE: 
* Windows/Linux: Ctrl + r
* MacOS: Cmd + r
*/
# CHALLENGES
# We define de database we will work with
USE publications; 

-- Describe the database
SELECT * FROM information_schema.columns WHERE table_schema = 'publications';

-- DESCRIBE
# Show columns, datatypes, primary and foreign keys and other information from the table you want to analyse
DESCRIBE sales;

-- SELECT
# Select everything from the table authors (publications database)
# https://www.w3schools.com/sql/sql_select.asp
SELECT * 
FROM authors; 

# Select the authors first and last name
SELECT au_fname, au_lname
FROM authors;

# Select the first name and the last name and merge them in one column and call it full_name by using CONCAT() function 
-- remember that you have to separate the two columns by adding space 
SELECT CONCAT(au_fname, ' ', au_lname) AS full_name
FROM authors;

# Select the distinct first names in authors
# https://www.w3schools.com/sql/sql_distinct.asp
SELECT DISTINCT au_fname
FROM authors;

-- WHERE
# Select first and last name from authors whose last name is "Ringer"
# https://www.w3schools.com/sql/sql_where.asp
SELECT au_fname, au_lname
FROM authors
WHERE au_lname = "Ringer";


# Select first and last name from authors whose last name is "Ringer" and fist name is "Anne"
-- https://www.w3schools.com/sql/sql_and_or.asp
SELECT au_fname, au_lname 
FROM authors
WHERE au_lname = "Ringer" AND au_fname = "Anne";

# Select first, last name and city from authors whose city is "Oakland" or "Berkeley" and first name is "Dean"
# HINT: parenthesis "()" can help
SELECT au_fname, au_lname, city 
FROM authors
WHERE (city = "Oakland" OR city = "Berkeley") AND au_fname = "Dean";


# Select first, last name and city from authors whose city is "Oakland" or "Berkeley" and last name is NOT "Straight"
SELECT * 
FROM authors
WHERE (city = "Oakland" OR city = "Berkeley") AND NOT au_lname = "Straight";

-- ORDER BY : sort the result either ascending or descending with respect to a given column. 
# Select the title and ytd_sales from the table titles and order them in relation to year to day sales in descending order
# https://www.w3schools.com/sql/sql_orderby.asp
SELECT title, ytd_sales
FROM titles
ORDER BY ytd_sales DESC;

-- LIMIT
# Select the top 5 titles with more ytd_sales from the table titles
# https://www.w3schools.com/sql/sql_top.asp
SELECT title, ytd_sales
FROM titles 
ORDER BY ytd_sales DESC
LIMIT 5;

-- MIN and MAX
# Select the minimum and maximum quantity in table sales. 
# You can assign a name to each created columns with the SQL function AS.
# https://www.w3schools.com/sql/sql_min_max.asp
SELECT MIN(qty) AS min_qty, MAX(qty) AS max_qty
FROM sales;

-- COUNT, AVG and SUM
-- COUNT(): counts the number of rows in a given column/table
-- AVG(): finds the average of a given column
-- SUM(): finds the sum of the row's values in a given column
# Select the count, average and sum of quantity in the table sales
# https://www.w3schools.com/sql/sql_count_avg_sum.asp
SELECT COUNT(qty) as count, AVG(qty) AS avg_qty, SUM(qty) AS sum_qty
FROM sales;

-- LIKE
# Select title from the table title that contains the word "cooking"
# https://www.w3schools.com/sql/sql_like.asp
SELECT * 
FROM titles
WHERE title LIKE "%cooking%";

# Select any title that has a word with four characters before "ing"
SELECT * 
FROM titles
WHERE title LIKE "%___ing%";

-- IN
# Select all the authors from the author table that does not come from the cities Salt Lake City, Ann Arbor and Oakland.
# https://www.w3schools.com/sql/sql_in.asp
SELECT * 
FROM authors
WHERE city NOT IN ('Salt Lake City', 'Ann Arbor','Oakland'); 

/* The differences between IN, LIKE, and =
IN : takes many values to look for and does not work with the wildcards.
= : takes only one value to look for and does not work with wildcards.
LIKE: takes only one value to look for and works with wildcards.
*/

SELECT * 
FROM authors
WHERE city IN ('Palo Alto', 'San Jose');

SELECT * 
FROM authors
WHERE city LIKE ('Palo Alto');

SELECT * 
FROM authors
WHERE city = ('Palo Alto');

-- BETWEEN 
# Select all the order numbers with a quantity sold between 25 and 45 from the table sales
# https://www.w3schools.com/sql/sql_between.asp
SELECT * 
FROM sales
WHERE qty BETWEEN 25 AND 45;
# Select all the orders between 1993-03-11 and 1994-09-13
SELECT * 
FROM sales
WHERE ord_date BETWEEN '1993-03-11' AND '1994-09-13';

-- MULTIPLE FUNCTIONS
# Select the top 5 orders with more quantity sold between 1993-03-11 and 1994-09-13 from the table sales
SELECT * 
FROM sales
WHERE ord_date BETWEEN '1993-03-11' AND '1994-09-13'
ORDER BY qty
LIMIT 5;

# Retrun the count of all the authors that have a "i" on the first name, in the state of UT, MD and KS
SELECT COUNT(*)
FROM authors
WHERE au_fname LIKE "%i%" AND state IN ("CA","MD","KS");

# Select the total sum of ytd_sales of the top 5 titles from titles with a lower royalty, between a price of 15 to 25
SELECT SUM(ytd_sales)
FROM titles
WHERE price BETWEEN 15 AND 25
ORDER BY royalty ASC
LIMIT 5;


-- GROUP BY
# Select the total count of authors by each state 
# https://www.w3schools.com/sql/sql_groupby.asp
SELECT state, COUNT(*)
FROM authors
GROUP BY state;

# Select the total count of authors by each state and order them descinding
SELECT state, COUNT(*)
FROM authors
GROUP BY state
ORDER BY COUNT(*)DESC;

# Select the maximum price for each publisher id in the table titles.
SELECT pub_id, MAX(price)
FROM titles
GROUP BY pub_id;

# Find out top 3 stores with more sales
SELECT stor_id, SUM(qty) 
FROM sales
GROUP BY stor_id
ORDER BY SUM(qty) DESC
LIMIT 3;

-- HAVING 
# Select for each publisher the total number of titles for each book type with an average price higher than 12
# https://www.w3schools.com/sql/sql_having.asp
SELECT pub_id, type, COUNT(*) 
FROM titles
GROUP BY pub_id, type
HAVING AVG(price) > 12;

# Select for each publisher the total number of titles for each book type with an average price higher than 12 and order them by the average price
SELECT pub_id, type, COUNT(*), AVG(price) 
FROM titles
GROUP BY pub_id, type
HAVING AVG(price) > 12
ORDER BY AVG(price);

# Select all the states and cities that contains more than 1 contract
SELECT state, city, SUM(contract)
FROM authors
GROUP BY state, city
HAVING SUM(contract) > 1
ORDER BY city; # ORDER BY city will order the results alphabetical

/* The main difference between WHERE and HAVING is that:
 the WHERE clause is used to specify a condition for filtering records before any groupings are made,
 while the HAVING clause is used to specify a condition for filtering values from a group this is why HAVING always comes after the GROUP BY and before ORDER BY */

-- CASE
# Create a new column called "sales_category" with case conditions to categorise qty in sales table: 
#  * qty >= 50 high sales
#  * 20 <= qty < 50 medium sales
#  * qty < 20 low sales
# https://www.w3schools.com/sql/sql_case.asp

SELECT *, 
CASE 
	WHEN qty >= 50 THEN 'high sales'
    WHEN qty < 20 THEN 'low sales'
    ELSE 'medium sales'
END AS sales_category
FROM sales;

# Find out the total amount of books sold (qty) by each sale category created with CASE
# HINT: you can use GROUP BY with the new variable you created
SELECT 
	CASE 
		WHEN qty >= 50 THEN 'high sales'
		WHEN qty < 20 THEN 'low sales'
		ELSE 'medium sales'
	END AS sales_category, 
    SUM(qty)
FROM sales
GROUP BY sales_category;

## challenge
/*  Find out the total amount of books sold (qty) by each sale category created with CASE, having the SUM(qty) greater than 100 and order them DESC */
SELECT 
	CASE 
		WHEN qty >= 50 THEN 'high sales'
		WHEN qty < 20 THEN 'low sales'
		ELSE 'medium sales'
	END AS sales_category, 
    SUM(qty)
FROM sales
GROUP BY sales_category
HAVING SUM(qty) > 100
ORDER BY SUM(qty)DESC;

-- LAST CHALLENGES
# In California, how many authors are there in cities containing an "o" in the name?
# Show only results for cities with more than 1 author.
# Sort the cities ascendingly by author count.
SELECT city, COUNT(au_fname)
FROM authors
WHERE state = "CA" AND city LIKE "%o%"
GROUP BY city
HAVING COUNT(au_fname) > 1
ORDER BY COUNT(au_fname);

# Find out the average price for each publisher and price category for the following book types: 
# * business, traditional cook and psychology
# * price categories: <= 5 super low, <= 10 low, <= 15 medium, > 15 high
SELECT pub_id,
	CASE
		WHEN price <= 5 THEN 'super low'
		WHEN price <= 10 THEN 'low'
        WHEN price <= 15 THEN 'medium'
        ELSE 'high'
	END AS price_category,
    AVG(price) AS 'avg_price'
FROM titles
WHERE type IN ('business','trad_cook','psychology')
GROUP BY pub_id, price_category;

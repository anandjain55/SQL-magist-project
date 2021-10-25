/*Business Questions

in relation to the products:

How many different products are being sold?
What are the most popular categories?
How popular are tech products compared to other categories?
What’s the average price of the products being sold?
Are expensive tech products popular?
What’s the average monthly revenue of Magist’s sellers?

-----
In relation to the sellers:

How many sellers are there?
What’s the average revenue of the sellers?
What’s the average revenue of sellers that sell tech products?
In relation to the delivery time:

What’s the average time between the order being placed and the product being delivered?
How many orders are delivered on time vs orders delivered with a delay?
Is there any pattern for delayed orders, e.g. big products being delayed more often?
*/

use magist;

-- How many different products are being sold?
SELECT COUNT(DISTINCT(product_id)) FROM products; -- 32951
# Looking to other columns except product id
SELECT COUNT(*) 
FROM (
	SELECT 
		product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm, 
		COUNT(*) AS num_duplicates
	FROM products
	GROUP BY 
		product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm
	HAVING COUNT(product_id) = 1
	ORDER BY COUNT(*) DESC
) prod;

-- What are the most popular categories? -- bed_bath_table, health_beauty, sports_leisure, furniture_decor, computers_accessories
SELECT product_category_name_english, count(*) as num_products
FROM order_items oi
	INNER JOIN products p ON oi.product_id = p.product_id
    INNER JOIN product_category_name_translation pc ON p.product_category_name = pc.product_category_name
GROUP BY product_category_name_english
ORDER BY num_products DESC
LIMIT 10;

-- How popular are tech products compared to other categories?

/* Tech categories:
- audio
- electronics
- computers_accessories
- pc_gamer
- computers
- tablets_printing_image
- telephony
*/
SELECT 
	product_category_name_english, 
    count(product_category_name_english) as products_sold
FROM 
	order_items oi 
		LEFT JOIN products p ON oi.product_id = p.product_id 
		LEFT JOIN product_category_name_translation c ON p.product_category_name = c.product_category_name
WHERE product_category_name_english NOT IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
GROUP BY product_category_name_english
ORDER BY products_sold DESC;

-- total tech_products sold: 15798
SELECT SUM(products_sold) AS tech_products FROM
(SELECT 
	product_category_name_english, 
    count(product_category_name_english) as products_sold
FROM 
	order_items oi 
		LEFT JOIN products p ON oi.product_id = p.product_id 
		LEFT JOIN product_category_name_translation c ON p.product_category_name = c.product_category_name
WHERE product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
GROUP BY product_category_name_english) a;

-- % of tech products sold
SELECT 
	(SELECT SUM(products_sold) AS tech_products FROM
		(SELECT 
				product_category_name_english, 
				count(product_category_name_english) as products_sold
			FROM 
				order_items oi 
					LEFT JOIN products p ON oi.product_id = p.product_id 
					LEFT JOIN product_category_name_translation c ON p.product_category_name = c.product_category_name
		WHERE product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
		GROUP BY product_category_name_english) a) /
	(SELECT COUNT(*) FROM order_items) * 100 AS percentage_tech_products;

/* Are expensive tech products popular?

 Expensive products: price > 100 */

-- total expensive tech products sold = 4437 (about 28% of total tech products)
SELECT SUM(products_sold) FROM (
SELECT 
	product_category_name_english, 
    count(product_category_name_english) as products_sold
FROM 
	order_items oi 
		LEFT JOIN products p ON oi.product_id = p.product_id 
		LEFT JOIN product_category_name_translation c ON p.product_category_name = c.product_category_name
WHERE product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
	AND oi.price > 100
GROUP BY product_category_name_english) a;


-- What’s the average price of the products being sold?
SELECT AVG(a.prod_price) 
FROM (
	SELECT product_id, AVG(price) as prod_price
	FROM order_items
	GROUP BY product_id
) a;

-- How many sellers are there?
SELECT COUNT(*) AS Sellers FROM sellers; -- 3095

-- What’s the average monthly revenue of Magist’s sellers? --4392
SELECT ROUND(AVG(revenue)) AS avg_revenue FROM(
	SELECT 
		s.seller_id, 
		ROUND(SUM(oi.price)) AS revenue 
	FROM sellers s
		LEFT JOIN order_items oi
		ON s.seller_id = oi.seller_id
	GROUP BY s.seller_id
	ORDER BY revenue DESC
	) a;

/*  What’s the average time between the order being placed and the product being delivered?

Step 1: substract delivered_date from purchase_timestamp - notice the result is in miliseconds

Step 2: go from miliseconds to days: divide by 1000 (to seconds), by 60 (to minutes), by 60 (to hours), by 24 (to days)

Step 3: take the average and round it
*/

-- Step 1
SELECT 
	order_delivered_customer_date, 
	order_purchase_timestamp, 
	order_delivered_customer_date - order_purchase_timestamp AS delivery_time 
FROM orders;

-- Step 2
SELECT 
	order_delivered_customer_date, 
	order_purchase_timestamp, 
	(order_delivered_customer_date - order_purchase_timestamp)/1000/60/60/24 AS delivery_time 
FROM orders;

-- Step 3
SELECT 
	ROUND(AVG((order_delivered_customer_date - order_purchase_timestamp)/1000/60/60/24), 2) AS avg_delivery_time 
FROM orders;


# How many orders are delivered on time vs orders delivered with a delay?

WITH main AS ( 
	SELECT * FROM orders
	WHERE order_delivered_customer_date AND order_estimated_delivery_date IS NOT NULL
    ),
    d1 AS (
	SELECT order_delivered_customer_date - order_estimated_delivery_date AS delay FROM main
    ), 
    d2 AS (
	SELECT 
		CASE WHEN delay > 0 THEN 1 ELSE 0 END AS pos_del,
		CASE WHEN delay <=0 THEN 1 ELSE 0 END AS neg_del FROM d1
	GROUP BY delay
    )
SELECT SUM(pos_del) AS delay, SUM(neg_del) AS on_time FROM d2;

# Is there any pattern for delayed orders, e.g. big products being delayed more often?

with main as ( 
	SELECT * FROM orders
	WHERE order_delivered_customer_date AND order_estimated_delivery_date IS NOT NULL
    ),
    d1 as (
	SELECT *, (order_delivered_customer_date - order_estimated_delivery_date)/1000/60/60/24 AS delay FROM main
    )
	SELECT * FROM d1 a
    INNER JOIN order_items b
    ON a.order_id = b.order_id
    INNER JOIN products c
    ON b.product_id = c.product_id
    WHERE delay > 0
    ORDER BY delay DESC, product_weight_g DESC;

#group by on the delay_range, then different aggregate functions about the product weight
with main as ( 
	SELECT * FROM orders
	WHERE order_delivered_customer_date AND order_estimated_delivery_date IS NOT NULL
    ),
    d1 as (
	SELECT *, (order_delivered_customer_date - order_estimated_delivery_date)/1000/60/60/24 AS delay FROM main
    )
		SELECT 
			CASE 
				WHEN delay > 101 THEN "> 100 day Delay"
				WHEN delay > 3 AND delay < 8 THEN "3-7 day delay"
                WHEN delay > 1.5 THEN "1.5 - 3 days delay"
				ELSE "< 1.5 day delay"
			END AS "delay_range", 
            AVG(product_weight_g) AS weight_avg,
            MAX(product_weight_g) AS max_weight,
            MIN(product_weight_g) AS min_weight,
            SUM(product_weight_g) AS sum_weight,
            COUNT(*) AS product_count FROM d1 a
    INNER JOIN order_items b
    ON a.order_id = b.order_id
    INNER JOIN products c
    ON b.product_id = c.product_id
    WHERE delay > 0
    GROUP BY delay_range
    ORDER BY weight_avg DESC;






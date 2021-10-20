USE SampleSales

-----------------///////////////////////-------
--1) What is the sales quantity of product according to the brands and sort them highest-lowest

SELECT		B.brand_name, SUM(C.quantity)
FROM		product.product A
INNER JOIN	product.brand B ON A.brand_id = B.brand_id
INNER JOIN	sale.order_item C ON A.product_id = C.product_id
GROUP BY	B.brand_name
ORDER BY	SUM(C.quantity) DESC;


-----------------///////////////////////-------
---2.Select the top 5 most expensive products

SELECT TOP 5		*
FROM				product.product
ORDER BY			list_price DESC;


-----------------///////////////////////-------
---3.What are the categories that each brand has

SELECT DISTINCT		brand_name, category_name
FROM				product.product A
INNER JOIN			product.brand B ON A.brand_id = B.brand_id
INNER JOIN			product.category C ON A.category_id= C.category_id
GROUP BY			B.brand_name,c.category_name ;


-----------------///////////////////////-------
---4.-Select the avg prices according to brands and categories

SELECT DISTINCT		brand_name, category_name , AVG(list_price)
FROM				product.product A
INNER JOIN			product.brand B ON A.brand_id = B.brand_id
INNER JOIN			product.category C ON A.category_id= C.category_id
GROUP BY
					brand_name, category_name
ORDER BY
					AVG(list_price) DESC;

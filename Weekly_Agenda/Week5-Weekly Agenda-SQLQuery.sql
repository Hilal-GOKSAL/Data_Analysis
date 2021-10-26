USE SampleSales
///////////////////////////////////////

--2. Answer the following SQL questions according to SampleSales database

-- Select the annual amount of product produced according to brands


SELECT			B.brand_name, 
				A.model_year, 
				COUNT(C.quantity) AS annual_amount_of_product

FROM			product.product A

INNER JOIN		product.brand B ON A.brand_id = B.brand_id
INNER JOIN		product.stock C ON A.product_id= C.product_id

GROUP By		B.brand_name, A.model_year
ORDER BY		B.brand_name DESC;



//////////////////////////////////////


-- Select the store which has the most sales quantity in 2018

SELECT TOP 1	A.store_name , COUNT(C.quantity ) AS most_sales_quantity
FROM			sale.store A, sale.orders B, sale.order_item C
WHERE			A.store_id = B.store_id 
AND				B.order_id = C.order_id  
AND				year(B.order_date) = 2018
GROUP BY		A.store_name
ORDER BY		most_sales_quantity DESC;


////////////////////////// --SECOND  SOLUTION:

SELECT TOP 1	A.store_name, 
				COUNT(C.quantity) AS most_sales_quantity

FROM			sale.store A 
	
INNER JOIN		sale.orders B ON A.store_id = B.store_id
INNER JOIN		sale.order_item C ON B.order_id = C.order_id

WHERE			B.order_date BETWEEN '2018-01-01' AND '2018-12-31'

GROUP BY		A.store_name
ORDER BY		most_sales_quantity DESC;


/////////////////////////////////////

-- Select the store which has the most sales amount in 2018

SELECT TOP 1	A.store_name , SUM((C.quantity*C.list_price)*(1-C.discount)) AS most_amount
FROM			sale.store A, sale.orders B, sale.order_item C
WHERE			A.store_id = B.store_id 
AND				B.order_id = C.order_id  
AND				year(B.order_date)= 2018
GROUP BY		A.store_name
ORDER BY		most_amount DESC;


////////////////////////// --SECOND  SOLUTION:

SELECT TOP 1	A.store_name, 
				SUM((C.quantity * C.list_price) * (1- C.discount)) AS most_sales_store

FROM			sale.store A 
	
INNER JOIN		sale.orders B ON A.store_id = B.store_id
INNER JOIN		sale.order_item C ON B.order_id = C.order_id

WHERE			B.order_date BETWEEN '2018-01-01' AND '2018-12-31'

GROUP BY		A.store_name
ORDER BY		most_sales_store DESC;


////////////////////////////////////

--Select the personnel which has the most sales amount in 2018

SELECT TOP 1	 A.first_name, 
				 A.last_name , 
				 SUM((C.quantity * C.list_price)*(1 - C.discount)) AS most_amount

FROM			 sale.staff A, sale.orders B, sale.order_item C
WHERE			 A.staff_id = B.staff_id 
AND				 B.order_id = C.order_id  
AND				 year(B.order_date) = 2018
GROUP BY		 A.first_name, A.last_name
ORDER BY		 most_amount DESC;


////////////////////////// --SECOND  SOLUTION:
SELECT TOP 1	A.first_name,
				A.last_name,
				SUM((C.quantity * C.list_price)* (1-C.discount)) AS most_amount_of_sales

FROM			sale.staff A 
INNER JOIN		sale.orders B ON A.staff_id = B.staff_id
INNER JOIN		sale.order_item C ON B.order_id = C.order_id

WHERE			B.order_date BETWEEN '2018-01-01' AND '2018-12-31'
GROUP BY		A.first_name,
				A.last_name
ORDER BY		most_amount_of_sales  DESC;


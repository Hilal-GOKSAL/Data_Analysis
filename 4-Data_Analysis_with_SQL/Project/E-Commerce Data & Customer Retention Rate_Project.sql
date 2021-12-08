USE ECommerce



--E-Commerce Project Solution
---------------------------
SELECT	*
FROM	cust_dimen;
---------------------------
SELECT	*
FROM	market_fact;
---------------------------
SELECT	*
FROM	orders_dimen;
---------------------------
SELECT	*
FROM	prod_dimen;
-----------------------------
SELECT	*
FROM	shipping_dimen;
-----------------------
--////////////////////////////////


--1. Join all the tables and create a new table called combined_table. 
--(market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)

DROP TABLE combined_table
--/////////////////////////////////////////////////////////////////////////

SELECT			*
INTO			combined_table 
FROM 
					(SELECT			A.Sales, A.Discount,A.Order_Quantity,A.Product_Base_Margin, B.*,C.*,D.*,E.*
					FROM			market_fact A
					FULL OUTER JOIN orders_dimen B ON B.Ord_id = A.Ord_id
					FULL OUTER JOIN prod_dimen C ON C.Prod_id = A.Prod_id
					FULL OUTER JOIN cust_dimen D ON D.Cust_id = A.Cust_id
					FULL OUTER JOIN shipping_dimen E ON E.Ship_id = A.Ship_id ) AS S ;





--//////////////////////////////////////////////////////////////////////
--Longer solution; 

SELECT			Customer.*, 
				Market.Sales,
				Market.Discount,
				Market.Order_Quantity,
				Market.Product_Base_Margin,
				Market.Ord_id,
				Market.Prod_id,
				Market.Ship_id,
				Orders.Order_Date,
				Orders.Order_Priority,
				Product.Product_Category,
				Product.Product_Sub_Category,
				Shipping.Order_ID,
				Shipping.Ship_Date,
				Shipping.Ship_Mode
				

INTO			combined_table

FROM					cust_dimen Customer
FULL OUTER JOIN			market_fact Market ON Customer.Cust_id= Market.Cust_id
FULL OUTER JOIN			orders_dimen Orders ON Market.Ord_id = Orders.Ord_id
FULL OUTER JOIN			prod_dimen Product ON Market.Prod_id = Product.Prod_id
FULL OUTER JOIN			shipping_dimen Shipping ON	Market.Ship_id = Shipping.Ship_id

--/////////////////////////////

SELECT	*
FROM	combined_table





--///////////////////////


--2. Find the top 3 customers who have the maximum count of orders.

SELECT TOP 3		Customer_Name, Cust_id, COUNT(Ord_id) AS max_ordered_customers
FROM				combined_table
GROUP BY			Customer_Name, Cust_id
ORDER BY			max_ordered_customers DESC;

--/////////////////////////////////



--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
--Use "ALTER TABLE", "UPDATE" etc.

ALTER TABLE combined_table
ADD DaysTakenForDelivery INT


UPDATE combined_table
SET DaysTakenForDelivery = DATEDIFF(DAY, Order_Date, Ship_Date);




SELECT		*
FROM		combined_table

--////////////////////////////////////


--4. Find the customer whose order took the maximum time to get delivered.
--Use "MAX" or "TOP"

SELECT	TOP 1	Cust_id, Customer_Name,MAX(DaysTakenForDelivery) AS max_delivered_time_cust
FROM			combined_table
GROUP BY		Cust_id, Customer_Name
ORDER BY		max_delivered_time_cust DESC;



--////////////////////////////////



--5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
--You can use such date functions and subqueries

SELECT		MONTH(Order_date) AS month_of_order, COUNT(DISTINCT Cust_id) AS distinct_number_of_cust
FROM		combined_table
WHERE		Cust_id IN
						(SELECT		Cust_id
						FROM		combined_table
						WHERE		MONTH(Order_date) = 1
						AND			YEAR(Order_date) =  2011
						)
GROUP BY	MONTH(Order_date) 
ORDER BY	month_of_order;



--////////////////////////////////////////////


--6. write a query to return for each user the time elapsed between the first purchasing and the third purchasing, 
--in ascending order by Customer ID
--Use "MIN" with Window Functions

SELECT DISTINCT Cust_id,
				Order_date,
				rank_of_third_purchase,
				time_of_first_purchase,
				DATEDIFF(day, time_of_first_purchase, order_date) time_elapsed

FROM		(SELECT Cust_id, Order_Date,
			MIN (Order_Date) OVER (PARTITION BY Cust_id) time_of_first_purchase,
			DENSE_RANK () OVER (PARTITION BY Cust_id ORDER BY Order_date) rank_of_third_purchase
			FROM combined_table) A

WHERE	rank_of_third_purchase = 3


--//////////////////////////////////////

--7. Write a query that returns customers who purchased both product 11 and product 14, 
--as well as the ratio of these products to the total number of products purchased by the customer. (exact product/customer's total purchase)
--Use CASE Expression, CTE, CAST AND such Aggregate Functions
--common table expression
--cast function

WITH Common_Table
AS 

(
		SELECT	Cust_id, 
				SUM(CASE WHEN CAST(Prod_id as INT) = 11 THEN CAST(Order_Quantity as INT) ELSE 0 END) Product_11,
				SUM(CASE WHEN CAST(Prod_id as INT) = 14 THEN CAST(Order_Quantity as INT) ELSE 0 END) Product_14,
				COUNT(Order_Quantity) AS TOTAL_PURCHASED
		FROM	combined_table
		GROUP BY Cust_id 
		HAVING 
				SUM(CASE WHEN CAST(Prod_id as INT) = 11 THEN CAST(Order_Quantity as INT) ELSE 0 END) >=1 AND
				SUM(CASE WHEN CAST(Prod_id as INT) = 14 THEN CAST(Order_Quantity as INT) ELSE 0 END) >=1
)
SELECT Cust_id, Product_11, Product_14, TOTAL_PURCHASED,
	   ROUND(CAST( Product_11 as float)/CAST (TOTAL_PURCHASED as float), 2) RATIO_Product_11,
	   ROUND(CAST( Product_14 as float)/CAST (TOTAL_PURCHASED as float), 2) RATIO_Product_14
FROM Common_Table
ORDER BY Cust_id;



--/////////////////



--CUSTOMER RETENTION ANALYSIS



--1. Create a view that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
--Use such date functions. Don't forget to call up columns you might need later.

CREATE VIEW customers_logs_view
AS

SELECT		Cust_id, YEAR(Order_date) AS [YEAR], MONTH(Order_date) AS [MONTH]
FROM		combined_table

-----------------

SELECT		*
FROM		customers_logs_view
ORDER BY	[YEAR],  [MONTH]

--//////////////////////////////////


--2. Create a view that keeps the number of monthly visits by users. (Separately for all months from the business beginning)
--Don't forget to call up columns you might need later.

CREATE VIEW monthly_visiters_view
AS
SELECT		Cust_id, DATEPART(MONTH, Order_Date) AS each_month, DATEPART(YEAR, Order_date) AS each_year, COUNT(*) count_of_visits_by_users
FROM		combined_table
GROUP BY	Cust_id, DATEPART(MONTH, Order_Date),DATEPART(YEAR, Order_date);

-------------

SELECT * 
FROM monthly_visiters_view


--//////////////////////////////////


--3. For each visit of customers, create the next month of the visit as a separate column.
--You can number the months with "DENSE_RANK" function.
--then create a new column for each month showing the next month using the numbering you have made. (use "LEAD" function.)
--Don't forget to call up columns you might need later.

CREATE VIEW seperate_column_for_next_visit
AS

SELECT		Cust_id, each_year,
			DENSE_RANK () OVER (ORDER BY each_month) AS rank_of_month,
			LEAD(count_of_visits_by_users, 1, 0) OVER(PARTITION BY Cust_id, each_year ORDER BY each_month) AS NextMonth 
FROM		monthly_visiters_view

-----

SELECT *
FROM seperate_column_for_next_visit


--/////////////////////////////////



--4. Calculate the monthly time gap between two consecutive visits by each customer.
--Don't forget to call up columns you might need later.


CREATE VIEW Time_Gaps_View 
AS

SELECT *, rank_of_month - NextMonth AS TIME_GAPS			
FROM seperate_column_for_next_visit


------
SELECT	* 
FROM	Time_Gaps_View




--/////////////////////////////////////////


--5.Categorise customers using time gaps. Choose the most fitted labeling model for you.
--  For example: 
--	Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
--	Labeled as regular if the customer has made a purchase every month.
--  Etc.


SELECT	*,
		CASE
		WHEN TIME_GAPS <= 0 THEN 'Churn'
		WHEN TIME_GAPS BETWEEN  1 AND 3 THEN 'Regular'
		WHEN TIME_GAPS > 3 THEN 'Unpredictable Potential Customer'
		END labels_of_customers

FROM Time_Gaps_View





--/////////////////////////////////////




--MONTH-WÝSE RETENTÝON RATE


--Find month-by-month customer retention rate  since the start of the business.


--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps

SELECT *,  COUNT(Cust_id) OVER(PARTITION BY NextMonth) RETENTITON_MONTH_WISE
FROM Time_Gaps_View 
WHERE TIME_GAPS=1
ORDER BY Cust_id, NextMonth


--//////////////////////


--2. Calculate the month-wise retention rate.

--Basic formula: o	Month-Wise Retention Rate = 1.0 * Total Number of Customers in The Previous Month / Number of Customers Retained in The Next Nonth

--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View. 
--You can also use CTE or Subquery if you want.

--You should pay attention to the join type and join columns between your views or tables.

---------------------------

SELECT *
FROM Time_Gaps_View

--------------------------

CREATE VIEW Customers_Previous_Month 
AS

SELECT	DISTINCT	cust_id, each_year,
		rank_of_month,
		NextMonth,
		COUNT (cust_id)	OVER (PARTITION BY NextMonth) Current_customers
FROM	Time_Gaps_View




CREATE VIEW Upcoming_Customers 
AS

SELECT	DISTINCT cust_id, each_year,
		rank_of_month,
		NextMonth,
		COUNT (cust_id)	OVER (PARTITION BY NextMonth) Next_customers
FROM	Time_Gaps_View
WHERE TIME_GAPS=1 AND NextMonth>1



SELECT DISTINCT			B.each_year,B.rank_of_month, 
						ROUND(CAST ( B.Next_customers AS FLOAT)/A.Current_customers,2) AS RETENTION_RATE

FROM					Customers_Previous_Month  A 
INNER JOIN				Upcoming_Customers  B
ON						A.NextMonth+1 =B.NextMonth;






---///////////////////////////////////

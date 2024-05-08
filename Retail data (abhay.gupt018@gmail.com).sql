select * from Customer;
select * from Product;
select * from Transactions;

--Data Prepartion And Understanding--
--1. Ans
Select Count(*) as total_row_cus
From Customer;
Select Count(*) as total_row_Pro
From Product;
Select Count(*) as total_row_Tran
From Transactions;

-- 2.Ans --
Select Count(*) As Total_return
From Transactions
where total_amt < 0;

--3. ans--

SELECT CONVERT(DATE, DOB, 105) AS DATES FROM CUSTOMER 
SELECT CONVERT(DATE, TRAN_DATE, 105) FROM TRANSACTIONS;

--4.Ans--
SELECT DATEDIFF(DAY, MIN(CONVERT(DATE, TRAN_DATE, 105)),MAX(CONVERT(DATE, TRAN_DATE, 105))) AS DAYSS,
DATEDIFF(MONTH, MIN(CONVERT(DATE, TRAN_DATE, 105)),MAX(CONVERT(DATE, TRAN_DATE, 105))) AS MONTHS,
DATEDIFF(YEAR, MIN(CONVERT(DATE, TRAN_DATE, 105)),MAX(CONVERT(DATE, TRAN_DATE, 105))) AS YEARS
FROM TRANSACTIONS;

--5. Ans "BOOK" --

SELECT prod_cat FROM PRODUCT
WHERE prod_subcat Like 'DIY';

/* DATA ANALYSIS */

--1. ANS "e-Shop" --

Select top 1 
Store_type, COUNT(TRANSACTION_ID) as counts
from Transactions
GROUP BY Store_type
ORDER BY COUNT(TRANSACTION_ID) DESC;

-- 2. ANS "F = 2753; M=2892"
SELECT GENDER , COUNT(CUSTOMER_ID) AS GENDERCOUNT
FROM Customer
WHERE GENDER IN ('M','F')
GROUP BY GENDER;

-- 3. ANS "CITY_CODE = 3, TOTAL_CUSTOMER = 595"

SELECT TOP 1
CITY_CODE, COUNT(CUSTOMER_ID) AS TOTAL_CUSTOMERE
FROM Customer
GROUP BY CITY_CODE
ORDER BY COUNT(CUSTOMER_ID) DESC;

--4. ANS. "6"

SELECT COUNT(PROD_SUBCAT) AS SUBCAT_CNT
FROM PRODUCT
WHERE PROD_CAT LIKE 'BOOKS'
GROUP BY PROD_CAT;

--5. ANS 'BOOK = 36414' --

SELECT TOP 1 
TRANSACTIONS.prod_cat_code, PRODUCT.prod_cat , COUNT(TRANSACTIONS.prod_cat_code) AS QUANTITY
FROM Transactions
LEFT JOIN Product ON PRODUCT.prod_cat_code = TRANSACTIONS.prod_cat_code
GROUP BY TRANSACTIONS.prod_cat_code, PRODUCT.prod_cat
ORDER BY 3 DESC;


-- 6. ANS. 23545157.6749999 --

SELECT SUM(TOTAL_AMT) AS TOTAL_AMT
FROM TRANSACTIONS
INNER JOIN PRODUCT ON PRODUCT.prod_cat_code = TRANSACTIONS.prod_cat_code
AND PRODUCT.prod_sub_cat_code = TRANSACTIONS.prod_subcat_code
WHERE prod_cat IN ('ELECTRONICS', 'BOOKS');


-- 7.  ANS '6' CUSTOMERS

SELECT COUNT(customer_Id) AS _CUSTOMERS FROM Customer
WHERE customer_Id IN (
SELECT CUST_ID
FROM Transactions
LEFT JOIN CUSTOMER ON CUSTOMER_ID = CUST_ID
WHERE TOTAL_AMT NOT LIKE '-%'
GROUP BY CUST_ID
HAVING COUNT(TRANSACTION_ID) > 10
) ;

--8. ANS 'TOTAL AMOUNT = 4703341.89'

SELECT SUM(TOTAL_AMT) AS TOTAL_AMT
FROM TRANSACTIONS
INNER JOIN PRODUCT ON PRODUCT.prod_cat_code = TRANSACTIONS.prod_cat_code
AND PRODUCT.prod_sub_cat_code = TRANSACTIONS.prod_subcat_code
WHERE prod_cat IN ('ELECTRONICS', 'BOOKS') AND STORE_TYPE = 'FLAGSHIP STORE';

-- 9. ANS. 
SELECT PROD_SUBCAT, SUM(TOTAL_AMT) AS  TOTAL_REVENUE
FROM TRANSACTIONS
LEFT JOIN CUSTOMER ON CUSTOMER.customer_Id = TRANSACTIONS.cust_id
LEFT JOIN PRODUCT ON PRODUCT.prod_sub_cat_code = TRANSACTIONS.prod_subcat_code AND PRODUCT.prod_cat_code = TRANSACTIONS.prod_cat_code
WHERE PRODUCT.prod_cat_code= '3' AND GENDER = 'M' 
GROUP BY TRANSACTIONS.prod_subcat_code, PROD_SUBCAT;

-- 10. ANS.

ALTER TABLE TRANSACTIONS
ALTER COLUMN TOTAL_AMT DECIMAL(10,2);

ALTER TABLE TRANSACTIONS
ALTER COLUMN QTY INT;

SELECT TOP 5
PRODUCT.prod_subcat,
(SUM(TOTAL_AMT)/(SELECT SUM(TOTAL_AMT) FROM TRANSACTIONS))*100 AS PERCENTAGE_SALES,
(COUNT(CASE WHEN QTY <0 THEN QTY ELSE NULL END)/SUM(QTY))*100 AS PERCENTAGE_RETURNS
FROM TRANSACTIONS
INNER JOIN Product ON PRODUCT.prod_cat_code = TRANSACTIONS.prod_cat_code AND PRODUCT.prod_sub_cat_code = TRANSACTIONS.prod_subcat_code
GROUP BY PRODUCT.prod_subcat
ORDER BY SUM(TOTAL_AMT) DESC;

-- 11. ANS
SELECT CUST_ID,SUM(TOTAL_AMT) AS REVENUE FROM TRANSACTIONS
WHERE CUST_ID IN 
	(SELECT customer_Id
	 FROM CUSTOMER
     WHERE DATEDIFF(YEAR,CONVERT(DATE,DOB,103),GETDATE()) BETWEEN 25 AND 35)
     AND CONVERT(DATE,tran_date,103) BETWEEN DATEADD(DAY,-30,(SELECT MAX(CONVERT(DATE,tran_date,103)) FROM TRANSACTIONS)) 
	 AND (SELECT MAX(CONVERT(DATE,tran_date,103)) FROM TRANSACTIONS)
GROUP BY CUST_ID;


--12. Ans

SELECT TOP 1 prod_cat , SUM(total_amt) FROM TRANSACTIONS AS T1
INNER JOIN PRODUCT T2 ON T1.prod_cat_code = T2.prod_cat_code AND 
T1.prod_subcat_code = T2.prod_sub_cat_code
WHERE TOTAL_AMT < 0 AND 
CONVERT(date, tran_date, 103) BETWEEN DATEADD(MONTH,-3,(SELECT MAX(CONVERT(DATE,tran_date,103)) FROM TRANSACTIONS)) 
	 AND (SELECT MAX(CONVERT(DATE,tran_date,103)) FROM TRANSACTIONS)
GROUP BY PROD_CAT
ORDER BY 2 DESC

--13. Ans
Select Store_type , 
Sum(total_amt) AS Total_Sum, 
Sum(Qty) As Total_Qty
from Transactions
Group by Store_type
Having Sum(total_amt)>= All (select Sum(total_amt) From Transactions Group by Store_type)
And Sum(Qty) >=All (Select Sum(Qty) From Transactions Group by Store_type) ;


--14. Ans
Select prod_cat, AVG(total_amt) AS Average
From Transactions As T
Inner Join Product As P On T.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = P.prod_sub_cat_code
Group by prod_cat
Having AVG(total_amt) > (Select AVG(total_amt) From Transactions);

--15. Ans

Select prod_cat, prod_subcat, AVG(total_amt) AS Average, Sum(total_amt) As Total_Revenue
From Transactions as T
Inner Join Product As P ON T.prod_cat_code = P.prod_sub_cat_code And T.prod_subcat_code = P.prod_sub_cat_code
where prod_cat in (select top 5 
prod_cat
From Transactions as T
Inner Join Product As P ON T.prod_cat_code = P.prod_sub_cat_code And T.prod_subcat_code = P.prod_sub_cat_code
Group by prod_cat
Order by Sum(Qty) DESC)
Group by prod_cat, prod_subcat;
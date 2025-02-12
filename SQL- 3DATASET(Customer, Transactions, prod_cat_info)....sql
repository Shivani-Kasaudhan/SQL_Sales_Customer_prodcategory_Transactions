create database customers;
use customers;

##DATA PREPARATION AND UNDERSTANDING
#What is total no of rows in each of the 3 tables in the database?
create view Total_rows_of_3_Tables As
SELECT 'Customer' AS TableName, COUNT(*) AS RowCount FROM Customer
UNION ALL
SELECT 'Transactions' AS TableName, COUNT(*) AS RowCount FROM Transactions
UNION ALL
SELECT 'Product Category' AS TableName, COUNT(*) AS RowCount FROM Prod_cat_info;

select * from Total_rows_of_3_Tables;

# What is the total no of transactions that have return?
Create view total_no_of_transactions_that_have_return AS
SELECT COUNT(*) AS Total_Return_Transactions
FROM Transactions
WHERE Qty < 0;

SELECT * FROM total_no_of_transactions_that_have_return;

#Update date column to a valid format (YYYY-MM-DD)
#Disabling safe update mode
SET SQL_SAFE_UPDATES = 0;  

UPDATE Customer 
SET DOB = DATE_FORMAT(STR_TO_DATE(DOB, '%Y-%m-%d'), '%d-%m-%y');

#Inabling safe update mode
SET SQL_SAFE_UPDATES = 1;

select DOB
from customer;

# Setting Primary key
ALTER TABLE Customer
  ADD PRIMARY KEY (customer_Id);
  
# checking count of Transcation Id group of Transaction
SELECT transaction_id, COUNT(*) 
FROM Transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;
    
#How to check Primary Key
  SHOW KEYS FROM Customer WHERE Key_name = 'PRIMARY';
  SHOW KEYS FROM Transactions WHERE Key_name = 'PRIMARY';
  
------------------------------------------------------------------------------------
SELECT COUNT(*) AS null_count
FROM Transactions
WHERE tran_date IS NULL;

DESCRIBE Transactions;

SELECT DISTINCT tran_date
FROM Transactions;

SELECT from Transactions order by cust_id, tran_date;


SELECT 
	,DATEDIFF(DAY,MAX(CAST(CAST(tran_date AS NCHAR(8)) AS date)), MIN(CAST(CAST(tran_date AS NCHAR(8)) AS date)) ) AS Difference_Days
    ,DATEDIFF(MONTH,MAX(CAST(CAST(tran_date AS NCHAR(8)) AS date)), MIN(CAST(CAST(tran_date AS NCHAR(8)) AS date)) ) AS Difference_Months
    ,DATEDIFF(YEAR,MAX(CAST(CAST(tran_date AS NCHAR(8)) AS date)), MIN(CAST(CAST(tran_date AS NCHAR(8)) AS date)) ) AS Difference_Years
FROM Transactions

UPDATE Transactions
SET tran_date = STR_TO_DATE(tran_date, '%Y-%m-%d'); -- Adjust the format as per your data (e.g., '%d-%m-%Y')

  
SELECT
    DATEDIFF(MAX(tran_date), MIN(tran_date)) AS total_days,
    TIMESTAMPDIFF(MONTH, MIN(tran_date), MAX(tran_date)) AS total_months,
    TIMESTAMPDIFF(YEAR, MIN(tran_date), MAX(tran_date)) AS total_years
FROM
    Transactions;




ALTER TABLE Transactions 
ADD COLUMN formatted_date DATE;

UPDATE Transactions
SET formatted_date = STR_TO_DATE(tran_date, '%d/%m/%Y')
WHERE tran_date IS NOT NULL;
--------------------------------------------------------------------------
# Which product category does the sub-category "DIY" belong to?
SELECT prod_cat
FROM prod_cat_info
WHERE prod_subcat = 'DIY';

## DATA ANALYSIS
# 1-Which Channel is most frequently used for transactions?

Select Store_type, count(*) AS Channel_For_Transactions
From Transactions
Group by Store_type
order by Channel_For_Transactions DESC
limit 1;


#2-What is the count of male and female customer in the database?

Select Gender, count(*) AS Gender_Count
FROM Customer
Group by Gender;

#3-From which city do we have maximum no of customers and how many?

Select city_code, count(*) AS Customer_Count
FROM customer
group by city_code
Order by Customer_Count Desc
Limit 1;

#4-How may sub-category are there under the Books category?

Select prod_cat, Count(distinct prod_subcat) AS Prod_Subcat_Count
From prod_cat_info
Where prod_cat = 'Books';

SELECT COUNT(DISTINCT prod_subcat) AS Subcategory_Count
FROM prod_cat_info
WHERE prod_cat = 'Books';

#5-what are  maximum quantities of products ever ordered?

Select prod_cat_code,max(Qty) AS QTY
FROM Transactions 
Group by prod_cat_code
order by QTY DESC;

#5-CHECK Which solution is correct for MAX_QTY ?

SELECT MAX(Qty) AS Max_Quantity_Ordered
FROM Transactions;
    
# To check Distinct value of Qty. 
Select distinct Qty
from Transactions;

# To check no of rows in Transactions table
select count(*) From Transactions;

# What is the net total revenue genrated in categories Electronics and Books?

Create View Total_Revenue_genrated_Electronics_Books AS
SELECT p.prod_cat AS Category, sum(t.total_amt) AS Total_Revenue
FROM Transactions t
JOIN prod_cat_info p 
ON t.prod_cat_code = p.prod_cat_code
WHERE p.prod_cat IN ('Electronics','Books')
GROUP BY p.prod_cat;

Select * From Total_Revenue_genrated_Electronics_Books;

#7-How many Customers have > 10 transactions with us, excluding returns?

SELECT COUNT(DISTINCT t.cust_id) AS Total_Customers
FROM Transactions t
WHERE t.Qty > 0
GROUP BY t.cust_id
HAVING COUNT(t.transaction_id) > 10;

#2nd way to solve:-
SELECT COUNT(*) AS Total_Customers
FROM (SELECT cust_id FROM Transactions
    WHERE Qty > 0 -- Exclude returns (assume returns have negative Qty)
    GROUP BY cust_id
    HAVING COUNT(transaction_id) > 10
) AS Subquery;

# 8- What is the combined revenue earned from the "Electronics" & "Clothing" categories,from "Flagship stores"?

SELECT SUM(total_amt) AS Combined_Revenue
FROM Transactions T
JOIN prod_cat_info P
ON T.prod_cat_code = P.prod_cat_code
WHERE P.prod_cat IN ('Electronics', 'Clothing') 
AND T.store_type = 'Flagship store';

# 9-What is the total revenue generated from "Male" customer in "Electronics" category? Output should display total revenue by prod sub-cat.

SELECT P.prod_subcat AS Product_Subcategory, SUM(T.total_amt) AS Total_Revenue
FROM Transactions T
JOIN Customer C
ON T.cust_id = C.customer_Id
JOIN prod_cat_info P
ON T.prod_cat_code = P.prod_cat_code
WHERE C.Gender = 'M' AND P.prod_cat = 'Electronics'
GROUP BY P.prod_subcat;

# 10- What is the percentage of sales and return by product sub category ;display only top 5 sub category in terms of sales?

WITH SubCategorySales AS (
    SELECT 
        P.prod_subcat AS Product_Subcategory,
        COUNT(CASE WHEN T.Qty > 0 THEN 1 END) AS Total_Sales,
        COUNT(CASE WHEN T.Qty < 0 THEN 1 END) AS Total_Returns,
        SUM(T.total_amt) AS Total_Revenue
    FROM 
        Transactions T
    JOIN 
        prod_cat_info P
    ON 
        T.prod_cat_code = P.prod_cat_code
    GROUP BY 
        P.prod_subcat
),
SalesWithPercentage AS (
    SELECT 
        Product_Subcategory,
        Total_Sales,
        Total_Returns,
        Total_Revenue,
        (Total_Sales * 100.0) / SUM(Total_Sales) OVER () AS Sales_Percentage,
        (Total_Returns * 100.0) / SUM(Total_Returns) OVER () AS Returns_Percentage
    FROM 
        SubCategorySales
)
SELECT 
    Product_Subcategory,
    Total_Sales,
    Total_Returns,
    Total_Revenue,
    ROUND(Sales_Percentage, 2) AS Sales_Percentage,
    ROUND(Returns_Percentage, 2) AS Returns_Percentage
FROM 
    SalesWithPercentage
ORDER BY 
    Total_Sales DESC
LIMIT 5;

#11- With all customers between 25 to 35 years .Find what is the total net revenue generated by these consumers in last 30 days of transactions from max transactions date available in data ?

-- Step 1: Find the maximum transaction date
SELECT MAX(STR_TO_DATE(tran_date, '%d-%m-%Y')) AS Max_Transaction_Date
FROM Transactions;

-- Step 2: Calculate the total net revenue
SELECT 
    SUM(t.total_amt) AS Total_Revenue
FROM 
    Transactions t
JOIN 
    Customer c ON t.cust_id = c.customer_id
WHERE 
    TIMESTAMPDIFF(YEAR, STR_TO_DATE(c.DOB, '%d-%m-%Y'), CURDATE()) BETWEEN 25 AND 35
    AND STR_TO_DATE(t.tran_date, '%d-%m-%Y') >= (
        SELECT DATE_SUB(MAX(STR_TO_DATE(tran_date, '%d-%m-%Y')), INTERVAL 30 DAY)
        FROM Transactions
    );

#12- Which product category has seen the max value  of returns in last 3 months of transactions?

-- Step 1: Find the maximum transaction date
SELECT MAX(STR_TO_DATE(tran_date, '%d-%m-%Y')) AS Max_Transaction_Date
FROM Transactions;

-- Step 2: Find the product category with the highest return value
SELECT 
    p.prod_cat AS Product_Category,
    SUM(t.total_amt) AS Total_Return_Value
FROM 
    Transactions t
JOIN 
    prod_cat_info p ON t.prod_cat_code = p.prod_cat_code
WHERE 
    STR_TO_DATE(t.tran_date, '%d-%m-%Y') >= (
        SELECT DATE_SUB(MAX(STR_TO_DATE(tran_date, '%d-%m-%Y')), INTERVAL 3 MONTH)
        FROM Transactions
    )
    AND t.Qty < 0 -- Returns are indicated by negative quantities
GROUP BY 
    p.prod_cat
ORDER BY 
    Total_Return_Value DESC
LIMIT 1;

#13-Which store-type sells the maximum products; by value of sales amount and by quantity sold? 

SELECT 
    store_type,
    SUM(total_amt) AS total_sales_value,
    SUM(Qty) AS total_quantity_sold
FROM Transactions
GROUP BY store_type
ORDER BY total_sales_value DESC, total_quantity_sold DESC
LIMIT 1;

#14-  What are the categories for which average revenue is above the overall average?

SELECT 
    p.prod_cat AS category,
    AVG(t.total_amt) AS avg_revenue_per_category
FROM Transactions t
JOIN prod_cat_info p ON t.prod_cat_code = p.prod_cat_code
GROUP BY p.prod_cat
HAVING AVG(t.total_amt) > (SELECT AVG(total_amt) FROM Transactions);

#15-  Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms quantity sold .

WITH TopCategories AS (
    SELECT 
        p.prod_cat, 
        SUM(t.Qty) AS total_quantity
    FROM 
        Transactions t
    JOIN 
        prod_cat_info p 
        ON t.prod_cat_code = p.prod_cat_code
    GROUP BY 
        p.prod_cat
    ORDER BY 
        total_quantity DESC
    LIMIT 5
),
RevenueBySubcategory AS (
    SELECT 
        p.prod_cat,
        p.prod_subcat,
        AVG(t.total_amt) AS avg_revenue,
        SUM(t.total_amt) AS total_revenue
    FROM 
        Transactions t
    JOIN 
        prod_cat_info p 
        ON t.prod_cat_code = p.prod_cat_code
    WHERE 
        p.prod_cat IN (SELECT prod_cat FROM TopCategories)
    GROUP BY 
        p.prod_cat, p.prod_subcat
)
SELECT 
    prod_cat,
    prod_subcat,
    avg_revenue,
    total_revenue
FROM 
    RevenueBySubcategory
ORDER BY 
    prod_cat, total_revenue DESC;













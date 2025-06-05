# IDT-Assignment2
Початковий запит:

SELECT 
    s.SalesID,
    s.SalesPersonID,
    s.CustomerID,
    s.ProductID,
    s.Quantity,
    s.Discount,
    s.TotalPrice,
    s.SalesDate,
    s.TransactionNumber,

    (SELECT COUNT(*) 
     FROM sales s2 
     WHERE s2.CustomerID = s.CustomerID) AS TotalCustomerSales,

    (SELECT AVG(s3.Quantity * (1 - s3.Discount)) 
     FROM sales s3 
     WHERE s3.SalesPersonID = s.SalesPersonID) AS AvgDiscountedQty,

    (SELECT MAX(s4.SalesDate) 
     FROM sales s4 
     WHERE s4.ProductID = s.ProductID) AS LastSaleOfProduct,

    (SELECT DATEDIFF(MAX(s5.SalesDate), MIN(s5.SalesDate)) 
     FROM sales s5 
     WHERE s5.ProductID = s.ProductID) AS ProductSaleSpanDays

FROM sales s

WHERE s.Discount > 0
  AND s.Quantity > 5
  AND s.ProductID IN (
      SELECT ProductID 
      FROM sales 
      WHERE YEAR(SalesDate) = 2018
      GROUP BY ProductID
      HAVING COUNT(*) > 5
  )
ORDER BY 
    s.SalesPersonID DESC,
    s.SalesDate ASC;


![image](https://github.com/user-attachments/assets/76dcd542-5872-454f-83d9-479a0bd468d0)
Створимо індекси:

CREATE INDEX sales_personID_ind ON sales(SalesPersonID);
![image](https://github.com/user-attachments/assets/6a37e632-e964-4442-aa1c-220ac48e2358)

CREATE INDEX productID_ind ON sales(ProductID);

![image](https://github.com/user-attachments/assets/57e0ae30-b564-4a45-8020-77ed0c4a3b11)

CREATE INDEX productID_salesDate_ind ON sales(SalesDate, ProductID);

І замінеми YEAR() на WHERE SalesDate >= '2018-01-01' AND SalesDate < '2019-01-01'

![image](https://github.com/user-attachments/assets/070bbc75-9957-431d-aa5f-9825541f2ee9)

CREATE INDEX customerID_ind ON sales(CustomerID);

CREATE INDEX idx_main_filter 
ON sales (Discount, Quantity, ProductID, SalesDate, SalesPersonID, CustomerID);

І ЗАМІНИМО IN НА JOIN

JOIN (
    SELECT ProductID
    FROM sales
    WHERE SalesDate >= '2018-01-01' AND SalesDate < '2019-01-01'
    GROUP BY ProductID
    HAVING COUNT(*) > 5
) fp ON fp.ProductID = s.ProductID

WHERE s.Discount > 0
  AND s.Quantity > 5

![image](https://github.com/user-attachments/assets/2b89cf24-4414-43bc-bdb5-f6825383ff03)

CREATE DATABASE IF NOT EXISTS P04_OPT;
USE P04_OPT;

CREATE INDEX sales_personID_ind ON sales(SalesPersonID);
CREATE INDEX productID_ind ON sales(ProductID);
CREATE INDEX customerID_ind ON sales(CustomerID);

CREATE INDEX idx_main_filter 
ON sales (Discount, Quantity, ProductID, SalesDate, SalesPersonID, CustomerID);

CREATE INDEX idx_product_sales_date 
ON sales (ProductID, SalesDate);

EXPLAIN SELECT 
    s.SalesID,
    s.SalesPersonID,
    s.CustomerID,
    s.ProductID,
    s.Quantity,
    s.Discount,
    s.TotalPrice,
    s.SalesDate,
    s.TransactionNumber,

    (SELECT COUNT(*) 
     FROM sales s2 
     WHERE s2.CustomerID = s.CustomerID) AS TotalCustomerSales,

    (SELECT AVG(s3.Quantity * (1 - s3.Discount)) 
     FROM sales s3 
     WHERE s3.SalesPersonID = s.SalesPersonID) AS AvgDiscountedQty,

    (SELECT MAX(s4.SalesDate) 
     FROM sales s4 
     WHERE s4.ProductID = s.ProductID) AS LastSaleOfProduct,

    (SELECT DATEDIFF(MAX(s5.SalesDate), MIN(s5.SalesDate)) 
     FROM sales s5 
     WHERE s5.ProductID = s.ProductID) AS ProductSaleSpanDays

FROM sales s

JOIN (
    SELECT ProductID
    FROM sales
    WHERE SalesDate >= '2018-01-01' AND SalesDate < '2019-01-01'
    GROUP BY ProductID
    HAVING COUNT(*) > 5
) fp ON fp.ProductID = s.ProductID

WHERE s.Discount > 0
  AND s.Quantity > 5

ORDER BY 
    s.SalesPersonID DESC,
    s.SalesDate ASC;

Додамо FORCE INDEX, щоб не було ALL (CREATE INDEX idx_quantity ON sales (Quantity);)

CREATE DATABASE IF NOT EXISTS P04_OPT;
USE P04_OPT;

CREATE INDEX sales_personID_ind ON sales(SalesPersonID);
CREATE INDEX productID_ind ON sales(ProductID);
CREATE INDEX customerID_ind ON sales(CustomerID);

CREATE INDEX idx_quantity ON sales (Quantity);


CREATE INDEX idx_product_sales_date 
ON sales (ProductID, SalesDate);

EXPLAIN SELECT 
    s.SalesID,
    s.SalesPersonID,
    s.CustomerID,
    s.ProductID,
    s.Quantity,
    s.Discount,
    s.TotalPrice,
    s.SalesDate,
    s.TransactionNumber,

    (SELECT COUNT(*) 
     FROM sales s2 
     WHERE s2.CustomerID = s.CustomerID) AS TotalCustomerSales,

    (SELECT AVG(s3.Quantity * (1 - s3.Discount)) 
     FROM sales s3 
     WHERE s3.SalesPersonID = s.SalesPersonID) AS AvgDiscountedQty,

    (SELECT MAX(s4.SalesDate) 
     FROM sales s4 
     WHERE s4.ProductID = s.ProductID) AS LastSaleOfProduct,

    (SELECT DATEDIFF(MAX(s5.SalesDate), MIN(s5.SalesDate)) 
     FROM sales s5 
     WHERE s5.ProductID = s.ProductID) AS ProductSaleSpanDays

FROM sales s FORCE INDEX (idx_quantity)

JOIN (
    SELECT ProductID
    FROM sales
    WHERE SalesDate >= '2018-01-01' AND SalesDate < '2019-01-01'
    GROUP BY ProductID
    HAVING COUNT(*) > 5
) fp ON fp.ProductID = s.ProductID

WHERE s.Discount > 0 AND s.Quantity > 5


ORDER BY 
    s.SalesPersonID DESC,
    s.SalesDate ASC;

![image](https://github.com/user-attachments/assets/f0332fbe-cf40-47e4-8d3f-e6302e2b57a5)

CREATE INDEX idx_salesdate_product ON sales (SalesDate, ProductID);

![image](https://github.com/user-attachments/assets/46de6c95-448a-4089-89f1-2dbc5f1354b1)







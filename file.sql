CREATE DATABASE IF NOT EXISTS P04_OPT;
USE P04_OPT;

CREATE INDEX sales_personID_ind ON sales(SalesPersonID);
CREATE INDEX productID_ind ON sales(ProductID);
CREATE INDEX customerID_ind ON sales(CustomerID);

CREATE INDEX idx_quantity ON sales (Quantity);

CREATE INDEX idx_salesdate_product ON sales (SalesDate, ProductID);


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









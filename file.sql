SELECT s.SalesID, s.SalesPersonID, s.CustomerID, s.ProductID, s.Quantity, s.Discount, s.TotalPrice, s.SalesDate, s.TransactionNumber,

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

WHERE s.Discount > 0 AND s.Quantity > 5 AND s.ProductID IN ( SELECT ProductID FROM sales WHERE YEAR(SalesDate) = 2018 GROUP BY ProductID HAVING COUNT(*) > 5 ) ORDER BY s.SalesPersonID DESC, s.SalesDate ASC;

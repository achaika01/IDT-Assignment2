CREATE DATABASE IF NOT EXISTS P04_OPT;
USE P04_OPT;


CREATE INDEX idx_discount_quantity_product ON sales(Discount, Quantity, ProductID);
CREATE INDEX idx_product_salesdate ON sales(ProductID, SalesDate);
CREATE INDEX idx_salesperson_salesdate ON sales(SalesPersonID DESC, SalesDate ASC);
CREATE INDEX customerID_ind ON sales(CustomerID);
CREATE INDEX sales_personID_ind ON sales(SalesPersonID);

EXPLAIN ANALYZE
WITH
tcs AS (
    SELECT CustomerID, COUNT(*) AS TotalCustomerSales
    FROM sales
    GROUP BY CustomerID
),
adq AS (
    SELECT SalesPersonID, AVG(Quantity * (1 - Discount)) AS AvgDiscountedQty
    FROM sales
    GROUP BY SalesPersonID
),
lsp AS (
    SELECT ProductID, MAX(SalesDate) AS LastSaleOfProduct
    FROM sales
    GROUP BY ProductID
),
pss AS (
    SELECT ProductID, DATEDIFF(MAX(SalesDate), MIN(SalesDate)) AS ProductSaleSpanDays
    FROM sales
    GROUP BY ProductID
),
fp AS (
    SELECT ProductID
    FROM sales
    WHERE SalesDate >= '2018-01-01' AND SalesDate < '2019-01-01'
    GROUP BY ProductID
    HAVING COUNT(*) > 5
)

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

    tcs.TotalCustomerSales,
    adq.AvgDiscountedQty,
    lsp.LastSaleOfProduct,
    pss.ProductSaleSpanDays

FROM (
    SELECT *
    FROM sales FORCE INDEX (idx_discount_quantity_product, idx_salesperson_salesdate)
    WHERE Discount > 0 AND Quantity > 5
) AS s

JOIN fp ON s.ProductID = fp.ProductID
LEFT JOIN tcs ON tcs.CustomerID = s.CustomerID
LEFT JOIN adq ON adq.SalesPersonID = s.SalesPersonID
LEFT JOIN lsp ON lsp.ProductID = s.ProductID
LEFT JOIN pss ON pss.ProductID = s.ProductID

ORDER BY 
    s.SalesPersonID DESC,
    s.SalesDate ASC;

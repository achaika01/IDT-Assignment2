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

WITH TEMPORARY TABLES:

CREATE DATABASE IF NOT EXISTS P04_OPT;
USE P04_OPT;


CREATE INDEX idx_discount_quantity_product ON sales(Discount, Quantity, ProductID);
CREATE INDEX idx_product_salesdate ON sales(ProductID, SalesDate);
CREATE INDEX idx_salesperson_salesdate ON sales(SalesPersonID DESC, SalesDate ASC);

CREATE INDEX customerID_ind ON sales(CustomerID);
CREATE INDEX sales_personID_ind ON sales(SalesPersonID);
CREATE INDEX productID_ind ON sales(ProductID);


CREATE TEMPORARY TABLE tcs AS
SELECT CustomerID, COUNT(*) AS TotalCustomerSales
FROM sales
GROUP BY CustomerID;

CREATE TEMPORARY TABLE adq AS
SELECT SalesPersonID, AVG(Quantity * (1 - Discount)) AS AvgDiscountedQty
FROM sales
GROUP BY SalesPersonID;

CREATE TEMPORARY TABLE lsp AS
SELECT ProductID, MAX(SalesDate) AS LastSaleOfProduct
FROM sales
GROUP BY ProductID;

CREATE TEMPORARY TABLE pss AS
SELECT ProductID, DATEDIFF(MAX(SalesDate), MIN(SalesDate)) AS ProductSaleSpanDays
FROM sales
WHERE SalesDate != '' AND SalesDate IS NOT NULL
GROUP BY ProductID;

CREATE TEMPORARY TABLE fp AS
SELECT ProductID
FROM sales
WHERE SalesDate >= '2018-01-01' AND SalesDate < '2019-01-01'
GROUP BY ProductID
HAVING COUNT(*) > 5;

--  EXPLAIN ANALYZE
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

FROM sales s
JOIN fp ON fp.ProductID = s.ProductID
LEFT JOIN tcs ON tcs.CustomerID = s.CustomerID
LEFT JOIN adq ON adq.SalesPersonID = s.SalesPersonID
LEFT JOIN lsp ON lsp.ProductID = s.ProductID
LEFT JOIN pss ON pss.ProductID = s.ProductID

WHERE s.Discount > 0 AND s.Quantity > 5

ORDER BY 
    s.SalesPersonID DESC,
    s.SalesDate ASC;
EXPLAIN ANLYZE:
    -> Sort: s.SalesPersonID DESC, s.SalesDate  (actual time=988147..988295 rows=1.08e+6 loops=1)
        -> Stream results  (cost=1.48e+15 rows=14.8e+15) (actual time=985058..986400 rows=1.08e+6 loops=1)
            -> Left hash join (pss.ProductID = fp.ProductID)  (cost=1.48e+15 rows=14.8e+15) (actual time=985058..985844 rows=1.08e+6 loops=1)
                -> Left hash join (lsp.ProductID = fp.ProductID)  (cost=3.27e+12 rows=32.7e+12) (actual time=985058..985691 rows=1.08e+6 loops=1)
                    -> Left hash join (adq.SalesPersonID = s.SalesPersonID)  (cost=5.55e+9 rows=55.5e+9) (actual time=985057..985536 rows=1.08e+6 loops=1)
                        -> Left hash join (tcs.CustomerID = s.CustomerID)  (cost=241e+6 rows=2.41e+9) (actual time=985057..985376 rows=1.08e+6 loops=1)
                            -> Nested loop inner join  (cost=209526 rows=24325) (actual time=0.908..982188 rows=1.08e+6 loops=1)
                                -> Filter: (fp.ProductID is not null)  (cost=45.5 rows=452) (actual time=0.0311..2.8 rows=452 loops=1)
                                    -> Table scan on fp  (cost=45.5 rows=452) (actual time=0.0298..2.24 rows=452 loops=1)
                                -> Filter: ((s.Discount > 0) and (s.Quantity > 5))  (cost=421 rows=53.8) (actual time=0.589..2173 rows=2392 loops=452)
                                    -> Index lookup on s using idx_product_salesdate (ProductID=fp.ProductID)  (cost=421 rows=421) (actual time=0.0803..2163 rows=14952 loops=452)
                            -> Hash
                                -> Table scan on tcs  (cost=0.533 rows=99151) (actual time=0.0158..74 rows=98759 loops=1)
                        -> Hash
                            -> Table scan on adq  (cost=438e-6 rows=23) (actual time=0.0385..0.0533 rows=23 loops=1)
                    -> Hash
                        -> Table scan on lsp  (cost=0.00135 rows=590) (actual time=0.0076..0.281 rows=452 loops=1)
                -> Hash
                    -> Table scan on pss  (cost=648e-6 rows=452) (actual time=0.004..0.259 rows=452 loops=1)

![image](https://github.com/user-attachments/assets/4b419943-8ba3-4b4f-a26e-b27c787922da)

LET'S FILTER DATA FIRST:
WITH
filtered_sales AS (
    SELECT *
    FROM sales
    WHERE Discount > 0 AND Quantity > 5
),

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

FROM filtered_sales s
JOIN fp ON s.ProductID = fp.ProductID
LEFT JOIN tcs ON tcs.CustomerID = s.CustomerID
LEFT JOIN adq ON adq.SalesPersonID = s.SalesPersonID
LEFT JOIN lsp ON lsp.ProductID = s.ProductID
LEFT JOIN pss ON pss.ProductID = s.ProductID

ORDER BY 
    s.SalesPersonID DESC,
    s.SalesDate ASC;

EXPLAIN ANALYZE:
-> Nested loop left join  (cost=160e+21 rows=1.6e+24) (actual time=79404..84684 rows=1.08e+6 loops=1)
-> Nested loop left join  (cost=10e+18 rows=100e+18) (actual time=79400..83818 rows=1.08e+6 loops=1)
    -> Nested loop inner join  (cost=633e+12 rows=6.31e+15) (actual time=79395..82961 rows=1.08e+6 loops=1)
        -> Nested loop left join  (cost=1.46e+12 rows=13.9e+12) (actual time=71373..74106 rows=1.08e+6 loops=1)
            -> Nested loop left join  (cost=66.3e+9 rows=663e+9) (actual time=14396..16444 rows=1.08e+6 loops=1)
                -> Sort: SalesPersonID DESC, SalesDate  (cost=716888 rows=6.71e+6) (actual time=9201..9368 rows=1.08e+6 loops=1)
                    -> Filter: ((sales.Discount > 0) and (sales.Quantity > 5) and (sales.ProductID is not null))  (cost=716888 rows=6.71e+6) (actual time=0.4..7660 rows=1.08e+6 loops=1)
                        -> Table scan on sales  (cost=716888 rows=6.71e+6) (actual time=0.381..7151 rows=6.76e+6 loops=1)
                -> Index lookup on tcs using <auto_key0> (CustomerID=sales.CustomerID)  (cost=1.4e+6..1.4e+6 rows=10) (actual time=0.00626..0.00641 rows=1 loops=1.08e+6)
                    -> Materialize CTE tcs  (cost=1.4e+6..1.4e+6 rows=98913) (actual time=5195..5195 rows=98759 loops=1)
                        -> Group aggregate: count(0)  (cost=1.39e+6 rows=98913) (actual time=5.66..5080 rows=98759 loops=1)
                            -> Covering index scan on sales using customerID_ind  (cost=716888 rows=6.71e+6) (actual time=5.58..4740 rows=6.76e+6 loops=1)
            -> Index lookup on adq using <auto_key0> (SalesPersonID=sales.SalesPersonID)  (cost=1.39e+6..1.39e+6 rows=10) (actual time=0.0531..0.0532 rows=1 loops=1.08e+6)
                -> Materialize CTE adq  (cost=1.39e+6..1.39e+6 rows=21) (actual time=56978..56978 rows=23 loops=1)
                    -> Group aggregate: avg((sales.Quantity * (1 - sales.Discount)))  (cost=1.39e+6 rows=21) (actual time=2470..56977 rows=23 loops=1)
                        -> Index scan on sales using sales_personID_ind  (cost=716888 rows=6.71e+6) (actual time=0.65..55858 rows=6.76e+6 loops=1)
        -> Covering index lookup on fp using <auto_key0> (ProductID=sales.ProductID)  (cost=791445..791447 rows=10) (actual time=0.00794..0.00806 rows=1 loops=1.08e+6)
            -> Materialize CTE fp  (cost=791445..791445 rows=453) (actual time=8021..8021 rows=452 loops=1)
                -> Filter: (count(0) > 5)  (cost=791400 rows=453) (actual time=20.6..8017 rows=452 loops=1)
                    -> Group aggregate: count(0)  (cost=791400 rows=453) (actual time=20.6..8016 rows=452 loops=1)
                        -> Filter: ((sales.SalesDate >= '2018-01-01') and (sales.SalesDate < '2019-01-01'))  (cost=716888 rows=745121) (actual time=0.47..7678 rows=6.69e+6 loops=1)
                            -> Covering index scan on sales using idx_product_salesdate  (cost=716888 rows=6.71e+6) (actual time=0.345..6034 rows=6.76e+6 loops=1)
    -> Index lookup on lsp using <auto_key0> (ProductID=sales.ProductID)  (cost=24314..24316 rows=10) (actual time=533e-6..659e-6 rows=1 loops=1.08e+6)
        -> Materialize CTE lsp  (cost=24313..24313 rows=15921) (actual time=5.03..5.03 rows=452 loops=1)
            -> Covering index skip scan for grouping on sales using idx_product_salesdate  (cost=22721 rows=15921) (actual time=0.383..4.66 rows=452 loops=1)
-> Index lookup on pss using <auto_key0> (ProductID=sales.ProductID)  (cost=24315..24317 rows=10) (actual time=514e-6..645e-6 rows=1 loops=1.08e+6)
    -> Materialize CTE pss  (cost=24314..24314 rows=15921) (actual time=3.62..3.62 rows=452 loops=1)
        -> Covering index skip scan for grouping on sales using idx_product_salesdate  (cost=22722 rows=15921) (actual time=0.0262..2.8 rows=452 loops=1)

![image](https://github.com/user-attachments/assets/d6cf1858-de2f-4f83-9c74-11d100d0ac3f)








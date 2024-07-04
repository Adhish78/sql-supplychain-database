-- List products with their total sales amount. (Example of Common Table Expression (CTE))
WITH ProductSales AS (
    SELECT 
        ProductID,
        SUM(TotalAmount) AS TotalSales
    FROM retail_supply_chain.Sales
    GROUP BY ProductID
)
SELECT 
    p.Name,
    ps.TotalSales
FROM retail_supply_chain.Products p
JOIN ProductSales ps ON p.ProductID = ps.ProductID;


-- -- Calculate the cumulative quantity of stock over shipments.
WITH CumulativeShipments AS (
    SELECT 
        si.ShipmentID,
        si.ProductID,
        si.Quantity,
        si.Quantity AS CumulativeQuantity
    FROM retail_supply_chain.ShipmentItems si

    UNION ALL

    SELECT 
        si.ShipmentID,
        si.ProductID,
        si.Quantity,
        cs.CumulativeQuantity + si.Quantity
    FROM retail_supply_chain.ShipmentItems si
    INNER JOIN CumulativeShipments cs 
    ON si.ProductID = cs.ProductID 
    AND si.ShipmentID > cs.ShipmentID
    WHERE si.ShipmentID = cs.ShipmentID + 1
)
SELECT 
    ShipmentID,
    ProductID,
    CumulativeQuantity
FROM CumulativeShipments
ORDER BY ProductID, ShipmentID;


-- Calculate running total sales for each product. (Example of Window Function)
SELECT
    SaleID,
    ProductID,
    SaleDate,
    Quantity,
    TotalAmount,
    SUM(TotalAmount) OVER (PARTITION BY ProductID ORDER BY SaleDate) AS RunningTotal
FROM retail_supply_chain.Sales;


-- Pivot total sales amount by product categories. (Example of Pivoting Data with CASE WHEN)
SELECT
    SaleDate,
    SUM(CASE WHEN p.Category = 'Clothing' THEN s.TotalAmount ELSE 0 END) AS ClothingSales,
    SUM(CASE WHEN p.Category = 'Home' THEN s.TotalAmount ELSE 0 END) AS HomeSales
FROM retail_supply_chain.Sales s
JOIN retail_supply_chain.Products p ON s.ProductID = p.ProductID
GROUP BY SaleDate;


-- -- Find products that have never been ordered.
SELECT p.ProductID, p.Name
FROM retail_supply_chain.Products p
EXCEPT
SELECT oi.ProductID, p.Name
FROM retail_supply_chain.OrderItems oi
JOIN retail_supply_chain.Products p ON oi.ProductID = p.ProductID;


-- -- Find duplicate shipments from the same supplier to the same warehouse on the same date. (Example of Self Join)
SELECT 
    s1.ShipmentID AS ShipmentID1,
    s2.ShipmentID AS ShipmentID2,
    s1.SupplierID,
    s1.WarehouseID,
    s1.ShipmentDate
FROM retail_supply_chain.Shipments s1
JOIN retail_supply_chain.Shipments s2 ON 
    s1.SupplierID = s2.SupplierID AND 
    s1.WarehouseID = s2.WarehouseID AND 
    s1.ShipmentDate = s2.ShipmentDate AND 
    s1.ShipmentID < s2.ShipmentID;


-- Rank products by total sales amount. (Example of Rank versus Dense Rank versus Row Number)
WITH ProductSales AS (
    SELECT 
        ProductID,
        SUM(TotalAmount) AS TotalSales
    FROM retail_supply_chain.Sales
    GROUP BY ProductID
)
SELECT 
    ProductID,
    TotalSales,
    RANK() OVER (ORDER BY TotalSales DESC) AS SalesRank,
    DENSE_RANK() OVER (ORDER BY TotalSales DESC) AS SalesDenseRank,
    ROW_NUMBER() OVER (ORDER BY TotalSales DESC) AS SalesRowNumber
FROM ProductSales;


-- -- Calculate month-over-month sales change.
WITH MonthlySales AS (
    SELECT 
        DATEFROMPARTS(YEAR(SaleDate), MONTH(SaleDate), 1) AS Month,
        SUM(TotalAmount) AS MonthlyTotal
    FROM retail_supply_chain.Sales
    GROUP BY DATEFROMPARTS(YEAR(SaleDate), MONTH(SaleDate), 1)
)
SELECT 
    Month,
    MonthlyTotal,
    MonthlyTotal - LAG(MonthlyTotal, 1, 0) OVER (ORDER BY Month) AS MonthlyChange
FROM MonthlySales
ORDER BY Month;


-- Calculate running totals of stock for each product in each warehouse.
SELECT
    WarehouseID,
    ProductID,
    Quantity,
    SUM(Quantity) OVER (PARTITION BY WarehouseID, ProductID ORDER BY Quantity) AS RunningTotal
FROM retail_supply_chain.Stock;


-- -- Get orders placed in the last 30 days.
SELECT 
    OrderID,
    OrderDate,
    CustomerName,
    CustomerAddress
FROM retail_supply_chain.Orders
WHERE OrderDate >= DATEADD(DAY, -30, GETDATE());


-- -- Find the total number of orders and the total quantity of items ordered for each customer.
SELECT
    o.CustomerName,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    SUM(oi.Quantity) AS TotalQuantityOrdered
FROM retail_supply_chain.Orders o
JOIN retail_supply_chain.OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.CustomerName;


-- Calculate the rolling average sales amount for the last 3 days.
SELECT
    SaleDate,
    ProductID,
    TotalAmount,
    AVG(TotalAmount) OVER (PARTITION BY ProductID ORDER BY SaleDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS RollingAvg3Days
FROM retail_supply_chain.Sales;


-- -- Find the top 3 products by sales amount in each category.
WITH ProductSales AS (
    SELECT 
        p.ProductID,
        p.Name,
        p.Category,
        SUM(s.TotalAmount) AS TotalSales
    FROM retail_supply_chain.Sales s
    JOIN retail_supply_chain.Products p ON s.ProductID = p.ProductID
    GROUP BY p.ProductID, p.Name, p.Category
),
RankedProductSales AS (
    SELECT
        ProductID,
        Name,
        Category,
        TotalSales,
        RANK() OVER (PARTITION BY Category ORDER BY TotalSales DESC) AS SalesRank
    FROM ProductSales
)
SELECT
    ProductID,
    Name,
    Category,
    TotalSales
FROM RankedProductSales
WHERE SalesRank <= 3;


-- -- Compare sales in the current quarter to the previous quarter. (Example of Interval Comparisons)
WITH QuarterlySales AS (
    SELECT
        DATEPART(QUARTER, SaleDate) AS Quarter,
        DATEPART(YEAR, SaleDate) AS Year,
        SUM(TotalAmount) AS QuarterlyTotal
    FROM retail_supply_chain.Sales
    GROUP BY DATEPART(YEAR, SaleDate), DATEPART(QUARTER, SaleDate)
),
CurrentAndPreviousQuarters AS (
    SELECT
        Quarter,
        Year,
        QuarterlyTotal,
        LAG(QuarterlyTotal) OVER (ORDER BY Year, Quarter) AS PreviousQuarterTotal
    FROM QuarterlySales
)
SELECT
    Year,
    Quarter,
    QuarterlyTotal,
    PreviousQuarterTotal,
    ISNULL(QuarterlyTotal - PreviousQuarterTotal, 0) AS Delta
FROM CurrentAndPreviousQuarters;


-- -- Find customers who have placed orders exceeding the average order amount.
WITH OrderTotals AS (
    SELECT 
        o.CustomerName,
        o.OrderID,
        SUM(oi.Quantity * oi.Price) AS OrderTotal
    FROM retail_supply_chain.Orders o
    JOIN retail_supply_chain.OrderItems oi ON o.OrderID = oi.OrderID
    GROUP BY o.CustomerName, o.OrderID
),
AvgOrderTotal AS (
    SELECT 
        AVG(OrderTotal) AS AvgOrderTotal
    FROM OrderTotals
)
SELECT 
    ot.CustomerName,
    ot.OrderID,
    ot.OrderTotal,
    avg.AvgOrderTotal
FROM OrderTotals ot
CROSS JOIN AvgOrderTotal avg
WHERE ot.OrderTotal > avg.AvgOrderTotal;


-- List all products and the total quantity available in all warehouses.
SELECT 
    p.ProductID,
    p.Name,
    p.Category,
    SUM(s.Quantity) AS TotalQuantityAvailable
FROM retail_supply_chain.Products p
LEFT JOIN retail_supply_chain.Stock s ON p.ProductID = s.ProductID
GROUP BY p.ProductID, p.Name, p.Category;


-- Calculate the cumulative sales amount for each product over time.
SELECT 
    SaleDate,
    ProductID,
    TotalAmount,
    SUM(TotalAmount) OVER (PARTITION BY ProductID ORDER BY SaleDate) AS CumulativeSales
FROM retail_supply_chain.Sales
ORDER BY ProductID, SaleDate;


-- Find all shipments, including the products and quantities shipped, along with supplier information.
SELECT 
    s.ShipmentID,
    s.ShipmentDate,
    p.ProductID,
    p.Name AS ProductName,
    si.Quantity,
    sup.SupplierID,
    sup.Name AS SupplierName,
    sup.ContactName
FROM retail_supply_chain.Shipments s
JOIN retail_supply_chain.ShipmentItems si ON s.ShipmentID = si.ShipmentID
JOIN retail_supply_chain.Products p ON si.ProductID = p.ProductID
JOIN retail_supply_chain.Suppliers sup ON s.SupplierID = sup.SupplierID
ORDER BY s.ShipmentID;

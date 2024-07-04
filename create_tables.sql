CREATE SCHEMA retail_supply_chain;

CREATE TABLE retail_supply_chain.Products (
    ProductID INT PRIMARY KEY,
    Name VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10, 2)
);

CREATE TABLE retail_supply_chain.Suppliers (
    SupplierID INT PRIMARY KEY,
    Name VARCHAR(100),
    ContactName VARCHAR(100),
    ContactEmail VARCHAR(100)
);

CREATE TABLE retail_supply_chain.Warehouses (
    WarehouseID INT PRIMARY KEY,
    Location VARCHAR(100),
    Capacity INT
);

CREATE TABLE retail_supply_chain.Stock (
    WarehouseID INT,
    ProductID INT,
    Quantity INT,
    PRIMARY KEY (WarehouseID, ProductID),
    FOREIGN KEY (WarehouseID) REFERENCES retail_supply_chain.Warehouses(WarehouseID),
    FOREIGN KEY (ProductID) REFERENCES retail_supply_chain.Products(ProductID)
);

CREATE TABLE retail_supply_chain.Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    CustomerName VARCHAR(100),
    CustomerAddress VARCHAR(100)
);

CREATE TABLE retail_supply_chain.OrderItems (
    OrderItemID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES retail_supply_chain.Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES retail_supply_chain.Products(ProductID)
);

CREATE TABLE retail_supply_chain.Shipments (
    ShipmentID INT PRIMARY KEY,
    SupplierID INT,
    WarehouseID INT,
    ShipmentDate DATE,
    FOREIGN KEY (SupplierID) REFERENCES retail_supply_chain.Suppliers(SupplierID),
    FOREIGN KEY (WarehouseID) REFERENCES retail_supply_chain.Warehouses(WarehouseID)
);

CREATE TABLE retail_supply_chain.ShipmentItems (
    ShipmentItemID INT PRIMARY KEY,
    ShipmentID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (ShipmentID) REFERENCES retail_supply_chain.Shipments(ShipmentID),
    FOREIGN KEY (ProductID) REFERENCES retail_supply_chain.Products(ProductID)
);

CREATE TABLE retail_supply_chain.Sales (
    SaleID INT PRIMARY KEY,
    SaleDate DATE,
    ProductID INT,
    Quantity INT,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (ProductID) REFERENCES retail_supply_chain.Products(ProductID)
);

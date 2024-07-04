# Supply Chain & Logistics Planning Database Management System

## Project Overview
This project aims to simulate a database management system for a large retailer. The database is designed to manage various aspects of supply chain and logistics, including products, suppliers, warehouses, stock management, orders, shipments, and sales. The database schema and sample data provided facilitate advanced SQL queries for analysis and reporting purposes.

## Table of Contents

- [Project Overview](#project-overview)
- [Database Schema](#database-schema)
- [Sample Data](#sample-data)
- [Project Structure](#project-structure)
- [How to Use](#how-to-use)
- [Examples of Queries](#examples-of-queries)
- [Contributing](#contributing)
- [License](#license)


## Database Schema

### Products
- `ProductID`: INT, Primary Key. Unique identifier for each product.
- `Name`: VARCHAR(100). Name of the product.
- `Category`: VARCHAR(50). Category of the product (e.g., Clothing, Home).
- `Price`: DECIMAL(10, 2). Price of the product.

### Suppliers
- `SupplierID`: INT, Primary Key. Unique identifier for each supplier.
- `Name`: VARCHAR(100). Name of the supplier.
- `ContactName`: VARCHAR(100). Contact name of the supplier.
- `ContactEmail`: VARCHAR(100). Email address of the supplier.

### Warehouses
- `WarehouseID`: INT, Primary Key. Unique identifier for each warehouse.
- `Location`: VARCHAR(100). Location of the warehouse.
- `Capacity`: INT. Capacity of the warehouse in terms of stock units.

### Stock
- `WarehouseID`: INT, Foreign Key referencing Warehouses(WarehouseID).
- `ProductID`: INT, Foreign Key referencing Products(ProductID).
- `Quantity`: INT. Quantity of the product available in the warehouse.
- **Primary Key**: (WarehouseID, ProductID).

### Orders
- `OrderID`: INT, Primary Key. Unique identifier for each order.
- `OrderDate`: DATE. Date when the order was placed.
- `CustomerName`: VARCHAR(100). Name of the customer placing the order.
- `CustomerAddress`: VARCHAR(100). Address to which the order will be shipped.

### OrderItems
- `OrderItemID`: INT, Primary Key. Unique identifier for each order item.
- `OrderID`: INT, Foreign Key referencing Orders(OrderID).
- `ProductID`: INT, Foreign Key referencing Products(ProductID).
- `Quantity`: INT. Quantity of the product ordered.
- `Price`: DECIMAL(10, 2). Price of the product at the time of order.

### Shipments
- `ShipmentID`: INT, Primary Key. Unique identifier for each shipment.
- `SupplierID`: INT, Foreign Key referencing Suppliers(SupplierID).
- `WarehouseID`: INT, Foreign Key referencing Warehouses(WarehouseID).
- `ShipmentDate`: DATE. Date when the shipment was made.

### ShipmentItems
- `ShipmentItemID`: INT, Primary Key. Unique identifier for each shipment item.
- `ShipmentID`: INT, Foreign Key referencing Shipments(ShipmentID).
- `ProductID`: INT, Foreign Key referencing Products(ProductID).
- `Quantity`: INT. Quantity of the product shipped.

### Sales
- `SaleID`: INT, Primary Key. Unique identifier for each sale.
- `SaleDate`: DATE. Date when the sale was made.
- `ProductID`: INT, Foreign Key referencing Products(ProductID).
- `Quantity`: INT. Quantity of the product sold.
- `TotalAmount`: DECIMAL(10, 2). Total amount of the sale.

## Sample Data

Sample data has been populated in the tables to facilitate testing and analysis. Here are some details of the sample data:
- Products: Includes various products with their categories and prices.
- Suppliers: Details of suppliers providing products to the retailer.
- Warehouses: Warehouse locations with their respective capacities for product storage.
- Stock: Quantity of each product available in each warehouse.
- Orders: Information about customer orders including order date and delivery address.
- OrderItems: Products included in each order along with quantities and prices.
- Shipments: Details of shipments from suppliers to warehouses.
- ShipmentItems: Products included in each shipment along with quantities.
- Sales: Records of product sales including sales date, customer ID, product ID, and sales amount.

## Project Structure

The project repository is structured as follows:
```
    sql-ecommerce-database/
    │
    ├── create_tables.sql       # SQL script to create tables
    ├── insert_data.sql         # SQL script to insert sample data
    ├── queries.sql             # SQL script with all the advanced queries
    ├── README.md               # Project overview and documentation
    └── screenshots/            # Folder containing screenshots of query results
        ├── q1.png
        ├── q2.png
        └── ...
```

## How to Use

To set up the database:

1. Execute `create_tables.sql` to create the database schema.
2. Execute `insert_data.sql` to populate the tables with sample data.

To run queries:

1. Execute the queries in `queries.sql` to analyze different aspects of the database.

## Examples of Queries

Here are examples of the SQL queries included:

- List products with their total sales amount. (Example of Common Table Expression (CTE))
- Calculate the cumulative quantity of stock over shipments.
- Calculate running total sales for each product. (Example of Window Function)
- Pivot total sales amount by product categories. (Example of Pivoting Data with CASE WHEN)
- Find products that have never been ordered.
- Find duplicate shipments from the same supplier to the same warehouse on the same date. (Example of Self Join)
- Rank products by total sales amount. (Example of Rank versus Dense Rank versus Row Number)
- Calculate month-over-month sales change.
- Calculate running totals of stock for each product in each warehouse.
- Get orders placed in the last 30 days.
- Find the total number of orders and the total quantity of items ordered for each customer.
- Calculate the rolling average sales amount for the last 3 days.
- Find the top 3 products by sales amount in each category.
- Compare sales in the current quarter to the previous quarter. (Example of Interval Comparisons)
- Find customers who have placed orders exceeding the average order amount.
- List all products and the total quantity available in all warehouses.
- Calculate the cumulative sales amount for each product over time.
- Find all shipments, including the products and quantities shipped, along with supplier information.

## Contributing

Feel free to contribute to this project by suggesting improvements, optimizing queries, or adding new features. Fork the repository, make your changes, and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/Adhish78/sql-supplychain-database/blob/main/LICENSE) file for details.

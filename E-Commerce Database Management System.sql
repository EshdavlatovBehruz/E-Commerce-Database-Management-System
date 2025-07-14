-- Customers
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100),
    Email NVARCHAR(100),
    Phone NVARCHAR(20),
    Address NVARCHAR(255)
);

-- Products
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100),
    Category NVARCHAR(100),
    Price DECIMAL(10, 2),
    StockQuantity INT
);

-- Orders
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY,
    CustomerID INT,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- OrderItems
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY IDENTITY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Transactions
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY,
    OrderID INT,
    PaymentAmount DECIMAL(10, 2),
    PaymentDate DATE,
    Status NVARCHAR(50),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);


INSERT INTO Customers (Name, Email, Phone, Address) VALUES
('Ali Valiyev', 'ali@mail.com', '+998901234567', 'Toshkent'),
('Gulnoza Karimova', 'gulnoza@mail.com', '+998931112233', 'Samarqand'),
('Javlonbek Usmonov', 'javlon@mail.com', '+998941112233', 'Fargona'),
('Dilshod Ganiev', 'dilshod@mail.com', '+998901110000', 'Andijon'),
('Madina Rajabova', 'madina@mail.com', '+998902223344', 'Buxoro'),
('Bolta Jamshidov', 'tesha_yoraman@mail.com', '+998935529124', 'Xorazm'),
('Sharofat Mallayev', 'shora@mail.com', '+998904445464', 'Jizzax'),
('Kamol Sappayev', 'sappayev@mail.com', '+998880013415', 'Surxandaryo'),
('Nasiba Karimova', 'haromi@mail.com', '+998998453125', 'Navoiy'),
('Behruz Eshdavlatov', 'behruz2005zz@mail.com', '+998946011106', 'Qashqadaryo');

INSERT INTO Products (Name, Category, Price, StockQuantity) VALUES
('Monitor LG 24"', 'Electronics', 200.00, 20),
('Keyboard Logitech', 'Accessories', 35.00, 40),
('Bluetooth Speaker JBL', 'Electronics', 120.00, 25),
('Power Bank 10000mAh', 'Accessories', 25.00, 60),
('External HDD 1TB', 'Electronics', 85.00, 18),
('Webcam HD', 'Accessories', 45.00, 35),
('Wireless Charger', 'Accessories', 30.00, 28),
('Smartwatch Apple', 'Electronics', 350.00, 12),
('Tablet Samsung Galaxy Tab', 'Electronics', 300.00, 14),
('Laptop HP', 'Electronics', 850.00, 9),
('Smartphone iPhone 13', 'Electronics', 950.00, 11),
('VR Headset Oculus', 'Electronics', 400.00, 7),
('Gaming Chair', 'Accessories', 180.00, 10),
('Laptop Stand', 'Accessories', 20.00, 45),
('Router TP-Link', 'Electronics', 60.00, 33),
('Headphones Sony', 'Accessories', 70.00, 22),
('Mouse Pad RGB', 'Accessories', 15.00, 50),
('Microphone USB', 'Accessories', 55.00, 17),
('Printer HP LaserJet', 'Electronics', 220.00, 8),
('Projector Epson', 'Electronics', 500.00, 5);

INSERT INTO Orders (CustomerID, OrderDate) VALUES
(1, '2025-07-01'),
(2, '2025-07-02'),
(3, '2025-07-03'),
(4, '2025-07-04'),
(5, '2025-07-05');

INSERT INTO OrderItems (OrderID, ProductID, Quantity, Price) VALUES
(1, 1, 1, 900.00),       
(1, 4, 2, 10.00),        
(2, 2, 1, 750.00),       
(3, 5, 3, 40.00),        
(4, 3, 2, 150.00),       
(4, 10, 1, 850.00),      
(5, 6, 1, 200.00),    
(5, 8, 1, 120.00);       

INSERT INTO Transactions (OrderID, PaymentAmount, PaymentDate, Status) VALUES
(1, 920.00, '2025-07-01', 'Completed'),   
(2, 750.00, '2025-07-02', 'Completed'),
(3, 120.00, '2025-07-03', 'Completed'),    
(4, 1150.00, '2025-07-04', 'Completed'),   
(5, 320.00, '2025-07-05', 'Completed');    

-- Retrieve distinct customers who have placed at least one order 
SELECT c.Name, c.Email FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID


-- Retrieve top 5 most sold products based on quantity sold 
SELECT TOP 5 p.Name, SUM(oi.Quantity) AS TotalSold
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalSold DESC;


-- Calculate total revenue from all order items  
SELECT SUM(oi.Price * oi.Quantity) AS TotalRevenue
FROM OrderItems oi


-- Find customers without any orders 
SELECT c.Name FROM Customers c
WHERE c.CustomerID NOT IN (SELECT o.CustomerID FROM Orders o);


-- Display orders with customer names, order dates, and total amount per order
SELECT o.OrderID, c.Name AS Customer_name,
SUM(oi.Quantity * oi.Price) AS TotalAmount, o.OrderDate
FROM Orders o 
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, c.Name, o.OrderDate


-- Begin transaction to insert new order safely  
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @NewOrderID INT;
    INSERT INTO Orders (CustomerID, OrderDate) VALUES (6, GETDATE());
    SET @NewOrderID = SCOPE_IDENTITY();
    
    DECLARE @ProductID INT = 2;
    DECLARE @Quantity INT = 4;
    DECLARE @Price DECIMAL(10,2);
    SELECT @Price = Price FROM Products WHERE ProductID = @ProductID;

    INSERT INTO OrderItems (OrderID, ProductID, Quantity, Price)
    VALUES (@NewOrderID, @ProductID, @Quantity, @Price);

    UPDATE Products SET StockQuantity = StockQuantity - @Quantity WHERE ProductID = @ProductID;

    INSERT INTO Transactions (OrderID, PaymentAmount, PaymentDate, Status)
    VALUES (@NewOrderID, @Price * @Quantity, GETDATE(), 'Completed');

    COMMIT;
END TRY
BEGIN CATCH
    -- Rollback transaction if any error occurs  
    ROLLBACK;
END CATCH;


-- Create a view summarizing orders with customer name, date, and total amount
CREATE VIEW vw_OrderSummary AS
SELECT o.OrderID, c.Name, o.OrderDate,
    SUM(oi.Quantity * oi.Price) AS TotalAmount
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderItems oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderID, c.Name,  o.OrderDate;


--Result view
SELECT * FROM vw_OrderSummary;


-- Create indexes to optimize query performance  
CREATE INDEX idx_orders_customer ON Orders(CustomerID);
CREATE INDEX idx_transactions_status ON Transactions(Status);
CREATE INDEX idx_products_category ON Products(Category);


-- Generate monthly revenue report based on transactions 
SELECT FORMAT(PaymentDate, 'yyyy-MM') AS Monthly,
       SUM(PaymentAmount) AS MonthlyRevenue
FROM Transactions
WHERE Status = 'Completed'
GROUP BY FORMAT(PaymentDate, 'yyyy-MM')
ORDER BY Monthly;


-- Generate sales distribution report grouped by product category 
SELECT p.Category, SUM(oi.Price * oi.Quantity) AS Result_Total
FROM OrderItems oi
JOIN Products p ON oi.ProductID = p.ProductID
GROUP BY p.Category
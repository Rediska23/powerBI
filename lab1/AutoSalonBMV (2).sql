USE master;
GO

-- Удаление базы, если она существует
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'AutoSalonBMV')
BEGIN
    ALTER DATABASE AutoSalonBMV SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AutoSalonBMV;
END
GO

-- Создание новой базы
CREATE DATABASE AutoSalonBMV;
GO

USE AutoSalonBMV;
GO

-- Таблица "Автомобиль"
CREATE TABLE Car (
    CarID INT PRIMARY KEY IDENTITY(1,1), 
    Brand NVARCHAR(50) NOT NULL,       
    Model NVARCHAR(50) NOT NULL,
    Color NVARCHAR(20) NOT NULL,
    Year INT  NOT NULL,
    Mileage INT NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    InStock BIT                           
);
GO

-- Таблица "Поставщик"
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY IDENTITY(1,1), 
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200) NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    ContactPerson NVARCHAR(100) NOT NULL
);
GO

-- Таблица "Клиент"
CREATE TABLE Client (
    ClientID INT PRIMARY KEY IDENTITY(1,1), 
    LastName NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50),
    Address NVARCHAR(200) NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    Passport NVARCHAR(20) UNIQUE NOT NULL
);
GO

-- Таблица "Заявка"
CREATE TABLE Request (
    RequestID INT PRIMARY KEY IDENTITY(1,1),
    ClientID INT,
    CarID INT,
    DateTime DATETIME DEFAULT GETDATE(),    
    Status NVARCHAR(20) CHECK (Status IN ('новая', 'подтвержденная', 'отклоненная')),
    Type NVARCHAR(20) CHECK (Type IN ('покупка', 'обмен')),
    FOREIGN KEY (ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE,
    FOREIGN KEY (CarID) REFERENCES Car(CarID) ON DELETE SET NULL
);
GO

-- Таблица "Заказ поставщику"
CREATE TABLE SupplierOrder (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    SupplierID INT,
    CarID INT,
    DateTime DATETIME DEFAULT GETDATE(),  
    Status NVARCHAR(20) CHECK (Status IN ('новый', 'выполненный', 'отмененный')),
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID) ON DELETE CASCADE,
    FOREIGN KEY (CarID) REFERENCES Car(CarID) ON DELETE SET NULL
);
GO

-- 1. Добавление автомобилей
INSERT INTO Car (Brand, Model, Color, Year, Mileage, Price, InStock)
VALUES 
    (N'Toyota', N'Camry', N'Красный', 2020, 15000, 25000.00, 1),
    (N'BMW', N'X5', N'Черный', 2022, 5000, 60000.00, 1),
    (N'Audi', N'A4', N'Белый', 2019, 30000, 28000.00, 0);

-- 2. Добавление поставщиков
INSERT INTO Supplier (Name, Address, Phone, ContactPerson)
VALUES 
    (N'АвтоМир', N'Москва, ул. Ленина, 1', N'+7-999-123-45-67', N'Иванов Иван'),
    (N'ЕвроАвто', N'Санкт-Петербург, Невский пр., 100', N'+7-911-222-33-44', N'Петрова Мария');

-- 3. Добавление клиентов
INSERT INTO Client (LastName, FirstName, MiddleName, Address, Phone, Passport)
VALUES 
    (N'Иванов', N'Петр', N'Сергеевич', N'Москва, ул. Пушкина, 10', N'+7-495-111-22-33', N'4508123456'),
    (N'Сидорова', N'Анна', NULL, N'Казань, ул. Гагарина, 5', N'+7-843-444-55-66', N'4510987654');

-- 4. Добавление заявок
INSERT INTO Request (ClientID, CarID, Status, Type)
VALUES 
    (1, 1, N'новая', N'покупка'),
    (2, 3, N'подтвержденная', N'обмен');

-- 5. Добавление заказов
INSERT INTO SupplierOrder (SupplierID, CarID, Status)
VALUES 
    (1, 2, N'новый'),
    (2, 3, N'выполненный');

--------------------------------------------
-- Проверочные запросы:
--------------------------------------------

-- 1. Все автомобили в наличии
SELECT Brand, Model, Price 
FROM Car 
WHERE InStock = 1;

-- 2. Клиенты из Москвы
SELECT LastName, FirstName, Phone 
FROM Client 
WHERE Address LIKE N'%Москва%';

-- 3. Заявки с статусом "новая"
SELECT RequestID, DateTime, Status 
FROM Request 
WHERE Status = N'новая';

-- 4. Заказы, выполненные за последний месяц
SELECT OrderID, DateTime, Status 
FROM SupplierOrder 
WHERE Status = N'выполненный' 
  AND DateTime >= DATEADD(MONTH, -1, GETDATE());

-- 5. Общая стоимость автомобилей в наличии
SELECT SUM(Price) AS TotalPrice 
FROM Car 
WHERE InStock = 1;

-- 6. Все данные о заявках (с именем клиента и маркой авто)
SELECT 
    R.RequestID,
    C.LastName + ' ' + C.FirstName AS ClientName,
    Car.Brand + ' ' + Car.Model AS Car,
    R.DateTime,
    R.Status
FROM Request R
JOIN Client C ON R.ClientID = C.ClientID
JOIN Car ON R.CarID = Car.CarID;

-- 7. Поставщики и их активные заказы
SELECT 
    S.Name AS Supplier,
    SO.DateTime AS OrderDate,
    SO.Status
FROM SupplierOrder SO
JOIN Supplier S ON SO.SupplierID = S.SupplierID;
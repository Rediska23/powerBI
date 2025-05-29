USE master;
GO

-- �������� ����, ���� ��� ����������
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'AutoSalonBMV')
BEGIN
    ALTER DATABASE AutoSalonBMV SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AutoSalonBMV;
END
GO

-- �������� ����� ����
CREATE DATABASE AutoSalonBMV;
GO

USE AutoSalonBMV;
GO

-- ������� "����������"
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

-- ������� "���������"
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY IDENTITY(1,1), 
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200) NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    ContactPerson NVARCHAR(100) NOT NULL
);
GO

-- ������� "������"
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

-- ������� "������"
CREATE TABLE Request (
    RequestID INT PRIMARY KEY IDENTITY(1,1),
    ClientID INT,
    CarID INT,
    DateTime DATETIME DEFAULT GETDATE(),    
    Status NVARCHAR(20) CHECK (Status IN ('�����', '��������������', '�����������')),
    Type NVARCHAR(20) CHECK (Type IN ('�������', '�����')),
    FOREIGN KEY (ClientID) REFERENCES Client(ClientID) ON DELETE CASCADE,
    FOREIGN KEY (CarID) REFERENCES Car(CarID) ON DELETE SET NULL
);
GO

-- ������� "����� ����������"
CREATE TABLE SupplierOrder (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    SupplierID INT,
    CarID INT,
    DateTime DATETIME DEFAULT GETDATE(),  
    Status NVARCHAR(20) CHECK (Status IN ('�����', '�����������', '����������')),
    FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID) ON DELETE CASCADE,
    FOREIGN KEY (CarID) REFERENCES Car(CarID) ON DELETE SET NULL
);
GO

-- 1. ���������� �����������
INSERT INTO Car (Brand, Model, Color, Year, Mileage, Price, InStock)
VALUES 
    (N'Toyota', N'Camry', N'�������', 2020, 15000, 25000.00, 1),
    (N'BMW', N'X5', N'������', 2022, 5000, 60000.00, 1),
    (N'Audi', N'A4', N'�����', 2019, 30000, 28000.00, 0);

-- 2. ���������� �����������
INSERT INTO Supplier (Name, Address, Phone, ContactPerson)
VALUES 
    (N'�������', N'������, ��. ������, 1', N'+7-999-123-45-67', N'������ ����'),
    (N'��������', N'�����-���������, ������� ��., 100', N'+7-911-222-33-44', N'������� �����');

-- 3. ���������� ��������
INSERT INTO Client (LastName, FirstName, MiddleName, Address, Phone, Passport)
VALUES 
    (N'������', N'����', N'���������', N'������, ��. �������, 10', N'+7-495-111-22-33', N'4508123456'),
    (N'��������', N'����', NULL, N'������, ��. ��������, 5', N'+7-843-444-55-66', N'4510987654');

-- 4. ���������� ������
INSERT INTO Request (ClientID, CarID, Status, Type)
VALUES 
    (1, 1, N'�����', N'�������'),
    (2, 3, N'��������������', N'�����');

-- 5. ���������� �������
INSERT INTO SupplierOrder (SupplierID, CarID, Status)
VALUES 
    (1, 2, N'�����'),
    (2, 3, N'�����������');

--------------------------------------------
-- ����������� �������:
--------------------------------------------

-- 1. ��� ���������� � �������
SELECT Brand, Model, Price 
FROM Car 
WHERE InStock = 1;

-- 2. ������� �� ������
SELECT LastName, FirstName, Phone 
FROM Client 
WHERE Address LIKE N'%������%';

-- 3. ������ � �������� "�����"
SELECT RequestID, DateTime, Status 
FROM Request 
WHERE Status = N'�����';

-- 4. ������, ����������� �� ��������� �����
SELECT OrderID, DateTime, Status 
FROM SupplierOrder 
WHERE Status = N'�����������' 
  AND DateTime >= DATEADD(MONTH, -1, GETDATE());

-- 5. ����� ��������� ����������� � �������
SELECT SUM(Price) AS TotalPrice 
FROM Car 
WHERE InStock = 1;

-- 6. ��� ������ � ������� (� ������ ������� � ������ ����)
SELECT 
    R.RequestID,
    C.LastName + ' ' + C.FirstName AS ClientName,
    Car.Brand + ' ' + Car.Model AS Car,
    R.DateTime,
    R.Status
FROM Request R
JOIN Client C ON R.ClientID = C.ClientID
JOIN Car ON R.CarID = Car.CarID;

-- 7. ���������� � �� �������� ������
SELECT 
    S.Name AS Supplier,
    SO.DateTime AS OrderDate,
    SO.Status
FROM SupplierOrder SO
JOIN Supplier S ON SO.SupplierID = S.SupplierID;
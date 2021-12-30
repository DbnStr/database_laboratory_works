-- Create a new database called 'lab_7'
-- Connect to the 'master' database to run this snippet
USE master
GO
-- Create the new database if it does not exist already
IF NOT EXISTS (
    SELECT [name]
        FROM sys.databases
        WHERE [name] = N'lab_7'
)
CREATE DATABASE lab_7
ON PRIMARY
(
    NAME = lab7primary,
    FILENAME = '/opt/mssql/lab_7_primary.mdf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
),
(
    NAME = lab7secondary,
    FILENAME = '/opt/mssql/lab_7_secondary.ndf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
)
LOG ON
(
    NAME = lab7log,
    FILENAME = '/opt/mssql/mylog_7.ldf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
);
GO

-- Задаём таблицы из Лабораторной 6

USE lab_7
GO

CREATE TABLE [dbo].dog_owner(
    [OwnerId] int PRIMARY KEY IDENTITY(1, 1),
    [Name] VARCHAR(255) NOT NULL 
)
GO

CREATE TABLE [dbo].Dog(
    [DogID] int PRIMARY KEY IDENTITY(1, 1),
    [Name] VARCHAR(100) NOT NULL,
    [OwnerId] int,
    CONSTRAINT Owner_cons FOREIGN KEY ([OwnerId]) REFERENCES [dbo].dog_owner
    ON DELETE SET NULL
    ON UPDATE CASCADE
)
GO

INSERT dog_owner (Name)
VALUES
(
    'Denis'
),
(
    'Elena'
),
(
    'Alex'
),
(
    'Petr'
)
GO

INSERT INTO Dog (Name, OwnerId)
VALUES 
(
    'Vasya', 1
),
(
    'Myxtar', 2
),
(
    'Jurka', 2
),
(
    'Plot', 3
)
GO

--Задание 1

USE lab_7
GO

CREATE VIEW [dbo].dog_owner_indx WITH SCHEMABINDING AS
    SELECT [OwnerId], [Name] FROM [dbo].dog_owner WHERE [Name] != 'Denis'
GO

SELECT * FROM Dog_Owner
GO

--Задание 2

-- Delete rows from table '[DogOwner]' in schema '[dbo]'
DELETE FROM [dbo].[dog_owner]
WHERE [OwnerId] = 1
GO

CREATE VIEW [dbo].dog_with_owner WITH SCHEMABINDING AS
    SELECT d.Name AS DogName, do.Name as OwnerName
    FROM [dbo].Dog AS d JOIN [dbo].dog_owner AS do
    ON (d.OwnerId IS NOT NULL) AND (d.OwnerId = do.OwnerId)
GO

SELECT * FROM [dbo].dog_with_owner
GO

--Задание 3
USE lab_7
GO

DROP TABLE Laptop

CREATE TABLE Laptop (
    [LaptopId] INT IDENTITY PRIMARY KEY,
    [Producer] VARCHAR(100) NOT NULL,
    [ProcessorProducer] VARCHAR(100) NOT NULL,
    [MemorySize] INT NOT NULL,
    [VideocardProducer] VARCHAR(100) NOT NULL,
    [OperativeMemorySize] INT NOT NULL
)

-- Insert rows into table 'Laptop' in schema '[dbo]'
INSERT INTO [dbo].[Laptop]
( -- Columns to insert data into
 [Producer], [ProcessorProducer], [MemorySize], [VideocardProducer], [OperativeMemorySize]
)
VALUES
(
 'Apple', 'Apple', 512, 'Apple', 16
),
(
 'Lenovo', 'Intel', 1024, 'NVIDIA', 32
),
(
 'ASUS', 'AMD', 1024, 'NVIDIA', 64
)
GO 100000


SELECT Producer, ProcessorProducer, MemorySize FROM Laptop WHERE MemorySize = 1024 AND Producer LIKE 'Lenovo'

DROP INDEX Orders_Laptop ON Laptop

CREATE NONCLUSTERED INDEX Orders_Laptop
    ON Laptop (Producer)
    INCLUDE (ProcessorProducer, MemorySize)
GO

SELECT * FROM Laptop WHERE MemorySize = 1024 AND Producer LIKE 'Intel'

--Задание 4

USE lab_7
GO

CREATE UNIQUE CLUSTERED INDEX INDX_1
    ON dbo.dog_with_owner (OwnerName, DogName)
GO

SELECT * FROM dbo.dog_with_owner
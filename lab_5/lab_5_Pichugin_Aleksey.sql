--1 пункт задания - создание Database
USE master
GO
 -- Create a new database called 'lab_5'
 -- Connect to the 'master' database to run this snippet
 USE master
 GO
 -- Create the new database if it does not exist already
 IF NOT EXISTS (
     SELECT [name]
         FROM sys.databases
         WHERE [name] = N'lab_5'
 )
CREATE DATABASE lab_5
ON PRIMARY
(
    NAME = lab5primary,
    FILENAME = '/opt/mssql/lab5primary.mdf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
),
(
    NAME = lab5secondary,
    FILENAME = '/opt/mssql/lab5secondary.ndf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
)
LOG ON
(
    NAME = lab5log,
    FILENAME = '/opt/mssql/mylog5.ldf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
);
GO

--2 пункт задания - создание Table

-- Create a new table called '[Customers]' in schema '[dbo]'
-- Drop the table if it already exists
USE lab_5
GO
IF OBJECT_ID('[dbo].[Customers]', 'U') IS NOT NULL
DROP TABLE [dbo].[Customers]
GO
-- Create the table in the specified schema
CREATE TABLE [dbo].[Customers]
(
    [CustomerId] INT NOT NULL PRIMARY KEY, -- Primary Key column
    [Name] NVARCHAR(50) NOT NULL,
    [Email] NVARCHAR(50) NOT NULL
    -- Specify more columns here
);
GO

-- Заполняем таблицу
INSERT INTO [dbo].[Customers]
( -- Columns to insert data into
 [CustomerId], [Name], [Email]
)
VALUES
( -- First row: values for the columns in the list above
 1, N'Alexey', N'alexpich2002@yandex.ru'
),
( -- Second row: values for the columns in the list above
 2, N'Darya', N'Daahaaa@icloud.com'
)
-- Add more rows here
GO

--Задание 3 - Добавление новой файловой группы
USE lab_5
GO

ALTER DATABASE lab_5
ADD FILEGROUP CustomersGroup1
GO

--Добавление 2 файлов в новую файловую группу
USE lab_5
GO
ALTER DATABASE lab_5
ADD FILE 
(
    NAME = Customer_dat_1,
    FILENAME = '/opt/mssql/Customer_dat_1.ndf'
),
(
    NAME = Customer_dat_2,
    FILENAME = '/opt/mssql/Customer_dat_2.ndf'
)
TO FILEGROUP CustomersGroup1;
GO

--Задание 4 - зменение файловой группы CustomerGroup как группы по умолчанию
ALTER DATABASE lab_5
MODIFY FILEGROUP CustomersGroup1 DEFAULT
GO

--Задание 5 - создание таблицы
USE lab_5
CREATE TABLE cats
(
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NCHAR(10)
)
GO

--добавление записей в таблицу
INSERT INTO cats VALUES ('VASYA')
GO 500

--Задание 6 - удаление файловой группы
--Изменение новой группы как группы по умолчанию
ALTER DATABASE lab_5
MODIFY FILEGROUP [primary] DEFAULT

USE lab_5
GO

-- Create copy of the table and all data in different filegroup
SELECT * INTO cats_copy ON [PRIMARY] 
FROM cats

--Удаление таблицы Cats
USE lab_5
GO
DROP TABLE cats 
GO

--переименовываем cats_copy->cats
USE lab_5
GO
EXEC sp_rename 'cats_copy', 'cats'

--Удаление 1 файла
USE lab_5
GO

ALTER DATABASE lab_5
REMOVE FILE Customer_dat_1
GO

--Удаление 2 файла
ALTER DATABASE lab_5
REMOVE FILE Customer_dat_2
GO

--Удаление файловой группы
ALTER DATABASE lab_5
REMOVE FILEGROUP CustomersGroup1
GO

--Пункт 7 - создание схемы
USE lab_5
GO

CREATE SCHEMA Customers_Scheme
GO

ALTER SCHEMA Customers_Scheme TRANSFER dbo.Customers
GO

DROP TABLE Customers_Scheme.Customers
DROP SCHEMA Customers_Scheme
GO

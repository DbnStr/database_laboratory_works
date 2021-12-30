USE master
GO

USE master
GO

CREATE DATABASE lab_6
ON PRIMARY
(
    NAME = lab5primary,
    FILENAME = '/opt/mssql/lab_6_primary.mdf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
),
(
    NAME = lab5secondary,
    FILENAME = '/opt/mssql/lab_6_secondary.ndf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
)
LOG ON
(
    NAME = lab5log,
    FILENAME = '/opt/mssql/mylog_6.ldf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
);
GO

--Задание 1, 2
IF OBJECT_ID('[dbo].[Cat]', 'U') IS NOT NULL
DROP TABLE [dbo].[Cat]
GO
CREATE TABLE [dbo].[Cat]
(
    CatId int IDENTITY(1, 1) PRIMARY KEY,
    [Name] VARCHAR(255) NOT NULL,
    [Color] VARCHAR(255),
    [Weight] int NOT NULl CHECK ([Weight] > 0 AND [Weight] < 20),
    NumberOfTall int DEFAULT 1
);
GO

INSERT INTO [dbo].[Cat]
( 
 [Name], Color, [Weight]
)
VALUES
(
 'BARSIK', 'GRAY', 5
),
(
 'Murzik', 'red', 10
)

SELECT * FROM Cat

SELECT @@IDENTITY AS 'Identity'
SELECT IDENT_CURRENT('Cat')
SELECT SCOPE_IDENTITY()

SELECT AVG([Weight]) FROM Cat

--Задание 3
IF OBJECT_ID('[dbo].[Customer]', 'U') IS NOT NULL
DROP TABLE [dbo].[Customer]
GO

CREATE TABLE [dbo].[Customer]
(
    [CustomerId] UNIQUEIDENTIFIER NOT NULL PRIMARY KEY DEFAULT newid(),
    [Name] VARCHAR(100) NOT NULL,
    [FavoriteCigarettes] VARCHAR(100) NOT NULL DEFAULT('PETR 1')
);
GO

--Задание 4
CREATE SEQUENCE MySequence
    START WITH 1
    INCREMENT BY 4;
GO

IF OBJECT_ID('[dbo].[Student]', 'U') IS NOT NULL
DROP TABLE [dbo].[Student]
GO
CREATE TABLE [dbo].[Student]
(
    [StudentId] INT NOT NULL PRIMARY KEY DEFAULT(NEXT VALUE FOR MySequence), -- Primary Key column
    [FirstName] NVARCHAR(50) NOT NULL,
    [LastName] NVARCHAR(50) NOT NULL
);
GO

INSERT INTO [dbo].[Student]
(
 [FirstName], [LastName]
)
VALUES
(
 'Aleksey', 'Pichugin'
),
(
 'Danya', 'Ismagilova'
)
GO

SELECT * FROM Student
GO

--5 задание


IF OBJECT_ID('[dbo].[Dog]', 'U') IS NOT NULL
DROP TABLE [dbo].[Dog]
GO

IF OBJECT_ID('[dbo].[DogOwner]', 'U') IS NOT NULL
DROP TABLE [dbo].[DogOwner]
GO

CREATE TABLE DogOwner(
    [OwnerId] int PRIMARY KEY IDENTITY(1, 1),
    [Name] VARCHAR(255) NOT NULL 
)
GO

CREATE TABLE Dog(
    [DogID] int PRIMARY KEY IDENTITY(1, 1),
    [Name] VARCHAR(100) NOT NULL,
    [OwnerId] int,
    CONSTRAINT Owner_cons FOREIGN KEY ([OwnerId]) REFERENCES [DogOwner]
    ON DELETE SET NULL
    ON UPDATE CASCADE
)
GO

INSERT DogOwner (Name)
VALUES
(
    'Denis'
),
(
    'Elena'
)
GO

INSERT INTO Dog (Name, OwnerId)
VALUES 
(
    'Vasya', 1
),
(
    'Myxtar', 2
)
GO

SELECT * FROM DogOwner
SELECT * FROM Dog

-- Delete rows from table '[DogOwner]' in schema '[dbo]'
DELETE FROM [dbo].[DogOwner]
WHERE [OwnerId] = 1
GO
USE master
GO
--Пункт 1 : Создать две базы данных на одном экземпляре СУБД SQL Server 2012.

--Создание 1 базы данных
IF DB_ID (N'lab_13_1') IS NOT NULL
    DROP DATABASE lab_13_1;
GO

CREATE DATABASE lab_13_1
ON PRIMARY
(
    NAME = lab13_1_primary,
    FILENAME = '/opt/mssql/lab13_1_primary.mdf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
)
LOG ON
(
    NAME = lab_13_1_log,
    FILENAME = '/opt/mssql/lab_13_1_log.ldf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
);
GO
--Создание 2 базы данных
IF DB_ID (N'lab_13_2') IS NOT NULL
DROP DATABASE lab_13_2;
GO

CREATE DATABASE lab_13_2
ON PRIMARY
(
    NAME = lab13_2_primary,
    FILENAME = '/opt/mssql/lab13_2_primary.mdf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
)
LOG ON
(
    NAME = lab_13_2_log,
    FILENAME = '/opt/mssql/lab_13_2_log.ldf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
);
GO

--Пункт 2 : Создать в базах данных п.1. горизонтально фрагментированные таблицы.

--Создаем таблицу в 1 базе

USE lab_13_1
GO

IF OBJECT_ID (N'District') IS NOT NULL
    DROP TABLE District;
GO

CREATE TABLE District (
    [districtNumber] INT PRIMARY KEY NOT NULL CHECK (districtNumber <= 50),
    [commisionPhoneNumber] VARCHAR(11) NOT NULL,
    [commisionEmail] VARCHAR(50) NOT NULL,
    [commisionCity] VARCHAR(50) NOT NULL,
    [commisionStreet] VARCHAR(50) NOT NULL,
    [commisionHouse] VARCHAR(50) NOT NULL
)

INSERT INTO District(districtNumber, commisionPhoneNumber, commisionEmail, commisionCity, commisionStreet, commisionHouse)
    VALUES 
        (12, '89807637442', 'alex@yandex.ru', 'Dubna', 'Pontekorovo', '15'),
        (11, '89164343342', 'dbnstr@gmail.ru', 'Pavlovskoe', 'Pochotvaya', '68')
GO

--Создаем таблицу во 2 базе

USE lab_13_2

IF OBJECT_ID (N'District') IS NOT NULL
    DROP TABLE District;
GO

CREATE TABLE District (
    [districtNumber] INT PRIMARY KEY NOT NULL CHECK (districtNumber > 50),
    [commisionPhoneNumber] VARCHAR(11) NOT NULL,
    [commisionEmail] VARCHAR(50) NOT NULL,
    [commisionCity] VARCHAR(50) NOT NULL,
    [commisionStreet] VARCHAR(50) NOT NULL,
    [commisionHouse] VARCHAR(50) NOT NULL
)

INSERT INTO District(districtNumber, commisionPhoneNumber, commisionEmail, commisionCity, commisionStreet, commisionHouse)
    VALUES 
        (51, '89163224643', 'danya@yandex.ru', 'Chistipol', 'Bebelya', '67'),
        (52, '89163229833', 'dasha@gmail.ru', 'Ijevsk', 'Pastuxova', '191')
GO

--Пункт 3 : Создать секционированные представления, обеспечивающие работу с данными таблиц (выборку, вставку, изменение, удаление).

USE lab_13_1
GO

if OBJECT_ID(N'All_districts') IS NOT NULL
    DROP VIEW All_districts
GO

CREATE VIEW All_districts
AS
    SELECT * FROM lab_13_1.dbo.District
    UNION ALL
    SELECT * FROM lab_13_2.dbo.District
GO

SELECT * FROM All_districts

USE lab_13_2
GO

if OBJECT_ID(N'All_districts') IS NOT NULL
    DROP VIEW All_districts
GO

CREATE VIEW All_districts
AS
    SELECT * FROM lab_13_1.dbo.District
    UNION ALL
    SELECT * FROM lab_13_2.dbo.District
GO

SELECT * FROM All_districts

INSERT INTO All_districts VALUES
    (23, '89807654323', 'igor@gmail.ru', 'Syktyvkar', 'Markova', '27'),
    (59, '89167634630', 'maks@yandex.ru', 'Samara', 'Rabochaya', '140')
GO

SELECT * FROM All_districts
GO

UPDATE All_districts
    SET commisionHouse = '28'
    WHERE districtNumber = 23
GO

SELECT * FROM All_districts
GO

DELETE FROM All_districts WHERE districtNumber = 12
GO

SELECT * FROM All_districts
GO



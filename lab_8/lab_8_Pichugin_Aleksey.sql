-- Create a new database called 'lab_8'
-- Connect to the 'master' database to run this snippet
USE master
GO
-- Create the new database if it does not exist already
IF NOT EXISTS (
    SELECT [name]
        FROM sys.databases
        WHERE [name] = N'lab_8'
)
CREATE DATABASE lab_8
GO


--Задание 1
USE lab_8
GO

CREATE TABLE Laptop (
    [LaptopId] int IDENTITY(1, 1) PRIMARY KEY,
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
),
(
 'Apple', 'Intel', 1024, 'NVIDIA', 8
)
GO

USE lab_8
GO

DROP PROCEDURE laptop_GetLaptopsFromProducer
GO

CREATE PROCEDURE [dbo].laptop_GetLaptopsFromProducer
    @laptop_cursor CURSOR VARYING OUTPUT,
    @producerName VARCHAR(100)
AS 
    SET @laptop_cursor = CURSOR
        FOR
            SELECT ProcessorProducer, VideocardProducer
            FROM Laptop WHERE Producer = @producerName
OPEN @laptop_cursor
GO

USE lab_8
GO

DECLARE @processorName VARCHAR(100)
DECLARE @videocardName VARCHAR(100)

DECLARE @cursor CURSOR;

EXEC [dbo].laptop_GetLaptopsFromProducer @laptop_cursor = @cursor OUTPUT, @producerName = 'Apple';

FETCH NEXT FROM @cursor INTO @processorName, @videocardName

WHILE(@@FETCH_STATUS = 0)
BEGIN
    PRINT @processorName + ' ' + @videocardName
    FETCH NEXT FROM @cursor INTO @processorName, @videocardName
END

CLOSE @cursor
DEALLOCATE @cursor
GO

--Задание 2

-- IF OBJECT_ID('[dbo].[CryptoCources]', 'U') IS NOT NULL
-- DROP TABLE [dbo].[CryptoCources]
-- GO

-- CREATE TABLE [dbo].[CryptoCources]
-- (
--     [CryptoName] NVARCHAR(50) PRIMARY KEY NOT NULL,
--     [Price] INT NOT NULL
-- );
-- GO

-- -- Insert rows into table 'CryptoCources' in schema '[dbo]'
-- INSERT INTO [dbo].[CryptoCources]
-- ( -- Columns to insert data into
--  [CryptoName], [Price]
-- )
-- VALUES
-- ( -- First row: values for the columns in the list above
--  'BTC', 49130
-- ),
-- ( -- Second row: values for the columns in the list above
--  'ETH', 4163
-- ),
-- (
--  'DOGE', 0.1728
-- )

GO
IF OBJECT_ID('[dbo].[Wallet]', 'U') IS NOT NULL
DROP TABLE [dbo].[Wallet]
GO

CREATE TABLE [dbo].[Wallet]
(
    [WalletID] INT IDENTITY(1, 1) PRIMARY KEY,
    [CountOfBitcoin] INT NOT NULL,
    [CountOfEth] INT NOT NULL,
    [CountOfDogeCoin] INT NOT NULL
);
GO

INSERT INTO [dbo].[Wallet]
( 
 [CountOfBitcoin], [CountOfEth], [CountOfDogeCoin]
)
VALUES
(
 1, 2, 145343
),
(
 3, 4, 10000
)
GO

CREATE FUNCTION [dbo].GetAmount (@btc INT, @eth INT, @doge INT)
RETURNS INT
AS
BEGIN
    DECLARE @res INT
    SELECT @res = @btc + @eth + @doge
RETURN @res
END
GO

CREATE PROCEDURE [dbo].get_wallets
    @cursor CURSOR VARYING OUTPUT
AS 
    SET @cursor = CURSOR
        FOR
            SELECT 
            CountOfBitcoin as btc, 
            CountOfEth as eth, 
            CountOfDogeCoin as doge,
            dbo.GetAmount(CountOfBitcoin, CountOfEth, CountOfDogeCoin) as amount
            FROM [dbo].Wallet WHERE CountOfBitcoin > 0
OPEN @cursor
GO

DECLARE @btc INT;
DECLARE @eth INT;
DECLARE @doge INT;
DECLARE @amount INT;

DECLARE @crypto_cursor CURSOR;

EXEC [dbo].get_wallets @cursor = @crypto_cursor OUTPUT

FETCH NEXT FROM @crypto_cursor INTO @btc, @eth, @doge, @amount

WHILE(@@FETCH_STATUS = 0)
BEGIN
    PRINT CAST(@btc as VARCHAR) + '  ' + CAST(@eth as VARCHAR)  + '  ' + CAST(@doge as VARCHAR)  + '  ' + CAST(@amount as VARCHAR) 
    FETCH NEXT FROM @crypto_cursor INTO @btc, @eth, @doge, @amount
END

CLOSE @crypto_cursor
DEALLOCATE @crypto_cursor
GO

--Задание 3
CREATE FUNCTION isProcessorApple(@processorName VARCHAR(100))
RETURNS INT
AS
    BEGIN
        if @processorName LIKE 'Apple'
        return 1
        return 0
    END
GO

CREATE PROCEDURE [dbo].proc2
AS
DECLARE @cursor CURSOR;
DECLARE @processorName VARCHAR(100)
DECLARE @videocardName VARCHAR(100)
EXEC [dbo].laptop_GetLaptopsFromProducer @laptop_cursor = @cursor OUTPUT, @producerName = 'Apple';
FETCH NEXT FROM @cursor INTO @processorName, @videocardName
WHILE (@@FETCH_STATUS = 0)
    BEGIN
        IF (dbo.isProcessorApple(@processorName) = 1)
            PRINT ' Processor: ' + @processorName + ' VideoCard: ' + @videocardName;

        FETCH NEXT FROM @cursor INTO @processorName, @videocardName
    END;
CLOSE @cursor;
DEALLOCATE @cursor;
GO

EXEC dbo.proc2;
GO

--Задание 4

CREATE FUNCTION [dbo].func4(@min_btc INT) RETURNS @res TABLE
(
    CountOfBitcoin INT NOT NULL,
    CountOfEth INT NOT NULL,
    CountOfDoge INT NOT NULL,
    Amount INT NOT NULL
)
AS
BEGIN
    INSERT @res SELECT CountOfBitcoin, CountOfEth, CountOfDogeCoin,
                  dbo.GetAmount(CountOfBitcoin, CountOfEth, CountOfDogeCoin) as amount FROM Wallet WHERE CountOfBitcoin > @min_btc
    RETURN
END
GO

CREATE FUNCTION [dbo].func_inline(@min_btc INT) 
RETURNS TABLE
AS
    RETURN SELECT CountOfBitcoin, CountOfEth, CountOfDogeCoin,
                  dbo.GetAmount(CountOfBitcoin, CountOfEth, CountOfDogeCoin) as amount FROM Wallet WHERE CountOfBitcoin > @min_btc
GO

CREATE PROCEDURE [dbo].proc4
    @min_btc INT = 0,
    @cursor CURSOR VARYING OUTPUT
AS 
    SET @cursor = CURSOR
        FOR
            SELECT * FROM func4(@min_btc)
OPEN @cursor
GO

CREATE PROCEDURE [dbo].proc_with_inline_func
    @min_btc INT = 0,
    @cursor CURSOR VARYING OUTPUT
AS 
    SET @cursor = CURSOR
        FOR
            SELECT * FROM func5(@min_btc)
OPEN @cursor
GO

DECLARE @btc INT;
DECLARE @eth INT;
DECLARE @doge INT;
DECLARE @amount INT;

DECLARE @crypto_cursor CURSOR;

EXEC [dbo].proc_with_inline_func @cursor = @crypto_cursor OUTPUT

FETCH NEXT FROM @crypto_cursor INTO @btc, @eth, @doge, @amount

WHILE(@@FETCH_STATUS = 0)
BEGIN
    PRINT CAST(@btc as VARCHAR) + '  ' + CAST(@eth as VARCHAR)  + '  ' + CAST(@doge as VARCHAR)  + '  ' + CAST(@amount as VARCHAR) 
    FETCH NEXT FROM @crypto_cursor INTO @btc, @eth, @doge, @amount
END

CLOSE @crypto_cursor
DEALLOCATE @crypto_cursor
GO

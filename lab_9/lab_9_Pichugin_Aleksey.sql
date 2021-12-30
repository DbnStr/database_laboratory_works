USE master
GO

IF DB_ID (N'lab_9') IS NOT NULL
    DROP DATABASE lab_9;
GO

CREATE DATABASE lab_9
ON PRIMARY
(
    NAME = lab_9_primary,
    FILENAME = '/opt/mssql/lab_9_primary.mdf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
)
LOG ON
(
    NAME = lab_9_log,
    FILENAME = '/opt/mssql/lab_9_log.ldf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
);
GO


--Создаём таблицы из 7 лабы
USE lab_9
GO

IF OBJECT_ID (N'dog_owner') IS NOT NULL
    DROP TABLE [dbo].dog_owner;
GO

CREATE TABLE [dbo].dog_owner(
    [OwnerId] int PRIMARY KEY IDENTITY(1, 1),
    [Name] VARCHAR(255) NOT NULL,
    [Email] VARCHAR(255) UNIQUE NOT NULL,
    [Phone] VARCHAR(100) NOT NULL
)
GO

IF OBJECT_ID (N'Dog') IS NOT NULL
    DROP TABLE [dbo].Dog;
GO

CREATE TABLE [dbo].Dog(
    [DogID] int PRIMARY KEY IDENTITY(1, 1),
    [Name] VARCHAR(100) NOT NULL,
    [colorOfWool] VARCHAR(100) NOT NULL,
    [OwnerId] INT,
    CONSTRAINT Owner_cons FOREIGN KEY ([OwnerId]) REFERENCES [dbo].dog_owner
    ON DELETE SET NULL
    ON UPDATE CASCADE
)
GO

USE lab_9
GO

INSERT INTO [dbo].dog_owner ([Name], [Email], [Phone])
VALUES
(
    'Denis', 'alexpich2002@yandex.ru', '89808923014'
),
(
    'Elena', 'dima@gmail.com', '89160258074'
),
(
    'Alex', 'krab@vk.ru', '89160258073'
),
(
    'Petr', 'lepestok@ok.ru', '89874563892'
)
GO

INSERT INTO Dog (Name, colorOfWool, OwnerId)
VALUES 
(
    'Vasya', 'Gray', 1
),
(
    'Myxtar', 'Black', 2
),
(
    'Jurka', 'White', 3
),
(
    'Plot', 'Pink', 4
)
GO

--Задание 1
IF OBJECT_ID (N'is_exist_owner') IS NOT NULL
    DROP FUNCTION [dbo].is_exist_owner;
GO

CREATE FUNCTION [dbo].is_exist_owner(@dog_owner_Id VARCHAR(100))
RETURNS INT
AS
    BEGIN
        if EXISTS (SELECT * FROM dog_owner WHERE OwnerId = @dog_owner_Id)
        RETURN 1
        RETURN 0
    END
GO

IF OBJECT_ID (N'trigger_insert') IS NOT NULL
    DROP TRIGGER [dbo].trigger_insert;
GO
        
CREATE TRIGGER trigger_insert
    ON Dog
    INSTEAD OF INSERT
    AS
    Begin
        IF NOT EXISTS (SELECT 1 FROM inserted WHERE [dbo].is_exist_owner(OwnerId) = 1)
        BEGIN
            RAISERROR('UNCORRECT OWNER ID', 1, 13)
            ROLLBACK TRANSACTION
            RETURN
        END
        ELSE
        INSERT INTO Dog ([Name], [colorOfWool], [OwnerId]) SELECT [Name], [colorOfWool], [OwnerId] FROM inserted
    END
GO

IF OBJECT_ID (N'dog_owner_trigger_insert') IS NOT NULL
    DROP TRIGGER [dbo].dog_owner_trigger_insert;
GO
        
CREATE TRIGGER dog_owner_trigger_insert
    ON dog_owner
    INSTEAD OF INSERT
    AS
    Begin
        PRINT '323'
        IF (SELECT COUNT(*) FROM inserted WHERE inserted.Email IN (SELECT dog_owner.Email FROM dog_owner)) != 0
        BEGIN
            RAISERROR('Owner with this email exists', 1, 13)
            ROLLBACK TRANSACTION
            RETURN
        END
        ELSE
        INSERT INTO dog_owner ([Name], [Email], [Phone]) SELECT [Name], [Email], [Phone] FROM inserted
    END
GO

INSERT INTO Dog (Name, colorOfWool, OwnerId)
VALUES
(
    'Lena', 'Orange', 11000
)

IF OBJECT_ID (N'trigger_delete') IS NOT NULL
    DROP TRIGGER [dbo].trigger_delete;
GO

CREATE TRIGGER trigger_delete
    ON Dog
    AFTER DELETE
    AS
    BEGIN
        PRINT 'DOG DELETED'
    END
GO

-- DELETE FROM Dog WHERE [Name] = 'Vasya'
-- GO

-- SELECT * FROM Dog
-- GO

IF OBJECT_ID (N'trigger_update') IS NOT NULL
    DROP TRIGGER [dbo].trigger_update;
GO

CREATE TRIGGER trigger_update
    ON Dog
    AFTER UPDATE
    AS
    BEGIN
        if UPDATE(colorOfWool)
        BEGIN
            RAISERROR('UPDATE ERROR : colorOfWool is constant', 1, 14)
            ROLLBACK TRANSACTION
            RETURN
        END
    END
GO

-- UPDATE Dog SET colorOfWool = 'gray' WHERE Name LIKE 'Vasya'
-- GO

-- SELECT * FROM Dog

--Задание 2

IF OBJECT_ID (N'dog_with_owner') IS NOT NULL
    DROP VIEW [dbo].dog_with_owner;
GO

CREATE VIEW [dbo].dog_with_owner AS
    SELECT d.Name AS DogName, d.colorOfWool as colorOfWool, do.Name as OwnerName, do.Email as OwnerEmail, do.phone as OwnerPhone
    FROM [dbo].Dog AS d
    INNER JOIN [dbo].[dog_owner] AS do ON (d.OwnerId = do.OwnerId)
GO

SELECT * FROM dog_with_owner

IF OBJECT_ID (N'getOwnerId') IS NOT NULL
    DROP FUNCTION [dbo].getOwnerId;
GO

CREATE FUNCTION [dbo].getOwnerId(@email VARCHAR(100))
RETURNS VARCHAR(100)
AS
    BEGIN
        DECLARE @res VARCHAR(100)
        SELECT @res = ownerID FROM dog_owner WHERE email = @email
        RETURN @res
    END
GO

IF OBJECT_ID (N'trigger_insert_view') IS NOT NULL
    DROP TRIGGER [dbo].trigger_insert_view;
GO

CREATE TRIGGER trigger_insert_view
    ON dog_with_owner
    INSTEAD OF INSERT
    AS
    BEGIN
        if EXISTS (SELECT * FROM inserted WHERE OwnerEmail in (SELECT Email FROM dog_owner)) OR EXISTS (SELECT * FROM inserted WHERE OwnerPhone in (SELECT phone FROM dog_owner))
            BEGIN
                RAISERROR('OWNER WITH THIS ADDRESS OR PHONE NUMBER EXISTS', 1, 14)
                ROLLBACK TRANSACTION
                RETURN
            END
        INSERT INTO dog_owner ([Name], email, phone)
            SELECT
            ownerName,
            ownerEmail,
            OwnerPhone
            FROM inserted
        INSERT INTO Dog ([Name], colorOfWool, ownerId)
            SELECT
            DogName,
            colorOfWool,
            [dbo].getOwnerId(ownerEmail)
            FROM inserted
    END
GO

INSERT INTO dog_with_owner (DogName, colorOfWool, OwnerName, OwnerEmail, OwnerPhone) 
    VALUES
        ('pop3', 'red', 'lesh1a', 'p32@gmail.com', '89808987323232'),
        ('jurka', 'blue', 'igor', 'p32@gmail.com', '89808945114')
GO

SELECT * FROM Dog
SELECT * FROM dog_owner
SELECT * FROM dog_with_owner

IF OBJECT_ID (N'trigger_update_view') IS NOT NULL
    DROP TRIGGER [dbo].trigger_update_view;
GO

CREATE TRIGGER trigger_update_view
    ON dog_with_owner
    INSTEAD OF UPDATE
    AS
    BEGIN
        if UPDATE(OwnerEmail) OR UPDATE(OwnerPhone)
        BEGIN
            RAISERROR('error', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
        if UPDATE(OwnerName)
        BEGIN
            UPDATE dog_owner SET Name = i.OwnerName FROM inserted AS i WHERE dog_owner.Email = i.OwnerEmail
        END
        if UPDATE(DogName)
        BEGIN
            UPDATE Dog SET Name = i.DogName FROM inserted AS i WHERE Dog.OwnerId = [dbo].getOwnerId(i.OwnerEmail)
        END
    END
GO

UPDATE dog_with_owner SET OwnerName = 'Igor' WHERE OwnerName = 'Denis'
UPDATE dog_with_owner SET DogName = 'Step' WHERE OwnerName = 'Plot'

SELECT * FROM dog_owner
SELECT * FROM dog
SELECT * FROM dog_with_owner

IF OBJECT_ID (N'trigger_delete_view') IS NOT NULL
    DROP TRIGGER [dbo].trigger_delete_view;
GO

CREATE TRIGGER trigger_delete_view
    ON dog_with_owner
    INSTEAD OF DELETE
    AS
    BEGIN
        MERGE Dog USING (SELECT ownerEmail FROM deleted) AS DogOwner(ownerEmail)
            ON dog.ownerID = [dbo].getOwnerId(ownerEmail)
            WHEN MATCHED 
            THEN DELETE;
        MERGE Dog_owner USING (SELECT ownerEmail FROM deleted) AS DogOwner(ownerEmail)
            ON dog_owner.email = ownerEmail
            WHEN MATCHED 
            THEN DELETE;
    END
GO

DELETE FROM dog_with_owner

SELECT * FROM Dog
SELECT * FROM dog_owner
SELECT * FROM dog_with_owner
            




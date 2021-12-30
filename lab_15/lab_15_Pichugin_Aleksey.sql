--Задание 2 : Создать в базах данных пункта 1 задания 13 связанные таблицы.

USE lab_13_1
GO

IF OBJECT_ID(N'District') IS NOT NULL
    DROP TABLE District

CREATE TABLE District (
    [districtNumber] INTEGER PRIMARY KEY NOT NULL,
    [districtName] VARCHAR(100) NOT NULL,
    [commisionPhoneNumber] VARCHAR(11) NOT NULL,
    [commisionEmail] VARCHAR(50) NULL,
    [commisionCity] VARCHAR(50) NOT NULL,
    [commisionStreet] VARCHAR(50) NOT NULL,
    [commisionHouse] VARCHAR(50) NOT NULL
)
GO

INSERT INTO District VALUES
(
    196, 'Gorod Moskva - Babushkinskij odnomandatnyj izbiratelnyj okrug', '84991883612', NULL, 'Moscow', 'Yaroslavl highway', '122'
),
(
    197, 'Gorod Moskva - Kuncevskij odnomandatnyj izbiratelnyj okrug', '84954472946', NULL, 'Moscow', 'st. Kubinka', '3'
)

USE lab_13_2
GO

IF OBJECT_ID(N'Electorate') IS NOT NULL
    DROP TABLE Electorate

CREATE TABLE Electorate (
    [electorateId] INTEGER PRIMARY KEY NOT NULL,
    [passportSeria] VARCHAR(4) NOT NULL,
    [passportNumber] VARCHAR(6) NOT NULL,
    UNIQUE([passportSeria], [passportNumber]),
    [firstName] VARCHAR(15) NOT NULL,
    [middleName] VARCHAR(15) NOT NULL,
    [lastName] VARCHAR(15) NOT NULL,
    [city] VARCHAR(50) NOT NULL,
    [street] VARCHAR(50) NOT NULL,
    [house] VARCHAR(50) NOT NULL,
    [birthDate] DATE NOT NULL,
    [phoneNumber] VARCHAR(11) NULL,
    [email] VARCHAR(50) NULL,
    [districtNumber] INTEGER
)
GO

INSERT INTO Electorate VALUES
(
    1, '4616', '109876', 'Alexey', 'Alexeevich', 'Pichugin', 'Moscow', 'Yaroslavl highway', '19', '2002-02-13', NULL, NULL, 196
),
(
    2, '4616', '109846', 'Darya', 'Sergeevna', 'Petrova', 'Moscow', 'Yaroslavl highway', '18', '2001-05-13', NULL, NULL, 196
),
(
    3, '4615', '105876', 'Alexey', 'Andreevich', 'Ivanov', 'Moscow', 'st. Kubinka', '5', '2002-07-13', NULL, NULL, 197
),
(
    4, '4615', '103846', 'Darya', 'Sergeevna', 'Petrova', 'Moscow', 'Yst. Kubinka', '1', '2001-09-22', NULL, NULL, 197
)
GO

SELECT * FROM Electorate

--Задание 2 : Создать необходимые элементы базы данных (представления, триггеры), обеспечивающие работу с данными связанных таблиц (выборку, вставку, изменение, удаление).

USE lab_13_1

IF OBJECT_ID(N'Electorate_View') IS NOT NULL
    DROP VIEW Electorate_View
GO

CREATE VIEW Electorate_View
AS
    SELECT e.electorateId, e.passportSeria, e.passportNumber, e.firstName, e.middleName, e.lastName, e.city, e.street, e.house, e.birthDate, e.phoneNumber, e.email, d.districtName
    FROM District as d
    INNER JOIN lab_13_2.dbo.Electorate as e
    ON d.districtNumber = e.districtNumber
GO

SELECT * FROM Electorate_View

IF OBJECT_ID(N'trigger_district_update') IS NOT NULL
    DROP TRIGGER trigger_district_update
GO

CREATE TRIGGER trigger_district_update ON District
INSTEAD OF UPDATE AS
BEGIN
    IF UPDATE(districtNumber)
        BEGIN
            RAISERROR (N'You can not update districtNumber', 16, -1);
            ROLLBACK
            RETURN
        END
    IF UPDATE(districtName)
        BEGIN
            RAISERROR (N'You can not update districtName', 16, -1);
            ROLLBACK
            RETURN
        END
    
    UPDATE District SET 
        commisionPhoneNumber = i.commisionPhoneNumber,
        commisionEmail = i.commisionEmail,
        commisionCity = i.commisionCity,
        commisionStreet = i.commisionStreet,
        commisionHouse = i.commisionHouse 
    FROM inserted AS i WHERE i.districtNumber = District.districtNumber
END
GO

UPDATE District SET commisionPhoneNumber = '88005553535' WHERE districtNumber = 196
SELECT * FROM District
GO

IF OBJECT_ID(N'trigger_delete_district') IS NOT NULL
    DROP TRIGGER trigger_delete_district
GO

CREATE TRIGGER trigger_delete_district ON District
INSTEAD OF DELETE AS
BEGIN
    RAISERROR(N'You can not delete district',16,0)
    ROLLBACK
END
GO

DELETE District
GO

USE lab_13_2
GO

IF (OBJECT_ID(N'trigger_insert_electorate')) IS NOT NULL
    DROP TRIGGER trigger_insert_electorate
GO

CREATE TRIGGER trigger_insert_electorate ON Electorate
INSTEAD OF INSERT AS
BEGIN
    IF (SELECT COUNT(*) FROM inserted AS i WHERE NOT (i.districtNumber IN (SELECT districtNumber FROM Electorate))) != 0
        BEGIN
            RAISERROR (N'District with this number does not exist', 16, -1);
            ROLLBACK
            RETURN
        END
    INSERT INTO Electorate SELECT * FROM inserted
END
GO

INSERT INTO Electorate VALUES
(
    5, '4616', '109876', 'Alexey', 'Alexeevich', 'Pichugin', 'Moscow', 'Yaroslavl highway', '19', '2002-02-13', NULL, NULL, 195
)
GO

INSERT INTO Electorate VALUES
(
    5, '4617', '109876', 'Alexey', 'Alexeevich', 'Pichugin', 'Moscow', 'Yaroslavl highway', '14', '2003-02-13', NULL, NULL, 196
)
GO

SELECT * FROM Electorate

IF OBJECT_ID(N'trigger_update_electorate') IS NOT NULL
    DROP TRIGGER trigger_update_electorate
GO

CREATE TRIGGER trigger_update_electorate ON Electorate
INSTEAD OF UPDATE AS
BEGIN
    IF UPDATE(districtNumber)
        BEGIN
            RAISERROR (N'You can not update districtNumber', 16, -1);
            ROLLBACK
            RETURN
        END
    IF UPDATE(electorateId)
        BEGIN
            RAISERROR (N'You can not update electorateId', 16, -1);
            ROLLBACK
            RETURN
        END
    UPDATE Electorate SET
        Electorate.passportSeria = i.passportSeria,
        Electorate.passportNumber = i.passportNumber,
        Electorate.firstName = i.firstName,
        Electorate.middleName = i.middleName,
        Electorate.lastName = i.lastName,
        Electorate.city = i.city,
        Electorate.street = i.street,
        Electorate.house = i.house,
        Electorate.birthDate = i.birthDate,
        Electorate.phoneNumber = i.phoneNumber,
        Electorate.email = i.email
    FROM inserted AS i WHERE i.electorateId = Electorate.electorateId
END
GO

UPDATE Electorate SET firstName = 'Petr' WHERE electorateId = 1
SELECT * FROM Electorate
GO

UPDATE Electorate SET districtNumber = 197 WHERE electorateId = 1
GO


    
--Задание 1 : Создать в базах данных пункта 1 задания 13 таблицы, содержащие вертикально фрагментированные данные.

USE lab_13_1
GO

IF OBJECT_ID(N'Voting_station') IS NOT NULL
    DROP TABLE Voting_station;
GO

CREATE TABLE Voting_station (
    [votingStationId] INTEGER NOT NULL PRIMARY KEY,
    [number] INTEGER NOT NULL,
    [phoneNumber] VARCHAR(11) NOT NULL,
)

INSERT Voting_station VALUES
(
    1, 1, '89808956340'
),
(
    2, 2, '89165436780'
),
(
    3, 3, '89809876545'
)

USE lab_13_2
GO

IF OBJECT_ID(N'Voting_station') IS NOT NULL
    DROP TABLE Voting_station
GO

CREATE TABLE Voting_station (
    [votingStationId] INTEGER NOT NULL PRIMARY KEY,
    [city] VARCHAR(50) NOT NULL,
    [street] VARCHAR(50) NOT NULL,
    [house] VARCHAR(50) NOT NULL
)

INSERT Voting_station VALUES
(
    1, 'Dubna', 'ave. Bogolubova', '45'
),
(
    2, 'Dubna', 'st. Vernova', '15'
),
(
    3, 'Dubna', 'ave. Pontekorvo', '16' 
)

--Задание 2 : Создать необходимые элементы базы данных (представления, триггеры), обеспечивающие работу с данными вертикально фрагментированных таблиц (выборку, вставку, изменение, удаление).
USE lab_13_1
GO

IF OBJECT_ID(N'All_Voting_stations') IS NOT NULL
    DROP VIEW All_Voting_stations
GO

CREATE VIEW All_Voting_stations
AS
    SELECT v1.votingStationId, v1.number, v1.phoneNumber,
           v2.city, v2.street, v2.house
    FROM lab_13_1.dbo.Voting_station AS v1 INNER JOIN lab_13_2.dbo.Voting_station AS v2
    ON v1.votingStationId = v2.votingStationId
GO

SELECT * FROM All_Voting_stations

IF OBJECT_ID(N'insert_into_view') IS NOT NULL
    DROP TRIGGER insert_into_view
GO

CREATE TRIGGER insert_into_view ON [dbo].All_Voting_stations
INSTEAD OF INSERT AS
BEGIN
    IF (SELECT COUNT(*) FROM inserted as i WHERE i.votingStationId IN (SELECT votingStationId FROM Voting_station)) != 0
        BEGIN
            RAISERROR(N'Voting station with this ID exists', 18, 10);
            ROLLBACK;
        END
    ELSE
        BEGIN
            INSERT lab_13_1.dbo.Voting_station
            SELECT [votingStationId], [number], [phoneNumber] FROM inserted
            
            INSERT lab_13_2.dbo.Voting_station
            SELECT [votingStationId], [city], [street], [house] FROM inserted
        END
END
GO

INSERT All_Voting_stations VALUES
(
    4, 4, '89808923516', 'Moscow', 'ave. Izmailovsky', '73/2'
)

SELECT * FROM All_Voting_stations

-- INSERT All_Voting_stations VALUES
-- (
--     4, 5, '89808923517', 'Moscow', 'ave. Izmailovsky', '73'
-- )

IF OBJECT_ID(N'update_view') IS NOT NULL
    DROP TRIGGER update_view
GO

CREATE TRIGGER update_view ON [dbo].All_Voting_stations
INSTEAD OF UPDATE AS
BEGIN
    IF UPDATE(votingStationID) OR UPDATE(number) OR UPDATE(city) OR UPDATE(street) OR UPDATE(house)
        BEGIN
            RAISERROR (N'You can not update theese fields', 18, 0);
            ROLLBACK;
        END

    IF UPDATE(phoneNumber)
        BEGIN
            UPDATE lab_13_1.dbo.Voting_station
            SET phoneNumber = (SELECT phoneNumber FROM inserted WHERE (inserted.votingStationId = lab_13_1.dbo.Voting_station.votingStationId))
            WHERE EXISTS (SELECT * FROM inserted WHERE inserted.votingStationId = lab_13_1.dbo.Voting_station.votingStationId)
        END
END
GO

UPDATE All_Voting_stations SET phoneNumber = phoneNumber-- WHERE votingStationId = 2

SELECT * FROM All_Voting_stations

IF OBJECT_ID(N'delete_view') IS NOT NULL
    DROP TRIGGER delete_view
GO

CREATE TRIGGER delete_view ON [dbo].All_Voting_stations
INSTEAD OF DELETE AS
BEGIN
    DELETE lab_13_1.dbo.Voting_station
    WHERE EXISTS (SELECT * FROM inserted WHERE inserted.votingStationId = lab_13_1.dbo.Voting_station.votingStationId)

    DELETE lab_13_2.dbo.Voting_station
    WHERE EXISTS (SELECT * FROM inserted WHERE inserted.votingStationId = lab_13_2.dbo.Voting_station.votingStationId)
END

DELETE FROM All_Voting_stations WHERE (votingStationId = 1 OR votingStationId = 2)
SELECT * FROM All_Voting_stations
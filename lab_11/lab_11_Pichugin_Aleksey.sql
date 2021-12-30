--Лабораторная 11

IF DB_ID(N'lab_11') IS NOT NULL
    DROP DATABASE lab_11
GO

CREATE DATABASE lab_11
ON PRIMARY
(
    NAME = lab_11_primary,
    FILENAME = '/opt/mssql/lab_11_primary.mdf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
)
LOG ON
(
    NAME = lab_11_log,
    FILENAME = '/opt/mssql/lab_11_log.ldf',
    SIZE = 15,
    MAXSIZE = 150,
    FILEGROWTH = 5
);
GO

USE lab_11
GO

IF OBJECT_ID(N'Candidate') IS NOT NULL
    DROP TABLE Candidate
GO

IF OBJECT_ID(N'Electorate') IS NOT NULL
    DROP TABLE Electorate
GO

IF OBJECT_ID(N'Voting_station') IS NOT NULL
    DROP TABLE Voting_station
GO

IF OBJECT_ID(N'District') IS NOT NULL
    DROP TABLE District

CREATE TABLE District (
    [districtNumber] INTEGER PRIMARY KEY NOT NULL,
    [districtName] VARCHAR(100) UNIQUE NOT NULL,
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

CREATE TABLE Candidate
(
    [candidateID] INTEGER IDENTITY(1, 1) PRIMARY KEY,
    [party] VARCHAR(100) NULL,
    [firstName] VARCHAR(100) NOT NULL,
    [middleName] VARCHAR(100) NOT NULL,
    [lastName] VARCHAR(100) NOT NULL,
    [education] VARCHAR(100) NULL,
    [birthDate] DATE NOT NULL,
    [districtNumber] INTEGER NOT NULL,
    CONSTRAINT FK_candidate_districtNumber FOREIGN KEY (districtNumber) REFERENCES District (districtNumber)
        ON UPDATE CASCADE
)

INSERT INTO Candidate VALUES
(
    'LDPR', 'Aleksey', 'Alekseevich', 'Pichugin', 'BMSTU', '2002-02-13', 196
),
(
    'KPRF', 'Darya', 'Nailevna', 'Ismagilova', 'BMSTU', '2001-02-19', 196
),
(
    NULL, 'Aleksey', 'Sergeevich', 'Ivanov', 'MSU', '1990-02-18', 197
),
(
    'LDPR', 'Ivan', 'Inanovich', 'Ivanov', 'MTI', '1970-07-19', 197
)

IF OBJECT_ID(N'trigger_update_candidate') IS NOT NULL
    DROP TRIGGER trigger_update_candidate
GO

CREATE TRIGGER trigger_update_candidate ON Candidate
AFTER UPDATE AS
BEGIN
    IF UPDATE(districtNumber)
        BEGIN
            RAISERROR('You can not change district', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
END
GO

CREATE TABLE Voting_station (
    [votingStationID] INTEGER IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    [number] INTEGER NOT NULL,
    [city] VARCHAR(100) NOT NULL,
    [street] VARCHAR(100) NOT NULL,
    [house] VARCHAR(100) NOT NULL,
    [phoneNumber] VARCHAR(11) NOT NULL,
    [districtNumber] INTEGER NOT NULL,
    CONSTRAINT FK_voting_station_districtNumber FOREIGN KEY (districtNumber) REFERENCES District (districtNumber)
        ON UPDATE CASCADE
)

INSERT INTO Voting_station VALUES 
(
    1, 'Moscow', 'st. Lenskaya', '18', '89808923098', 196
),
(
    2, 'Moscow', 'st. Eniseevskaya', '19', '89809876543', 196
),
(
    3, 'Moscow', 'st. Academica Pavlova', '56', '89808924567', 197
),
(
    4, 'Moscow', 'st. Marshala Timoshenko', '19', '89165627865', 197
)

IF OBJECT_ID(N'trigger_update_voting_station') IS NOT NULL
    DROP TRIGGER trigger_update_voting_station
GO

CREATE TRIGGER trigger_update_voting_station ON Voting_station
AFTER UPDATE AS
BEGIN
    IF UPDATE(votingStationId)
        BEGIN
            RAISERROR('You can not update votingStationId', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
    IF UPDATE(districtNumber)
        BEGIN
            RAISERROR('You can not change district', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
END
GO

IF OBJECT_ID(N'Electorate') IS NOT NULL
    DROP TABLE Electorate
GO

CREATE TABLE Electorate (
    [electorateId] INTEGER IDENTITY(1,1) PRIMARY KEY NOT NULL,
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
    [districtNumber] INTEGER NOT NULL,
    CONSTRAINT FK_electorate_districtNumber FOREIGN KEY (districtNumber) REFERENCES District (districtNumber)
        ON UPDATE CASCADE,
    [votingStationID] INTEGER NULL,
    CONSTRAINT FK_electorate_voting_station FOREIGN KEY (votingStationID) REFERENCES Voting_station (votingStationID)
)
GO

INSERT INTO Electorate VALUES
(
    '4616', '109876', 'Alexey', 'Alexeevich', 'Pichugin', 'Moscow', 'st. Lenskaya', '19', '2002-02-13', NULL, NULL, 196, 1
),
(
    '4616', '109846', 'Darya', 'Sergeevna', 'Petrova', 'Moscow', 'st. Lenskaya', '20', '2001-05-13', NULL, NULL, 196, 2
),
(
    '4615', '105876', 'Andrey', 'Vasilievich', 'Vinogradov', 'Moscow', 'st. Academica Pavlova', '5', '2002-02-22', NULL, NULL, 197, 3
),
(
    '4615', '103846', 'Darya', 'Nailyevna', 'Ismagilova', 'Moscow', 'st. Academica Pavlova', '1', '2001-02-19', NULL, NULL, 197, 4
)
GO

IF OBJECT_ID(N'trigger_update_electorate') IS NOT NULL
    DROP TRIGGER trigger_update_electorate
GO

CREATE TRIGGER trigger_update_electorate ON Electorate
AFTER UPDATE AS
BEGIN
    IF UPDATE(districtNumber)
        BEGIN
            RAISERROR('You can not change district', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END
END
GO


SELECT * FROM District
SELECT * FROM Candidate
SELECT * FROM Voting_station
SELECT * FROM Electorate

IF OBJECT_ID(N'view_electorate') IS NOT NULL
    DROP VIEW view_electorate
GO

CREATE VIEW view_electorate
AS
    SELECT e.electorateId, e.firstName, e.middleName, e.lastName, d.districtName, v.city AS VotingCity, v.street AS VotingStreet , v.house AS VotingHouse FROM Electorate AS e 
    LEFT JOIN Voting_station as v ON v.votingStationID = e.votingStationID
    LEFT JOIN District as d ON d.districtNumber = e.districtNumber
GO

SELECT * FROM view_electorate WHERE districtName LIKE 'Gorod Moskva - Babushkinskij odnomandatnyj izbiratelnyj okrug'
SELECT * FROM view_electorate ORDER BY electorateId DESC
GO

--Задание 4 : DISTINCT

SELECT DISTINCT party FROM Candidate

--Задание 4 : выбор, упорядочивание и именование полей (создание псевдонимов для полей и таблиц / представлений);
--соединение таблиц (INNER JOIN / LEFT JOIN / RIGHT JOIN / FULL OUTER JOIN);

SELECT e.firstName, e.middleName, e.lastName, v.city, v.street, v.house FROM Electorate AS e
    INNER JOIN Voting_station AS v ON e.votingStationID = v.votingStationID

INSERT INTO Electorate VALUES
(
    '4615', '109876', 'Alexey', 'Alexeevich', 'Pichugin', 'Moscow', 'st. Lenskaya', '19', '2002-02-13', NULL, NULL, 196, NULL
),
(
    '4614', '109846', 'Darya', 'Sergeevna', 'Petrova', 'Moscow', 'st. Lenskaya', '20', '1990-05-13', NULL, NULL, 196, NULL
),
(
    '4613', '105876', 'Andrey', 'Vasilievich', 'Vinogradov', 'Moscow', 'st. Academica Pavlova', '5', '1967-02-22', NULL, NULL, 197, NULL
),
(
    '4612', '103846', 'Darya', 'Nailyevna', 'Ismagilova', 'Moscow', 'st. Academica Pavlova', '1', '1988-02-19', NULL, NULL, 197, NULL
)
GO

SELECT e.firstName, e.middleName, e.lastName, v.city, v.street, v.house FROM Electorate AS e
    LEFT JOIN Voting_station AS v ON e.votingStationID = e.votingStationID

INSERT INTO Voting_station VALUES 
(
    5, 'Moscow', 'st. Lenskaya', '22', '89808923098', 196
)

SELECT count(e.firstName) FROM Electorate AS e
    RIGHT JOIN Voting_station AS v ON v.votingStationID = e.votingStationID

SELECT e.firstName, e.middleName, e.lastName, v.city, v.street, v.house FROM Electorate AS e
    FULL OUTER JOIN Voting_station AS v ON e.votingStationID = v.votingStationID

--Задание 4 : условия выбора записей (в том числе, условия NULL / LIKE / BETWEEN / IN / EXISTS);

SELECT * FROM Electorate WHERE phoneNumber IS NOT NULL

SELECT * FROM Electorate WHERE passportSeria LIKE '46%'

SELECT * FROM Electorate WHERE passportNumber BETWEEN 103486 AND 109846

SELECT * FROM Electorate WHERE city IN ('Moscow', 'Dubna')

SELECT * FROM Electorate AS e WHERE EXISTS (SELECT d.commisionCity FROM District as d WHERE e.city = d.commisionCity AND e.districtNumber = d.districtNumber)

--Задание 4 : сортировка записей (ORDER BY - ASC, DESC);

SELECT e.districtNumber, COUNT(*) AS countOfElectorates FROM Electorate AS e GROUP BY e.districtNumber ORDER BY countOfElectorates DESC

SELECT e.districtNumber, COUNT(*) AS countOfElectorates FROM Electorate AS e GROUP BY e.districtNumber ORDER BY countOfElectorates ASC

--Задание 4 : группировка записей (GROUP BY + HAVING, использование функций агрегирования – COUNT / AVG / SUM / MIN / MAX)

SELECT e.districtNumber, COUNT(*) AS countOfElectorates FROM Electorate AS e GROUP BY e.districtNumber

SELECT e.passportSeria,  MAX(passportNumber) FROM Electorate AS e GROUP BY e.passportSeria

SELECT e.passportSeria,  MIN(passportNumber) FROM Electorate AS e GROUP BY e.passportSeria

SELECT AVG(DATEDIFF("YYYY", BirthDate , GETDATE())) AS average_electorate_age, districtNumber 
FROM Electorate AS e GROUP BY e.districtNumber HAVING AVG(DATEDIFF("YYYY", BirthDate , GETDATE())) > 20

--Задание 4 : объединение результатов нескольких запросов (UNION / UNION ALL / EXCEPT / INTERSECT);

SELECT e.firstName, e.votingStationID, e.electorateId FROM Electorate AS e
    UNION
SELECT 'total electorates' as count_of_electorates, e.votingStationID, COUNT(*) AS countOfElectorates FROM Electorate AS e GROUP BY e.votingStationID
    ORDER BY votingStationID

SELECT e.firstName, e.votingStationID, e.electorateId FROM Electorate AS e
    UNION ALL
SELECT 'total electorates' as count_of_electorates, e.votingStationID, COUNT(*) AS countOfElectorates FROM Electorate AS e GROUP BY e.votingStationID
    ORDER BY votingStationID

SELECT votingStationID AS voting_station_id FROM Electorate
INTERSECT
SELECT votingStationId AS voting_station_id FROM Voting_station

SELECT votingStationId AS voting_station_id FROM Voting_station
EXCEPT
SELECT votingStationId AS voting_station_id FROM Electorate

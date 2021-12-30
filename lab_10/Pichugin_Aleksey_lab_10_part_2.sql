USE tempdb
GO

--Проблема 1 : «грязное» чтение (dirty read), проверка идет для уровня изоляции Read Uncommited.
--Все остальные более безопасные уровни изоляции не подвержены данной проблеме.
--Все остальные менее безопасные уровни изоляции ей подвержены.

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRANSACTION 

SELECT * FROM dbo.bank_account WHERE id = 1

COMMIT TRANSACTION

--Проблема 2 : "невоспроизводимое чтение" (non-repeatable read), проверка идет для уровня изоляции Read Committed.
--Все остальные более безопасные уровни изоляции не подвержены данной проблеме.
--Все остальные менее безопасные уровни изоляции ей подвержены.

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

BEGIN TRANSACTION

SELECT * FROM dbo.bank_account WHERE id = 1

WAITFOR DELAY '00:00:05'

SELECT * FROM dbo.bank_account WHERE id = 1

COMMIT

--Проблема 3 : "фантомное чтение" (phantom read), провекра идет для уровня изоляции Repeatable Read.
--Все остальные более безопасные уровни изоляции не подвержены данной проблеме.
--Все остальные менее безопасные уровни изоляции ей подвержены.

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

BEGIN TRANSACTION

SELECT * FROM dbo.bank_account

WAITFOR DELAY '00:00:05'

SELECT * FROM dbo.bank_account

COMMIT






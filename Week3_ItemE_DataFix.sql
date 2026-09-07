USE Restaurant;
GO


/*  1. back up the current values first so this is reversible.
    if the group wants the original data back, the rollback block at the
    bottom of this file puts it there.
*/
IF OBJECT_ID('dbo.Week3_ReservationTableBackup', 'U') IS NOT NULL
	DROP TABLE dbo.Week3_ReservationTableBackup;
GO

SELECT ReservationID, TableID AS OriginalTableID
INTO dbo.Week3_ReservationTableBackup
FROM dbo.Reservations;
GO

SELECT COUNT(*) AS RowsBackedUp,
	CASE WHEN COUNT(*) = 100 THEN 'OK' ELSE 'STOP - expected 100' END AS Result
FROM dbo.Week3_ReservationTableBackup;
GO


/*  2. the split before the change, so the before and after can be compared
    in the writeup. expecting 1 / 87 / 12.
*/
SELECT 'BEFORE' AS Stage,
	SUM(CASE WHEN r.TableID IS NULL THEN 1 ELSE 0 END) AS NoTableAssigned,
	SUM(CASE WHEN r.TableID = c.PreferredTable THEN 1 ELSE 0 END) AS GotFavoriteTable,
	SUM(CASE WHEN r.TableID IS NOT NULL
		AND r.TableID <> c.PreferredTable THEN 1 ELSE 0 END) AS DidNotGetFavorite,
	COUNT(*) AS TotalReservations
FROM dbo.Reservations r
	JOIN dbo.Customers c ON c.CustomerID = r.CustomerID;
GO


/*  3. the change itself. every third reservation that already has a table
    gets pointed at that customer's preferred table.

    the TableID IS NOT NULL test matters. without it this would fill in the
    12 unassigned reservations too and the "could not be seated at their
    preferred table" requirement would lose its evidence.

    PreferredTable is a foreign key to ResTables, so every value written
    here is already a valid table number. no orphan rows can be created.

    should report 33 rows affected.
*/
UPDATE r
SET r.TableID = c.PreferredTable
FROM dbo.Reservations r
	JOIN dbo.Customers c ON c.CustomerID = r.CustomerID
WHERE r.ReservationID % 3 = 0
	AND r.TableID IS NOT NULL
	AND c.PreferredTable IS NOT NULL;
GO


/*  4. the split after the change. expecting 33 / 55 / 12.
    this is the grid worth screenshotting next to the BEFORE grid.
*/
SELECT 'AFTER' AS Stage,
	SUM(CASE WHEN r.TableID IS NULL THEN 1 ELSE 0 END) AS NoTableAssigned,
	SUM(CASE WHEN r.TableID = c.PreferredTable THEN 1 ELSE 0 END) AS GotFavoriteTable,
	SUM(CASE WHEN r.TableID IS NOT NULL
		AND r.TableID <> c.PreferredTable THEN 1 ELSE 0 END) AS DidNotGetFavorite,
	COUNT(*) AS TotalReservations
FROM dbo.Reservations r
	JOIN dbo.Customers c ON c.CustomerID = r.CustomerID;
GO


/*  5. nothing else moved. row count is still 100, no reservation lost its
    customer, and no TableID points at a table that does not exist.
*/
SELECT
	(SELECT COUNT(*) FROM dbo.Reservations) AS ReservationRows,
	(SELECT COUNT(*) FROM dbo.Reservations WHERE CustomerID IS NULL) AS OrphanedRows,
	(SELECT COUNT(*) FROM dbo.Reservations r
		WHERE r.TableID IS NOT NULL
			AND NOT EXISTS (SELECT 1 FROM dbo.ResTables t
				WHERE t.TableID = r.TableID)) AS InvalidTableIDs,
	CASE WHEN (SELECT COUNT(*) FROM dbo.Reservations) = 100
		THEN 'OK' ELSE 'STOP - row count changed' END AS Result;
GO


-- ============================================================================
-- ROLLBACK. only run this block if the change needs to be undone. it is
-- commented out so it cannot fire by accident when the file is run whole.
-- ============================================================================
/*
UPDATE r
SET r.TableID = b.OriginalTableID
FROM dbo.Reservations r
	JOIN dbo.Week3_ReservationTableBackup b ON b.ReservationID = r.ReservationID;
GO
*/
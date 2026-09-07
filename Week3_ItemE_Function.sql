USE Restaurant;
GO


/*  drop both first so this file can be run again without editing it.
    the counts function goes first because it depends on the detail one.
*/
IF OBJECT_ID('dbo.fnReservationFavoriteTableCounts', 'IF') IS NOT NULL
	DROP FUNCTION dbo.fnReservationFavoriteTableCounts;
GO

IF OBJECT_ID('dbo.fnReservationFavoriteTable', 'IF') IS NOT NULL
	DROP FUNCTION dbo.fnReservationFavoriteTable;
GO


/*  ------------------------------------------------------------------------
    FUNCTION 1 of 2 - the reservations themselves.

    An inline table valued function rather than a scalar or multi statement
    one. Inline means the optimizer folds the body into the calling query the
    way it would a view, so it can still use the indexes on Reservations and
    Customers instead of building a table variable row by row.

    GotFavoriteTable is returned as a bit alongside the text Outcome so the
    result can be filtered or summed without parsing a string.
    ------------------------------------------------------------------------ */
CREATE FUNCTION dbo.fnReservationFavoriteTable()
RETURNS TABLE
AS
RETURN
	SELECT
		r.ReservationID,
		r.ReservationDateTime,
		r.CustomerID,
		c.FirstName + ' ' + c.LastName AS CustomerName,
		c.PreferredTable AS FavoriteTable,
		r.TableID AS TableAssigned,
		r.Recurring,
		r.Cancelled,
		CASE
			WHEN r.Cancelled = 1 THEN '4 - Reservation cancelled'
			WHEN r.TableID IS NULL THEN '3 - No table assigned'
			WHEN r.TableID = c.PreferredTable THEN '1 - Got favorite table'
			ELSE '2 - Did not get favorite table'
		END AS Outcome,
		CASE
			WHEN r.Cancelled = 0
				AND r.TableID IS NOT NULL
				AND r.TableID = c.PreferredTable
			THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT)
		END AS GotFavoriteTable
	FROM dbo.Reservations r
		JOIN dbo.Customers c ON c.CustomerID = r.CustomerID;
GO


/*  ------------------------------------------------------------------------
    FUNCTION 2 of 2 - how many.

    Selects from the function above so the classification is not written
    twice. SUM(COUNT(*)) OVER () gives every row the grand total without a
    second pass over the data, which is what turns the raw count into a
    percentage.
    ------------------------------------------------------------------------ */
CREATE FUNCTION dbo.fnReservationFavoriteTableCounts()
RETURNS TABLE
AS
RETURN
	SELECT
		Outcome,
		COUNT(*) AS NumReservations,
		SUM(COUNT(*)) OVER () AS TotalReservations,
		CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()
			AS DECIMAL(5,2)) AS PercentOfAll
	FROM dbo.fnReservationFavoriteTable()
	GROUP BY Outcome;
GO


-- ============================================================================
-- TESTING. everything below proves the two functions above were created and
-- run. these are the grids to screenshot.
-- ============================================================================

/*  TEST 1. both functions exist in the database.
    the project states an object missing from the instance scores nothing,
    so this is the proof they were actually deployed.

    every week 3 function is listed, not just these two, so the same
    screenshot also shows that creating item E left items A, C and D alone.
*/
SELECT name AS FunctionName, type_desc AS ObjectType, create_date AS Created,
	CASE
		WHEN name IN ('fnReservationFavoriteTable',
			'fnReservationFavoriteTableCounts') THEN 'Item E - this file'
		WHEN name IN ('fnChefSalary', 'fnMenuPrices') THEN 'Items A and C - PR 15'
		WHEN name = 'fnOrderMethodSum' THEN 'Item D - PR 16'
		ELSE 'not a week 3 deliverable'
	END AS Deliverable
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF')
ORDER BY Deliverable, name;
GO


/*  TEST 2. the headline answer. how many patrons got their favorite table
    and how many did not.
    expecting 33 got their favorite, 55 did not, 12 unassigned, 8 cancelled.
*/
SELECT Outcome, NumReservations, TotalReservations, PercentOfAll
FROM dbo.fnReservationFavoriteTableCounts()
ORDER BY Outcome;
GO


/*  TEST 3. the same answer stated as the plain two way split the
    requirement literally asks for, ignoring cancelled bookings.
*/
SELECT
	SUM(CASE WHEN GotFavoriteTable = 1 THEN 1 ELSE 0 END) AS ReceivedFavoriteTable,
	SUM(CASE WHEN GotFavoriteTable = 0 THEN 1 ELSE 0 END) AS DidNotReceiveFavoriteTable,
	COUNT(*) AS TotalReservations
FROM dbo.fnReservationFavoriteTable()
WHERE Cancelled = 0;
GO


/*  TEST 4. the reservations themselves, which is the first half of the
    requirement. top 25 so the grid fits in one screenshot.
*/
SELECT TOP 25
	ReservationID, ReservationDateTime, CustomerName,
	FavoriteTable, TableAssigned, Recurring, Cancelled, Outcome
FROM dbo.fnReservationFavoriteTable()
ORDER BY ReservationID;
GO


/*  TEST 5. proof the classification is right, not just plausible. this pulls
    a few rows of each outcome so the FavoriteTable and TableAssigned columns
    can be eyeballed against the Outcome text on the same line.
*/
SELECT ReservationID, CustomerName, FavoriteTable, TableAssigned,
	Cancelled, Outcome
FROM (
	SELECT ROW_NUMBER() OVER (PARTITION BY Outcome ORDER BY ReservationID) AS rn,
		ReservationID, CustomerName, FavoriteTable, TableAssigned,
		Cancelled, Outcome
	FROM dbo.fnReservationFavoriteTable()
) x
WHERE rn <= 3
ORDER BY Outcome, ReservationID;
GO


/*  TEST 6. the function is a real function and takes part in a normal query.
    this joins it back to the recurring bookings only, showing it can be
    filtered and aggregated like any table.
*/
SELECT Outcome, COUNT(*) AS RecurringReservations
FROM dbo.fnReservationFavoriteTable()
WHERE Recurring = 1
GROUP BY Outcome
ORDER BY Outcome;
GO
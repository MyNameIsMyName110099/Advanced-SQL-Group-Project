USE Restaurant
GO

DROP FUNCTION IF EXISTS fnReservationFavoriteTableCounts;
DROP FUNCTION IF EXISTS fnReservationFavoriteTable;
DROP FUNCTION IF EXISTS fnFavoriteTableCounts;
GO

--E. function returns each reservation and whether that patron got their favorite table
CREATE FUNCTION fnReservationFavoriteTable()
RETURNS TABLE
AS
RETURN
(
	SELECT r.ReservationID, r.ReservationDateTime AS 'Reservation',
		CONCAT(c.FirstName, ' ', c.LastName) AS 'Customer',
		c.PreferredTable AS 'Favorite Table', r.TableID AS 'Table Assigned',
		CASE WHEN r.TableID = c.PreferredTable THEN 'Yes' ELSE 'No' END
			AS 'Got Favorite Table'
	FROM Reservations r
		INNER JOIN Customers c ON r.CustomerID = c.CustomerID
);
GO

--E. function returns how many patrons got their favorite table and how many did not
CREATE FUNCTION fnFavoriteTableCounts()
RETURNS TABLE
AS
RETURN
(
	SELECT ISNULL(CASE WHEN r.TableID = c.PreferredTable THEN 'Yes' ELSE 'No' END,
			'All Reservations') AS 'Got Favorite Table',
		COUNT(*) AS 'Reservations'
	FROM Reservations r
		INNER JOIN Customers c ON r.CustomerID = c.CustomerID
	GROUP BY ROLLUP(CASE WHEN r.TableID = c.PreferredTable THEN 'Yes' ELSE 'No' END)
);
GO

/* SELECT * FROM fnReservationFavoriteTable();
SELECT * FROM fnFavoriteTableCounts();
*/

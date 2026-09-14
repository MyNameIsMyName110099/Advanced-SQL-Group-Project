USE Restaurant
GO

-- Week 2 seed data only gave 1 of 100 reservations its preferred table, because
-- Customers.PreferredTable and Reservations.TableID were generated separately.
-- Every third assigned reservation is repointed so Item E has a realistic split.
-- Run once, before Week3_ItemE_Function.sql.
UPDATE r
SET r.TableID = c.PreferredTable
FROM Reservations r
	INNER JOIN Customers c ON r.CustomerID = c.CustomerID
WHERE r.ReservationID % 3 = 0 AND r.TableID IS NOT NULL;
GO

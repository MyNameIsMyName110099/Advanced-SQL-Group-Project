USE Restaurant;
GO


-- ============================================================================
-- Drop the indexes if they already exist so this file can be re-run.
-- ============================================================================
DROP INDEX IF EXISTS IX_Charities_DonatingLocationID ON Charities;
DROP INDEX IF EXISTS IX_Dishname_Price ON Dishes;
DROP INDEX IF EXISTS IX_Recipes_DishID ON Recipes;
DROP INDEX IF EXISTS IX_Transactions_OrderDateTime ON Transactions;
DROP INDEX IF EXISTS IX_TransactionDetails_TransactionID ON TransactionDetails;
DROP INDEX IF EXISTS IX_CustomerID ON Reservations;
GO


-- ============================================================================
-- ITEM 2 - INDEXES
--
-- All are nonclustered because each table's primary key already took the one
-- clustered index a table gets. INCLUDE adds columns to the index so the
-- query can be answered without going back to the table.
-- ============================================================================

-- ============================================================================
-- Index d - Charities
-- Mason Romdenne
--
-- DonatingLocationID is the foreign key to Demographic, so it is what the
-- join and any "charities for this branch" filter run on, and SQL Server
-- does not index foreign keys on its own. CharityID is already the primary
-- key and CharityName already has a unique constraint, so neither needed
-- one. Name and donated total are included for the donation report.
-- ============================================================================
CREATE NONCLUSTERED INDEX IX_Charities_DonatingLocationID
	ON Charities (DonatingLocationID)
	INCLUDE (CharityName, TotalDonatedValue);
GO


-- ============================================================================
-- Index e - Dishes
-- Nicholas Fearing
--
-- I chose Dishname and Price to make a covering index for fnMenuPrices().
-- ============================================================================
CREATE INDEX IX_Dishname_Price
ON Dishes (Dishname, Price);
GO


-- ============================================================================
-- Index i - Recipes
-- Nathan Krouth
--
-- Key already takes up clustered index so this one is unclustered. I decided
-- to use the DishID for this index since it is mandatory when looking into
-- this table to find all ingredients belonging to a specific dish. I am
-- including the IngredientID and Quantity so this may work as a recipe book
-- as well.
-- ============================================================================
CREATE NONCLUSTERED INDEX IX_Recipes_DishID
	ON Recipes (DishID)
	INCLUDE (IngredientID, QuantityUsed);
GO


-- ============================================================================
-- Index l - Transactions (and TransactionDetails)
-- Mason Romdenne
--
-- The restaurant keeps three years of orders and nearly every question is a
-- date range (sales this month, orders last week), which scans the whole
-- table without an index on OrderDateTime. TransactionID and BillingNumber
-- are already indexed by their constraints, and OrderChannel and
-- PaymentMethod only have a handful of values so an index on them would not
-- narrow much. Total and channel are included since date queries sum and
-- group by them.
-- ============================================================================
CREATE NONCLUSTERED INDEX IX_Transactions_OrderDateTime
	ON Transactions (OrderDateTime)
	INCLUDE (OrderTotal, OrderChannel);
GO

-- TransactionDetails as well, since item l's order total is built from this
-- table. TransactionID is the foreign key back to the order and "lines on
-- this bill" is the only way the table is ever read, but the primary key is
-- TransactionDetailID so that lookup had no index. Dish, quantity and price
-- are included so printing a bill only touches the index.
CREATE NONCLUSTERED INDEX IX_TransactionDetails_TransactionID
	ON TransactionDetails (TransactionID)
	INCLUDE (DishID, Quantity, UnitPrice);
GO


-- ============================================================================
-- Index p - Reservations
-- Nicholas Fearing
--
-- I chose CustomerID because it is both a FK and it is used in a join by
-- fnReservationFavoriteTable().
-- ============================================================================
CREATE INDEX IX_CustomerID
ON Reservations (CustomerID);
GO


-- ============================================================================
-- TESTING
--
-- Lists the six indexes, then runs the query each one was built for.
-- Turn on Include Actual Execution Plan (Ctrl+M) before running the
-- queries to see the Index Seek on each new index.
-- ============================================================================

-- the six indexes exist
SELECT OBJECT_NAME(object_id) AS 'Table', name AS 'Index'
FROM sys.indexes
WHERE name LIKE 'IX[_]%'
ORDER BY 1;

-- d  Charities - charities for one branch
SELECT CharityName, TotalDonatedValue FROM Charities WHERE DonatingLocationID = 1;

-- e  Dishes - the menu price list (what fnMenuPrices reads)
SELECT DishName, Price FROM Dishes ORDER BY DishName;

-- i  Recipes - the ingredients for one dish
SELECT IngredientID, QuantityUsed FROM Recipes WHERE DishID = 1;

-- l  Transactions - sales by channel for a date range
SELECT OrderChannel, COUNT(*) AS 'Orders', SUM(OrderTotal) AS 'Sales'
FROM Transactions
WHERE OrderDateTime >= '2026-04-01' AND OrderDateTime < '2026-04-16'
GROUP BY OrderChannel;

-- l  TransactionDetails - the lines on one bill
SELECT DishID, Quantity, UnitPrice FROM TransactionDetails WHERE TransactionID = 500001;

-- p  Reservations - one customer's reservations
SELECT ReservationID, ReservationDateTime, TableID FROM Reservations WHERE CustomerID = 1;
GO

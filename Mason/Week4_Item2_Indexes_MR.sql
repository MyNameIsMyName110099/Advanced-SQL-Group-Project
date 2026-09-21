USE Restaurant;
GO

DROP INDEX IF EXISTS IX_Charities_DonatingLocationID ON Charities;
DROP INDEX IF EXISTS IX_Transactions_OrderDateTime ON Transactions;
DROP INDEX IF EXISTS IX_TransactionDetails_TransactionID ON TransactionDetails;
GO

-- all three are nonclustered because the primary key already took the one
-- clustered index each table gets. INCLUDE adds columns to the index so
-- the query can be answered without going back to the table.

-- Week 2 item d - Charities.
-- DonatingLocationID is the foreign key to Demographic, so it is what the
-- join and any "charities for this branch" filter run on, and SQL Server
-- does not index foreign keys on its own. CharityID is already the primary
-- key and CharityName already has a unique constraint, so neither needed
-- one. Name and donated total are included for the donation report.
CREATE NONCLUSTERED INDEX IX_Charities_DonatingLocationID
	ON Charities (DonatingLocationID)
	INCLUDE (CharityName, TotalDonatedValue);
GO

-- Week 2 item l - Transactions.
-- the restaurant keeps three years of orders and nearly every question is
-- a date range (sales this month, orders last week), which scans the whole
-- table without an index on OrderDateTime. TransactionID and BillingNumber
-- are already indexed by their constraints, and OrderChannel and
-- PaymentMethod only have a handful of values so an index on them would not
-- narrow much. Total and channel are included since date queries sum and
-- group by them.
CREATE NONCLUSTERED INDEX IX_Transactions_OrderDateTime
	ON Transactions (OrderDateTime)
	INCLUDE (OrderTotal, OrderChannel);
GO

-- TransactionDetails, added as well since the group assigned "transaction
-- details" and item l's order total is built from this table.
-- TransactionID is the foreign key back to the order and "lines on this
-- bill" is the only way the table is ever read, but the primary key is
-- TransactionDetailID so that lookup had no index. Dish, quantity and
-- price are included so printing a bill only touches the index.
CREATE NONCLUSTERED INDEX IX_TransactionDetails_TransactionID
	ON TransactionDetails (TransactionID)
	INCLUDE (DishID, Quantity, UnitPrice);
GO

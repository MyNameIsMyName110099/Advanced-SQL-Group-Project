-- ============================================================================
-- Advanced SQL Semester Project
-- Week 4 Deliverables - Items 1, 2 and 3
--
-- Mason Romdenne, Nathan Krouth, Nicholas Fearing
-- Prepared by Mason Romdenne
-- Database: Restaurant
--
-- Item 1  Five stored procedures (a through e)
--   spN_ChefDetails        requirement a   Mason
--   spN_RecipeDetails      requirement b   Nathan
--   spN_DishDetails        requirement c   Nathan
--   spN_KitchenDetails     requirement d   Nicholas
--   spN_CustomerDetails    requirement e   Nathan
--
-- Item 2  One index on each of five Week 2 tables
--   d  Charities           Mason
--   e  Dishes              Nicholas
--   i  Recipes             Nathan
--   l  Transactions        Mason  (plus TransactionDetails)
--   p  Reservations        Nicholas
--
-- Item 3  CRUD stored procedures on two tables, Charities and KitchenDetails
--   spN_Get...             Mason
--   spN_Insert...          Mason
--   spN_Update...          Nicholas
--   spN_Delete...          Nathan
--
-- Requirement c is named spN_RecipeDetails in the project document, the same
-- name as requirement b, so it is spN_DishDetails here.
--
-- Item 1a needs a link between a supplier and the items it sells, which the
-- Week 2 schema did not have, so a SupplierIngredients table is created and
-- filled at the top of this file.
--
-- Money columns use FORMAT(value, 'C', 'en-IE') so SQL Server supplies the
-- euro sign for the Irish locale rather than it being hardcoded.
--
-- Each object is written by the group member named above it and was reviewed
-- and merged through a pull request on the group's GitHub repo.
--
-- Run the whole file at once. Every object is dropped first if it already
-- exists, so it can be run again without editing. The TESTING section at the
-- bottom calls every procedure and is the testing code for this submission.
-- ============================================================================

USE Restaurant;
GO


-- ============================================================================
-- Drop everything this file creates so it can be re-run.
-- ============================================================================
DROP PROCEDURE IF EXISTS spN_ChefDetails;
DROP PROCEDURE IF EXISTS spN_RecipeDetails;
DROP PROCEDURE IF EXISTS spN_DishDetails;
DROP PROCEDURE IF EXISTS spN_KitchenDetails;
DROP PROCEDURE IF EXISTS spN_CustomerDetails;

DROP PROCEDURE IF EXISTS spN_GetCharities;
DROP PROCEDURE IF EXISTS spN_InsertCharities;
DROP PROCEDURE IF EXISTS spN_UpdateCharities;
DROP PROCEDURE IF EXISTS spN_DeleteCharities;
DROP PROCEDURE IF EXISTS spN_GetKitchenDetails;
DROP PROCEDURE IF EXISTS spN_InsertKitchenDetails;
DROP PROCEDURE IF EXISTS spN_UpdateKitchenDetails;
DROP PROCEDURE IF EXISTS spN_DeleteKitchenDetails;

DROP INDEX IF EXISTS IX_Charities_DonatingLocationID ON Charities;
DROP INDEX IF EXISTS IX_Dishname_Price ON Dishes;
DROP INDEX IF EXISTS IX_Recipes_DishID ON Recipes;
DROP INDEX IF EXISTS IX_Transactions_OrderDateTime ON Transactions;
DROP INDEX IF EXISTS IX_TransactionDetails_TransactionID ON TransactionDetails;
DROP INDEX IF EXISTS IX_CustomerID ON Reservations;

DROP TABLE IF EXISTS SupplierIngredients;
GO


-- ============================================================================
-- ITEM 1 - STORED PROCEDURES
-- ============================================================================

-- ============================================================================
-- Supporting table for 1a - SupplierIngredients
-- Mason Romdenne
--
-- What each supplier sells and what they charge for it. Nothing in the Week 2
-- schema linked a supplier to its items, so this is needed before
-- spN_ChefDetails can be written.
-- ============================================================================
CREATE TABLE SupplierIngredients (
	SupplierIngredientID INT IDENTITY(1,1) NOT NULL,
	SupplierID INT NOT NULL,
	IngredientID INT NOT NULL,
	SupplierPrice DECIMAL(10,2) NOT NULL,
	IsActive BIT NOT NULL DEFAULT 1,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	CONSTRAINT PK_SupplierIngredients PRIMARY KEY (SupplierIngredientID),
	CONSTRAINT UQ_SupplierIngredients_SupplierIngredient
		UNIQUE (SupplierID, IngredientID),
	CONSTRAINT FK_SupplierIngredients_Suppliers FOREIGN KEY (SupplierID)
		REFERENCES Suppliers (SupplierID),
	CONSTRAINT FK_SupplierIngredients_Ingredients FOREIGN KEY (IngredientID)
		REFERENCES Ingredients (IngredientID),
	CONSTRAINT CK_SupplierIngredients_Price_Positive CHECK (SupplierPrice >= 0)
);
GO

-- fill it. pairs every supplier with every ingredient and keeps one pair in
-- fifteen, which works out to 4 items per supplier and 400 rows. the price
-- is the ingredient cost plus a markup based on the supplier id, so each
-- vendor charges something different and it comes out the same every run.
INSERT INTO SupplierIngredients (SupplierID, IngredientID, SupplierPrice)
SELECT s.SupplierID, i.IngredientID,
	CAST(i.IngredientCost * (1 + (s.SupplierID % 5) / 20.0) AS DECIMAL(10,2))
FROM Suppliers s
	CROSS JOIN Ingredients i
WHERE (s.SupplierID + i.IngredientID) % 15 = 0;
GO


-- ============================================================================
-- Procedure 1a - spN_ChefDetails
-- Mason Romdenne
--
-- "Return the chef(s) that have a preferred vendor and what item(s) these
--  chefs prefer from these vendors. Also include the price for these items.
--  Ensure the item price is in Irish Pounds and do NOT hardcode the euro
--  dollar sign."
--
-- The INNER JOIN on Suppliers drops any chef with no preferred vendor.
-- ============================================================================
CREATE PROCEDURE spN_ChefDetails
AS
BEGIN
	SET NOCOUNT ON;

	SELECT c.ChefID,
		CONCAT(e.FirstName, ' ', e.LastName) AS 'Chef Name',
		c.ChefType AS 'Chef Type',
		s.SupplierName AS 'Preferred Vendor',
		i.IngredientName AS 'Item',
		FORMAT(si.SupplierPrice, 'C', 'en-IE') AS 'Item Price'
	FROM Chefs c
		INNER JOIN Employees e ON c.EmployeeID = e.EmployeeID
		INNER JOIN Suppliers s ON c.PreferredSupplierID = s.SupplierID
		INNER JOIN SupplierIngredients si ON s.SupplierID = si.SupplierID
		INNER JOIN Ingredients i ON si.IngredientID = i.IngredientID
	WHERE si.IsActive = 1
	ORDER BY e.LastName, e.FirstName, i.IngredientName;
END;
GO


-- ============================================================================
-- Procedure 1b - spN_RecipeDetails
-- Nathan Krouth
--
-- "Return the sum of the ingredients by recipe. Also included with this will
--  be the recipe items. Ensure the totaldue is in Irish Pounds and do NOT
--  hardcode the euro dollar sign."
--
-- Selects all of the ingredients for each dish then tallies up the cost for
-- all of the ingredients. ROLLUP adds a subtotal row per dish (IngredientName
-- is NULL) and a grand total row at the top (both columns NULL).
-- ============================================================================
CREATE PROC spN_RecipeDetails

AS

SELECT DishID, IngredientName, FORMAT(SUM(IngredientCost * QuantityUsed), 'C', 'en-IE') AS RecipeCost
FROM Recipes r
	JOIN Ingredients i
		ON r.IngredientID = i.IngredientID
GROUP BY ROLLUP(DishID, IngredientName)
ORDER BY DishID
GO


-- ============================================================================
-- Procedure 1c - spN_DishDetails
-- Nathan Krouth
--
-- "Show me the ingredients used in each recipe and the prices listed for
--  those dishes that use the ingredients. Ensure the totaldue is in Irish
--  Pounds and do NOT hardcode the euro dollar sign."
--
-- Returns a dish's details, each ingredient in it, and the menu price of the
-- dish itself.
-- ============================================================================
CREATE PROC spN_DishDetails

AS

SELECT r.DishID, d.DishName, r.IngredientID, IngredientName, FORMAT(Price, 'C', 'en-IE') AS DishCost
FROM Dishes d
	JOIN Recipes r
		ON d.DishID = r.DishID
	JOIN Ingredients i
		ON i.IngredientID = r.IngredientID
GROUP BY r.DishID, d.DishName, r.IngredientID, IngredientName, Price
GO


-- ============================================================================
-- Procedure 1d - spN_KitchenDetails
-- Nicholas Fearing
--
-- "Show me the kitchen details. These details can either be all records or
--  by individual chef. Call this stored procedure spN_KitchenDetails."
--
-- Returns all columns from KitchenDetails. If the parameter is left empty it
-- returns all rows, otherwise only the row with the matching LeadChef.
-- ============================================================================
CREATE PROCEDURE spN_KitchenDetails
	@LeadChef int = NULL
AS
BEGIN
	BEGIN TRY
		SELECT *
		FROM KitchenDetails
		WHERE @LeadChef IS NULL OR @LeadChef = LeadChef
	END TRY
	BEGIN CATCH
		PRINT 'An error occured while searching for Chef #' +
			CONVERT(varchar, @LeadChef, 1) + '.'
	END CATCH
END;
GO


-- ============================================================================
-- Procedure 1e - spN_CustomerDetails
-- Nathan Krouth
--
-- "Return information on the customers that dine at the restaurant. This
--  stored procedure should be able to run and return individual customer
--  information."
--
-- Returns the details of all customers, with a formatted name to make it a
-- bit more neat. The optional @CustomerID parameter returns one customer.
-- ============================================================================
CREATE PROC spN_CustomerDetails
	@CustomerID INT = NULL
AS

SELECT FirstName + ' ' + LastName AS CustName, Email, PhoneNumber,
	PreferredTable, PreferredServer, PreferredRes, PreferredOrder,
	Birthday
FROM Customers
WHERE @CustomerID IS NULL OR CustomerID = @CustomerID
ORDER BY CustName ASC
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
-- ITEM 3 - CRUD STORED PROCEDURES
--
-- The two tables are Charities and KitchenDetails, chosen because nothing
-- else has a foreign key pointing at them, so the DELETE procedures can run
-- without breaking a relationship. The project says each procedure "should
-- not generate any exceptions and all should return data", so the INSERT
-- procedures check for anything that would trip a constraint and return a
-- Rejected message instead of letting SQL Server throw, and every procedure
-- returns a result set.
--
--   SELECT   spN_GetCharities        spN_GetKitchenDetails       Mason
--   INSERT   spN_InsertCharities     spN_InsertKitchenDetails    Mason
--   UPDATE   spN_UpdateCharities     spN_UpdateKitchenDetails    Nicholas
--   DELETE   spN_DeleteCharities     spN_DeleteKitchenDetails    Nathan
-- ============================================================================

-- ============================================================================
-- SELECT - spN_GetCharities
-- Mason Romdenne
--
-- Takes the primary key as an optional parameter, so with no argument it
-- returns every row and with an ID it returns just that one. Shows the
-- branch name instead of the LocationID. LEFT JOIN because a charity does
-- not have to be assigned to a branch.
-- ============================================================================
CREATE PROCEDURE spN_GetCharities
	@CharityID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT c.CharityID,
		c.CharityName AS 'Charity',
		c.CharityType AS 'Type',
		c.ContactName AS 'Contact',
		c.PhoneNumber AS 'Phone',
		c.City,
		d.LocationName AS 'Donating Branch',
		FORMAT(c.TotalDonatedValue, 'C', 'en-IE') AS 'Total Donated',
		CASE WHEN c.IsActive = 1 THEN 'Yes' ELSE 'No' END AS 'Active',
		c.CreationDate AS 'Created'
	FROM Charities c
		LEFT JOIN Demographic d ON c.DonatingLocationID = d.LocationID
	WHERE (@CharityID IS NULL OR c.CharityID = @CharityID)
	ORDER BY c.CharityName;
END;
GO


-- ============================================================================
-- SELECT - spN_GetKitchenDetails
-- Mason Romdenne
--
-- Kitchens with the branch name and the lead chef's name. The chef name goes
-- through Chefs to Employees since Chefs only stores an EmployeeID.
-- ============================================================================
CREATE PROCEDURE spN_GetKitchenDetails
	@KitchenID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT k.KitchenID,
		d.LocationName AS 'Branch',
		k.NumStoves AS 'Stoves',
		k.AreaSqft AS 'Area (sq ft)',
		k.MinCooks AS 'Min Cooks',
		CONCAT(e.FirstName, ' ', e.LastName) AS 'Lead Chef',
		c.ChefType AS 'Lead Chef Type',
		k.FreezerCubicFeet AS 'Freezer (cu ft)',
		k.LastInspectionDate AS 'Last Inspection',
		CASE k.InspectionPassed
			WHEN 1 THEN 'Passed'
			WHEN 0 THEN 'Failed'
			ELSE 'Not yet inspected'
		END AS 'Inspection Result',
		k.InspectionComments AS 'Inspection Comments',
		k.CreationDate AS 'Created'
	FROM KitchenDetails k
		INNER JOIN Demographic d ON k.LocationID = d.LocationID
		INNER JOIN Chefs c ON k.LeadChef = c.ChefID
		INNER JOIN Employees e ON c.EmployeeID = e.EmployeeID
	WHERE (@KitchenID IS NULL OR k.KitchenID = @KitchenID)
	ORDER BY k.KitchenID;
END;
GO


-- ============================================================================
-- INSERT - spN_InsertCharities
-- Mason Romdenne
--
-- Every column a user can fill in is a parameter. CreationDate is left out so
-- its default of SYSDATETIME() records when the row was inserted.
-- CharityName is required, the rest can be left off. Checks a blank name, a
-- duplicate name (unique constraint), a branch that does not exist (foreign
-- key) and a negative donation total. On a good call it returns the row it
-- just inserted.
-- ============================================================================
CREATE PROCEDURE spN_InsertCharities
	@CharityName NVARCHAR(100),
	@CharityType NVARCHAR(50) = NULL,
	@ContactName NVARCHAR(100) = NULL,
	@PhoneNumber NVARCHAR(20) = NULL,
	@City NVARCHAR(50) = NULL,
	@DonatingLocationID INT = NULL,
	@TotalDonatedValue DECIMAL(10,2) = NULL,
	@IsActive BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	IF @CharityName IS NULL OR LTRIM(RTRIM(@CharityName)) = ''
	BEGIN
		SELECT 'Rejected - a charity name is required.' AS 'Result';
		RETURN 1;
	END;

	IF EXISTS (SELECT 1 FROM Charities WHERE CharityName = @CharityName)
	BEGIN
		SELECT CONCAT('Rejected - ', @CharityName, ' already exists.') AS 'Result';
		RETURN 1;
	END;

	IF @DonatingLocationID IS NOT NULL
		AND NOT EXISTS (SELECT 1 FROM Demographic WHERE LocationID = @DonatingLocationID)
	BEGIN
		SELECT CONCAT('Rejected - no location with ID ', @DonatingLocationID, '.') AS 'Result';
		RETURN 1;
	END;

	IF @TotalDonatedValue < 0
	BEGIN
		SELECT 'Rejected - the donated total cannot be negative.' AS 'Result';
		RETURN 1;
	END;

	INSERT INTO Charities
		(CharityName, CharityType, ContactName, PhoneNumber, City,
		DonatingLocationID, TotalDonatedValue, IsActive)
	VALUES
		(@CharityName, @CharityType, @ContactName, @PhoneNumber, @City,
		@DonatingLocationID, @TotalDonatedValue, @IsActive);

	-- return the new row so the ID and CreationDate show up
	SELECT * FROM Charities WHERE CharityID = SCOPE_IDENTITY();
	RETURN 0;
END;
GO


-- ============================================================================
-- INSERT - spN_InsertKitchenDetails
-- Mason Romdenne
--
-- Six required parameters for the six NOT NULL columns; the inspection
-- columns can be left off since a new kitchen has not been inspected yet.
-- Checks the branch and the chef exist (both foreign keys) and that the
-- sizes and counts are above zero.
-- ============================================================================
CREATE PROCEDURE spN_InsertKitchenDetails
	@LocationID INT,
	@NumStoves INT,
	@AreaSqft INT,
	@MinCooks INT,
	@LeadChef INT,
	@FreezerCubicFeet INT,
	@LastInspectionDate DATETIME = NULL,
	@InspectionComments NVARCHAR(500) = NULL,
	@InspectionPassed BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM Demographic WHERE LocationID = @LocationID)
	BEGIN
		SELECT CONCAT('Rejected - no location with ID ', ISNULL(@LocationID, 0), '.') AS 'Result';
		RETURN 1;
	END;

	IF NOT EXISTS (SELECT 1 FROM Chefs WHERE ChefID = @LeadChef)
	BEGIN
		SELECT CONCAT('Rejected - no chef with ID ', ISNULL(@LeadChef, 0), '.') AS 'Result';
		RETURN 1;
	END;

	IF ISNULL(@NumStoves, 0) <= 0 OR ISNULL(@AreaSqft, 0) <= 0
		OR ISNULL(@MinCooks, 0) <= 0 OR ISNULL(@FreezerCubicFeet, 0) <= 0
	BEGIN
		SELECT 'Rejected - stoves, area, min cooks and freezer size must be above zero.' AS 'Result';
		RETURN 1;
	END;

	INSERT INTO KitchenDetails
		(LocationID, NumStoves, AreaSqft, MinCooks, LeadChef, FreezerCubicFeet,
		LastInspectionDate, InspectionComments, InspectionPassed)
	VALUES
		(@LocationID, @NumStoves, @AreaSqft, @MinCooks, @LeadChef, @FreezerCubicFeet,
		@LastInspectionDate, @InspectionComments, @InspectionPassed);

	SELECT * FROM KitchenDetails WHERE KitchenID = SCOPE_IDENTITY();
	RETURN 0;
END;
GO


-- ============================================================================
-- UPDATE - spN_UpdateKitchenDetails
-- Nicholas Fearing
--
-- UPDATE stored proc on KitchenDetails table for inputting inspection data.
-- Proc takes four parameters:
--   KitchenID int (to identify row to be updated),
--   Comments nvarchar(500),
--   InspectionPassed bit,
--   LastInspectionDate datetime (defaults to day and time of update if not given)
-- Returns the updated row.
-- ============================================================================
CREATE PROC spN_UpdateKitchenDetails
	@KitchenID int,
	@Comments nvarchar(500),
	@InspectionPassed bit,
	@InspectionDate datetime = NULL
AS
BEGIN TRY
	IF @InspectionDate IS NULL
		SELECT @InspectionDate = SYSDATETIME();

	BEGIN TRAN;
		UPDATE KitchenDetails
		SET InspectionComments = @Comments,
			InspectionPassed = @InspectionPassed,
			LastInspectionDate = @InspectionDate
		WHERE KitchenID = @KitchenID
	COMMIT TRAN;

	SELECT * FROM KitchenDetails WHERE KitchenID = @KitchenID;
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
END CATCH;
GO


-- ============================================================================
-- UPDATE - spN_UpdateCharities
-- Nicholas Fearing
--
-- UPDATE stored proc on Charities table for updating charity info.
-- Proc takes six parameters:
--   CharityID int (to identify row to be updated),
--   IsActive bit,
--   ContactName nvarchar(100),
--   PhoneNumber nvarchar(20),
--   CharityName nvarchar(100),
--   CharityType nvarchar(50)
-- The last four parameters default to existing value and are optional.
-- They are ordered from most likely to change to least. Returns the
-- updated row.
-- ============================================================================
CREATE PROC spN_UpdateCharities
	@CharityID int,
	@IsActive bit,
	@ContactName nvarchar(100) = NULL,
	@PhoneNumber nvarchar(20) = NULL,
	@CharityName nvarchar(100) = NULL,
	@CharityType nvarchar(50) = NULL
AS
BEGIN TRY
	IF @ContactName IS NULL
		SELECT @ContactName = ContactName FROM Charities WHERE CharityID = @CharityID;

	IF @PhoneNumber IS NULL
		SELECT @PhoneNumber = PhoneNumber FROM Charities WHERE CharityID = @CharityID;

	IF @CharityName IS NULL
		SELECT @CharityName = CharityName FROM Charities WHERE CharityID = @CharityID;

	IF @CharityType IS NULL
		SELECT @CharityType = CharityType FROM Charities WHERE CharityID = @CharityID;

	BEGIN TRAN;
		UPDATE Charities
		SET IsActive = @IsActive,
			ContactName = @ContactName,
			PhoneNumber = @PhoneNumber,
			CharityName = @CharityName,
			CharityType = @CharityType
		WHERE CharityID = @CharityID;
	COMMIT TRAN;

	SELECT * FROM Charities WHERE CharityID = @CharityID;
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
END CATCH;
GO


-- ============================================================================
-- DELETE - spN_DeleteCharities
-- Nathan Krouth
--
-- Procedure to delete items from the Charities table.
-- Thankfully simple since there are no dependencies here.
-- Returns how many rows were deleted.
-- ============================================================================
CREATE PROC spN_DeleteCharities

	@CharityID INT

AS

DELETE FROM Charities
WHERE CharityID = @CharityID;

SELECT @@ROWCOUNT AS RowsDeleted;
GO


-- ============================================================================
-- DELETE - spN_DeleteKitchenDetails
-- Nathan Krouth
--
-- Procedure to delete items from the KitchenDetails table.
-- Nothing has a foreign key to KitchenDetails (chefs are tied to a branch
-- through Demographic, not through the kitchen), so the row can be removed
-- without touching any other table. Returns how many rows were deleted.
-- ============================================================================
CREATE PROC spN_DeleteKitchenDetails

	@KitchenID INT,
	@LocationID INT

AS

DELETE FROM KitchenDetails
WHERE LocationID = @LocationID AND KitchenID = @KitchenID;

SELECT @@ROWCOUNT AS RowsDeleted;
GO


-- ============================================================================
-- TESTING
--
-- Calls every procedure above. Run the file as a whole, or highlight one
-- statement at a time for the screenshots. The Item 3 tests insert a test
-- charity and a test kitchen, update them, then delete them, so the tables
-- end up exactly as they started (15 charities, 5 kitchens).
-- ============================================================================

-- Item 1a - 400 rows in the new table, 100 suppliers; then 84 chef/item rows
SELECT COUNT(*) AS 'Rows', COUNT(DISTINCT SupplierID) AS 'Suppliers'
FROM SupplierIngredients;
EXEC spN_ChefDetails;

-- Item 1b - 141 rows: 100 ingredient lines, 40 dish subtotals, 1 grand total
EXEC spN_RecipeDetails;

-- Item 1c - 100 rows
EXEC spN_DishDetails;

-- Item 1d - all 5 kitchens, then the one kitchen led by chef 503
EXEC spN_KitchenDetails;
EXEC spN_KitchenDetails @LeadChef = 503;

-- Item 1e - all 100 customers, then one customer
EXEC spN_CustomerDetails;
EXEC spN_CustomerDetails @CustomerID = 1;

-- Item 2 - the six indexes exist
SELECT OBJECT_NAME(object_id) AS 'Table', name AS 'Index'
FROM sys.indexes
WHERE name LIKE 'IX[_]%'
ORDER BY 1;

-- clear out any test rows an earlier run left behind, so the counts below
-- start from 15 charities and 5 kitchens
DELETE FROM Charities WHERE CharityName IN ('Week 4 Test Charity', 'Joyce Dublin Clinic');
DELETE FROM KitchenDetails WHERE InspectionComments IN ('Week 4 test row', 'Insufficient fire suppression system.');

-- Item 3 SELECT - all rows then one row
EXEC spN_GetCharities;
EXEC spN_GetCharities @CharityID = 9001;
EXEC spN_GetKitchenDetails;
EXEC spN_GetKitchenDetails @KitchenID = 3;

-- Item 3 INSERT - a good call then a bad call for each
EXEC spN_InsertCharities @CharityName = 'Week 4 Test Charity',
	@CharityType = 'Food Bank', @City = 'Galway', @DonatingLocationID = 1,
	@TotalDonatedValue = 250.00;
EXEC spN_InsertCharities @CharityName = 'Week 4 Test Charity';
EXEC spN_InsertCharities @CharityName = 'Bad Branch', @DonatingLocationID = 9999;

EXEC spN_InsertKitchenDetails @LocationID = 1, @NumStoves = 5, @AreaSqft = 80,
	@MinCooks = 4, @LeadChef = 501, @FreezerCubicFeet = 100,
	@InspectionComments = 'Week 4 test row';
EXEC spN_InsertKitchenDetails @LocationID = 1, @NumStoves = 5, @AreaSqft = 80,
	@MinCooks = 4, @LeadChef = 9999, @FreezerCubicFeet = 100;
EXEC spN_InsertKitchenDetails @LocationID = 1, @NumStoves = 0, @AreaSqft = 80,
	@MinCooks = 4, @LeadChef = 501, @FreezerCubicFeet = 100;

-- Item 3 UPDATE - the test rows
-- the lookups match the row before and after the UPDATE renames it, so each
-- statement below can be highlighted and run on its own
DECLARE @TestCharity INT = (SELECT MAX(CharityID) FROM Charities
	WHERE CharityName IN ('Week 4 Test Charity', 'Joyce Dublin Clinic'));
DECLARE @TestKitchen INT = (SELECT MAX(KitchenID) FROM KitchenDetails
	WHERE InspectionComments IN ('Week 4 test row', 'Insufficient fire suppression system.'));

EXEC spN_UpdateCharities @CharityID = @TestCharity, @IsActive = 1,
	@ContactName = 'James Joyce', @PhoneNumber = '353 1 878 8547',
	@CharityName = 'Joyce Dublin Clinic', @CharityType = 'Free Clinic';

EXEC spN_UpdateKitchenDetails @KitchenID = @TestKitchen,
	@Comments = 'Insufficient fire suppression system.', @InspectionPassed = 0;

-- Item 3 DELETE - the test rows
EXEC spN_DeleteCharities @CharityID = @TestCharity;
EXEC spN_DeleteKitchenDetails @KitchenID = @TestKitchen, @LocationID = 1;

-- back to 15 and 5
SELECT (SELECT COUNT(*) FROM Charities) AS 'Charities',
	(SELECT COUNT(*) FROM KitchenDetails) AS 'Kitchens';
GO

USE Restaurant;
GO


-- ============================================================================
-- Drop the objects if they already exist so this file can be re-run.
-- ============================================================================
DROP PROCEDURE IF EXISTS spN_ChefDetails;
DROP PROCEDURE IF EXISTS spN_RecipeDetails;
DROP PROCEDURE IF EXISTS spN_DishDetails;
DROP PROCEDURE IF EXISTS spN_KitchenDetails;
DROP PROCEDURE IF EXISTS spN_CustomerDetails;
DROP TABLE IF EXISTS SupplierIngredients;
GO


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
-- TESTING
--
-- Calls every procedure above. Run the file as a whole, or highlight one
-- statement at a time for the screenshots.
-- ============================================================================

-- 1a - 400 rows in the new table, 100 suppliers; then 84 chef/item rows
SELECT COUNT(*) AS 'Rows', COUNT(DISTINCT SupplierID) AS 'Suppliers'
FROM SupplierIngredients;
EXEC spN_ChefDetails;

-- 1b - 141 rows: 100 ingredient lines, 40 dish subtotals, 1 grand total
EXEC spN_RecipeDetails;

-- 1c - 100 rows
EXEC spN_DishDetails;

-- 1d - all 5 kitchens, then the one kitchen led by chef 503
EXEC spN_KitchenDetails;
EXEC spN_KitchenDetails @LeadChef = 503;

-- 1e - all 100 customers, then one customer
EXEC spN_CustomerDetails;
EXEC spN_CustomerDetails @CustomerID = 1;
GO

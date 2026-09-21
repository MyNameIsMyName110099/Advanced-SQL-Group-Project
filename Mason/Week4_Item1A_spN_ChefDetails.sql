USE Restaurant;
GO

DROP PROCEDURE IF EXISTS spN_ChefDetails;
GO

-- 1a. chefs that have a preferred vendor, the items that vendor sells and
-- the price of each. the INNER JOIN on Suppliers drops any chef with no
-- preferred vendor. FORMAT with the en-IE locale supplies the euro sign so
-- it is not hardcoded. run Week4_Item1A_SupplierIngredients.sql first.
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

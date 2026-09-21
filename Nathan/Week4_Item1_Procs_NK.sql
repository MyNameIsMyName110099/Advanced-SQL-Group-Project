USE Restaurant;

DROP PROC IF EXISTS spN_RecipeDetails
DROP PROC IF EXISTS spN_DishDetails
DROP PROC IF EXISTS spN_CustomerDetails

GO

/*

Item B:

Creating a stored procedure to select all of the ingredients for
each dish then tallying up the cost for all of the ingredients

*/


CREATE PROC spN_RecipeDetails
	
AS

SELECT DishID, IngredientName, FORMAT(SUM(IngredientCost * QuantityUsed), 'C', 'en-IE') AS RecipeCost 
FROM Recipes r
	JOIN Ingredients i
		ON r.IngredientID = i.IngredientID
GROUP BY ROLLUP(DishID, IngredientName)
ORDER BY DishID
GO


/*

Item C:

Stored procedure to return a dishes details and the cost of the dish itself

*/

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


/*

Item E:

Stored Procedure that returns the details of all customers
Included a formatted name to make it a bit more neat

*/

CREATE PROC spN_CustomerDetails
	
AS

SELECT FirstName + ' ' + LastName AS CustName, Email, PhoneNumber,
	PreferredTable, PreferredServer, PreferredRes, PreferredOrder,
	Birthday
FROM Customers
ORDER BY CustName ASC

EXEC spN_CustomerDetails

  

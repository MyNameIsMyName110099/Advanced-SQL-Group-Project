USE Restaurant;
GO


/*  drop both first so this file can be run again without editing it.
*/
IF OBJECT_ID('dbo.fnChefSalary', 'IF') IS NOT NULL
	DROP FUNCTION dbo.fnChefSalary;
GO

IF OBJECT_ID('dbo.fnMenuPrices', 'IF') IS NOT NULL
	DROP FUNCTION dbo.fnMenuPrices;
GO


--A. function returns ID#, name, and salary of each Chef
CREATE FUNCTION fnChefSalary()
	RETURNS table
RETURN
	SELECT c.EmployeeID, CONCAT(e.FirstName, ' ', e.LastName) AS 'Chef Name', 
		FORMAT(c.Salary, 'C', 'en-IE') AS 'Salary'
	FROM Chefs c
		INNER JOIN Employees e ON c.EmployeeID = e.EmployeeID;
GO


--C. function returns each unique menu item with prices
CREATE FUNCTION fnMenuPrices()
	RETURNS table
RETURN
	SELECT DISTINCT DishName AS 'Dish Name', FORMAT(Price, 'C', 'en-IE') AS 'Price'
	FROM Dishes;
GO

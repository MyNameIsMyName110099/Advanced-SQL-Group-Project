-- ============================================================================
-- Advanced SQL Semester Project
-- Week 3 Deliverables, Item 1 - Functions
--
-- Kelsey Wilcox, Mason Romdenne, Nathan Krouth, Nicholas Fearing
-- Prepared by Mason Romdenne
-- Database: Restaurant
--
-- Item 1 asks for one function per requirement a through e. There are six
-- functions here because requirement e is answered in two parts, one that
-- lists the reservations and one that counts them.
--
--   Function 1  fnChefSalary                 requirement a
--   Function 2  fnKitchenDetails             requirement b
--   Function 3  fnMenuPrices                 requirement c
--   Function 4  fnOrderMethodSum             requirement d
--   Function 5  fnReservationFavoriteTable   requirement e (the reservations)
--   Function 6  fnFavoriteTableCounts        requirement e (how many)
--
-- Every function is an inline table valued function, so each one is called
-- with SELECT * FROM dbo.fnName(). The money columns are formatted with
-- FORMAT(value, 'C', 'en-IE'), which lets SQL Server supply the euro sign
-- and two decimal places for the Irish locale rather than hardcoding it.
--
-- Each function is written by the group member named above it and was
-- reviewed and merged through a pull request on the group's GitHub repo.
--
-- Run the whole file at once. The functions are dropped first if they
-- already exist, so it can be run again without editing. The TESTING
-- section at the bottom calls every function and is the testing code for
-- this submission.
-- ============================================================================

USE Restaurant;
GO


-- ============================================================================
-- Drop the functions if they already exist so this file can be re-run.
-- Function 6 is dropped before Function 5 in case a future version of it
-- selects from Function 5.
-- ============================================================================
DROP FUNCTION IF EXISTS dbo.fnFavoriteTableCounts;
DROP FUNCTION IF EXISTS dbo.fnReservationFavoriteTable;
DROP FUNCTION IF EXISTS dbo.fnOrderMethodSum;
DROP FUNCTION IF EXISTS dbo.fnMenuPrices;
DROP FUNCTION IF EXISTS dbo.fnKitchenDetails;
DROP FUNCTION IF EXISTS dbo.fnChefSalary;
GO


-- ============================================================================
-- Function 1 - fnChefSalary                                (requirement a)
-- Nicholas Fearing
--
-- "Chef - show me the salary of each chef listed in the table. Ensure this
--  salary is displayed correctly as the Irish pound. Do NOT hardcode the
--  euro dollar sign."
--
-- Joins Chefs to Employees on EmployeeID so the chef's name can be shown
-- next to the salary that is stored on the Chefs table. Salary is passed
-- through FORMAT with the 'C' currency pattern and the 'en-IE' culture, so
-- the euro sign and two decimal places come from the locale, not from the
-- code. Returns one row per chef, 25 in all.
-- ============================================================================
CREATE FUNCTION dbo.fnChefSalary()
RETURNS TABLE
AS
RETURN
(
	SELECT c.EmployeeID, CONCAT(e.FirstName, ' ', e.LastName) AS 'Chef Name',
		FORMAT(c.Salary, 'C', 'en-IE') AS 'Salary'
	FROM Chefs c
		INNER JOIN Employees e ON c.EmployeeID = e.EmployeeID
);
GO


-- ============================================================================
-- Function 2 - fnKitchenDetails                            (requirement b)
-- Nathan Krouth
--
-- "Show me the kitchen details by kitchen."
--
-- Joins KitchenDetails to Demographic on LocationID so each kitchen is
-- labelled with the name of the branch it is in, then returns every column
-- of the kitchen row: the number of stoves, floor area, minimum cooks,
-- lead chef, freezer size and the last inspection. One row per kitchen,
-- one kitchen per location, 5 in all.
-- ============================================================================
CREATE FUNCTION dbo.fnKitchenDetails()
RETURNS TABLE
AS
RETURN
(
	SELECT DISTINCT LocationName, ki.*
	FROM Demographic d
		JOIN KitchenDetails ki
			ON d.LocationID = ki.LocationID
);
GO


-- ============================================================================
-- Function 3 - fnMenuPrices                                (requirement c)
-- Nicholas Fearing
--
-- "Menu price - show me the unique menu items along with the price of those
--  dishes."
--
-- The Dishes table holds the dish name and the price listed on the menu, so
-- the function reads straight from it. DISTINCT guarantees each dish name
-- appears once. Price is formatted the same way as the salary in Function 1,
-- with the euro sign supplied by the 'en-IE' locale. Returns 40 dishes.
-- ============================================================================
CREATE FUNCTION dbo.fnMenuPrices()
RETURNS TABLE
AS
RETURN
(
	SELECT DISTINCT DishName AS 'Dish Name', FORMAT(Price, 'C', 'en-IE') AS 'Price'
	FROM Dishes
);
GO


-- ============================================================================
-- Function 4 - fnOrderMethodSum                            (requirement d)
-- Kelsey Wilcox
--
-- "Show me the distribution of how orders are placed (in-person, online,
--  phone). Show this as a sum of each, with an overall sum for all options."
--
-- Groups the Transactions table by OrderChannel and counts the orders in
-- each group. GROUP BY ROLLUP adds one extra row that is the total across
-- all channels. On that total row OrderChannel is NULL, so ISNULL replaces
-- it with the label 'All Methods'. Returns four rows: In-Person, Online,
-- Phone and the overall total of 100.
-- ============================================================================
CREATE FUNCTION dbo.fnOrderMethodSum()
RETURNS TABLE
AS
RETURN
(
	SELECT ISNULL(OrderChannel, 'All Methods') AS 'Order Method',
		COUNT(OrderChannel) AS 'Order Method Count'
	FROM Transactions
	GROUP BY ROLLUP(OrderChannel)
);
GO


-- ============================================================================
-- Function 5 - fnReservationFavoriteTable                  (requirement e)
-- Mason Romdenne
--
-- "Show me the reservations and how many patrons receive their favorite
--  table and those that don't."  (part 1 - the reservations)
--
-- Joins Reservations to Customers on CustomerID and puts the customer's
-- preferred table (Customers.PreferredTable) next to the table the
-- reservation was actually given (Reservations.TableID). The CASE compares
-- the two and reports Yes when they match and No when they do not. A
-- reservation with no table assigned yet compares as NULL, which falls to
-- the ELSE and is reported as No, since that patron did not receive their
-- favorite table either. Returns all 100 reservations.
-- ============================================================================
CREATE FUNCTION dbo.fnReservationFavoriteTable()
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


-- ============================================================================
-- Function 6 - fnFavoriteTableCounts                       (requirement e)
-- Mason Romdenne
--
-- "Show me the reservations and how many patrons receive their favorite
--  table and those that don't."  (part 2 - how many)
--
-- The same Yes/No comparison as Function 5, but grouped, so it returns the
-- number of reservations where the patron got their favorite table and the
-- number where they did not. GROUP BY ROLLUP adds the overall total, the
-- same technique as Function 4. COALESCE is used for the total row's label
-- rather than ISNULL because ISNULL takes the data type of its first
-- argument, the 3 character Yes/No, and would cut 'All Reservations' down
-- to 'All'. Returns three rows: No, Yes and the total of 100.
-- ============================================================================
CREATE FUNCTION dbo.fnFavoriteTableCounts()
RETURNS TABLE
AS
RETURN
(
	SELECT COALESCE(CASE WHEN r.TableID = c.PreferredTable THEN 'Yes' ELSE 'No' END,
			'All Reservations') AS 'Got Favorite Table',
		COUNT(*) AS 'Reservations'
	FROM Reservations r
		INNER JOIN Customers c ON r.CustomerID = c.CustomerID
	GROUP BY ROLLUP(CASE WHEN r.TableID = c.PreferredTable THEN 'Yes' ELSE 'No' END)
);
GO


-- ============================================================================
-- TESTING
--
-- Everything below is the testing code for this submission. Test 0 proves
-- all six functions exist in the Restaurant database, and Tests 1 to 6 call
-- each function in turn. Each test is one result grid to screenshot.
-- ============================================================================

-- Test 0. All six functions are deployed to the Restaurant database.
SELECT name AS FunctionName, type_desc AS ObjectType, create_date AS Created
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF')
	AND name IN ('fnChefSalary', 'fnKitchenDetails', 'fnMenuPrices',
		'fnOrderMethodSum', 'fnReservationFavoriteTable', 'fnFavoriteTableCounts')
ORDER BY name;
GO

-- Test 1. Function 1 - the salary of each chef, in euro. 25 rows.
SELECT * FROM dbo.fnChefSalary();
GO

-- Test 2. Function 2 - the kitchen details by kitchen. 5 rows.
SELECT * FROM dbo.fnKitchenDetails();
GO

-- Test 3. Function 3 - the unique menu items and their prices, in euro. 40 rows.
SELECT * FROM dbo.fnMenuPrices();
GO

-- Test 4. Function 4 - how orders are placed, with the overall total. 4 rows.
SELECT * FROM dbo.fnOrderMethodSum();
GO

-- Test 5. Function 5 - every reservation and whether the patron got their
--         favorite table. 100 rows.
SELECT * FROM dbo.fnReservationFavoriteTable();
GO

-- Test 6. Function 6 - how many patrons got their favorite table and how
--         many did not, with the overall total. 3 rows.
SELECT * FROM dbo.fnFavoriteTableCounts();
GO

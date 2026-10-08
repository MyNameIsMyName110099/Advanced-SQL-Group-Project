--Drop anything left from an earlier run so this script can be run again

USE Restaurant;
GO

--Users first, so the roles below have no members left when they are dropped
DROP USER IF EXISTS RestaurantUser;
DROP USER IF EXISTS RestaurantAddDeleteDB_User;
DROP USER IF EXISTS Dishes_table_user;
DROP USER IF EXISTS Transactions_table_user;
DROP USER IF EXISTS ServerEmployees_table_user;
DROP USER IF EXISTS Chefs_table_user;
DROP USER IF EXISTS Reservations_table_user;
GO

DROP ROLE IF EXISTS RestaurantDoAnything;
DROP ROLE IF EXISTS RestaurantPower;
GO

--Logins and the server role live at the server level
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'RestaurantUser')
DROP LOGIN RestaurantUser;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'RestaurantAddDeleteDB_Login')
DROP LOGIN RestaurantAddDeleteDB_Login;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Dishes_table_user')
DROP LOGIN Dishes_table_user;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Transactions_table_user')
DROP LOGIN Transactions_table_user;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ServerEmployees_table_user')
DROP LOGIN ServerEmployees_table_user;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Chefs_table_user')
DROP LOGIN Chefs_table_user;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Reservations_table_user')
DROP LOGIN Reservations_table_user;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'RestaurantAddDeleteDB' AND type = 'R')
DROP SERVER ROLE RestaurantAddDeleteDB;
GO


--Week 7 Item 1

/* Create users for Restaurant database

In class Dave read 'role/user' in the requirements as 'role or user', 
	so I've elected to use the one which makes the most sense for each item,
	rather than do both for all items.	*/

--Create users for correct database no matter context where query is run
USE Restaurant;
GO

--B. Add new user RestaurantUser with schema db_backupoperator
CREATE LOGIN RestaurantUser WITH PASSWORD = '123456';
GO

CREATE USER RestaurantUser FOR LOGIN RestaurantUser
	WITH DEFAULT_SCHEMA = db_backupoperator;
GO

--C. Add new role RestaurantDoAnything 
--		with necessary permissions to do anything in the Restaurant database
CREATE ROLE RestaurantDoAnything;
GO

GRANT CONTROL
ON DATABASE::Restaurant
TO RestaurantDoAnything;
GO


--D. Add new role RestaurantAddDeleteDB with permissions to
--		create, alter, drop, and restore any database, but is unable to insert

--using server role to allow for permissions over other databases
CREATE SERVER ROLE RestaurantAddDeleteDB;
GO

USE master;
GO		--needs to be in scope of master to grant these permissions

GRANT CREATE ANY DATABASE, 
	ALTER ANY DATABASE	--ALTER also covers Drop and Restore
TO RestaurantAddDeleteDB;
GO

CREATE LOGIN RestaurantAddDeleteDB_Login WITH PASSWORD = '123456';
GO

ALTER SERVER ROLE RestaurantAddDeleteDB
ADD MEMBER RestaurantAddDeleteDB_Login;
GO

USE Restaurant;
GO		--return to Restaurant for remaining item


--E. Add a new role RestaurantPower that can modify rights/permissions 
--		of users in Restaurant database
CREATE ROLE RestaurantPower;
GO

GRANT ALTER ANY USER
TO RestaurantPower;
GO


--Week 7 Item 2

/*	Assign permissions to stored procedures created in Week 4	*/

--Run week7_Item1 script first, then this script second


USE Restaurant;
GO

--A. Assign EXECUTE permission to spN_ChefDetails, to schema dbo
/*	This requirement is not clearly worded. I have implemented my best interpretation.	*/
GRANT EXECUTE
ON SCHEMA::dbo
TO RestaurantUser;
GO

GRANT EXECUTE
ON spN_ChefDetails
TO RestaurantUser;
GO


--B. Assign 'View Definition' permissions to RestaurantUser to spN_RecipeDetails
GRANT VIEW Definition
ON spN_RecipeDetails
TO RestaurantUser;
GO

--C. Assign ALTER permissions to RestaurantAddDeleteDB to spN_DishDetails
CREATE USER RestaurantAddDeleteDB_User FOR LOGIN RestaurantAddDeleteDB_Login;
GO	--first create user, as trying to apply GRANT ALTER to the server role throws an error

GRANT ALTER
ON Restaurant.dbo.spN_DishDetails
TO RestaurantAddDeleteDB_User;
GO

--D. Assign 'Take Ownership' permissions to RestaurantPower to spN_KitchenDetails
GRANT TAKE OWNERSHIP
ON spN_KitchenDetails
TO RestaurantPower;
GO


--E. Assign CONTROL permissions to RestaurantDoAnything to spN_CustomerDetails
GRANT CONTROL
ON spN_CustomerDetails
TO RestaurantDoAnything;
GO


--Week 7 Item 3

/*

Creating the connection and dropping users in case code is re-ran

*/

USE Restaurant
GO

/*

Had to use an if statement for the login as the IF EXISTS does
not appear to work in this context

*/

IF EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE name = 'Dishes_table_user'
)
DROP LOGIN Dishes_table_user

IF EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE name = 'Transactions_table_user'
)
DROP LOGIN Transactions_table_user

IF EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE name = 'ServerEmployees_table_user'
)
DROP LOGIN ServerEmployees_table_user

IF EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE name = 'Chefs_table_user'
)
DROP LOGIN Chefs_table_user

IF EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE name = 'Reservations_table_user'
)
DROP LOGIN Reservations_table_user

DROP USER IF EXISTS Dishes_table_user
DROP USER IF EXISTS Transactions_table_user
DROP USER IF EXISTS ServerEmployees_table_user
DROP USER IF EXISTS Chefs_table_user
DROP USER IF EXISTS Reservations_table_user

/*

Creating the login and users in batches. Using the sql server user
creation syntax. Using another means of applying the second schema
to the final user

*/

CREATE LOGIN Dishes_table_user WITH PASSWORD = 'dishestableuser',
	DEFAULT_DATABASE = Restaurant;
CREATE USER Dishes_table_user WITH Default_Schema = db_datareader

CREATE LOGIN Transactions_table_user WITH PASSWORD = 'transtableuser',
	DEFAULT_DATABASE = Restaurant;
CREATE USER Transactions_table_user WITH Default_Schema = guest

CREATE LOGIN ServerEmployees_table_user WITH PASSWORD = 'servertableuser',
	DEFAULT_DATABASE = Restaurant;
CREATE USER ServerEmployees_table_user WITH Default_Schema = db_datawriter

CREATE LOGIN Chefs_table_user WITH PASSWORD = 'cheftableuser',
	DEFAULT_DATABASE = Restaurant;
CREATE USER Chefs_table_user WITH Default_Schema = db_accessadmin

CREATE LOGIN Reservations_table_user WITH PASSWORD = 'reservetableuser',
	DEFAULT_DATABASE = Restaurant;
CREATE USER Reservations_table_user WITH Default_Schema = db_datareader 
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA :: db_datawriter TO Reservations_table_user
GO

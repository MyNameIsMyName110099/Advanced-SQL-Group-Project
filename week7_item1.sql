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
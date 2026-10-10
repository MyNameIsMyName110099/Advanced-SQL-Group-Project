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
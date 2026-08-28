

-- create database
CREATE DATABASE Restaurants;


/*	create table for positions. this table should be relatively small
	and serve as the dominant table referenced by the employeee table. 
	the positionname field is enforced with the UNIQUE keyword to ensure that
	we do not have multiple fields with the same position
*/
CREATE TABLE Positions (
	PositionID INT IDENTITY(31,1) PRIMARY KEY,
	PositionName NVARCHAR(30) NOT NULL UNIQUE,
	Notes NVARCHAR(100)
);


/*	create table for employees.
	the column for updates to the row will need a trigger at a later date.
	rather than making multiple tables, i've opted to make
	the employees table do a lot of heavy lifting
*/
CREATE TABLE Employees (
	EmployeeID INT IDENTITY(101001,1) PRIMARY KEY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	HireDate DATE NOT NULL,
	HourlyRate DECIMAL(10,2) NOT NULL,
	PhoneNumber NVARCHAR(20) NOT NULL,
	Email NVARCHAR(50) NOT NULL,
	PositionID INT REFERENCES Positions(PositionID),
	IsActive BIT NOT NULL DEFAULT 1,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
	UpdateDate DATETIME2 DEFAULT NULL,
	Notes NVARCHAR(100)
);


/*	create table for servers. "servers" is a keyword, changed table name to circumvent this.
	since we need more details on servers, i made a separate table for only employees that
	are also servers. this table could optionally also by filtered by positionID and employeeID together
*/
CREATE TABLE ServerEmployees (
	ServerID INT IDENTITY(1,1) PRIMARY KEY,
	EmployeeID INT REFERENCES Employees(EmployeeID) NOT NULL,
	TablesAssigned INT,
	Notes NVARCHAR(100)
);

/*	BONUS table, small table for tables in restaurant because
	they will need to be given numbers and be assigned servers and the requirements request that
	customers be assigned a preferred table
*/
CREATE TABLE ResTables (
	TableID INT IDENTITY(1,1) PRIMARY KEY,
	Section NVARCHAR(25),
	AssignedServer INT REFERENCES ServerEmployees(ServerID)
);

/*	create table for customers
*/
CREATE TABLE Customers (
	CustomerID INT IDENTITY(1,1) PRIMARY KEY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Email NVARCHAR(50),
	PhoneNumber NVARCHAR(30),
	PreferredTable INT REFERENCES ResTables(TableID),
	PrefferedServer	INT REFERENCES ServerEmployees(ServerID),
	PrefferedResTime TIME(0), -- this may need to change based on reservation table
	PrefferedOrder INT REFERENCES Dishes(DishID), -- not in this code, serves only as an example
	Birthday DATE,
	Notes NVARCHAR(100)
);



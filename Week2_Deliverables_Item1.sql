
-- CREATE DATABASE Restaurant;

USE Restaurant;
GO

/*	create table for positions. this table should be relatively small
	and serve as the dominant table referenced by the employeee table. 
	the positionname field is enforced with the UNIQUE keyword to ensure that
	we do not have multiple fields with the same position
*/
CREATE TABLE Positions (
	PositionID INT IDENTITY(31,1) NOT NULL,
	PositionName NVARCHAR(30) NOT NULL,
	Notes NVARCHAR(100)

	-- constraints to enforce data intergrity
	CONSTRAINT PK_Positions PRIMARY KEY (PositionID),
	CONSTRAINT UG_Positions_PositionName UNIQUE (PositionName)
);
GO


/*	create table for employees.
	the column for updates to the row will need a trigger at a later date.
	rather than making multiple tables, i've opted to make
	the employees table do a lot of heavy lifting
*/
CREATE TABLE Employees (
	EmployeeID INT IDENTITY(101001,1) NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	HireDate DATE NOT NULL,
	HourlyRate DECIMAL(10,2) NOT NULL,
	PhoneNumber NVARCHAR(20) NOT NULL,
	Email NVARCHAR(50) NOT NULL,
	PositionID INT NOT NULL,
	IsActive BIT NOT NULL DEFAULT 1,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
	UpdateDate DATETIME2 DEFAULT NULL,
	Notes NVARCHAR(100),

	-- constraints to enforce data intergrity
	CONSTRAINT Pk_Employees PRIMARY KEY (EmployeeID),
	CONSTRAINT FK_Employees_PositionID
		FOREIGN KEY (PositionID) REFERENCES Positions(PositionID),
	CONSTRAINT CK_Employees_HourlyRate_Positive
		CHECK (HourlyRate > 0),
	CONSTRAINT CK_Employees_Email_IsValid
		CHECK	(
				Email LIKE '%@.%' AND
				Email NOT LIKE '%%' AND
				Email NOT LIKE '@%' AND
				Email NOT LIKE '%@' AND
				LEN(Email) >= 5
				)
);
GO


/*	create table for servers. "servers" is a keyword, changed table name to circumvent this.
	since we need more details on servers, i made a separate table for only employees that
	are also servers. this table could optionally also by filtered by positionID and employeeID together
*/
CREATE TABLE ServerEmployees (
	ServerID INT IDENTITY(1,1) NOT NULL,
	EmployeeID INT NOT NULL,
	TablesAssigned INT,
	Notes NVARCHAR(100),

	-- constraints to enforce data intergrity
	CONSTRAINT PK_ServerEmployees PRIMARY KEY (ServerID),
	CONSTRAINT FK_ServerEmployees_EmployeedID
		FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
	CONSTRAINT CK_ServerEmployees_TablesAssigned_Positive
		CHECK (TablesAssigned IS NULL OR TablesAssigned >= 0)
);
GO


/*	BONUS table, small table for tables in restaurant because
	they will need to be given numbers and be assigned servers and the requirements request that
	customers be assigned a preferred table
*/
CREATE TABLE ResTables (
	TableID INT IDENTITY(1,1) NOT NULL,
	Section NVARCHAR(25),
	AssignedServer INT,
	
	-- constraints to enforce data intergrity
	CONSTRAINT PK_ResTables PRIMARY KEY (TableID),
	CONSTRAINT FK_ResTables_AssignedServer
		FOREIGN KEY (AssignedServer) REFERENCES ServerEmployees(ServerID),
	CONSTRAINT CK_ResTables_Section_IsBlank
		CHECK (Section IS NULL OR (Section <> ''))
);
GO


/*	create table for customers
*/
CREATE TABLE Customers (
	CustomerID INT IDENTITY(1,1) NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Email NVARCHAR(50),
	PhoneNumber NVARCHAR(30),
	PreferredTable INT,
	PreferredServer	INT,
	PreferredRes INT,
	PreferredOrder INT,
	Birthday DATE,
	Notes NVARCHAR(100),

	-- constraints to enforce data intergrity
	CONSTRAINT PK_Customers PRIMARY KEY (CustomerID),
	CONSTRAINT FK_Customers_PreferredTable
		FOREIGN KEY (PreferredTable) REFERENCES ResTables(TableID),
	CONSTRAINT FK_Customers_PreferredServer
		FOREIGN KEY (PreferredServer) REFERENCES ServerEmployees(ServerID),
	CONSTRAINT CK_Customers_Email_IsValid
		CHECK	(
				Email LIKE '%@.%' AND
				Email NOT LIKE '%%' AND
				Email NOT LIKE '@%' AND
				Email NOT LIKE '%@' AND
				LEN(Email) >= 5
				),
	CONSTRAINT CK_Customers_PhoneNumber_IsBlank
		CHECK (PhoneNumber IS NULL OR (PhoneNumber <> ''))
);
GO


/* foreign keys for other group tables

group 4:

ALTER TABLE Customers ADD CONSTRAINT FK_Customers_PreferredOrder
		FOREIGN KEY (PreferredOrder) REFERENCES Dishes(DishID)

group 3:

ALTER TABLE Customers ADD CONSTRAINT FK_Customers_PreferredRes
	FOREIGN KEY (PreferredRes) REFERENCES Reservations(ReservationID)

*/

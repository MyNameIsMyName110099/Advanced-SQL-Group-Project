-- ============================================================================
-- Advanced SQL Semester Project
-- Week 2 Deliverables, Item 1 - Database and Table Creation
--
-- Kelsey Wilcox, Mason Romdenne, Nathan Krouth, Nicholas Fearing
--
-- Creates the Restaurant database and all 18 tables.
--
-- Every foreign key that crosses between one group's tables and another's is
-- in the ALTER TABLE section at the end of the file. That way the whole script
-- runs top to bottom on a clean instance in a single pass, and no table has to
-- exist before the one that references it.
-- ============================================================================

CREATE DATABASE Restaurant;
GO

USE Restaurant;
GO


-- ============================================================================
-- GROUP 1 - Kelsey Wilcox
-- Positions, Employees, ServerEmployees, ResTables, Customers
-- ============================================================================

/*	create table for positions. this table should be relatively small and
	serve as the dominant table referenced by the employee table.
	the positionname field is enforced with the UNIQUE keyword to ensure that
	we do not have multiple fields with the same position
*/
CREATE TABLE Positions (
	PositionID INT IDENTITY(31,1) NOT NULL,
	PositionName NVARCHAR(30) NOT NULL,
	Notes NVARCHAR(100),
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_Positions PRIMARY KEY (PositionID),
	CONSTRAINT UQ_Positions_PositionName UNIQUE (PositionName)
);
GO


/*	create table for employees.
	the column for updates to the row will need a trigger at a later date.
	rather than making multiple tables, the employees table does a lot of the
	heavy lifting.
	the email check makes sure there is at least one character on each side of
	the @ and a dot after it, and that the address has no spaces in it.
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

	-- constraints to enforce data integrity
	CONSTRAINT PK_Employees PRIMARY KEY (EmployeeID),
	CONSTRAINT FK_Employees_PositionID FOREIGN KEY (PositionID)
		REFERENCES Positions (PositionID),
	CONSTRAINT CK_Employees_HourlyRate_Positive
		CHECK (HourlyRate > 0),
	CONSTRAINT CK_Employees_Email_IsValid
		CHECK (Email LIKE '%_@_%._%' AND Email NOT LIKE '% %' AND LEN(Email) >= 5)
);
GO


/*	create table for servers. "servers" is a keyword so the table name was
	changed to get around it.
	since we need more details on servers than on other staff, this is a
	separate table for only the employees who are also servers.
*/
CREATE TABLE ServerEmployees (
	ServerID INT IDENTITY(1,1) NOT NULL,
	EmployeeID INT NOT NULL,
	TablesAssigned INT,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
	Notes NVARCHAR(100),

	-- constraints to enforce data integrity
	CONSTRAINT PK_ServerEmployees PRIMARY KEY (ServerID),
	CONSTRAINT FK_ServerEmployees_EmployeeID FOREIGN KEY (EmployeeID)
		REFERENCES Employees (EmployeeID),
	CONSTRAINT CK_ServerEmployees_TablesAssigned_Positive
		CHECK (TablesAssigned IS NULL OR TablesAssigned >= 0)
);
GO


/*	create table for the tables in the restaurant.
	they need to be given numbers and assigned to servers, and the
	requirements ask for customers to have a preferred table.
*/
CREATE TABLE ResTables (
	TableID INT IDENTITY(1,1) NOT NULL,
	Section NVARCHAR(25),
	AssignedServer INT,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_ResTables PRIMARY KEY (TableID),
	CONSTRAINT FK_ResTables_AssignedServer FOREIGN KEY (AssignedServer)
		REFERENCES ServerEmployees (ServerID),
	CONSTRAINT CK_ResTables_Section_IsBlank
		CHECK (Section IS NULL OR Section <> '')
);
GO


/*	create table for the customers that dine at the restaurant.
	the preferred columns cover the requirement that a customer can have a
	favourite table, server, reservation slot and dish.
*/
CREATE TABLE Customers (
	CustomerID INT IDENTITY(1,1) NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	Email NVARCHAR(50),
	PhoneNumber NVARCHAR(30),
	PreferredTable INT,
	PreferredServer INT,
	PreferredRes INT,
	PreferredOrder INT,
	Birthday DATE,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
	Notes NVARCHAR(100),

	-- constraints to enforce data integrity
	CONSTRAINT PK_Customers PRIMARY KEY (CustomerID),
	CONSTRAINT FK_Customers_PreferredTable FOREIGN KEY (PreferredTable)
		REFERENCES ResTables (TableID),
	CONSTRAINT FK_Customers_PreferredServer FOREIGN KEY (PreferredServer)
		REFERENCES ServerEmployees (ServerID),
	CONSTRAINT CK_Customers_Email_IsValid
		CHECK (Email LIKE '%_@_%._%' AND Email NOT LIKE '% %' AND LEN(Email) >= 5),
	CONSTRAINT CK_Customers_PhoneNumber_IsBlank
		CHECK (PhoneNumber IS NULL OR PhoneNumber <> '')
);
GO


-- ============================================================================
-- GROUP 2 - Mason Romdenne
-- Demographic, Chefs, ChefLocations, Charities, Transactions,
-- TransactionDetails
-- ============================================================================

/*	create table for the restaurant locations (requirement a).
	the requirement says the restaurant is thinking about opening multiple
	locations, so this is one row per branch instead of one row for the whole
	business. that makes it the parent table most of the others point at.
	AreaPopulation is the demographic part of the requirement, it is what you
	would look at when picking where to open the next location.
	IsActive goes to 0 if a branch closes, that way old orders still point at
	somewhere real.
*/
CREATE TABLE Demographic (
	LocationID INT IDENTITY(1,1) NOT NULL,
	LocationName NVARCHAR(50) NOT NULL,
	AddressLine1 NVARCHAR(100) NOT NULL,
	City NVARCHAR(50) NOT NULL,
	PhoneNumber NVARCHAR(20),
	SeatingCapacity INT NOT NULL,
	OpenDate DATE NOT NULL,
	AreaPopulation INT,
	IsActive BIT NOT NULL DEFAULT 1,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_Demographic PRIMARY KEY (LocationID)
);
GO


/*	create table for chefs (requirement b).
	chefs are employees, so instead of repeating name and hire date this links
	back to the Employees table the same way ServerEmployees does. that keeps
	one pattern for both kinds of specialised staff.
	salary is its own column because Employees stores an hourly rate and chefs
	are salaried.
	HomeLocationID is the branch they are based at, the other branches they
	cook at are in ChefLocations below.
	PreferredSupplierID is requirement q, certain chefs have a vendor they
	like to work with.
*/
CREATE TABLE Chefs (
	ChefID INT IDENTITY(501,1) NOT NULL,
	EmployeeID INT NOT NULL,
	ChefType NVARCHAR(30) NOT NULL,
	Salary DECIMAL(10,2) NOT NULL,
	HomeLocationID INT,
	PreferredSupplierID INT,
	IsActive BIT NOT NULL DEFAULT 1,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_Chefs PRIMARY KEY (ChefID),
	CONSTRAINT UQ_Chefs_EmployeeID UNIQUE (EmployeeID),
	CONSTRAINT FK_Chefs_Demographic FOREIGN KEY (HomeLocationID)
		REFERENCES Demographic (LocationID),
	CONSTRAINT CK_Chefs_ChefType CHECK (ChefType IN
		('Head Chef', 'Sous Chef', 'Pastry Chef', 'Line Cook', 'Prep Cook'))
);
GO


/*	create table linking chefs to the branches they cook at (requirement b).
	the requirement says each chef may cook at other branches, which is a many
	to many, so it needs its own table.
	IsActive goes to 0 when a chef stops covering that branch.
*/
CREATE TABLE ChefLocations (
	ChefLocationID INT IDENTITY(1,1) NOT NULL,
	ChefID INT NOT NULL,
	LocationID INT NOT NULL,
	IsActive BIT NOT NULL DEFAULT 1,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_ChefLocations PRIMARY KEY (ChefLocationID),
	CONSTRAINT UQ_ChefLocations_ChefLocation UNIQUE (ChefID, LocationID),
	CONSTRAINT FK_ChefLocations_Chefs FOREIGN KEY (ChefID)
		REFERENCES Chefs (ChefID),
	CONSTRAINT FK_ChefLocations_Demographic FOREIGN KEY (LocationID)
		REFERENCES Demographic (LocationID)
);
GO


/*	create table for the charities the restaurant donates food to
	(requirement d).
	TotalDonatedValue is a running total of what has been given to that
	charity rather than a whole second table tracking every drop off.
	DonatingLocationID is which branch handles that charity, since with
	multiple locations each one works with the charities near it.
*/
CREATE TABLE Charities (
	CharityID INT IDENTITY(9001,1) NOT NULL,
	CharityName NVARCHAR(100) NOT NULL,
	CharityType NVARCHAR(50),
	ContactName NVARCHAR(100),
	PhoneNumber NVARCHAR(20),
	City NVARCHAR(50),
	DonatingLocationID INT,
	TotalDonatedValue DECIMAL(10,2),
	IsActive BIT NOT NULL DEFAULT 1,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_Charities PRIMARY KEY (CharityID),
	CONSTRAINT UQ_Charities_CharityName UNIQUE (CharityName),
	CONSTRAINT FK_Charities_Demographic FOREIGN KEY (DonatingLocationID)
		REFERENCES Demographic (LocationID)
);
GO


/*	create table for orders and bills (requirements k and l).
	this is the header for one order. everything requirement l asks for is a
	column here, the billing number, when it was placed, payment method, the
	order total, and the employee who collected it.
	requirement k is the OrderChannel column, in person online or phone.
	OrderDateTime is when the customer ordered and CreationDate is when the
	row was inserted, so they are two different columns.
	CustomerID is null for a walk in we do not know, and TableID is null for
	takeout since those do not use a table.
	ChefID is here because requirement b says chefs are responsible for
	certain orders.
	IsActive goes to 0 for a voided order so the billing number is not reused.
*/
CREATE TABLE Transactions (
	TransactionID INT IDENTITY(500001,1) NOT NULL,
	BillingNumber NVARCHAR(20) NOT NULL,
	OrderDateTime DATETIME2 NOT NULL,
	OrderChannel NVARCHAR(20) NOT NULL,
	PaymentMethod NVARCHAR(20) NOT NULL,
	OrderTotal DECIMAL(10,2) NOT NULL,
	LocationID INT NOT NULL,
	EmployeeID INT NOT NULL,
	CustomerID INT,
	ChefID INT,
	TableID INT,
	IsActive BIT NOT NULL DEFAULT 1,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_Transactions PRIMARY KEY (TransactionID),
	CONSTRAINT UQ_Transactions_BillingNumber UNIQUE (BillingNumber),
	CONSTRAINT FK_Transactions_Demographic FOREIGN KEY (LocationID)
		REFERENCES Demographic (LocationID),
	CONSTRAINT FK_Transactions_Chefs FOREIGN KEY (ChefID)
		REFERENCES Chefs (ChefID),
	CONSTRAINT CK_Transactions_OrderChannel CHECK (OrderChannel IN
		('In-Person', 'Online', 'Phone')),
	CONSTRAINT CK_Transactions_PaymentMethod CHECK (PaymentMethod IN
		('Cash', 'Credit Card', 'Debit Card', 'Gift Card', 'Mobile Pay'))
);
GO


/*	create table for the individual items on an order.
	requirement l asks for an order total, and this is the table that holds
	what the total is made up of. one row per dish on the bill.
	UnitPrice is stored on the row rather than looked up from Dishes so that
	an old bill still shows the price the customer actually paid after the
	menu price changes.
	LineTotal is computed so it can never disagree with the quantity and price
	on the same row.
*/
CREATE TABLE TransactionDetails (
	TransactionDetailID INT IDENTITY(1,1) NOT NULL,
	TransactionID INT NOT NULL,
	DishID INT NOT NULL,
	Quantity INT NOT NULL,
	UnitPrice DECIMAL(10,2) NOT NULL,
	LineTotal AS (Quantity * UnitPrice),
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_TransactionDetails PRIMARY KEY (TransactionDetailID),
	CONSTRAINT FK_TransactionDetails_Transactions FOREIGN KEY (TransactionID)
		REFERENCES Transactions (TransactionID),
	CONSTRAINT CK_TransactionDetails_Quantity CHECK (Quantity > 0)
);
GO


-- ============================================================================
-- GROUP 4 - Nathan Krouth
-- Dishes, Ingredients, Recipes, Menu
-- ============================================================================

/*	create table for the dishes served at the restaurant (requirement e).
	Price is the price listed on the menu for that dish, which covers
	requirement j.
	this is left fairly open ended in case more information is needed later.
*/
CREATE TABLE Dishes (
	DishID INT IDENTITY(1,1) NOT NULL,
	DishName NVARCHAR(50) NOT NULL,
	Price DECIMAL(10,2) NOT NULL,
	Notes NVARCHAR(100),
	DateAdded DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_Dishes PRIMARY KEY (DishID),
	CONSTRAINT CK_Dishes_Price_Positive CHECK (Price >= 0)
);
GO


/*	create table for the ingredients used in the recipes (requirement f).
	IngredientCost is what the ingredient costs the restaurant to buy, which
	is a different thing from the price a dish sells for.
	QuantityStocked is how much of it is currently on hand.
*/
CREATE TABLE Ingredients (
	IngredientID INT IDENTITY(101,1) NOT NULL,
	IngredientName NVARCHAR(30) NOT NULL,
	IngredientCost DECIMAL(10,2) NOT NULL,
	QuantityStocked INT NOT NULL,
	DateAdded DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_Ingredients PRIMARY KEY (IngredientID),
	CONSTRAINT CK_Ingredients_Cost_Positive CHECK (IngredientCost >= 0)
);
GO


/*	create table for the recipes used at the restaurant (requirements g and i).
	one row per ingredient in a dish, so a dish with five ingredients has five
	rows here. QuantityUsed is how much of that ingredient the dish takes,
	which is requirement g.
*/
CREATE TABLE Recipes (
	RecipeID INT IDENTITY(1,1) NOT NULL,
	DishID INT NOT NULL,
	IngredientID INT NOT NULL,
	QuantityUsed INT NOT NULL,
	DateAdded DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_Recipes PRIMARY KEY (RecipeID),
	CONSTRAINT FK_Recipes_DishID FOREIGN KEY (DishID)
		REFERENCES Dishes (DishID),
	CONSTRAINT FK_Recipes_IngredientID FOREIGN KEY (IngredientID)
		REFERENCES Ingredients (IngredientID),
	CONSTRAINT CK_Recipes_QuantityUsed_Positive
		CHECK (QuantityUsed > 0)
);
GO


/*	create table for the menu (requirement h).
	InUse marks whether that entry is on the menu currently, so a seasonal
	item can be taken off without deleting the row.
*/
CREATE TABLE Menu (
	MenuID INT IDENTITY(10,1) NOT NULL,
	RecipeID INT NOT NULL,
	InUse NVARCHAR(3) NOT NULL,
	DateAdded DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_Menu PRIMARY KEY (MenuID),
	CONSTRAINT FK_Menu_RecipeID FOREIGN KEY (RecipeID)
		REFERENCES Recipes (RecipeID),
	CONSTRAINT CK_Menu_InUse_Status CHECK (LOWER(InUse) IN ('yes', 'no'))
);
GO


-- ============================================================================
-- GROUP 3 - Nicholas Fearing
-- KitchenDetails, Reservations, Suppliers
-- ============================================================================

/*	create table for the kitchen details at each branch (requirement n).
	one row per kitchen, linked to the branch it sits in and to the chef who
	runs it.
	the three inspection columns are nullable because a kitchen that has just
	opened has not been inspected yet.
*/
CREATE TABLE KitchenDetails (
	KitchenID INT IDENTITY(1,1) NOT NULL,
	LocationID INT NOT NULL,
	NumStoves INT NOT NULL,
	AreaSqft INT NOT NULL,
	MinCooks INT NOT NULL,
	LeadChef INT NOT NULL,
	FreezerCubicFeet INT NOT NULL,
	LastInspectionDate DATETIME NULL,
	InspectionComments NVARCHAR(500) NULL,
	InspectionPassed BIT NULL,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_KitchenDetails PRIMARY KEY (KitchenID)
);
GO


/*	create table for reservations (requirement p).
	Recurring marks a customer who books the same day and time regularly.
	Cancelled lets a reservation be called off without deleting the row, since
	the requirement says reservations can be cancelled.
	TableID is nullable because the requirement also says a customer will not
	always be able to sit at their preferred table.
*/
CREATE TABLE Reservations (
	ReservationID INT IDENTITY(1,1) NOT NULL,
	ReservationDateTime DATETIME NOT NULL,
	CustomerID INT NOT NULL,
	TableID INT NULL,
	ServerID INT NULL,
	Recurring BIT NOT NULL,
	Cancelled BIT NOT NULL DEFAULT 0,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_Reservations PRIMARY KEY (ReservationID)
);
GO


/*	create table for the suppliers the restaurant orders from
	(requirement q).
	LengthOfHistory is when the restaurant started buying from them and
	OwedPayments is the balance currently outstanding with that supplier.
*/
CREATE TABLE Suppliers (
	SupplierID INT IDENTITY(1,1) NOT NULL,
	SupplierName NVARCHAR(25) NOT NULL,
	SupplierPhoneNum CHAR(10) NULL,
	SupplierAddress NVARCHAR(40) NOT NULL,
	LengthOfHistory DATETIME NULL,
	OwedPayments DECIMAL(10,2) NULL,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	-- constraints to enforce data integrity
	CONSTRAINT PK_Suppliers PRIMARY KEY (SupplierID)
);
GO


-- ============================================================================
-- CROSS-GROUP RELATIONSHIPS
--
-- Every foreign key below joins one group's tables to another's. They are
-- added here rather than inline so that all 18 CREATE TABLE statements above
-- can run in any order. Each one has its own GO so a single failure does not
-- stop the rest of the section.
-- ============================================================================

ALTER TABLE Customers ADD CONSTRAINT FK_Customers_PreferredOrder
	FOREIGN KEY (PreferredOrder) REFERENCES Dishes (DishID);
GO

ALTER TABLE Customers ADD CONSTRAINT FK_Customers_PreferredRes
	FOREIGN KEY (PreferredRes) REFERENCES Reservations (ReservationID);
GO

ALTER TABLE Chefs ADD CONSTRAINT FK_Chefs_Employees
	FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID);
GO

ALTER TABLE Chefs ADD CONSTRAINT FK_Chefs_Suppliers
	FOREIGN KEY (PreferredSupplierID) REFERENCES Suppliers (SupplierID);
GO

ALTER TABLE Transactions ADD CONSTRAINT FK_Transactions_Employees
	FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID);
GO

ALTER TABLE Transactions ADD CONSTRAINT FK_Transactions_Customers
	FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID);
GO

ALTER TABLE Transactions ADD CONSTRAINT FK_Transactions_ResTables
	FOREIGN KEY (TableID) REFERENCES ResTables (TableID);
GO

ALTER TABLE TransactionDetails ADD CONSTRAINT FK_TransactionDetails_Dishes
	FOREIGN KEY (DishID) REFERENCES Dishes (DishID);
GO

ALTER TABLE Reservations ADD CONSTRAINT FK_Reservations_Customers
	FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID);
GO

ALTER TABLE Reservations ADD CONSTRAINT FK_Reservations_ResTables
	FOREIGN KEY (TableID) REFERENCES ResTables (TableID);
GO

ALTER TABLE Reservations ADD CONSTRAINT FK_Reservations_ServerEmployees
	FOREIGN KEY (ServerID) REFERENCES ServerEmployees (ServerID);
GO

ALTER TABLE KitchenDetails ADD CONSTRAINT FK_KitchenDetails_Demographic
	FOREIGN KEY (LocationID) REFERENCES Demographic (LocationID);
GO

ALTER TABLE KitchenDetails ADD CONSTRAINT FK_KitchenDetails_Chefs
	FOREIGN KEY (LeadChef) REFERENCES Chefs (ChefID);
GO


-- ============================================================================
-- confirm the build
-- ============================================================================

SELECT COUNT(*) AS TableCount FROM sys.tables;

SELECT name AS TableName FROM sys.tables ORDER BY name;

SELECT name AS ForeignKeyName FROM sys.foreign_keys ORDER BY name;

/*	Make sure that the other SQL was added before you run this */

USE Restaurants;
GO


/*	create table for the restaurant locations (requirement a).
	the requirement says the restaurant is thinking about opening multiple
	locations, so this is one row per branch instead of one row for the whole
	business. that makes it the parent table my other tables point at.
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
	CONSTRAINT PK_Demographic PRIMARY KEY (LocationID)
);
GO


/*	create table for chefs (requirement b).
	chefs are employees, so instead of repeating name and hire date i linked
	back to the Employees table the same way group 1 did with ServerEmployees.
	salary is its own column because Employees stores an hourly rate and chefs
	are salaried.
	HomeLocationID is the branch they are based at, the other branches they
	cook at are in ChefLocations below.
	PreferredSupplierID is requirement q, certain chefs have a vendor they
	like to work with. Suppliers is group 3's table so the key gets added at
	the bottom once theirs is in.
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
	CONSTRAINT PK_Chefs PRIMARY KEY (ChefID),
	CONSTRAINT UQ_Chefs_EmployeeID UNIQUE (EmployeeID),
	CONSTRAINT FK_Chefs_Demographic FOREIGN KEY (HomeLocationID)
		REFERENCES Demographic (LocationID),
	CONSTRAINT CK_Chefs_ChefType CHECK (ChefType IN
		('Head Chef', 'Sous Chef', 'Pastry Chef', 'Line Cook', 'Prep Cook'))
);
GO


/*	create table linking chefs to the branches they cook at (requirement b).
	the requirement says each chef may cook at other branches, which is a
	many to many, so it needs its own table.
	IsActive goes to 0 when they stop covering that branch.
*/
CREATE TABLE ChefLocations (
	ChefLocationID INT IDENTITY(1,1) NOT NULL,
	ChefID INT NOT NULL,
	LocationID INT NOT NULL,
	IsActive BIT NOT NULL DEFAULT 1,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
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
	the requirement is one line so i kept this small. TotalDonatedValue is a
	running total of what we have given them instead of a whole second table
	tracking every drop off.
	DonatingLocationID is which branch handles that charity. since we have
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
	CONSTRAINT PK_Charities PRIMARY KEY (CharityID),
	CONSTRAINT UQ_Charities_CharityName UNIQUE (CharityName),
	CONSTRAINT FK_Charities_Demographic FOREIGN KEY (DonatingLocationID)
		REFERENCES Demographic (LocationID)
);
GO


/*	create table for orders and bills (requirements k and l).
	this is the header for one order. everything requirement l asks for is a
	column here, the billing number, when it was placed, payment method, the
	total, and the employee who took it.
	requirement k is the OrderChannel column, in person online or phone.
	OrderDateTime is when the customer ordered, CreationDate is when the row
	got inserted, so they are two different columns.
	CustomerID is null for a walk in we do not know and TableID is null for
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


/*	create table for the items on an order.
	requirement l asks for an order total but nothing in our tables held what
	was actually ordered, so the total had nothing behind it. this is one row
	per dish on the bill and it is what connects an order to group 4's
	Dishes table.
	it points at Dishes and not Menu because group 4's Menu table is a list of
	menus, not a list of items. a customer orders a dish, not a whole menu.
	UnitPrice is stored here instead of looked up so an old bill still shows
	what the customer actually paid after prices change.
*/
CREATE TABLE TransactionDetails (
	TransactionDetailID INT IDENTITY(1,1) NOT NULL,
	TransactionID INT NOT NULL,
	DishNum INT NOT NULL,
	Quantity INT NOT NULL,
	UnitPrice DECIMAL(10,2) NOT NULL,
	LineTotal AS (Quantity * UnitPrice),
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
	CONSTRAINT PK_TransactionDetails PRIMARY KEY (TransactionDetailID),
	CONSTRAINT FK_TransactionDetails_Transactions FOREIGN KEY (TransactionID)
		REFERENCES Transactions (TransactionID),
	CONSTRAINT CK_TransactionDetails_Quantity CHECK (Quantity > 0)
);
GO


/*	foreign keys to the other groups' tables. these are down here instead of
	inline so this script still runs on its own if the other groups' tables
	are not in yet. run this part last, after everyone's scripts.
*/
ALTER TABLE Chefs ADD CONSTRAINT FK_Chefs_Employees
	FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID);

ALTER TABLE Transactions ADD CONSTRAINT FK_Transactions_Employees
	FOREIGN KEY (EmployeeID) REFERENCES Employees (EmployeeID);

ALTER TABLE Transactions ADD CONSTRAINT FK_Transactions_Customers
	FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID);

ALTER TABLE Transactions ADD CONSTRAINT FK_Transactions_ResTables
	FOREIGN KEY (TableID) REFERENCES ResTables (TableID);

ALTER TABLE TransactionDetails ADD CONSTRAINT FK_TransactionDetails_Dishes
	FOREIGN KEY (DishNum) REFERENCES Dishes (DishNum);
GO


/*	group 3 has not put their tables up yet. uncomment once Suppliers is in
	and we know what they called the key.
*/
-- ALTER TABLE Chefs ADD CONSTRAINT FK_Chefs_Suppliers
--	FOREIGN KEY (PreferredSupplierID) REFERENCES Suppliers (SupplierID);
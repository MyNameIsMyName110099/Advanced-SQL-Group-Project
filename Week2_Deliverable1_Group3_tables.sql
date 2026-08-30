-- Do not run this code until the code from groups one and two have been run.
-- The block comments above each section of code are the AI prompts.

USE Restaurant;

/*
	create table in t-sql called KitchenDetails. pk is a fk from a table 
	'Demographic' on int 'LocationID', int 'NumStoves', int 'AreaSqft', int 'MinCooks', 
	nvarchar(12) 'ChefType', int 'FreezerCubicFeet', datetime 'LastInspectionDate', 
	nvarchar(500) 'InspectionComments', bit 'InspectionPassed'. the last three fields 
	relating to inspections are allowed to be null, all other fields are not nullable.
*/

CREATE TABLE KitchenDetails (
	KitchenID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
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
);

/*
	create table in t-sql called Reservations. pk is auto-incrementing int 
	called ReservationID. other fields are datetime 'ReservationDateTime', int 
	'CustomerID' fk on table 'Customers', int 'TableID' fk on table 'Tables', 
	int 'ServerID' fk on table 'Servers', bit 'Recurring'. tableid and serverid 
	can be null, the rest are not nullable.
*/

CREATE TABLE Reservations (
    ReservationID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    ReservationDateTime DATETIME NOT NULL,
    CustomerID INT NOT NULL,
    TableID INT NULL,
    ServerID INT NULL,
    Recurring BIT NOT NULL,
	Cancelled BIT NOT NULL DEFAULT 0,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

/*
	create table in t-sql called Suppliers. pk is auto-incrementing int called SupplierID. 
	other fields are varchar(25) 'SupplierName', char(10) 'SupplierPhoneNum', varchar(40) 
	'SupplierAddress', datetime 'LengthOfHistory', decimal(7,2) 'OwedPayments'. supplierid, 
	suppliername, and supplieraddress are not nullable, the other fields are.
*/

CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    SupplierName NVARCHAR(25) NOT NULL,
    SupplierPhoneNum CHAR(10) NULL,
    SupplierAddress NVARCHAR(40) NOT NULL,
    LengthOfHistory DATETIME NULL,
    OwedPayments DECIMAL(10,2) NULL,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

/* --foreign keys dependent on tables from other group members

	--group #1:
ALTER TABLE Reservations
ADD CONSTRAINT FK_Reservations_Customers FOREIGN KEY (CustomerID) 
        REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Reservations_ResTables FOREIGN KEY (TableID) 
        REFERENCES ResTables(TableID),
    CONSTRAINT FK_Reservations_ServerEmployees FOREIGN KEY (ServerID) 
        REFERENCES ServerEmployees(ServerID);

	--group #2:
ALTER TABLE KitchenDetails
ADD CONSTRAINT FK_KitchenDetails_Demographic FOREIGN KEY (LocationID) 
        REFERENCES Demographic(LocationID),
    CONSTRAINT FK_KitchenDetails_Chefs FOREIGN KEY (LeadChef) 
        REFERENCES Chefs(ChefID);

*/

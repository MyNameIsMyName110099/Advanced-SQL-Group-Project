-- Do not run this code until the code from groups one and two have been run.
-- The block comments above each section of code are the AI prompts.

USE Restaurants;

/*
	create table in t-sql called KitchenDetails. pk is a fk from a table 
	'Demographic' on int 'LocationID', int 'NumStoves', int 'AreaSqft', int 'MinCooks', 
	varchar(12) 'ChefType', int 'FreezerCubicFeet', datetime 'LastInspectionDate', 
	varchar(500) 'InspectionComments', bit 'InspectionPassed'. the last three fields 
	relating to inspections are allowed to be null, all other fields are not nullable.
*/

CREATE TABLE KitchenDetails (
    LocationID INT PRIMARY KEY NOT NULL,
    NumStoves INT NOT NULL,
    AreaSqft INT NOT NULL,
    MinCooks INT NOT NULL,
    ChefType VARCHAR(12) NOT NULL,
    FreezerCubicFeet INT NOT NULL,
    LastInspectionDate DATETIME NULL,
    InspectionComments VARCHAR(500) NULL,
    InspectionPassed BIT NULL,

    -- Foreign Key Constraint mapping back to Demographic table
    CONSTRAINT FK_KitchenDetails_Demographic FOREIGN KEY (LocationID) 
        REFERENCES Demographic(LocationID)
);

/*
	create table in t-sql called Reservations. pk is auto-incrementing int 
	called ReservationID. other fields are datetime 'ReservationDate', int 
	'CustomerID' fk on table 'Customers', int 'TableID' fk on table 'Tables', 
	int 'ServerID' fk on table 'Servers', bit 'Recurring'. tableid and serverid 
	can be null, the rest are not nullable.
*/

CREATE TABLE Reservations (
    ReservationID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    ReservationDate DATETIME NOT NULL,
    CustomerID INT NOT NULL,
    TableID INT NULL,
    ServerID INT NULL,
    Recurring BIT NOT NULL,

    -- Foreign Key Constraints
    CONSTRAINT FK_Reservations_Customers FOREIGN KEY (CustomerID) 
        REFERENCES Customers(CustomerID),
        
    CONSTRAINT FK_Reservations_Tables FOREIGN KEY (TableID) 
        REFERENCES Tables(TableID),
        
    CONSTRAINT FK_Reservations_Servers FOREIGN KEY (ServerID) 
        REFERENCES Servers(ServerID)
);

/*
	create table in t-sql called Suppliers. pk is auto-incrementing int called SupplierID. 
	other fields are varchar(25) 'SupplierName', char(10) 'SupplierPhoneNum', varchar(40) 
	'SupplierAddress', datetime 'LengthOfHistory', decimal(7,2) 'OwedPayments'. supplierid, 
	suppliername, and supplieraddress are not nullable, the other fields are.
*/

CREATE TABLE Suppliers (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
    SupplierName VARCHAR(25) NOT NULL,
    SupplierPhoneNum CHAR(10) NULL,
    SupplierAddress VARCHAR(40) NOT NULL,
    LengthOfHistory DATETIME NULL,
    OwedPayments DECIMAL(7,2) NULL
);

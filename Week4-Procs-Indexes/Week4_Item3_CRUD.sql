USE Restaurant;
GO


-- ============================================================================
-- Drop the procedures if they already exist so this file can be re-run.
-- ============================================================================
DROP PROCEDURE IF EXISTS spN_GetCharities;
DROP PROCEDURE IF EXISTS spN_InsertCharities;
DROP PROCEDURE IF EXISTS spN_UpdateCharities;
DROP PROCEDURE IF EXISTS spN_DeleteCharities;
DROP PROCEDURE IF EXISTS spN_GetKitchenDetails;
DROP PROCEDURE IF EXISTS spN_InsertKitchenDetails;
DROP PROCEDURE IF EXISTS spN_UpdateKitchenDetails;
DROP PROCEDURE IF EXISTS spN_DeleteKitchenDetails;
GO


-- ============================================================================
-- ITEM 3 - CRUD STORED PROCEDURES
--
-- The two tables are Charities and KitchenDetails, chosen because nothing
-- else has a foreign key pointing at them, so the DELETE procedures can run
-- without breaking a relationship. The project says each procedure "should
-- not generate any exceptions and all should return data", so the INSERT
-- procedures check for anything that would trip a constraint and return a
-- Rejected message instead of letting SQL Server throw, and every procedure
-- returns a result set.
--
--   SELECT   spN_GetCharities        spN_GetKitchenDetails       Mason
--   INSERT   spN_InsertCharities     spN_InsertKitchenDetails    Mason
--   UPDATE   spN_UpdateCharities     spN_UpdateKitchenDetails    Nicholas
--   DELETE   spN_DeleteCharities     spN_DeleteKitchenDetails    Nathan
-- ============================================================================

-- ============================================================================
-- SELECT - spN_GetCharities
-- Mason Romdenne
--
-- Takes the primary key as an optional parameter, so with no argument it
-- returns every row and with an ID it returns just that one. Shows the
-- branch name instead of the LocationID. LEFT JOIN because a charity does
-- not have to be assigned to a branch.
-- ============================================================================
CREATE PROCEDURE spN_GetCharities
	@CharityID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT c.CharityID,
		c.CharityName AS 'Charity',
		c.CharityType AS 'Type',
		c.ContactName AS 'Contact',
		c.PhoneNumber AS 'Phone',
		c.City,
		d.LocationName AS 'Donating Branch',
		FORMAT(c.TotalDonatedValue, 'C', 'en-IE') AS 'Total Donated',
		CASE WHEN c.IsActive = 1 THEN 'Yes' ELSE 'No' END AS 'Active',
		c.CreationDate AS 'Created'
	FROM Charities c
		LEFT JOIN Demographic d ON c.DonatingLocationID = d.LocationID
	WHERE (@CharityID IS NULL OR c.CharityID = @CharityID)
	ORDER BY c.CharityName;
END;
GO


-- ============================================================================
-- SELECT - spN_GetKitchenDetails
-- Mason Romdenne
--
-- Kitchens with the branch name and the lead chef's name. The chef name goes
-- through Chefs to Employees since Chefs only stores an EmployeeID.
-- ============================================================================
CREATE PROCEDURE spN_GetKitchenDetails
	@KitchenID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT k.KitchenID,
		d.LocationName AS 'Branch',
		k.NumStoves AS 'Stoves',
		k.AreaSqft AS 'Area (sq ft)',
		k.MinCooks AS 'Min Cooks',
		CONCAT(e.FirstName, ' ', e.LastName) AS 'Lead Chef',
		c.ChefType AS 'Lead Chef Type',
		k.FreezerCubicFeet AS 'Freezer (cu ft)',
		k.LastInspectionDate AS 'Last Inspection',
		CASE k.InspectionPassed
			WHEN 1 THEN 'Passed'
			WHEN 0 THEN 'Failed'
			ELSE 'Not yet inspected'
		END AS 'Inspection Result',
		k.InspectionComments AS 'Inspection Comments',
		k.CreationDate AS 'Created'
	FROM KitchenDetails k
		INNER JOIN Demographic d ON k.LocationID = d.LocationID
		INNER JOIN Chefs c ON k.LeadChef = c.ChefID
		INNER JOIN Employees e ON c.EmployeeID = e.EmployeeID
	WHERE (@KitchenID IS NULL OR k.KitchenID = @KitchenID)
	ORDER BY k.KitchenID;
END;
GO


-- ============================================================================
-- INSERT - spN_InsertCharities
-- Mason Romdenne
--
-- Every column a user can fill in is a parameter. CreationDate is left out so
-- its default of SYSDATETIME() records when the row was inserted.
-- CharityName is required, the rest can be left off. Checks a blank name, a
-- duplicate name (unique constraint), a branch that does not exist (foreign
-- key) and a negative donation total. On a good call it returns the row it
-- just inserted.
-- ============================================================================
CREATE PROCEDURE spN_InsertCharities
	@CharityName NVARCHAR(100),
	@CharityType NVARCHAR(50) = NULL,
	@ContactName NVARCHAR(100) = NULL,
	@PhoneNumber NVARCHAR(20) = NULL,
	@City NVARCHAR(50) = NULL,
	@DonatingLocationID INT = NULL,
	@TotalDonatedValue DECIMAL(10,2) = NULL,
	@IsActive BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	IF @CharityName IS NULL OR LTRIM(RTRIM(@CharityName)) = ''
	BEGIN
		SELECT 'Rejected - a charity name is required.' AS 'Result';
		RETURN 1;
	END;

	IF EXISTS (SELECT 1 FROM Charities WHERE CharityName = @CharityName)
	BEGIN
		SELECT CONCAT('Rejected - ', @CharityName, ' already exists.') AS 'Result';
		RETURN 1;
	END;

	IF @DonatingLocationID IS NOT NULL
		AND NOT EXISTS (SELECT 1 FROM Demographic WHERE LocationID = @DonatingLocationID)
	BEGIN
		SELECT CONCAT('Rejected - no location with ID ', @DonatingLocationID, '.') AS 'Result';
		RETURN 1;
	END;

	IF @TotalDonatedValue < 0
	BEGIN
		SELECT 'Rejected - the donated total cannot be negative.' AS 'Result';
		RETURN 1;
	END;

	INSERT INTO Charities
		(CharityName, CharityType, ContactName, PhoneNumber, City,
		DonatingLocationID, TotalDonatedValue, IsActive)
	VALUES
		(@CharityName, @CharityType, @ContactName, @PhoneNumber, @City,
		@DonatingLocationID, @TotalDonatedValue, @IsActive);

	-- return the new row so the ID and CreationDate show up
	SELECT * FROM Charities WHERE CharityID = SCOPE_IDENTITY();
	RETURN 0;
END;
GO


-- ============================================================================
-- INSERT - spN_InsertKitchenDetails
-- Mason Romdenne
--
-- Six required parameters for the six NOT NULL columns; the inspection
-- columns can be left off since a new kitchen has not been inspected yet.
-- Checks the branch and the chef exist (both foreign keys) and that the
-- sizes and counts are above zero.
-- ============================================================================
CREATE PROCEDURE spN_InsertKitchenDetails
	@LocationID INT,
	@NumStoves INT,
	@AreaSqft INT,
	@MinCooks INT,
	@LeadChef INT,
	@FreezerCubicFeet INT,
	@LastInspectionDate DATETIME = NULL,
	@InspectionComments NVARCHAR(500) = NULL,
	@InspectionPassed BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM Demographic WHERE LocationID = @LocationID)
	BEGIN
		SELECT CONCAT('Rejected - no location with ID ', ISNULL(@LocationID, 0), '.') AS 'Result';
		RETURN 1;
	END;

	IF NOT EXISTS (SELECT 1 FROM Chefs WHERE ChefID = @LeadChef)
	BEGIN
		SELECT CONCAT('Rejected - no chef with ID ', ISNULL(@LeadChef, 0), '.') AS 'Result';
		RETURN 1;
	END;

	IF ISNULL(@NumStoves, 0) <= 0 OR ISNULL(@AreaSqft, 0) <= 0
		OR ISNULL(@MinCooks, 0) <= 0 OR ISNULL(@FreezerCubicFeet, 0) <= 0
	BEGIN
		SELECT 'Rejected - stoves, area, min cooks and freezer size must be above zero.' AS 'Result';
		RETURN 1;
	END;

	INSERT INTO KitchenDetails
		(LocationID, NumStoves, AreaSqft, MinCooks, LeadChef, FreezerCubicFeet,
		LastInspectionDate, InspectionComments, InspectionPassed)
	VALUES
		(@LocationID, @NumStoves, @AreaSqft, @MinCooks, @LeadChef, @FreezerCubicFeet,
		@LastInspectionDate, @InspectionComments, @InspectionPassed);

	SELECT * FROM KitchenDetails WHERE KitchenID = SCOPE_IDENTITY();
	RETURN 0;
END;
GO


-- ============================================================================
-- UPDATE - spN_UpdateKitchenDetails
-- Nicholas Fearing
--
-- UPDATE stored proc on KitchenDetails table for inputting inspection data.
-- Proc takes four parameters:
--   KitchenID int (to identify row to be updated),
--   Comments nvarchar(500),
--   InspectionPassed bit,
--   LastInspectionDate datetime (defaults to day and time of update if not given)
-- Returns the updated row.
-- ============================================================================
CREATE PROC spN_UpdateKitchenDetails
	@KitchenID int,
	@Comments nvarchar(500),
	@InspectionPassed bit,
	@InspectionDate datetime = NULL
AS
BEGIN TRY
	IF @InspectionDate IS NULL
		SELECT @InspectionDate = SYSDATETIME();

	BEGIN TRAN;
		UPDATE KitchenDetails
		SET InspectionComments = @Comments,
			InspectionPassed = @InspectionPassed,
			LastInspectionDate = @InspectionDate
		WHERE KitchenID = @KitchenID
	COMMIT TRAN;

	SELECT * FROM KitchenDetails WHERE KitchenID = @KitchenID;
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
END CATCH;
GO


-- ============================================================================
-- UPDATE - spN_UpdateCharities
-- Nicholas Fearing
--
-- UPDATE stored proc on Charities table for updating charity info.
-- Proc takes six parameters:
--   CharityID int (to identify row to be updated),
--   IsActive bit,
--   ContactName nvarchar(100),
--   PhoneNumber nvarchar(20),
--   CharityName nvarchar(100),
--   CharityType nvarchar(50)
-- The last four parameters default to existing value and are optional.
-- They are ordered from most likely to change to least. Returns the
-- updated row.
-- ============================================================================
CREATE PROC spN_UpdateCharities
	@CharityID int,
	@IsActive bit,
	@ContactName nvarchar(100) = NULL,
	@PhoneNumber nvarchar(20) = NULL,
	@CharityName nvarchar(100) = NULL,
	@CharityType nvarchar(50) = NULL
AS
BEGIN TRY
	IF @ContactName IS NULL
		SELECT @ContactName = ContactName FROM Charities WHERE CharityID = @CharityID;

	IF @PhoneNumber IS NULL
		SELECT @PhoneNumber = PhoneNumber FROM Charities WHERE CharityID = @CharityID;

	IF @CharityName IS NULL
		SELECT @CharityName = CharityName FROM Charities WHERE CharityID = @CharityID;

	IF @CharityType IS NULL
		SELECT @CharityType = CharityType FROM Charities WHERE CharityID = @CharityID;

	BEGIN TRAN;
		UPDATE Charities
		SET IsActive = @IsActive,
			ContactName = @ContactName,
			PhoneNumber = @PhoneNumber,
			CharityName = @CharityName,
			CharityType = @CharityType
		WHERE CharityID = @CharityID;
	COMMIT TRAN;

	SELECT * FROM Charities WHERE CharityID = @CharityID;
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
END CATCH;
GO


-- ============================================================================
-- DELETE - spN_DeleteCharities
-- Nathan Krouth
--
-- Procedure to delete items from the Charities table.
-- Thankfully simple since there are no dependencies here.
-- Returns how many rows were deleted.
-- ============================================================================
CREATE PROC spN_DeleteCharities

	@CharityID INT

AS

DELETE FROM Charities
WHERE CharityID = @CharityID;

SELECT @@ROWCOUNT AS RowsDeleted;
GO


-- ============================================================================
-- DELETE - spN_DeleteKitchenDetails
-- Nathan Krouth
--
-- Procedure to delete items from the KitchenDetails table.
-- Nothing has a foreign key to KitchenDetails (chefs are tied to a branch
-- through Demographic, not through the kitchen), so the row can be removed
-- without touching any other table. Returns how many rows were deleted.
-- ============================================================================
CREATE PROC spN_DeleteKitchenDetails

	@KitchenID INT,
	@LocationID INT

AS

DELETE FROM KitchenDetails
WHERE LocationID = @LocationID AND KitchenID = @KitchenID;

SELECT @@ROWCOUNT AS RowsDeleted;
GO


-- ============================================================================
-- TESTING
--
-- Calls every procedure above. Run the file as a whole, or highlight one
-- statement at a time for the screenshots. The tests insert a test charity
-- and a test kitchen, update them, then delete them, so the tables end up
-- exactly as they started (15 charities, 5 kitchens). The INSERT procedures
-- also get bad calls to show the Rejected message instead of an exception.
-- ============================================================================

-- clear out any test rows an earlier run left behind, so the counts below
-- start from 15 charities and 5 kitchens
DELETE FROM Charities WHERE CharityName IN ('Week 4 Test Charity', 'Joyce Dublin Clinic');
DELETE FROM KitchenDetails WHERE InspectionComments IN ('Week 4 test row', 'Insufficient fire suppression system.');

-- SELECT - all rows then one row
EXEC spN_GetCharities;
EXEC spN_GetCharities @CharityID = 9001;
EXEC spN_GetKitchenDetails;
EXEC spN_GetKitchenDetails @KitchenID = 3;

-- INSERT - a good call then a bad call for each
EXEC spN_InsertCharities @CharityName = 'Week 4 Test Charity',
	@CharityType = 'Food Bank', @City = 'Galway', @DonatingLocationID = 1,
	@TotalDonatedValue = 250.00;
EXEC spN_InsertCharities @CharityName = 'Week 4 Test Charity';
EXEC spN_InsertCharities @CharityName = 'Bad Branch', @DonatingLocationID = 9999;

EXEC spN_InsertKitchenDetails @LocationID = 1, @NumStoves = 5, @AreaSqft = 80,
	@MinCooks = 4, @LeadChef = 501, @FreezerCubicFeet = 100,
	@InspectionComments = 'Week 4 test row';
EXEC spN_InsertKitchenDetails @LocationID = 1, @NumStoves = 5, @AreaSqft = 80,
	@MinCooks = 4, @LeadChef = 9999, @FreezerCubicFeet = 100;
EXEC spN_InsertKitchenDetails @LocationID = 1, @NumStoves = 0, @AreaSqft = 80,
	@MinCooks = 4, @LeadChef = 501, @FreezerCubicFeet = 100;

-- UPDATE - the test rows
-- the lookups match the row before and after the UPDATE renames it, so each
-- statement below can be highlighted and run on its own
DECLARE @TestCharity INT = (SELECT MAX(CharityID) FROM Charities
	WHERE CharityName IN ('Week 4 Test Charity', 'Joyce Dublin Clinic'));
DECLARE @TestKitchen INT = (SELECT MAX(KitchenID) FROM KitchenDetails
	WHERE InspectionComments IN ('Week 4 test row', 'Insufficient fire suppression system.'));

EXEC spN_UpdateCharities @CharityID = @TestCharity, @IsActive = 1,
	@ContactName = 'James Joyce', @PhoneNumber = '353 1 878 8547',
	@CharityName = 'Joyce Dublin Clinic', @CharityType = 'Free Clinic';

EXEC spN_UpdateKitchenDetails @KitchenID = @TestKitchen,
	@Comments = 'Insufficient fire suppression system.', @InspectionPassed = 0;

-- DELETE - the test rows
EXEC spN_DeleteCharities @CharityID = @TestCharity;
EXEC spN_DeleteKitchenDetails @KitchenID = @TestKitchen, @LocationID = 1;

-- back to 15 and 5
SELECT (SELECT COUNT(*) FROM Charities) AS 'Charities',
	(SELECT COUNT(*) FROM KitchenDetails) AS 'Kitchens';
GO

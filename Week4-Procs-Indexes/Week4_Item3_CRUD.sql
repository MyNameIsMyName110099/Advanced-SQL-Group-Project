-- ============================================================================
-- Advanced SQL Semester Project
-- Week 4 Deliverables, Item 3 - CRUD Stored Procedures
--
-- Mason Romdenne, Nathan Krouth, Nicholas Fearing
-- Prepared by Mason Romdenne
-- Database: Restaurant
--
-- Item 3 asks for CRUD stored procedures on two tables, one procedure per
-- action, named spN_<Action><Table>. The two tables are Charities and
-- KitchenDetails. The group split the work by action:
--
--   SELECT   spN_GetCharities        spN_GetKitchenDetails       Mason
--   INSERT   spN_InsertCharities     spN_InsertKitchenDetails    Mason
--   UPDATE   spN_UpdateCharities     spN_UpdateKitchenDetails    Nicholas
--   DELETE   spN_DeleteCharities     spN_DeleteKitchenDetails    Nathan
--
-- Money columns use FORMAT(value, 'C', 'en-IE') so SQL Server supplies the
-- euro sign for the Irish locale rather than it being hardcoded.
--
-- Each object is written by the group member named above it and was reviewed
-- and merged through a pull request on the group's GitHub repo.
--
-- Run the whole file at once. Every object is dropped first if it already
-- exists, so it can be run again without editing. The TESTING section at the
-- bottom is the testing code for this submission.
-- ============================================================================

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
-- not generate any exceptions and all should return data", so every
-- procedure checks for anything that would trip a constraint first and
-- returns a Rejected message instead of letting SQL Server throw, and every
-- procedure returns a result set.
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
-- UPDATE - spN_UpdateCharities
-- Nicholas Fearing
--
-- Updates a charity's info. Takes six parameters: CharityID (to identify the
-- row), IsActive, ContactName, PhoneNumber, CharityName and CharityType. The
-- last four are optional and default to the row's existing value, ordered
-- from most likely to change to least. Checks the charity exists and that a
-- new name is not already taken, then returns the updated row.
-- ============================================================================
CREATE PROCEDURE spN_UpdateCharities
	@CharityID INT,
	@IsActive BIT,
	@ContactName NVARCHAR(100) = NULL,
	@PhoneNumber NVARCHAR(20) = NULL,
	@CharityName NVARCHAR(100) = NULL,
	@CharityType NVARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM Charities WHERE CharityID = @CharityID)
	BEGIN
		SELECT CONCAT('Rejected - no charity with ID ', ISNULL(@CharityID, 0), '.') AS 'Result';
		RETURN 1;
	END;

	IF @CharityName IS NOT NULL
		AND EXISTS (SELECT 1 FROM Charities WHERE CharityName = @CharityName AND CharityID <> @CharityID)
	BEGIN
		SELECT CONCAT('Rejected - ', @CharityName, ' already exists.') AS 'Result';
		RETURN 1;
	END;

	-- any parameter left off keeps the value already on the row
	IF @ContactName IS NULL
		SELECT @ContactName = ContactName FROM Charities WHERE CharityID = @CharityID;

	IF @PhoneNumber IS NULL
		SELECT @PhoneNumber = PhoneNumber FROM Charities WHERE CharityID = @CharityID;

	IF @CharityName IS NULL
		SELECT @CharityName = CharityName FROM Charities WHERE CharityID = @CharityID;

	IF @CharityType IS NULL
		SELECT @CharityType = CharityType FROM Charities WHERE CharityID = @CharityID;

	BEGIN TRY
		BEGIN TRAN;
			UPDATE Charities
			SET IsActive = @IsActive,
				ContactName = @ContactName,
				PhoneNumber = @PhoneNumber,
				CharityName = @CharityName,
				CharityType = @CharityType
			WHERE CharityID = @CharityID;
		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		SELECT CONCAT('Rejected - ', ERROR_MESSAGE()) AS 'Result';
		RETURN 1;
	END CATCH;

	-- return the updated row
	SELECT * FROM Charities WHERE CharityID = @CharityID;
	RETURN 0;
END;
GO


-- ============================================================================
-- UPDATE - spN_UpdateKitchenDetails
-- Nicholas Fearing
--
-- Records an inspection on a kitchen. Takes four parameters: KitchenID (to
-- identify the row), Comments, InspectionPassed and InspectionDate, which
-- defaults to the day and time of the update if not given. Checks the
-- kitchen exists, then returns the updated row.
-- ============================================================================
CREATE PROCEDURE spN_UpdateKitchenDetails
	@KitchenID INT,
	@Comments NVARCHAR(500),
	@InspectionPassed BIT,
	@InspectionDate DATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM KitchenDetails WHERE KitchenID = @KitchenID)
	BEGIN
		SELECT CONCAT('Rejected - no kitchen with ID ', ISNULL(@KitchenID, 0), '.') AS 'Result';
		RETURN 1;
	END;

	IF @InspectionDate IS NULL
		SELECT @InspectionDate = SYSDATETIME();

	BEGIN TRY
		BEGIN TRAN;
			UPDATE KitchenDetails
			SET InspectionComments = @Comments,
				InspectionPassed = @InspectionPassed,
				LastInspectionDate = @InspectionDate
			WHERE KitchenID = @KitchenID;
		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRAN;
		SELECT CONCAT('Rejected - ', ERROR_MESSAGE()) AS 'Result';
		RETURN 1;
	END CATCH;

	-- return the updated row
	SELECT * FROM KitchenDetails WHERE KitchenID = @KitchenID;
	RETURN 0;
END;
GO


-- ============================================================================
-- DELETE - spN_DeleteCharities
-- Nathan Krouth
--
-- Deletes a charity by CharityID. Simple since no other table has a foreign
-- key to Charities, so there are no dependencies to clear first. Checks the
-- charity exists, then returns what was deleted.
-- ============================================================================
CREATE PROCEDURE spN_DeleteCharities
	@CharityID INT
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM Charities WHERE CharityID = @CharityID)
	BEGIN
		SELECT CONCAT('Rejected - no charity with ID ', ISNULL(@CharityID, 0), '.') AS 'Result';
		RETURN 1;
	END;

	DECLARE @Name NVARCHAR(100) = (SELECT CharityName FROM Charities WHERE CharityID = @CharityID);

	DELETE FROM Charities
	WHERE CharityID = @CharityID;

	DECLARE @Rows INT = @@ROWCOUNT;

	SELECT CONCAT('Deleted charity ', @CharityID, ' - ', @Name, '.') AS 'Result',
		@Rows AS 'Rows Deleted';
	RETURN 0;
END;
GO


-- ============================================================================
-- DELETE - spN_DeleteKitchenDetails
-- Nathan Krouth
--
-- Deletes a kitchen by KitchenID. Chefs are linked to a branch through
-- Demographic, not through KitchenDetails, and nothing references
-- KitchenDetails, so the row can be removed without touching any other
-- table. Checks the kitchen exists, then returns what was deleted.
-- ============================================================================
CREATE PROCEDURE spN_DeleteKitchenDetails
	@KitchenID INT
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS (SELECT 1 FROM KitchenDetails WHERE KitchenID = @KitchenID)
	BEGIN
		SELECT CONCAT('Rejected - no kitchen with ID ', ISNULL(@KitchenID, 0), '.') AS 'Result';
		RETURN 1;
	END;

	DECLARE @Branch NVARCHAR(100) = (
		SELECT d.LocationName
		FROM KitchenDetails k
			INNER JOIN Demographic d ON k.LocationID = d.LocationID
		WHERE k.KitchenID = @KitchenID);

	DELETE FROM KitchenDetails
	WHERE KitchenID = @KitchenID;

	DECLARE @Rows INT = @@ROWCOUNT;

	SELECT CONCAT('Deleted kitchen ', @KitchenID, ' at ', @Branch, '.') AS 'Result',
		@Rows AS 'Rows Deleted';
	RETURN 0;
END;
GO


-- ============================================================================
-- TESTING
--
-- Calls every procedure above. Run the file as a whole, or highlight one
-- statement at a time for the screenshots. The tests insert a test charity
-- and a test kitchen, update them, then delete them, so the tables end up
-- exactly as they started (15 charities, 5 kitchens). Each action also
-- gets a bad call to show the Rejected message instead of an exception.
-- ============================================================================

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

-- UPDATE - the test rows, then a bad ID
DECLARE @TestCharity INT = (SELECT CharityID FROM Charities WHERE CharityName = 'Week 4 Test Charity');
DECLARE @TestKitchen INT = (SELECT KitchenID FROM KitchenDetails WHERE InspectionComments = 'Week 4 test row');

EXEC spN_UpdateCharities @CharityID = @TestCharity, @IsActive = 1,
	@ContactName = 'James Joyce', @PhoneNumber = '353 1 878 8547',
	@CharityName = 'Joyce Dublin Clinic', @CharityType = 'Free Clinic';
EXEC spN_UpdateCharities @CharityID = 9999, @IsActive = 0;

EXEC spN_UpdateKitchenDetails @KitchenID = @TestKitchen,
	@Comments = 'Insufficient fire suppression system.', @InspectionPassed = 0;
EXEC spN_UpdateKitchenDetails @KitchenID = 9999, @Comments = 'x', @InspectionPassed = 1;

-- DELETE - the test rows, then a bad ID
EXEC spN_DeleteCharities @CharityID = @TestCharity;
EXEC spN_DeleteCharities @CharityID = 9999;

EXEC spN_DeleteKitchenDetails @KitchenID = @TestKitchen;
EXEC spN_DeleteKitchenDetails @KitchenID = 9999;

-- back to 15 and 5
SELECT (SELECT COUNT(*) FROM Charities) AS 'Charities',
	(SELECT COUNT(*) FROM KitchenDetails) AS 'Kitchens';
GO

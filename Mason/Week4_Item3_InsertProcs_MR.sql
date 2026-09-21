USE Restaurant;
GO

DROP PROCEDURE IF EXISTS spN_InsertCharities;
DROP PROCEDURE IF EXISTS spN_InsertKitchenDetails;
GO

-- 3. INSERT procedures for Charities and KitchenDetails. every column a
-- user can fill in is a parameter. CreationDate is left out so its default
-- of SYSDATETIME() records when the row was inserted. the project says
-- these must not throw exceptions, so each one checks the things that
-- would break a constraint first and returns a message instead of an
-- error. on a good call it returns the row it just inserted.

-- CharityName is required, the rest can be left off. checks a blank name,
-- a duplicate name (unique constraint), a branch that does not exist
-- (foreign key) and a negative donation total.
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

-- six required parameters for the six NOT NULL columns, the inspection
-- columns can be left off since a new kitchen has not been inspected yet.
-- checks the branch and the chef exist (both foreign keys) and that the
-- sizes and counts are above zero.
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

USE Restaurant
GO

/* Item 3c-i - UPDATE stored proc on KitchenDetails table 
	for inputting inspection data.
Proc takes four parameters:
	KitchenID int (to identify row to be updated),
	Comments nvarchar(500),
	InspectionPassed bit,
	LastInspectionDate datetime (defaults to day and time of update if not given) */
CREATE PROC spN_UpdateInspection
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
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
END CATCH;
GO


/* Item 3c-ii - UPDATE stored proc on Charities table for updating charity info.
Proc takes six parameters:
	CharityID int (to identify row to be updated),
	IsActive bit,
	ContactName nvarchar(100),
	PhoneNumber nvarchar(20),
	CharityName nvarchar(100),
	CharityType nvarchar(50)
The last four parameters default to existing value and are optional.
	They are ordered from most likely to change to least. */

CREATE PROC spN_UpdateCharityInfo
	@CharityID int,
	@IsActive bit,
	@ContactName nvarchar(100) = NULL,
	@PhoneNumber nvarchar(20) = NULL,
	@CharityName nvarchar(100) = NULL,
	@CharityType nvarchar(50) = NULL
AS
BEGIN TRY
	IF @ContactName IS NULL
		SELECT @ContactName = ContactName FROM Charities;
		
	IF @PhoneNumber IS NULL
		SELECT @PhoneNumber = PhoneNumber FROM Charities;
		
	IF @CharityName IS NULL
		SELECT @CharityName = CharityName FROM Charities;
		
	IF @CharityType IS NULL
		SELECT @CharityType = CharityType FROM Charities;
		
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
	ROLLBACK TRAN;
END CATCH;
GO

--Testing code for update on KitchenDetails
exec spN_UpdateInspection 2, "Insufficient Fire System.", 0

--Testing code for Update on Charities
exec spN_UpdateCharityInfo 9001, 1, "James Joyce", "353 1 878 8547", "Joyce Dublin Clinic", "Free Clinic"
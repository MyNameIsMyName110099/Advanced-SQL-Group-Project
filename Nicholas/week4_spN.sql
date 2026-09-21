USE Restaurant
GO

/* Item 1d - Stored Procedure returns all columns from KitchenDetails.
	If parameter left empty, it returns all rows;
	else it returns only the row with matching LeadChef. */

CREATE PROCEDURE spN_KitchenDetails
	@LeadChef int = NULL
AS
BEGIN
	BEGIN TRY
		SELECT *
		FROM KitchenDetails
		WHERE @LeadChef IS NULL OR @LeadChef = LeadChef
	END TRY
	BEGIN CATCH
		PRINT 'An error occured while searching for Chef #' + 
			CONVERT(varchar, @LeadChef, 1) + '.'
	END CATCH
END;
GO

--Testing code for Item 1d, both without and with parameter
exec spN_KitchenDetails
exec spN_KitchenDetails 503
GO
USE Restaurant;
GO

DROP PROCEDURE IF EXISTS spN_GetCharities;
DROP PROCEDURE IF EXISTS spN_GetKitchenDetails;
GO

-- 3. SELECT procedures for Charities and KitchenDetails. each takes the
-- primary key as an optional parameter, so with no argument it returns
-- every row and with an ID it returns just that one.

-- charities with the branch name instead of the LocationID. LEFT JOIN
-- because a charity does not have to be assigned to a branch.
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

-- kitchens with the branch name and the lead chef's name. the chef name
-- goes through Chefs to Employees since Chefs only stores an EmployeeID.
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

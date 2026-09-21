USE Restaurant;
GO

DROP PROC IF EXISTS spN_CharitiesDelete
DROP PROC IF EXISTS spN_KitchenDetailsDelete

/*

Item 3 Procedures:

Procedure to delete items from the Charities table

Thankfully simple since there are no dependencies here

*/

CREATE PROC spN_CharitiesDelete

	@CharityID INT

AS

DELETE FROM Charities
WHERE CharityID = @CharityID;

/*

Procedure to delete items from the KitchenDetails table

First takes the Chefs and changes their HomeLocation to NONE to prevent errors

Then changing the demographic to be not active since their only ktichen is down

*/

CREATE PROC spN_KitchenDetailsDelete
	
	@KitchenID INT,
	@LocationID INT

AS

UPDATE Chefs
SET HomeLocationID = NULL
WHERE HomeLocationID = @KitchenID;

UPDATE Demographic
SET IsActive = 0
WHERE LocationID = @LocationID;

DELETE FROM KitchenDetails
WHERE LocationID = @LocationID AND KitchenID = @KitchenID;






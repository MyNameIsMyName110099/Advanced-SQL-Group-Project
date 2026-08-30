-- ============================================================================
-- Advanced SQL Semester Project
-- Week 2 Deliverables, Item 3 - Seed Data  (file 3 of 4)
--
-- Kelsey Wilcox, Mason Romdenne, Nathan Krouth, Nicholas Fearing
--
-- Recipes, Menu, Charities.
--
-- Run the four insert files in order after Week2_Restaurant_AllTables.sql.
-- They assume a freshly built database so the identity values start at their
-- seeds, which is what the foreign key values below are based on.
--
-- CreationDate is never inserted. It defaults to the moment the row is
-- created, which is what the requirement asks for.
-- ============================================================================

USE Restaurant;
GO

/*	100 rows. one row is one ingredient in one dish, so this is not a hundred
	recipes. it is the ingredient lines for the forty dishes, two or three
	each. QuantityUsed is how much of that ingredient the dish takes,
	which is requirement g.
*/
INSERT INTO Recipes
	(DishID, IngredientID, QuantityUsed)
VALUES
	(1, 101, 1),
	(2, 108, 2),
	(3, 115, 3),
	(4, 122, 4),
	(5, 129, 5),
	(6, 136, 6),
	(7, 143, 7),
	(8, 150, 8),
	(9, 157, 1),
	(10, 104, 2),
	(11, 111, 3),
	(12, 118, 4),
	(13, 125, 5),
	(14, 132, 6),
	(15, 139, 7),
	(16, 146, 8),
	(17, 153, 1),
	(18, 160, 2),
	(19, 107, 3),
	(20, 114, 4),
	(21, 121, 5),
	(22, 128, 6),
	(23, 135, 7),
	(24, 142, 8),
	(25, 149, 1),
	(26, 156, 2),
	(27, 103, 3),
	(28, 110, 4),
	(29, 117, 5),
	(30, 124, 6),
	(31, 131, 7),
	(32, 138, 8),
	(33, 145, 1),
	(34, 152, 2),
	(35, 159, 3),
	(36, 106, 4),
	(37, 113, 5),
	(38, 120, 6),
	(39, 127, 7),
	(40, 134, 8),
	(1, 141, 1),
	(2, 148, 2),
	(3, 155, 3),
	(4, 102, 4),
	(5, 109, 5),
	(6, 116, 6),
	(7, 123, 7),
	(8, 130, 8),
	(9, 137, 1),
	(10, 144, 2),
	(11, 151, 3),
	(12, 158, 4),
	(13, 105, 5),
	(14, 112, 6),
	(15, 119, 7),
	(16, 126, 8),
	(17, 133, 1),
	(18, 140, 2),
	(19, 147, 3),
	(20, 154, 4),
	(21, 101, 5),
	(22, 108, 6),
	(23, 115, 7),
	(24, 122, 8),
	(25, 129, 1),
	(26, 136, 2),
	(27, 143, 3),
	(28, 150, 4),
	(29, 157, 5),
	(30, 104, 6),
	(31, 111, 7),
	(32, 118, 8),
	(33, 125, 1),
	(34, 132, 2),
	(35, 139, 3),
	(36, 146, 4),
	(37, 153, 5),
	(38, 160, 6),
	(39, 107, 7),
	(40, 114, 8),
	(1, 121, 1),
	(2, 128, 2),
	(3, 135, 3),
	(4, 142, 4),
	(5, 149, 5),
	(6, 156, 6),
	(7, 103, 7),
	(8, 110, 8),
	(9, 117, 1),
	(10, 124, 2),
	(11, 131, 3),
	(12, 138, 4),
	(13, 145, 5),
	(14, 152, 6),
	(15, 159, 7),
	(16, 106, 8),
	(17, 113, 1),
	(18, 120, 2),
	(19, 127, 3),
	(20, 134, 4);
GO


/*	40 rows. one per dish on the menu. InUse is No on a few so a seasonal item can
	come off the menu without the row being deleted.
*/
INSERT INTO Menu
	(RecipeID, InUse)
VALUES
	(1, 'No'),
	(2, 'Yes'),
	(3, 'Yes'),
	(4, 'Yes'),
	(5, 'Yes'),
	(6, 'Yes'),
	(7, 'No'),
	(8, 'Yes'),
	(9, 'Yes'),
	(10, 'Yes'),
	(11, 'Yes'),
	(12, 'Yes'),
	(13, 'No'),
	(14, 'Yes'),
	(15, 'Yes'),
	(16, 'Yes'),
	(17, 'Yes'),
	(18, 'Yes'),
	(19, 'No'),
	(20, 'Yes'),
	(21, 'Yes'),
	(22, 'Yes'),
	(23, 'Yes'),
	(24, 'Yes'),
	(25, 'No'),
	(26, 'Yes'),
	(27, 'Yes'),
	(28, 'Yes'),
	(29, 'Yes'),
	(30, 'Yes'),
	(31, 'No'),
	(32, 'Yes'),
	(33, 'Yes'),
	(34, 'Yes'),
	(35, 'Yes'),
	(36, 'Yes'),
	(37, 'No'),
	(38, 'Yes'),
	(39, 'Yes'),
	(40, 'Yes');
GO


/*	15 rows. about three charities per branch. a restaurant builds a real
	relationship with a few local food banks and shelters, it does not
	donate to a hundred different organisations.
	every charity name is distinct so the UNIQUE constraint on
	CharityName holds.
*/
INSERT INTO Charities
	(CharityName, CharityType, ContactName, PhoneNumber, City, DonatingLocationID, TotalDonatedValue, IsActive)
VALUES
	('Simon Dublin Food Bank', 'Food Bank', 'Aoife Walsh', '080 000 0000', 'Dublin', 1, 120.00, 1),
	('Focus Dublin Food Bank', 'Food Bank', 'Saoirse Duffy', '082 026 0074', 'Dublin', 2, 207.25, 1),
	('Peter McVerry Dublin Food Bank', 'Food Bank', 'Orla Tierney', '084 052 0148', 'Dublin', 3, 294.50, 1),
	('Capuchin Dublin Food Bank', 'Food Bank', 'Grainne McLoughlin', '086 078 0222', 'Dublin', 4, 381.75, 1),
	('Vincent de Paul Dublin Food Bank', 'Food Bank', 'Aisling Egan', '088 104 0296', 'Dublin', 5, 469.00, 1),
	('Crosscare Dublin Food Bank', 'Food Bank', 'Caoimhe Lynch', '080 130 0370', 'Dublin', 1, 556.25, 1),
	('Novas Dublin Food Bank', 'Food Bank', 'Nuala Power', '082 156 0444', 'Dublin', 2, 643.50, 1),
	('Depaul Dublin Food Bank', 'Food Bank', 'Muireann McCarthy', '084 182 0518', 'Dublin', 3, 730.75, 1),
	('Sophia Dublin Food Bank', 'Food Bank', 'Oisin Casey', '086 208 0592', 'Dublin', 4, 818.00, 1),
	('Threshold Dublin Food Bank', 'Food Bank', 'Declan O''Connor', '088 234 0666', 'Dublin', 5, 905.25, 1),
	('Simon Cork Homeless Shelter', 'Homeless Shelter', 'Fergal Sheehan', '080 260 0740', 'Cork', 1, 992.50, 1),
	('Focus Cork Homeless Shelter', 'Homeless Shelter', 'Sean Smith', '082 286 0814', 'Cork', 2, 1079.75, 1),
	('Peter McVerry Cork Homeless Shelter', 'Homeless Shelter', 'Diarmuid Brennan', '084 312 0888', 'Cork', 3, 1167.00, 1),
	('Capuchin Cork Homeless Shelter', 'Homeless Shelter', 'Tadhg Murphy', '086 338 0962', 'Cork', 4, 1254.25, 1),
	('Vincent de Paul Cork Homeless Shelter', 'Homeless Shelter', 'Barry Connolly', '088 364 1036', 'Cork', 5, 1341.50, 1);
GO

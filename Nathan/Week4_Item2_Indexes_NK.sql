/*

Key already takes up clustered index so this one is unclustered

Week 4 Item C:

I decided to use the DishID for this index since it is mandatory
when looking into this table to find all ingredients belonging to 
a specific dish. I am including the IngredientID and Quantity
for so this may work as a recipe book as well

*/

CREATE NONCLUSTERED INDEX IX_Recipes_DishID
	ON Recipes(DishID)
	INCLUDE(IngredientID, QuantityUsed) 
GO
/*	Assign permissions to stored procedures created in Week 4	*/

--Run week7_Item1 script first, then this script second


USE Restaurant;
GO

--A. Assign EXECUTE permission to spN_ChefDetails, to schema dbo
/*	This requirement is not clearly worded. I have implemented my best interpretation.	*/
GRANT EXECUTE
ON SCHEMA::dbo
TO RestaurantUser;
GO

GRANT EXECUTE
ON spN_ChefDetails
TO RestaurantUser;
GO


--B. Assign 'View Definition' permissions to RestaurantUser to spN_RecipeDetails
GRANT VIEW Definition
ON spN_RecipeDetails
TO RestaurantUser;
GO

--C. Assign ALTER permissions to RestaurantAddDeleteDB to spN_DishDetails
CREATE USER RestaurantAddDeleteDB_User FOR LOGIN RestaurantAddDeleteDB_Login;
GO	--first create user, as trying to apply GRANT ALTER to the server role throws an error

GRANT ALTER
ON Restaurant.dbo.spN_DishDetails
TO RestaurantAddDeleteDB_User;
GO

--D. Assign 'Take Ownership' permissions to RestaurantPower to spN_KitchenDetails
GRANT TAKE OWNERSHIP
ON spN_KitchenDetails
TO RestaurantPower;
GO


--E. Assign CONTROL permissions to RestaurantDoAnything to spN_CustomerDetails
GRANT CONTROL
ON spN_CustomerDetails
TO RestaurantDoAnything;
GO
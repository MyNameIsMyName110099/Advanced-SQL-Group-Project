/* 
    Creating the table for the dishes served at the restaurant.
    I'm leaving this fairly open ended incase we need to add more
    information at a later point
*/

CREATE TABLE Dishes(

    DishNum int IDENTITY (1,1) PRIMARY KEY,
    DishName nvarchar(50) NOT NULL,
    Notes nvarchar(100)

)

/* 
    Creating the table for ingredients used in the recipes.
    I'm setting up a cost here just in case we need it later
    down the line.
*/

CREATE TABLE Ingredients(

    IngredientNum int IDENTITY (1,1) PRIMARY KEY,
    IngredientName nvarchar(30) NOT NULL,
    IngredientCost money NOT NULL,
    QuantityStocked int NOT NULL

)

/* 
    Creating the table for the recipes used at the restaurant
*/

CREATE TABLE Recipes(

    RecipeNum int IDENTITY(1,1) PRIMARY KEY,
    DishNum int references Dishes(DishNum) NOT NULL,
    IngredientNum int references Ingredients(IngredientNum) NOT NULL,
    QuantityUsed int NOT NULL,
    DateAdded DATETIME DEFAULT GETDATE()

)

/* 
    Creating the table for menus.
    I'm not sure how many menus we may need or if we will
    be doing unique ones at some point so I'm throwing in an
    InUse column.
*/

CREATE TABLE Menu(

    MenuNum INT IDENTITY (1,1) PRIMARY KEY,
    InUse nvarchar(3) NOT NULL,
    DateAdded DATETIME DEFAULT GETDATE()

)

/* 
    Creating table linking the recipes to the menus.
*/

CREATE TABLE MenuRecipes(

    RecipeNum int references Recipes(RecipeNum) NOT NULL,
    MenuNum int references Menu(MenuNum) NOT NULL,
    DateAdded DATETIME DEFAULT GETDATE(),
    Notes nvarchar(100),
    PRIMARY KEY(RecipeNum, MenuNum)

)
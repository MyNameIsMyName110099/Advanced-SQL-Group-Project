USE Restaurants;
GO

/* 
    Creating the table for the dishes served at the restaurant.
    I'm leaving this fairly open ended incase we need to add more
    information at a later point
*/

CREATE TABLE Dishes(

    DishID INT IDENTITY (1,1) NOT NULL,
    DishName NVARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Notes NVARCHAR(100),
    DateAdded DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    -- constraints to enforce data integrity
    CONSTRAINT PK_Dishes PRIMARY KEY (DishID)

);
GO

/* 
    Creating the table for ingredients used in the recipes.
    I'm setting up a cost here just in case we need it later
    down the line.
*/

CREATE TABLE Ingredients(

    IngredientID INT IDENTITY (101,1),
    IngredientName NVARCHAR(30) NOT NULL,
    IngredientCost DECIMAL(10,2) NOT NULL,
    QuantityStocked INT NOT NULL,
    DateAdded DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    -- constraints to enforce data integrity
    CONSTRAINT PK_Ingredients PRIMARY KEY (IngredientID)

);
GO

/* 
    Creating the table for the recipes used at the restaurant
*/

CREATE TABLE Recipes(

    RecipeID INT IDENTITY(1,1),
    DishID INT REFERENCES Dishes(DishID) NOT NULL,
    IngredientID INT REFERENCES Ingredients(IngredientID) NOT NULL,
    QuantityUsed INT NOT NULL,
    DateAdded DATETIME2 NOT NULL DEFAULT SYSDATETIME()

    -- constraints to enforce data integrity
    CONSTRAINT PK_Recipes PRIMARY KEY (RecipeID)
    CONSTRAINT FK_Recipes_DishID
        FOREIGN KEY (DishID) REFERENCES Dishes(DishID)
    CONSTRAINT CK_Recipes_QuantityUsed_Positive
        CHECK (QuantityUsed > 0)

);
GO

/* 
    Creating the table for menus.
    I'm not sure how many menus we may need or if we will
    be doing unique ones at some point so I'm throwing in an
    InUse column.
*/

CREATE TABLE Menu(

    MenuID INT IDENTITY (10,1),
    RecipeID INT REFERENCES Recipes(RecipeID) NOT NULL,
    InUse NVARCHAR(3) NOT NULL,
    DateAdded DATETIME2 NOT NULL DEFAULT SYSDATETIME()

    -- constraints to enforce data integrity
    CONSTRAINT PK_Menu PRIMARY KEY (MenuID)
    CONSTRAINT FK_Menu_RecipeID
        FOREIGN KEY (RecipeID) REFERENCES Recipes(RecipeID)
    CONSTRAINT CK_Menu_InUse_Status
        CHECK (LOWER(InUse) IN ('yes','no'))

);
GO
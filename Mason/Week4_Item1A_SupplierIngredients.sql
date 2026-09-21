USE Restaurant;
GO

DROP TABLE IF EXISTS SupplierIngredients;
GO

-- 1a. new table for what each supplier sells and what they charge for it.
-- nothing in the Week 2 schema linked a supplier to its items, so this is
-- needed before spN_ChefDetails can be written.
CREATE TABLE SupplierIngredients (
	SupplierIngredientID INT IDENTITY(1,1) NOT NULL,
	SupplierID INT NOT NULL,
	IngredientID INT NOT NULL,
	SupplierPrice DECIMAL(10,2) NOT NULL,
	IsActive BIT NOT NULL DEFAULT 1,
	CreationDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

	CONSTRAINT PK_SupplierIngredients PRIMARY KEY (SupplierIngredientID),
	CONSTRAINT UQ_SupplierIngredients_SupplierIngredient
		UNIQUE (SupplierID, IngredientID),
	CONSTRAINT FK_SupplierIngredients_Suppliers FOREIGN KEY (SupplierID)
		REFERENCES Suppliers (SupplierID),
	CONSTRAINT FK_SupplierIngredients_Ingredients FOREIGN KEY (IngredientID)
		REFERENCES Ingredients (IngredientID),
	CONSTRAINT CK_SupplierIngredients_Price_Positive CHECK (SupplierPrice >= 0)
);
GO

-- fill it. pairs every supplier with every ingredient and keeps one pair in
-- fifteen, which works out to 4 items per supplier and 400 rows. the price
-- is the ingredient cost plus a markup based on the supplier id, so each
-- vendor charges something different and it comes out the same every run.
INSERT INTO SupplierIngredients (SupplierID, IngredientID, SupplierPrice)
SELECT s.SupplierID, i.IngredientID,
	CAST(i.IngredientCost * (1 + (s.SupplierID % 5) / 20.0) AS DECIMAL(10,2))
FROM Suppliers s
	CROSS JOIN Ingredients i
WHERE (s.SupplierID + i.IngredientID) % 15 = 0;
GO

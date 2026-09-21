USE Restaurant
GO

/* Item 2b - index for Dishes table.
I chose Dishname and Price to make a covering index for fnMenuPrices() */

CREATE INDEX IX_Dishname_Price
ON Dishes (Dishname, Price);

/* Item 2e - index for Reservations table.
	I chose CustomerID because it is both a FK
	and it is used in a join by fnReservationFavoriteTable() */

CREATE INDEX IX_CustomerID
ON Reservations (CustomerID);
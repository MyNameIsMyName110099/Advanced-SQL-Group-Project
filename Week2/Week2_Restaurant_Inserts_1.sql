USE Restaurant;
GO

/*	15 rows. these are the job titles the restaurant actually has. a restaurant does
	not have a hundred distinct roles, so a hundred rows here would be
	invented data that means nothing.
*/
INSERT INTO Positions
	(PositionName, Notes)
VALUES
	('Owner', 'Restaurant staff role'),
	('General Manager', 'Restaurant staff role'),
	('Assistant Manager', 'Restaurant staff role'),
	('Head Chef', 'Restaurant staff role'),
	('Sous Chef', 'Restaurant staff role'),
	('Pastry Chef', 'Restaurant staff role'),
	('Line Cook', 'Restaurant staff role'),
	('Prep Cook', 'Restaurant staff role'),
	('Server', 'Restaurant staff role'),
	('Head Server', 'Restaurant staff role'),
	('Bartender', 'Restaurant staff role'),
	('Host', 'Restaurant staff role'),
	('Dish Washer', 'Restaurant staff role'),
	('Cleaner', 'Restaurant staff role'),
	('Delivery Driver', 'Restaurant staff role');
GO


/*	5 rows. one row per branch. the requirement is a restaurant thinking about
	opening more locations, not a chain of a hundred.
*/
INSERT INTO Demographic
	(LocationName, AddressLine1, City, PhoneNumber, SeatingCapacity, OpenDate, AreaPopulation)
VALUES
	('Temple Bar', '12 Fownes Street', 'Dublin', '080 000 0000', 120, '2019-03-14', 118000),
	('Shop Street', '41 Shop Street', 'Galway', '081 013 0037', 90, '2020-06-02', 85000),
	('Oliver Plunkett', '23 Oliver Plunkett St', 'Cork', '082 026 0074', 140, '2021-01-18', 210000),
	('Bedford Row', '8 Bedford Row', 'Limerick', '083 039 0111', 75, '2022-09-05', 94000),
	('John Roberts Square', '3 John Roberts Square', 'Waterford', '084 052 0148', 60, '2024-02-11', 54000);
GO


/*	100 rows. a group this size buys from a lot of vendors, so a hundred is fair.
	LengthOfHistory is the date we started buying from them, so every row
	gets a different date.
*/
INSERT INTO Suppliers
	(SupplierName, SupplierPhoneNum, SupplierAddress, LengthOfHistory, OwedPayments)
VALUES
	('Dublin Produce 1', '0860000000', '3 Murphy Road, Dublin', '2022-01-01', 231.87),
	('Cork Meats 2', '0860000137', '4 Kelly Road, Limerick', '2022-01-10', 954.81),
	('Galway Seafood 3', '0860000274', '5 OSullivan Road, Sligo', '2022-01-19', 438.67),
	('Limerick Dairy 4', '0860000411', '6 Walsh Road, Dundalk', '2022-01-28', 2864.74),
	('Waterford Bakery 5', '0860000548', '7 Smith Road, Ennis', '2022-02-06', 3815.55),
	('Kilkenny Beverages 6', '0860000685', '8 OBrien Road, Naas', '2022-02-15', 2270.72),
	('Sligo Poultry 7', '0860000822', '9 Byrne Road, Killarney', '2022-02-24', 2484.41),
	('Wexford Butchers 8', '0860000959', '10 Ryan Road, Cork', '2022-03-05', 3293.26),
	('Drogheda Farm 9', '0860001096', '11 OConnor Road, Waterford', '2022-03-14', 1194.44),
	('Dundalk Fisheries 10', '0860001233', '12 ONeill Road, Wexford', '2022-03-23', 3746.11),
	('Bray Produce 11', '0860001370', '13 Reilly Road, Bray', '2022-04-01', 3314.28),
	('Navan Meats 12', '0860001507', '14 Doyle Road, Tralee', '2022-04-10', 3768.51),
	('Ennis Seafood 13', '0860001644', '15 McCarthy Road, Athlone', '2022-04-19', 874.66),
	('Tralee Dairy 14', '0860001781', '16 Gallagher Road, Clonmel', '2022-04-28', 3984.34),
	('Carlow Bakery 15', '0860001918', '17 Doherty Road, Galway', '2022-05-07', 2330.67),
	('Naas Beverages 16', '0860002055', '18 Kennedy Road, Kilkenny', '2022-05-16', 2192.92),
	('Athlone Poultry 17', '0860002192', '19 Lynch Road, Drogheda', '2022-05-25', 3286.53),
	('Letterkenny Butchers 18', '0860002329', '20 Murray Road, Navan', '2022-06-03', 2181.16),
	('Killarney Farm 19', '0860002466', '21 Quinn Road, Carlow', '2022-06-12', 4029.45),
	('Clonmel Fisheries 20', '0860002603', '22 Moore Road, Letterkenny', '2022-06-21', 2490.57),
	('Dublin Produce 21', '0860002740', '23 McLoughlin Road, Dublin', '2022-06-30', 3557.71),
	('Cork Meats 22', '0860002877', '24 Connolly Road, Limerick', '2022-07-09', 1301.08),
	('Galway Seafood 23', '0860003014', '25 Daly Road, Sligo', '2022-07-18', 2806.70),
	('Limerick Dairy 24', '0860003151', '26 ODonnell Road, Dundalk', '2022-07-27', 691.09),
	('Waterford Bakery 25', '0860003288', '27 Duffy Road, Ennis', '2022-08-05', 2802.71),
	('Kilkenny Beverages 26', '0860003425', '28 Brennan Road, Naas', '2022-08-14', 3913.25),
	('Sligo Poultry 27', '0860003562', '29 Barry Road, Killarney', '2022-08-23', 3956.77),
	('Wexford Butchers 28', '0860003699', '30 Nolan Road, Cork', '2022-09-01', 3929.20),
	('Drogheda Farm 29', '0860003836', '31 Whelan Road, Waterford', '2022-09-10', 1034.87),
	('Dundalk Fisheries 30', '0860003973', '32 Sheehan Road, Wexford', '2022-09-19', 1357.49),
	('Bray Produce 31', '0860004110', '33 Keane Road, Bray', '2022-09-28', 3553.46),
	('Navan Meats 32', '0860004247', '34 Hayes Road, Tralee', '2022-10-07', 1276.84),
	('Ennis Seafood 33', '0860004384', '35 Fitzgerald Road, Athlone', '2022-10-16', 1449.32),
	('Tralee Dairy 34', '0860004521', '36 Casey Road, Clonmel', '2022-10-25', 3128.32),
	('Carlow Bakery 35', '0860004658', '37 Foley Road, Galway', '2022-11-03', 217.63),
	('Naas Beverages 36', '0860004795', '38 Healy Road, Kilkenny', '2022-11-12', 760.03),
	('Athlone Poultry 37', '0860004932', '39 Kavanagh Road, Drogheda', '2022-11-21', 989.82),
	('Letterkenny Butchers 38', '0860005069', '40 Power Road, Navan', '2022-11-30', 1585.89),
	('Killarney Farm 39', '0860005206', '41 Maguire Road, Carlow', '2022-12-09', 3515.34),
	('Clonmel Fisheries 40', '0860005343', '42 Dunne Road, Letterkenny', '2022-12-18', 3683.03),
	('Dublin Produce 41', '0860005480', '43 Flynn Road, Dublin', '2022-12-27', 1061.19),
	('Cork Meats 42', '0860005617', '44 Egan Road, Limerick', '2023-01-05', 552.15),
	('Galway Seafood 43', '0860005754', '45 Cullen Road, Sligo', '2023-01-14', 1681.43),
	('Limerick Dairy 44', '0860005891', '46 Callaghan Road, Dundalk', '2023-01-23', 2425.28),
	('Waterford Bakery 45', '0860006028', '47 Ward Road, Ennis', '2023-02-01', 303.49),
	('Kilkenny Beverages 46', '0860006165', '48 Tierney Road, Naas', '2023-02-10', 1250.33),
	('Sligo Poultry 47', '0860006302', '49 Murphy Road, Killarney', '2023-02-19', 2144.08),
	('Wexford Butchers 48', '0860006439', '50 Kelly Road, Cork', '2023-02-28', 1959.66),
	('Drogheda Farm 49', '0860006576', '51 OSullivan Road, Waterford', '2023-03-09', 2299.05),
	('Dundalk Fisheries 50', '0860006713', '52 Walsh Road, Wexford', '2023-03-18', 545.79),
	('Bray Produce 51', '0860006850', '53 Smith Road, Bray', '2023-03-27', 3087.20),
	('Navan Meats 52', '0860006987', '54 OBrien Road, Tralee', '2023-04-05', 1079.18),
	('Ennis Seafood 53', '0860007124', '55 Byrne Road, Athlone', '2023-04-14', 1241.62),
	('Tralee Dairy 54', '0860007261', '56 Ryan Road, Clonmel', '2023-04-23', 705.07),
	('Carlow Bakery 55', '0860007398', '57 OConnor Road, Galway', '2023-05-02', 2418.14),
	('Naas Beverages 56', '0860007535', '58 ONeill Road, Kilkenny', '2023-05-11', 458.49),
	('Athlone Poultry 57', '0860007672', '59 Reilly Road, Drogheda', '2023-05-20', 3672.72),
	('Letterkenny Butchers 58', '0860007809', '60 Doyle Road, Navan', '2023-05-29', 2434.66),
	('Killarney Farm 59', '0860007946', '61 McCarthy Road, Carlow', '2023-06-07', 3482.15),
	('Clonmel Fisheries 60', '0860008083', '62 Gallagher Road, Letterkenny', '2023-06-16', 155.90),
	('Dublin Produce 61', '0860008220', '63 Doherty Road, Dublin', '2023-06-25', 135.69),
	('Cork Meats 62', '0860008357', '64 Kennedy Road, Limerick', '2023-07-04', 3610.38),
	('Galway Seafood 63', '0860008494', '65 Lynch Road, Sligo', '2023-07-13', 601.37),
	('Limerick Dairy 64', '0860008631', '66 Murray Road, Dundalk', '2023-07-22', 2888.42),
	('Waterford Bakery 65', '0860008768', '67 Quinn Road, Ennis', '2023-07-31', 3569.11),
	('Kilkenny Beverages 66', '0860008905', '68 Moore Road, Naas', '2023-08-09', 3260.88),
	('Sligo Poultry 67', '0860009042', '69 McLoughlin Road, Killarney', '2023-08-18', 51.52),
	('Wexford Butchers 68', '0860009179', '70 Connolly Road, Cork', '2023-08-27', 552.75),
	('Drogheda Farm 69', '0860009316', '71 Daly Road, Waterford', '2023-09-05', 2396.29),
	('Dundalk Fisheries 70', '0860009453', '72 ODonnell Road, Wexford', '2023-09-14', 3610.26),
	('Bray Produce 71', '0860009590', '73 Duffy Road, Bray', '2023-09-23', 2609.57),
	('Navan Meats 72', '0860009727', '74 Brennan Road, Tralee', '2023-10-02', 3144.85),
	('Ennis Seafood 73', '0860009864', '75 Barry Road, Athlone', '2023-10-11', 3459.69),
	('Tralee Dairy 74', '0860010001', '76 Nolan Road, Clonmel', '2023-10-20', 616.40),
	('Carlow Bakery 75', '0860010138', '77 Whelan Road, Galway', '2023-10-29', 3156.24),
	('Naas Beverages 76', '0860010275', '78 Sheehan Road, Kilkenny', '2023-11-07', 2904.70),
	('Athlone Poultry 77', '0860010412', '79 Keane Road, Drogheda', '2023-11-16', 2387.77),
	('Letterkenny Butchers 78', '0860010549', '80 Hayes Road, Navan', '2023-11-25', 1580.23),
	('Killarney Farm 79', '0860010686', '81 Fitzgerald Road, Carlow', '2023-12-04', 342.91),
	('Clonmel Fisheries 80', '0860010823', '82 Casey Road, Letterkenny', '2023-12-13', 3984.48),
	('Dublin Produce 81', '0860010960', '83 Foley Road, Dublin', '2023-12-22', 1430.95),
	('Cork Meats 82', '0860011097', '84 Healy Road, Limerick', '2023-12-31', 3879.63),
	('Galway Seafood 83', '0860011234', '85 Kavanagh Road, Sligo', '2024-01-09', 907.95),
	('Limerick Dairy 84', '0860011371', '86 Power Road, Dundalk', '2024-01-18', 2376.34),
	('Waterford Bakery 85', '0860011508', '87 Maguire Road, Ennis', '2024-01-27', 3686.10),
	('Kilkenny Beverages 86', '0860011645', '88 Dunne Road, Naas', '2024-02-05', 88.25),
	('Sligo Poultry 87', '0860011782', '89 Flynn Road, Killarney', '2024-02-14', 1040.87),
	('Wexford Butchers 88', '0860011919', '90 Egan Road, Cork', '2024-02-23', 1135.06),
	('Drogheda Farm 89', '0860012056', '91 Cullen Road, Waterford', '2024-03-03', 1633.75),
	('Dundalk Fisheries 90', '0860012193', '92 Callaghan Road, Wexford', '2024-03-12', 852.30),
	('Bray Produce 91', '0860012330', '93 Ward Road, Bray', '2024-03-21', 3669.80),
	('Navan Meats 92', '0860012467', '94 Tierney Road, Tralee', '2024-03-30', 3320.33),
	('Ennis Seafood 93', '0860012604', '95 Murphy Road, Athlone', '2024-04-08', 2588.37),
	('Tralee Dairy 94', '0860012741', '96 Kelly Road, Clonmel', '2024-04-17', 3938.42),
	('Carlow Bakery 95', '0860012878', '97 OSullivan Road, Galway', '2024-04-26', 338.21),
	('Naas Beverages 96', '0860013015', '98 Walsh Road, Kilkenny', '2024-05-05', 67.37),
	('Athlone Poultry 97', '0860013152', '99 Smith Road, Drogheda', '2024-05-14', 1719.28),
	('Letterkenny Butchers 98', '0860013289', '100 OBrien Road, Navan', '2024-05-23', 2635.13),
	('Killarney Farm 99', '0860013426', '101 Byrne Road, Carlow', '2024-06-01', 3760.36),
	('Clonmel Fisheries 100', '0860013563', '102 Ryan Road, Letterkenny', '2024-06-10', 3068.27);
GO


/*	40 rows. a pub menu is around forty items, not a hundred.
	Price is the price listed on the menu, which is requirement j.
*/
INSERT INTO Dishes
	(DishName, Price, Notes)
VALUES
	('Irish Stew', 8.50, 'Served all day'),
	('Beef and Guinness Pie', 9.65, 'Served all day'),
	('Boxty', 10.80, 'Served all day'),
	('Colcannon', 11.95, 'Served all day'),
	('Dublin Coddle', 13.10, 'Served all day'),
	('Bacon and Cabbage', 14.25, 'Served all day'),
	('Shepherds Pie', 15.40, 'Served all day'),
	('Fish and Chips', 16.55, 'Served all day'),
	('Seafood Chowder', 17.70, 'Served all day'),
	('Black Pudding', 18.85, 'Served all day'),
	('White Pudding', 20.00, 'Served all day'),
	('Champ', 21.15, 'Served all day'),
	('Barmbrack', 22.30, 'Served all day'),
	('Soda Bread Basket', 23.45, 'Served all day'),
	('Smoked Salmon Plate', 24.60, 'Served all day'),
	('Galway Oysters', 25.75, 'Served all day'),
	('Lamb Shank', 26.90, 'Served all day'),
	('Roast Ham Dinner', 28.05, 'Served all day'),
	('Chicken and Leek Pie', 29.20, 'Served all day'),
	('Cottage Pie', 30.35, 'Served all day'),
	('Traditional Irish Stew', 31.50, 'Served all day'),
	('Traditional Beef and Guinness Pie', 32.65, 'Served all day'),
	('Traditional Boxty', 33.80, 'Served all day'),
	('Traditional Colcannon', 34.95, 'Served all day'),
	('Traditional Dublin Coddle', 8.50, 'Served all day'),
	('Traditional Bacon and Cabbage', 9.65, 'Served all day'),
	('Traditional Shepherds Pie', 10.80, 'Served all day'),
	('Traditional Fish and Chips', 11.95, 'Served all day'),
	('Traditional Seafood Chowder', 13.10, 'Served all day'),
	('Traditional Black Pudding', 14.25, 'Served all day'),
	('Traditional White Pudding', 15.40, 'Served all day'),
	('Traditional Champ', 16.55, 'Served all day'),
	('Traditional Barmbrack', 17.70, 'Served all day'),
	('Traditional Soda Bread Basket', 18.85, 'Served all day'),
	('Traditional Smoked Salmon Plate', 20.00, 'Served all day'),
	('Traditional Galway Oysters', 21.15, 'Served all day'),
	('Traditional Lamb Shank', 22.30, 'Served all day'),
	('Traditional Roast Ham Dinner', 23.45, 'Served all day'),
	('Traditional Chicken and Leek Pie', 24.60, 'Served all day'),
	('Traditional Cottage Pie', 25.75, 'Served all day');
GO


/*	60 rows. forty dishes do not need a hundred separate ingredients.
	IngredientCost is what we pay for it, not what a dish sells for.
*/
INSERT INTO Ingredients
	(IngredientName, IngredientCost, QuantityStocked)
VALUES
	('Potatoes', 0.60, 20),
	('Carrots', 1.05, 27),
	('Onions', 1.50, 34),
	('Cabbage', 1.95, 41),
	('Leeks', 2.40, 48),
	('Parsnips', 2.85, 55),
	('Turnips', 3.30, 62),
	('Beef Brisket', 3.75, 69),
	('Lamb Shoulder', 4.20, 76),
	('Bacon Lardons', 4.65, 83),
	('Pork Sausage', 5.10, 90),
	('Chicken Thigh', 5.55, 97),
	('Smoked Salmon', 6.00, 104),
	('Cod Fillet', 6.45, 111),
	('Haddock', 6.90, 118),
	('Mussels', 7.35, 125),
	('Oysters', 7.80, 132),
	('Butter', 8.25, 139),
	('Cream', 8.70, 146),
	('Buttermilk', 9.15, 153),
	('Cheddar', 9.60, 160),
	('Plain Flour', 10.05, 167),
	('Wholemeal Flour', 10.50, 174),
	('Oats', 10.95, 181),
	('Barley', 11.40, 188),
	('Guinness Stout', 11.85, 195),
	('Cider', 12.30, 202),
	('Thyme', 12.75, 209),
	('Parsley', 13.20, 216),
	('Chives', 13.65, 223),
	('Bay Leaf', 0.60, 230),
	('Black Pepper', 1.05, 237),
	('Sea Salt', 1.50, 244),
	('Rapeseed Oil', 1.95, 251),
	('Beef Stock', 2.40, 258),
	('Chicken Stock', 2.85, 265),
	('Fish Stock', 3.30, 272),
	('Pearl Barley', 3.75, 279),
	('Celery', 4.20, 286),
	('Garlic', 4.65, 293),
	('Scallions', 5.10, 300),
	('Rhubarb', 5.55, 307),
	('Apples', 6.00, 314),
	('Blackberries', 6.45, 321),
	('Honey', 6.90, 328),
	('Brown Sugar', 7.35, 335),
	('Eggs', 7.80, 342),
	('Whole Milk', 8.25, 349),
	('Baking Soda', 8.70, 356),
	('Dried Yeast', 9.15, 363),
	('Potatoes (Organic)', 9.60, 370),
	('Carrots (Organic)', 10.05, 377),
	('Onions (Organic)', 10.50, 384),
	('Cabbage (Organic)', 10.95, 391),
	('Leeks (Organic)', 11.40, 398),
	('Parsnips (Organic)', 11.85, 405),
	('Turnips (Organic)', 12.30, 412),
	('Beef Brisket (Organic)', 12.75, 419),
	('Lamb Shoulder (Organic)', 13.20, 26),
	('Bacon Lardons (Organic)', 13.65, 33);
	GO
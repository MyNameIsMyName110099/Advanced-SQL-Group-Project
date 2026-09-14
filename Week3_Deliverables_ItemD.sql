
USE Restaurant
GO

/* a select statement that shows the distribution of how orders
	are placed (in-person, online, phone) using a sum of
	each with an overall sum for all options
*/

CREATE FUNCTION fnOrderMethodSum()
RETURNS TABLE
AS
RETURN
(
	SELECT ISNULL(OrderChannel, 'All Methods') AS 'Order Method',
		COUNT(OrderChannel) AS 'Order Method Count'
	FROM Transactions
	GROUP BY ROLLUP(OrderChannel)
);

/* SELECT *
FROM fnOrderMethodSum();
*/
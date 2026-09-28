USE AdventureWorks2019;
GO


-- ============================================================================
-- Drop the table if it already exists so this file can be re-run.
-- ============================================================================
DROP TABLE IF EXISTS dbo.SSIS_File_Load;
GO


-- ============================================================================
-- ITEM 1 - TABLE CREATION FOR THE SSIS FILE LOAD
-- Mason Romdenne
--
-- SSIS File Load.txt holds four values per row and ten rows, for example:
--
--     1.00070049USD9/3/05 0:001.001201442
--
-- The four values are a rate, a three letter currency code, a date with a
-- time on it, and a second rate. That is the same shape as the stock
-- AdventureWorks table Sales.CurrencyRate, so the columns below are named
-- after its columns to keep the load table recognizable.
--
-- The table is exactly the four columns that are in the file. No identity or
-- surrogate key was added, because the assignment asks for the fields the
-- data in the file needs, and an identity column is not in the file. It would
-- also be one more column Nathan has to leave unmapped in the destination.
--
-- (CurrencyRateDate, FromCurrencyCode) is the natural key and is unique
-- across all ten rows, but no key constraint is declared. This is a load
-- target, so a duplicate row should land and be caught in review rather than
-- fail the package mid-load.
-- ============================================================================
CREATE TABLE dbo.SSIS_File_Load (
	AverageRate			DECIMAL(18, 9)	NOT NULL,
	FromCurrencyCode	NCHAR(3)		NOT NULL,
	CurrencyRateDate	DATETIME		NOT NULL,
	EndOfDayRate		DECIMAL(18, 9)	NOT NULL
);
GO


-- ============================================================================
-- Why each datatype
--
-- AverageRate      DECIMAL(18, 9)
-- EndOfDayRate     DECIMAL(18, 9)
--     Both are exchange rates just either side of 1.0. In the file AverageRate
--     is always ten characters with eight decimal places (1.00070049) and
--     EndOfDayRate runs from one to eleven characters with up to nine decimal
--     places (1.001502253, and also a bare 1). Scale 9 is taken from that
--     longest value, and both columns get the same type so the two rates are
--     directly comparable and neither one rounds.
--
--     MONEY was rejected. It only keeps four decimal places, so 1.001502253
--     would silently store as 1.0015 and the file would not round trip. The
--     stock Sales.CurrencyRate does use MONEY, but its data only carries four
--     decimals and ours carries nine. FLOAT was rejected as well: it is
--     approximate, and a rate that money is calculated from should be exact.
--
--     Precision 18 leaves nine digits in front of the decimal point, which is
--     far more than a rate near 1.0 needs, and keeps the column inside the
--     nine byte storage band for DECIMAL.
--
-- FromCurrencyCode NCHAR(3)
--     Every row is the literal USD. ISO 4217 currency codes are always
--     exactly three characters, so the column is fixed length rather than
--     NVARCHAR, and NCHAR(3) is what Sales.CurrencyRate.FromCurrencyCode uses.
--
-- CurrencyRateDate DATETIME
--     The values look like 9/3/05 0:00, so there is a time component in the
--     file even though it is midnight on all ten rows. DATETIME keeps it.
--     DATE would have quietly dropped it, and DATETIME matches
--     Sales.CurrencyRateDate. The two digit year relies on SQL Server's
--     default two digit year cutoff of 2049, so 05 reads as 2005.
--
--     The month comes first in these dates, so the load has to run under a
--     US English language setting. Do not put SET DATEFORMAT dmy anywhere in
--     the package or 9/3/05 becomes 9 March.
--
-- All four columns are NOT NULL because all four are populated on every row
-- of the file.
-- ============================================================================


-- ============================================================================
-- TESTING
--
-- The ten rows below are the real values from SSIS File Load.txt, typed in by
-- hand to prove the table holds them without rounding or overflow before the
-- package is built. The rows are deleted again at the bottom so the table is
-- empty for Nathan's package to load into.
-- ============================================================================
INSERT INTO dbo.SSIS_File_Load
	(AverageRate, FromCurrencyCode, CurrencyRateDate, EndOfDayRate)
VALUES
	(1.00070049, 'USD', '9/3/05 0:00',  1.001201442),
	(1.00020004, 'USD', '9/4/05 0:00',  1),
	(1.00020004, 'USD', '9/5/05 0:00',  1.001201442),
	(1.00020004, 'USD', '9/6/05 0:00',  1),
	(1.00020004, 'USD', '9/7/05 0:00',  1.00070049),
	(1.00070049, 'USD', '9/8/05 0:00',  0.99980004),
	(1.00070049, 'USD', '9/9/05 0:00',  1.001502253),
	(1.00070049, 'USD', '9/10/05 0:00', 0.99990001),
	(1.00020004, 'USD', '9/11/05 0:00', 1.001101211),
	(1.00020004, 'USD', '9/12/05 0:00', 0.99970009);
GO

-- All ten rows back out, to confirm the dates parsed as September 2005 and
-- that the nine decimal place rates kept every digit.
SELECT
	AverageRate,
	FromCurrencyCode,
	CurrencyRateDate,
	EndOfDayRate
FROM dbo.SSIS_File_Load
ORDER BY CurrencyRateDate;
GO

-- Row count, and a check that nothing was rounded on the way in. The longest
-- value in the file is 1.001502253, so if the CAST below comes back equal for
-- all ten rows then no precision was lost.
SELECT
	RowsLoaded = COUNT(*),
	RowsMoneyWouldHaveRounded =
		SUM(CASE WHEN EndOfDayRate = CAST(EndOfDayRate AS MONEY) THEN 0 ELSE 1 END)
FROM dbo.SSIS_File_Load;
GO

-- Leave the table empty for the package.
DELETE FROM dbo.SSIS_File_Load;
GO

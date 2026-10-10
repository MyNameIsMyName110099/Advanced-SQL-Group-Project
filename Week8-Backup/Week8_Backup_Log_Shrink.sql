--Week 8 Deliverables, Items 1, 2 and 3 for the Restaurant database
--Run each item once, in order. Each item is followed by the testing code that shows
--it worked.

USE master;
GO


--Item 1: Back up the Restaurant database into the SQL Backup folder
--xp_create_subdir makes the folder if it is not there yet and does nothing if it is.
--When SQL Server creates the folder itself, the SQL Server service is sure to have
--permission to write the backup file into it. WITH INIT overwrites any older backup in
--the same file, and CHECKSUM has SQL Server check every page as it is backed up.
EXEC master.dbo.xp_create_subdir N'C:\SQL Backup';

BACKUP DATABASE Restaurant
TO DISK = N'C:\SQL Backup\Restaurant.bak'
WITH INIT, CHECKSUM, NAME = N'Restaurant Full Backup';
GO

--Testing Item 1
--VERIFYONLY reads the backup file, checks it is complete and readable, and with
--CHECKSUM re-checks every page against the checksums written during the backup.
--HEADERONLY shows what is inside it: the database name, the backup type (1 = full)
--and when it was taken.
RESTORE VERIFYONLY
FROM DISK = N'C:\SQL Backup\Restaurant.bak'
WITH CHECKSUM;

RESTORE HEADERONLY
FROM DISK = N'C:\SQL Backup\Restaurant.bak';
GO


--Item 2: Create a transaction log file called RestaurantTransactionLog.ldf in the
--SQL Server DATA folder
--ADD LOG FILE gives Restaurant a second log file next to the one it was created with.
--NAME is the name SQL Server uses for the file, FILENAME is where it goes on disk.
ALTER DATABASE Restaurant
ADD LOG FILE
(
    NAME = RestaurantTransactionLog,
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\RestaurantTransactionLog.ldf'
);
GO

--Testing Item 2
--Lists every file in the Restaurant database. The new RestaurantTransactionLog file
--should show as a LOG file in the DATA folder.
SELECT name AS LogicalName, type_desc AS FileType, physical_name AS FileLocation,
       CAST(size * 8 / 1024.0 AS decimal(10, 2)) AS SizeMB
FROM Restaurant.sys.database_files;
GO


--Item 3: Shrink the transaction log created in Item 2 to recover any available space
--The size of every file and of the whole database is shown before and after
--DBCC SHRINKFILE, which gives back to the disk any space the log file is not using.
--The 1 is a target size in MB. Without it SQL Server will not shrink the file below
--the size it was created at, so a brand-new log file would not get any smaller.
USE Restaurant;
GO

--Testing Item 3: size before the shrink
SELECT 'Before shrink' AS TestStep, name AS LogicalName, type_desc AS FileType,
       CAST(size * 8 / 1024.0 AS decimal(10, 2)) AS SizeMB
FROM sys.database_files;

SELECT 'Before shrink' AS TestStep,
       CAST(SUM(size) * 8 / 1024.0 AS decimal(10, 2)) AS DatabaseSizeMB
FROM sys.database_files;
GO

DBCC SHRINKFILE (RestaurantTransactionLog, 1);
GO

--Testing Item 3: size after the shrink
SELECT 'After shrink' AS TestStep, name AS LogicalName, type_desc AS FileType,
       CAST(size * 8 / 1024.0 AS decimal(10, 2)) AS SizeMB
FROM sys.database_files;

SELECT 'After shrink' AS TestStep,
       CAST(SUM(size) * 8 / 1024.0 AS decimal(10, 2)) AS DatabaseSizeMB
FROM sys.database_files;
GO

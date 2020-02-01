USE [master]
DROP DATABASE IF EXISTS [AssignmentPart1];
RESTORE DATABASE [AssignmentPart1] FROM  DISK = N'C:\Users\Public\AssignmentPart1_no_nulls_V2.bak' WITH  FILE = 1,  MOVE N'MumsnetAssignmentPart1' TO N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\MumsnetAssignmentPart1.mdf',  MOVE N'MumsnetAssignmentPart1_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\MumsnetAssignmentPart1_log.ldf',  NOUNLOAD,  STATS = 5
ALTER DATABASE [AssignmentPart1] SET COMPATIBILITY_LEVEL = 140;
GO


USE [master]
DROP DATABASE IF EXISTS [mumsnet];
RESTORE DATABASE [mumsnet] FROM  DISK = N'C:\Users\Public\mumsnet_v7.bak' WITH  FILE = 1,  NOUNLOAD,  STATS = 5
GO

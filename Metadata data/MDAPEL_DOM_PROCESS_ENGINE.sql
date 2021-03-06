﻿
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [MDAPEL].[DOM_PROCESS_ENGINE]([COD_PROCESS_ENGINE], [NAM_PROCESS_ENGINE], [DES_PROCESS_ENGINE])
SELECT -2, N'_#_', N'Process Type Not Applicable' UNION ALL
SELECT -1, N'_?_', N'Unknown process type' UNION ALL
SELECT 1, N'MANUAL_ENTRY', N'Manual entry in the database' UNION ALL
SELECT 100, N'DBMS_MICROSOFT_PROCEDURE', N'MICROSOFT SQL SERVER DBMS PROCEDURE' UNION ALL
SELECT 101, N'DBMS_ORACLE_PROCEDURE', N'ORACLE DBMS PROCEDURE' UNION ALL
SELECT 102, N'DBMS_POSTGRESQL_PROCEDURE', N'POSTGRESQL DBMS PROCEDURE' UNION ALL
SELECT 103, N'DBMS_SYBASE_PROCEDURE', N'SYBASE DBMS PROCEDURE' UNION ALL
SELECT 104, N'DBMS_MYSQL_PROCEDURE', N'MYSQL DBMS PROCEDURE' UNION ALL
SELECT 105, N'DBMS_DB2_PROCEDURE', N'IBM DBMS PROCEDURE' UNION ALL
SELECT 500, N'ETL_SSIS_PACKAGE', N'ETL TOOL Microsoft SSIS Package' UNION ALL
SELECT 501, N'ETL_KETTLE_SCRIPT', N'Kettle Script' UNION ALL
SELECT 502, N'ETL_OWB_SCRIPT', N'ETL TOOL Oracle Warehouse Builder' UNION ALL
SELECT 503, N'ETL_INFORMATICA', N'ETL Informatica Powercenter Job'
COMMIT;
RAISERROR (N'[MDAPEL].[DOM_PROCESS_ENGINE]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO


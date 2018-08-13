﻿
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [MDAPEL].[DOM_DTI_FREQUENCY]([COD_DTI_FREQUENCY], [DES_DTI_FREQUENCY])
SELECT -2, N'Not Applicable' UNION ALL
SELECT -1, N'Onbekend' UNION ALL
SELECT 1, N'Yearly' UNION ALL
SELECT 2, N'Quarterly' UNION ALL
SELECT 3, N'Monthly' UNION ALL
SELECT 4, N'Weekly' UNION ALL
SELECT 5, N'Daily' UNION ALL
SELECT 6, N'Intra Daily' UNION ALL
SELECT 7, N'Real Time' UNION ALL
SELECT 8, N'Adhoc'
COMMIT;
RAISERROR (N'[MDAPEL].[DOM_DTI_FREQUENCY]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO

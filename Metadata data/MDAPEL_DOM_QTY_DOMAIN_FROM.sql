﻿
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [MDAPEL].[DOM_QTY_DOMAIN_FROM]([QTY_DOMAIN_FROM])
SELECT 1 UNION ALL
SELECT 2 UNION ALL
SELECT 3 UNION ALL
SELECT 4 UNION ALL
SELECT 5
COMMIT;
RAISERROR (N'[MDAPEL].[DOM_QTY_DOMAIN_FROM]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO

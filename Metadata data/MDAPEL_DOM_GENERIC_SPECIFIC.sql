﻿
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [MDAPEL].[DOM_GENERIC_SPECIFIC]([IND_GENERIC_SPECIFIC], [DES_GENERIC_SPECIFIC])
SELECT N'G', N'GENERIC' UNION ALL
SELECT N'S', N'SPECIFIC'
COMMIT;
RAISERROR (N'[MDAPEL].[DOM_GENERIC_SPECIFIC]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO


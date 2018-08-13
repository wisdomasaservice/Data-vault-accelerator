
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [MDAPEL].[DOM_PLAUSIBLE]([COD_PLAUSIBLE], [DES_PLAUSIBLE])
SELECT N'D', N'The Data Transfer Interface Delivery (DTID) has already been processed in earlier times.' UNION ALL
SELECT N'P', N'The Data Transfer Interface Delivery (DTID) is Plausible.' UNION ALL
SELECT N'R', N'The Data Transfer Interface Delivery (DTID) is Rejected.' UNION ALL
SELECT N'T', N'The Data Transfer Interface Delivery (DTID) is Transferred. (no Plausiblity Check has been done yet)'
COMMIT;
RAISERROR (N'[MDAPEL].[DOM_PLAUSIBLE]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO


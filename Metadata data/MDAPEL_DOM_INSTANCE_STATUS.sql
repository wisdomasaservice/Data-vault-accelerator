
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [MDAPEL].[DOM_INSTANCE_STATUS]([COD_INSTANCE_STATUS], [DES_INSTANCE_STATUS])
SELECT N'ACTIVATED BUT LOCKED', N'Process is active but is still locked by another instance.' UNION ALL
SELECT N'DEACTIVATED', N'Process is deactivated, can make active by change attribute IND_ACTIVE to ''Y''.' UNION ALL
SELECT N'ERROR', N'Instance of process has resulted in an error, check for problems in LOG.' UNION ALL
SELECT N'FINNISHED', N'Instance has finnished technically correct.' UNION ALL
SELECT N'STARTED', N'Instance has started correctly.'
COMMIT;
RAISERROR (N'[MDAPEL].[DOM_INSTANCE_STATUS]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO


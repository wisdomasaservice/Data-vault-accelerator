
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [MDAPEL].[DOM_OBJECTROLE]([COD_OBJECTROLE], [COD_HUB_ENTITY], [DES_OBJECTROLE_UK], [DES_OBJECTROLE_NL], [M_COD_PROCESS], [M_UTC_RECORD_INSERTED], [M_UTC_RECORD_UPDATED])
SELECT 10000001, N'PERSON', N'Person is a customer', N'Persoon is klant', 0, '20121106 15:42:57.740', NULL UNION ALL
SELECT 10000002, N'PERSON', N'Person is employee', N'Persoon is werknemer', 0, '20121106 15:43:49.003', NULL UNION ALL
SELECT 10000003, N'PERSON', N'Person is parent / father or mother', N'Persoon is ouder / vader of moeder', 0, '20121106 15:44:41.387', NULL UNION ALL
SELECT 10100001, N'ORGANIZATION', N'Organization is registered at Chamber of Commerce', N'Organisatie is gergeristreerd bij Kamer van koophandel', 0, '20121106 15:45:29.210', NULL
COMMIT;
RAISERROR (N'[MDAPEL].[DOM_OBJECTROLE]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO

/* Deze hoeft niet volgens Jan Willem, want hij is verkeerd [AN] */
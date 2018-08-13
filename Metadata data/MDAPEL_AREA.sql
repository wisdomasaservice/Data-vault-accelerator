
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [MDAPEL].[AREA]([COD_AREA], [DES_AREA], [IND_ACTIVATED])
SELECT N'DDA', N'Data Distribution Area', N'Y' UNION ALL
SELECT N'DSA', N'Data Staging Area', N'Y' UNION ALL
SELECT N'EDA', N'External Data Area', N'Y' UNION ALL
SELECT N'EMA', N'Enterprise Memory Area', N'Y' UNION ALL
SELECT N'IDA', N'Internal Data Area', N'Y' UNION ALL
SELECT N'ISA', N'Information Subject Area', N'Y' UNION ALL
SELECT N'KSA', N'Knowledge Subject Area', N'Y' UNION ALL
SELECT N'MDA', N'Meta Data Area', N'Y' UNION ALL
SELECT N'OMA', N'Organizational Memory Area', N'Y' UNION ALL
SELECT N'UDA', N'Unstructured Data Area', N'Y'
COMMIT;
RAISERROR (N'[MDAPEL].[AREA]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO


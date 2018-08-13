
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [MDAPEL].[DOMAIN]([COD_DOMAIN], [IND_GENERIC_SPECIFIC], [COD_SOR], [COD_DOMAIN_MASK], [NAM_DOMAIN], [DES_DOMAIN], [DAT_START], [DAT_END])
SELECT -4, N'G', 0, N'_#_', N'Domain empty', N'Dummy domain for referential integrity', '19000101 00:00:00.000', '99991231 00:00:00.000' UNION ALL
SELECT -3, N'G', 0, N'_#_', N'Domain wrong domain value', N'Dummy domain for referential integrity', '19000101 00:00:00.000', '99991231 00:00:00.000' UNION ALL
SELECT -2, N'G', 0, N'_#_', N'Domain not applicable', N'Dummy domain for referential integrity', '19000101 00:00:00.000', '99991231 00:00:00.000' UNION ALL
SELECT -1, N'G', 0, N'_#_', N'Dummy domain for referential integrity', N'Dummy domain for referential integrity', '19000101 00:00:00.000', '99991231 00:00:00.000' UNION ALL
SELECT 1, N'G', 1, N'CHAR(1)', N'Male / Female indication', N'Indication of sex', '19000101 00:00:00.000', '99991231 00:00:00.000' UNION ALL
SELECT 2, N'G', 1, N'CHAR(1)', N'Yes / No Indication', N'Indication Yes / No', '19000101 00:00:00.000', '99991231 00:00:00.000' UNION ALL
SELECT 1000, N'G', 9001, N'CHAR(2)', N'ISO 3166-1 Country Code (A2)', N'Domain with two letter alfanumeric Country Codes', '19000101 00:00:00.000', '99991231 00:00:00.000' UNION ALL
SELECT 1001, N'G', 9001, N'CHAR(3)', N'ISO 3166-2 Country Code (A3)', N'Domain with three letter currency codes', '19000101 00:00:00.000', '99991231 00:00:00.000' UNION ALL
SELECT 1002, N'G', 9001, N'INTEGER', N'ISO 3166-3 Country Code (N)', N'Domain with Country Codes ISO 3166-3', '19000101 00:00:00.000', '99991231 00:00:00.000' UNION ALL
SELECT 1010, N'G', 9001, N'CHAR(3)', N'ISO 4217 Currency Codes', N'Domain with Currency Codes', '19000101 00:00:00.000', '99991231 00:00:00.000' UNION ALL
SELECT 1020, N'G', 9001, N'CHAR(3)', N'ISO 639-2 Language Codes', N'Domain with languages', '19000101 00:00:00.000', '99991231 00:00:00.000' UNION ALL
SELECT 2001, N'G', 9002, N'CHAR(2)', N'NL KvK Rechtsvormen', N'Domain with Dutch Organizational Legal Forms', '19000101 00:00:00.000', '99991231 00:00:00.000'
COMMIT;
RAISERROR (N'[MDAPEL].[DOMAIN]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO


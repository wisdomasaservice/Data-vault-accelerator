
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [MDAPEL].[SUBJECT]([COD_SUBJECT], [COD_AREA], [COD_SUBJECT_TYPE], [DES_SUBJECT], [IND_ACTIVATED])
SELECT N'DDADTI', N'DDA', N'DATABASE_SCHEME', N'Subject for Data Transfer Interfaces.', N'Y' UNION ALL
SELECT N'DDAIDF', N'DDA', N'OS_FOLDER', N'Subject for Incoming Data Files.', N'Y' UNION ALL
SELECT N'DDAINB', N'DDA', N'DATABASE_SCHEME', N'Subject for raw data', N'Y' UNION ALL
SELECT N'DDAODF', N'DDA', N'OS_FOLDER', N'Subject for Outgoing Data Files.', N'Y' UNION ALL
SELECT N'DSAFIC', N'DSA', N'DATABASE_SCHEME', N'Subject for temporary data but persisent tables to update DSAFIC', N'Y' UNION ALL
SELECT N'DSAISA', N'DSA', N'DATABASE_SCHEME', N'Subject for temporary snapshot tables for the ISA Area', N'Y' UNION ALL
SELECT N'DSAOMA', N'DSA', N'DATABASE_SCHEME', N'subject for temp objects for OMA', N'Y' UNION ALL
SELECT N'DSARIC', N'DSA', N'DATABASE_SCHEME', N'Subject for temporary data but persistent tables to update EMARIC', N'Y' UNION ALL
SELECT N'DSATMP', N'DSA', N'DATABASE_SCHEME', N'Subject for temporay data and temporary tables to update any other subject.', N'Y' UNION ALL
SELECT N'EDAISO', N'EDA', N'META_INFORMATION', N'Subject for ISO data', N'Y' UNION ALL
SELECT N'EDAKVK', N'EDA', N'META_INFORMATION', N'Subject for Kamer van Koophandel', N'Y' UNION ALL
SELECT N'EDALNK', N'EDA', N'META_INFORMATION', N'Subject f or data from LinkedIN', N'Y' UNION ALL
SELECT N'IDACRM', N'IDA', N'DATABASE_SCHEME', N'Subject for MySQL Database scheme of SUGARCRM', N'Y' UNION ALL
SELECT N'IDAFIN', N'IDA', N'DATABASE_SCHEME', N'Subject for MS SQL SERVER Database scheme of UNIT4 application', N'Y' UNION ALL
SELECT N'IDATIM', N'IDA', N'DATABASE_SCHEME', N'Subject for MS SQL SERVER Database scheme of TIMEREG application', N'Y' UNION ALL
SELECT N'ISACOM', N'ISA', N'DATABASE_SCHEME', N'Subject for Competitive Intelligence ', N'Y' UNION ALL
SELECT N'ISACUS', N'ISA', N'DATABASE_SCHEME', N'Subject for Customer Intelligence', N'Y' UNION ALL
SELECT N'ISAFIN', N'ISA', N'DATABASE_SCHEME', N'Subject for Financial Management Info', N'Y' UNION ALL
SELECT N'ISAHRM', N'ISA', N'DATABASE_SCHEME', N'Subject for Human Resources management info', N'Y' UNION ALL
SELECT N'ISAMIS', N'ISA', N'DATABASE_SCHEME', N'Subject for Generic Management Information', N'Y' UNION ALL
SELECT N'KSAREP', N'KSA', N'DATABASE_SCHEME', N'Subject for reporting datasets', N'Y' UNION ALL
SELECT N'MDADOC', N'MDA', N'SHAREPOINT_SITE', N'Subject for DWH documents.', N'Y' UNION ALL
SELECT N'MDAPEL', N'MDA', N'DATABASE_SCHEME', N'Subject for Proces and Entity Logistics.', N'Y' UNION ALL
SELECT N'MDAYFB', N'MDA', N'DATABASE_SCHEME', N'Subject for Metadata of YellowFin BI 6.2', N'Y' UNION ALL
SELECT N'OMADIA', N'OMA', N'DATABASE_SCHEME', N'Subject for Diary', N'Y' UNION ALL
SELECT N'OMAFIC', N'OMA', N'DATABASE_SCHEME', N'Subject for Forced Information Context', N'Y' UNION ALL
SELECT N'OMAMDM', N'OMA', N'DATABASE_SCHEME', N'Subject for Generic Internal and External Domains in OMA', N'Y' UNION ALL
SELECT N'OMARIC', N'OMA', N'DATABASE_SCHEME', N'Subject for Generic Modelling', N'Y'
COMMIT;
RAISERROR (N'[MDAPEL].[SUBJECT]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO


﻿
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [MDAPEL].[ENTITY]([COD_ENTITY], [COD_SUBJECT], [NAM_ENTITY], [COD_ENTITY_TYPE], [DES_ENTITY], [DES_DESIGN_REMARKS], [DAT_ENTITY_START], [DAT_ENTITY_END], [DAT_ENTITY_LAST_STATUS], [QTY_NUMBER_OF_ROWS], [QTY_DATA_SPACE_IN_KB], [QTY_INDEX_SPACE_IN_KB], [QTY_UNUSED_SPACE_IN_KB], [QTY_TOTAL_SPACE_IN_KB])
SELECT N'MDAPEL.AREA', N'MDAPEL', N'AREA', N'TABLE', N'', NULL, '20120801 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 10, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.ATTRIBUTE', N'MDAPEL', N'ATTRIBUTE', N'TABLE', N'', NULL, '20120801 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 6141, 2896, 0, 336, 3232 UNION ALL
SELECT N'MDAPEL.ATTRIBUTE_PROCESS', N'MDAPEL', N'ATTRIBUTE_PROCESS', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 0, 0, 0, 0, 0 UNION ALL
SELECT N'MDAPEL.DIM_PROCESSED_SNAPSHOTS', N'MDAPEL', N'DIM_PROCESSED_SNAPSHOTS', N'TABLE', N'', NULL, '20120801 00:00:00.000', '99991231 00:00:00.000', '20120801 00:00:00.000', 0, 0, 0, 0, 0 UNION ALL
SELECT N'MDAPEL.DOM_ASSOCIATION', N'MDAPEL', N'DOM_ASSOCIATION', N'TABLE', N'', NULL, '20121106 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 51, 32, 0, 0, 32
COMMIT;
RAISERROR (N'[MDAPEL].[ENTITY]: Insert Batch: 4.....Done!', 10, 1) WITH NOWAIT;
GO

BEGIN TRANSACTION;
INSERT INTO [MDAPEL].[ENTITY]([COD_ENTITY], [COD_SUBJECT], [NAM_ENTITY], [COD_ENTITY_TYPE], [DES_ENTITY], [DES_DESIGN_REMARKS], [DAT_ENTITY_START], [DAT_ENTITY_END], [DAT_ENTITY_LAST_STATUS], [QTY_NUMBER_OF_ROWS], [QTY_DATA_SPACE_IN_KB], [QTY_INDEX_SPACE_IN_KB], [QTY_UNUSED_SPACE_IN_KB], [QTY_TOTAL_SPACE_IN_KB])
SELECT N'MDAPEL.DOM_ATTRIBUTE_TYPE', N'MDAPEL', N'DOM_ATTRIBUTE_TYPE', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 22, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_BOOLEAN', N'MDAPEL', N'DOM_BOOLEAN', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 4, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_DTI_CONTAINER_TYPE', N'MDAPEL', N'DOM_DTI_CONTAINER_TYPE', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 13, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_DTI_FREQUENCY', N'MDAPEL', N'DOM_DTI_FREQUENCY', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 10, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_DTI_TRANSFER_PROTOCOL', N'MDAPEL', N'DOM_DTI_TRANSFER_PROTOCOL', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 9, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_DTI_TYPE', N'MDAPEL', N'DOM_DTI_TYPE', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 7, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_ENTITY_TYPE', N'MDAPEL', N'DOM_ENTITY_TYPE', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 6, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_FUNCTION_TYPE', N'MDAPEL', N'DOM_FUNCTION_TYPE', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 2, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_GENDER', N'MDAPEL', N'DOM_GENDER', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 4, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_GENERIC_SPECIFIC', N'MDAPEL', N'DOM_GENERIC_SPECIFIC', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 2, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_HUB_ENTITY', N'MDAPEL', N'DOM_HUB_ENTITY', N'TABLE', N'', NULL, '20121106 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 37, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_HUB_IDC', N'MDAPEL', N'DOM_HUB_IDC', N'TABLE', N'', NULL, '20121106 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 11056, 1552, 0, 192, 1744 UNION ALL
SELECT N'MDAPEL.DOM_INPUT_OUTPUT', N'MDAPEL', N'DOM_INPUT_OUTPUT', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 2, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_INSTANCE_STATUS', N'MDAPEL', N'DOM_INSTANCE_STATUS', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 5, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_LOG_TYPE', N'MDAPEL', N'DOM_LOG_TYPE', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 2, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_OBJECTROLE', N'MDAPEL', N'DOM_OBJECTROLE', N'TABLE', N'', NULL, '20121106 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 4, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_PLAUSIBLE', N'MDAPEL', N'DOM_PLAUSIBLE', N'TABLE', N'', NULL, '20121011 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 4, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_PROCESS_ENGINE', N'MDAPEL', N'DOM_PROCESS_ENGINE', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 13, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_QTY_DOMAIN_FROM', N'MDAPEL', N'DOM_QTY_DOMAIN_FROM', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 5, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_SCENARIO', N'MDAPEL', N'DOM_SCENARIO', N'TABLE', N'', NULL, '20121106 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 3, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOM_SUBJECT_TYPE', N'MDAPEL', N'DOM_SUBJECT_TYPE', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 5, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOMAIN', N'MDAPEL', N'DOMAIN', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 12, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOMAIN_TRANSLATION', N'MDAPEL', N'DOMAIN_TRANSLATION', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 3, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.DOMAIN_TRANSLATION_VALUE', N'MDAPEL', N'DOMAIN_TRANSLATION_VALUE', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 720, 208, 0, 0, 208 UNION ALL
SELECT N'MDAPEL.DOMAIN_VALUE', N'MDAPEL', N'DOMAIN_VALUE', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 1127, 96, 0, 40, 136 UNION ALL
SELECT N'MDAPEL.DTI', N'MDAPEL', N'DTI', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 122, 40, 0, 40, 80 UNION ALL
SELECT N'MDAPEL.ENTITY', N'MDAPEL', N'ENTITY', N'TABLE', N'', NULL, '20120801 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 394, 192, 0, 48, 240 UNION ALL
SELECT N'MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_DAT', N'MDAPEL', N'ENTITY_PROCESSED_SNAPSHOTS_DAT', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 103, 128, 0, 0, 128 UNION ALL
SELECT N'MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC', N'MDAPEL', N'ENTITY_PROCESSED_SNAPSHOTS_UTC', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 2361, 1176, 0, 464, 1640 UNION ALL
SELECT N'MDAPEL.FUNCTION', N'MDAPEL', N'FUNCTION', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 22, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.FUNCTION_PROCESS', N'MDAPEL', N'FUNCTION_PROCESS', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 0, 0, 0, 0, 0 UNION ALL
SELECT N'MDAPEL.HUB_PROCESSED_SNAPSHOTS', N'MDAPEL', N'HUB_PROCESSED_SNAPSHOTS', N'TABLE', N'', NULL, '20120801 00:00:00.000', '99991231 00:00:00.000', '20120801 00:00:00.000', 0, 0, 0, 0, 0 UNION ALL
SELECT N'MDAPEL.INSTANCE', N'MDAPEL', N'INSTANCE', N'TABLE', N'', NULL, '20120801 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 148537, 15648, 0, 144, 15792 UNION ALL
SELECT N'MDAPEL.LNK_OBJECTROLE_PROCESSED_SNAPSHOTS', N'MDAPEL', N'LNK_OBJECTROLE_PROCESSED_SNAPSHOTS', N'TABLE', N'', NULL, '20120801 00:00:00.000', '99991231 00:00:00.000', '20120801 00:00:00.000', 0, 0, 0, 0, 0 UNION ALL
SELECT N'MDAPEL.LNK_PROCESSED_SNAPSHOTS', N'MDAPEL', N'LNK_PROCESSED_SNAPSHOTS', N'TABLE', N'', NULL, '20120801 00:00:00.000', '99991231 00:00:00.000', '20120801 00:00:00.000', 0, 0, 0, 0, 0 UNION ALL
SELECT N'MDAPEL.LOG', N'MDAPEL', N'LOG', N'TABLE', N'', NULL, '20120801 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 991799, 219040, 0, 320, 219360 UNION ALL
SELECT N'MDAPEL.PROCESS', N'MDAPEL', N'PROCESS', N'TABLE', N'', NULL, '20120801 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 404, 152, 0, 48, 200 UNION ALL
SELECT N'MDAPEL.SAT_PROCESSED_SNAPSHOTS', N'MDAPEL', N'SAT_PROCESSED_SNAPSHOTS', N'TABLE', N'', NULL, '20120801 00:00:00.000', '99991231 00:00:00.000', '20120801 00:00:00.000', 0, 0, 0, 0, 0 UNION ALL
SELECT N'MDAPEL.SOR', N'MDAPEL', N'SOR', N'TABLE', N'', NULL, '20120801 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 10, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.SUBJECT', N'MDAPEL', N'SUBJECT', N'TABLE', N'', NULL, '20120801 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 28, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.USER', N'MDAPEL', N'USER', N'TABLE', N'', NULL, '20121004 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 1, 16, 0, 0, 16 UNION ALL
SELECT N'MDAPEL.VERSION', N'MDAPEL', N'VERSION', N'TABLE', N'', NULL, '20121220 00:00:00.000', '99991231 00:00:00.000', '20130219 00:00:00.000', 1, 16, 0, 0, 16 
COMMIT;
RAISERROR (N'[MDAPEL].[ENTITY]: Insert Batch: 5.....Done!', 10, 1) WITH NOWAIT;
GO

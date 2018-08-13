
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [MDAPEL].[DOM_HUB_ENTITY]([COD_HUB_ENTITY], [DES_HUB_ENTITY_UK], [DES_HUB_ENTITY_NL])
SELECT N'_#_', N'Not Applicable', N'Niet van toepassing' UNION ALL
SELECT N'_?_', N'Unknown', N'Onbekend' UNION ALL
SELECT N'ACTIVITY', N'Activity', N'Activiteit' UNION ALL
SELECT N'ADDRESS', N'Address', N'Adres' UNION ALL
SELECT N'ANIMAL', N'Animal', N'Dier / Beest' UNION ALL
SELECT N'CAMPAIGN', N'Campaign / Marketing action', N'Campagne / Marketing actie' UNION ALL
SELECT N'CARD', N'Card', N'Kaart / pas' UNION ALL
SELECT N'COLLATERAL', N'Collateral', N'Zekerheid / onderpand' UNION ALL
SELECT N'CONTRACT', N'Contract / Agreement', N'Contract / overeenkomst' UNION ALL
SELECT N'COVER', N'Cover', N'Dekking' UNION ALL
SELECT N'DEPARTMENT', N'Deparment', N'Afdeling / Organisatieonderdeel' UNION ALL
SELECT N'DEPOT', N'Depot', N'Depot / Rekening' UNION ALL
SELECT N'DEVICE', N'Device', N'Apparaat' UNION ALL
SELECT N'DOCUMENT', N'Document', N'Document' UNION ALL
SELECT N'EMAILADDRESS', N'Email Address', N'Email Adres' UNION ALL
SELECT N'GROUP', N'Group', N'Groep' UNION ALL
SELECT N'IBAN', N'Iban account number', N'IBAN rekeningnummer' UNION ALL
SELECT N'INSTALLATION', N'Installation', N'Installatie' UNION ALL
SELECT N'INVOICE', N'Invoice', N'Faktuur' UNION ALL
SELECT N'LABEL', N'Label', N'Label / merknaam' UNION ALL
SELECT N'LOCATION', N'Location', N'Lokatie coordinaten' UNION ALL
SELECT N'NOTE', N'Note', N'Note / Aantekening' UNION ALL
SELECT N'OBJECT', N'Object', N'Object (gebouw op een perceel)' UNION ALL
SELECT N'OPPORTUNITY', N'opportunity', N'Kans / Mogelijkheid' UNION ALL
SELECT N'ORGANIZATION', N'Organization / Organisation', N'Organisatie' UNION ALL
SELECT N'PERSON', N'Person', N'Persoon' UNION ALL
SELECT N'PERSONSKILL', N'Person Skills', N'Persoon Vaardigheden met betrekking tot vakgebied' UNION ALL
SELECT N'PHONENUMBER', N'Phonenumber', N'Phonenumber' UNION ALL
SELECT N'PRODUCT', N'Product', N'Produkt' UNION ALL
SELECT N'PROJECT', N'Project', N'Project' UNION ALL
SELECT N'RSSFEED', N'URL RSS Feed', N'URL RSS Feed' UNION ALL
SELECT N'SERVICE', N'Service', N'Service / Dienst' UNION ALL
SELECT N'SUBJECT', N'Subject', N'Subject / Perceel' UNION ALL
SELECT N'TASK', N'Task ', N'Taak' UNION ALL
SELECT N'TWITTER', N'URL Twitter', N'URL Twitter' UNION ALL
SELECT N'VEHICLE', N'Vehicle', N'Voertuig' UNION ALL
SELECT N'WEAPON', N'Weapon', N'Wapen'
COMMIT;
RAISERROR (N'[MDAPEL].[DOM_HUB_ENTITY]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO



SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

BEGIN TRANSACTION;
INSERT INTO [MDAPEL].[DOM_DTI_TYPE]([COD_DTI_TYPE], [DES_DTI_TYPE])
SELECT -2, N'Not applicable Data Transfer Interface type' UNION ALL
SELECT -1, N'Unknown Data Transfer Interface type' UNION ALL
SELECT 1, N'Data Type = Status Data ; Delivery Type = Batch      ; Timeline = Fixed Time                ; Delivery Quantity = Snapshot with all identifyers' UNION ALL
SELECT 2, N'Data Type = Status Data ; Delivery Type = Message ; Timeline = Real Time                  ; Delivery Quantity = message for every change per identifyer' UNION ALL
SELECT 3, N'Data Type = Status Data; Delivery Type = Batch       ; Timeline = Fixed Time                ; Delivery Quantity = Snapshot with only changed identifyers since last delivery' UNION ALL
SELECT 101, N'Data Type = Event Data  ; Delivery Type = Batch      ; Timeline = Fixed Time                ; Delivery Quantity = All events since last delivery' UNION ALL
SELECT 102, N'Data Type = Event Data  ; Delivery Type = Message ; Timeline = Real Time                 ; Delivery Quantity  = message for every event'
COMMIT;
RAISERROR (N'[MDAPEL].[DOM_DTI_TYPE]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO


/****** Object:  View [MDAPEL].[VW_INSTANCE_LOG]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [MDAPEL].[VW_INSTANCE_LOG] 
AS
SELECT 
 [INSTANCE].COD_PROCESS
,[INSTANCE].COD_INSTANCE
,[PROCESS].IND_INSTANCE_RUNNING
,[INSTANCE].COD_INSTANCE_STATUS
,[INSTANCE].UTC_INSTANCE_START
,[INSTANCE].UTC_INSTANCE_END
,[INSTANCE].TIM_DURATION_INSTANCE
,[PROCESS].COD_SUBJECT
,[PROCESS].NAM_PROCESS
  FROM
(
SELECT *
  FROM [MDAPEL].[INSTANCE]
) [INSTANCE]
INNER JOIN
(
SELECT *
  FROM MDAPEL.PROCESS
) [PROCESS]
ON [INSTANCE].[COD_PROCESS] = [PROCESS].[COD_PROCESS]
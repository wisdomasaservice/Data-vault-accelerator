/****** Object:  StoredProcedure [MDAPEL].[GF_0020_CREATE_DDADTI_STATUS_PLAUSIBILITY_PROCESS I.O.]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================================================
-- Author(s)          : Michael Doves
-- date Created       : 2012-10-01
-- Version            : 1
-- Date Last Modified :            
-- Description        :	Generates a generic Plausibility Procedure for DTID's
--                      Default actions are also generating an M_CRC value and setting
--                      the attribute value of M_COD_PLAUSIBLE from 'T' (transferred) 
--                      to 'P' (plausible) or 'R' (Rejected).
-- Parameters         :	@DDADTI_TABLE = input DDA table
-- Modifications      : 
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-- ========================================================================================
CREATE PROCEDURE [MDAPEL].[GF_0020_CREATE_DDADTI_STATUS_PLAUSIBILITY_PROCESS I.O.]
  @DDADTI_TABLE nvarchar(100)
AS
BEGIN TRY
--DECLARE @DDADTI_TABLE   varchar(100) = 'DTI0001000_ACCOUNTS'
DECLARE @SQL1			varchar(max)
DECLARE @DDA_COLUMNLIST varchar(max)
DECLARE @OUTPUT_SCHEMA	char(6) = 'DDADTI'
DECLARE @M_COD_PROCESS   bigint

SET @M_COD_PROCESS = CONVERT(BIGINT,'3'+SUBSTRING(@DDADTI_TABLE,4,7))
PRINT @M_COD_PROCESS


END TRY

BEGIN CATCH
		SELECT ERROR_MESSAGE() 
		RETURN
END CATCH

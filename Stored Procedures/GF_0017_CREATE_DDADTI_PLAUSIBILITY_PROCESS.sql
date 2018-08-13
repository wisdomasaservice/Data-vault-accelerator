/****** Object:  StoredProcedure [MDAPEL].[GF_0017_CREATE_DDADTI_PLAUSIBILITY_PROCESS]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0017_CREATE_DDADTI_PLAUSIBILITY_PROCESS]
/* PARAMETER 01 */ @COD_DTI INTEGER
-------------------------------------------------------------------------------------
-- Author             : Michael Doves
-- Author Phone       : +31(0)30-6005858
-- Author Email       : info@astragy.com
-- Purpose            : generate automatic an initial code for a process that does 
--                      a Plausibility Check on DTID.
-- Date Created       : 2012-11-05
-- Date Last Modified : 
-- Total Run Time (s) : 
-- Version            : 1
-- Modification(s)    : Version 1: Initial Code
-- Remarks            : 
-- Example call       : EXECUTE MDAPEL.GF_0017_CREATE_DDADTI_PLAUSIBILITY_PROCESS 1052
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-------------------------------------------------------------------------------------
AS
BEGIN TRY
-------------------------------------------------------------------------------------------
-- BEGIN DECLARE PARAMETERS
-------------------------------------------------------------------------------------------
--DECLARE @COD_DTI            INTEGER = 1005
DECLARE @TXT_KEY_COLUMNS    NVARCHAR(200)
DECLARE @SQL1			    NVARCHAR(MAX)
DECLARE @SQL2			    VARCHAR(MAX)
DECLARE @SQL3               NVARCHAR(MAX)
DECLARE @CRC_LIST           NVARCHAR(MAX)
DECLARE @COD_ENTITY         NVARCHAR(107)
DECLARE @NAM_ENTITY         NVARCHAR(107)
DECLARE @NAM_PROCESS        NVARCHAR(100)
DECLARE @TXT_DATE           NCHAR(10)
DECLARE @M_COD_PROCESS      NCHAR(8)
DECLARE @M_COD_SOR          NVARCHAR(18)
-------------------------------------------------------------------------------------------
-- END DECLARE PARAMETERS
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
-- BEGIN INITIALIZE PARAMETERS
-------------------------------------------------------------------------------------------                     
SET @TXT_DATE = (SELECT CONVERT(DATE,GETDATE()))
PRINT '@TXT_DATE = '+CONVERT(NVARCHAR(10),@TXT_DATE)

SET @M_COD_PROCESS = ('3'+RIGHT('0000000'+CONVERT(NVARCHAR,@COD_DTI),7))
PRINT '@M_COD_PROCESS = '+CONVERT(NVARCHAR(8),@M_COD_PROCESS)

SET @COD_ENTITY = (SELECT COD_ENTITY
                     FROM MDAPEL.DTI
                    WHERE 1=1
                      AND COD_DTI = @COD_DTI
                  )
PRINT '@COD_ENTITY = '+CONVERT(NVARCHAR(107),@COD_ENTITY)
     
SET @NAM_ENTITY = (SUBSTRING(@COD_ENTITY,8,100))
PRINT '@NAM_ENTITY = '+CONVERT(NVARCHAR(100),@NAM_ENTITY)    

SET @NAM_PROCESS = ('PROCESS_3'+ SUBSTRING(@COD_ENTITY,11,100))
PRINT '@NAM_PROCESS = '+CONVERT(NVARCHAR(100),@NAM_PROCESS)    

SET @M_COD_SOR = (SELECT CONVERT(NVARCHAR,COD_SOR)
                     FROM MDAPEL.DTI
                    WHERE 1=1
                      AND COD_DTI = @COD_DTI
                  )
PRINT '@M_COD_SOR = '+CONVERT(NVARCHAR(18),@M_COD_SOR) 
-------------------------------------------------------------------------------------------
-- END INITIALIZE PARAMETERS
-------------------------------------------------------------------------------------------
                   --  HASHBYTES ( 'MD5', convert(nvarchar,[id]))
SET @SQL1 = N'
SELECT @CRC_LIST = (SELECT STUFF ((SELECT '',HASHBYTES(''''MD5'''',CONVERT(NVARCHAR(MAX),[''+COLUMN_NAME+'']))''
						                       FROM INFORMATION_SCHEMA.COLUMNS
						                      WHERE 1=1 
						                        AND TABLE_NAME = '''+@NAM_ENTITY+'''
						                        AND TABLE_SCHEMA = ''DDADTI''
						                        AND UPPER(SUBSTRING(COLUMN_NAME,1,2)) <> (''M_'')
						                      ORDER BY ORDINAL_POSITION FOR XML PATH('''')
										    ), 1, 1, '''') 
					         )
'
PRINT @SQL1
EXECUTE SP_EXECUTESQL @SQL1, N'@CRC_LIST nvarchar(max) OUTPUT', @CRC_LIST = @CRC_LIST OUTPUT
PRINT @CRC_LIST

SET @SQL2 = '
CREATE PROCEDURE DDADTI.'+@NAM_PROCESS+'
---------------------------------------------------------------------
-- BEGIN: PROCEDURE  MDAPEL.'+@NAM_PROCESS+'
---------------------------------------------------------------------
AS
-------------------------------------------------------------------------------------
-- Author             : DIKW Astragy B.V.
-- Author Phone       : +31(0)30-6005858
-- Author Email       : info@astragy.com
-- Purpose            : Plausibility Check on DTID
-- Target Entity      : '+@COD_ENTITY+'
-- Date Created       : '+@TXT_DATE+'
-- Date Last Modified : 
-- Total Run Time (s) : 
-- Version            : 1
-- Modification(s)    : Version 1: Initial Code
-- Remarks            : Version 1 is Automatically generated
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-------------------------------------------------------------------------------------
DECLARE @M_COD_PROCESS        BIGINT = '+@M_COD_PROCESS+'
DECLARE @M_COD_INSTANCE       BIGINT
DECLARE @M_COD_PROCESS_STATUS NVARCHAR(22)
DECLARE @M_COD_PLAUSIBLE      NCHAR(1) = ''R''
EXECUTE MDAPEL.GF_1001_GENERIC_PRE_PROCESS @M_COD_PROCESS,@M_COD_INSTANCE OUTPUT,@M_COD_PROCESS_STATUS OUTPUT
BEGIN TRY
IF @M_COD_PROCESS_STATUS = ''ACTIVATED AND UNLOCKED''
BEGIN 
EXECUTE MDAPEL.GF_1000_INSERT_LOG @M_COD_PROCESS,@M_COD_INSTANCE,''INFORMATION'',''Specific Pre Process has started.''
EXECUTE MDAPEL.GF_1000_INSERT_LOG @M_COD_PROCESS,@M_COD_INSTANCE,''INFORMATION'',''Main Process has started.''
DECLARE @M_UTC_SNAPSHOT   DATETIME2(0)
DECLARE @M_COD_SOR        BIGINT
    SET @M_UTC_SNAPSHOT = (SELECT MIN(M_UTC_SNAPSHOT) AS M_UTC_SNAPSHOT
                             FROM '+@COD_ENTITY+'    
                            WHERE M_COD_PLAUSIBLE = ''T''         
                          )
    SET @M_COD_SOR      = (SELECT MIN(M_COD_SOR) AS M_COD_SOR
                             FROM '+@COD_ENTITY+'
                            WHERE M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
                              AND M_COD_PLAUSIBLE = ''T'' 
                          )                      
  PRINT ''@M_UTC_SNAPSHOT = ''+convert(nvarchar,@M_UTC_SNAPSHOT)
  PRINT ''@M_COD_SOR      = ''+convert(nvarchar,@M_COD_SOR)
--------------------------------------------------------------------------------------
-- BEGIN: PLAUSIBILITY CHECK(s)
--------------------------------------------------------------------------------------
-- Here come all specific checks for this DTI.
-- DECLARE @M_COD_PLAUSIBLE_01      NCHAR(1) = ''R'' -- Rejected
-- IF check OK SET @M_COD_PLAUSIBLE_01 = ''P''       -- Plausible
-- If all plausibility checks are ''P'' then ''P'' else ''R''
SET @M_COD_PLAUSIBLE = ''P''
--------------------------------------------------------------------------------------
-- END: PLAUSIBILITY CHECK(s)
--------------------------------------------------------------------------------------
UPDATE '+@COD_ENTITY+'
   SET M_COD_PLAUSIBLE = ''P''
      ,M_CRC           = BINARY_CHECKSUM ('+@CRC_LIST+') 

WHERE 1=1
  AND M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
  AND M_COD_SOR      = @M_COD_SOR
  
EXECUTE MDAPEL.GF_1000_INSERT_LOG @M_COD_PROCESS,@M_COD_INSTANCE,''INFORMATION'',''Specific Post Process has started.''
END
EXECUTE MDAPEL.GF_1002_GENERIC_POST_PROCESS @M_COD_PROCESS,@M_COD_INSTANCE,@M_COD_PROCESS_STATUS
END TRY
BEGIN CATCH
  DECLARE @M_ERROR_MESSAGE NVARCHAR(4000) = (SELECT ERROR_MESSAGE())
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING @M_COD_PROCESS,@M_COD_INSTANCE,@M_ERROR_MESSAGE
END CATCH 
'
PRINT @SQL2
SET @SQL3 = CONVERT(NVARCHAR(MAX),@SQL2)
PRINT @SQL3
EXECUTE SP_EXECUTESQL @SQL3

END TRY
BEGIN CATCH
		SELECT ERROR_MESSAGE() 
		RETURN
END CATCH
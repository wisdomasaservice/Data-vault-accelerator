/*USE [DWHPRD]*/
GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0205_OMADIA_DELTA_STATUS]    Script Date: 2/19/2014 1:18:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0205_OMADIA_DELTA_STATUS] 
/* PAR 1 */ @M_COD_DTI      NVARCHAR(200)
/* PAR 2 */,@M_COD_PROCESS  NVARCHAR(18)
/* PAR 3 */,@M_COD_INSTANCE BIGINT
/* PAR 4 */,@DELETE_IND_FIELD NVARCHAR(100)
/* PAR 5 */,@DELETE_IND_CHAR NVARCHAR(3) = 'X'
/* PAR 6 */,@DEBUG          BIT = 0
AS
-- =========================================================================================
-- Author(s)          : Dinand Kleibeuker
-- date Created       : 2013-03-07
-- Version            : 1
-- Date Last Modified : 2014-02-19 (DK)    
-- Description        :	OMADIA TYPE I Update Proces based on delta source (DTI) and not snapshot!
-- Parameters         :	PAR 1 @M_COD_DTI      = Name of Input Table, The Data Transfer Interface (DTI).
--                      PAR 2 @M_COD_PROCESS  = Unique Integer of Process.
--                      PAR 3 @M_COD_INSTANCE = Unique integer of Process Instance.
--						PAR 4 @DELETE_IND_FIELD = the field in the DDADTI table that provides the delete indicator from the source
--						PAR 5 @DELETE_IND_CHAR = Character for deletion-indicator often it is X; For purchase it is L
--                      PAR 6 @DEBUG          = Optional parameter for debugging
-- Modifications      : Automatic Logging and error Handling is integrated
--                      20130422HE: Condition DELETE_IND_FIELD = 'D' changed in = 'X'
--						20130822HE: Extra parameter DELETE_IND_CHAR while purchase orders has L in stead of X
--						20140219DK: Added CASE to close records that are already deleted in source (DELETE_IND_CHAR = DELETE_IND_FIELD)
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-- ========================================================================================

---------------------------------------------------------------------
-- BEGIN: Remarks
---------------------------------------------------------------------
-- M_COD_PLAUSIBLE: T = Transferred, ready to be checked.
--                  P = plausible, may be processed into OMADIA
--                  R = Rejected, may not be processed into OMADIA.
---------------------------------------------------------------------
-- END: Remarks
---------------------------------------------------------------------

SET @DELETE_IND_CHAR = CHAR(39) + @DELETE_IND_CHAR + CHAR(39)

BEGIN TRY-- A
IF @DEBUG = 0 SET NOCOUNT ON

/* BEGIN: Initialize Process Parameters */
DECLARE @PROCESS_NAME				VARCHAR(208) 	='PROCESS_'+@M_COD_DTI  --Actually instance name
DECLARE @INPUT_SCHEMA				VARCHAR(200)	='DDADTI'
DECLARE @OUTPUT_SCHEMA				VARCHAR(200)	='OMADIA'
--DECLARE @UTC_INSTANCE_START			DATETIME2(0)    = GETUTCDATE()
/* END: Initialize Process Parameters */

/* BEGIN: DECLARE parameters */
DECLARE @M_COD_SOR					NVARCHAR(18) -- Bigint is maximaal 18 digits		
DECLARE @SQL1						NVARCHAR(MAX)
DECLARE @SQL2						NVARCHAR(MAX)
DECLARE @SQL3						NVARCHAR(MAX)
DECLARE @BIGSQL						NVARCHAR(MAX)
DECLARE @M_UTC_SNAPSHOT				DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_MAX			DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_MIN			DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_PREVIOUS	DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_NEXT		DATETIME2(0)
DECLARE @M_UTC_START				DATETIME2(0)
DECLARE @SCENARIO					NVARCHAR(20)
DECLARE @LOG						NVARCHAR(MAX)
DECLARE @ROWCOUNT					BIGINT
DECLARE @ROWCOUNT_P					BIGINT
DECLARE @M_ERROR_MESSAGE            NVARCHAR(4000)
/* END: DECLARE parameters */

/**********************************************************************************/
-- BEGIN: Write log message
/**********************************************************************************/
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'GF_0205_OMADIA_DELTA_STATUS is called'

/**********************************************************************************/
-- END: Write log message
/**********************************************************************************/

/*BEGIN: Collect M_COD_SOR from source (DDADTI) table */

BEGIN TRY
  SET @SQL1 = N'SELECT @M_COD_SOR = (SELECT MAX(M_COD_SOR) FROM '+@INPUT_SCHEMA+'.'+ @M_COD_DTI+')'
  EXECUTE sp_executesql @SQL1, N'@M_COD_SOR BIGINT OUTPUT', @M_COD_SOR = @M_COD_SOR OUTPUT
  IF @DEBUG = 1 PRINT 'M_COD_SOR = '+@M_COD_SOR
END TRY

BEGIN CATCH
  SET @LOG = 'Unable to retrieve M_COD_SOR - ' + ERROR_MESSAGE() + ' | '+ @SQL1
  EXECUTE MDAPEL.GF_1000_INSERT_LOG 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,'ERROR'
  /* PAR 4 */ ,@LOG  
  
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE())
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE
  RETURN
END CATCH

/* END: Collect M_COD_SOR from source (DDADTI) table */



/**********************************************************************************/
/**********************************************************************************/
-- BEGIN: Specific Pre-Process
/**********************************************************************************/
/**********************************************************************************/

IF @DEBUG = 1 PRINT'******** SPECIFIC PRE-PROCESS ********'

/**********************************************************************************/
-- BEGIN: Determine M_UTC_SNAPSHOT to process from DDADTI
/**********************************************************************************/
-- If there are more than 1 DTID's the oldest will be processed.
BEGIN TRY
  SET @SQL1 = N'select @M_UTC_SNAPSHOT = isnull(min(M_UTC_SNAPSHOT), CAST(''01-01-1000'' as DATETIME2))
                  from '+@INPUT_SCHEMA+'.'+@M_COD_DTI+' 
                 where M_COD_SOR =  '+@M_COD_SOR+' 
                   and M_COD_PLAUSIBLE = ''P''
               '
  IF @DEBUG = 1 PRINT @SQL1
    EXECUTE sp_executesql @SQL1, N'@M_UTC_SNAPSHOT DATETIME2(0) OUTPUT', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT OUTPUT
  
  IF @DEBUG = 1 PRINT '@M_UTC_SNAPSHOT: ' +cast(@M_UTC_SNAPSHOT as NVARCHAR(30))
    SET @LOG = '@M_UTC_SNAPSHOT: ' + ISNULL(cast(@M_UTC_SNAPSHOT as NVARCHAR(30)), 'No Snapshot')
    EXECUTE MDAPEL.GF_1000_INSERT_LOG 
    /* PAR 1 */  @M_COD_PROCESS
    /* PAR 2 */ ,@M_COD_INSTANCE
    /* PAR 3 */ ,'INFORMATION'
    /* PAR 4 */ ,@LOG   		
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE())
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN
END CATCH                       
/**********************************************************************************/
-- END: Determine M_UTC_SNAPSHOT to process from DDADTI
/**********************************************************************************/

/**********************************************************************************/
-- BEGIN: Determine number of DDADTI records for snapshot
/**********************************************************************************/

BEGIN TRY
  SET @SQL1 = N'SELECT @LOG = COUNT(1) FROM '+@INPUT_SCHEMA+'.'+@M_COD_DTI+' WHERE M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT'
  EXECUTE sp_executesql @SQL1, N'@M_UTC_SNAPSHOT DATETIME2(0), @LOG NVARCHAR(MAX) OUTPUT', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT, @LOG = @LOG OUTPUT
  
  SET @LOG = 'DDA Records in snapshot: ' +@LOG
  EXECUTE MDAPEL.GF_1000_INSERT_LOG 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,'INFORMATION'
  /* PAR 4 */ ,@LOG  
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE())
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN
END CATCH 


/**********************************************************************************/
-- BEGIN: Determine M_UTC_SNAPSHOT_MAX from OUTPUT Table
/**********************************************************************************/
BEGIN TRY
  SET @SQL1=
  N'(select @M_UTC_SNAPSHOT_MAX =  max(X.M_UTC_SNAPSHOT)
     from (select isnull(max(M_UTC_START),CAST(''01-01-1000'' as DATETIME2)) as M_UTC_SNAPSHOT
			from '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+' 
			where M_COD_SOR = '+@M_COD_SOR+' 
            union 
           select isnull(max(dateadd(ss,1,M_UTC_END)),CAST(''01-01-1000'' as DATETIME2))  as M_UTC_SNAPSHOT
            from '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+' 
			where M_COD_SOR = '+@M_COD_SOR+'
              and M_UTC_END < ''9999-12-31''
           ) X
	)'
  IF @DEBUG = 1 PRINT @SQL1
    EXECUTE sp_executesql @SQL1, N'@M_UTC_SNAPSHOT_MAX DATETIME2(0) OUTPUT', @M_UTC_SNAPSHOT_MAX = @M_UTC_SNAPSHOT_MAX OUTPUT
		
  IF @DEBUG = 1 PRINT '@M_UTC_SNAPSHOT_MAX: ' +cast(@M_UTC_SNAPSHOT_MAX as NVARCHAR(25))
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
/**********************************************************************************/
-- END: Determine M_UTC_SNAPSHOT_MAX from OUTPUT Table
/**********************************************************************************/


/**********************************************************************************/
-- BEGIN: Determine M_UTC_SNAPSHOT_MIN from OUTPUT Table
/**********************************************************************************/
BEGIN TRY
  SET @SQL1 =
  N'(select @M_UTC_SNAPSHOT_MIN =  min(X.M_UTC_SNAPSHOT)
     from (select isnull(min(M_UTC_START),CAST(''01-01-1000'' as DATETIME2)) as M_UTC_SNAPSHOT
            from '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+' 
			where M_COD_SOR = '+@M_COD_SOR+'                        
            union 
           select isnull(min(dateadd(ss,1,M_UTC_END)),CAST(''01-01-1000'' as DATETIME2))  as M_UTC_SNAPSHOT
             from '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+' 
			where M_COD_SOR = '+@M_COD_SOR+'
           ) X  
  )'
  IF @DEBUG = 1 PRINT @SQL1
    EXECUTE sp_executesql @SQL1, N'@M_UTC_SNAPSHOT_MIN DATETIME2(0) OUTPUT', @M_UTC_SNAPSHOT_MIN = @M_UTC_SNAPSHOT_MIN OUTPUT
		
  IF @DEBUG = 1 PRINT '@M_UTC_SNAPSHOT_MIN: ' +cast(@M_UTC_SNAPSHOT_MIN as NVARCHAR(30))
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN
END CATCH 
/**********************************************************************************/
-- END: Determine M_UTC_SNAPSHOT_MAX from OUTPUT Table
/**********************************************************************************/


/**********************************************************************************/
-- BEGIN: Determine @SCENARIO
/**********************************************************************************/
IF @DEBUG = 1 PRINT'******* DETERMINE SCENARIO *********'
BEGIN TRY
  CREATE TABLE #UTC_START (PROCESS_NAME NVARCHAR(100), M_UTC_START DATETIME2(0))
  --Collect list of M_UTC_START dates first
  SET @SQL1 = N'insert into #UTC_START select distinct '''+@PROCESS_NAME+''', M_UTC_START FROM (select M_UTC_START 
                                from '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+' 
								where M_COD_SOR = '+@M_COD_SOR+'                             
                              union     
                             select dateadd(ss,1,M_UTC_END)
                                from '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+' 
								where M_COD_SOR = '+@M_COD_SOR+'
                                  and M_UTC_END <> ''9999-12-31 00:00:00'') resultset'

  IF @DEBUG = 1 PRINT @SQL1
    EXECUTE sp_executesql  @SQL1
  IF @DEBUG = 1 SELECT * FROM #UTC_START				
  IF @M_UTC_SNAPSHOT = convert(DATETIME2(0),'01-01-1000')
    BEGIN 
      SET @SCENARIO = UPPER('No_Snapshot')
    END
  ELSE IF @M_UTC_SNAPSHOT_MAX = convert(DATETIME2(0),'01-01-1000') 
      AND @M_UTC_SNAPSHOT_MIN = convert(DATETIME2(0),'01-01-1000') 
      AND @M_UTC_SNAPSHOT    <> convert(DATETIME2(0),'01-01-1000') 
    BEGIN 
       SET @SCENARIO = UPPER('Initial_Load')
    END  
  ELSE IF @M_UTC_SNAPSHOT_MAX <> convert(DATETIME2(0),'01-01-1000') 
      AND @M_UTC_SNAPSHOT      > @M_UTC_SNAPSHOT_MAX 
    BEGIN 
       SET @SCENARIO = UPPER('After')
    END 
  ELSE IF @M_UTC_SNAPSHOT_MIN <> convert(DATETIME2(0),'01-01-1000') 
      AND @M_UTC_SNAPSHOT < @M_UTC_SNAPSHOT_MIN 
    BEGIN 
       SET @SCENARIO = UPPER('Before') 
    END 
  ELSE IF @M_UTC_SNAPSHOT BETWEEN @M_UTC_SNAPSHOT_MIN AND @M_UTC_SNAPSHOT_MAX
    BEGIN 
      IF @M_UTC_SNAPSHOT IN (SELECT M_UTC_START FROM #UTC_START WHERE PROCESS_NAME = @PROCESS_NAME)
        BEGIN
          SET @SCENARIO = UPPER('Done')
        END
      ELSE
        BEGIN 
          SET @SCENARIO = UPPER('Between')
        END  
    END   
  ELSE 
    BEGIN
      SET @SCENARIO = UPPER('Unknown')
    END

  SET @LOG = 'Scenario: '+@SCENARIO
    EXECUTE MDAPEL.GF_1000_INSERT_LOG 
    /* PAR 1 */  @M_COD_PROCESS
    /* PAR 2 */ ,@M_COD_INSTANCE
    /* PAR 3 */ ,'INFORMATION'
    /* PAR 4 */ ,@LOG    
    
  IF @DEBUG = 1 PRINT '@SCENARIO = '+@SCENARIO
  DROP TABLE #UTC_START
END TRY

BEGIN CATCH
  SET @LOG = 'Determine scenario - ' + ERROR_MESSAGE()
  EXECUTE MDAPEL.GF_1000_INSERT_LOG 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,'ERROR'
  /* PAR 4 */ ,@LOG  
  
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE())
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE
  RETURN        
END CATCH 
/**********************************************************************************/
-- END: Determine @SCENARIO
/**********************************************************************************/

/**********************************************************************************/
/**********************************************************************************/
-- END: Specific Pre-Process
/**********************************************************************************/
/**********************************************************************************/                                  


/**********************************************************************************/
/**********************************************************************************/
-- BEGIN: Main Process
/**********************************************************************************/
/**********************************************************************************/  
IF @DEBUG = 1 PRINT'****** MAIN PROCESS *******'
/**********************************************************************************/
--BEGIN: Collect DDA and OMA columnlists
/**********************************************************************************/
BEGIN TRY
  DECLARE @DDA_COLUMNLIST VARCHAR(MAX)
  DECLARE @OMA_COLUMNLIST VARCHAR(MAX)
  
  --Collect DDA table columns, already formated in a list without Metadata columns (M_xxx)
  SET @SQL1 = N'SELECT @DDA_COLUMNLIST = (SELECT STUFF((SELECT '', '' + quotename( COLUMN_NAME , '']'') 
   			 FROM INFORMATION_SCHEMA.COLUMNS
			 WHERE TABLE_NAME = '''+@M_COD_DTI+'''
			 AND TABLE_SCHEMA = '''+@INPUT_SCHEMA+'''
			 and COLUMN_NAME NOT IN(''M_IDR''
			                       ,''M_UTC_SNAPSHOT''
			                       ,''M_COD_PROCESS''
			                       ,''M_COD_SOR''
			                       ,''M_UTC_RECORD_INSERTED''
			                       ,''M_COD_PLAUSIBLE''
			                       ,''M_CRC''
			                       ,''M_COD_KEY'' 
			                       )
			 ORDER BY ORDINAL_POSITION
			 FOR XML PATH('''')
			 ), 1, 1, '''') )'
  IF @DEBUG = 1 PRINT @SQL1
    EXECUTE sp_executesql @SQL1, N'@DDA_COLUMNLIST VARCHAR(MAX) OUTPUT', @DDA_COLUMNLIST = @DDA_COLUMNLIST OUTPUT
  IF @DEBUG = 1 PRINT @DDA_COLUMNLIST

  --Collect OMA table columns, already formated in a list without M_IDR
  SET @SQL1 = N'SELECT @OMA_COLUMNLIST = (SELECT STUFF((SELECT '', '' + quotename( COLUMN_NAME , '']'') 
			 FROM INFORMATION_SCHEMA.COLUMNS
			 WHERE TABLE_NAME = '''+@M_COD_DTI+'''
			 AND TABLE_SCHEMA = '''+@OUTPUT_SCHEMA+'''
			 AND COLUMN_NAME NOT IN( ''M_IDR'',''M_UTC_RECORD_INSERTED'')
			 ORDER BY ORDINAL_POSITION
			 FOR XML PATH('''')
			 ), 1, 1, '''') )'
  IF @DEBUG = 1 PRINT @SQL1
    EXECUTE sp_executesql @SQL1, N'@OMA_COLUMNLIST VARCHAR(MAX) OUTPUT', @OMA_COLUMNLIST = @OMA_COLUMNLIST OUTPUT
  IF @DEBUG = 1 PRINT @OMA_COLUMNLIST
END TRY

BEGIN CATCH
  SET @LOG = 'Columnlists - ' + ERROR_MESSAGE()
  EXECUTE MDAPEL.GF_1000_INSERT_LOG 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,'ERROR'
  /* PAR 4 */ ,@LOG  
  
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE())
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE
  RETURN     
END CATCH 
/**********************************************************************************/
--END: Collect DDA and OMA Columnlists
/**********************************************************************************/

/**********************************************************************************/
/* BEGIN: Scenario Initial Load.                                                  */
/**********************************************************************************/
IF @SCENARIO = 'INITIAL_LOAD'
BEGIN TRY
  IF @DEBUG = 1 PRINT '-----Scenario INITIAL_LOAD-----'
  --Create Insert statement
  SET @SQL1 = N'insert into '+@OUTPUT_SCHEMA+'.'+ @M_COD_DTI+'
  ('+@OMA_COLUMNLIST+')
  select
   M_UTC_SNAPSHOT			 as M_UTC_START
  ,CASE WHEN '+@DELETE_IND_CHAR+' = '+ @DELETE_IND_FIELD +'
	THEN M_UTC_SNAPSHOT 
	ELSE ''9999-12-31 00:00:00'' 
	END						 as M_UTC_END
  ,'+@M_COD_PROCESS+'        as M_COD_PROCESS_INSERTED
  ,NULL					     as M_COD_PROCESS_UPDATED 
  ,M_COD_SOR				 as M_COD_SOR
  ,NULL					     as M_UTC_RECORD_UPDATED
  ,M_CRC                     as M_CRC
  ,M_COD_KEY				 as M_COD_KEY
  ,'+@DDA_COLUMNLIST+'
   from '+@INPUT_SCHEMA+'.'+@M_COD_DTI+'
  where M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
    and M_COD_SOR = '+@M_COD_SOR+'
    and M_COD_PLAUSIBLE = ''P''
'
BEGIN TRAN
  IF @DEBUG =  1 PRINT @SQL1
  EXECUTE sp_executesql @SQL1, N'@M_UTC_SNAPSHOT DATETIME2(0)', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
  SET @ROWCOUNT = @@ROWCOUNT
COMMIT TRAN

/* BEGIN: delete processed records */ 
SET @SQL2 = 
N'
 delete 
   from '+@INPUT_SCHEMA+'.'+@M_COD_DTI+'
  where M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
    and M_COD_SOR = '+@M_COD_SOR+'
    and M_COD_PLAUSIBLE = ''P''
 '

IF @DEBUG =  1 PRINT @SQL2
EXECUTE sp_executesql @SQL2, N'@M_UTC_SNAPSHOT DATETIME2', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
/* END: delete processed records */
END TRY

BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
  SET @LOG = 'Initial load scenario - ' + ERROR_MESSAGE() + ' | '+ @SQL1
  EXECUTE MDAPEL.GF_1000_INSERT_LOG 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,'ERROR'
  /* PAR 4 */ ,@LOG  
  
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE())
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE  
  RETURN 55555
END CATCH
/**********************************************************************************/
/* END: Scenario Initial Load.                                                    */
/**********************************************************************************/

/**********************************************************************************/
/* BEGIN: Scenario After.                                                         */
/**********************************************************************************/
IF @SCENARIO = 'AFTER'
BEGIN TRY
-------------------------------------------------------------------------------------------------------------------------
-- is the M_COD_KEY and M_COD_SOR existent? Are the details different?
-- Subscenario Prev		Snapshot	DIFF_PREV_SNAP	CHANGE_IND  Action
-- AFTER_01    Yes		No          #				D			Update (update M_UTC_END of PREV set to M_UTC_SNAPSHOT-1) -- DELETE SCENARIO
-- AFTER_02    Yes		Yes         Yes				-			Update (update M_UTC_END of PREV set to M_UTC_SNAPSHOT-1) -- UPDATE: CLOSE OLD RECORD
-- AFTER_03    Yes      Yes         Yes				-			Insert (insert Snapshot set M_UTC_END to '9999-12-31')	  -- UPDATE: INSERT NEW RECORD
-- AFTER_04    No       Yes         #				-			Insert (Insert Snapshot set M_UTC_END to '9999-12-31')	  -- NEW
-- AFTER_05	   Yes		Yes			#				D			Insert (Insert Snapshot set M_UTC_END to M_UTC_SNAPSHOT) -- UPDATE: INSERT DELETE RECORD
-- AFTER_06	   Yes		Yes         No				-			Do Nothing
--------------------------------------------------------------------------------------------------------------------------
IF @DEBUG = 1 PRINT '-----Scenario AFTER-----'

-- BEGIN SubScenario AFTER_01 and AFTER_02:
SET @SQL1 = N'
UPDATE '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+'
   SET M_UTC_END = DATEADD(SS,-1,@M_UTC_SNAPSHOT)
      ,M_COD_PROCESS_UPDATED = '+@M_COD_PROCESS+'
      ,M_UTC_RECORD_UPDATED = GETUTCDATE()
 WHERE 1=1
 
   AND M_IDR IN (-- BEGIN AFTER_01
                 SELECT M_IDR
                   FROM (SELECT M_COD_KEY AS M_COD_KEY_SRC
                           FROM '+@INPUT_SCHEMA+'.'+@M_COD_DTI+'
                          WHERE 1=1
                            AND M_COD_PLAUSIBLE = ''P''
                            AND M_COD_SOR       = '+@M_COD_SOR+'
                            AND M_UTC_SNAPSHOT  = @M_UTC_SNAPSHOT  
							AND '+@DELETE_IND_FIELD+' = '+@DELETE_IND_CHAR+'               
                        ) SRC
                        INNER JOIN
                        (SELECT M_IDR
                               ,M_COD_KEY AS M_COD_KEY_TRG
                           FROM '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+'
                          WHERE 1=1
                            AND M_COD_SOR       = '+@M_COD_SOR+'
                            AND @M_UTC_SNAPSHOT BETWEEN M_UTC_START AND M_UTC_END
                        ) TRG
                        ON  SRC.M_COD_KEY_SRC = TRG.M_COD_KEY_TRG  
                 -- END AFTER_01
				 			      
                 UNION -- Sorted and Deduplicated
                 -- BEGIN AFTER_02       
                 SELECT M_IDR
                   FROM (SELECT M_COD_KEY AS M_COD_KEY_SRC
                               ,M_CRC     AS M_CRC_SRC
                           FROM '+@INPUT_SCHEMA+'.'+@M_COD_DTI+'
                          WHERE 1=1
                            AND M_COD_PLAUSIBLE = ''P''
                            AND M_COD_SOR       = '+@M_COD_SOR+'
                            AND M_UTC_SNAPSHOT  = @M_UTC_SNAPSHOT                   
                        ) SRC
                        FULL OUTER JOIN
                        (SELECT M_IDR
                               ,M_COD_KEY AS M_COD_KEY_TRG
                               ,M_CRC     AS M_CRC_TRG
                           FROM '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+'
                          WHERE 1=1
                            AND M_COD_SOR       = '+@M_COD_SOR+'
                            AND @M_UTC_SNAPSHOT BETWEEN M_UTC_START AND M_UTC_END
                        ) TRG
                        ON  SRC.M_COD_KEY_SRC = TRG.M_COD_KEY_TRG
                        WHERE 1=1
                          AND M_IDR IS NOT NULL  
                          AND SRC.M_CRC_SRC    <> TRG.M_CRC_TRG 
                 -- END AFTER_02  
                  )
'
IF @DEBUG = 1 PRINT @SQL1
BEGIN TRAN
	EXECUTE sp_executesql @SQL1, N'@M_UTC_SNAPSHOT DATETIME2', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
	SET @ROWCOUNT = @@ROWCOUNT
	IF @ROWCOUNT = 0 SET @ROWCOUNT = @ROWCOUNT_P
	SET @ROWCOUNT_P = @ROWCOUNT
COMMIT TRAN
IF @DEBUG =  1 SELECT @ROWCOUNT ROW_COUNT
-- END SubScenario AFTER_01 and AFTER_02:

-- BEGIN SubScenario AFTER_03 and AFTER_04:
IF @DEBUG = 1 print @DDA_COLUMNLIST 
SET @SQL1 = N'
INSERT INTO '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+'
(M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
,M_COD_SOR
,M_CRC
,M_COD_KEY
,'+@DDA_COLUMNLIST+'
)
SELECT 
 M_UTC_SNAPSHOT                AS M_UTC_START
,''9999-12-31 00:00:00''       AS M_UTC_END
,'+@M_COD_PROCESS+'            AS M_COD_PROCESS_INSERTED
,M_COD_SOR                     AS M_COD_SOR
,M_CRC
,M_COD_KEY
,'+@DDA_COLUMNLIST+' 
  FROM '+@INPUT_SCHEMA+'.'+@M_COD_DTI+' SRC
 WHERE 1=1
   AND M_COD_PLAUSIBLE = ''P''
   AND M_COD_SOR = '+@M_COD_SOR+'
   AND M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
   AND '+@DELETE_IND_FIELD+' <> '+@DELETE_IND_CHAR+' 
   AND NOT EXISTS (SELECT M_IDR
                     FROM '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+' TRG
                    WHERE 1=1
                      AND TRG.M_COD_SOR = SRC.M_COD_SOR
                      AND TRG.M_COD_KEY = SRC.M_COD_KEY
					  AND '+@DELETE_IND_FIELD+' <> '+@DELETE_IND_CHAR+' 
                      AND SRC.M_UTC_SNAPSHOT BETWEEN TRG.M_UTC_START AND TRG.M_UTC_END
                  ) 
'
IF @DEBUG = 1 PRINT @SQL1
BEGIN TRAN
	EXECUTE sp_executesql @SQL1, N'@M_UTC_SNAPSHOT DATETIME2(0)', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
	SET @ROWCOUNT = @@ROWCOUNT
	IF @ROWCOUNT = 0 SET @ROWCOUNT = @ROWCOUNT_P
	SET @ROWCOUNT_P = @ROWCOUNT
COMMIT TRAN
IF @DEBUG =  1 SELECT @ROWCOUNT ROW_COUNT
-- END SubScenario AFTER_03 and AFTER_04:


-- BEGIN SubScenario AFTER_05:
IF @DEBUG=1 print @DDA_COLUMNLIST 
SET @SQL1 = N'
INSERT INTO '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+'
(M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
,M_COD_SOR
,M_CRC
,M_COD_KEY
,'+@DDA_COLUMNLIST+'
)
SELECT 
 M_UTC_SNAPSHOT                AS M_UTC_START
,M_UTC_SNAPSHOT                AS M_UTC_END
,'+@M_COD_PROCESS+'            AS M_COD_PROCESS_INSERTED
,M_COD_SOR                     AS M_COD_SOR
,M_CRC
,M_COD_KEY
,'+@DDA_COLUMNLIST+' 
  FROM '+@INPUT_SCHEMA+'.'+@M_COD_DTI+' SRC
 WHERE 1=1
   AND M_COD_PLAUSIBLE = ''P''
   AND M_COD_SOR = '+@M_COD_SOR+'
   AND M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
   AND '+@DELETE_IND_FIELD+' = '+@DELETE_IND_CHAR+' 
   AND NOT EXISTS (SELECT M_IDR
                     FROM '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+' TRG
                    WHERE 1=1
                      AND TRG.M_COD_SOR = SRC.M_COD_SOR
                      AND TRG.M_COD_KEY = SRC.M_COD_KEY
					  AND '+@DELETE_IND_FIELD+' = '+@DELETE_IND_CHAR+' 
                      AND SRC.M_UTC_SNAPSHOT BETWEEN TRG.M_UTC_START AND TRG.M_UTC_END
                  ) 
'
IF @DEBUG = 1 PRINT @SQL1
BEGIN TRAN
	EXECUTE sp_executesql @SQL1, N'@M_UTC_SNAPSHOT DATETIME2(0)', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
	SET @ROWCOUNT = @@ROWCOUNT
	IF @ROWCOUNT = 0 SET @ROWCOUNT = @ROWCOUNT_P
	SET @ROWCOUNT_P = @ROWCOUNT
COMMIT TRAN
IF @DEBUG =  1 SELECT @ROWCOUNT ROW_COUNT
-- END SubScenario AFTER_05


/* BEGIN: delete processed records */ 
SET @SQL2 = N'
delete 
  from '+@INPUT_SCHEMA+'.'+@M_COD_DTI+'
 where M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
   and M_COD_SOR = '+@M_COD_SOR+'
   and M_COD_PLAUSIBLE = ''P''
'
IF @DEBUG =  1 PRINT @SQL2
EXECUTE sp_executesql @SQL2, N'@M_UTC_SNAPSHOT DATETIME2', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
/* END: delete processed records */
END TRY

BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
  SET @LOG = 'After scenario 2 - ' + ERROR_MESSAGE() + ' | '+ @SQL1		
  EXECUTE MDAPEL.GF_1000_INSERT_LOG 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,'ERROR'
  /* PAR 4 */ ,@LOG  
  
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE())
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE 			
  RETURN 55555
END CATCH
/**********************************************************************************/
/* END: Scenario After.                                                           */
/**********************************************************************************/

/**********************************************************************************/
/* BEGIN: Scenario Before.                                                        */
/**********************************************************************************/
IF @SCENARIO = 'BEFORE'
BEGIN TRY
/*
is the M_COD_KEY and M_COD_SOR existent? Are the details different?
Subscenario Snapshot	Next		DIFF_SNAP_NEXT	Action
A1			Yes			Yes			No				Update (M_UTC_START of NEXT set to M_UTC_SNAPSHOT)
A2			Yes			Yes			Yes				Insert (Insert Snapshot set M_UTC_END to M_UTC_START-1)
B1			Yes			No			#				Insert (Insert Snapshot set M_UTC_END to '9999-12-31 00:00:00')
C1			No			Yes			#				Do Nothing
*/  

IF @DEBUG = 1 PRINT '-----Scenario BEFORE-----'


-- A1: New record, identical CRC (update)
SET @SQL1 = N'
UPDATE TRG
   SET M_UTC_START = SRC.M_UTC_SNAPSHOT
      ,M_COD_PROCESS_UPDATED = '+@M_COD_PROCESS+'
      ,M_UTC_RECORD_UPDATED = GETUTCDATE()
 	FROM '+@INPUT_SCHEMA+'.'+@M_COD_DTI+' SRC
		INNER JOIN '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+' TRG
		ON  TRG.M_COD_KEY = SRC.M_COD_KEY
		AND TRG.M_COD_SOR = SRC.M_COD_SOR
		AND TRG.M_CRC     = SRC.M_CRC
		AND TRG.M_UTC_START = (SELECT MIN(M_UTC_START)
					FROM '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+' TRG
					WHERE 1=1
					AND TRG.M_COD_KEY = SRC.M_COD_KEY
					AND TRG.M_COD_SOR = SRC.M_COD_SOR
					AND TRG.M_UTC_START > SRC.M_UTC_SNAPSHOT
					)
	WHERE 1=1
	AND M_COD_PLAUSIBLE = ''P''
	AND SRC.M_COD_SOR =  '+@M_COD_SOR+'
	AND M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
'

IF @DEBUG = 1 PRINT @SQL1
BEGIN TRAN
	EXECUTE sp_executesql @SQL1, N'@M_UTC_SNAPSHOT DATETIME2(0)', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
	SET @ROWCOUNT = @@ROWCOUNT
	IF @ROWCOUNT = 0 SET @ROWCOUNT = @ROWCOUNT_P
	SET @ROWCOUNT_P = @ROWCOUNT
COMMIT TRAN
IF @DEBUG =  1 SELECT @ROWCOUNT ROW_COUNT


-- A2: New record, different CRC (insert)
SET @SQL1 = N'
INSERT INTO '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+'
(M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
,M_COD_SOR
,M_CRC
,M_COD_KEY
,'+@DDA_COLUMNLIST+'
)
SELECT 
  SRC.M_COD_KEY
, SRC.M_UTC_SNAPSHOT AS M_UTC_START
, SRC.M_CRC
, SRC.M_COD_SOR
, DATEADD(SS,-1,TRG.M_UTC_START) AS M_UTC_END
, '+@M_COD_PROCESS+' AS M_COD_PROCESS_INSERTED

FROM '+@INPUT_SCHEMA+'.'+@M_COD_DTI+' SRC
	INNER JOIN '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+' TRG
	ON  TRG.M_COD_KEY = SRC.M_COD_KEY
	AND TRG.M_COD_SOR = SRC.M_COD_SOR
	AND TRG.M_CRC    <> SRC.M_CRC
	AND TRG.M_UTC_START = (SELECT MIN(M_UTC_START)
				FROM '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+' TRG
				WHERE 1=1
				AND TRG.M_COD_KEY = SRC.M_COD_KEY
				AND TRG.M_COD_SOR = SRC.M_COD_SOR
				AND TRG.M_UTC_START > SRC.M_UTC_SNAPSHOT
				)
WHERE 1=1
AND M_COD_PLAUSIBLE = ''P''
AND SRC.M_COD_SOR = '+@M_COD_SOR+'
AND M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
'

IF @DEBUG = 1 PRINT @SQL1
BEGIN TRAN
	EXECUTE sp_executesql @SQL1, N'@M_UTC_SNAPSHOT DATETIME2(0)', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
	SET @ROWCOUNT = @@ROWCOUNT
	IF @ROWCOUNT = 0 SET @ROWCOUNT = @ROWCOUNT_P
	SET @ROWCOUNT_P = @ROWCOUNT
COMMIT TRAN
IF @DEBUG =  1 SELECT @ROWCOUNT ROW_COUNT

-- B1: New record, no previous record (insert)
SET @SQL1 =N'
SELECT 
  SRC.M_COD_KEY
, SRC.M_UTC_SNAPSHOT AS M_UTC_START
, SRC.M_CRC
, SRC.M_COD_SOR
, ''9999-12-31 00:00:00'' AS M_UTC_END

FROM '+@INPUT_SCHEMA+'.'+@M_COD_DTI+' SRC
WHERE 1=1
	AND NOT EXISTS (SELECT M_IDR
				FROM '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+' TRG
				WHERE 1=1
				AND TRG.M_COD_KEY = SRC.M_COD_KEY
				AND TRG.M_COD_SOR = SRC.M_COD_SOR
				AND TRG.M_UTC_START > SRC.M_UTC_SNAPSHOT
				)
	AND M_COD_PLAUSIBLE = ''P''
	AND SRC.M_COD_SOR = '+@M_COD_SOR+'
	AND M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
'

IF @DEBUG = 1 PRINT @SQL1
BEGIN TRAN
	EXECUTE sp_executesql @SQL1, N'@M_UTC_SNAPSHOT DATETIME2(0)', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
	SET @ROWCOUNT = @@ROWCOUNT
	IF @ROWCOUNT = 0 SET @ROWCOUNT = @ROWCOUNT_P
	SET @ROWCOUNT_P = @ROWCOUNT
COMMIT TRAN
IF @DEBUG =  1 SELECT @ROWCOUNT ROW_COUNT

/* BEGIN: delete processed records */ 
SET @SQL2 = 
N'
 delete 
   from '+@INPUT_SCHEMA+'.'+@M_COD_DTI+'
  where M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
    and M_COD_SOR = '+@M_COD_SOR+'
    and M_COD_PLAUSIBLE = ''P''
 '

IF @DEBUG =  1 PRINT @SQL2
EXECUTE sp_executesql @SQL2, N'@M_UTC_SNAPSHOT DATETIME2', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
/* END: delete processed records */
END TRY

BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
  SET @LOG = 'Before load scenario - ' + ERROR_MESSAGE() + ' | '+ @SQL1
  EXECUTE MDAPEL.GF_1000_INSERT_LOG 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,'ERROR'
  /* PAR 4 */ ,@LOG  
  
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE())
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE  
  RETURN 55555
END CATCH
/**********************************************************************************/
/* END: Scenario BEFORE Load.                                                    */
/**********************************************************************************/


/**********************************************************************************/
/* BEGIN: Scenario BETWEEN Load.                                                  */
/**********************************************************************************/
IF @SCENARIO = 'BETWEEN'
BEGIN TRY
  IF @DEBUG = 1 PRINT '-----Scenario BETWEEN-----'
-- BETWEEN STATEMENTS TBD!?
--  --Create Insert statement
--  SET @SQL1 = N'insert into '+@OUTPUT_SCHEMA+'.'+ @M_COD_DTI+'
--  ('+@OMA_COLUMNLIST+')
--  select
--   M_UTC_SNAPSHOT			 as M_UTC_START
--  ,''9999-12-31 00:00:00''   as M_UTC_END
--  ,'+@M_COD_PROCESS+'        as M_COD_PROCESS_INSERTED
--  ,NULL					     as M_COD_PROCESS_UPDATED 
--  ,M_COD_SOR				 as M_COD_SOR
--  ,NULL					     as M_UTC_RECORD_UPDATED
--  ,M_CRC                     as M_CRC
--  ,M_COD_KEY				 as M_COD_KEY
--  ,'+@DDA_COLUMNLIST+'
--   from '+@INPUT_SCHEMA+'.'+@M_COD_DTI+'
--  where M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
--    and M_COD_SOR = '+@M_COD_SOR+'
--    and M_COD_PLAUSIBLE = ''P''
--'
--BEGIN TRAN
--  IF @DEBUG =  1 PRINT @SQL1
--  EXECUTE sp_executesql @SQL1, N'@M_UTC_SNAPSHOT DATETIME2(0)', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
--  SET @ROWCOUNT = @@ROWCOUNT
--COMMIT TRAN

/* BEGIN: delete processed records */ 
SET @SQL2 = 
N'
 delete 
   from '+@INPUT_SCHEMA+'.'+@M_COD_DTI+'
  where M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
    and M_COD_SOR = '+@M_COD_SOR+'
    and M_COD_PLAUSIBLE = ''P''
 '

IF @DEBUG =  1 PRINT @SQL2
EXECUTE sp_executesql @SQL2, N'@M_UTC_SNAPSHOT DATETIME2', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
/* END: delete processed records */
END TRY

BEGIN CATCH
  IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
  SET @LOG = 'Between load scenario - ' + ERROR_MESSAGE() + ' | '+ @SQL1
  EXECUTE MDAPEL.GF_1000_INSERT_LOG 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,'ERROR'
  /* PAR 4 */ ,@LOG  
  
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE())
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE  
  RETURN 55555
END CATCH
/**********************************************************************************/
/* END: Scenario BETWEEN Load.                                                    */
/**********************************************************************************/

/**********************************************************************************/
/* BEGIN: Scenario Done   .                                                       */
/**********************************************************************************/
IF @DEBUG = 1 PRINT'********** DONE **********'
IF @SCENARIO = 'DONE'
BEGIN TRY
  IF @DEBUG = 1 print 'Moet nog uitgewerkt worden.'
  SET @SQL1 = N'update '+@INPUT_SCHEMA+'.'+CONVERT(NVARCHAR,@M_COD_DTI)+'
   set M_COD_PLAUSIBLE = ''D'' -- Done scenario, administrator should decide manually. 
 where 1=1
   and M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
   and M_COD_SOR = '+@M_COD_SOR+'    
   and M_COD_PLAUSIBLE = ''P'''


IF @DEBUG =  1 PRINT @SQL1
EXECUTE sp_executesql @SQL1, N'@M_UTC_SNAPSHOT DATETIME2', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT  

END TRY

BEGIN CATCH
  SET @LOG = 'Done scnario - ' + ERROR_MESSAGE() + ' | '+ @SQL1
  EXECUTE MDAPEL.GF_1000_INSERT_LOG 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,'ERROR'
  /* PAR 4 */ ,@LOG  
  
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE
  RETURN 55555  
END CATCH
  
/* BEGIN: delete processed records */ 
--no delete
/* END: delete processed records */
/**********************************************************************************/
/* END: Scenario Done.                                                            */
/**********************************************************************************/

/**********************************************************************************/
/* BEGIN: Scenario Unknown.                                                       */
/**********************************************************************************/
IF @SCENARIO = 'UNKNOWN'
BEGIN
  print 'Scenario Unknown Moet nog uitgewerkt worden.'
END
/**********************************************************************************/
/* END: Scenario Unknown.                                                         */
/**********************************************************************************/

/**********************************************************************************/
/**********************************************************************************/
-- END: Main Process
/**********************************************************************************/
/**********************************************************************************/   


/**********************************************************************************/
/**********************************************************************************/
-- BEGIN: Specific Post Process
/**********************************************************************************/
/**********************************************************************************/    
          

/* BEGIN: Generic PostProcess */
BEGIN TRY

--Close process instance logging, including number of records processed
SET @LOG = 'Records processed: ' +CAST(ISNULL(@ROWCOUNT,0) as VARCHAR(20))

IF @DEBUG = 1 SELECT @LOG
  EXECUTE MDAPEL.GF_1000_INSERT_LOG 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,'INFORMATION'
  /* PAR 4 */ ,@LOG 
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE
  RETURN
END CATCH

/* END: Generic PostProcess */
/**********************************************************************************/
/**********************************************************************************/
-- END: Specific Post Process
/**********************************************************************************/
/**********************************************************************************/
IF @@TRANCOUNT > 0 COMMIT TRANSACTION
END TRY -- A

BEGIN CATCH -- A
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE())
  IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE	
  RETURN 55555
END CATCH --- A

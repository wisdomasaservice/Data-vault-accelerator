/*USE [DWHPRD]*/
GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0204_OMADIA_EVENT]    Script Date: 2/19/2014 1:20:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0204_OMADIA_EVENT] 
	  @TABLE nvarchar(max)
	, @M_COD_PROCESS varchar(10) = 999999 
	,  @M_COD_INSTANCE				bigint =0
	, @DEBUG bit = 0
AS
-- ===================== Version Control ============================

-- Author:		D.Kleijbeuker
-- Create date: 2011
-- Description:	EMADIA Transaction upsert process
--
-- Version 2011-09-09 : DK - First draft version
-- Version 2012-03-28 : DK - changed the M_COD_SOR selection to MAX (only 1 result can be processed at one time)
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.

-- ===================== Version Control ============================
---------------------------------------------------------------------
-- BEGIN: Remarks
---------------------------------------------------------------------
-- process is started with input tablename (DDADTI)
---------------------------------------------------------------------
-- END: Remarks
---------------------------------------------------------------------
BEGIN TRY-- A
IF @DEBUG = 0 SET NOCOUNT ON
/* BEGIN: Generic PreProcess */
-- None
/* END: Generic PreProcess */

/* BEGIN: Initialize Process Parameters */
declare @PROCESS_NAME				varchar(max)	='PROCESS_'+@TABLE  --Actually instance name
declare @INPUT_SCHEMA				varchar(200)	='DDADTI'
declare @OUTPUT_SCHEMA				varchar(200)	='OMADIA'
declare @UTC_INSTANCE_START			datetime2		= GETUTCDATE()
declare @GF_PROCESS_NAME			varchar(200)	='GF_0204_OMADIA_EVENT'
/* END: Initialize Process Parameters */

/* BEGIN: Declare parameters */
DECLARE @DDA_COLUMNLIST				varchar(max)
DECLARE @EMA_COLUMNLIST				varchar(max)
declare @DDA_EMA_COLUMNLIST			varchar(max)
declare @DDA_HASH_COLUMNLIST		varchar(max)
declare @M_COD_SOR					varchar(8)
declare @SQL1						nvarchar(max)
declare @SQL2						nvarchar(max)
declare @SQL_VARCHAR				varchar(max)
declare @M_UTC_SNAPSHOT				datetime2
DECLARE @M_UTC_START				datetime2
DECLARE @LOG						NVARCHAR(MAX)
declare @ROWCOUNT					int
declare @ROWCOUNT_P					int
DECLARE @M_ERROR_MESSAGE            NVARCHAR(4000)
/* END: Declare parameters */

/**********************************************************************************/
-- BEGIN: Write log message
/**********************************************************************************/
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'GF_0204_OMADIA_EVENT is called'

/**********************************************************************************/
-- END: Write log message
/**********************************************************************************/


/*BEGIN: Collect M_COD_SOR from source (EMADIA) table */

BEGIN TRY

SET @SQL1 = N'SELECT @M_COD_SOR = (SELECT MAX (M_COD_SOR) FROM '+@INPUT_SCHEMA+'.'+ @TABLE+')'

EXEC sp_executesql @SQL1, N'@M_COD_SOR varchar(8) OUTPUT', @M_COD_SOR = @M_COD_SOR OUTPUT
IF @DEBUG = 1 PRINT 'M_COD_SOR: ' +(@M_COD_SOR)

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

/* END: Collect M_COD_SOR from source (EMADIA) table */


/**********************************************************************************/
/**********************************************************************************/
-- BEGIN: Specific Pre-Process
/**********************************************************************************/
/**********************************************************************************/

IF @DEBUG = 1 PRINT'******** SPECIFIC PRE-PROCESS ********'

/**********************************************************************************/
-- BEGIN: Determine number of DDADTI records
/**********************************************************************************/

BEGIN TRY

SET @SQL1 = N'SELECT @LOG = COUNT(1) FROM '+@INPUT_SCHEMA+'.'+@TABLE
EXEC sp_executesql @SQL1, N'@LOG nvarchar(max) OUTPUT', @LOG = @LOG OUTPUT

SET @LOG = 'DDADTI Records: ' +@LOG

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
-- BEGIN: Determine M_UTC_SNAPSHOT to process from DDADTI
/**********************************************************************************/
-- If there are more than 1 DTID's the oldest will be processed.
BEGIN TRY
		SET @SQL1 = N'select @M_UTC_SNAPSHOT = isnull(min(M_UTC_SNAPSHOT), CAST(''01-01-1000'' as datetime2))
					from '+@INPUT_SCHEMA+'.'+@TABLE+' 
					where M_COD_SOR = ('+ @M_COD_SOR + ') 
		 			and M_COD_PLAUSIBLE = ''P'''
		IF @DEBUG = 1 PRINT @SQL1
		EXEC sp_executesql @SQL1, N'@M_UTC_SNAPSHOT DATETIME2 OUTPUT', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT OUTPUT
		
		IF @DEBUG = 1 PRINT '@M_UTC_SNAPSHOT: ' +cast(@M_UTC_SNAPSHOT as nvarchar(30))
		
		SET @LOG = '@M_UTC_SNAPSHOT: ' + ISNULL(cast(@M_UTC_SNAPSHOT as nvarchar(30)), 'No Snapshot')
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
/**********************************************************************************/
-- END: Specific Pre-Process
/**********************************************************************************/
/**********************************************************************************/ 


-- ===================================================================================================================

-- BEGIN: Main Process

-- ===================================================================================================================


IF @DEBUG = 1 PRINT'****** MAIN PROCESS *******'

/**********************************************************************************/
--BEGIN: Collect DDA and EMA columnlists
/**********************************************************************************/
BEGIN TRY

--Collect DDA table columns, already formated in a list without Metadata columns (M_xxx)
SET @SQL1 = N'SELECT @DDA_COLUMNLIST = (SELECT STUFF((SELECT '', '' +''DDA.'' + quotename( COLUMN_NAME , '']'') 
			 FROM INFORMATION_SCHEMA.COLUMNS
			 WHERE TABLE_NAME = '''+@TABLE+'''
			 AND TABLE_SCHEMA = '''+@INPUT_SCHEMA+'''
			 and COLUMN_NAME NOT IN(''M_IDR'',''M_UTC_SNAPSHOT'',''M_COD_PROCESS'',''M_COD_SOR'',''M_UTC_RECORD_INSERTED'', ''M_COD_PLAUSIBLE'', ''M_COD_KEY'', ''M_CRC'' )
			 ORDER BY ORDINAL_POSITION
			 FOR XML PATH('''')
			 ), 1, 1, '''') )'
IF @DEBUG = 1 PRINT @SQL1
EXEC sp_executesql @SQL1, N'@DDA_COLUMNLIST nvarchar(max) OUTPUT', @DDA_COLUMNLIST = @DDA_COLUMNLIST OUTPUT
IF @DEBUG = 1 PRINT @DDA_COLUMNLIST

--Collect EMA table columns, already formated in a list without M_IDR
SET @SQL1 = N'SELECT @EMA_COLUMNLIST = (SELECT STUFF((SELECT '', '' + quotename( COLUMN_NAME , '']'') 
			 FROM INFORMATION_SCHEMA.COLUMNS
			 WHERE TABLE_NAME = '''+@TABLE+'''
			 AND TABLE_SCHEMA = '''+@OUTPUT_SCHEMA+'''
			 AND COLUMN_NAME NOT IN( ''M_IDR'')
			 ORDER BY ORDINAL_POSITION
			 FOR XML PATH('''')
			 ), 1, 1, '''') )'
IF @DEBUG = 1 PRINT @SQL1
EXEC sp_executesql @SQL1, N'@EMA_COLUMNLIST nvarchar(max) OUTPUT', @EMA_COLUMNLIST = @EMA_COLUMNLIST OUTPUT
IF @DEBUG = 1 PRINT @EMA_COLUMNLIST

--Collect DDA to EMA mapping columns, already formated in a list without Metadata fields (necessary for update statement)
SET @SQL1 = N'SELECT @DDA_EMA_COLUMNLIST = (SELECT STUFF((SELECT '', '' +''EMA.'' + quotename( COLUMN_NAME , '']'') +'' = '' +''DDA.''+ quotename( COLUMN_NAME , '']'')
			 FROM INFORMATION_SCHEMA.COLUMNS
			 WHERE TABLE_NAME = '''+@TABLE+'''
			 AND TABLE_SCHEMA = '''+@OUTPUT_SCHEMA+'''
			 and COLUMN_NAME NOT IN(''M_IDR'',''M_UTC_SNAPSHOT'',''M_COD_PROCESS'',''M_COD_SOR'',''M_UTC_RECORD_INSERTED'', ''M_UTC_RECORD_UPDATED'' , ''M_COD_PROCESS_INSERTED'',''M_CRC'' ,''M_COD_PROCESS_UPDATED'', ''M_COD_PLAUSIBLE'', ''M_COD_KEY'' )
			 ORDER BY ORDINAL_POSITION
			 FOR XML PATH('''')
			 ), 1, 1, '''') )'
IF @DEBUG = 1 PRINT @SQL1
EXEC sp_executesql @SQL1, N'@DDA_EMA_COLUMNLIST nvarchar(max) OUTPUT', @DDA_EMA_COLUMNLIST = @DDA_EMA_COLUMNLIST OUTPUT
IF @DEBUG = 1 PRINT @DDA_EMA_COLUMNLIST

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
--END: Collect DDA and EMA Columnlists
/**********************************************************************************/


/**********************************************************************************/
/* BEGIN: Data processing (MERGE statement)                                       */
/**********************************************************************************/
BEGIN TRY
IF @DEBUG = 1 PRINT '---------- START MERGE -----------'

DECLARE @M_UTC_SNAPSHOT_VAR varchar(40) = convert(varchar(40), @M_UTC_SNAPSHOT)
IF @DEBUG = 1 print @M_UTC_SNAPSHOT_VAR

CREATE TABLE #ROWS (MergeAction varchar(10))

SET @SQL_VARCHAR = '
INSERT INTO #ROWS
SELECT MergeAction FROM (
MERGE  '+@OUTPUT_SCHEMA+'.'+@TABLE+' as EMA
USING (SELECT * FROM '+@INPUT_SCHEMA+'.'+@TABLE+' WHERE M_UTC_SNAPSHOT = '''+@M_UTC_SNAPSHOT_VAR+''')as DDA -- Process only the current snapshot (merge cannot process multiple snapshots)
   ON EMA.M_COD_KEY = DDA.M_COD_KEY
  AND EMA.M_COD_SOR = DDA.M_COD_SOR 
 WHEN MATCHED
  AND (EMA.M_CRC <> DDA.M_CRC)
  THEN UPDATE SET
          EMA.M_UTC_SNAPSHOT = '''+@M_UTC_SNAPSHOT_VAR+'''
        , EMA.[M_COD_PROCESS_UPDATED] = ('+@M_COD_PROCESS+')
        , EMA.[M_UTC_RECORD_UPDATED] = GETUTCDATE()
        , EMA.[M_CRC] = DDA.M_CRC
        , '+@DDA_EMA_COLUMNLIST+'
 WHEN NOT MATCHED BY TARGET THEN
  INSERT 
			('+@EMA_COLUMNLIST+')
  VALUES
			( '''+@M_UTC_SNAPSHOT_VAR+'''			
			, ('+@M_COD_PROCESS+')					
			, NULL						
			, M_COD_SOR					
			, GETUTCDATE()				
			, NULL					
			, M_COD_KEY
			, DDA.M_CRC
			, '+@DDA_COLUMNLIST+')
 OUTPUT $action as MergeAction) MergeResult;'
 
IF @DEBUG = 1 PRINT @SQL_VARCHAR
IF @DEBUG = 1 PRINT '@SQL1 lenght = ' + convert(varchar(10),LEN(@SQL_VARCHAR))

BEGIN TRAN
	EXEC(@SQL_VARCHAR)
COMMIT TRAN

IF @DEBUG = 1 SELECT ISNULL(MergeAction,'No records processed') MergeAction, COUNT(1) NmbrOfRec  FROM #ROWS GROUP BY MergeAction

-- LOGGING : Insert MergeActions including recordcounts into logging tables.
		
		IF (SELECT COUNT(1) FROM #ROWS) > 0 --is 0 when there are no Merge actions, then cursor remains empty
		BEGIN
			DECLARE @MergeAction varchar(30)
			DECLARE @NmbrOfRec int
			DECLARE Action_cur CURSOR FOR
				SELECT ISNULL(MergeAction,'No records processed') MergeAction, COUNT(1) NmbrOfRec  
				FROM #ROWS GROUP BY MergeAction

			OPEN Action_cur

			FETCH NEXT FROM Action_Cur INTO @MergeAction, @NmbrOfRec
			WHILE @@fetch_status = 0
			BEGIN			
				SET @LOG = @MergeAction +' Records processed: ' +CAST(ISNULL(@NmbrOfRec,0) as varchar(20))
				EXECUTE MDAPEL.GF_1000_INSERT_LOG 
						/* PAR 1 */  @M_COD_PROCESS
						/* PAR 2 */ ,@M_COD_INSTANCE
						/* PAR 3 */ ,'INFORMATION'
						/* PAR 4 */ ,@LOG

				FETCH NEXT FROM Action_cur INTO @MergeAction, @NmbrOfRec
			END
			CLOSE Action_cur
			DEALLOCATE Action_cur
		END
		
		ELSE
			EXECUTE MDAPEL.GF_1000_INSERT_LOG 
						/* PAR 1 */  @M_COD_PROCESS
						/* PAR 2 */ ,@M_COD_INSTANCE
						/* PAR 3 */ ,'INFORMATION'
						/* PAR 4 */ , 'No Merge Action'


/* BEGIN: delete processed records */ 
SET @SQL2 = N'delete 
 from '+@INPUT_SCHEMA+'.'+@TABLE+'
 where M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
   and M_COD_SOR = ('+@M_COD_SOR+')
   and M_COD_PLAUSIBLE = ''P'''

IF @DEBUG =  1 PRINT @SQL2
EXEC sp_executesql @SQL2, N'@M_UTC_SNAPSHOT datetime2', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
/* END: delete processed records */

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
/* END: Data processing (MERGE statement)                                         */
/**********************************************************************************/


-- ================================================================================================================

-- END: Main Process

-- ================================================================================================================


/**********************************************************************************/
/**********************************************************************************/
-- BEGIN: Specific Post Process
/**********************************************************************************/
/**********************************************************************************/    
          
/* BEGIN: Generic PostProcess */


/* END: Generic PostProcess */
/**********************************************************************************/
/**********************************************************************************/
-- END: Specific Post Process
/**********************************************************************************/
/**********************************************************************************/


END TRY
BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE())
  IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE	
	RETURN 55555
END CATCH


/****** Object:  StoredProcedure [MDAPEL].[GF_1000_INSERT_LOG]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_1000_INSERT_LOG]
 @M_COD_PROCESS  BIGINT
,@M_COD_INSTANCE BIGINT
,@M_COD_LOG_TYPE NVARCHAR(20)
,@M_TXT_LOG      NVARCHAR(4000)
----------------------------------------------------------------------------------
-- Author         : Michael Doves
-- Author Contact : michael.doves@dikw.com
-- Version        : 1
-- Creation Date  : 2012-06-08
-- Version Date   : 2012-06-08
-- Description    : Insert into logging table: MDAPEL.LOG
-- Modification   : 2012-06-08 Version 1: Initial Code
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
----------------------------------------------------------------------------------	
AS
BEGIN -- PROCEDURE

BEGIN TRY
  INSERT INTO [MDAPEL].[LOG] 
  (COD_PROCESS
  ,COD_INSTANCE
  ,COD_LOG_TYPE
  ,TXT_LOG
  )
  VALUES 
  (@M_COD_PROCESS
  ,@M_COD_INSTANCE
  ,@M_COD_LOG_TYPE
  ,@M_TXT_LOG
  )
END TRY

BEGIN CATCH
		SELECT ERROR_MESSAGE()
        RETURN
END CATCH 

END -- PROCEDURE

/****** Object:  StoredProcedure [MDAPEL].[GF_9999_GENERIC_ERROR_HANDLING]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_9999_GENERIC_ERROR_HANDLING]
 @M_COD_PROCESS     BIGINT
,@M_COD_INSTANCE    BIGINT 
,@M_ERROR_MESSAGE   NVARCHAR(4000)
----------------------------------------------------------------------------------
-- Author         : Michael Doves
-- Author Contact : michael.doves@dikw.com
-- Version        : 1
-- Creation Date  : 2012-06-08
-- Version Date   : 2012-06-08
-- Description    : Generic Error handling of an instance of a process.
-- Modification   : 2012-06-08 Version 1: Initial Code
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
----------------------------------------------------------------------------------
-- Example call: 'EXECUTE GF_9999_GENERIC_ERROR_HANDLING @M_COD_PROCESS,@M_COD_INSTANCE,@ERROR_MESSAGE'
AS
BEGIN TRY
  -- BEGIN STEP 0: DETERMINE UTCDATE
  DECLARE @M_UTC DATETIME2(7) = (SELECT GETUTCDATE())
  -- END   STEP 0: DETERMINE UTCDATE
  

  -- BEGIN: STEP 1 INSERT LOG with error message
  EXECUTE MDAPEL.GF_1000_INSERT_LOG
   @M_COD_PROCESS
  ,@M_COD_INSTANCE
  ,'ERROR'
  ,@M_ERROR_MESSAGE
  -- END: STEP 1 INSERT LOG with error message

  -- BEGIN: STEP 2 Update Instance Status 
  UPDATE MDAPEL.INSTANCE
     SET UTC_INSTANCE_END      = @M_UTC
        ,COD_INSTANCE_STATUS   = 'ERROR'
        ,TIM_DURATION_INSTANCE = DATEDIFF(SS,UTC_INSTANCE_START,@M_UTC)
   WHERE COD_INSTANCE = @M_COD_INSTANCE				
  --   END: STEP 2 Update Instance Status 
END TRY

-- BEGIN: STEP 99 ERROR HANDLING
BEGIN CATCH
  SELECT ERROR_MESSAGE()
  RETURN
END CATCH
-- END: STEP 99 ERROR HANDLING

/****** Object:  StoredProcedure [MDAPEL].[GF_0001_UPDATE_MDAPEL_FROM_DBMS]    Script Date: 2/19/2013 12:38:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0001_UPDATE_MDAPEL_FROM_DBMS]
---------------------------------------------------------------------
-- BEGIN: PROCEDURE GF_0001_UPDATE_MDAPEL_FROM_DBMS
---------------------------------------------------------------------
AS
-------------------------------------------------------------------------------------
-- Author             : Michael Doves
-- Author Phone       : +31611044715
-- Author Email       : michael.doves@dikw.com
-- Purpose            : Update metadata tables from subject MDAPEL.
--                      Entity, Attribute
-- Target Entity      : 
-- Date Created       : 2012-11-16
-- Date Last Modified : 2012-11-16
-- Total Run Time (s) : +/- 40 Seconds
-- Number of Records  : 
-- Version            : 1
-- Modification(s)    : Version 1: Initial Code
-- Remarks            : 
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.

------------------------------------------------------------------------------------------------
-- BEGIN ENTITIES
------------------------------------------------------------------------------------------------
DECLARE @M_ERROR_MESSAGE NVARCHAR(4000)

BEGIN TRY -- UPDATE MDAPEL.ENTITY

-- BEGIN UPDATE EXISTING ENTITIES
UPDATE MDAPEL.ENTITY
   SET COD_SUBJECT            = B.COD_SUBJECT
      ,NAM_ENTITY             = B.NAM_ENTITY
      ,COD_ENTITY_TYPE        = B.COD_ENTITY_TYPE    
      ,DAT_ENTITY_LAST_STATUS = B.DAT_ENTITY_LAST_STATUS
      ,QTY_NUMBER_OF_ROWS     = B.QTY_NUMBER_OF_ROWS
      ,QTY_DATA_SPACE_IN_KB   = B.QTY_DATA_SPACE_IN_KB
      ,QTY_INDEX_SPACE_IN_KB  = B.QTY_INDEX_SPACE_IN_KB
      ,QTY_UNUSED_SPACE_IN_KB = B.QTY_UNUSED_SPACE_IN_KB
      ,QTY_TOTAL_SPACE_IN_KB  = B.QTY_TOTAL_SPACE_IN_KB
  FROM MDAPEL.ENTITY A
 INNER JOIN 
(
-- BEGIN B
SELECT 
 Z1.COD_ENTITY 
,Z1.COD_SUBJECT
,Z1.NAM_ENTITY
,Z1.COD_ENTITY_TYPE
,Z1.DES_ENTITY
,Z1.DAT_ENTITY_START
,Z1.DAT_ENTITY_END
,Z1.DAT_ENTITY_LAST_STATUS
,Z2.QTY_NUMBER_OF_ROWS
,Z2.QTY_DATA_SPACE_IN_KB
,Z2.QTY_INDEX_SPACE_IN_KB
,Z2.QTY_UNUSED_SPACE_IN_KB
,Z2.QTY_TOTAL_SPACE_IN_KB
  FROM
(
-- BEGIN Z1  
SELECT 
 SUB.NAME+'.'+ENT.NAME         AS COD_ENTITY 
,SUB.NAME                      AS COD_SUBJECT
,ENT.NAME                      AS NAM_ENTITY
,'TABLE'                       AS COD_ENTITY_TYPE
,PAR.QTY_NUMBER_OF_ROWS        AS QTY_NUMBER_OF_ROWS
,''                            AS DES_ENTITY
,CONVERT(DATE,ENT.CREATE_DATE) AS DAT_ENTITY_START
,CONVERT(DATE,'9999-12-31')    AS DAT_ENTITY_END
,CONVERT(DATE,GETDATE())       AS DAT_ENTITY_LAST_STATUS
  FROM
(  
SELECT * 
 FROM SYS.SCHEMAS  
WHERE 1=1
  AND UPPER(NAME) IN (SELECT COD_SUBJECT FROM MDAPEL.SUBJECT )
) SUB
INNER JOIN
(SELECT * 
  FROM SYS.TABLES
) ENT
ON SUB.SCHEMA_ID = ENT.SCHEMA_ID
LEFT JOIN
(SELECT * 
  FROM SYS.OBJECTS
) OBJ
ON ENT.OBJECT_ID = OBJ.OBJECT_ID
LEFT JOIN
(
SELECT OBJECT_ID
      ,MAX(rows) AS QTY_NUMBER_OF_ROWS
  FROM SYS.PARTITIONS
 GROUP BY OBJECT_ID 
) PAR
ON ENT.OBJECT_ID = PAR.OBJECT_ID
-- END  Z1
) Z1
LEFT JOIN
(
-- BEGIN Z2
SELECT
 schemaname+'.'+TableName            AS COD_ENTITY
,NumRows                             AS QTY_NUMBER_OF_ROWS
,pages * 8192/1024                   AS QTY_DATA_SPACE_IN_KB
,(usedpages-pages)*8192/1024         AS QTY_INDEX_SPACE_IN_KB
,(reservedpages-usedpages)*8192/1024 AS QTY_UNUSED_SPACE_IN_KB
,reservedpages *8192/1024            AS QTY_TOTAL_SPACE_IN_KB
 FROM 
(
-- BEGIN Z
SELECT
 s.[name] as schemaname
,t.[name] as tablename
,avg([rows]) as NumRows
,sum(total_pages) as reservedpages
,sum(used_pages) as usedpages
,sum(CASE
       When it.internal_type IN (202,204) Then 0
       When a.type = 1 Then a.used_pages
       When p.index_id < 2 Then a.data_pages
       Else 0
     END
     ) as pages
 from sys.allocation_units as a 
 Join sys.partitions as p on p.partition_id = a.container_id
 left join sys.internal_tables it on p.object_id = it.object_id
 JOIN sys.tables as t on p.object_id=t.object_id
 join sys.schemas as s on t.schema_id = s.schema_id
 group by s.[name], t.[name]) as subselect
-- Z2  
) Z2
ON Z1.COD_ENTITY = Z2.COD_ENTITY
-- END B
) B
ON A.COD_ENTITY = B.COD_ENTITY
-- END   UPDATE EXISTING ENTITIES

-- BEGIN INSERT NEW ENTITIES
INSERT INTO MDAPEL.ENTITY 
(COD_ENTITY
,COD_SUBJECT
,NAM_ENTITY
,COD_ENTITY_TYPE
,DES_ENTITY
,DAT_ENTITY_START
,DAT_ENTITY_END
,DAT_ENTITY_LAST_STATUS
,QTY_NUMBER_OF_ROWS
,QTY_DATA_SPACE_IN_KB
,QTY_INDEX_SPACE_IN_KB
,QTY_UNUSED_SPACE_IN_KB
,QTY_TOTAL_SPACE_IN_KB
)
SELECT
 COD_ENTITY
,COD_SUBJECT
,NAM_ENTITY
,COD_ENTITY_TYPE
,DES_ENTITY
,DAT_ENTITY_START
,DAT_ENTITY_END
,DAT_ENTITY_LAST_STATUS
,QTY_NUMBER_OF_ROWS
,QTY_DATA_SPACE_IN_KB
,QTY_INDEX_SPACE_IN_KB
,QTY_UNUSED_SPACE_IN_KB
,QTY_TOTAL_SPACE_IN_KB
  FROM
(
-- BEGIN B
SELECT 
 Z1.COD_ENTITY 
,Z1.COD_SUBJECT
,Z1.NAM_ENTITY
,Z1.COD_ENTITY_TYPE
,Z1.DES_ENTITY
,Z1.DAT_ENTITY_START
,Z1.DAT_ENTITY_END
,Z1.DAT_ENTITY_LAST_STATUS
,Z2.QTY_NUMBER_OF_ROWS
,Z2.QTY_DATA_SPACE_IN_KB
,Z2.QTY_INDEX_SPACE_IN_KB
,Z2.QTY_UNUSED_SPACE_IN_KB
,Z2.QTY_TOTAL_SPACE_IN_KB
  FROM
(
-- BEGIN Z1  
SELECT 
 SUB.NAME+'.'+ENT.NAME         AS COD_ENTITY 
,SUB.NAME                      AS COD_SUBJECT
,ENT.NAME                      AS NAM_ENTITY
,'TABLE'                       AS COD_ENTITY_TYPE
,PAR.QTY_NUMBER_OF_ROWS        AS QTY_NUMBER_OF_ROWS
,''                            AS DES_ENTITY
,CONVERT(DATE,ENT.CREATE_DATE) AS DAT_ENTITY_START
,CONVERT(DATE,'9999-12-31')    AS DAT_ENTITY_END
,CONVERT(DATE,GETDATE())       AS DAT_ENTITY_LAST_STATUS
  FROM
(  
SELECT * 
 FROM SYS.SCHEMAS  
WHERE 1=1
  AND UPPER(NAME) IN (SELECT COD_SUBJECT FROM MDAPEL.SUBJECT )
) SUB
INNER JOIN
(SELECT * 
  FROM SYS.TABLES
) ENT
ON SUB.SCHEMA_ID = ENT.SCHEMA_ID
LEFT JOIN
(SELECT * 
  FROM SYS.OBJECTS
) OBJ
ON ENT.OBJECT_ID = OBJ.OBJECT_ID
LEFT JOIN
(
SELECT OBJECT_ID
      ,MAX(rows) AS QTY_NUMBER_OF_ROWS
  FROM SYS.PARTITIONS
 GROUP BY OBJECT_ID 
) PAR
ON ENT.OBJECT_ID = PAR.OBJECT_ID
-- END  Z1
) Z1
LEFT JOIN
(
-- BEGIN Z2
SELECT
 schemaname+'.'+TableName            AS COD_ENTITY
,NumRows                             AS QTY_NUMBER_OF_ROWS
,pages * 8192/1024                   AS QTY_DATA_SPACE_IN_KB
,(usedpages-pages)*8192/1024         AS QTY_INDEX_SPACE_IN_KB
,(reservedpages-usedpages)*8192/1024 AS QTY_UNUSED_SPACE_IN_KB
,reservedpages *8192/1024            AS QTY_TOTAL_SPACE_IN_KB
 FROM 
(
-- BEGIN Z
SELECT
 s.[name] as schemaname
,t.[name] as tablename
,avg([rows]) as NumRows
,sum(total_pages) as reservedpages
,sum(used_pages) as usedpages
,sum(CASE
       When it.internal_type IN (202,204) Then 0
       When a.type = 1 Then a.used_pages
       When p.index_id < 2 Then a.data_pages
       Else 0
     END
     ) as pages
 from sys.allocation_units as a 
 Join sys.partitions as p on p.partition_id = a.container_id
 left join sys.internal_tables it on p.object_id = it.object_id
 JOIN sys.tables as t on p.object_id=t.object_id
 join sys.schemas as s on t.schema_id = s.schema_id
 group by s.[name], t.[name]) as subselect
-- Z2  
) Z2
ON Z1.COD_ENTITY = Z2.COD_ENTITY
-- END B
) X
WHERE 1=1
  AND COD_ENTITY NOT IN (SELECT COD_ENTITY FROM MDAPEL.ENTITY)
-- END   INSERT NEW ENTITIES

END TRY -- UPDATE MDAPEL.ENTITY

BEGIN CATCH -- UPDATE MDAPEL.ENTITY
  SET @M_ERROR_MESSAGE  = ('UPDATE OF MDAPEL.ENTITY FAILED: '+ (SELECT ISNULL(ERROR_MESSAGE(),'')))
  PRINT @M_ERROR_MESSAGE
END CATCH -- UPDATE MDAPEL.ENTITY
------------------------------------------------------------------------------------------------
-- END ENTITIES
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
-- BEGIN ATTRIBUTES
------------------------------------------------------------------------------------------------
BEGIN TRY -- UPDATE MDAPEL.ATTRIBUTE

-------------------------------------------------------------------------------------
-- BEGIN UPDATE EXISTING ATTRIBUTES
-------------------------------------------------------------------------------------
UPDATE MDAPEL.ATTRIBUTE
   SET  IND_ATTRIBUTE_IS_NULLABLE = B.IND_ATTRIBUTE_IS_NULLABLE
       ,COD_ATTRIBUTE_TYPE = B.COD_ATTRIBUTE_TYPE
       ,NUM_ATTRIBUTE_MAXIMUM_LENGTH = B.NUM_ATTRIBUTE_MAXIMUM_LENGTH
       ,NUM_ATTRIBUTE_PRECISION = B.NUM_ATTRIBUTE_PRECISION
       ,NUM_ATTRIBUTE_SCALE = B.NUM_ATTRIBUTE_SCALE
       ,DAT_ATTRIBUTE_LAST_STATUS = CONVERT(DATE,GETUTCDATE())
  FROM MDAPEL.ATTRIBUTE A
  INNER JOIN 
(
-- BEGIN B
SELECT
 COD_ATTRIBUTE
,COD_ENTITY
,NAM_ATTRIBUTE
,DES_ATTRIBUTE
,IND_ATTRIBUTE_IS_NULLABLE
,COD_ATTRIBUTE_TYPE
,NUM_ATTRIBUTE_MAXIMUM_LENGTH
,NUM_ATTRIBUTE_PRECISION
,NUM_ATTRIBUTE_SCALE
,COD_DOMAIN
,DAT_ATTRIBUTE_START
,DAT_ATTRIBUTE_END
,DAT_ATTRIBUTE_LAST_STATUS
  FROM
(
-- BEGIN Y  
SELECT
 COD_ATTRIBUTE
,MAX(COD_ENTITY) AS COD_ENTITY
,MAX(NAM_ATTRIBUTE) AS NAM_ATTRIBUTE
,MAX(DES_ATTRIBUTE) AS DES_ATTRIBUTE
,MAX(IND_ATTRIBUTE_IS_NULLABLE) AS IND_ATTRIBUTE_IS_NULLABLE
,MAX(COD_ATTRIBUTE_TYPE) AS COD_ATTRIBUTE_TYPE
,MAX(NUM_ATTRIBUTE_MAXIMUM_LENGTH) AS NUM_ATTRIBUTE_MAXIMUM_LENGTH
,MAX(NUM_ATTRIBUTE_PRECISION) AS NUM_ATTRIBUTE_PRECISION
,MAX(NUM_ATTRIBUTE_SCALE) AS NUM_ATTRIBUTE_SCALE
,MAX(COD_DOMAIN) AS COD_DOMAIN
,MAX(DAT_ATTRIBUTE_START) AS DAT_ATTRIBUTE_START
,MAX(DAT_ATTRIBUTE_END) AS DAT_ATTRIBUTE_END
,MAX(DAT_ATTRIBUTE_LAST_STATUS) AS DAT_ATTRIBUTE_LAST_STATUS
  FROM
(
-- BEGIN X
SELECT 
 SUB.NAME+'.'+ENT.NAME+'.'+ATT.NAME         AS COD_ATTRIBUTE
,SUB.NAME+'.'+ENT.NAME                      AS COD_ENTITY 
,ATT.NAME                                   AS NAM_ATTRIBUTE
,CONVERT(NVARCHAR(MAX),'')                  AS DES_ATTRIBUTE
,CASE
   WHEN ATT.IS_NULLABLE = 1 THEN 'Y'
   WHEN ATT.IS_NULLABLE = 0 THEN 'N'       
   ELSE '?'
 END                                        AS IND_ATTRIBUTE_IS_NULLABLE
,ISNULL(DAT.COD_ATTRIBUTE_TYPE,'_?_')       AS COD_ATTRIBUTE_TYPE 
,ATT.MAX_LENGTH                             AS NUM_ATTRIBUTE_MAXIMUM_LENGTH
,ATT.[PRECISION]                            AS NUM_ATTRIBUTE_PRECISION
,ATT.SCALE                                  AS NUM_ATTRIBUTE_SCALE
,-2                                         AS COD_DOMAIN
,CONVERT(DATE,GETUTCDATE())                 AS DAT_ATTRIBUTE_START
,CONVERT(DATE,'9999-12-31')                 AS DAT_ATTRIBUTE_END
,CONVERT(DATE,GETUTCDATE())                 AS DAT_ATTRIBUTE_LAST_STATUS
  FROM
(
-- BEGIN SCHEMAS
SELECT * 
  FROM SYS.SCHEMAS  
 WHERE 1=1
  AND UPPER(NAME) IN (SELECT COD_SUBJECT FROM MDAPEL.SUBJECT)
-- END SCHEMAS
) SUB

INNER JOIN

(
-- BEGIN TABLES
SELECT * 
  FROM SYS.TABLES
-- END TABLES
) ENT
ON SUB.SCHEMA_ID = ENT.SCHEMA_ID

LEFT JOIN

(
-- BEGIN OBJECTS
SELECT * 
  FROM SYS.OBJECTS
-- END OBJECTS
) OBJ
ON ENT.OBJECT_ID = OBJ.OBJECT_ID

LEFT JOIN

(
-- BEGIN PARTITIONS
SELECT OBJECT_ID
      ,MAX(rows) AS QTY_NUMBER_OF_ROWS
  FROM SYS.PARTITIONS
 GROUP BY OBJECT_ID 
-- BEGIN PARTITIONS
) PAR
ON ENT.OBJECT_ID = PAR.OBJECT_ID

LEFT JOIN
(
-- BEGIN COLUMNS 
SELECT *
  FROM SYS.COLUMNS 
-- END COLUMNS 
) ATT
ON ATT.OBJECT_ID = ENT.OBJECT_ID

LEFT JOIN

(
-- BEGIN SYSTYPES
SELECT *
  FROM SYS.SYSTYPES
-- END SYSTYPES
) STP
ON ATT.SYSTEM_TYPE_ID = STP.XTYPE

LEFT JOIN

(
-- BEGIN DAT
SELECT *
  FROM MDAPEL.DOM_ATTRIBUTE_TYPE
-- END DAT
) DAT
ON UPPER(STP.name) = DAT.COD_ATTRIBUTE_TYPE
-- END X
) X
 WHERE 1=1
   AND COD_ENTITY IN (SELECT COD_ENTITY FROM MDAPEL.ENTITY)
 GROUP BY COD_ATTRIBUTE
-- END Y
) Y
WHERE 1=1
  AND COD_ATTRIBUTE IN (SELECT COD_ATTRIBUTE FROM MDAPEL.ATTRIBUTE)
-- END B
) B
ON A.COD_ATTRIBUTE = B.COD_ATTRIBUTE
-------------------------------------------------------------------------------------
-- END UPDATE EXISTING ATTRIBUTES
-------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------
-- BEGIN INSERT NEW ATTRIBUTES
-------------------------------------------------------------------------------------
INSERT INTO MDAPEL.ATTRIBUTE
(COD_ATTRIBUTE
,COD_ENTITY
,NAM_ATTRIBUTE
,DES_ATTRIBUTE
,IND_ATTRIBUTE_IS_NULLABLE
,COD_ATTRIBUTE_TYPE
,NUM_ATTRIBUTE_MAXIMUM_LENGTH
,NUM_ATTRIBUTE_PRECISION
,NUM_ATTRIBUTE_SCALE
,COD_DOMAIN
,DAT_ATTRIBUTE_START
,DAT_ATTRIBUTE_END
,DAT_ATTRIBUTE_LAST_STATUS
)
SELECT
 COD_ATTRIBUTE
,COD_ENTITY
,NAM_ATTRIBUTE
,DES_ATTRIBUTE
,IND_ATTRIBUTE_IS_NULLABLE
,COD_ATTRIBUTE_TYPE
,NUM_ATTRIBUTE_MAXIMUM_LENGTH
,NUM_ATTRIBUTE_PRECISION
,NUM_ATTRIBUTE_SCALE
,COD_DOMAIN
,DAT_ATTRIBUTE_START
,DAT_ATTRIBUTE_END
,DAT_ATTRIBUTE_LAST_STATUS
  FROM
(
-- BEGIN Y  
SELECT
 COD_ATTRIBUTE
,MAX(COD_ENTITY) AS COD_ENTITY
,MAX(NAM_ATTRIBUTE) AS NAM_ATTRIBUTE
,MAX(DES_ATTRIBUTE) AS DES_ATTRIBUTE
,MAX(IND_ATTRIBUTE_IS_NULLABLE) AS IND_ATTRIBUTE_IS_NULLABLE
,MAX(COD_ATTRIBUTE_TYPE) AS COD_ATTRIBUTE_TYPE
,MAX(NUM_ATTRIBUTE_MAXIMUM_LENGTH) AS NUM_ATTRIBUTE_MAXIMUM_LENGTH
,MAX(NUM_ATTRIBUTE_PRECISION) AS NUM_ATTRIBUTE_PRECISION
,MAX(NUM_ATTRIBUTE_SCALE) AS NUM_ATTRIBUTE_SCALE
,MAX(COD_DOMAIN) AS COD_DOMAIN
,MAX(DAT_ATTRIBUTE_START) AS DAT_ATTRIBUTE_START
,MAX(DAT_ATTRIBUTE_END) AS DAT_ATTRIBUTE_END
,MAX(DAT_ATTRIBUTE_LAST_STATUS) AS DAT_ATTRIBUTE_LAST_STATUS
  FROM
(
-- BEGIN X
SELECT 
 SUB.NAME+'.'+ENT.NAME+'.'+ATT.NAME         AS COD_ATTRIBUTE
,SUB.NAME+'.'+ENT.NAME                      AS COD_ENTITY 
,ATT.NAME                                   AS NAM_ATTRIBUTE
,CONVERT(NVARCHAR(MAX),'')                  AS DES_ATTRIBUTE
,CASE
   WHEN ATT.IS_NULLABLE = 1 THEN 'Y'
   WHEN ATT.IS_NULLABLE = 0 THEN 'N'       
   ELSE '?'
 END                                        AS IND_ATTRIBUTE_IS_NULLABLE
,ISNULL(DAT.COD_ATTRIBUTE_TYPE,'_?_')       AS COD_ATTRIBUTE_TYPE
,ATT.MAX_LENGTH                             AS NUM_ATTRIBUTE_MAXIMUM_LENGTH
,ATT.[PRECISION]                            AS NUM_ATTRIBUTE_PRECISION
,ATT.SCALE                                  AS NUM_ATTRIBUTE_SCALE
,-2                                         AS COD_DOMAIN
,CONVERT(DATE,GETUTCDATE())                 AS DAT_ATTRIBUTE_START
,CONVERT(DATE,'9999-12-31')                 AS DAT_ATTRIBUTE_END
,CONVERT(DATE,GETUTCDATE())                 AS DAT_ATTRIBUTE_LAST_STATUS
  FROM
(  
SELECT * 
 FROM SYS.SCHEMAS  
WHERE 1=1
  AND UPPER(NAME) IN (SELECT COD_SUBJECT FROM MDAPEL.SUBJECT )
) SUB
INNER JOIN
(SELECT * 
  FROM SYS.TABLES
) ENT
ON SUB.SCHEMA_ID = ENT.SCHEMA_ID
LEFT JOIN
(SELECT * 
  FROM SYS.OBJECTS
) OBJ
ON ENT.OBJECT_ID = OBJ.OBJECT_ID
LEFT JOIN
(
SELECT OBJECT_ID
      ,MAX(rows) AS QTY_NUMBER_OF_ROWS
  FROM SYS.PARTITIONS
 GROUP BY OBJECT_ID 
) PAR
ON ENT.OBJECT_ID = PAR.OBJECT_ID
LEFT JOIN
(
SELECT *
  FROM SYS.COLUMNS 
) ATT
ON ATT.OBJECT_ID = ENT.OBJECT_ID
LEFT JOIN
(
SELECT *
  FROM SYS.SYSTYPES
) STP
ON ATT.SYSTEM_TYPE_ID = STP.XTYPE

LEFT JOIN

(
-- BEGIN DAT
SELECT *
  FROM MDAPEL.DOM_ATTRIBUTE_TYPE
-- END DAT
) DAT
ON UPPER(STP.name) = DAT.COD_ATTRIBUTE_TYPE
-- END X
) X
WHERE 1=1
  AND COD_ENTITY IN (SELECT COD_ENTITY FROM MDAPEL.ENTITY)
 GROUP BY COD_ATTRIBUTE
-- END Y  
) Y
WHERE 1=1
  AND COD_ATTRIBUTE NOT IN (SELECT COD_ATTRIBUTE FROM MDAPEL.ATTRIBUTE)
-------------------------------------------------------------------------------------
-- END   INSERT NEW ATTRIBUTES
-------------------------------------------------------------------------------------

END TRY   -- UPDATE MDAPEL.ATTRIBUTE

BEGIN CATCH -- UPDATE MDAPEL.ATTRIBUTE
  SET  @M_ERROR_MESSAGE = ('UPDATE OF MDAPEL.ATTRIBUTE FAILED: '+ (SELECT ISNULL(ERROR_MESSAGE(),'')))
  PRINT @M_ERROR_MESSAGE
END CATCH -- UPDATE MDAPEL.ATTRIBUTE
------------------------------------------------------------------------------------------------
-- END GF_0001_UPDATE_MDAPEL_FROM_DBMS
------------------------------------------------------------------------------------------------

GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0015_CREATE_DDADTI_STATUS_PROCESS]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0015_CREATE_DDADTI_STATUS_PROCESS]
 /* PARAMETER 01 */ @COD_DTI           INTEGER
,/* PARAMETER 02 */ @NAM_SOR_TABLE     NVARCHAR(100) 
,/* PARAMETER 03 */ @TXT_SPECIFIC_FROM NVARCHAR(400)
,/* PARAMETER 04 */ @NR_KEY_COLUMNS    INTEGER
,/* PARAMETER 05 */ @COD_KEY01         NVARCHAR(100)
,/* PARAMETER 06 */ @COD_KEY02         NVARCHAR(100) = NULL /* OPTIONAL */
,/* PARAMETER 07 */ @COD_KEY03         NVARCHAR(100) = NULL /* OPTIONAL */
,/* PARAMETER 08 */ @COD_KEY04         NVARCHAR(100) = NULL /* OPTIONAL */
,/* PARAMETER 09 */ @COD_KEY05         NVARCHAR(100) = NULL /* OPTIONAL */
,/* PARAMETER 10 */ @COD_KEY06         NVARCHAR(100) = NULL /* OPTIONAL */
,/* PARAMETER 11 */ @COD_KEY07         NVARCHAR(100) = NULL /* OPTIONAL */
,/* PARAMETER 12 */ @COD_KEY08         NVARCHAR(100) = NULL /* OPTIONAL */
,/* PARAMETER 13 */ @COD_KEY09         NVARCHAR(100) = NULL /* OPTIONAL */
,/* PARAMETER 14 */ @COD_KEY10         NVARCHAR(100) = NULL /* OPTIONAL */
-- =========================================================================================
-- Author(s)          : Michael Doves
-- Date Created       : 2012-11-05
-- Date Last Modified : 2012-11-22
-- Version            : 2
-- Modification       : 2012-11-22 Michael Doves
--                      CONVERT(NVARCHAR,atrribute_name) kapt af naar 20 posities, dus veranderd
--                      in CONVERT(NVARCHAR(100),atrribute_name)
-- Remark             : Automatically generated by GF_0015_CREATE_DDADTI_STATUS_PROCESS
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-- ========================================================================================
AS
BEGIN TRY
/*
DECLARE @COD_DTI            INTEGER = 1003
DECLARE @NAM_SOR_TABLE      NVARCHAR(100) = 'accounts_bugs'
DECLARE @TXT_SPECIFIC_FROM  VARCHAR(400)
--SET @TXT_SPECIFIC_FROM  = 'OPENQUERY(IDACRM, ''SELECT * FROM sugarcrm.'+@NAM_SOR_TABLE+''')'
--PRINT @TXT_SPECIFIC_FROM
DECLARE @NR_KEY_COLUMNS     INTEGER = 1
DECLARE @COD_KEY01          NVARCHAR(100) = 'id'
DECLARE @COD_KEY02          NVARCHAR(100) = 'parent_id'
DECLARE @COD_KEY03          NVARCHAR(100) = 'field_name'
DECLARE @COD_KEY04          NVARCHAR(100)
DECLARE @COD_KEY05          NVARCHAR(100)
DECLARE @COD_KEY06          NVARCHAR(100)
DECLARE @COD_KEY07          NVARCHAR(100)
DECLARE @COD_KEY08          NVARCHAR(100)
DECLARE @COD_KEY09          NVARCHAR(100)
DECLARE @COD_KEY10          NVARCHAR(100)
*/
DECLARE @TXT_KEY_COLUMNS    NVARCHAR(200)
DECLARE @SQL1			    NVARCHAR(MAX)
DECLARE @SQL2			    VARCHAR(MAX)
DECLARE @SQL3               NVARCHAR(MAX)
DECLARE @DTI_COLUMNLIST_KEY NVARCHAR(MAX)
DECLARE @COD_COMPONENT_KEY  NVARCHAR(MAX)
DECLARE @DTI_COLUMNLIST_DET NVARCHAR(MAX)
DECLARE @COD_ENTITY         NVARCHAR(107)
DECLARE @NAM_ENTITY         NVARCHAR(107)
DECLARE @NAM_PROCESS        NVARCHAR(100)
DECLARE @TXT_DATE           NCHAR(10)
DECLARE @M_COD_PROCESS      NCHAR(8)
DECLARE @M_COD_SOR          NVARCHAR(18)
SET @TXT_KEY_COLUMNS = (CASE
                          WHEN @NR_KEY_COLUMNS = 1
                          THEN REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY01),'[','''['),']',']'''),'[',''),']','')
                          WHEN @NR_KEY_COLUMNS = 2
                          THEN REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY01),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY02),'[','''['),']',']'''),'[',''),']','')
                          WHEN @NR_KEY_COLUMNS = 3
                          THEN REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY01),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY02),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY03),'[','''['),']',']'''),'[',''),']','')
                          WHEN @NR_KEY_COLUMNS = 4     
                          THEN REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY01),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY02),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY03),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY04),'[','''['),']',']'''),'[',''),']','') 
                          WHEN @NR_KEY_COLUMNS = 5          
                          THEN REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY01),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY02),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY03),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY04),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY05),'[','''['),']',']'''),'[',''),']','')
                          WHEN @NR_KEY_COLUMNS = 6           
                          THEN REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY01),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY02),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY03),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY04),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY05),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY06),'[','''['),']',']'''),'[',''),']','')
                          WHEN @NR_KEY_COLUMNS = 7          
                          THEN REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY01),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY02),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY03),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY04),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY05),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY06),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY07),'[','''['),']',']'''),'[',''),']','')
                          WHEN @NR_KEY_COLUMNS = 8          
                          THEN REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY01),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY02),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY03),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY04),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY05),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY06),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY07),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY08),'[','''['),']',']'''),'[',''),']','')
                          WHEN @NR_KEY_COLUMNS = 9          
                          THEN REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY01),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY02),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY03),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY04),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY05),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY06),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY07),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY08),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY09),'[','''['),']',']'''),'[',''),']','')
                          WHEN @NR_KEY_COLUMNS = 10          
                          THEN REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY01),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY02),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY03),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY04),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY05),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY06),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY07),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY08),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY09),'[','''['),']',']'''),'[',''),']','') + ',' +
                               REPLACE(REPLACE(REPLACE(REPLACE(QUOTENAME(@COD_KEY10),'[','''['),']',']'''),'[',''),']','')                                      
                          ELSE ''
                        END 
                       )
PRINT @TXT_KEY_COLUMNS
                       
SET @TXT_DATE = (SELECT CONVERT(DATE,GETDATE()))
PRINT @TXT_DATE

SET @M_COD_PROCESS = ('2'+RIGHT('0000000'+CONVERT(NVARCHAR,@COD_DTI),7))
PRINT @M_COD_PROCESS

SET @COD_ENTITY = (SELECT COD_ENTITY
                     FROM MDAPEL.DTI
                    WHERE 1=1
                      AND COD_DTI = @COD_DTI
                  )
PRINT @COD_ENTITY
     
SET @NAM_ENTITY = (SUBSTRING(@COD_ENTITY,8,100))
PRINT @NAM_ENTITY     

SET @NAM_PROCESS = ('PROCESS_2'+ SUBSTRING(@COD_ENTITY,11,100))
PRINT @NAM_PROCESS    

SET @M_COD_SOR = (SELECT CONVERT(NVARCHAR,COD_SOR)
                     FROM MDAPEL.DTI
                    WHERE 1=1
                      AND COD_DTI = @COD_DTI
                  )
PRINT @M_COD_SOR 
                             
SET @SQL1 = N'
SELECT @DTI_COLUMNLIST_KEY = (SELECT STUFF ((SELECT '',[''+COLUMN_NAME+'']''
						                       FROM INFORMATION_SCHEMA.COLUMNS
						                      WHERE 1=1 
						                        AND TABLE_NAME = '''+@NAM_ENTITY+'''
						                        AND TABLE_SCHEMA = ''DDADTI''
						                        AND COLUMN_NAME IN ('+@TXT_KEY_COLUMNS+')
						                      ORDER BY ORDINAL_POSITION FOR XML PATH('''')
										    ), 1, 1, '''') 
					         )
'
PRINT @SQL1
EXECUTE SP_EXECUTESQL @SQL1, N'@DTI_COLUMNLIST_KEY nvarchar(max) OUTPUT', @DTI_COLUMNLIST_KEY = @DTI_COLUMNLIST_KEY OUTPUT
PRINT @DTI_COLUMNLIST_KEY

SET @COD_COMPONENT_KEY = (REPLACE(REPLACE(@DTI_COLUMNLIST_KEY,'[','CONVERT(NVARCHAR(100),['),'],','])+''_''+')
                          +')' 
                         )
PRINT @COD_COMPONENT_KEY                          

                             
SET @SQL1 = N'
SELECT @DTI_COLUMNLIST_DET = (SELECT STUFF ((SELECT '', ['' + COLUMN_NAME +''] ''
						                       FROM INFORMATION_SCHEMA.COLUMNS
						                      WHERE 1=1 
						                        AND TABLE_NAME = '''+@NAM_ENTITY+'''
						                        AND TABLE_SCHEMA = ''DDADTI''
						                        AND COLUMN_NAME NOT IN (''M_IDR''
						                                               ,''M_UTC_SNAPSHOT''
						                                               ,''M_COD_PROCESS''
						                                               ,''M_COD_SOR''
						                                               ,''M_UTC_RECORD_INSERTED''
						                                               ,''M_COD_PLAUSIBLE''
						                                               ,''M_CRC''
						                                               ,''M_COD_KEY''
						                                               )
						                      ORDER BY ORDINAL_POSITION FOR XML PATH('''')
										    ), 1, 1, '''') 
					         )
'
PRINT @SQL1
EXECUTE SP_EXECUTESQL @SQL1, N'@DTI_COLUMNLIST_DET nvarchar(max) OUTPUT', @DTI_COLUMNLIST_DET = @DTI_COLUMNLIST_DET OUTPUT
PRINT @DTI_COLUMNLIST_DET

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
-- Purpose            : Extracting data from source systems into Data Distribution Area 
--                      of Data Warehouse.
-- Target Entity      : '+@COD_ENTITY+'
-- Date Created       : '+@TXT_DATE+'
-- Date Last Modified : 
-- Total Run Time (s) : 
-- Number of Records  : 
-- Eletronic Size     : 
-- Version            : 1
-- Modification(s)    : Version 1: Initial Code
-- Remarks            : Automatically generated
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V. express consent.
-------------------------------------------------------------------------------------
DECLARE @M_COD_PROCESS        BIGINT = '+@M_COD_PROCESS+'
DECLARE @M_COD_SOR            BIGINT = '+@M_COD_SOR+'
DECLARE @M_COD_INSTANCE       BIGINT
DECLARE @M_COD_PROCESS_STATUS NVARCHAR(22)
EXECUTE MDAPEL.GF_1001_GENERIC_PRE_PROCESS @M_COD_PROCESS,@M_COD_INSTANCE OUTPUT,@M_COD_PROCESS_STATUS OUTPUT
BEGIN TRY
IF @M_COD_PROCESS_STATUS = ''ACTIVATED AND UNLOCKED''
BEGIN 
EXECUTE MDAPEL.GF_1000_INSERT_LOG @M_COD_PROCESS,@M_COD_INSTANCE,''INFORMATION'',''Specific Pre Process has started.''
EXECUTE MDAPEL.GF_1000_INSERT_LOG @M_COD_PROCESS,@M_COD_INSTANCE,''INFORMATION'',''Main Process has started.''
DECLARE @M_UTC_SNAPSHOT   DATETIME2(0)
    SET @M_UTC_SNAPSHOT = (select getutcdate())
DELETE FROM '+@COD_ENTITY+' WHERE 1=1 AND M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT AND M_COD_SOR = @M_COD_SOR
INSERT INTO '+@COD_ENTITY+' (M_UTC_SNAPSHOT,M_COD_PROCESS,M_COD_SOR,M_COD_KEY,'+@DTI_COLUMNLIST_DET+')
SELECT M_UTC_SNAPSHOT,M_COD_PROCESS,M_COD_SOR,M_COD_KEY,'+@DTI_COLUMNLIST_DET+' FROM
(SELECT @M_UTC_SNAPSHOT AS M_UTC_SNAPSHOT,@M_COD_PROCESS AS M_COD_PROCESS,@M_COD_SOR AS M_COD_SOR,'+@COD_COMPONENT_KEY+' AS M_COD_KEY,'+@DTI_COLUMNLIST_DET+'
   FROM '+@TXT_SPECIFIC_FROM+'
) X
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

GO
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

GO
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

GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0030_CREATE_OMADIA_STATUS_ENTITY]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [MDAPEL].[GF_0030_CREATE_OMADIA_STATUS_ENTITY] 
 @DDADTI_TABLE nvarchar(100) 
-- =========================================================================================
-- Author(s)          : Michael Doves
-- date Created       : 2012-10-10
-- Version            : 1
-- Date Last Modified : 2012-10-10         
-- Description        :	Generates a OMADIA Snapshot table based on DDADTI snapshot input table, 
-- Parameters         :	@DDADTI_TABLE = input DDA table
-- Modifications      : 
-- EXAMPLE CALL       : EXECUTE MDAPEL.GF_0030_CREATE_OMADIA_STATUS_ENTITY 'DTI0009002_LINKEDIN_ASSOCIATION_148_149'
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-- ========================================================================================
AS
BEGIN 
--DECLARE @DDADTI_TABLE nvarchar(100) = 'DTI0001000_ACCOUNTS'
DECLARE @SQL1			         nvarchar(max)
DECLARE @DDA_COLUMNLIST          nvarchar(max)
DECLARE @INPUT_SCHEMA	         nchar(6) = 'DDADTI'
DECLARE @OUTPUT_SCHEMA	         nchar(6) = 'OMADIA'

--Collect DDA table columns, already formated in a list without Metadata columns (M_xxx)
SET @SQL1 = N'SELECT @DDA_COLUMNLIST = (SELECT STUFF ((SELECT '', ['' + COLUMN_NAME
										+''] ''+ CASE DATA_TYPE
											    WHEN ''int''                THEN ''int''
												WHEN ''timestamp''          THEN ''timestamp''
												WHEN ''image''              THEN ''image''
												WHEN ''tinyint''            THEN ''tinyint''
												WHEN ''smallint''           THEN ''smallint''
												WHEN ''bigint''             THEN ''bigint''
												WHEN ''float''              THEN ''float''
												WHEN ''uniqueidentifier''   THEN ''uniqueidentifier''
												WHEN ''numeric''	        THEN ''numeric(''+ISNULL(CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)), (CAST(NUMERIC_PRECISION AS VARCHAR(5)) +'',''+ CAST(NUMERIC_SCALE AS VARCHAR(4))))+'')''
												WHEN ''decimal''	        THEN ''decimal(''+ISNULL(CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)), (CAST(NUMERIC_PRECISION AS VARCHAR(5)) +'',''+ CAST(NUMERIC_SCALE AS VARCHAR(4))))+'')''
												WHEN ''datetime''	        THEN ''datetime''
												WHEN ''datetime2''	        THEN ''datetime2''
												WHEN ''date''		        THEN ''date''
												WHEN ''bit''	            THEN ''bit''
												WHEN ''nchar''              THEN ''nchar(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
												WHEN ''char''               THEN ''char(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
												WHEN ''nvarchar''           THEN ''nvarchar(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
												WHEN ''varchar''            THEN ''varchar(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
												WHEN ''text''               THEN ''text''
												WHEN ''ntext''              THEN ''ntext''
												WHEN ''time''               THEN ''time''
											ELSE NULL END
										+'' ''+ CASE WHEN IS_NULLABLE = ''NO'' THEN ''NOT NULL'' ELSE ''NULL'' END
									 FROM INFORMATION_SCHEMA.COLUMNS
									 WHERE TABLE_NAME = '''+@DDADTI_TABLE+'''
									 AND TABLE_SCHEMA = '''+@INPUT_SCHEMA+'''
									 AND COLUMN_NAME NOT IN(''M_IDR'',''M_UTC_SNAPSHOT'',''M_COD_PROCESS'',''M_COD_SOR'',''M_UTC_RECORD_INSERTED'', ''M_COD_PLAUSIBLE'', ''M_COD_KEY'',''M_CRC'' )
									 ORDER BY ORDINAL_POSITION
									 FOR XML PATH('''')
									 ), 1, 1, '''') )'
PRINT @SQL1									 
EXECUTE sp_executesql @SQL1, N'@DDA_COLUMNLIST nvarchar(max) OUTPUT', @DDA_COLUMNLIST = @DDA_COLUMNLIST OUTPUT

SET @SQL1 = N'CREATE TABLE '+@OUTPUT_SCHEMA+'.'+@DDADTI_TABLE+'(
		[M_IDR]                  [bigint] IDENTITY(1,1) NOT NULL,
		[M_UTC_START]            [datetime2](0)         NOT NULL,
		[M_UTC_END]              [datetime2](0)         NOT NULL,
		[M_COD_PROCESS_INSERTED] [bigint]               NOT NULL,
		[M_COD_PROCESS_UPDATED]  [bigint]                   NULL,
		[M_COD_SOR]              [bigint]               NOT NULL,
		[M_UTC_RECORD_INSERTED]  [datetime2](0)         NOT NULL,
		[M_UTC_RECORD_UPDATED]   [datetime2](0)         NULL,
		[M_CRC]                  [bigint]               NOT NULL,
		[M_COD_KEY]              [nvarchar](100)        NOT NULL,		
		'+@DDA_COLUMNLIST+'
		/* BEGIN PK00 */
		CONSTRAINT [PK00_'+@DDADTI_TABLE+'] PRIMARY KEY CLUSTERED 
		  ([M_IDR] ASC
		  )
		) 
		/* END   PK00 */
		/* BEGIN UK01 */
		CREATE UNIQUE NONCLUSTERED INDEX [UK01_'+@DDADTI_TABLE+'] ON [OMADIA].['+@DDADTI_TABLE+'] 
          ([M_UTC_START] ASC
          ,[M_COD_SOR] ASC
          ,[M_COD_KEY] ASC
          )
        /* END   UK01 */
        /* BEGIN UK02 */
		CREATE UNIQUE NONCLUSTERED INDEX [UK02_'+@DDADTI_TABLE+'] ON [OMADIA].['+@DDADTI_TABLE+'] 
          ([M_UTC_END] ASC
          ,[M_COD_SOR] ASC
          ,[M_COD_KEY] ASC
          )
        /* END   UK02 */
        /* BEGIN IX01 */   
        CREATE NONCLUSTERED INDEX [IX01_'+@DDADTI_TABLE+'] ON [OMADIA].['+@DDADTI_TABLE+'] 
          ([M_UTC_START] ASC
          )
        /* END   IX01 */ 
        /* BEGIN IX02 */
        CREATE NONCLUSTERED INDEX [IX02_'+@DDADTI_TABLE+'] ON [OMADIA].['+@DDADTI_TABLE+'] 
          ([M_UTC_END] ASC
          )
        /* END   IX02 */ 
        /* BEGIN IX03 */
        CREATE NONCLUSTERED INDEX [IX03_'+@DDADTI_TABLE+'] ON [OMADIA].['+@DDADTI_TABLE+'] 
          ([M_COD_SOR] ASC
          )
        /* END   IX03 */        
        /* BEGIN IX04 */
        CREATE NONCLUSTERED INDEX [IX04_'+@DDADTI_TABLE+'] ON [OMADIA].['+@DDADTI_TABLE+'] 
          ([M_COD_KEY] ASC
          )
        /* END   IX04 */        
        /* BEGIN FK01 */    
        ALTER TABLE [OMADIA].['+@DDADTI_TABLE+'] WITH CHECK ADD CONSTRAINT [FK01_'+@DDADTI_TABLE+'] FOREIGN KEY([M_COD_SOR]) REFERENCES [MDAPEL].[SOR] ([COD_SOR])
        ALTER TABLE [OMADIA].['+@DDADTI_TABLE+'] CHECK CONSTRAINT [FK01_'+@DDADTI_TABLE+']
        /* END   FK01 */     
        /* BEGIN FK02 */    
        ALTER TABLE [OMADIA].['+@DDADTI_TABLE+'] WITH CHECK ADD CONSTRAINT [FK02_'+@DDADTI_TABLE+'] FOREIGN KEY([M_COD_PROCESS_INSERTED]) REFERENCES [MDAPEL].[PROCESS] ([COD_PROCESS])
        ALTER TABLE [OMADIA].['+@DDADTI_TABLE+'] CHECK CONSTRAINT [FK02_'+@DDADTI_TABLE+']
        /* END   FK02 */     
        /* BEGIN FK03 */    
        ALTER TABLE [OMADIA].['+@DDADTI_TABLE+'] WITH CHECK ADD CONSTRAINT [FK03_'+@DDADTI_TABLE+'] FOREIGN KEY([M_COD_PROCESS_UPDATED]) REFERENCES [MDAPEL].[PROCESS] ([COD_PROCESS])
        ALTER TABLE [OMADIA].['+@DDADTI_TABLE+'] CHECK CONSTRAINT [FK03_'+@DDADTI_TABLE+']
        /* END   FK03 */
        /* BEGIN CN01 */ 
        ALTER TABLE [OMADIA].['+@DDADTI_TABLE+'] ADD CONSTRAINT [CN01_'+@DDADTI_TABLE+'] DEFAULT GETUTCDATE() FOR [M_UTC_RECORD_INSERTED]
        /* END   CN01 */
                                                 
'
-- check if table really doesn't exists
IF OBJECT_ID(@OUTPUT_SCHEMA+'.'+@DDADTI_TABLE, 'U') IS NULL 
BEGIN
  PRINT @SQL1
  EXECUTE sp_executesql @SQL1
END
ELSE PRINT '-- TABLE ALREADY EXISTS, NOT RECREATED (first manual delete) --'
----------------------------------------------------------------------------------
-- END create OMADIA table
----------------------------------------------------------------------------------
END

GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0040_CREATE_OMADIA_STATUS_PROCESS]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0040_CREATE_OMADIA_STATUS_PROCESS] 
 @DDADTI_TABLE nvarchar(100) 
-- =========================================================================================
-- Author(s)          : Michael Doves
-- date Created       : 2012-05-20
-- Version            : 1
-- Date Last Modified :         
-- Description        :	OMADIA STATUS PROCESS
-- Parameters         :	@DDADTI_TABLE = input DDA table                    
-- Modifications      : 
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-- ========================================================================================
AS
BEGIN TRY
--DECLARE @DDADTI_TABLE                 nvarchar(100)  ='DTI0001000_ACCOUNTS'
DECLARE @SQL1			              nvarchar(max)
DECLARE @INPUT_SCHEMA	              nchar(6) = 'DDADTI'
DECLARE @OUTPUT_SCHEMA	              nchar(6) = 'OMADIA'
DECLARE @M_COD_PROCESS	              nchar(8) = '4'+SUBSTRING(@DDADTI_TABLE,4,7)
PRINT @M_COD_PROCESS
DECLARE @PROCEDURE_NAME_POST_FIX      nvarchar(88) = LTRIM(RTRIM(SUBSTRING(@DDADTI_TABLE,CHARINDEX('_', @DDADTI_TABLE)+1,88)))
DECLARE @PROCEDURE_NAME               nvarchar(100) = 'PROCESS_'+@M_COD_PROCESS+'_'+@PROCEDURE_NAME_POST_FIX
PRINT @PROCEDURE_NAME


		
-- Drop procedure if it exists
IF OBJECT_ID(@OUTPUT_SCHEMA+'.'+@PROCEDURE_NAME,'P') IS NOT NULL
	BEGIN
	  SELECT @SQL1 = 'DROP PROCEDURE '+@OUTPUT_SCHEMA+'.'+@PROCEDURE_NAME
	  EXECUTE(@SQL1) 
	END

----------------------------------------------------------------------------------		
-- BEGIN Create OMADIA snapshot procedure
----------------------------------------------------------------------------------
SET @SQL1 = 
N'
CREATE PROCEDURE '+@OUTPUT_SCHEMA+'.'+@PROCEDURE_NAME+'
AS
/* This procedure is automatically generated */
DECLARE @M_COD_PROCESS        BIGINT = '+@M_COD_PROCESS+' 
DECLARE @M_COD_INSTANCE       BIGINT
DECLARE @M_COD_PROCESS_STATUS NVARCHAR(22)
DECLARE @M_COD_DTI            NVARCHAR(200) = '''+@DDADTI_TABLE+'''
DECLARE @M_UTC_SNAPSHOT       DATETIME2(0)
DECLARE @M_COD_SOR            BIGINT 
EXECUTE MDAPEL.GF_1001_GENERIC_PRE_PROCESS @M_COD_PROCESS,@M_COD_INSTANCE OUTPUT,@M_COD_PROCESS_STATUS OUTPUT
BEGIN TRY
IF @M_COD_PROCESS_STATUS = ''ACTIVATED AND UNLOCKED''
BEGIN 
EXECUTE MDAPEL.GF_1000_INSERT_LOG @M_COD_PROCESS,@M_COD_INSTANCE,''INFORMATION'',''Specific Pre Process has started.''
EXECUTE MDAPEL.GF_1000_INSERT_LOG @M_COD_PROCESS,@M_COD_INSTANCE,''INFORMATION'',''Main Process has started.''
  IF (SELECT COUNT(M_UTC_SNAPSHOT) FROM DDADTI.'+@DDADTI_TABLE+') > 0 
    BEGIN
      DECLARE M_UTC_SNAPSHOT_CUR CURSOR FOR
      SELECT DISTINCT M_COD_SOR, M_UTC_SNAPSHOT FROM DDADTI.'+@DDADTI_TABLE+'
      OPEN M_UTC_SNAPSHOT_CUR
        FETCH NEXT FROM M_UTC_SNAPSHOT_CUR INTO @M_COD_SOR, @M_UTC_SNAPSHOT
        WHILE @@fetch_status = 0
        BEGIN
            EXECUTE MDAPEL.GF_0201_OMADIA_STATUS @M_COD_DTI,@M_COD_PROCESS,@M_COD_INSTANCE
            FETCH NEXT FROM M_UTC_SNAPSHOT_CUR INTO @M_COD_SOR,@M_UTC_SNAPSHOT
        END
      CLOSE M_UTC_SNAPSHOT_CUR
      DEALLOCATE M_UTC_SNAPSHOT_CUR
    END
  ELSE
    BEGIN
       EXECUTE MDAPEL.GF_0201_OMADIA_STATUS @M_COD_DTI,@M_COD_PROCESS,@M_COD_INSTANCE
    END 

EXECUTE MDAPEL.GF_1000_INSERT_LOG @M_COD_PROCESS,@M_COD_INSTANCE,''INFORMATION'',''Specific Post Process has started.''
END
EXECUTE MDAPEL.GF_1002_GENERIC_POST_PROCESS @M_COD_PROCESS,@M_COD_INSTANCE,@M_COD_PROCESS_STATUS
END TRY

BEGIN CATCH
  DECLARE @M_ERROR_MESSAGE NVARCHAR(4000) = (SELECT ERROR_MESSAGE())
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING @M_COD_PROCESS,@M_COD_INSTANCE,@M_ERROR_MESSAGE
END CATCH 
'
EXECUTE sp_executesql @SQL1
END TRY
BEGIN CATCH
			SELECT ERROR_MESSAGE() + ' | '+ @SQL1 AS ErrorMessage
			RETURN
END CATCH

GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0041_CREATE_OMADIA_EVENT_PROCESS]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0041_CREATE_OMADIA_EVENT_PROCESS] 
	  @TABLE nvarchar(max)
	, @M_COD_PROCESS varchar(10) = 999999 
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
declare @OUTPUT_SCHEMA				varchar(200)	='EMADIA'
declare @UTC_INSTANCE_START			datetime2		= GETUTCDATE()
declare @GF_PROCESS_NAME			varchar(200)	='GF_07_EMADIA_TRANSACTION'
/* END: Initialize Process Parameters */

/* BEGIN: Declare parameters */
DECLARE @DDA_COLUMNLIST				nvarchar(max)
DECLARE @EMA_COLUMNLIST				nvarchar(max)
declare @DDA_EMA_COLUMNLIST			nvarchar(max)
declare @M_COD_SOR					varchar(8)
declare @M_COD_INSTANCE				bigint			
declare @SQL1						nvarchar(max)
declare @SQL2						nvarchar(max)
declare @M_UTC_SNAPSHOT				datetime2
DECLARE @M_UTC_START				datetime2
DECLARE @LOG						NVARCHAR(MAX)
declare @ROWCOUNT					int
declare @ROWCOUNT_P					int
/* END: Declare parameters */

/**********************************************************************************/
-- BEGIN: Write log message
/**********************************************************************************/

BEGIN TRY

EXECUTE MDAPEL.GF_003_LOG_PROCESS_INSTANCE I, @M_COD_PROCESS, @UTC_INSTANCE_START, 'START', @PROCESS_NAME, @GF_PROCESS_NAME, @M_COD_INSTANCE OUTPUT

END TRY
BEGIN CATCH
		SELECT ERROR_MESSAGE()
        RETURN
END CATCH   


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
            EXEC MDAPEL.GF_004_LOG_PROCESS_INSTANCE_LOG @M_COD_PROCESS, @M_COD_INSTANCE, 'ERROR', @LOG
            EXEC MDAPEL.GF_003_LOG_PROCESS_INSTANCE U, @M_COD_PROCESS, @UTC_INSTANCE_START, 'ERROR', @PROCESS_NAME, @GF_PROCESS_NAME, @M_COD_INSTANCE
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

EXEC MDAPEL.GF_004_LOG_PROCESS_INSTANCE_LOG @M_COD_PROCESS, @M_COD_INSTANCE, 'INFORMATION', @LOG

END TRY
BEGIN CATCH
		SELECT ERROR_MESSAGE()
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
		EXEC MDAPEL.GF_004_LOG_PROCESS_INSTANCE_LOG @M_COD_PROCESS, @M_COD_INSTANCE, 'INFORMATION', @LOG
		
END TRY
BEGIN CATCH
		SELECT ERROR_MESSAGE() + ' | '+ @SQL1 AS ErrorMessage
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
			 and COLUMN_NAME NOT IN(''M_IDR'',''M_UTC_SNAPSHOT'',''M_COD_PROCESS'',''M_COD_SOR'',''M_UTC_RECORD_INSERTED'', ''M_COD_PLAUSIBLE'', ''M_COD_KEY'' )
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
		SET @LOG = 'Columnlists - ' + ERROR_MESSAGE()
        EXEC MDAPEL.GF_004_LOG_PROCESS_INSTANCE_LOG @M_COD_PROCESS, @M_COD_INSTANCE, 'ERROR', @LOG
        EXEC MDAPEL.GF_003_LOG_PROCESS_INSTANCE U, @M_COD_PROCESS, @UTC_INSTANCE_START, 'ERROR', @PROCESS_NAME,  @GF_PROCESS_NAME, @M_COD_INSTANCE
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

CREATE TABLE #ROWS (MergeAction varchar(10))

SET @SQL1 = N'
INSERT INTO #ROWS
SELECT MergeAction FROM (
MERGE  '+@OUTPUT_SCHEMA+'.'+@TABLE+' as EMA
USING (SELECT * FROM '+@INPUT_SCHEMA+'.'+@TABLE+' WHERE M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT)as DDA -- Process only the current snapshot (merge cannot process multiple snapshots)
   ON EMA.M_COD_KEY = DDA.M_COD_KEY
  AND EMA.M_COD_SOR = DDA.M_COD_SOR 
 WHEN MATCHED
  AND (EMA.M_CRC <> BINARY_CHECKSUM('+@DDA_COLUMNLIST+'))
  THEN UPDATE SET
          EMA.M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
        , EMA.[M_COD_PROCESS_UPDATED] = ('+@M_COD_PROCESS+')
        , EMA.[M_UTC_RECORD_UPDATED] = GETUTCDATE()
        , EMA.[M_CRC] = BINARY_CHECKSUM('+@DDA_COLUMNLIST+')
        , '+@DDA_EMA_COLUMNLIST+'
 WHEN NOT MATCHED BY TARGET THEN
  INSERT 
			('+@EMA_COLUMNLIST+')
  VALUES
			( @M_UTC_SNAPSHOT			
			, ('+@M_COD_PROCESS+')					
			, NULL						
			, M_COD_SOR					
			, GETUTCDATE()				
			, NULL					
			, M_COD_KEY
			, BINARY_CHECKSUM('+@DDA_COLUMNLIST+')
			, '+@DDA_COLUMNLIST+')
 OUTPUT $action as MergeAction) MergeResult;'
 
BEGIN TRAN
	IF @DEBUG =  1 PRINT @SQL1
	EXEC sp_executesql @SQL1, N'@M_UTC_SNAPSHOT datetime2', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
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
				EXEC MDAPEL.GF_004_LOG_PROCESS_INSTANCE_LOG @M_COD_PROCESS, @M_COD_INSTANCE, 'INFORMATION', @LOG
				FETCH NEXT FROM Action_cur INTO @MergeAction, @NmbrOfRec
			END
			CLOSE Action_cur
			DEALLOCATE Action_cur
		END
		
		ELSE
		EXEC MDAPEL.GF_004_LOG_PROCESS_INSTANCE_LOG @M_COD_PROCESS, @M_COD_INSTANCE, 'INFORMATION', 'No Merge Action'


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
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
			SET @LOG = 'Merge load scenario - ' + ERROR_MESSAGE() + ' | '+ @SQL1
            EXEC MDAPEL.GF_004_LOG_PROCESS_INSTANCE_LOG @M_COD_PROCESS, @M_COD_INSTANCE, 'ERROR', @LOG
            EXEC MDAPEL.GF_003_LOG_PROCESS_INSTANCE U, @M_COD_PROCESS, @UTC_INSTANCE_START, 'ERROR', @PROCESS_NAME, @GF_PROCESS_NAME, @M_COD_INSTANCE
        RETURN 55555
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
BEGIN TRY

--Close process instance logging
EXEC MDAPEL.GF_003_LOG_PROCESS_INSTANCE U, @M_COD_PROCESS, @UTC_INSTANCE_START, 'FINISHED', @PROCESS_NAME, @GF_PROCESS_NAME, @M_COD_INSTANCE

END TRY
BEGIN CATCH
		SELECT ERROR_MESSAGE()
        RETURN
END CATCH

/* END: Generic PostProcess */
/**********************************************************************************/
/**********************************************************************************/
-- END: Specific Post Process
/**********************************************************************************/
/**********************************************************************************/


END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE() as ProcedureError
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	RETURN 55555
END CATCH

GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0100_HUB_UPDATE_TYPE_II_NO_SEQUENCE]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0100_HUB_UPDATE_TYPE_II_NO_SEQUENCE] 
 /* PARAMETER 1 */ @M_COD_PROCESS  BIGINT
,/* PARAMETER 2 */ @SUBJECT        NVARCHAR(100)
,/* PARAMETER 3 */ @SOURCE_SUBJECT NCHAR(6)
,/* PARAMETER 4 */ @SOURCE_ENTITY  NVARCHAR(100)
,/* PARAMETER 5 */ @TARGET_SUBJECT NCHAR(6)
,/* PARAMETER 6 */ @TARGET_ENTITY  NVARCHAR(100)
,/* PARAMETER 7 */ @M_COD_INSTANCE BIGINT
AS
BEGIN -- PROCEDURE MDAPEL.GF_0100_HUB_UPDATE_TYPE_II_NO_SEQUENCE
-- =========================================================================================
-- Author(s)          : Michael Doves
-- date Created       : 2012-04-24
-- Version            : 2
-- Date Last Modified : 2013-01-15     
-- Description        :	Generic Function to update HUB Tables Type II in OMARIC OMARIC, 
--                      without the use of sequences.
-- Parameters         :	
-- Modifications      : 2013-01-15 No temporary tables are necessary, the GF is faster and 
--                                 more robust.
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-- ========================================================================================

------------------------------------------------------------------------------------------
-- BEGIN Initialize Process Parameters 
------------------------------------------------------------------------------------------
--DECLARE @M_COD_PROCESS                          BIGINT         = 50001101
--DECLARE @M_COD_INSTANCE                         BIGINT         = 1
--DECLARE @SUBJECT                                NVARCHAR(100)  = 'EMAILADDRESS'
--DECLARE @SOURCE_SUBJECT                         NCHAR(6)       = 'DSARIC'
--DECLARE @SOURCE_ENTITY                          NVARCHAR(100)  = 'SNAPSHOT_HUB_EMAILADDRESS'
--DECLARE @TARGET_SUBJECT                         NCHAR(6)       = 'OMARIC'
--DECLARE @TARGET_ENTITY                          NVARCHAR(100)  = 'HUB_EMAILADDRESS'
DECLARE @COD_TARGET_ENTITY                      NVARCHAR(107)
    SET @COD_TARGET_ENTITY = UPPER(@TARGET_SUBJECT)+'.'+UPPER(@TARGET_ENTITY)
  PRINT @COD_TARGET_ENTITY
DECLARE @COD_SOURCE_ENTITY                      NVARCHAR(107)
    SET @COD_SOURCE_ENTITY = UPPER(@SOURCE_SUBJECT)+'.'+UPPER(@SOURCE_ENTITY)
  PRINT @COD_SOURCE_ENTITY
DECLARE @M_COD_SOR                              BIGINT
DECLARE @M_UTC_SNAPSHOT                         DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_MAX1                    DATETIME2(0) 
DECLARE @M_UTC_SNAPSHOT_MAX2                    DATETIME2(0) 
DECLARE @M_UTC_SNAPSHOT_MAX3                    DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_MAX                     DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_MIN1                    DATETIME2(0) 
DECLARE @M_UTC_SNAPSHOT_MIN2                    DATETIME2(0) 
DECLARE @M_UTC_SNAPSHOT_MIN3                    DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_MIN                     DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_PRE                     DATETIME2(0) 
DECLARE @M_UTC_SNAPSHOT_NEX                     DATETIME2(0)
DECLARE @SCENARIO                               NVARCHAR(27)
DECLARE @SQL01						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @LOG                                    NVARCHAR(MAX)
DECLARE @M_ERROR_MESSAGE                        NVARCHAR(MAX)
------------------------------------------------------------------------------------------
-- END Initialize Process Parameters 
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine the M_UTC_SNAPSHOT & M_COD_SOR to be Processed
------------------------------------------------------------------------------------------
SET @SQL01 = N'
SELECT @M_UTC_SNAPSHOT = 
  (SELECT MIN(M_UTC_SNAPSHOT) AS M_UTC_SNAPSHOT
     FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
  ) 
' -- END @SQL07

PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 
EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT OUTPUT
                     
IF @M_UTC_SNAPSHOT IS NULL 
BEGIN
  SET @M_UTC_SNAPSHOT = CONVERT(DATETIME2(0),'1000-01-01 00:00:00')
END                      

IF @M_UTC_SNAPSHOT <> CONVERT(DATETIME2(0),'1000-01-01 00:00:00')
BEGIN
SET @SQL01 = N'
SELECT @M_COD_SOR = 
  (SELECT MIN(M_COD_SOR) AS M_COD_SOR
     FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
    WHERE 1=1
      AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''' 
  ) 
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 
EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_COD_SOR BIGINT OUTPUT'
                     ,@M_COD_SOR = @M_COD_SOR OUTPUT
END

IF @M_UTC_SNAPSHOT = CONVERT(DATETIME2(0),'1000-01-01 00:00:00')
BEGIN  
  SET @M_COD_SOR = -1             
END          

PRINT '@M_UTC_SNAPSHOT = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)                 
PRINT '@M_COD_SOR = '+CONVERT(NVARCHAR(18),@M_COD_SOR)

-- BEGIN INSERT LOG
SET @LOG = '@M_COD_SOR = '+CONVERT(NVARCHAR(18),@M_COD_SOR)
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN INSERT LOG
SET @LOG = '@M_UTC_SNAPSHOT = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG
------------------------------------------------------------------------------------------
-- END Determine the M_UTC_SNAPSHOT & M_COD_SOR to be Processed
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine M_UTC_SNAPSHOT_MAX
------------------------------------------------------------------------------------------
SET @SQL01 = N'
SET @M_UTC_SNAPSHOT_MAX1 = (SELECT ISNULL(MAX(M_UTC_START),''1000-01-01 00:00:00'') AS M_UTC_SNAPSHOT_MAX1
                             FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                               WHERE 1=1
                                 AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+' 
                             )
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 
EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT_MAX1 DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT_MAX1 = @M_UTC_SNAPSHOT_MAX1 OUTPUT

SET @SQL01 = N'
SET @M_UTC_SNAPSHOT_MAX2 = (SELECT ISNULL(DATEADD(SS,1,MAX(M_UTC_END)),''1000-01-01 00:00:00'') AS M_UTC_SNAPSHOT_MAX2
                              FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                             WHERE 1=1
                               AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
							   AND M_UTC_END < ''9999-12-31 00:00:00''
                           )
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 

EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT_MAX2 DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT_MAX2 = @M_UTC_SNAPSHOT_MAX2 OUTPUT

SET @SQL01 = N'
SET @M_UTC_SNAPSHOT_MAX3 = (SELECT ISNULL(MAX(UTC_SNAPSHOT),''1000-01-01 00:00:00'') AS M_UTC_SNAPSHOT_MAX3
                              FROM MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC
                             WHERE 1=1
							   AND COD_ENTITY = '''+@COD_TARGET_ENTITY+'''
                               AND COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
                           )
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 

EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT_MAX3 DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT_MAX3 = @M_UTC_SNAPSHOT_MAX3 OUTPUT

IF @M_UTC_SNAPSHOT_MAX1 >= @M_UTC_SNAPSHOT_MAX2 AND @M_UTC_SNAPSHOT_MAX1 >= @M_UTC_SNAPSHOT_MAX3
BEGIN  
  SET @M_UTC_SNAPSHOT_MAX = @M_UTC_SNAPSHOT_MAX1          
END 
IF @M_UTC_SNAPSHOT_MAX2 >= @M_UTC_SNAPSHOT_MAX1 AND @M_UTC_SNAPSHOT_MAX2 >= @M_UTC_SNAPSHOT_MAX3
BEGIN  
  SET @M_UTC_SNAPSHOT_MAX = @M_UTC_SNAPSHOT_MAX2         
END
IF @M_UTC_SNAPSHOT_MAX3 >= @M_UTC_SNAPSHOT_MAX1 AND @M_UTC_SNAPSHOT_MAX3 >= @M_UTC_SNAPSHOT_MAX2
BEGIN  
  SET @M_UTC_SNAPSHOT_MAX = @M_UTC_SNAPSHOT_MAX3         
END
PRINT '@M_UTC_SNAPSHOT_MAX1 = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX1)
PRINT '@M_UTC_SNAPSHOT_MAX2 = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX2)
PRINT '@M_UTC_SNAPSHOT_MAX3 = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX3)
PRINT '@M_UTC_SNAPSHOT_MAX  = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX)

-- BEGIN INSERT LOG
SET @LOG = '@M_UTC_SNAPSHOT_MAX  = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX)
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG
------------------------------------------------------------------------------------------
-- END Determine M_UTC_SNAPSHOT_MAX
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine M_UTC_SNAPSHOT_MIN
------------------------------------------------------------------------------------------
SET @SQL01 = N'
SET @M_UTC_SNAPSHOT_MIN1 = (SELECT ISNULL(MIN(M_UTC_START),''9999-12-31 00:00:00'') AS M_UTC_SNAPSHOT_MIN1
                             FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                               WHERE 1=1
                                 AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+' 
                             )
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 
EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT_MIN1 DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT_MIN1 = @M_UTC_SNAPSHOT_MIN1 OUTPUT

SET @SQL01 = N'
SET @M_UTC_SNAPSHOT_MIN2 = (SELECT ISNULL(DATEADD(SS,1,MIN(M_UTC_END)),''9999-12-31 00:00:00'') AS M_UTC_SNAPSHOT_MIN2
                              FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                             WHERE 1=1
                               AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
							   AND M_UTC_END < ''9999-12-31 00:00:00''
                           )
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 

EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT_MIN2 DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT_MIN2 = @M_UTC_SNAPSHOT_MIN2 OUTPUT

SET @SQL01 = N'
SET @M_UTC_SNAPSHOT_MIN3 = (SELECT ISNULL(MIN(UTC_SNAPSHOT),''9999-12-31 00:00:00'') AS M_UTC_SNAPSHOT_MIN3
                              FROM MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC
                             WHERE 1=1
							   AND COD_ENTITY = '''+@COD_TARGET_ENTITY+'''
                               AND COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
                           )
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 

EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT_MIN3 DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT_MIN3 = @M_UTC_SNAPSHOT_MIN3 OUTPUT

IF @M_UTC_SNAPSHOT_MIN1 <= @M_UTC_SNAPSHOT_MIN2 AND @M_UTC_SNAPSHOT_MIN1 <= @M_UTC_SNAPSHOT_MIN3
BEGIN  
  SET @M_UTC_SNAPSHOT_MIN = @M_UTC_SNAPSHOT_MIN1          
END 
IF @M_UTC_SNAPSHOT_MIN2 <= @M_UTC_SNAPSHOT_MIN1 AND @M_UTC_SNAPSHOT_MIN2 <= @M_UTC_SNAPSHOT_MIN3
BEGIN  
  SET @M_UTC_SNAPSHOT_MIN = @M_UTC_SNAPSHOT_MIN2         
END
IF @M_UTC_SNAPSHOT_MIN3 <= @M_UTC_SNAPSHOT_MIN1 AND @M_UTC_SNAPSHOT_MAX3 <= @M_UTC_SNAPSHOT_MIN2
BEGIN  
  SET @M_UTC_SNAPSHOT_MIN = @M_UTC_SNAPSHOT_MIN3         
END
PRINT '@M_UTC_SNAPSHOT_MIN1 = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN1)
PRINT '@M_UTC_SNAPSHOT_MIN2 = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN2)
PRINT '@M_UTC_SNAPSHOT_MIN3 = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN3)
PRINT '@M_UTC_SNAPSHOT_MIN  = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)

-- BEGIN INSERT LOG
SET @LOG = '@M_UTC_SNAPSHOT_MIN  = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG
------------------------------------------------------------------------------------------
-- END Determine M_UTC_SNAPSHOT_MIN
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine SCENARIO of Processing
------------------------------------------------------------------------------------------
SET @SQL01 = N'
IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' = CONVERT(DATETIME2(0),''1000-01-01 00:00:00'')
  BEGIN 
    SET @SCENARIO = UPPER(''NO SOURCE DATA'')
  END

ELSE IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''     <> CONVERT(DATETIME2(0),''1000-01-01 00:00:00'')
    AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)+''' =  CONVERT(DATETIME2(0),''9999-12-31 00:00:00'')
	AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MAX)+''' =  CONVERT(DATETIME2(0),''1000-01-01 00:00:00'')
  BEGIN 
    SET @SCENARIO = UPPER(''INITIAL LOAD'')
  END

ELSE IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MAX)+''' < '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' 
  BEGIN 
    SET @SCENARIO = UPPER(''AFTER'')
  END 
  
ELSE IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)+''' > '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''
    AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''    <> CONVERT(DATETIME2(0),''1000-01-01 00:00:00'')
  BEGIN 
    SET @SCENARIO = UPPER(''BEFORE'') 
  END  
  
ELSE IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' BETWEEN '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)+'''
                                                      AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MAX)+'''
    AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' NOT IN (SELECT DISTINCT M_UTC_SNAPSHOT 
                                                            FROM (SELECT DISTINCT M_UTC_START AS M_UTC_SNAPSHOT
                                                                    FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                                                                   WHERE 1=1
                                                                     AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
																  
																  UNION

																  SELECT DISTINCT DATEADD(SS,1,M_UTC_END) AS M_UTC_SNAPSHOT
                                                                    FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                                                                   WHERE 1=1
                                                                     AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'

																  UNION

																  SELECT DISTINCT UTC_SNAPSHOT AS M_UTC_SNAPSHOT
																    FROM MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC
                                                                   WHERE 1=1
							                                         AND COD_ENTITY = '''+@COD_TARGET_ENTITY+'''
                                                                     AND COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
															     ) X
                                                         )
  BEGIN
    SET @SCENARIO = UPPER(''BETWEEN'')
  END

ELSE IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' BETWEEN '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)+'''
                                                      AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MAX)+'''
    AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''     IN (SELECT DISTINCT M_UTC_SNAPSHOT 
                                                            FROM (SELECT DISTINCT M_UTC_START AS M_UTC_SNAPSHOT
                                                                    FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                                                                   WHERE 1=1
                                                                     AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
																  
																  UNION

																  SELECT DISTINCT DATEADD(SS,1,M_UTC_END) AS M_UTC_SNAPSHOT
                                                                    FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                                                                   WHERE 1=1
                                                                     AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'

																  UNION

																  SELECT DISTINCT UTC_SNAPSHOT AS M_UTC_SNAPSHOT
																    FROM MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC
                                                                   WHERE 1=1
							                                         AND COD_ENTITY = '''+@COD_TARGET_ENTITY+'''
                                                                     AND COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
															     ) X
                                                         )
  BEGIN
    SET @SCENARIO = UPPER(''DONE'')
  END
  
ELSE     
  BEGIN
    SET @SCENARIO = UPPER(''UNKOWN'') -- terug naar Tekentafel!!!!
  END
  
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 
EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@SCENARIO NVARCHAR(27) OUTPUT'
                     ,@SCENARIO = @SCENARIO OUTPUT

-- BEGIN INSERT LOG
SET @LOG = '@SCENARIO = '+@SCENARIO
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG
------------------------------------------------------------------------------------------
-- END Determine SCENARIO of Processing
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN PRINT ALL DYNAMIC VARIABLES
------------------------------------------------------------------------------------------
PRINT '@M_COD_SOR                            = '+CONVERT(NVARCHAR(18),@M_COD_SOR)
PRINT '@M_UTC_SNAPSHOT                       = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)
PRINT '@M_UTC_SNAPSHOT_MAX                   = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX)
PRINT '@M_UTC_SNAPSHOT_MIN                   = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)
PRINT '@SCENARIO                             = '+@SCENARIO
------------------------------------------------------------------------------------------
-- END PRINT ALL DYNAMIC VARIABLES
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'INITIAL LOAD'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'INITIAL LOAD'
BEGIN

-- BEGIN INSERT LOG
SET @LOG = 'INITIAL LOAD SCENARIO STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

SET @SQL01 = N'
INSERT INTO '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
(IDC_'+@SUBJECT+'
,M_COD_SOR
,IDI_'+@SUBJECT+'
,M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
)
SELECT
 IDC_'+@SUBJECT+'
,M_COD_SOR
,IDI_'+@SUBJECT+'
,M_UTC_SNAPSHOT                           AS M_UTC_START
,CONVERT(DATETIME2(0),''9999-12-31'')     AS M_UTC_END
,'+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+' AS M_COD_PROCESS_INSERTED
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR      = '+CONVERT(NVARCHAR(18),@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
'
PRINT @SQL01
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 			 

-- BEGIN INSERT LOG
SET @LOG = 'INITIAL LOAD SCENARIO ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Snapshot records will be deleted.'
-- END INSERT LOG

SET @SQL01 = N'
DELETE 
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR      = '+CONVERT(NVARCHAR(18),@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
'
PRINT @SQL01	
		 
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 

END -- SCENARIO = 'INITIAL LOAD'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'INITIAL LOAD'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'DONE'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'DONE'
BEGIN

-- BEGIN INSERT LOG
SET @LOG = 'DONE SCENARIO STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Snapshot records will be deleted.'
-- END INSERT LOG

SET @SQL01 = N'
DELETE 
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR      = '+CONVERT(NVARCHAR(18),@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
'
PRINT @SQL01
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 			 

-- BEGIN INSERT LOG
SET @LOG = 'DONE SCENARIO ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

END
------------------------------------------------------------------------------------------
-- END SCENARIO = 'DONE'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'AFTER'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'AFTER'
BEGIN
------------------------------------------------------------------------------------------
-- is the IDC_'+@SUBJECT+' existent?
-- Subscenario Prev		Snapshot	Action
-- AFTER_01    Yes		No          Update (update M_UTC_END of PREV set to M_UTC_SNAPSHOT-1)
-- AFTER_02    No       Yes         Insert (Insert Snapshot set M_UTC_END to '9999-12-31')
-- AFTER_03	   Yes		Yes         Do Nothing
------------------------------------------------------------------------------------------

-- BEGIN INSERT LOG
SET @LOG = 'AFTER SCENARIO STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN INSERT LOG
SET @LOG = 'AFTER_01 STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN SubScenario AFTER_01:
SET @SQL01 = N'
UPDATE '+@COD_TARGET_ENTITY+'
   SET M_UTC_END = DATEADD(SS,-1,'''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''')
      ,M_COD_PROCESS_UPDATED = '+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'
 WHERE 1=1
   AND M_IDR IN (-- BEGIN AFTER_01
                 SELECT M_IDR
                   FROM (SELECT IDC_'+@SUBJECT+'
                           FROM '+@COD_SOURCE_ENTITY+'
                          WHERE 1=1
                            AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
                            AND M_COD_SOR = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''          
                        ) SRC
                        FULL OUTER JOIN
                        (SELECT M_IDR
                               ,IDC_'+@SUBJECT+'
                           FROM '+@COD_TARGET_ENTITY+'
                          WHERE 1=1
                            AND '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''' BETWEEN M_UTC_START AND M_UTC_END
							AND M_COD_SOR = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''
                        ) TRG
                        ON  SRC.IDC_'+@SUBJECT+' = TRG.IDC_'+@SUBJECT+'
                      WHERE 1=1
                        AND TRG.M_IDR               IS NOT NULL
						AND SRC.IDC_'+@SUBJECT+'    IS NULL
                -- END AFTER_01     
                )
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END SubScenario AFTER_01:

-- BEGIN INSERT LOG
SET @LOG = 'AFTER_01 ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN SubScenario AFTER_02:
-- BEGIN INSERT LOG
SET @LOG = 'AFTER_02 STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

SET @SQL01 = N'
INSERT INTO '+@COD_TARGET_ENTITY+'
(IDC_'+@SUBJECT+'
,M_COD_SOR
,IDI_'+@SUBJECT+'
,M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
)
SELECT
 IDC_'+@SUBJECT+'
,M_COD_SOR
,IDI_'+@SUBJECT+'
,M_UTC_SNAPSHOT                                AS M_UTC_START
,''9999-12-31 00:00:00''                       AS M_UTC_END
,'+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'      AS M_COD_PROCESS_INSERTED
  FROM '+@COD_SOURCE_ENTITY+' SRC
 WHERE 1=1
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
   AND M_COD_SOR = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''
   AND NOT EXISTS (SELECT M_IDR
                     FROM '+@COD_TARGET_ENTITY+' TRG
                    WHERE 1=1
					  AND SRC.M_UTC_SNAPSHOT BETWEEN TRG.M_UTC_START AND TRG.M_UTC_END
					  AND M_COD_SOR = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''
                      AND SRC.IDC_'+@SUBJECT+' = TRG.IDC_'+@SUBJECT+'
                  ) 
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 

-- BEGIN INSERT LOG
SET @LOG = 'AFTER_02 ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG
-- END SubScenario AFTER_02:

-- BEGIN INSERT LOG
SET @LOG = 'AFTER SCENARIO ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Snapshot records will be deleted.'
-- END INSERT LOG

SET @SQL01 = N'
DELETE 
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR      = '+CONVERT(NVARCHAR(18),@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
'
PRINT @SQL01			 
EXECUTE SP_EXECUTESQL @SQL01

END -- IF @SCENARIO = 'AFTER'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'AFTER'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'BEFORE'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'BEFORE'
BEGIN
------------------------------------------------------------------------------------------
-- is the IDC_'+@SUBJECT+' existent?
-- Subscenario Prev 	Snapshot	Action
-- BEFORE_01   Yes      Yes         Update (update M_UTC_START of PREV set to M_UTC_SNAPSHOT)
-- BEFORE_02   No       Yes         Insert (Insert Snapshot set M_UTC_END to M_UTC_SNAPSHOT_MIN-1)
-- BEFORE_03   Yes      No          Do Nothing
------------------------------------------------------------------------------------------

-- BEGIN INSERT LOG
SET @LOG = 'BEFORE SCENARIO STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN INSERT LOG
SET @LOG = 'BEFORE_01 STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN SubScenario BEFORE_01:
SET @SQL01 = N'
UPDATE '+@COD_TARGET_ENTITY+'
   SET M_UTC_END = DATEADD(SS,-1,'''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''')
      ,M_COD_PROCESS_UPDATED = '+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'
 WHERE 1=1
   AND M_IDR IN (-- BEGIN BEFORE_01
                 SELECT M_IDR
                   FROM (SELECT IDC_'+@SUBJECT+'
                           FROM '+@COD_SOURCE_ENTITY+'
                          WHERE 1=1
                            AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
                            AND M_COD_SOR = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''          
                        ) SRC
                        FULL OUTER JOIN
                        (SELECT M_IDR
                               ,IDC_'+@SUBJECT+'
                           FROM '+@COD_TARGET_ENTITY+'
                          WHERE 1=1
                            AND M_UTC_START = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)+'''
							AND M_COD_SOR   = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''
                        ) TRG
                        ON  SRC.IDC_'+@SUBJECT+' = TRG.IDC_'+@SUBJECT+'
                      WHERE 1=1
                        AND TRG.M_IDR               IS NOT NULL
						AND SRC.IDC_'+@SUBJECT+'    IS NOT NULL
                -- END BEFORE_01     
                )
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END SubScenario BEFORE_01:

-- BEGIN INSERT LOG
SET @LOG = 'BEFORE_01 ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN SubScenario BEFORE_02:
-- BEGIN INSERT LOG
SET @LOG = 'BEFORE_02 STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

SET @SQL01 = N'
INSERT INTO '+@COD_TARGET_ENTITY+'
(IDC_'+@SUBJECT+'
,M_COD_SOR
,IDI_'+@SUBJECT+'
,M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
)
SELECT
 IDC_'+@SUBJECT+'
,M_COD_SOR
,IDI_'+@SUBJECT+'
,M_UTC_SNAPSHOT                                                   AS M_UTC_START
,DATEADD(SS,-1,'''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)+''') AS M_UTC_END
,'+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'                         AS M_COD_PROCESS_INSERTED
  FROM '+@COD_SOURCE_ENTITY+' SRC
 WHERE 1=1
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
   AND M_COD_SOR = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''
   AND NOT EXISTS (SELECT M_IDR
                     FROM '+@COD_TARGET_ENTITY+' TRG
                    WHERE 1=1
					  AND SRC.M_UTC_SNAPSHOT BETWEEN TRG.M_UTC_START AND TRG.M_UTC_END
					  AND M_COD_SOR = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''
                      AND SRC.IDC_'+@SUBJECT+' = TRG.IDC_'+@SUBJECT+'
                  ) 
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 

-- BEGIN INSERT LOG
SET @LOG = 'BEFORE_02 ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG
-- END SubScenario AFTER_02:

-- BEGIN INSERT LOG
SET @LOG = 'BEFORE SCENARIO ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Snapshot records will be deleted.'
-- END INSERT LOG

SET @SQL01 = N'
DELETE 
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR      = '+CONVERT(NVARCHAR(18),@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
'
PRINT @SQL01			 
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 

END -- IF @SCENARIO = 'BEFORE'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'BEFORE'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'BETWEEN'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'BETWEEN'
BEGIN -- IF @SCENARIO = 'BETWEEN'
PRINT 'Dit scenario moet nog uitgewerkt worden.'

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Dit scenario moet nog uitgewerkt worden.'
-- END INSERT LOG

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Snapshot records will be deleted.'
-- END INSERT LOG

SET @SQL01 = N'
DELETE 
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR      = '+CONVERT(NVARCHAR(18),@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
'
PRINT @SQL01			 
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 

END -- IF @SCENARIO = 'BETWEEN'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'BETWEEN'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SPECIFIC POST PROCESS
------------------------------------------------------------------------------------------
-- BEGIN UPDATE METADATA
IF @SCENARIO IN ('INITIAL LOAD','AFTER','BEFORE','BETWEEN')
BEGIN 

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Insert metadata started.'
-- END INSERT LOG

BEGIN TRY
-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Insert metadata ended.'
-- END INSERT LOG

INSERT INTO MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC
(COD_ENTITY
,COD_SOR
,UTC_SNAPSHOT
)
VALUES
(@COD_TARGET_ENTITY
,@M_COD_SOR
,@M_UTC_SNAPSHOT
)
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 


END -- @SCENARIO IN ('INITIAL LOAD','AFTER','BEFORE','BETWEEN','DONE')
-- END UPDATE METADATA

------------------------------------------------------------------------------------------
-- END SPECIFIC POST PROCESS
------------------------------------------------------------------------------------------
END -- PROCEDURE MDAPEL.GF_011_HUB_UPDATE_TYPE_II_NO_SEQUENCE

GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0100_HUB_UPDATE_TYPE_II_NO_SEQUENCE IO]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0100_HUB_UPDATE_TYPE_II_NO_SEQUENCE IO] 
 /* PARAMETER 1 */ @M_COD_PROCESS  BIGINT
,/* PARAMETER 2 */ @SUBJECT        NVARCHAR(100)
,/* PARAMETER 3 */ @SOURCE_SUBJECT NCHAR(6)
,/* PARAMETER 4 */ @SOURCE_ENTITY  NVARCHAR(100)
,/* PARAMETER 5 */ @TARGET_SUBJECT NCHAR(6)
,/* PARAMETER 6 */ @TARGET_ENTITY  NVARCHAR(100)
,/* PARAMETER 7 */ @M_COD_INSTANCE BIGINT
AS
BEGIN -- PROCEDURE MDAPEL.GF_0100_HUB_UPDATE_TYPE_II_NO_SEQUENCE
-- =========================================================================================
-- Author(s)          : Michael Doves
-- date Created       : 2012-04-24
-- Version            : 3
-- Date Last Modified : 2013-01-16     
-- Description        :	Generic Function to update HUB Tables Type II in subject OMARIC, 
--                      without the use of sequences.
-- Parameters         :	/* PARAMETER 1 */ @M_COD_PROCESS  BIGINT
--                      /* PARAMETER 2 */ @SUBJECT        NVARCHAR(100)
--                      /* PARAMETER 3 */ @SOURCE_SUBJECT NCHAR(6)
--                      /* PARAMETER 4 */ @SOURCE_ENTITY  NVARCHAR(100)
--                      /* PARAMETER 5 */ @TARGET_SUBJECT NCHAR(6)
--                      /* PARAMETER 6 */ @TARGET_ENTITY  NVARCHAR(100)
--                      /* PARAMETER 7 */ @M_COD_INSTANCE BIGINT
-- Modifications      : 2013-01-15 V2 Michael Doves
--                      No temporary tables are necessary, the GF is faster and 
--                      more robust.
--                      2013-01-16 V3 Michael Doves
--                      Between Scenario added.
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-- ========================================================================================

------------------------------------------------------------------------------------------
-- BEGIN Initialize Process Parameters 
------------------------------------------------------------------------------------------
--DECLARE @M_COD_PROCESS                          BIGINT         = 50001101
--DECLARE @M_COD_INSTANCE                         BIGINT         = 1
--DECLARE @SUBJECT                                NVARCHAR(100)  = 'EMAILADDRESS'
--DECLARE @SOURCE_SUBJECT                         NCHAR(6)       = 'DSARIC'
--DECLARE @SOURCE_ENTITY                          NVARCHAR(100)  = 'SNAPSHOT_HUB_EMAILADDRESS'
--DECLARE @TARGET_SUBJECT                         NCHAR(6)       = 'OMARIC'
--DECLARE @TARGET_ENTITY                          NVARCHAR(100)  = 'HUB_EMAILADDRESS'
DECLARE @COD_TARGET_ENTITY                      NVARCHAR(107)
    SET @COD_TARGET_ENTITY = UPPER(@TARGET_SUBJECT)+'.'+UPPER(@TARGET_ENTITY)
  PRINT @COD_TARGET_ENTITY
DECLARE @COD_SOURCE_ENTITY                      NVARCHAR(107)
    SET @COD_SOURCE_ENTITY = UPPER(@SOURCE_SUBJECT)+'.'+UPPER(@SOURCE_ENTITY)
  PRINT @COD_SOURCE_ENTITY
DECLARE @M_COD_SOR                              BIGINT
DECLARE @M_UTC_SNAPSHOT                         DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_MAX1                    DATETIME2(0) 
DECLARE @M_UTC_SNAPSHOT_MAX2                    DATETIME2(0) 
DECLARE @M_UTC_SNAPSHOT_MAX3                    DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_MAX                     DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_MIN1                    DATETIME2(0) 
DECLARE @M_UTC_SNAPSHOT_MIN2                    DATETIME2(0) 
DECLARE @M_UTC_SNAPSHOT_MIN3                    DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_MIN                     DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_PRE                     DATETIME2(0) 
DECLARE @M_UTC_SNAPSHOT_NEX                     DATETIME2(0)
DECLARE @SCENARIO                               NVARCHAR(27)
DECLARE @SQL01						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @LOG                                    NVARCHAR(MAX)
DECLARE @M_ERROR_MESSAGE                        NVARCHAR(MAX)
------------------------------------------------------------------------------------------
-- END Initialize Process Parameters 
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine the M_UTC_SNAPSHOT & M_COD_SOR to be Processed
------------------------------------------------------------------------------------------
SET @SQL01 = N'
SELECT @M_UTC_SNAPSHOT = 
  (SELECT MIN(M_UTC_SNAPSHOT) AS M_UTC_SNAPSHOT
     FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
  ) 
' -- END @SQL07

PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 
EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT OUTPUT
                     
IF @M_UTC_SNAPSHOT IS NULL 
BEGIN
  SET @M_UTC_SNAPSHOT = CONVERT(DATETIME2(0),'1000-01-01 00:00:00')
END                      

IF @M_UTC_SNAPSHOT <> CONVERT(DATETIME2(0),'1000-01-01 00:00:00')
BEGIN
SET @SQL01 = N'
SELECT @M_COD_SOR = 
  (SELECT MIN(M_COD_SOR) AS M_COD_SOR
     FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
    WHERE 1=1
      AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''' 
  ) 
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 
EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_COD_SOR BIGINT OUTPUT'
                     ,@M_COD_SOR = @M_COD_SOR OUTPUT
END

IF @M_UTC_SNAPSHOT = CONVERT(DATETIME2(0),'1000-01-01 00:00:00')
BEGIN  
  SET @M_COD_SOR = -1             
END          

PRINT '@M_UTC_SNAPSHOT = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)                 
PRINT '@M_COD_SOR = '+CONVERT(NVARCHAR(18),@M_COD_SOR)

-- BEGIN INSERT LOG
SET @LOG = '@M_COD_SOR = '+CONVERT(NVARCHAR(18),@M_COD_SOR)
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN INSERT LOG
SET @LOG = '@M_UTC_SNAPSHOT = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG
------------------------------------------------------------------------------------------
-- END Determine the M_UTC_SNAPSHOT & M_COD_SOR to be Processed
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine M_UTC_SNAPSHOT_MAX
------------------------------------------------------------------------------------------
SET @SQL01 = N'
SET @M_UTC_SNAPSHOT_MAX1 = (SELECT ISNULL(MAX(M_UTC_START),''1000-01-01 00:00:00'') AS M_UTC_SNAPSHOT_MAX1
                             FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                               WHERE 1=1
                                 AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+' 
                             )
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 
EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT_MAX1 DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT_MAX1 = @M_UTC_SNAPSHOT_MAX1 OUTPUT

SET @SQL01 = N'
SET @M_UTC_SNAPSHOT_MAX2 = (SELECT ISNULL(DATEADD(SS,1,MAX(M_UTC_END)),''1000-01-01 00:00:00'') AS M_UTC_SNAPSHOT_MAX2
                              FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                             WHERE 1=1
                               AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
							   AND M_UTC_END < ''9999-12-31 00:00:00''
                           )
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 

EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT_MAX2 DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT_MAX2 = @M_UTC_SNAPSHOT_MAX2 OUTPUT

SET @SQL01 = N'
SET @M_UTC_SNAPSHOT_MAX3 = (SELECT ISNULL(MAX(UTC_SNAPSHOT),''1000-01-01 00:00:00'') AS M_UTC_SNAPSHOT_MAX3
                              FROM MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC
                             WHERE 1=1
							   AND COD_ENTITY = '''+@COD_TARGET_ENTITY+'''
                               AND COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
                           )
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 

EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT_MAX3 DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT_MAX3 = @M_UTC_SNAPSHOT_MAX3 OUTPUT

IF @M_UTC_SNAPSHOT_MAX1 >= @M_UTC_SNAPSHOT_MAX2 AND @M_UTC_SNAPSHOT_MAX1 >= @M_UTC_SNAPSHOT_MAX3
BEGIN  
  SET @M_UTC_SNAPSHOT_MAX = @M_UTC_SNAPSHOT_MAX1          
END 
IF @M_UTC_SNAPSHOT_MAX2 >= @M_UTC_SNAPSHOT_MAX1 AND @M_UTC_SNAPSHOT_MAX2 >= @M_UTC_SNAPSHOT_MAX3
BEGIN  
  SET @M_UTC_SNAPSHOT_MAX = @M_UTC_SNAPSHOT_MAX2         
END
IF @M_UTC_SNAPSHOT_MAX3 >= @M_UTC_SNAPSHOT_MAX1 AND @M_UTC_SNAPSHOT_MAX3 >= @M_UTC_SNAPSHOT_MAX2
BEGIN  
  SET @M_UTC_SNAPSHOT_MAX = @M_UTC_SNAPSHOT_MAX3         
END
PRINT '@M_UTC_SNAPSHOT_MAX1 = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX1)
PRINT '@M_UTC_SNAPSHOT_MAX2 = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX2)
PRINT '@M_UTC_SNAPSHOT_MAX3 = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX3)
PRINT '@M_UTC_SNAPSHOT_MAX  = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX)

-- BEGIN INSERT LOG
SET @LOG = '@M_UTC_SNAPSHOT_MAX  = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX)
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG
------------------------------------------------------------------------------------------
-- END Determine M_UTC_SNAPSHOT_MAX
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine M_UTC_SNAPSHOT_MIN
------------------------------------------------------------------------------------------
SET @SQL01 = N'
SET @M_UTC_SNAPSHOT_MIN1 = (SELECT ISNULL(MIN(M_UTC_START),''9999-12-31 00:00:00'') AS M_UTC_SNAPSHOT_MIN1
                             FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                               WHERE 1=1
                                 AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+' 
                             )
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 
EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT_MIN1 DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT_MIN1 = @M_UTC_SNAPSHOT_MIN1 OUTPUT

SET @SQL01 = N'
SET @M_UTC_SNAPSHOT_MIN2 = (SELECT ISNULL(DATEADD(SS,1,MIN(M_UTC_END)),''9999-12-31 00:00:00'') AS M_UTC_SNAPSHOT_MIN2
                              FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                             WHERE 1=1
                               AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
							   AND M_UTC_END < ''9999-12-31 00:00:00''
                           )
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 

EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT_MIN2 DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT_MIN2 = @M_UTC_SNAPSHOT_MIN2 OUTPUT

SET @SQL01 = N'
SET @M_UTC_SNAPSHOT_MIN3 = (SELECT ISNULL(MIN(UTC_SNAPSHOT),''9999-12-31 00:00:00'') AS M_UTC_SNAPSHOT_MIN3
                              FROM MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC
                             WHERE 1=1
							   AND COD_ENTITY = '''+@COD_TARGET_ENTITY+'''
                               AND COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
                           )
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 

EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT_MIN3 DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT_MIN3 = @M_UTC_SNAPSHOT_MIN3 OUTPUT

IF @M_UTC_SNAPSHOT_MIN1 <= @M_UTC_SNAPSHOT_MIN2 AND @M_UTC_SNAPSHOT_MIN1 <= @M_UTC_SNAPSHOT_MIN3
BEGIN  
  SET @M_UTC_SNAPSHOT_MIN = @M_UTC_SNAPSHOT_MIN1          
END 
IF @M_UTC_SNAPSHOT_MIN2 <= @M_UTC_SNAPSHOT_MIN1 AND @M_UTC_SNAPSHOT_MIN2 <= @M_UTC_SNAPSHOT_MIN3
BEGIN  
  SET @M_UTC_SNAPSHOT_MIN = @M_UTC_SNAPSHOT_MIN2         
END
IF @M_UTC_SNAPSHOT_MIN3 <= @M_UTC_SNAPSHOT_MIN1 AND @M_UTC_SNAPSHOT_MAX3 <= @M_UTC_SNAPSHOT_MIN2
BEGIN  
  SET @M_UTC_SNAPSHOT_MIN = @M_UTC_SNAPSHOT_MIN3         
END
PRINT '@M_UTC_SNAPSHOT_MIN1 = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN1)
PRINT '@M_UTC_SNAPSHOT_MIN2 = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN2)
PRINT '@M_UTC_SNAPSHOT_MIN3 = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN3)
PRINT '@M_UTC_SNAPSHOT_MIN  = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)

-- BEGIN INSERT LOG
SET @LOG = '@M_UTC_SNAPSHOT_MIN  = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG
------------------------------------------------------------------------------------------
-- END Determine M_UTC_SNAPSHOT_MIN
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine SCENARIO of Processing
------------------------------------------------------------------------------------------
SET @SQL01 = N'
IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' = CONVERT(DATETIME2(0),''1000-01-01 00:00:00'')
  BEGIN 
    SET @SCENARIO = UPPER(''NO SOURCE DATA'')
  END

ELSE IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''     <> CONVERT(DATETIME2(0),''1000-01-01 00:00:00'')
    AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)+''' =  CONVERT(DATETIME2(0),''9999-12-31 00:00:00'')
	AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MAX)+''' =  CONVERT(DATETIME2(0),''1000-01-01 00:00:00'')
  BEGIN 
    SET @SCENARIO = UPPER(''INITIAL LOAD'')
  END

ELSE IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MAX)+''' < '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' 
  BEGIN 
    SET @SCENARIO = UPPER(''AFTER'')
  END 
  
ELSE IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)+''' > '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''
    AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''    <> CONVERT(DATETIME2(0),''1000-01-01 00:00:00'')
  BEGIN 
    SET @SCENARIO = UPPER(''BEFORE'') 
  END  
  
ELSE IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' BETWEEN '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)+'''
                                                      AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MAX)+'''
    AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' NOT IN (SELECT DISTINCT M_UTC_SNAPSHOT 
                                                            FROM (SELECT DISTINCT M_UTC_START AS M_UTC_SNAPSHOT
                                                                    FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                                                                   WHERE 1=1
                                                                     AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
																  
																  UNION

																  SELECT DISTINCT DATEADD(SS,1,M_UTC_END) AS M_UTC_SNAPSHOT
                                                                    FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                                                                   WHERE 1=1
                                                                     AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'

																  UNION

																  SELECT DISTINCT UTC_SNAPSHOT AS M_UTC_SNAPSHOT
																    FROM MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC
                                                                   WHERE 1=1
							                                         AND COD_ENTITY = '''+@COD_TARGET_ENTITY+'''
                                                                     AND COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
															     ) X
                                                         )
  BEGIN
    SET @SCENARIO = UPPER(''BETWEEN'')
  END

ELSE IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' BETWEEN '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)+'''
                                                      AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MAX)+'''
    AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''     IN (SELECT DISTINCT M_UTC_SNAPSHOT 
                                                            FROM (SELECT DISTINCT M_UTC_START AS M_UTC_SNAPSHOT
                                                                    FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                                                                   WHERE 1=1
                                                                     AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
																  
																  UNION

																  SELECT DISTINCT DATEADD(SS,1,M_UTC_END) AS M_UTC_SNAPSHOT
                                                                    FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
                                                                   WHERE 1=1
                                                                     AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'

																  UNION

																  SELECT DISTINCT UTC_SNAPSHOT AS M_UTC_SNAPSHOT
																    FROM MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC
                                                                   WHERE 1=1
							                                         AND COD_ENTITY = '''+@COD_TARGET_ENTITY+'''
                                                                     AND COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
															     ) X
                                                         )
  BEGIN
    SET @SCENARIO = UPPER(''DONE'')
  END
  
ELSE     
  BEGIN
    SET @SCENARIO = UPPER(''UNKOWN'') -- terug naar Tekentafel!!!!
  END
  
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 
EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@SCENARIO NVARCHAR(27) OUTPUT'
                     ,@SCENARIO = @SCENARIO OUTPUT

-- BEGIN INSERT LOG
SET @LOG = '@SCENARIO = '+@SCENARIO
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG
------------------------------------------------------------------------------------------
-- END Determine SCENARIO of Processing
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN PRINT ALL DYNAMIC VARIABLES
------------------------------------------------------------------------------------------
PRINT '@M_COD_SOR                            = '+CONVERT(NVARCHAR(18),@M_COD_SOR)
PRINT '@M_UTC_SNAPSHOT                       = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)
PRINT '@M_UTC_SNAPSHOT_MAX                   = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX)
PRINT '@M_UTC_SNAPSHOT_MIN                   = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)
PRINT '@SCENARIO                             = '+@SCENARIO
------------------------------------------------------------------------------------------
-- END PRINT ALL DYNAMIC VARIABLES
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'INITIAL LOAD'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'INITIAL LOAD'
BEGIN

-- BEGIN INSERT LOG
SET @LOG = 'INITIAL LOAD SCENARIO STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

SET @SQL01 = N'
INSERT INTO '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
(IDC_'+@SUBJECT+'
,M_COD_SOR
,IDI_'+@SUBJECT+'
,M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
)
SELECT
 IDC_'+@SUBJECT+'
,M_COD_SOR
,IDI_'+@SUBJECT+'
,M_UTC_SNAPSHOT                           AS M_UTC_START
,CONVERT(DATETIME2(0),''9999-12-31'')     AS M_UTC_END
,'+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+' AS M_COD_PROCESS_INSERTED
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR      = '+CONVERT(NVARCHAR(18),@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
'
PRINT @SQL01
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 			 

-- BEGIN INSERT LOG
SET @LOG = 'INITIAL LOAD SCENARIO ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Snapshot records will be deleted.'
-- END INSERT LOG

SET @SQL01 = N'
DELETE 
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR      = '+CONVERT(NVARCHAR(18),@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
'
PRINT @SQL01	
		 
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 

END -- SCENARIO = 'INITIAL LOAD'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'INITIAL LOAD'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'DONE'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'DONE'
BEGIN

-- BEGIN INSERT LOG
SET @LOG = 'DONE SCENARIO STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Snapshot records will be deleted.'
-- END INSERT LOG

SET @SQL01 = N'
DELETE 
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR      = '+CONVERT(NVARCHAR(18),@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
'
PRINT @SQL01
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 			 

-- BEGIN INSERT LOG
SET @LOG = 'DONE SCENARIO ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

END
------------------------------------------------------------------------------------------
-- END SCENARIO = 'DONE'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'AFTER'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'AFTER'
BEGIN
------------------------------------------------------------------------------------------
-- is the IDC_'+@SUBJECT+' existent?
-- Subscenario Prev		Snapshot	Action
-- AFTER_01    Yes		No          Update (update M_UTC_END of PREV set to M_UTC_SNAPSHOT-1)
-- AFTER_02    No       Yes         Insert (Insert Snapshot set M_UTC_END to '9999-12-31')
-- AFTER_03	   Yes		Yes         Do Nothing
------------------------------------------------------------------------------------------

-- BEGIN INSERT LOG
SET @LOG = 'AFTER SCENARIO STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN INSERT LOG
SET @LOG = 'AFTER_01 STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN SubScenario AFTER_01:
SET @SQL01 = N'
UPDATE '+@COD_TARGET_ENTITY+'
   SET M_UTC_END = DATEADD(SS,-1,'''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''')
      ,M_COD_PROCESS_UPDATED = '+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'
 WHERE 1=1
   AND M_IDR IN (-- BEGIN AFTER_01
                 SELECT M_IDR
                   FROM (SELECT IDC_'+@SUBJECT+'
                           FROM '+@COD_SOURCE_ENTITY+'
                          WHERE 1=1
                            AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
                            AND M_COD_SOR = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''          
                        ) SRC
                        FULL OUTER JOIN
                        (SELECT M_IDR
                               ,IDC_'+@SUBJECT+'
                           FROM '+@COD_TARGET_ENTITY+'
                          WHERE 1=1
                            AND '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''' BETWEEN M_UTC_START AND M_UTC_END
							AND M_COD_SOR = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''
                        ) TRG
                        ON  SRC.IDC_'+@SUBJECT+' = TRG.IDC_'+@SUBJECT+'
                      WHERE 1=1
                        AND TRG.M_IDR               IS NOT NULL
						AND SRC.IDC_'+@SUBJECT+'    IS NULL
                -- END AFTER_01     
                )
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END SubScenario AFTER_01:

-- BEGIN INSERT LOG
SET @LOG = 'AFTER_01 ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN SubScenario AFTER_02:
-- BEGIN INSERT LOG
SET @LOG = 'AFTER_02 STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

SET @SQL01 = N'
INSERT INTO '+@COD_TARGET_ENTITY+'
(IDC_'+@SUBJECT+'
,M_COD_SOR
,IDI_'+@SUBJECT+'
,M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
)
SELECT
 IDC_'+@SUBJECT+'
,M_COD_SOR
,IDI_'+@SUBJECT+'
,M_UTC_SNAPSHOT                                AS M_UTC_START
,''9999-12-31 00:00:00''                       AS M_UTC_END
,'+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'      AS M_COD_PROCESS_INSERTED
  FROM '+@COD_SOURCE_ENTITY+' SRC
 WHERE 1=1
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
   AND M_COD_SOR = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''
   AND NOT EXISTS (SELECT M_IDR
                     FROM '+@COD_TARGET_ENTITY+' TRG
                    WHERE 1=1
					  AND SRC.M_UTC_SNAPSHOT BETWEEN TRG.M_UTC_START AND TRG.M_UTC_END
					  AND M_COD_SOR = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''
                      AND SRC.IDC_'+@SUBJECT+' = TRG.IDC_'+@SUBJECT+'
                  ) 
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 

-- BEGIN INSERT LOG
SET @LOG = 'AFTER_02 ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG
-- END SubScenario AFTER_02:

-- BEGIN INSERT LOG
SET @LOG = 'AFTER SCENARIO ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Snapshot records will be deleted.'
-- END INSERT LOG

SET @SQL01 = N'
DELETE 
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR      = '+CONVERT(NVARCHAR(18),@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
'
PRINT @SQL01			 
EXECUTE SP_EXECUTESQL @SQL01

END -- IF @SCENARIO = 'AFTER'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'AFTER'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'BEFORE'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'BEFORE'
BEGIN
------------------------------------------------------------------------------------------
-- is the IDC_'+@SUBJECT+' existent?
-- Subscenario Prev 	Snapshot	Action
-- BEFORE_01   Yes      Yes         Update (update M_UTC_START of PREV set to M_UTC_SNAPSHOT)
-- BEFORE_02   No       Yes         Insert (Insert Snapshot set M_UTC_END to M_UTC_SNAPSHOT_MIN-1)
-- BEFORE_03   Yes      No          Do Nothing
------------------------------------------------------------------------------------------

-- BEGIN INSERT LOG
SET @LOG = 'BEFORE SCENARIO STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN INSERT LOG
SET @LOG = 'BEFORE_01 STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN SubScenario BEFORE_01:
SET @SQL01 = N'
UPDATE '+@COD_TARGET_ENTITY+'
   SET M_UTC_END = DATEADD(SS,-1,'''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''')
      ,M_COD_PROCESS_UPDATED = '+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'
 WHERE 1=1
   AND M_IDR IN (-- BEGIN BEFORE_01
                 SELECT M_IDR
                   FROM (SELECT IDC_'+@SUBJECT+'
                           FROM '+@COD_SOURCE_ENTITY+'
                          WHERE 1=1
                            AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
                            AND M_COD_SOR = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''          
                        ) SRC
                        FULL OUTER JOIN
                        (SELECT M_IDR
                               ,IDC_'+@SUBJECT+'
                           FROM '+@COD_TARGET_ENTITY+'
                          WHERE 1=1
                            AND M_UTC_START = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)+'''
							AND M_COD_SOR   = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''
                        ) TRG
                        ON  SRC.IDC_'+@SUBJECT+' = TRG.IDC_'+@SUBJECT+'
                      WHERE 1=1
                        AND TRG.M_IDR               IS NOT NULL
						AND SRC.IDC_'+@SUBJECT+'    IS NOT NULL
                -- END BEFORE_01     
                )
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END SubScenario BEFORE_01:

-- BEGIN INSERT LOG
SET @LOG = 'BEFORE_01 ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN SubScenario BEFORE_02:
-- BEGIN INSERT LOG
SET @LOG = 'BEFORE_02 STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

SET @SQL01 = N'
INSERT INTO '+@COD_TARGET_ENTITY+'
(IDC_'+@SUBJECT+'
,M_COD_SOR
,IDI_'+@SUBJECT+'
,M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
)
SELECT
 IDC_'+@SUBJECT+'
,M_COD_SOR
,IDI_'+@SUBJECT+'
,M_UTC_SNAPSHOT                                                   AS M_UTC_START
,DATEADD(SS,-1,'''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)+''') AS M_UTC_END
,'+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'                         AS M_COD_PROCESS_INSERTED
  FROM '+@COD_SOURCE_ENTITY+' SRC
 WHERE 1=1
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
   AND M_COD_SOR = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''
   AND NOT EXISTS (SELECT M_IDR
                     FROM '+@COD_TARGET_ENTITY+' TRG
                    WHERE 1=1
					  AND SRC.M_UTC_SNAPSHOT BETWEEN TRG.M_UTC_START AND TRG.M_UTC_END
					  AND M_COD_SOR = '''+CONVERT(NVARCHAR(18),@M_COD_SOR)+'''
                      AND SRC.IDC_'+@SUBJECT+' = TRG.IDC_'+@SUBJECT+'
                  ) 
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 

-- BEGIN INSERT LOG
SET @LOG = 'BEFORE_02 ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG
-- END SubScenario AFTER_02:

-- BEGIN INSERT LOG
SET @LOG = 'BEFORE SCENARIO ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Snapshot records will be deleted.'
-- END INSERT LOG

SET @SQL01 = N'
DELETE 
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR      = '+CONVERT(NVARCHAR(18),@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
'
PRINT @SQL01			 
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 

END -- IF @SCENARIO = 'BEFORE'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'BEFORE'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'BETWEEN'
------------------------------------------------------------------------------------------
-- Voor Scenario 4 is het het beste om toch een temporary table aan te maken.
-- en vanuit deze tabel de subscenario's uit te voeren.
IF @SCENARIO = 'BETWEEN'
BEGIN -- IF @SCENARIO = 'BETWEEN'

-- BEGIN INSERT LOG
SET @LOG = 'BETWEEN SCENARIO STARTED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

--------------------------------------------------------
-- BEGIN DETERMINE @M_UTC_SNAPSHOT_PRE
--------------------------------------------------------
-- @M_UTC_SNAPSHOT_PRE en @M_UTC_SNAPSHOT_NEX baseren op de metadata omdat niet iedere snapshot hoeft te leiden tot
-- een verandering of een resultaat in target hub tabel.
SET @SQL01 = N'
SET @M_UTC_SNAPSHOT_PRE = (SELECT ISNULL(MAX(UTC_SNAPSHOT),''1000-01-01 00:00:00'') AS M_UTC_SNAPSHOT_PRE
                             FROM MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC
                            WHERE 1=1
							  AND COD_ENTITY = '''+@COD_TARGET_ENTITY+'''
                              AND COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
							  AND UTC_SNAPSHOT < '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
                           )
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 

EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT_PRE DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT_PRE = @M_UTC_SNAPSHOT_PRE OUTPUT
PRINT @M_UTC_SNAPSHOT_PRE
--------------------------------------------------------
-- END DETERMINE @M_UTC_SNAPSHOT_PRE
--------------------------------------------------------

--------------------------------------------------------
-- BEGIN DETERMINE @M_UTC_SNAPSHOT_NEX
--------------------------------------------------------
SET @SQL01 = N'
SET @M_UTC_SNAPSHOT_NEX = (SELECT ISNULL(MIN(UTC_SNAPSHOT),''1000-01-01 00:00:00'') AS M_UTC_SNAPSHOT_NEX
                             FROM MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC
                            WHERE 1=1
							  AND COD_ENTITY = '''+@COD_TARGET_ENTITY+'''
                              AND COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
							  AND UTC_SNAPSHOT > '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
                           )
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 

EXECUTE SP_EXECUTESQL @SQL01
                     ,N'@M_UTC_SNAPSHOT_NEX DATETIME2(0) OUTPUT'
					 ,@M_UTC_SNAPSHOT_NEX = @M_UTC_SNAPSHOT_NEX OUTPUT
PRINT @M_UTC_SNAPSHOT_NEX
--------------------------------------------------------
-- END DETERMINE @M_UTC_SNAPSHOT_NEX
--------------------------------------------------------

------------------------------------------------------------------------------------------
-- is the IDC_'+@SUBJECT+' existent?
-- Subscenario  PRE SNP NEX  Action
-- BETWEEN_01   Yes No  No   Update (set PRE.M_UTC_END = M_UTC_SNAPSHOT-1)
-- BETWEEN_02   No  Yes Yes  Update (set NEX.M_UTC_START = M_UTC_SNAPSHOT)
-- BETWEEN_03   No  Yes No   Insert (SNP.M_UTC_START = M_UTC_SNAPSHOT, SNP.M_UTC_END = M_UTC_SNAPSHOT_NEX-1)
-- For the last Subscenario a temporary table is necessary to update all 
-- BETWEEN_04   Yes No  Yes  Update (set NEX.M_UTC_START = M_UTC_SNAPSHOT_NEX)
--                           Insert (set PRE.M_UTC_START = PRE.M_UTC_START PRE.M_UTC_END = M_UTC_SNAPSHOT-1)
-- BETWEEN_05   Yes Yes Yes  Do Nothing 
-- BETWEEN_06   Yes Yes No   Do Nothing
-- BETWEEN_07   No  No  No   Do Nothing
-- BETWEEN_08   No  No  Yes  Do Nothing
------------------------------------------------------------------------------------------

-- BEGIN SubScenario BETWEEN_01:
SET @SQL01 = N'
UPDATE '+@COD_TARGET_ENTITY+'
   SET M_UTC_END = DATEADD(SS,-1,'''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''')
      ,M_COD_PROCESS_UPDATED = '+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'
 WHERE 1=1
   AND M_IDR IN (-- BEGIN IN
                 SELECT M_IDR
                   FROM (
				         -- BEGIN Y
                         SELECT ISNULL(IDC_'+@SUBJECT+',IDC_'+@SUBJECT+'_NEX) AS IDC_'+@SUBJECT+'
						       ,M_IDR_PRE AS M_IDR
                               ,IDC_'+@SUBJECT+'_PRE
                               ,M_UTC_START_PRE
                               ,M_UTC_END_PRE
                               ,IDC_'+@SUBJECT+'_SNP
                               ,M_UTC_SNAPSHOT_SNP
                               ,M_IDR_NEX
                               ,IDC_'+@SUBJECT+'_NEX
                               ,M_UTC_START_NEX
                               ,M_UTC_END_NEX
                           FROM
                        (
                        -- BEGIN X
                          SELECT M_IDR_PRE
                                ,IDC_'+@SUBJECT+'_PRE
                                ,M_UTC_START_PRE
                                ,M_UTC_END_PRE
                                ,IDC_'+@SUBJECT+'_SNP
                                ,M_UTC_SNAPSHOT_SNP
                                ,ISNULL(IDC_'+@SUBJECT+'_PRE,IDC_'+@SUBJECT+'_SNP) AS IDC_'+@SUBJECT+'
                            FROM (
                                 -- BEGIN PRE
                                   SELECT M_IDR AS M_IDR_PRE
                                         ,IDC_'+@SUBJECT+' AS IDC_'+@SUBJECT+'_PRE
                                         ,M_UTC_START AS M_UTC_START_PRE
                                         ,M_UTC_END   AS M_UTC_END_PRE
                                     FROM OMARIC.HUB_'+@SUBJECT+'
                                    WHERE 1=1
                                      AND '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_PRE)+''' BETWEEN M_UTC_START AND M_UTC_END
                                      AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
                                 -- END PRE
                                 ) PRE

                                 FULL OUTER JOIN

                                (
                                -- BEGIN SNP								
                                  SELECT IDC_'+@SUBJECT+' AS IDC_'+@SUBJECT+'_SNP
                                        ,M_UTC_SNAPSHOT AS M_UTC_SNAPSHOT_SNP
                                    FROM DSARIC.SNAPSHOT_HUB_'+@SUBJECT+'
                                   WHERE 1=1
                                     AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
                                     AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
                                -- END SNP
                                ) SNP
                                ON PRE.IDC_'+@SUBJECT+'_PRE = SNP.IDC_'+@SUBJECT+'_SNP
                        -- END X
                        ) X 

                        FULL OUTER JOIN
    
                        (
                        -- BEGIN NEX
                          SELECT M_IDR AS M_IDR_NEX
                                ,IDC_'+@SUBJECT+' AS IDC_'+@SUBJECT+'_NEX
                                ,M_UTC_START AS M_UTC_START_NEX
                                ,M_UTC_END AS M_UTC_END_NEX
                            FROM OMARIC.HUB_'+@SUBJECT+'
                           WHERE 1=1
                             AND '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_NEX)+''' BETWEEN M_UTC_START AND M_UTC_END
                             AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
                         -- END NEX
                         ) NEX
                         ON X.IDC_'+@SUBJECT+' = NEX.IDC_'+@SUBJECT+'_NEX
                         WHERE 1=1
                           AND IDC_'+@SUBJECT+'_PRE IS NOT NULL  -- Yes
                           AND IDC_'+@SUBJECT+'_SNP IS NULL      -- No
                           AND IDC_'+@SUBJECT+'_NEX IS NULL      -- No
                         -- END Y
                        ) Y 
                -- END IN					  
                )
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END SubScenario BETWEEN_01:

-- BEGIN SubScenario BETWEEN_02:
SET @SQL01 = N'
UPDATE '+@COD_TARGET_ENTITY+'
   SET M_UTC_START = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
      ,M_COD_PROCESS_UPDATED = '+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'
 WHERE 1=1
   AND M_IDR IN (-- BEGIN IN
                 SELECT M_IDR
                   FROM (
				         -- BEGIN Y
                         SELECT ISNULL(IDC_'+@SUBJECT+',IDC_'+@SUBJECT+'_NEX) AS IDC_'+@SUBJECT+'
						       ,M_IDR_PRE 
                               ,IDC_'+@SUBJECT+'_PRE
                               ,M_UTC_START_PRE
                               ,M_UTC_END_PRE
                               ,IDC_'+@SUBJECT+'_SNP
                               ,M_UTC_SNAPSHOT_SNP
                               ,M_IDR_NEX AS M_IDR
                               ,IDC_'+@SUBJECT+'_NEX
                               ,M_UTC_START_NEX
                               ,M_UTC_END_NEX
                           FROM
                        (
                        -- BEGIN X
                          SELECT M_IDR_PRE
                                ,IDC_'+@SUBJECT+'_PRE
                                ,M_UTC_START_PRE
                                ,M_UTC_END_PRE
                                ,IDC_'+@SUBJECT+'_SNP
                                ,M_UTC_SNAPSHOT_SNP
                                ,ISNULL(IDC_'+@SUBJECT+'_PRE,IDC_'+@SUBJECT+'_SNP) AS IDC_'+@SUBJECT+'
                            FROM (
                                 -- BEGIN PRE
                                   SELECT M_IDR AS M_IDR_PRE
                                         ,IDC_'+@SUBJECT+' AS IDC_'+@SUBJECT+'_PRE
                                         ,M_UTC_START AS M_UTC_START_PRE
                                         ,M_UTC_END   AS M_UTC_END_PRE
                                     FROM OMARIC.HUB_'+@SUBJECT+'
                                    WHERE 1=1
                                      AND '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_PRE)+''' BETWEEN M_UTC_START AND M_UTC_END
                                      AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
                                 -- END PRE
                                 ) PRE

                                 FULL OUTER JOIN

                                (
                                -- BEGIN SNP								
                                  SELECT IDC_'+@SUBJECT+' AS IDC_'+@SUBJECT+'_SNP
                                        ,M_UTC_SNAPSHOT AS M_UTC_SNAPSHOT_SNP
                                    FROM DSARIC.SNAPSHOT_HUB_'+@SUBJECT+'
                                   WHERE 1=1
                                     AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
                                     AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
                                -- END SNP
                                ) SNP
                                ON PRE.IDC_'+@SUBJECT+'_PRE = SNP.IDC_'+@SUBJECT+'_SNP
                        -- END X
                        ) X 

                        FULL OUTER JOIN
    
                        (
                        -- BEGIN NEX
                          SELECT M_IDR AS M_IDR_NEX
                                ,IDC_'+@SUBJECT+' AS IDC_'+@SUBJECT+'_NEX
                                ,M_UTC_START AS M_UTC_START_NEX
                                ,M_UTC_END AS M_UTC_END_NEX
                            FROM OMARIC.HUB_'+@SUBJECT+'
                           WHERE 1=1
                             AND '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_NEX)+''' BETWEEN M_UTC_START AND M_UTC_END
                             AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
                         -- END NEX
                         ) NEX
                         ON X.IDC_'+@SUBJECT+' = NEX.IDC_'+@SUBJECT+'_NEX
                         WHERE 1=1
                           AND IDC_'+@SUBJECT+'_PRE IS NULL      -- No
                           AND IDC_'+@SUBJECT+'_SNP IS NOT NULL  -- Yes
                           AND IDC_'+@SUBJECT+'_NEX IS NOT NULL  -- Yes
                         -- END Y
                        ) Y 
                -- END IN					  
                )
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END SubScenario BETWEEN_02:

-- BEGIN SubScenario BETWEEN_03:
SET @SQL01 = N'
INSERT INTO '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
(IDC_'+@SUBJECT+'
,M_COD_SOR
,IDI_'+@SUBJECT+'
,M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
)
SELECT
 IDC_'+@SUBJECT+'
,'+CONVERT(NVARCHAR,@M_COD_SOR)+' AS M_COD_SOR
,IDI_'+@SUBJECT+'
,'''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''                        AS M_UTC_START
,DATEADD(SS,-1,'''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_NEX)+''')     AS M_UTC_END
,'+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'                             AS M_COD_PROCESS_INSERTED
  FROM 
      (
      -- BEGIN Y
       SELECT ISNULL(IDC_'+@SUBJECT+',IDC_'+@SUBJECT+'_NEX) AS IDC_'+@SUBJECT+'
             ,IDI_'+@SUBJECT+'_SNP
         FROM
             (
             -- BEGIN X
                SELECT M_IDR_PRE
                      ,IDC_'+@SUBJECT+'_PRE
                      ,M_UTC_START_PRE
                      ,M_UTC_END_PRE
                      ,IDC_'+@SUBJECT+'_SNP
                      ,IDI_'+@SUBJECT+'_SNP
                      ,M_UTC_SNAPSHOT_SNP
                      ,ISNULL(IDC_'+@SUBJECT+'_PRE,IDC_'+@SUBJECT+'_SNP) AS IDC_'+@SUBJECT+'
                  FROM (
                       -- BEGIN PRE
                          SELECT M_IDR AS M_IDR_PRE
                                ,IDC_'+@SUBJECT+' AS IDC_'+@SUBJECT+'_PRE
                                ,M_UTC_START AS M_UTC_START_PRE
                                ,M_UTC_END   AS M_UTC_END_PRE
                            FROM OMARIC.HUB_'+@SUBJECT+'
                            WHERE 1=1
                              AND '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_PRE)+''' BETWEEN M_UTC_START AND M_UTC_END
                              AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
                       -- END PRE
                       ) PRE

                   FULL OUTER JOIN
				   
				       (
                       -- BEGIN SNP								
                          SELECT IDC_'+@SUBJECT+' AS IDC_'+@SUBJECT+'_SNP
					            ,IDI_'+@SUBJECT+' AS IDI_'+@SUBJECT+'_SNP
                                ,M_UTC_SNAPSHOT AS M_UTC_SNAPSHOT_SNP
                            FROM DSARIC.SNAPSHOT_HUB_'+@SUBJECT+'
                           WHERE 1=1
                             AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
                             AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
                       -- END SNP
                       ) SNP
                    ON PRE.IDC_'+@SUBJECT+'_PRE = SNP.IDC_'+@SUBJECT+'_SNP
             -- END X
             ) X 

            FULL OUTER JOIN
    
            (
            -- BEGIN NEX
               SELECT M_IDR AS M_IDR_NEX
                     ,IDC_'+@SUBJECT+' AS IDC_'+@SUBJECT+'_NEX
                     ,M_UTC_START AS M_UTC_START_NEX
                     ,M_UTC_END AS M_UTC_END_NEX
                 FROM OMARIC.HUB_'+@SUBJECT+'
                WHERE 1=1
                  AND '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_NEX)+''' BETWEEN M_UTC_START AND M_UTC_END
                  AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
            -- END NEX
            ) NEX
            ON X.IDC_'+@SUBJECT+' = NEX.IDC_'+@SUBJECT+'_NEX
         WHERE 1=1
           AND IDC_'+@SUBJECT+'_PRE IS NULL      -- No
           AND IDC_'+@SUBJECT+'_SNP IS NOT NULL  -- Yes
           AND IDC_'+@SUBJECT+'_NEX IS NULL      -- No
      -- END Y
      ) Y 
'
PRINT @SQL01
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END SubScenario BETWEEN_03:


-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Snapshot records will be deleted.'
-- END INSERT LOG

SET @SQL01 = N'
DELETE 
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR      = '+CONVERT(NVARCHAR(18),@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
'
PRINT @SQL01			 
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL01
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 

-- BEGIN INSERT LOG
SET @LOG = 'BETWEEN SCENARIO ENDED'
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG

END -- IF @SCENARIO = 'BETWEEN'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'BETWEEN'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SPECIFIC POST PROCESS
------------------------------------------------------------------------------------------
-- BEGIN UPDATE METADATA
IF @SCENARIO IN ('INITIAL LOAD','AFTER','BEFORE','BETWEEN')
BEGIN 

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Insert metadata started.'
-- END INSERT LOG

BEGIN TRY
-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Insert metadata ended.'
-- END INSERT LOG

INSERT INTO MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC
(COD_ENTITY
,COD_SOR
,UTC_SNAPSHOT
)
VALUES
(@COD_TARGET_ENTITY
,@M_COD_SOR
,@M_UTC_SNAPSHOT
)
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL01)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 


END -- @SCENARIO IN ('INITIAL LOAD','AFTER','BEFORE','BETWEEN','DONE')
-- END UPDATE METADATA

------------------------------------------------------------------------------------------
-- END SPECIFIC POST PROCESS
------------------------------------------------------------------------------------------
END -- PROCEDURE MDAPEL.GF_011_HUB_UPDATE_TYPE_II_NO_SEQUENCE

GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0110_LNK_UPDATE_TYPE_II]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0110_LNK_UPDATE_TYPE_II]
 /* PARAMETER 1 */ @M_COD_PROCESS  BIGINT
,/* PARAMETER 2 */ @M_COD_INSTANCE BIGINT
,/* PARAMETER 3 */ @SUBJECT1       NVARCHAR(100)
,/* PARAMETER 4 */ @SUBJECT2       NVARCHAR(100)
,/* PARAMETER 5 */ @SOURCE_SUBJECT NCHAR(6)
,/* PARAMETER 6 */ @SOURCE_ENTITY  NVARCHAR(100)
,/* PARAMETER 7 */ @TARGET_SUBJECT NCHAR(6) 
,/* PARAMETER 8 */ @TARGET_ENTITY  NVARCHAR(100)
AS
BEGIN -- PROCEDURE MDAPEL.GF_0110_LNK_UPDATE_TYPE_II
------------------------------------------------------------------------------------------
-- =========================================================================================
-- Author(s)          : Michael Doves
-- date Created       : 2012-12-30
-- Version            : 1
-- Date Last Modified : 2012-12-30     
-- Description        :	Generic Function to update LNK Tables Type II in OMARIC
-- Parameters         :	
-- Modifications      : 
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-- ========================================================================================
------------------------------------------------------------------------------------------
-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Generic Function MDAPEL.GF_0110_LNK_UPDATE_TYPE_II is called'
-- END INSERT LOG

--------------------------------------------------------------
-- BEGIN test Process Parameters 
--------------------------------------------------------------
-- PARAMETER 1 DECLARE @M_COD_PROCESS  BIGINT = 50003099
-- PARAMETER 2 DECLARE @M_COD_INSTANCE BIGINT = 1
-- PARAMETER 3 DECLARE @SUBJECT1       NVARCHAR(100) = 'ORGANIZATION'
-- PARAMETER 4 DECLARE @SUBJECT2       NVARCHAR(100) = 'PERSON'
-- PARAMETER 5 DECLARE @SOURCE_SUBJECT NCHAR(6)      = 'DSARIC'
-- PARAMETER 6 DECLARE @SOURCE_ENTITY  NVARCHAR(100) = 'SNAPSHOT_LNK_ORGANIZATION_PERSON'
-- PARAMETER 7 DECLARE @TARGET_SUBJECT NCHAR(6)      = 'OMARIC'
-- PARAMETER 8 DECLARE @TARGET_ENTITY  NVARCHAR(100) = 'LNK_ORGANIZATION_PERSON'
--------------------------------------------------------------
-- END test Process Parameters 
--------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Declare Process Parameters 
------------------------------------------------------------------------------------------
DECLARE @COD_SOURCE_ENTITY                      NVARCHAR(207)
DECLARE @COD_TARGET_ENTITY                      NVARCHAR(207)
DECLARE @M_COD_SOR                              BIGINT
DECLARE @M_UTC_SNAPSHOT                         DATETIME2(0)
DECLARE @NUMBER_OF_SNAPSHOTS_TARGET             BIGINT
DECLARE @NUMBER_OF_SNAPSHOTS_SOURCE             BIGINT
DECLARE @M_UTC_SNAPSHOT_MAX                     DATETIME2(0) 
DECLARE @M_UTC_SNAPSHOT_MIN                     DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_PRE                     DATETIME2(0) 
DECLARE @M_UTC_SNAPSHOT_NEX                     DATETIME2(0)
DECLARE @SCENARIO                               NVARCHAR(27)
DECLARE @M_COD_SCENARIO                         BIGINT
DECLARE @COD_ASSOCIATION                        BIGINT
DECLARE @LOG                                    NVARCHAR(MAX)
DECLARE @M_ERROR_MESSAGE                        NVARCHAR(MAX)
DECLARE @SQL1 						            NVARCHAR(MAX)
------------------------------------------------------------------------------------------
-- END Declare Process Parameters 
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Initialize Process Parameters 
------------------------------------------------------------------------------------------
SET @COD_SOURCE_ENTITY = UPPER(@SOURCE_SUBJECT)+'.'+UPPER(@SOURCE_ENTITY)
PRINT '@COD_SOURCE_ENTITY = '+CONVERT(NVARCHAR(207),@COD_SOURCE_ENTITY)

SET @COD_TARGET_ENTITY = UPPER(@TARGET_SUBJECT)+'.'+UPPER(@TARGET_ENTITY)
PRINT '@COD_TARGET_ENTITY = '+CONVERT(NVARCHAR(207),@COD_TARGET_ENTITY)
------------------------------------------------------------------------------------------
-- END Initialize Process Parameters 
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN determine NUMBER_OF_SNAPSHOTS_SOURCE
------------------------------------------------------------------------------------------
BEGIN TRY
  SET @SQL1 = N'SELECT @NUMBER_OF_SNAPSHOTS_SOURCE = (SELECT COUNT(1) AS NUMBER_OF_SNAPSHOTS_SOURCE
                                                        FROM (SELECT DISTINCT M_UTC_SNAPSHOT
                                                                          ,COD_ASSOCIATION
                                                                          ,M_COD_SCENARIO
                                                               FROM '+@COD_SOURCE_ENTITY+'
                                                             ) A
													 )
		       ' 
EXECUTE SP_EXECUTESQL @SQL1, N'@NUMBER_OF_SNAPSHOTS_SOURCE BIGINT OUTPUT', @NUMBER_OF_SNAPSHOTS_SOURCE = @NUMBER_OF_SNAPSHOTS_SOURCE OUTPUT
PRINT '@NUMBER_OF_SNAPSHOTS_SOURCE = '+CONVERT(NVARCHAR(18),@NUMBER_OF_SNAPSHOTS_SOURCE)
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE())
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN
END CATCH
------------------------------------------------------------------------------------------
-- END determine NUMBER_OF_SNAPSHOTS_SOURCE
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SELECT 1 SNAPSHOT TO PROCESS
------------------------------------------------------------------------------------------
-- If there are more than 1 snapshot to be processed the oldest will be processed.
BEGIN TRY

SET @SQL1 = N'SELECT @M_UTC_SNAPSHOT = ISNULL(MIN(M_UTC_SNAPSHOT),CONVERT(DATETIME2(0),''1000-04-04''))
                FROM '+@COD_SOURCE_ENTITY+'
             '
EXECUTE SP_EXECUTESQL @SQL1, N'@M_UTC_SNAPSHOT DATETIME2(0) OUTPUT', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT OUTPUT
PRINT '@M_UTC_SNAPSHOT = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)

SET @SQL1 = N'SELECT @COD_ASSOCIATION = ISNULL(MIN(COD_ASSOCIATION),-4)
                FROM '+@COD_SOURCE_ENTITY+'
               WHERE 1=1
			     AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
             '
EXECUTE SP_EXECUTESQL @SQL1, N'@COD_ASSOCIATION BIGINT OUTPUT', @COD_ASSOCIATION = @COD_ASSOCIATION OUTPUT
PRINT '@COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)

SET @SQL1 = N'SELECT @M_COD_SCENARIO = ISNULL(MIN(M_COD_SCENARIO),-4)
                FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
               WHERE 1=1
			     AND M_UTC_SNAPSHOT  = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
				 AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
             '
EXECUTE SP_EXECUTESQL @SQL1, N'@M_COD_SCENARIO BIGINT OUTPUT', @M_COD_SCENARIO = @M_COD_SCENARIO OUTPUT
PRINT '@M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO )

SET @LOG = 'The snapshot with M_UTC_SNAPSHOT = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+' and COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+' and M_COD_SCENARIO = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+' will be processed.'
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
------------------------------------------------------------------------------------------
-- END SELECT 1 SNAPSHOT TO PROCESS
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN determine NUMBER_OF_SNAPSHOTS_TARGET
------------------------------------------------------------------------------------------
BEGIN TRY
  SET @SQL1 = N'SELECT @NUMBER_OF_SNAPSHOTS_TARGET = (SELECT COUNT(1) AS NUMBER_OF_SNAPSHOTS_TARGET
                                                        FROM (SELECT DISTINCT M_UTC_START AS M_UTC_SNAPSHOT
                                                               FROM '+@COD_TARGET_ENTITY+'
                                                              WHERE 1=1
															    AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
																AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'

																UNION -- deduplicates also

															 SELECT DISTINCT DATEADD(SS,1,M_UTC_END) AS M_UTC_SNAPSHOT
                                                               FROM '+@COD_TARGET_ENTITY+'
                                                              WHERE 1=1
															    AND M_UTC_END < CONVERT(DATETIME2(0),''9999-12-31'')
															    AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
																AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
                                                             ) A
													 )
		       '
EXECUTE SP_EXECUTESQL @SQL1, N'@NUMBER_OF_SNAPSHOTS_TARGET BIGINT OUTPUT', @NUMBER_OF_SNAPSHOTS_TARGET = @NUMBER_OF_SNAPSHOTS_TARGET OUTPUT
PRINT '@NUMBER_OF_SNAPSHOTS_TARGET = '+CONVERT(NVARCHAR(18),@NUMBER_OF_SNAPSHOTS_TARGET)
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE())
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN
END CATCH
------------------------------------------------------------------------------------------
-- END determine NUMBER_OF_SNAPSHOTS_TARGET
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine M_UTC_SNAPSHOT_MAX from TARGET Table
------------------------------------------------------------------------------------------
BEGIN TRY
SET @SQL1=
N'(SELECT @M_UTC_SNAPSHOT_MAX =  ISNULL(MAX(X.M_UTC_SNAPSHOT),CONVERT(DATETIME2(0),''1000-04-04''))
     FROM (SELECT MAX(M_UTC_START) AS M_UTC_SNAPSHOT
			 FROM '+@COD_TARGET_ENTITY+'
            WHERE 1=1
			  AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
			  AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'

            UNION

           SELECT MAX(DATEADD(SS,1,M_UTC_END)) AS M_UTC_SNAPSHOT
             FROM '+@COD_TARGET_ENTITY+'
            WHERE 1=1
			  AND M_UTC_END < CONVERT(DATETIME2(0),''9999-12-31'')
			  AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
			  AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
           ) X
	)'
EXECUTE SP_EXECUTESQL @SQL1, N'@M_UTC_SNAPSHOT_MAX DATETIME2(0) OUTPUT', @M_UTC_SNAPSHOT_MAX = @M_UTC_SNAPSHOT_MAX OUTPUT
PRINT '@M_UTC_SNAPSHOT_MAX = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX)
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
------------------------------------------------------------------------------------------
-- END Determine M_UTC_SNAPSHOT_MAX from TARGET Table
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine M_UTC_SNAPSHOT_MIN from TARGET Table
------------------------------------------------------------------------------------------
BEGIN TRY
SET @SQL1=
N'(SELECT @M_UTC_SNAPSHOT_MIN =  ISNULL(MIN(X.M_UTC_SNAPSHOT),CONVERT(DATETIME2(0),''1000-04-04''))
     FROM (SELECT MIN(M_UTC_START) AS M_UTC_SNAPSHOT
			 FROM '+@COD_TARGET_ENTITY+'
            WHERE 1=1
			  AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
			  AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'

            UNION

           SELECT MIN(DATEADD(SS,1,M_UTC_END)) AS M_UTC_SNAPSHOT
             FROM '+@COD_TARGET_ENTITY+'
            WHERE 1=1
			  AND M_UTC_END < CONVERT(DATETIME2(0),''9999-12-31'')
			  AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
			  AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
           ) X
	)'
EXECUTE SP_EXECUTESQL @SQL1, N'@M_UTC_SNAPSHOT_MIN DATETIME2(0) OUTPUT', @M_UTC_SNAPSHOT_MIN = @M_UTC_SNAPSHOT_MIN OUTPUT
PRINT '@M_UTC_SNAPSHOT_MIN = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
------------------------------------------------------------------------------------------
-- END Determine M_UTC_SNAPSHOT_MIN from TARGET Table
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine SCENARIO of Processing
------------------------------------------------------------------------------------------
SET @SQL1 = N'
IF      '+CONVERT(NVARCHAR(18),@NUMBER_OF_SNAPSHOTS_SOURCE)+' = 0
  AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' = CONVERT(DATETIME2(0),''1000-04-04'')
  BEGIN 
    SET @SCENARIO = UPPER(''NO SOURCE DATA'')
  END

ELSE IF '+CONVERT(NVARCHAR,@NUMBER_OF_SNAPSHOTS_TARGET)+' = 0
    AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' <> CONVERT(DATETIME2(0),''1000-04-04'')
  BEGIN 
    SET @SCENARIO = UPPER(''INITIAL LOAD'')
  END

ELSE IF '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX)+''' < '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''' 
  BEGIN 
    SET @SCENARIO = UPPER(''AFTER'')
  END 
  
ELSE IF '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)+''' > '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
    AND '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''' <> CONVERT(DATETIME2(0),''1000-04-04'')
  BEGIN 
    SET @SCENARIO = UPPER(''BEFORE'') 
  END  
  
ELSE IF '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''' BETWEEN '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)+'''
                                                          AND '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX)+'''
    AND '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''' NOT IN (SELECT M_UTC_SNAPSHOT
                                                                FROM (SELECT DISTINCT M_UTC_START AS M_UTC_SNAPSHOT
                                                                        FROM '+@COD_TARGET_ENTITY+'
                                                                       WHERE 1=1
															             AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
																         AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'

																      UNION -- deduplicates also

															         SELECT DISTINCT DATEADD(SS,1,M_UTC_END) AS M_UTC_SNAPSHOT
                                                                      FROM '+@COD_TARGET_ENTITY+'
                                                                     WHERE 1=1
															           AND M_UTC_END < CONVERT(DATETIME2(0),''9999-12-31'')
															           AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
																       AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
                                                                     ) A
                                                            )
  BEGIN
    SET @SCENARIO = UPPER(''BETWEEN'')
  END

ELSE IF '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''' BETWEEN '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)+'''
                                                          AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MAX)+'''
    AND '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''' IN (SELECT M_UTC_SNAPSHOT
                                                                FROM (SELECT DISTINCT M_UTC_START AS M_UTC_SNAPSHOT
                                                                        FROM '+@COD_TARGET_ENTITY+'
                                                                       WHERE 1=1
															             AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
																         AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'

																      UNION -- deduplicates also

															         SELECT DISTINCT DATEADD(SS,1,M_UTC_END) AS M_UTC_SNAPSHOT
                                                                      FROM '+@COD_TARGET_ENTITY+'
                                                                     WHERE 1=1
															           AND M_UTC_END < CONVERT(DATETIME2(0),''9999-12-31'')
															           AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
																       AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
                                                                     ) A
                                                            )
  BEGIN
    SET @SCENARIO = UPPER(''DONE'')
  END
  
ELSE     
  BEGIN
    SET @SCENARIO = UPPER(''UNKOWN'') -- terug naar Tekentafel!!!!
  END
  
'
EXECUTE SP_EXECUTESQL @SQL1
                     ,N'@SCENARIO NVARCHAR(27) OUTPUT'
                     ,@SCENARIO = @SCENARIO OUTPUT
                     
PRINT '@SCENARIO = '+@SCENARIO

-- BEGIN INSERT LOG
SET @LOG = 'PROCESS SCENARIO = '+@SCENARIO
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,@LOG
-- END INSERT LOG
------------------------------------------------------------------------------------------
-- END Determine SCENARIO of Processing
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN PRINT ALL DYNAMIC VARIABLES
------------------------------------------------------------------------------------------
PRINT '@NUMBER_OF_SNAPSHOTS_TARGET = '+CONVERT(NVARCHAR(18),@NUMBER_OF_SNAPSHOTS_TARGET)
PRINT '@NUMBER_OF_SNAPSHOTS_SOURCE = '+CONVERT(NVARCHAR(18),@NUMBER_OF_SNAPSHOTS_SOURCE)
PRINT '@M_UTC_SNAPSHOT             = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)
PRINT '@M_UTC_SNAPSHOT_MAX         = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MAX)
PRINT '@M_UTC_SNAPSHOT_MIN         = '+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)
PRINT '@COD_ASSOCIATION            = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)
PRINT '@M_COD_SCENARIO             = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)
PRINT '@SCENARIO                   = '+@SCENARIO
------------------------------------------------------------------------------------------
-- END PRINT ALL DYNAMIC VARIABLES
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'INITIAL LOAD'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'INITIAL LOAD'
BEGIN

EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Initial Load scenario is started'

SET @SQL1 = N'
INSERT INTO '+@COD_TARGET_ENTITY+'
(IDC_'+@SUBJECT1+'
,COD_ASSOCIATION
,IDC_'+@SUBJECT2+'
,M_COD_SCENARIO
,M_COD_SOR
,M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
)
SELECT
 IDC_'+@SUBJECT1+'
,COD_ASSOCIATION
,IDC_'+@SUBJECT2+'
,M_COD_SCENARIO
,M_COD_SOR
,M_UTC_SNAPSHOT                                AS M_UTC_START
,''9999-12-31 00:00:00''                       AS M_UTC_END
,'+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'      AS M_COD_PROCESS_INSERTED
  FROM '+@COD_SOURCE_ENTITY+'
 WHERE 1=1
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
   AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
   AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL1
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 

-- BEGIN Delete processed snapshot records
SET @SQL1 = N'
DELETE 
  FROM '+@COD_SOURCE_ENTITY+'
 WHERE 1=1
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
   AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
   AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL1
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END Delete processed snapshot records

EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Initial Load scenario is ended'

END -- SCENARIO = 'INITIAL LOAD'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'INITIAL LOAD'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'AFTER'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'AFTER'
BEGIN
------------------------------------------------------------------------------------------
-- is the IDC_'+@SUBJECT1+',COD_ASSOCIATION,IDC_'+@SUBJECT2+' existent?
-- Subscenario Prev		Snapshot	Action
-- AFTER_01    Yes		No          Update (update M_UTC_END of PREV set to M_UTC_SNAPSHOT-1)
-- AFTER_02    No       Yes         Insert (Insert Snapshot set M_UTC_END to '9999-12-31')
-- AFTER_03	   Yes		Yes         Do Nothing
------------------------------------------------------------------------------------------
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'After scenario is started'

-- BEGIN SubScenario AFTER_01:
SET @SQL1 = N'
UPDATE '+@COD_TARGET_ENTITY+'
   SET M_UTC_END = DATEADD(SS,-1,'''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''')
      ,M_COD_PROCESS_UPDATED = '+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'
 WHERE 1=1
   AND M_IDR IN (
                 -- BEGIN AFTER_01
                 SELECT M_IDR
                   FROM (SELECT IDC_'+@SUBJECT1+'
                               ,COD_ASSOCIATION
                               ,IDC_'+@SUBJECT2+'
                               ,M_COD_SCENARIO
                           FROM '+@COD_SOURCE_ENTITY+'
                          WHERE 1=1
                            AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
                            AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
                            AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'             
                        ) SRC
                        FULL OUTER JOIN
                        (SELECT M_IDR
                               ,IDC_'+@SUBJECT1+'
                               ,COD_ASSOCIATION
                               ,IDC_'+@SUBJECT2+'
                               ,M_COD_SCENARIO
                           FROM '+@COD_TARGET_ENTITY+'
                          WHERE 1=1
                            AND '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+''' BETWEEN M_UTC_START AND M_UTC_END
							AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
                            AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
                        ) TRG
                        ON  SRC.IDC_'+@SUBJECT1+' = TRG.IDC_'+@SUBJECT1+'
						AND SRC.COD_ASSOCIATION   = TRG.COD_ASSOCIATION
						AND SRC.IDC_'+@SUBJECT2+' = TRG.IDC_'+@SUBJECT2+'
						AND SRC.M_COD_SCENARIO    = TRG.M_COD_SCENARIO
                      WHERE 1=1
                        AND TRG.M_IDR               IS NOT NULL
						AND SRC.IDC_'+@SUBJECT1+'   IS NULL
                        AND SRC.COD_ASSOCIATION     IS NULL
                        AND SRC.IDC_'+@SUBJECT2+'   IS NULL
                        AND SRC.M_COD_SCENARIO      IS NULL
                 -- END AFTER_01     
                 )
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL1
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END SubScenario AFTER_01:

-- BEGIN SubScenario AFTER_02:
SET @SQL1 = N'
INSERT INTO '+@COD_TARGET_ENTITY+'
(IDC_'+@SUBJECT1+'
,COD_ASSOCIATION
,IDC_'+@SUBJECT2+'
,M_COD_SCENARIO
,M_COD_SOR
,M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
)
SELECT
 IDC_'+@SUBJECT1+'
,COD_ASSOCIATION
,IDC_'+@SUBJECT2+'
,M_COD_SCENARIO
,M_COD_SOR
,M_UTC_SNAPSHOT                                AS M_UTC_START
,''9999-12-31 00:00:00''                       AS M_UTC_END
,'+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'      AS M_COD_PROCESS_INSERTED
  FROM '+@COD_SOURCE_ENTITY+' SRC
 WHERE 1=1
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
   AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
   AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
   AND NOT EXISTS (SELECT M_IDR
                     FROM '+@COD_TARGET_ENTITY+' TRG
                    WHERE 1=1
					  AND TRG.COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
                      AND TRG.M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
					  AND SRC.M_UTC_SNAPSHOT BETWEEN TRG.M_UTC_START AND TRG.M_UTC_END
                      AND SRC.IDC_'+@SUBJECT1+' = TRG.IDC_'+@SUBJECT1+'
					  AND SRC.COD_ASSOCIATION   = TRG.COD_ASSOCIATION
                      AND SRC.IDC_'+@SUBJECT2+' = TRG.IDC_'+@SUBJECT2+'
                      AND SRC.M_COD_SCENARIO    = TRG.M_COD_SCENARIO
                  ) 
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL1
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END SubScenario AFTER_02:

-- BEGIN Delete processed snapshot records
SET @SQL1 = N'
DELETE 
  FROM '+@COD_SOURCE_ENTITY+'
 WHERE 1=1
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
   AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
   AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL1
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END Delete processed snapshot records

EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'After scenario has ended'
END -- IF @SCENARIO = 'AFTER'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'AFTER'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'BEFORE'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'BEFORE'
BEGIN
------------------------------------------------------------------------------------------
-- is the IDC_'+@SUBJECT1+',COD_ASSOCIATION,IDC_'+@SUBJECT2+' existent?
-- Subscenario Prev 	Snapshot	Action
-- BEFORE_01   Yes      Yes         Update (update M_UTC_START of PREV set to M_UTC_SNAPSHOT)
-- BEFORE_02   No       Yes         Insert (Insert Snapshot set M_UTC_END to M_UTC_SNAPSHOT_MIN-1)
-- BEFORE_03   Yes      No          Do Nothing
------------------------------------------------------------------------------------------
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Before scenario is started'

-- BEGIN SubScenario BEFORE_01:
SET @SQL1 = N'
UPDATE '+@COD_TARGET_ENTITY+'
   SET M_UTC_START = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
      ,M_COD_PROCESS_UPDATED = '+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'
 WHERE 1=1
   AND M_IDR IN (
                 -- BEGIN BEFORE_01
                 SELECT M_IDR
                   FROM (SELECT IDC_'+@SUBJECT1+'
                               ,COD_ASSOCIATION
                               ,IDC_'+@SUBJECT2+'
                               ,M_COD_SCENARIO
                           FROM '+@COD_SOURCE_ENTITY+'
                          WHERE 1=1
                            AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
                            AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
                            AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'             
                        ) SRC
                        FULL OUTER JOIN
                        (SELECT M_IDR
                               ,IDC_'+@SUBJECT1+'
                               ,COD_ASSOCIATION
                               ,IDC_'+@SUBJECT2+'
                               ,M_COD_SCENARIO
                           FROM '+@COD_TARGET_ENTITY+'
                          WHERE 1=1
                            AND M_UTC_START = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)+'''
							AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
                            AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
                        ) TRG
                        ON  SRC.IDC_'+@SUBJECT1+' = TRG.IDC_'+@SUBJECT1+'
						AND SRC.COD_ASSOCIATION   = TRG.COD_ASSOCIATION
						AND SRC.IDC_'+@SUBJECT2+' = TRG.IDC_'+@SUBJECT2+'
						AND SRC.M_COD_SCENARIO    = TRG.M_COD_SCENARIO
                      WHERE 1=1
                        AND TRG.M_IDR               IS NOT NULL
						AND SRC.IDC_'+@SUBJECT1+'   IS NOT NULL
                        AND SRC.COD_ASSOCIATION     IS NOT NULL
                        AND SRC.IDC_'+@SUBJECT2+'   IS NOT NULL
                        AND SRC.M_COD_SCENARIO      IS NOT NULL
                 -- END BEFORE_01     
                 )
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL1
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END SubScenario BEFORE_01:

-- BEGIN SubScenario BEFORE_02:
SET @SQL1 = N'
INSERT INTO '+@COD_TARGET_ENTITY+'
(IDC_'+@SUBJECT1+'
,COD_ASSOCIATION
,IDC_'+@SUBJECT2+'
,M_COD_SCENARIO
,M_COD_SOR
,M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
)
SELECT
 IDC_'+@SUBJECT1+'
,COD_ASSOCIATION
,IDC_'+@SUBJECT2+'
,M_COD_SCENARIO
,M_COD_SOR
,M_UTC_SNAPSHOT                                                   AS M_UTC_START
,DATEADD(SS,-1,'''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT_MIN)+''') AS M_UTC_END
,'+CONVERT(NVARCHAR(18),@M_COD_PROCESS)+'                         AS M_COD_PROCESS_INSERTED
  FROM '+@COD_SOURCE_ENTITY+' SRC
 WHERE 1=1
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
   AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
   AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
   AND NOT EXISTS (SELECT M_IDR
                     FROM '+@COD_TARGET_ENTITY+' TRG
                    WHERE 1=1
					  AND TRG.COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
                      AND TRG.M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
					  AND SRC.M_UTC_SNAPSHOT BETWEEN TRG.M_UTC_START AND TRG.M_UTC_END
                      AND SRC.IDC_'+@SUBJECT1+' = TRG.IDC_'+@SUBJECT1+'
					  AND SRC.COD_ASSOCIATION   = TRG.COD_ASSOCIATION
                      AND SRC.IDC_'+@SUBJECT2+' = TRG.IDC_'+@SUBJECT2+'
                      AND SRC.M_COD_SCENARIO    = TRG.M_COD_SCENARIO
                  ) 
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL1
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END SubScenario BEFORE_02:

-- BEGIN Delete processed snapshot records
SET @SQL1 = N'
DELETE 
  FROM '+@COD_SOURCE_ENTITY+'
 WHERE 1=1
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
   AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
   AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL1
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END Delete processed snapshot records

EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Before scenario has ended'
END -- IF @SCENARIO = 'BEFORE'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'BEFORE'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'BETWEEN'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'BETWEEN'
BEGIN -- IF @SCENARIO = 'BETWEEN'

EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Between scenario has started'

EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Between scenario moet nog verder uitgewerkt worden, maar de snapshot records worden verwijderd'

-- BEGIN Delete processed snapshot records
SET @SQL1 = N'
DELETE 
  FROM '+@COD_SOURCE_ENTITY+'
 WHERE 1=1
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
   AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
   AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL1
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END Delete processed snapshot records
END -- IF @SCENARIO = 'BETWEEN'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'BETWEEN'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'DONE'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'DONE'
BEGIN -- IF @SCENARIO = 'DONE'

EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Done scenario has started'

-- BEGIN Delete processed snapshot records
SET @SQL1 = N'
DELETE 
  FROM '+@COD_SOURCE_ENTITY+'
 WHERE 1=1
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR(19),@M_UTC_SNAPSHOT)+'''
   AND COD_ASSOCIATION = '+CONVERT(NVARCHAR(18),@COD_ASSOCIATION)+'
   AND M_COD_SCENARIO  = '+CONVERT(NVARCHAR(18),@M_COD_SCENARIO)+'
'
BEGIN TRY
  EXECUTE SP_EXECUTESQL @SQL1
END TRY

BEGIN CATCH
  SET @M_ERROR_MESSAGE = (SELECT ERROR_MESSAGE() + ' | '+ @SQL1)
  EXECUTE MDAPEL.GF_9999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE          
  RETURN        
END CATCH 
-- END Delete processed snapshot records

EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Done scenario has ended'
END -- IF @SCENARIO = 'DONE'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'DONE'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SPECIFIC POST PROCESS
------------------------------------------------------------------------------------------
-- BEGIN UPDATE METADATA
IF @SCENARIO IN ('INITIAL LOAD','AFTER','BEFORE','BETWEEN','DONE')
BEGIN 

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Begin Specific Post Process'
-- END INSERT LOG

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Metadata insert nog niet uitgewerkt voor LNK tables'
-- END INSERT LOG

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'End Specific Post Process'
-- END INSERT LOG

END -- @SCENARIO IN ('INITIAL LOAD','AFTER','BEFORE','BETWEEN','DONE')
-- END UPDATE METADATA
------------------------------------------------------------------------------------------
-- END SPECIFIC POST PROCESS
------------------------------------------------------------------------------------------
END -- PROCEDURE MDAPEL.GF_0110_LNK_UPDATE_TYPE_II
GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0112_LNK_OBJECTROLE_UPDATE_TYPE_II I.O.]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0112_LNK_OBJECTROLE_UPDATE_TYPE_II I.O.] 
 /* PARAMETER 1 */ @M_COD_PROCESS  BIGINT
,/* PARAMETER 2 */ @SUBJECT        NVARCHAR(100)
,/* PARAMETER 3 */ @SOURCE_SUBJECT NCHAR(6)
,/* PARAMETER 4 */ @SOURCE_ENTITY  NVARCHAR(100)
,/* PARAMETER 5 */ @TARGET_SUBJECT NCHAR(6)
,/* PARAMETER 6 */ @TARGET_ENTITY  NVARCHAR(100)
AS
BEGIN -- PROCEDURE MDAPEL.GF_012_LNK_OBJECTROLE_UPDATE_TYPE_II

-- =========================================================================================
-- Author(s)          : Michael Doves
-- date Created       : 2012-04-24
-- Version            : 1
-- Date Last Modified : 2012-04-24     
-- Description        :	Generic Function to update LNK_OBJECTROLE Tables Type II in EMARIC 
-- Parameters         :	
-- Modifications      : 
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-- ========================================================================================

--------------------------------------------------------------
-- BEGIN Initialize Process Parameters 
--------------------------------------------------------------
--DECLARE @M_COD_PROCESS                          BIGINT         = 31002001
--DECLARE @SUBJECT                                NVARCHAR(100)  = 'PERSON'
--DECLARE @SOURCE_SUBJECT                         NCHAR(6)       = 'DSAPER'
--DECLARE @SOURCE_ENTITY                          NVARCHAR(100)  = 'SNAPSHOT_LNK_OBJECTROLE_PERSON'
--DECLARE @TARGET_SUBJECT                         NCHAR(6)       = 'EMARIC'
--DECLARE @TARGET_ENTITY                          NVARCHAR(100)  = 'LNK_OBJECTROLE_PERSON'
DECLARE @COD_OBJECTROLE                         BIGINT
DECLARE @M_COD_SOR                              BIGINT
DECLARE @M_UTC_SNAPSHOT                         DATETIME2(0)
DECLARE @NUMBER_OF_PROCESSED_SNAPSHOTS_TARGET   BIGINT
DECLARE @NUMBER_OF_PROCESSED_SNAPSHOTS_SOURCE   BIGINT
DECLARE @M_UTC_SNAPSHOT_MAX                     DATETIME2(0) 
DECLARE @M_UTC_SNAPSHOT_MIN                     DATETIME2(0)
DECLARE @M_UTC_SNAPSHOT_PRE                     DATETIME2(0) 
DECLARE @M_UTC_SNAPSHOT_NEX                     DATETIME2(0)
DECLARE @SCENARIO                               NVARCHAR(27)
DECLARE @SQL01						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL02						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL03						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL04						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL05						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL06						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL07						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL08						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL09						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL10						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL11						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL12						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL13						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL14						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL15						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL16						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL17						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL18						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL19						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL20						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL21						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL22						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL23						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL24						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL25						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL26						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL27						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL28						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL29						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL91						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL92						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL93						            NVARCHAR(MAX) -- Generating Dynamic SQL
DECLARE @SQL94						            NVARCHAR(MAX) -- Generating Dynamic SQL
--------------------------------------------------------------
-- END Initialize Process Parameters 
--------------------------------------------------------------

--------------------------------------------------------------
-- BEGIN FILL LIST with unique processed snapshots Target
--------------------------------------------------------------
-- BEGIN DROP IF TABLE ALREADY EXISTS
SET @SQL01 = N'
IF  EXISTS (SELECT * 
              FROM SYS.OBJECTS 
             WHERE 1=1
               AND OBJECT_ID = OBJECT_ID(N''DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_TARGET'') 
               AND TYPE IN (N''U'')
           )
BEGIN            
  DROP TABLE DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_TARGET;
END             
' -- END @SQL01
PRINT 'BEGIN SQL01: '+@SQL01+' END: @SQL01' 
EXECUTE SP_EXECUTESQL @SQL01
-- END DROP IF TABLE ALREADY EXISTS

-- BEGIN CREATE TEMPORARY TABLE
SET @SQL02 = N'
CREATE TABLE DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_TARGET 
             (M_UTC_SNAPSHOT DATETIME2(0)
             ,M_COD_SOR      BIGINT
             ,COD_OBJECTROLE BIGINT
             )        
INSERT INTO DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_TARGET
(M_UTC_SNAPSHOT
,M_COD_SOR
,COD_OBJECTROLE
)
SELECT DISTINCT M_UTC_SNAPSHOT
               ,M_COD_SOR
               ,COD_OBJECTROLE
  FROM
(  
SELECT DISTINCT M_UTC_START AS M_UTC_SNAPSHOT
               ,M_COD_SOR
               ,COD_OBJECTROLE
  FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
 WHERE 1=1
  UNION ALL
SELECT DISTINCT DATEADD(SS,1,M_UTC_END) AS M_UTC_SNAPSHOT
               ,M_COD_SOR
               ,COD_OBJECTROLE
  FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'  
 WHERE 1=1 
   AND M_UTC_END < CONVERT(DATETIME2(0),''9999-12-31'')
  UNION ALL
SELECT UTC_SNAPSHOT AS M_UTC_SNAPSHOT
      ,COD_SOR      AS M_COD_SOR
      ,COD_OBJECTROLE
  FROM MDAPEL.LNK_OBJECTROLE_PROCESSED_SNAPSHOTS
 WHERE 1=1
   AND COD_SUBJECT = '''+@TARGET_SUBJECT+'''
   AND COD_ENTITY  = '''+@TARGET_ENTITY+'''
) X                
' -- END @SQL02
PRINT 'BEGIN SQL02: '+@SQL02+' END: @SQL02' 
EXECUTE SP_EXECUTESQL @SQL02
-- END CREATE TEMPORARY TABLE 
-------------------------------------------------------------------------------------------
-- END FILL LIST with unique processed snapshots Target
-------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------
-- BEGIN FILL LIST with unique processed snapshots Source
-------------------------------------------------------------------------------------------
-- BEGIN DROP IF TABLE ALREADY EXISTS
SET @SQL04 = N'
IF  EXISTS (SELECT * 
              FROM SYS.OBJECTS 
             WHERE 1=1
               AND OBJECT_ID = OBJECT_ID(N''DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_SOURCE'') 
               AND TYPE IN (N''U'')
           )
BEGIN            
  DROP TABLE DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_SOURCE;
END             
' -- END @SQL04
PRINT 'BEGIN SQL04: '+@SQL04+' END: @SQL04' 
EXECUTE SP_EXECUTESQL @SQL04
-- END DROP IF TABLE ALREADY EXISTS
 
-- BEGIN CREATE TEMPORARY TABLE
SET @SQL05 = N'
CREATE TABLE DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_SOURCE
             (M_UTC_SNAPSHOT DATETIME2(0)
             ,M_COD_SOR      BIGINT
             ,COD_OBJECTROLE BIGINT
             )        
INSERT INTO DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_SOURCE
(M_UTC_SNAPSHOT
,M_COD_SOR
,COD_OBJECTROLE
)
SELECT DISTINCT M_UTC_SNAPSHOT
               ,M_COD_SOR
               ,COD_OBJECTROLE
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'               
' -- END @SQL05
PRINT 'BEGIN SQL05: '+@SQL05+' END: @SQL05' 
EXECUTE SP_EXECUTESQL @SQL05
-- END CREATE TEMPORARY TABLE
------------------------------------------------------------------------------------------
-- END FILL LIST with unique processed snapshots Source
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine the M_UTC_SNAPSHOT & M_COD_SOR & COD_OBJECTROLE to be Processed
------------------------------------------------------------------------------------------
SET @SQL07 = N'
SELECT @M_UTC_SNAPSHOT = 
  (SELECT MIN(M_UTC_SNAPSHOT_SOURCE) AS M_UTC_SNAPSHOT
     FROM (SELECT DISTINCT M_UTC_SNAPSHOT AS M_UTC_SNAPSHOT_SOURCE
                          ,M_COD_SOR      AS M_COD_SOR_SOURCE
                          ,COD_OBJECTROLE AS COD_OBJECTROLE_SOURCE
             FROM DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_SOURCE
           ) A
     FULL OUTER JOIN
          (SELECT DISTINCT M_UTC_SNAPSHOT AS M_UTC_SNAPSHOT_TARGET
                          ,M_COD_SOR      AS M_COD_SOR_TARGET
                          ,COD_OBJECTROLE AS COD_OBJECTROLE_TARGET
             FROM DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_TARGET
           ) B
           ON  A.M_UTC_SNAPSHOT_SOURCE = B.M_UTC_SNAPSHOT_TARGET
          AND  A.M_COD_SOR_SOURCE      = B.M_COD_SOR_TARGET
          AND  A.COD_OBJECTROLE_SOURCE = B.COD_OBJECTROLE_TARGET
     WHERE 1=1
       AND M_UTC_SNAPSHOT_TARGET IS NULL 
  ) 
' -- END @SQL07
PRINT 'BEGIN SQL07: '+@SQL07+' END: @SQL07' 
EXECUTE SP_EXECUTESQL @SQL07
                     ,N'@M_UTC_SNAPSHOT DATETIME2(0) OUTPUT'
                     ,@M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT OUTPUT
                     
IF @M_UTC_SNAPSHOT IS NULL 
BEGIN
  SET @M_UTC_SNAPSHOT = CONVERT(DATETIME2(0),'1000-01-01')
END                      
PRINT '@M_UTC_SNAPSHOT = '+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)

IF @M_UTC_SNAPSHOT <> CONVERT(DATETIME2(0),'1000-01-01')
BEGIN
SET @SQL08 = N'
SELECT @M_COD_SOR = 
  (SELECT MIN(M_COD_SOR) AS M_COD_SOR
     FROM DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_SOURCE
    WHERE 1=1
      AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' 
  ) 
' -- END @SQL08
PRINT 'BEGIN SQL08: '+@SQL08+' END: @SQL08' 
EXECUTE SP_EXECUTESQL @SQL08
                     ,N'@M_COD_SOR BIGINT OUTPUT'
                     ,@M_COD_SOR = @M_COD_SOR OUTPUT
END

IF @M_UTC_SNAPSHOT = CONVERT(DATETIME2(0),'1000-01-01')
BEGIN  
  SET @M_COD_SOR = -1             
END                           
PRINT '@M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)

IF @M_UTC_SNAPSHOT <> CONVERT(DATETIME2(0),'1000-01-01')
BEGIN
SET @SQL09 = N'
SELECT @COD_OBJECTROLE = 
  (SELECT MIN(COD_OBJECTROLE) AS COD_OBJECTROLE
     FROM DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_SOURCE
    WHERE 1=1
      AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''
      AND M_COD_SOR      = '+CONVERT(NVARCHAR,@M_COD_SOR)+' 
  ) 
' -- END @SQL09
PRINT 'BEGIN SQL09: '+@SQL09+' END: @SQL09' 
EXECUTE SP_EXECUTESQL @SQL09
                     ,N'@COD_OBJECTROLE BIGINT OUTPUT'
                     ,@COD_OBJECTROLE = @COD_OBJECTROLE OUTPUT
END
PRINT '@COD_OBJECTROLE = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)

SET @SQL03 = N'
SET @NUMBER_OF_PROCESSED_SNAPSHOTS_TARGET = (SELECT COUNT(*) 
                                               FROM DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_TARGET
                                              WHERE 1=1
                                                AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+' 
                                                AND COD_OBJECTROLE = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)+'
                                            )
' -- END @SQL03
PRINT 'BEGIN SQL03: '+@SQL03+' END: @SQL03' 
EXECUTE SP_EXECUTESQL @SQL03
                     ,N'@NUMBER_OF_PROCESSED_SNAPSHOTS_TARGET BIGINT OUTPUT'
                     ,@NUMBER_OF_PROCESSED_SNAPSHOTS_TARGET = @NUMBER_OF_PROCESSED_SNAPSHOTS_TARGET OUTPUT
PRINT '@NUMBER_OF_PROCESSED_SNAPSHOTS_TARGET = '+CONVERT(NVARCHAR,@NUMBER_OF_PROCESSED_SNAPSHOTS_TARGET)

SET @SQL06 = N'
SET @NUMBER_OF_PROCESSED_SNAPSHOTS_SOURCE = (SELECT COUNT(*) 
                                               FROM DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_SOURCE
                                              WHERE 1=1
                                                AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'  
                                                AND COD_OBJECTROLE = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)+'
                                            )
' -- END @SQL06
PRINT 'BEGIN SQL06: '+@SQL06+' END: @SQL06' 
EXECUTE SP_EXECUTESQL @SQL06
                     ,N'@NUMBER_OF_PROCESSED_SNAPSHOTS_SOURCE BIGINT OUTPUT'
                     ,@NUMBER_OF_PROCESSED_SNAPSHOTS_SOURCE = @NUMBER_OF_PROCESSED_SNAPSHOTS_SOURCE OUTPUT
PRINT '@NUMBER_OF_PROCESSED_SNAPSHOTS_SOURCE = '+CONVERT(NVARCHAR,@NUMBER_OF_PROCESSED_SNAPSHOTS_SOURCE)
------------------------------------------------------------------------------------------
-- END Determine the M_UTC_SNAPSHOT & M_COD_SOR to be Processed
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine M_UTC_SNAPSHOT_MAX
------------------------------------------------------------------------------------------
SET @SQL10 = N'
IF '+CONVERT(NVARCHAR,@NUMBER_OF_PROCESSED_SNAPSHOTS_TARGET)+' = 0
BEGIN
   SET @M_UTC_SNAPSHOT_MAX = CONVERT(DATETIME2(0),''1000-01-01'')
END

IF '+CONVERT(NVARCHAR,@NUMBER_OF_PROCESSED_SNAPSHOTS_TARGET)+' > 0
BEGIN
   SET @M_UTC_SNAPSHOT_MAX = (SELECT MAX(M_UTC_SNAPSHOT) AS M_UTC_SNAPSHOT
                                FROM DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_TARGET
                               WHERE 1=1
                                 AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+' 
                                 AND COD_OBJECTROLE = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)+'
                             )
END
' -- END @SQL10
PRINT 'BEGIN SQL10: '+@SQL10+' END: @SQL10' 
EXECUTE SP_EXECUTESQL @SQL10
                     ,N'@M_UTC_SNAPSHOT_MAX DATETIME2(0) OUTPUT'
                     ,@M_UTC_SNAPSHOT_MAX =@M_UTC_SNAPSHOT_MAX OUTPUT
                     
PRINT '@M_UTC_SNAPSHOT_MAX = '+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MAX)
------------------------------------------------------------------------------------------
-- END Determine M_UTC_SNAPSHOT_MAX
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine M_UTC_SNAPSHOT_MIN
------------------------------------------------------------------------------------------
SET @SQL11 = N'
IF '+CONVERT(NVARCHAR,@NUMBER_OF_PROCESSED_SNAPSHOTS_TARGET)+' = 0
BEGIN
   SET @M_UTC_SNAPSHOT_MIN = CONVERT(DATETIME2(0),''1000-01-01'')
END

IF '+CONVERT(NVARCHAR,@NUMBER_OF_PROCESSED_SNAPSHOTS_TARGET)+' > 0
BEGIN
   SET @M_UTC_SNAPSHOT_MIN = (SELECT MIN(M_UTC_SNAPSHOT) AS M_UTC_SNAPSHOT
                                FROM DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_TARGET
                               WHERE 1=1
                                 AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
                                 AND COD_OBJECTROLE = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)+'
                             )
END
' -- END @SQL11
PRINT 'BEGIN SQL11: '+@SQL11+' END: @SQL11' 
EXECUTE SP_EXECUTESQL @SQL11
                     ,N'@M_UTC_SNAPSHOT_MIN DATETIME2(0) OUTPUT'
                     ,@M_UTC_SNAPSHOT_MIN =@M_UTC_SNAPSHOT_MIN OUTPUT
                     
PRINT '@M_UTC_SNAPSHOT_MIN = '+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)
------------------------------------------------------------------------------------------
-- END Determine M_UTC_SNAPSHOT_MIN
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN Determine SCENARIO of Processing
------------------------------------------------------------------------------------------
SET @SQL11 = N'
IF    '+CONVERT(NVARCHAR,@NUMBER_OF_PROCESSED_SNAPSHOTS_SOURCE)+' = 0
  AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' = CONVERT(DATETIME2(0),''1000-01-01'')
  BEGIN 
    SET @SCENARIO = UPPER(''NO SOURCE DATA'')
  END

ELSE IF '+CONVERT(NVARCHAR,@NUMBER_OF_PROCESSED_SNAPSHOTS_TARGET)+' = 0
    AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' <> CONVERT(DATETIME2(0),''1000-01-01'')
  BEGIN 
    SET @SCENARIO = UPPER(''INITIAL LOAD'')
  END

ELSE IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MAX)+''' < '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' 
  BEGIN 
    SET @SCENARIO = UPPER(''AFTER'')
  END 
  
ELSE IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)+''' > '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''
    AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' <> CONVERT(DATETIME2(0),''1000-01-01'')
  BEGIN 
    SET @SCENARIO = UPPER(''BEFORE'') 
  END  
  
ELSE IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' BETWEEN '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)+'''
                                                      AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MAX)+'''
    AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' NOT IN (SELECT M_UTC_SNAPSHOT 
                                                            FROM DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_TARGET
                                                           WHERE 1=1
                                                             AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+' 
                                                             AND COD_OBJECTROLE = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)+'
                                                         )
  BEGIN
    SET @SCENARIO = UPPER(''BETWEEN'')
  END

ELSE IF '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' BETWEEN '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)+'''
                                                      AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MAX)+'''
    AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''     IN (SELECT M_UTC_SNAPSHOT 
                                                            FROM DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_TARGET
                                                           WHERE 1=1
                                                             AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
                                                             AND COD_OBJECTROLE = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)+'
                                                         )
  BEGIN
    SET @SCENARIO = UPPER(''DONE'')
  END
  
ELSE     
  BEGIN
    SET @SCENARIO = UPPER(''UNKOWN'') -- terug naar Tekentafel!!!!
  END
  
' -- END @SQL11
PRINT 'BEGIN SQL11: '+@SQL11+' END: @SQL11' 
EXECUTE SP_EXECUTESQL @SQL11
                     ,N'@SCENARIO NVARCHAR(27) OUTPUT'
                     ,@SCENARIO = @SCENARIO OUTPUT
                     
PRINT '@SCENARIO = '+@SCENARIO
------------------------------------------------------------------------------------------
-- END Determine SCENARIO of Processing
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN PRINT ALL DYNAMIC VARIABLES
------------------------------------------------------------------------------------------
PRINT '@NUMBER_OF_PROCESSED_SNAPSHOTS_TARGET = '+CONVERT(NVARCHAR,@NUMBER_OF_PROCESSED_SNAPSHOTS_TARGET)
PRINT '@NUMBER_OF_PROCESSED_SNAPSHOTS_SOURCE = '+CONVERT(NVARCHAR,@NUMBER_OF_PROCESSED_SNAPSHOTS_SOURCE)
PRINT '@M_UTC_SNAPSHOT                       = '+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)
PRINT '@M_UTC_SNAPSHOT_MAX                   = '+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MAX)
PRINT '@M_UTC_SNAPSHOT_MIN                   = '+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)
PRINT '@M_COD_SOR                            = '+CONVERT(NVARCHAR,@M_COD_SOR)
PRINT '@COD_OBJECTROLE                       = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)
PRINT '@SCENARIO                             = '+@SCENARIO
------------------------------------------------------------------------------------------
-- END PRINT ALL DYNAMIC VARIABLES
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'INITIAL LOAD'
------------------------------------------------------------------------------------------
-- TRUNCATE TABLE EMAFIC.SAT_PERSON_IDENTIFICATION
IF @SCENARIO = 'INITIAL LOAD'
BEGIN
SET @SQL12 = N'
INSERT INTO '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
(COD_OBJECTROLE
,IDC_'+@SUBJECT+'
,M_COD_SOR
,M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
)
SELECT
 COD_OBJECTROLE
,IDC_'+@SUBJECT+'
,M_COD_SOR
,M_UTC_SNAPSHOT                       AS M_UTC_START
,CONVERT(DATETIME2(0),''9999-12-31'') AS M_UTC_END
,'+CONVERT(NVARCHAR,@M_COD_PROCESS)+' AS M_COD_PROCESS_INSERTED
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR      = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''
   AND COD_OBJECTROLE = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)+'
'
PRINT @SQL12			 
EXECUTE SP_EXECUTESQL @SQL12
END -- SCENARIO = 'INITIAL LOAD'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'INITIAL LOAD'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'AFTER'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'AFTER'
BEGIN
-- BEGIN DROP IF TABLE ALREADY EXISTS
SET @SQL13 = N'
IF  EXISTS (SELECT * 
              FROM SYS.OBJECTS 
             WHERE 1=1
               AND OBJECT_ID = OBJECT_ID(N''[DSATMP].[PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_SCENARIO]'') 
               AND TYPE IN (N''U'')
           )
BEGIN            
  DROP TABLE DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_SCENARIO
END             
' -- END @SQL13
PRINT 'BEGIN SQL13: '+@SQL13+' END: @SQL13' 
EXECUTE SP_EXECUTESQL @SQL13
-- END DROP IF TABLE ALREADY EXISTS

-- BEGIN CREATE TEMPORARY TABLE
SET @SQL14 = N'
CREATE TABLE DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_SCENARIO
(M_COD_SCENARIO       NVARCHAR(27) NOT NULL
,M_COD_SUBSCENARIO    NCHAR(2)     NOT NULL
,M_IDR_LNK            BIGINT           NULL
,COD_OBJECTROLE_LNK   BIGINT           NULL
,IDC_'+@SUBJECT+'_LNK BIGINT           NULL
,M_COD_SOR_LNK        BIGINT           NULL
,M_UTC_START_LNK      DATETIME2(0)     NULL
,M_UTC_END_LNK        DATETIME2(0)     NULL
,M_IDR_SNA            BIGINT           NULL
,M_UTC_SNAPSHOT_SNA   DATETIME2(0)     NULL
,COD_OBJECTROLE_SNA   BIGINT           NULL
,IDC_'+@SUBJECT+'_SNA BIGINT           NULL
,M_COD_SOR_SNA        BIGINT           NULL
)
' -- END @SQL14
PRINT 'BEGIN SQL14: '+@SQL14+' END: @SQL14' 
EXECUTE SP_EXECUTESQL @SQL14
-- END CREATE TEMPORARY TABLE

------------------------------------------------------------------------------------------
-- is the M_COD_SOR, IDI existent? Are the details different?
-- Subscenario  Prev		Snapshot	 	Action
-- A1			 Yes			Yes			Do Nothing
-- B1			 Yes			 No			Update (M_UTC_END of PREV set to M_UTC_SNAPSHOT-1)
-- C1			 No			    Yes			Insert (Insert Snapshot set M_UTC_END to '9999-12-31')
------------------------------------------------------------------------------------------

-- BEGIN FILL TEMPORARY TABLE
SET @SQL15 = N'
INSERT INTO DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_SCENARIO
(M_COD_SCENARIO
,M_COD_SUBSCENARIO
,M_IDR_LNK
,COD_OBJECTROLE_LNK
,IDC_'+@SUBJECT+'_LNK
,M_COD_SOR_LNK
,M_UTC_START_LNK
,M_UTC_END_LNK
,M_IDR_SNA
,M_UTC_SNAPSHOT_SNA
,COD_OBJECTROLE_SNA
,IDC_'+@SUBJECT+'_SNA
,M_COD_SOR_SNA
)
SELECT
 ''AFTER'' AS M_COD_SCENARIO
,CASE
   WHEN COD_OBJECTROLE_LNK   = COD_OBJECTROLE_SNA
    AND IDC_'+@SUBJECT+'_LNK = IDC_'+@SUBJECT+'_SNA
    AND M_COD_SOR_LNK        = M_COD_SOR_SNA
   THEN ''A1''
   WHEN COD_OBJECTROLE_LNK IS NOT NULL
    AND COD_OBJECTROLE_SNA IS NULL
   THEN ''B1'' 
   WHEN COD_OBJECTROLE_LNK IS NULL
    AND COD_OBJECTROLE_SNA IS NOT NULL
   THEN ''C1''
   ELSE NULL -- Program will Error!
 END AS M_COD_SUBSCENARIO
,M_IDR_LNK
,COD_OBJECTROLE_LNK
,IDC_'+@SUBJECT+'_LNK
,M_COD_SOR_LNK
,M_UTC_START_LNK
,M_UTC_END_LNK
,M_IDR_SNA
,M_UTC_SNAPSHOT_SNA
,COD_OBJECTROLE_SNA
,IDC_'+@SUBJECT+'_SNA
,M_COD_SOR_SNA
  FROM
(
SELECT 
 M_IDR AS M_IDR_LNK
,COD_OBJECTROLE AS COD_OBJECTROLE_LNK
,IDC_'+@SUBJECT+' AS IDC_'+@SUBJECT+'_LNK
,M_COD_SOR AS M_COD_SOR_LNK
,M_UTC_START AS M_UTC_START_LNK
,M_UTC_END AS M_UTC_END_LNK
  FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
   AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' BETWEEN M_UTC_START AND M_UTC_END
   AND COD_OBJECTROLE = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)+'
) A
FULL OUTER JOIN
(
SELECT 
 M_IDR AS M_IDR_SNA
,M_UTC_SNAPSHOT AS M_UTC_SNAPSHOT_SNA
,COD_OBJECTROLE AS COD_OBJECTROLE_SNA
,IDC_'+@SUBJECT+' AS IDC_'+@SUBJECT+'_SNA
,M_COD_SOR AS M_COD_SOR_SNA
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''
   AND COD_OBJECTROLE = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)+'
) B 
 ON A.COD_OBJECTROLE_LNK = B.COD_OBJECTROLE_SNA
AND A.IDC_'+@SUBJECT+'_LNK = B.IDC_'+@SUBJECT+'_SNA
AND A.M_COD_SOR_LNK = B.M_COD_SOR_SNA
' -- END @SQL15
PRINT 'BEGIN SQL15: '+@SQL15+' END: @SQL15' 
EXECUTE SP_EXECUTESQL @SQL15
-- END FILL TEMPORARY TABLE   

-- BEGIN SUBSCENARIO B1 UPDATE 
SET @SQL16 = N'
UPDATE '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
   SET M_UTC_END             = DATEADD(SS,-1,'''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''')
      ,M_COD_PROCESS_UPDATED = '+CONVERT(NVARCHAR,@M_COD_PROCESS)+'
  WHERE 1=1
    AND M_IDR IN (SELECT M_IDR_LNK
                    FROM DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_SCENARIO
				   WHERE 1=1
				     AND M_COD_SCENARIO = ''AFTER''
				     AND M_COD_SUBSCENARIO = ''B1''
				     AND M_IDR_LNK IS NOT NULL
				     AND M_UTC_SNAPSHOT_SNA = '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''
				  )
' -- END @SQL16
PRINT 'BEGIN SQL16: '+@SQL16+' END: @SQL16' 
EXECUTE SP_EXECUTESQL @SQL16
-- END SUBSCENARIO B1 UPDATE

-- BEGIN SUBSCENARIO C1 INSERT
SET @SQL17 = N'
INSERT INTO '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
(COD_OBJECTROLE
,IDC_'+@SUBJECT+'
,M_COD_SOR
,M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
)
SELECT
 COD_OBJECTROLE_SNA
,IDC_'+@SUBJECT+'_SNA
,M_COD_SOR_SNA
,M_UTC_SNAPSHOT_SNA                   AS M_UTC_START
,CONVERT(DATETIME2(0),''9999-12-31'') AS M_UTC_END
,'+CONVERT(NVARCHAR,@M_COD_PROCESS)+' AS M_COD_PROCESS_INSERTED
  FROM DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_SCENARIO
 WHERE 1=1
   AND M_COD_SCENARIO     = ''AFTER''
   AND M_COD_SUBSCENARIO  = ''C1''
   AND M_UTC_SNAPSHOT_SNA = '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''
   AND M_COD_SOR_SNA      = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
   AND COD_OBJECTROLE_SNA = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)+'
'
PRINT @SQL17			 
EXECUTE SP_EXECUTESQL @SQL17
-- END SUBSCENARIO C1 INSERT

END -- IF @SCENARIO = 'AFTER'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'AFTER'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'BEFORE'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'BEFORE'
BEGIN -- IF @SCENARIO = 'BEFORE'

-- BEGIN DROP IF TABLE ALREADY EXISTS
SET @SQL18 = N'
IF  EXISTS (SELECT * 
              FROM SYS.OBJECTS 
             WHERE 1=1
               AND OBJECT_ID = OBJECT_ID(N''[DSATMP].[PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_SCENARIO]'') 
               AND TYPE IN (N''U'')
           )
BEGIN            
  DROP TABLE DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_SCENARIO
END             
' -- END @SQL18
PRINT 'BEGIN SQL18: '+@SQL18+' END: @SQL18' 
EXECUTE SP_EXECUTESQL @SQL18
-- END DROP IF TABLE ALREADY EXISTS

-- BEGIN CREATE TEMPORARY TABLE
SET @SQL19 = N'
CREATE TABLE DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_SCENARIO
(M_COD_SCENARIO       NVARCHAR(27) NOT NULL
,M_COD_SUBSCENARIO    NCHAR(2)     NOT NULL
,M_IDR_LNK            BIGINT           NULL
,COD_OBJECTROLE_LNK   BIGINT           NULL
,IDC_'+@SUBJECT+'_LNK BIGINT           NULL
,M_COD_SOR_LNK        BIGINT           NULL
,M_UTC_START_LNK      DATETIME2(0)     NULL
,M_UTC_END_LNK        DATETIME2(0)     NULL
,M_IDR_SNA            BIGINT           NULL
,M_UTC_SNAPSHOT_SNA   DATETIME2(0)     NULL
,COD_OBJECTROLE_SNA   BIGINT           NULL
,IDC_'+@SUBJECT+'_SNA BIGINT           NULL
,M_COD_SOR_SNA        BIGINT           NULL
)
' -- END @SQL19
PRINT 'BEGIN SQL19: '+@SQL19+' END: @SQL19' 
EXECUTE SP_EXECUTESQL @SQL19
-- END CREATE TEMPORARY TABLE

------------------------------------------------------------------------------------------
-- is the M_COD_SOR, IDI existent? Are the details different?
-- Subscenario  Prev		Snapshot	 	Action
-- A1			 Yes			Yes			Update, set M_UTC_START to M_UTC_SNAPSHOT
-- B1			 Yes			 No			Do Nothing
-- C1			 No			    Yes			Insert and set M_UTC_END to M_UTC_SNAPSHOT_MIN -1 
------------------------------------------------------------------------------------------

-- BEGIN FILL TEMPORARY TABLE
SET @SQL20 = N'
INSERT INTO DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_SCENARIO
(M_COD_SCENARIO
,M_COD_SUBSCENARIO
,M_IDR_LNK
,COD_OBJECTROLE_LNK
,IDC_'+@SUBJECT+'_LNK
,M_COD_SOR_LNK
,M_UTC_START_LNK
,M_UTC_END_LNK
,M_IDR_SNA
,M_UTC_SNAPSHOT_SNA
,COD_OBJECTROLE_SNA
,IDC_'+@SUBJECT+'_SNA
,M_COD_SOR_SNA
)
SELECT
 ''BEFORE'' AS M_COD_SCENARIO
,CASE
   WHEN COD_OBJECTROLE_LNK   = COD_OBJECTROLE_SNA
    AND IDC_'+@SUBJECT+'_LNK = IDC_'+@SUBJECT+'_SNA
    AND M_COD_SOR_LNK        = M_COD_SOR_SNA
   THEN ''A1''
   WHEN COD_OBJECTROLE_LNK IS NOT NULL
    AND COD_OBJECTROLE_SNA IS NULL
   THEN ''B1'' 
   WHEN COD_OBJECTROLE_LNK IS NULL
    AND COD_OBJECTROLE_SNA IS NOT NULL
   THEN ''C1''
   ELSE NULL -- Program will Error!
 END AS M_COD_SUBSCENARIO
,M_IDR_LNK
,COD_OBJECTROLE_LNK
,IDC_'+@SUBJECT+'_LNK
,M_COD_SOR_LNK
,M_UTC_START_LNK
,M_UTC_END_LNK
,M_IDR_SNA
,M_UTC_SNAPSHOT_SNA
,COD_OBJECTROLE_SNA
,IDC_'+@SUBJECT+'_SNA
,M_COD_SOR_SNA
  FROM
(
SELECT 
 M_IDR AS M_IDR_LNK
,COD_OBJECTROLE AS COD_OBJECTROLE_LNK
,IDC_'+@SUBJECT+' AS IDC_'+@SUBJECT+'_LNK
,M_COD_SOR AS M_COD_SOR_LNK
,M_UTC_START AS M_UTC_START_LNK
,M_UTC_END AS M_UTC_END_LNK
  FROM '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
   AND '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+''' BETWEEN M_UTC_START AND M_UTC_END
   AND COD_OBJECTROLE = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)+'
) A
FULL OUTER JOIN
(
SELECT 
 M_IDR AS M_IDR_SNA
,M_UTC_SNAPSHOT AS M_UTC_SNAPSHOT_SNA
,COD_OBJECTROLE AS COD_OBJECTROLE_SNA
,IDC_'+@SUBJECT+' AS IDC_'+@SUBJECT+'_SNA
,M_COD_SOR AS M_COD_SOR_SNA
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_COD_SOR = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''
   AND COD_OBJECTROLE = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)+'
) B 
 ON A.COD_OBJECTROLE_LNK = B.COD_OBJECTROLE_SNA
AND A.IDC_'+@SUBJECT+'_LNK = B.IDC_'+@SUBJECT+'_SNA
AND A.M_COD_SOR_LNK = B.M_COD_SOR_SNA
' -- END @SQL20
PRINT 'BEGIN SQL20: '+@SQL20+' END: @SQL20' 
EXECUTE SP_EXECUTESQL @SQL20
-- END FILL TEMPORARY TABLE

-- BEGIN SUBSCENARIO A1 UPDATE 
SET @SQL21 = N'
UPDATE '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
   SET M_UTC_START           = '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''
      ,M_COD_PROCESS_UPDATED = '+CONVERT(NVARCHAR,@M_COD_PROCESS)+'
  WHERE 1=1
    AND M_IDR IN (SELECT M_IDR_LNK
                    FROM DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_SCENARIO
				   WHERE 1=1
				     AND M_COD_SCENARIO = ''BEFORE''
				     AND M_COD_SUBSCENARIO = ''A1''
				     AND M_IDR_LNK IS NOT NULL
				     AND M_UTC_SNAPSHOT_SNA = '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''
				  )
' -- END @SQL21
PRINT 'BEGIN SQL21: '+@SQL21+' END: @SQL21' 
EXECUTE SP_EXECUTESQL @SQL21
-- END SUBSCENARIO A1 UPDATE

-- BEGIN SUBSCENARIO C1 INSERT
SET @SQL22 = N'
INSERT INTO '+@TARGET_SUBJECT+'.'+@TARGET_ENTITY+'
(COD_OBJECTROLE
,IDC_'+@SUBJECT+'
,M_COD_SOR
,M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
)
SELECT
 COD_OBJECTROLE_SNA
,IDC_'+@SUBJECT+'_SNA
,M_COD_SOR_SNA
,M_UTC_SNAPSHOT_SNA                   AS M_UTC_START
,DATEADD(SS,-1,'''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT_MIN)+''') AS M_UTC_END
,'+CONVERT(NVARCHAR,@M_COD_PROCESS)+' AS M_COD_PROCESS_INSERTED
  FROM DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_SCENARIO
 WHERE 1=1
   AND M_COD_SCENARIO     = ''BEFORE''
   AND M_COD_SUBSCENARIO  = ''C1''
   AND M_UTC_SNAPSHOT_SNA = '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''
   AND M_COD_SOR_SNA      = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
   AND COD_OBJECTROLE_SNA = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)+'
' -- END @SQL22
PRINT 'BEGIN SQL22: '+@SQL22+' END: @SQL22' 
EXECUTE SP_EXECUTESQL @SQL22
-- END SUBSCENARIO C1 INSERT

END -- IF @SCENARIO = 'BEFORE'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'BEFORE'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SCENARIO = 'BETWEEN'
------------------------------------------------------------------------------------------
IF @SCENARIO = 'BETWEEN'
BEGIN -- IF @SCENARIO = 'BETWEEN'
PRINT 'Dit scenario moet nog uitgewerkt worden.'
END -- IF @SCENARIO = 'BETWEEN'
------------------------------------------------------------------------------------------
-- END SCENARIO = 'BETWEEN'
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- BEGIN SPECIFIC POST PROCESS
------------------------------------------------------------------------------------------
-- BEGIN UPDATE METADATA
IF @SCENARIO IN ('INITIAL LOAD','AFTER','BEFORE','BETWEEN')
BEGIN 
INSERT INTO MDAPEL.LNK_OBJECTROLE_PROCESSED_SNAPSHOTS
(COD_SUBJECT
,COD_ENTITY
,COD_SOR
,COD_OBJECTROLE
,UTC_SNAPSHOT
)
VALUES
(@TARGET_SUBJECT
,@TARGET_ENTITY
,@M_COD_SOR
,@COD_OBJECTROLE
,@M_UTC_SNAPSHOT
)
END -- @SCENARIO IN ('INITIAL LOAD','AFTER','BEFORE','BETWEEN','DONE')
-- END UPDATE METADATA

-- BEGIN DELETE PROCESSED RECORDS FROM SOURCE TABLE
IF @SCENARIO IN ('INITIAL LOAD','AFTER','BEFORE','BETWEEN','DONE')
BEGIN 
SET @SQL91 = N'
DELETE 
  FROM '+@SOURCE_SUBJECT+'.'+@SOURCE_ENTITY+'
 WHERE 1=1
   AND M_UTC_SNAPSHOT = '''+CONVERT(NVARCHAR,@M_UTC_SNAPSHOT)+'''
   AND M_COD_SOR      = '+CONVERT(NVARCHAR,@M_COD_SOR)+'
   AND COD_OBJECTROLE = '+CONVERT(NVARCHAR,@COD_OBJECTROLE)+'
' -- END @SQL91
PRINT 'BEGIN SQL91: '+@SQL91+' END: @SQL91' 
EXECUTE SP_EXECUTESQL @SQL91
END -- @SCENARIO IN ('INITIAL LOAD','AFTER','BEFORE','BETWEEN','DONE')
-- END DELETE PROCESSED RECORDS FROM SOURCE TABLE

-- BEGIN DROP IF TABLE ALREADY EXISTS
SET @SQL92 = N'
IF  EXISTS (SELECT * 
              FROM SYS.OBJECTS 
             WHERE 1=1
               AND OBJECT_ID = OBJECT_ID(N''DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_TARGET'') 
               AND TYPE IN (N''U'')
           )
BEGIN            
  DROP TABLE DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_TARGET
END             
' -- END @SQL92
PRINT 'BEGIN SQL92: '+@SQL92+' END: @SQL92' 
EXECUTE SP_EXECUTESQL @SQL92
-- END DROP IF TABLE ALREADY EXISTS

-- BEGIN DROP IF TABLE ALREADY EXISTS
SET @SQL93 = N'
IF  EXISTS (SELECT * 
              FROM SYS.OBJECTS 
             WHERE 1=1
               AND OBJECT_ID = OBJECT_ID(N''DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_SOURCE'') 
               AND TYPE IN (N''U'')
           )
BEGIN            
  DROP TABLE DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_LIST_OF_UTC_SOURCE
END             
' -- END @SQL93
PRINT 'BEGIN SQL93: '+@SQL93+' END: @SQL93' 
EXECUTE SP_EXECUTESQL @SQL93
-- END DROP IF TABLE ALREADY EXISTS

-- BEGIN DROP IF TABLE ALREADY EXISTS
SET @SQL94 = N'
IF  EXISTS (SELECT * 
              FROM SYS.OBJECTS 
             WHERE 1=1
               AND OBJECT_ID = OBJECT_ID(N''[DSATMP].[PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_SCENARIO]'') 
               AND TYPE IN (N''U'')
           )
BEGIN            
  DROP TABLE DSATMP.PROCESS_'+CONVERT(NVARCHAR,@M_COD_PROCESS)+'_SCENARIO
END             
' -- END @SQL94
PRINT 'BEGIN SQL94: '+@SQL94+' END: @SQL94' 
EXECUTE SP_EXECUTESQL @SQL94
-- END DROP IF TABLE ALREADY EXISTS
------------------------------------------------------------------------------------------
-- END SPECIFIC POST PROCESS
------------------------------------------------------------------------------------------
END -- PROCEDURE MDAPEL.GF_011_HUB_UPDATE_TYPE_II_NO_SEQUENCE

GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0120_CREATE_DDADTI_STATUS_ENTITY]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =========================================================================================
-- Author(s)          : Dinand Kleijbeuker
-- date Created       : 2011-07-05
-- Version            : 3
-- Date Last Modified : 2012-10-10           
-- Description        :	Generates a DDADTI Snapshot table based on SOURCE input table, 
--                      also adds necessary metadata (M_) columns, indexes, constraints
--                      and foreign keys.
--                      The EMADIA Processing procedure will always be dropped and 
--                      (re)created.
--                      The EMADIA table needs to be dropped manually first before 
--                      recreation.
--                      Let op: de DBO tabel moet al exact de juiste naamgeving hebben
--                              DTIxxxxxxx_specificname waarbij x een getal is.
-- Parameters         :	@DDADTI_TABLE = input DDA table
--                      @PROCEDURE = Create EMADIA procedure (No, Snapshot, Transaction)
--                      @DEBUG = Debug on (1) or off (0) default
-- Modifications      : 2012-04-05 Michael Doves
--                        Add extra attribute types
--                        Add constraints, indexes and foreign keys
--                        Change int tot bigint
--                        Change datetime2 in datetime2(0)	
--                      2012-04-10 Michael Doves
--                        Add smallint attribute tpe
--                      2012-10-10 Michael Doves
--                        Extra Foreign Keys and Check build in (plausibility).
--                      2012-11-22 Michael Doves
--                        CHAR moet VARCHAR worden en NCHAR moet NVARCHAR worden
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-- ========================================================================================
CREATE PROCEDURE [MDAPEL].[GF_0120_CREATE_DDADTI_STATUS_ENTITY]
  @DDADTI_TABLE nvarchar(100)
 ,@INPUT_SCHEMA nvarchar(100) = DBO
 ,@DEBUG bit = 0

AS
BEGIN TRY
DECLARE @SQL1			nvarchar(max)
DECLARE @DDA_COLUMNLIST nvarchar(max)
DECLARE @OUTPUT_SCHEMA	nvarchar(100) = 'DDADTI'

IF NOT EXISTS (select * 
                 from sys.tables 
                 INNER JOIN 
			          sys.schemas 
			     on tables.schema_id = schemas.schema_id		
			    where 1=1
			      and tables.name  = (@DDADTI_TABLE)
			      and schemas.name = (@OUTPUT_SCHEMA)
			      and tables.type  = 'U')
   	BEGIN TRY
--Collect DDA table columns, already formated in a list without Metadata columns (M_xxx)
		SET @SQL1 = N'SELECT @DDA_COLUMNLIST = (SELECT STUFF ((SELECT '', ['' + COLUMN_NAME
											+''] ''+ CASE DATA_TYPE
												WHEN ''int''                THEN ''int''
												WHEN ''timestamp''          THEN ''timestamp''
												WHEN ''image''              THEN ''image''
												WHEN ''tinyint''            THEN ''tinyint''
												WHEN ''smallint''           THEN ''smallint''
												WHEN ''bigint''             THEN ''bigint''
												WHEN ''float''              THEN ''float''
												WHEN ''uniqueidentifier''   THEN ''uniqueidentifier''
												WHEN ''numeric''	        THEN ''numeric(''+ISNULL(CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)), (CAST(NUMERIC_PRECISION AS VARCHAR(5)) +'',''+ CAST(NUMERIC_SCALE AS VARCHAR(4))))+'')''
												WHEN ''decimal''	        THEN ''decimal(''+ISNULL(CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)), (CAST(NUMERIC_PRECISION AS VARCHAR(5)) +'',''+ CAST(NUMERIC_SCALE AS VARCHAR(4))))+'')''
												WHEN ''datetime''	        THEN ''datetime''
												WHEN ''datetime2''	        THEN ''datetime2''
												WHEN ''date''		        THEN ''date''
												WHEN ''bit''	            THEN ''bit''
												WHEN ''nchar''              THEN ''nvarchar(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
												WHEN ''char''               THEN ''varchar(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
												WHEN ''nvarchar''           THEN ''nvarchar(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
												WHEN ''varchar''            THEN ''varchar(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
												WHEN ''text''               THEN ''text''
												WHEN ''ntext''              THEN ''ntext''
												WHEN ''time''               THEN ''time''
												ELSE NULL END
												+'' ''+ CASE WHEN IS_NULLABLE = ''NO'' THEN ''NULL'' ELSE ''NULL'' END
										 FROM INFORMATION_SCHEMA.COLUMNS
										 WHERE TABLE_NAME = '''+@DDADTI_TABLE+'''
										 AND TABLE_SCHEMA = '''+@INPUT_SCHEMA+'''
										 ORDER BY ORDINAL_POSITION
										 FOR XML PATH('''')
										 ), 1, 1, '''') )'

		IF @DEBUG = 1 PRINT @SQL1
		EXEC sp_executesql @SQL1, N'@DDA_COLUMNLIST nvarchar(max) OUTPUT', @DDA_COLUMNLIST = @DDA_COLUMNLIST OUTPUT
		IF @DEBUG = 1 PRINT @DDA_COLUMNLIST
		
		SET @SQL1 = N'CREATE TABLE '+@OUTPUT_SCHEMA+'.'+@DDADTI_TABLE+'(
		[M_IDR] [bigint] IDENTITY(1,1) NOT NULL,
		[M_UTC_SNAPSHOT] [datetime2](0) NOT NULL,
		[M_COD_PROCESS] [bigint] NOT NULL,
		[M_COD_SOR] [bigint] NOT NULL,
		[M_UTC_RECORD_INSERTED] [datetime2](7) NOT NULL,
		[M_COD_PLAUSIBLE] [nchar](1) NOT NULL,
		[M_CRC] [bigint] NOT NULL,
		[M_COD_KEY] [nvarchar](100) NOT NULL,
		'+@DDA_COLUMNLIST+'
		CONSTRAINT [PK00_'+@DDADTI_TABLE+'] PRIMARY KEY CLUSTERED 
		(
			[M_IDR] ASC
		)WITH (PAD_INDEX  = OFF
		                   ,STATISTICS_NORECOMPUTE  = OFF
		                   ,IGNORE_DUP_KEY = OFF
		                   ,ALLOW_ROW_LOCKS  = ON
		                   ,ALLOW_PAGE_LOCKS  = ON
		      ) ON [PRIMARY]
		) ON [PRIMARY]
		ALTER TABLE [DDADTI].['+@DDADTI_TABLE+'] ADD CONSTRAINT [CN01_'+@DDADTI_TABLE+'_M_COD_PLAUSIBLE]       DEFAULT (''T'')        FOR [M_COD_PLAUSIBLE]
		ALTER TABLE [DDADTI].['+@DDADTI_TABLE+'] ADD CONSTRAINT [CN02_'+@DDADTI_TABLE+'_M_UTC_RECORD_INSERTED] DEFAULT (getutcdate()) FOR [M_UTC_RECORD_INSERTED]
		ALTER TABLE [DDADTI].['+@DDADTI_TABLE+'] ADD CONSTRAINT [CN03_'+@DDADTI_TABLE+'_M_CRC]                 DEFAULT (0)            FOR [M_CRC]		
		ALTER TABLE [DDADTI].['+@DDADTI_TABLE+'] WITH CHECK ADD CONSTRAINT [FK01_'+@DDADTI_TABLE+'_M_COD_SOR] FOREIGN KEY([M_COD_SOR]) REFERENCES [MDAPEL].[SOR] ([COD_SOR])
		ALTER TABLE [DDADTI].['+@DDADTI_TABLE+'] CHECK CONSTRAINT [FK01_'+@DDADTI_TABLE+'_M_COD_SOR]
		ALTER TABLE [DDADTI].['+@DDADTI_TABLE+'] WITH CHECK ADD CONSTRAINT [FK02_'+@DDADTI_TABLE+'_M_COD_PROCESS] FOREIGN KEY([M_COD_PROCESS]) REFERENCES [MDAPEL].[PROCESS] ([COD_PROCESS])
		ALTER TABLE [DDADTI].['+@DDADTI_TABLE+'] CHECK CONSTRAINT [FK02_'+@DDADTI_TABLE+'_M_COD_PROCESS]
		ALTER TABLE [DDADTI].['+@DDADTI_TABLE+'] WITH CHECK ADD CONSTRAINT [FK03_'+@DDADTI_TABLE+'_M_COD_PLAUSIBLE] FOREIGN KEY([M_COD_PLAUSIBLE]) REFERENCES [MDAPEL].[DOM_PLAUSIBLE] ([COD_PLAUSIBLE])
		ALTER TABLE [DDADTI].['+@DDADTI_TABLE+'] CHECK CONSTRAINT [FK03_'+@DDADTI_TABLE+'_M_COD_PLAUSIBLE]
		CREATE UNIQUE NONCLUSTERED INDEX [UK01_'+@DDADTI_TABLE+'] ON [DDADTI].['+@DDADTI_TABLE+'] 
        ([M_UTC_SNAPSHOT] ASC
        ,[M_COD_KEY]      ASC
        ,[M_COD_SOR]      ASC
        )
		'
		IF @DEBUG = 1 PRINT @SQL1
		EXEC sp_executesql @SQL1
		IF @DEBUG = 1 PRINT '-- TABLE CREATED --'
	END TRY
	BEGIN CATCH
			SELECT ERROR_MESSAGE() + ' | '+ @SQL1 AS ErrorMessage
			RETURN
	END CATCH
		
ELSE IF @DEBUG = 1 PRINT '-- TABLE ALREADY EXISTS! --'

END TRY
BEGIN CATCH
		SELECT ERROR_MESSAGE() 
		RETURN
END CATCH

GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0201_OMADIA_STATUS]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0201_OMADIA_STATUS] 
/* PAR 1 */ @M_COD_DTI      NVARCHAR(200)
/* PAR 2 */,@M_COD_PROCESS  NVARCHAR(18)
/* PAR 3 */,@M_COD_INSTANCE BIGINT
/* PAR 4 */,@DEBUG          BIT = 0
AS
-- =========================================================================================
-- Author(s)          : Michael Doves
-- date Created       : 2012-06-12
-- Version            : 1
-- Date Last Modified : 2012-06-12           
-- Description        :	OMADIA TYPE I Update Proces
-- Parameters         :	PAR 1 @M_COD_DTI      = Name of Input Table, The Data Transfer Interface (DTI).
--                      PAR 2 @M_COD_PROCESS  = Unique Integer of Process.
--                      PAR 3 @M_COD_INSTANCE = Unique integer of Process Instance.
--                      PAR 4 @DEBUG          = Optional parameter for debugging
-- Modifications      : Automatic Logging and error Handling is integrated.
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
/* PAR 4 */ ,'GF_0201_OMADIA_SNAPSHOT is called'

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
-- BEGIN: Determine number of DDADTI records
/**********************************************************************************/

BEGIN TRY
  SET @SQL1 = N'SELECT @LOG = COUNT(1) FROM '+@INPUT_SCHEMA+'.'+@M_COD_DTI
  EXECUTE sp_executesql @SQL1, N'@LOG NVARCHAR(MAX) OUTPUT', @LOG = @LOG OUTPUT
  
  SET @LOG = 'DDA Records: ' +@LOG
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
  ,''9999-12-31 00:00:00''   as M_UTC_END
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
-- Subscenario Prev		Snapshot	DIFF_PREV_SNAP	Action
-- AFTER_01    Yes		No          #               Update (update M_UTC_END of PREV set to M_UTC_SNAPSHOT-1)
-- AFTER_02    Yes		Yes         Yes             Update (update M_UTC_END of PREV set to M_UTC_SNAPSHOT-1)
-- AFTER_03    Yes      Yes         Yes             Insert (insert Snapshot set M_UTC_END to '9999-12-31')
-- AFTER_04    No       Yes         #               Insert (Insert Snapshot set M_UTC_END to '9999-12-31')
-- AFTER_05	   Yes		Yes         No              Do Nothing
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
                        ) SRC
                        FULL OUTER JOIN
                        (SELECT M_IDR
                               ,M_COD_KEY AS M_COD_KEY_TRG
                           FROM '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+'
                          WHERE 1=1
                            AND M_COD_SOR       = '+@M_COD_SOR+'
                            AND @M_UTC_SNAPSHOT BETWEEN M_UTC_START AND M_UTC_END
                        ) TRG
                        ON  SRC.M_COD_KEY_SRC = TRG.M_COD_KEY_TRG
                        WHERE 1=1
                          AND M_COD_KEY_SRC IS NULL
                          AND M_IDR IS NOT NULL    
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
print @DDA_COLUMNLIST 
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
   AND NOT EXISTS (SELECT M_IDR
                     FROM '+@OUTPUT_SCHEMA+'.'+@M_COD_DTI+' TRG
                    WHERE 1=1
                      AND TRG.M_COD_SOR = SRC.M_COD_SOR
                      AND TRG.M_COD_KEY = SRC.M_COD_KEY
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

GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0202_OMAXXX_STATUS]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0202_OMAXXX_STATUS] 
/* PAR 1 */ @COD_INPUT_SUBJECT   NCHAR(6)
/* PAR 2 */,@COD_INPUT_ENTITY    NVARCHAR(100)
/* PAR 3 */,@COD_OUTPUT_SUBJECT  NCHAR(6)
/* PAR 4 */,@COD_OUTPUT_ENTITY   NVARCHAR(100)
/* PAR 5 */,@M_COD_PROCESS       NVARCHAR(18)
/* PAR 6 */,@M_COD_INSTANCE      BIGINT
/* PAR 7 */,@DEBUG               BIT = 0
AS
-- =========================================================================================
-- Author(s)          : Michael Doves
-- date Created       : 2012-11-16
-- Version            : 1
-- Date Last Modified : 2012-06-12           
-- Description        :	OMAXXX TYPE II Update Proces for Status Information.
-- Parameters         :	
-- Modifications      : Automatic Logging and error Handling is integrated.
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
BEGIN TRY-- A
--/* PAR 1 */ DECLARE @COD_INPUT_SUBJECT   NCHAR(6) = 'DSAFIC'
--/* PAR 2 */ DECLARE @COD_INPUT_ENTITY    NVARCHAR(100) = 'SNAPSHOT_SAT_ORGANIZATION_IDENTIFICATION'
--/* PAR 3 */ DECLARE @COD_OUTPUT_SUBJECT  NCHAR(6) = 'OMAFIC'
--/* PAR 4 */ DECLARE @COD_OUTPUT_ENTITY   NVARCHAR(100) = 'SAT_ORGANIZATION_IDENTIFICATION'
--/* PAR 5 */ DECLARE @M_COD_PROCESS       NVARCHAR(18)  = '60001002'
--/* PAR 6 */ DECLARE @M_COD_INSTANCE      BIGINT        = 2
--/* PAR 7 */ DECLARE @DEBUG               BIT = 0

IF @DEBUG = 0 SET NOCOUNT ON

/* BEGIN: Initialize Process Parameters */
DECLARE @PROCESS_NAME				VARCHAR(117) 	='PROCESS_'+@M_COD_PROCESS+'_'+@COD_OUTPUT_ENTITY
PRINT @PROCESS_NAME
/* END: Initialize Process Parameters */

/* BEGIN: DECLARE parameters */
--DECLARE @M_COD_SOR					NVARCHAR(18) -- Bigint is maximaal 18 digits		
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
/* PAR 4 */ ,'MDAPEL.GF_0202_OMAXXX_STATUS is called'

/**********************************************************************************/
-- END: Write log message
/**********************************************************************************/


/**********************************************************************************/
/**********************************************************************************/
-- BEGIN: Specific Pre-Process
/**********************************************************************************/
/**********************************************************************************/

IF @DEBUG = 1 PRINT'******** SPECIFIC PRE-PROCESS ********'

/**********************************************************************************/
-- BEGIN: Determine number of input records
/**********************************************************************************/

BEGIN TRY
  SET @SQL1 = N'SELECT @LOG = COUNT(1) FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY
  EXECUTE sp_executesql @SQL1, N'@LOG NVARCHAR(MAX) OUTPUT', @LOG = @LOG OUTPUT
  
  SET @LOG = 'Number of input Records: ' +@LOG
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
-- END: Determine number of input records
/**********************************************************************************/


/**********************************************************************************/
-- BEGIN: Determine M_UTC_SNAPSHOT to process from input table
/**********************************************************************************/
-- If there are more than 1 DTID's the oldest will be processed.
BEGIN TRY
  SET @SQL1 = N'select @M_UTC_SNAPSHOT = isnull(min(M_UTC_SNAPSHOT), CAST(''01-01-1000'' as DATETIME2))
                  from '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+'
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
-- BEGIN: Determine M_UTC_SNAPSHOT_MAX from OUTPUT Table
/**********************************************************************************/
BEGIN TRY
  SET @SQL1=
  N'(select @M_UTC_SNAPSHOT_MAX =  max(X.M_UTC_SNAPSHOT)
     from (select isnull(max(M_UTC_START),CAST(''01-01-1000'' as DATETIME2)) as M_UTC_SNAPSHOT
			from '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'
            union 
           select isnull(max(dateadd(ss,1,M_UTC_END)),CAST(''01-01-1000'' as DATETIME2))  as M_UTC_SNAPSHOT
            from '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+' 
			where M_UTC_END < ''9999-12-31''
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
            from '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'                      
            union 
           select isnull(min(dateadd(ss,1,M_UTC_END)),CAST(''01-01-1000'' as DATETIME2))  as M_UTC_SNAPSHOT
             from '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'
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
  CREATE TABLE #UTC_SNAPSHOT (M_UTC_SNAPSHOT DATETIME2(0))
  --Collect list of M_UTC_START dates first
  SET @SQL1 = N'insert into #UTC_SNAPSHOT select distinct M_UTC_SNAPSHOT 
                                            from (select M_UTC_START AS M_UTC_SNAPSHOT
                                                    from '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+' 
								                            
                                                   union
                                   
                                                  select dateadd(ss,1,M_UTC_END) as M_UTC_SNAPSHOT
                                                    from '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+' 
								                   where M_UTC_END <> ''9999-12-31 00:00:00''
								                  ) resultset'

  IF @DEBUG = 1 PRINT @SQL1
    EXECUTE sp_executesql  @SQL1
  IF @DEBUG = 1 SELECT * FROM #UTC_SNAPSHOT				
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
      IF @M_UTC_SNAPSHOT IN (SELECT M_UTC_SNAPSHOT FROM #UTC_SNAPSHOT)
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
  DROP TABLE #UTC_SNAPSHOT
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
			 WHERE TABLE_NAME   = '''+@COD_INPUT_ENTITY+'''
			   AND TABLE_SCHEMA = '''+@COD_INPUT_SUBJECT+'''
			   AND COLUMN_NAME NOT IN(''M_IDR''
			                         ,''M_UTC_SNAPSHOT''
			                         ,''M_COD_PROCESS''
			                         ,''M_COD_SOR''
			                         ,''M_UTC_RECORD_INSERTED''
			                         ,''M_CRC''
			                         ,''M_COD_KEY'' 
			                         )
			 ORDER BY ORDINAL_POSITION
			 FOR XML PATH('''')
			 ), 1, 1, '''') )'
  IF @DEBUG = 1 PRINT @SQL1
    EXECUTE sp_executesql @SQL1, N'@DDA_COLUMNLIST VARCHAR(MAX) OUTPUT', @DDA_COLUMNLIST = @DDA_COLUMNLIST OUTPUT
  IF @DEBUG = 1 PRINT @DDA_COLUMNLIST

  --Collect OMA table columns, already formated in a list without M_IDR AND M_UTC_RECORD_INSERTED
  SET @SQL1 = N'SELECT @OMA_COLUMNLIST = (SELECT STUFF((SELECT '', '' + quotename( COLUMN_NAME , '']'') 
			 FROM INFORMATION_SCHEMA.COLUMNS
			 WHERE TABLE_NAME   = '''+@COD_OUTPUT_ENTITY+'''
			   AND TABLE_SCHEMA = '''+@COD_OUTPUT_SUBJECT+'''
			   AND COLUMN_NAME NOT IN(''M_IDR''
			                         ,''M_UTC_RECORD_INSERTED''
			                         )
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
  SET @SQL1 = N'insert into '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'
  ('+@OMA_COLUMNLIST+')
  SELECT
   M_COD_SOR				 as M_COD_SOR
  ,M_UTC_SNAPSHOT			 as M_UTC_START
  ,''9999-12-31 00:00:00''   as M_UTC_END
  ,'+@M_COD_PROCESS+'        as M_COD_PROCESS_INSERTED
  ,NULL					     as M_COD_PROCESS_UPDATED 
  ,NULL					     as M_UTC_RECORD_UPDATED
  ,M_CRC                     as M_CRC
  ,M_COD_KEY				 as M_COD_KEY
  ,'+@DDA_COLUMNLIST+'
   FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+'
  WHERE M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
'
BEGIN TRAN
  IF @DEBUG =  1 PRINT @SQL1
  EXECUTE sp_executesql @SQL1, N'@M_UTC_SNAPSHOT DATETIME2(0)', @M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
  SET @ROWCOUNT = @@ROWCOUNT
COMMIT TRAN

/* BEGIN: delete processed records */ 
SET @SQL2 = 
N'
 DELETE 
   FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+'
  WHERE M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
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
-- Subscenario Prev		Snapshot	DIFF_PREV_SNAP	Action
-- AFTER_01    Yes		No          #               Update (update M_UTC_END of PREV set to M_UTC_SNAPSHOT-1)
-- AFTER_02    Yes		Yes         Yes             Update (update M_UTC_END of PREV set to M_UTC_SNAPSHOT-1)
-- AFTER_03    Yes      Yes         Yes             Insert (insert Snapshot set M_UTC_END to '9999-12-31')
-- AFTER_04    No       Yes         #               Insert (Insert Snapshot set M_UTC_END to '9999-12-31')
-- AFTER_05	   Yes		Yes         No              Do Nothing
--------------------------------------------------------------------------------------------------------------------------
IF @DEBUG = 1 PRINT '-----Scenario AFTER-----'

-- BEGIN SubScenario AFTER_01 and AFTER_02:
SET @SQL1 = N'
UPDATE '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'
   SET M_UTC_END = DATEADD(SS,-1,@M_UTC_SNAPSHOT)
      ,M_COD_PROCESS_UPDATED = '+@M_COD_PROCESS+'
      ,M_UTC_RECORD_UPDATED = GETUTCDATE()
 WHERE 1=1
   AND M_IDR IN (-- BEGIN AFTER_01
                 SELECT M_IDR
                   FROM (SELECT M_COD_KEY AS M_COD_KEY_SRC
                           FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+'
                          WHERE 1=1
                            AND M_UTC_SNAPSHOT  = @M_UTC_SNAPSHOT                 
                        ) SRC
                        FULL OUTER JOIN
                        (SELECT M_IDR
                               ,M_COD_KEY AS M_COD_KEY_TRG
                           FROM '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'
                          WHERE 1=1
                            AND @M_UTC_SNAPSHOT BETWEEN M_UTC_START AND M_UTC_END
                        ) TRG
                        ON  SRC.M_COD_KEY_SRC = TRG.M_COD_KEY_TRG
                        WHERE 1=1
                          AND M_COD_KEY_SRC IS NULL
                          AND M_IDR IS NOT NULL    
                 -- END AFTER_01     
                 UNION -- Sorted and Deduplicated
                 -- BEGIN AFTER_02       
                 SELECT M_IDR
                   FROM (SELECT M_COD_KEY AS M_COD_KEY_SRC
                               ,M_CRC     AS M_CRC_SRC
                           FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+'
                          WHERE 1=1
                            AND M_UTC_SNAPSHOT  = @M_UTC_SNAPSHOT                   
                        ) SRC
                        FULL OUTER JOIN
                        (SELECT M_IDR
                               ,M_COD_KEY AS M_COD_KEY_TRG
                               ,M_CRC     AS M_CRC_TRG
                           FROM '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'
                          WHERE 1=1
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
print @DDA_COLUMNLIST 
SET @SQL1 = N'
INSERT INTO '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'
(M_COD_SOR
,M_UTC_START
,M_UTC_END
,M_COD_PROCESS_INSERTED
,M_CRC
,M_COD_KEY
,'+@DDA_COLUMNLIST+'
)
SELECT 
 M_COD_SOR                     AS M_COD_SOR
,M_UTC_SNAPSHOT                AS M_UTC_START
,''9999-12-31 00:00:00''       AS M_UTC_END
,'+@M_COD_PROCESS+'            AS M_COD_PROCESS_INSERTED
,M_CRC
,M_COD_KEY
,'+@DDA_COLUMNLIST+' 
  FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+' SRC
 WHERE 1=1
   AND M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
   AND NOT EXISTS (SELECT M_IDR
                     FROM '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+' TRG
                    WHERE 1=1
                      AND TRG.M_COD_KEY = SRC.M_COD_KEY
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

/* BEGIN: delete processed records */ 
SET @SQL2 = N'
DELETE 
  FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+'
 WHERE M_UTC_SNAPSHOT = @M_UTC_SNAPSHOT
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
/* BEGIN: Scenario Done   .                                                       */
/**********************************************************************************/
IF @DEBUG = 1 PRINT'********** DONE **********'
IF @SCENARIO = 'DONE'
BEGIN TRY
  IF @DEBUG = 1 print 'Moet nog uitgewerkt worden.'
  SET @LOG = 'Done scenario moet nog uitgewerkt worden.'
  EXECUTE MDAPEL.GF_1000_INSERT_LOG 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,'INFORMATION'
  /* PAR 4 */ ,@LOG 
END TRY

BEGIN CATCH
  SET @LOG = 'Done scenario - ' + ERROR_MESSAGE() + ' | '+ @SQL1
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
-- BEGIN UPDATE METADATA
IF @SCENARIO IN ('INITIAL LOAD','AFTER','BEFORE','BETWEEN')
BEGIN 
-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Start updating MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC'
-- END INSERT LOG


INSERT INTO MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC
(COD_ENTITY
,COD_SOR
,UTC_SNAPSHOT
)
VALUES
(@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY
,-2 -- SOR is not Applicable in OMAFIC.
,@M_UTC_SNAPSHOT
)

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Finnished updating MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC'
-- END INSERT LOG

END -- @SCENARIO IN ('INITIAL LOAD','AFTER','BEFORE','BETWEEN','DONE')
-- END UPDATE METADATA
       
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

GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0203_ISAXXX_DIM_TYPE_II]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0203_ISAXXX_DIM_TYPE_II] 
/* PAR 1 */ @COD_INPUT_SUBJECT   NCHAR(6)
/* PAR 2 */,@COD_INPUT_ENTITY    NVARCHAR(100)
/* PAR 3 */,@COD_OUTPUT_SUBJECT  NCHAR(6)
/* PAR 4 */,@COD_OUTPUT_ENTITY   NVARCHAR(100)
/* PAR 5 */,@M_COD_PROCESS       NVARCHAR(18)
/* PAR 6 */,@M_COD_INSTANCE      BIGINT
/* PAR 7 */,@DEBUG               BIT = 0
AS
-- =========================================================================================
-- Author(s)          : Michael Doves
-- date Created       : 2012-12-18
-- Version            : 1
-- Date Last Modified :          
-- Description        :	DIMENSION UPDATE KIMBAAL TYPE II.
-- Parameters         :	
-- Modifications      : Automatic Logging and error Handling is integrated.
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
BEGIN TRY-- A
--/* PAR 1 */ DECLARE @COD_INPUT_SUBJECT   NCHAR(6) = 'DSAFIC'
--/* PAR 2 */ DECLARE @COD_INPUT_ENTITY    NVARCHAR(100) = 'SNAPSHOT_SAT_ORGANIZATION_IDENTIFICATION'
--/* PAR 3 */ DECLARE @COD_OUTPUT_SUBJECT  NCHAR(6) = 'OMAFIC'
--/* PAR 4 */ DECLARE @COD_OUTPUT_ENTITY   NVARCHAR(100) = 'SAT_ORGANIZATION_IDENTIFICATION'
--/* PAR 5 */ DECLARE @M_COD_PROCESS       NVARCHAR(18)  = '60001002'
--/* PAR 6 */ DECLARE @M_COD_INSTANCE      BIGINT        = 2
--/* PAR 7 */ DECLARE @DEBUG               BIT = 0

IF @DEBUG = 0 SET NOCOUNT ON

/* BEGIN: Initialize Process Parameters */
DECLARE @PROCESS_NAME				NVARCHAR(117) 	='PROCESS_'+@M_COD_PROCESS+'_'+@COD_OUTPUT_ENTITY
PRINT @PROCESS_NAME
/* END: Initialize Process Parameters */

/* BEGIN: DECLARE parameters */
--DECLARE @M_COD_SOR					NVARCHAR(18) -- Bigint is maximaal 18 digits		
DECLARE @SQL1						NVARCHAR(MAX)
DECLARE @SQL2						NVARCHAR(MAX)
DECLARE @SQL3						NVARCHAR(MAX)
DECLARE @BIGSQL						NVARCHAR(MAX)
DECLARE @M_DAT_SNAPSHOT				DATE
DECLARE @M_DAT_SNAPSHOT_MAX			DATE
DECLARE @M_DAT_SNAPSHOT_MIN			DATE
DECLARE @M_DAT_SNAPSHOT_PREVIOUS	DATE
DECLARE @M_DAT_SNAPSHOT_NEXT		DATE
DECLARE @M_DAT_START				DATE
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
/* PAR 4 */ ,'MDAPEL.GF_0203_ISAXXX_DIM_TYPE_II is called'

/**********************************************************************************/
-- END: Write log message
/**********************************************************************************/


/**********************************************************************************/
/**********************************************************************************/
-- BEGIN: Specific Pre-Process
/**********************************************************************************/
/**********************************************************************************/

IF @DEBUG = 1 PRINT'******** SPECIFIC PRE-PROCESS ********'

/**********************************************************************************/
-- BEGIN: Determine number of input records
/**********************************************************************************/

BEGIN TRY
  SET @SQL1 = N'SELECT @LOG = COUNT(1) FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY
  EXECUTE sp_executesql @SQL1, N'@LOG NVARCHAR(MAX) OUTPUT', @LOG = @LOG OUTPUT
  
  SET @LOG = 'Number of input Records: ' +@LOG
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
-- END: Determine number of input records
/**********************************************************************************/


/**********************************************************************************/
-- BEGIN: Determine M_DAT_SNAPSHOT to process from input table
/**********************************************************************************/
-- If there are more than 1 DTID's the oldest will be processed.
BEGIN TRY
  SET @SQL1 = N'select @M_DAT_SNAPSHOT = isnull(min(M_DAT_SNAPSHOT), CAST(''1000-01-01'' as DATE))
                  from '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+'
               '
  IF @DEBUG = 1 PRINT @SQL1
    EXECUTE sp_executesql @SQL1, N'@M_DAT_SNAPSHOT DATE OUTPUT', @M_DAT_SNAPSHOT = @M_DAT_SNAPSHOT OUTPUT
  
  IF @DEBUG = 1 PRINT '@M_DAT_SNAPSHOT: ' +cast(@M_DAT_SNAPSHOT as NVARCHAR(10))
    SET @LOG = '@M_DAT_SNAPSHOT: ' + ISNULL(cast(@M_DAT_SNAPSHOT as NVARCHAR(10)), 'No Snapshot')
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
-- END: Determine M_DAT_SNAPSHOT to process from DDADTI
/**********************************************************************************/

/**********************************************************************************/
-- BEGIN: Determine M_DAT_SNAPSHOT_MAX from OUTPUT Table
/**********************************************************************************/
BEGIN TRY
  SET @SQL1=
  N'(select @M_DAT_SNAPSHOT_MAX =  max(X.M_DAT_SNAPSHOT)
     from (select isnull(max(M_DAT_START),CAST(''1000-01-01'' as DATE)) as M_DAT_SNAPSHOT
			from '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'
            union 
           select isnull(max(dateadd(DD,1,M_DAT_END)),CAST(''1000-01-01'' as DATE))  as M_DAT_SNAPSHOT
            from '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+' 
			where M_DAT_END < ''9999-12-31''
           ) X
	)'
  IF @DEBUG = 1 PRINT @SQL1
    EXECUTE sp_executesql @SQL1, N'@M_DAT_SNAPSHOT_MAX DATE OUTPUT', @M_DAT_SNAPSHOT_MAX = @M_DAT_SNAPSHOT_MAX OUTPUT
		
  IF @DEBUG = 1 PRINT '@M_DAT_SNAPSHOT_MAX: ' +cast(@M_DAT_SNAPSHOT_MAX as NVARCHAR(10))
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
-- END: Determine M_DAT_SNAPSHOT_MAX from OUTPUT Table
/**********************************************************************************/


/**********************************************************************************/
-- BEGIN: Determine M_DAT_SNAPSHOT_MIN from OUTPUT Table
/**********************************************************************************/
BEGIN TRY
  SET @SQL1 =
  N'(select @M_DAT_SNAPSHOT_MIN =  min(X.M_DAT_SNAPSHOT)
     from (select isnull(min(M_DAT_START),CAST(''1000-01-01'' as DATE)) as M_DAT_SNAPSHOT
            from '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'                      
            union 
           select isnull(min(dateadd(DD,1,M_DAT_END)),CAST(''1000-01-01'' as DATE))  as M_DAT_SNAPSHOT
             from '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'
			where M_DAT_END < ''9999-12-31''
           ) X  
  )'
  IF @DEBUG = 1 PRINT @SQL1
    EXECUTE sp_executesql @SQL1, N'@M_DAT_SNAPSHOT_MIN DATE OUTPUT', @M_DAT_SNAPSHOT_MIN = @M_DAT_SNAPSHOT_MIN OUTPUT
		
  IF @DEBUG = 1 PRINT '@M_DAT_SNAPSHOT_MIN: ' +cast(@M_DAT_SNAPSHOT_MIN as NVARCHAR(10))
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
-- END: Determine M_DAT_SNAPSHOT_MAX from OUTPUT Table
/**********************************************************************************/


/**********************************************************************************/
-- BEGIN: Determine @SCENARIO
/**********************************************************************************/
IF @DEBUG = 1 PRINT'******* DETERMINE SCENARIO *********'
BEGIN TRY
  CREATE TABLE #DAT_SNAPSHOT (M_DAT_SNAPSHOT DATE)
  --Collect list of M_UTC_START dates first
  SET @SQL1 = N'insert into #DAT_SNAPSHOT select distinct M_DAT_SNAPSHOT 
                                            from (select M_DAT_START AS M_DAT_SNAPSHOT
                                                    from '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+' 
								                            
                                                   union
                                   
                                                  select dateadd(DD,1,M_DAT_END) as M_DAT_SNAPSHOT
                                                    from '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+' 
								                   where M_DAT_END <> ''9999-12-31''
								                  ) resultset'

  IF @DEBUG = 1 PRINT @SQL1
    EXECUTE sp_executesql  @SQL1
  IF @DEBUG = 1 SELECT * FROM #DAT_SNAPSHOT				
  IF @M_DAT_SNAPSHOT = convert(DATE,'1000-01-01')
    BEGIN 
      SET @SCENARIO = UPPER('No_Snapshot')
    END
  ELSE IF @M_DAT_SNAPSHOT_MAX = convert(DATE,'1000-01-01') 
      AND @M_DAT_SNAPSHOT_MIN = convert(DATE,'1000-01-01') 
      AND @M_DAT_SNAPSHOT    <> convert(DATE,'1000-01-01') 
    BEGIN 
       SET @SCENARIO = UPPER('Initial_Load')
    END  
  ELSE IF @M_DAT_SNAPSHOT_MAX <> convert(DATE,'1000-01-01') 
      AND @M_DAT_SNAPSHOT      > @M_DAT_SNAPSHOT_MAX 
    BEGIN 
       SET @SCENARIO = UPPER('After')
    END 
  ELSE IF @M_DAT_SNAPSHOT_MIN <> convert(DATE,'1000-01-01') 
      AND @M_DAT_SNAPSHOT < @M_DAT_SNAPSHOT_MIN 
    BEGIN 
       SET @SCENARIO = UPPER('Before') 
    END 
  ELSE IF @M_DAT_SNAPSHOT BETWEEN @M_DAT_SNAPSHOT_MIN AND @M_DAT_SNAPSHOT_MAX
    BEGIN 
      IF @M_DAT_SNAPSHOT IN (SELECT M_DAT_SNAPSHOT FROM #DAT_SNAPSHOT)
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
  DROP TABLE #DAT_SNAPSHOT
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
			 WHERE TABLE_NAME   = '''+@COD_INPUT_ENTITY+'''
			   AND TABLE_SCHEMA = '''+@COD_INPUT_SUBJECT+'''
			   AND COLUMN_NAME NOT IN(''M_IDR''
			                         ,''M_DAT_SNAPSHOT''
			                         ,''M_COD_PROCESS''
			                         ,''M_COD_SOR''
			                         ,''M_UTC_RECORD_INSERTED''
			                         ,''M_CRC''
			                         ,''M_COD_KEY'' 
			                         )
			 ORDER BY ORDINAL_POSITION
			 FOR XML PATH('''')
			 ), 1, 1, '''') )'
  IF @DEBUG = 1 PRINT @SQL1
    EXECUTE sp_executesql @SQL1, N'@DDA_COLUMNLIST VARCHAR(MAX) OUTPUT', @DDA_COLUMNLIST = @DDA_COLUMNLIST OUTPUT
  IF @DEBUG = 1 PRINT @DDA_COLUMNLIST

  --Collect OMA table columns, already formated in a list without M_IDR AND M_UTC_RECORD_INSERTED
  SET @SQL1 = N'SELECT @OMA_COLUMNLIST = (SELECT STUFF((SELECT '', '' + quotename( COLUMN_NAME , '']'') 
			 FROM INFORMATION_SCHEMA.COLUMNS
			 WHERE TABLE_NAME   = '''+@COD_OUTPUT_ENTITY+'''
			   AND TABLE_SCHEMA = '''+@COD_OUTPUT_SUBJECT+'''
			   AND COLUMN_NAME NOT IN(''M_IDR''
			                         ,''M_UTC_RECORD_INSERTED''
			                         )
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
  SET @SQL1 = N'insert into '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'
  ('+@OMA_COLUMNLIST+')
  SELECT
   M_COD_SOR				 as M_COD_SOR
  ,M_DAT_SNAPSHOT			 as M_DAT_START
  ,''9999-12-31''            as M_DAT_END
  ,'+@M_COD_PROCESS+'        as M_COD_PROCESS_INSERTED
  ,NULL					     as M_COD_PROCESS_UPDATED 
  ,NULL					     as M_UTC_RECORD_UPDATED
  ,M_CRC                     as M_CRC
  ,M_COD_KEY				 as M_COD_KEY
  ,'+@DDA_COLUMNLIST+'
   FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+'
  WHERE M_DAT_SNAPSHOT = @M_DAT_SNAPSHOT
'
BEGIN TRAN
  IF @DEBUG =  1 PRINT @SQL1
  EXECUTE sp_executesql @SQL1, N'@M_DAT_SNAPSHOT DATE', @M_DAT_SNAPSHOT = @M_DAT_SNAPSHOT
  SET @ROWCOUNT = @@ROWCOUNT
COMMIT TRAN

/* BEGIN: delete processed records */ 
SET @SQL2 = 
N'
 DELETE 
   FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+'
  WHERE M_DAT_SNAPSHOT = @M_DAT_SNAPSHOT
 '

IF @DEBUG =  1 PRINT @SQL2
EXECUTE sp_executesql @SQL2, N'@M_DAT_SNAPSHOT DATE', @M_DAT_SNAPSHOT = @M_DAT_SNAPSHOT
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
-- Subscenario Prev		Snapshot	DIFF_PREV_SNAP	Action
-- AFTER_01    Yes		No          #               Update (update M_UTC_END of PREV set to M_DAT_SNAPSHOT-1)
-- AFTER_02    Yes		Yes         Yes             Update (update M_UTC_END of PREV set to M_DAT_SNAPSHOT-1)
-- AFTER_03    Yes      Yes         Yes             Insert (insert Snapshot set M_UTC_END to '9999-12-31')
-- AFTER_04    No       Yes         #               Insert (Insert Snapshot set M_UTC_END to '9999-12-31')
-- AFTER_05	   Yes		Yes         No              Do Nothing
--------------------------------------------------------------------------------------------------------------------------
IF @DEBUG = 1 PRINT '-----Scenario AFTER-----'

-- BEGIN SubScenario AFTER_01 and AFTER_02:
SET @SQL1 = N'
UPDATE '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'
   SET M_DAT_END = DATEADD(DD,-1,@M_DAT_SNAPSHOT)
      ,M_COD_PROCESS_UPDATED = '+@M_COD_PROCESS+'
      ,M_UTC_RECORD_UPDATED = GETUTCDATE()
 WHERE 1=1
   AND M_IDR IN (-- BEGIN AFTER_01
                 SELECT M_IDR
                   FROM (SELECT M_COD_KEY AS M_COD_KEY_SRC
                           FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+'
                          WHERE 1=1
                            AND M_DAT_SNAPSHOT  = @M_DAT_SNAPSHOT                 
                        ) SRC
                        FULL OUTER JOIN
                        (SELECT M_IDR
                               ,M_COD_KEY AS M_COD_KEY_TRG
                           FROM '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'
                          WHERE 1=1
                            AND @M_DAT_SNAPSHOT BETWEEN M_DAT_START AND M_DAT_END
                        ) TRG
                        ON  SRC.M_COD_KEY_SRC = TRG.M_COD_KEY_TRG
                        WHERE 1=1
                          AND M_COD_KEY_SRC IS NULL
                          AND M_IDR IS NOT NULL    
                 -- END AFTER_01     
                 UNION -- Sorted and Deduplicated
                 -- BEGIN AFTER_02       
                 SELECT M_IDR
                   FROM (SELECT M_COD_KEY AS M_COD_KEY_SRC
                               ,M_CRC     AS M_CRC_SRC
                           FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+'
                          WHERE 1=1
                            AND M_DAT_SNAPSHOT  = @M_DAT_SNAPSHOT                   
                        ) SRC
                        FULL OUTER JOIN
                        (SELECT M_IDR
                               ,M_COD_KEY AS M_COD_KEY_TRG
                               ,M_CRC     AS M_CRC_TRG
                           FROM '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'
                          WHERE 1=1
                            AND @M_DAT_SNAPSHOT BETWEEN M_DAT_START AND M_DAT_END
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
	EXECUTE sp_executesql @SQL1, N'@M_DAT_SNAPSHOT DATE', @M_DAT_SNAPSHOT = @M_DAT_SNAPSHOT
	SET @ROWCOUNT = @@ROWCOUNT
	IF @ROWCOUNT = 0 SET @ROWCOUNT = @ROWCOUNT_P
	SET @ROWCOUNT_P = @ROWCOUNT
COMMIT TRAN
IF @DEBUG =  1 SELECT @ROWCOUNT ROW_COUNT
-- END SubScenario AFTER_01 and AFTER_02:

-- BEGIN SubScenario AFTER_03 and AFTER_04:
print @DDA_COLUMNLIST 
SET @SQL1 = N'
INSERT INTO '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+'
(M_COD_SOR
,M_DAT_START
,M_DAT_END
,M_COD_PROCESS_INSERTED
,M_CRC
,M_COD_KEY
,'+@DDA_COLUMNLIST+'
)
SELECT 
 M_COD_SOR                     AS M_COD_SOR
,M_DAT_SNAPSHOT                AS M_DAT_START
,''9999-12-31''                AS M_DAT_END
,'+@M_COD_PROCESS+'            AS M_COD_PROCESS_INSERTED
,M_CRC
,M_COD_KEY
,'+@DDA_COLUMNLIST+' 
  FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+' SRC
 WHERE 1=1
   AND M_DAT_SNAPSHOT = @M_DAT_SNAPSHOT
   AND NOT EXISTS (SELECT M_IDR
                     FROM '+@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY+' TRG
                    WHERE 1=1
                      AND TRG.M_COD_KEY = SRC.M_COD_KEY
                      AND SRC.M_DAT_SNAPSHOT BETWEEN TRG.M_DAT_START AND TRG.M_DAT_END
                  ) 
'
IF @DEBUG = 1 PRINT @SQL1
BEGIN TRAN
	EXECUTE sp_executesql @SQL1, N'@M_DAT_SNAPSHOT DATE', @M_DAT_SNAPSHOT = @M_DAT_SNAPSHOT
	SET @ROWCOUNT = @@ROWCOUNT
	IF @ROWCOUNT = 0 SET @ROWCOUNT = @ROWCOUNT_P
	SET @ROWCOUNT_P = @ROWCOUNT
COMMIT TRAN
IF @DEBUG =  1 SELECT @ROWCOUNT ROW_COUNT
-- END SubScenario AFTER_03 and AFTER_04:

/* BEGIN: delete processed records */ 
SET @SQL2 = N'
DELETE 
  FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+'
 WHERE M_DAT_SNAPSHOT = @M_DAT_SNAPSHOT
'
IF @DEBUG =  1 PRINT @SQL2
EXECUTE sp_executesql @SQL2, N'@M_DAT_SNAPSHOT DATE', @M_DAT_SNAPSHOT = @M_DAT_SNAPSHOT
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
/* BEGIN: Scenario Done   .                                                       */
/**********************************************************************************/
IF @DEBUG = 1 PRINT'********** DONE **********'
IF @SCENARIO = 'DONE'
BEGIN TRY
  IF @DEBUG = 1 print 'Moet nog uitgewerkt worden.'
  SET @LOG = 'Done scenario moet nog uitgewerkt worden.'
  EXECUTE MDAPEL.GF_1000_INSERT_LOG 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,'INFORMATION'
  /* PAR 4 */ ,@LOG 

   SET @LOG = 'De snapshot records worden verwijderd.'
  EXECUTE MDAPEL.GF_1000_INSERT_LOG 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,'INFORMATION'
  /* PAR 4 */ ,@LOG 

  /* BEGIN: delete processed records */ 
SET @SQL2 = N'
DELETE 
  FROM '+@COD_INPUT_SUBJECT+'.'+@COD_INPUT_ENTITY+'
 WHERE M_DAT_SNAPSHOT = @M_DAT_SNAPSHOT
'
IF @DEBUG =  1 PRINT @SQL2
EXECUTE sp_executesql @SQL2, N'@M_DAT_SNAPSHOT DATE', @M_DAT_SNAPSHOT = @M_DAT_SNAPSHOT
/* END: delete processed records */

END TRY

BEGIN CATCH
  SET @LOG = 'Done scenario - ' + ERROR_MESSAGE() + ' | '+ @SQL1
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
-- BEGIN UPDATE METADATA
IF @SCENARIO IN ('INITIAL LOAD','AFTER','BEFORE','BETWEEN')
BEGIN 
-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Start updating MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC'
-- END INSERT LOG


INSERT INTO MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_DAT
(COD_ENTITY
,COD_SOR
,DAT_SNAPSHOT
)
VALUES
(@COD_OUTPUT_SUBJECT+'.'+@COD_OUTPUT_ENTITY
,-2 -- SOR is not Applicable in ISACOM.
,@M_DAT_SNAPSHOT
)

-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_1000_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Finnished updating MDAPEL.ENTITY_PROCESSED_SNAPSHOTS_UTC'
-- END INSERT LOG

END -- @SCENARIO IN ('INITIAL LOAD','AFTER','BEFORE','BETWEEN','DONE')
-- END UPDATE METADATA
       
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

GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0902_CREATE_TABLE_OMAXXX_FOR_UPDATE_SATELITE_UTC_TYPE_02]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0902_CREATE_TABLE_OMAXXX_FOR_UPDATE_SATELITE_UTC_TYPE_02] 
 /* PARAMETER 1 */ @INPUT_SUBJECT  NCHAR(6)
,/* PARAMETER 2 */ @INPUT_ENTITY   NVARCHAR(100) 
,/* PARAMETER 3 */ @OUTPUT_SUBJECT NCHAR(6)
,/* PARAMETER 4 */ @OUTPUT_ENTITY  NVARCHAR(100) 
-- =========================================================================================
-- Author(s)          : Michael Doves
-- date Created       : 2012-04-12
-- Version            : 3
-- Date Last Modified : 2012-04-12         
-- Description        :	based upon a SOURCE snapshot table with some prohibited metadata columns
--                      the TARGET Update Type II table will be generated. This generic function
--                      will mostly be used for Satellite tables in de Businnes Data Vault (EMAFIC)
-- Parameters         :	@INPUT_SUBJECT
--                      @INPUT_ENTITY
--                      @OUTPUT_SUBJECT
--                      @OUTPUT_ENTITY
-- Modifications      : 
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-- ========================================================================================
AS
BEGIN
-- BEGIN PARAMETER DECLARATIONS

/* EXAMPLE CALL OF GENERIC FUNCATION
EXECUTE [MDAPEL].[GF_0902_CREATE_TABLE_OMAXXX_FOR_UPDATE_SATELITE_UTC_TYPE_02] 
 'DSAFIC'
,'SNAPSHOT_SAT_GL_ACCOUNT'
,'OMAFIC'
,'SAT_GL_ACCOUNT'
*/
 
DECLARE @SQL1			  NVARCHAR(MAX)
DECLARE @INPUT_COLUMNLIST NVARCHAR(MAX)
-- END PARAMETER DECLARATIONS

-- BEGIN CREATE DYNAMIC COLUMN LIST
SET @SQL1 = N'SELECT @INPUT_COLUMNLIST = 
(SELECT STUFF ((SELECT '', ['' + COLUMN_NAME +''] ''+ 
   CASE DATA_TYPE
     WHEN ''int''         THEN ''int''
     WHEN ''tinyint''     THEN ''tinyint''
     WHEN ''smallint''    THEN ''smallint''
     WHEN ''bigint''      THEN ''bigint''
     WHEN ''decimal''     THEN ''decimal(''+ISNULL(CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)), (CAST(NUMERIC_PRECISION AS VARCHAR(5)) +'',''+ CAST(NUMERIC_SCALE AS VARCHAR(4))))+'')''
     WHEN ''numeric''     THEN ''numeric(''+ISNULL(CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)), (CAST(NUMERIC_PRECISION AS VARCHAR(5)) +'',''+ CAST(NUMERIC_SCALE AS VARCHAR(4))))+'')''
     WHEN ''datetime''    THEN ''datetime''
     WHEN ''datetime2''   THEN ''datetime2''
     WHEN ''date''        THEN ''date''
     WHEN ''bit''         THEN ''bit''
     WHEN ''nchar''       THEN ''nchar(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
     WHEN ''char''        THEN ''char(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
     WHEN ''nvarchar''    THEN ''nvarchar(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
     WHEN ''varchar''     THEN ''varchar(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
     WHEN ''text''        THEN ''text''
     ELSE NULL 
   END
   +'' ''+ 
  CASE 
    WHEN IS_NULLABLE = ''NO'' 
    THEN ''NOT NULL'' 
    ELSE '''' 
   END
  FROM INFORMATION_SCHEMA.COLUMNS
 WHERE 1=1
   AND TABLE_NAME = '''+@INPUT_ENTITY+'''
   AND TABLE_SCHEMA = '''+@INPUT_SUBJECT+'''
   AND SUBSTRING(COLUMN_NAME,1,2) <> ''M_'' 
 ORDER BY ORDINAL_POSITION FOR XML PATH('''')
 ), 1, 1, '''') 
)'
-- END CREATE DYNAMIC COLUMN LIST

EXECUTE SP_EXECUTESQL @SQL1, N'@INPUT_COLUMNLIST NVARCHAR(MAX) OUTPUT', @INPUT_COLUMNLIST = @INPUT_COLUMNLIST OUTPUT

-- BEGIN CREATE DYNAMIC CREATE TABLE
SET @SQL1 = N'CREATE TABLE '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+'
([M_IDR]                  [BIGINT] IDENTITY(1,1) NOT NULL
,[M_COD_SOR]              [BIGINT]               NOT NULL
,[M_UTC_START]            [DATETIME2](0)         NOT NULL
,[M_UTC_END]              [DATETIME2](0)         NOT NULL
,[M_COD_PROCESS_INSERTED] [BIGINT]               NOT NULL
,[M_COD_PROCESS_UPDATED]  [BIGINT]                   NULL
,[M_UTC_RECORD_INSERTED]  [DATETIME2](0)         NOT NULL
,[M_UTC_RECORD_UPDATED]   [DATETIME2](0)             NULL
,[M_CRC]                  [BIGINT]               NOT NULL
,[M_COD_KEY]              [NVARCHAR](100)        NOT NULL
,'+@INPUT_COLUMNLIST+'
)
-- BEGIN PK00
ALTER TABLE '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
  ADD CONSTRAINT PK00_'+@OUTPUT_ENTITY+' PRIMARY KEY CLUSTERED 
   (M_IDR ASC) WITH (PAD_INDEX  = OFF
                    ,STATISTICS_NORECOMPUTE  = OFF
                    ,SORT_IN_TEMPDB = OFF
                    ,IGNORE_DUP_KEY = OFF
                    ,ONLINE = OFF
                    ,ALLOW_ROW_LOCKS  = ON
                    ,ALLOW_PAGE_LOCKS  = ON
                    ) ON [PRIMARY]
-- END   PK00
-- BEGIN UK01
CREATE UNIQUE NONCLUSTERED INDEX UK01_'+@OUTPUT_ENTITY+' 
    ON '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
      (M_UTC_START ASC
      ,M_COD_KEY   ASC
      )WITH (PAD_INDEX  = OFF
            ,STATISTICS_NORECOMPUTE  = OFF
            ,SORT_IN_TEMPDB = OFF
            ,IGNORE_DUP_KEY = OFF
            ,DROP_EXISTING = OFF
            ,ONLINE = OFF
            ,ALLOW_ROW_LOCKS  = ON
            ,ALLOW_PAGE_LOCKS  = ON
            ) ON [PRIMARY]
-- END   UK01
-- BEGIN UK02
CREATE UNIQUE NONCLUSTERED INDEX UK02_'+@OUTPUT_ENTITY+' 
    ON '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
      (M_UTC_END ASC
      ,M_COD_KEY ASC
      )WITH (PAD_INDEX  = OFF
            ,STATISTICS_NORECOMPUTE  = OFF
            ,SORT_IN_TEMPDB = OFF
            ,IGNORE_DUP_KEY = OFF
            ,DROP_EXISTING = OFF
            ,ONLINE = OFF
            ,ALLOW_ROW_LOCKS  = ON
            ,ALLOW_PAGE_LOCKS  = ON
            ) ON [PRIMARY]
-- END   UK02
-- BEGIN CN03
ALTER TABLE '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
  ADD CONSTRAINT CN03_'+@OUTPUT_ENTITY+' DEFAULT (GETUTCDATE()) FOR M_UTC_RECORD_INSERTED
-- END   CN03
-- BEGIN IX04
CREATE NONCLUSTERED INDEX IX04_'+@OUTPUT_ENTITY+' 
    ON '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
    (M_UTC_START ASC) WITH (PAD_INDEX  = OFF
                           ,STATISTICS_NORECOMPUTE  = OFF
                           ,SORT_IN_TEMPDB = OFF
                           ,IGNORE_DUP_KEY = OFF
                           ,DROP_EXISTING = OFF
                           ,ONLINE = OFF
                           ,ALLOW_ROW_LOCKS  = ON
                           ,ALLOW_PAGE_LOCKS  = ON
                           ) ON [PRIMARY]
-- END   IX04
-- BEGIN IX05
CREATE NONCLUSTERED INDEX IX05_'+@OUTPUT_ENTITY+' 
    ON '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
    (M_UTC_END ASC) WITH (PAD_INDEX  = OFF
                         ,STATISTICS_NORECOMPUTE  = OFF
                         ,SORT_IN_TEMPDB = OFF
                         ,IGNORE_DUP_KEY = OFF
                         ,DROP_EXISTING = OFF
                         ,ONLINE = OFF
                         ,ALLOW_ROW_LOCKS  = ON
                         ,ALLOW_PAGE_LOCKS  = ON
                         ) ON [PRIMARY]
-- END   IX05
-- BEGIN IX06
CREATE NONCLUSTERED INDEX IX06_'+@OUTPUT_ENTITY+' 
    ON '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
    (M_COD_KEY ASC) WITH (PAD_INDEX  = OFF
                         ,STATISTICS_NORECOMPUTE  = OFF
                         ,SORT_IN_TEMPDB = OFF
                         ,IGNORE_DUP_KEY = OFF
                         ,DROP_EXISTING = OFF
                         ,ONLINE = OFF
                         ,ALLOW_ROW_LOCKS  = ON
                         ,ALLOW_PAGE_LOCKS  = ON
                         ) ON [PRIMARY]
-- END   IX06
-- BEGIN IX07
CREATE NONCLUSTERED INDEX IX07_'+@OUTPUT_ENTITY+' 
    ON '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
    (M_COD_SOR ASC) WITH (PAD_INDEX  = OFF
                         ,STATISTICS_NORECOMPUTE  = OFF
                         ,SORT_IN_TEMPDB = OFF
                         ,IGNORE_DUP_KEY = OFF
                         ,DROP_EXISTING = OFF
                         ,ONLINE = OFF
                         ,ALLOW_ROW_LOCKS  = ON
                         ,ALLOW_PAGE_LOCKS  = ON
                         ) ON [PRIMARY]
-- END   IX07
' -- END DYNAMIC SQL
		
IF OBJECT_ID(@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY,'U') IS NULL 
  BEGIN
     EXECUTE SP_EXECUTESQL @SQL1
  END
ELSE PRINT '-- TABLE ALREADY EXISTS, NOT RECREATED (first manual delete) --'

SET @SQL1 = 
N'
-- BEGIN TRU
CREATE TRIGGER '+@OUTPUT_SUBJECT+'.TRU_'+@OUTPUT_ENTITY+' 
    ON '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+'
   FOR UPDATE AS
 BEGIN
   UPDATE T
      SET M_UTC_RECORD_UPDATED = GETUTCDATE()
     FROM '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' T
     INNER JOIN INSERTED I
       ON T.M_IDR = I.M_IDR   
 END
-- END TRU
 '
-- BEGIN CREATE TRIGGER
BEGIN
  EXECUTE SP_EXECUTESQL @SQL1
END
-- END CREATE TRIGGER
----------------------------------------------------------------------------------
-- END create DYNAMIC SAT Table
----------------------------------------------------------------------------------
END -- PROCEDURE

GO
/****** Object:  StoredProcedure [MDAPEL].[GF_0903_CREATE_TABLE_ISAXXX_FOR_UPDATE_DIMENSION_DAT_TYPE_02]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_0903_CREATE_TABLE_ISAXXX_FOR_UPDATE_DIMENSION_DAT_TYPE_02] 
 /* PARAMETER 1 */ @INPUT_SUBJECT  NCHAR(6)
,/* PARAMETER 2 */ @INPUT_ENTITY   NVARCHAR(100) 
,/* PARAMETER 3 */ @OUTPUT_SUBJECT NCHAR(6)
,/* PARAMETER 4 */ @OUTPUT_ENTITY  NVARCHAR(100) 
-- =========================================================================================
-- Author(s)          : Michael Doves
-- date Created       : 2012-04-12
-- Version            : 3
-- Date Last Modified : 2012-04-12         
-- Description        :	based upon a SOURCE snapshot table with some prohibited metadata columns
--                      the TARGET Update Type II table will be generated. This generic function
--                      will mostly be used for Satellite tables in de Businnes Data Vault (EMAFIC)
-- Parameters         :	@INPUT_SUBJECT
--                      @INPUT_ENTITY
--                      @OUTPUT_SUBJECT
--                      @OUTPUT_ENTITY
-- Modifications      : 
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-- ========================================================================================
AS
BEGIN
-- BEGIN PARAMETER DECLARATIONS

/* EXAMPLE CALL OF GENERIC FUNCATION
EXECUTE MDAPEL.GF_0903_CREATE_TABLE_ISAXXX_FOR_UPDATE_DIMENSION_DAT_TYPE_02
 'DSAISA'
,'SNAPSHOT_DIM_COMPETITOR_ORGANIZATION'
,'ISACOM'
,'DIM_COMPETITOR_ORGANIZATION'
*/
 
DECLARE @SQL1			  NVARCHAR(MAX)
DECLARE @INPUT_COLUMNLIST NVARCHAR(MAX)
-- END PARAMETER DECLARATIONS

-- BEGIN CREATE DYNAMIC COLUMN LIST
SET @SQL1 = N'SELECT @INPUT_COLUMNLIST = 
(SELECT STUFF ((SELECT '', ['' + COLUMN_NAME +''] ''+ 
   CASE DATA_TYPE
     WHEN ''int''         THEN ''int''
     WHEN ''tinyint''     THEN ''tinyint''
     WHEN ''smallint''    THEN ''smallint''
     WHEN ''bigint''      THEN ''bigint''
     WHEN ''decimal''     THEN ''decimal(''+ISNULL(CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)), (CAST(NUMERIC_PRECISION AS VARCHAR(5)) +'',''+ CAST(NUMERIC_SCALE AS VARCHAR(4))))+'')''
     WHEN ''numeric''     THEN ''numeric(''+ISNULL(CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)), (CAST(NUMERIC_PRECISION AS VARCHAR(5)) +'',''+ CAST(NUMERIC_SCALE AS VARCHAR(4))))+'')''
     WHEN ''datetime''    THEN ''datetime''
     WHEN ''datetime2''   THEN ''datetime2''
     WHEN ''date''        THEN ''date''
     WHEN ''bit''         THEN ''bit''
     WHEN ''nchar''       THEN ''nchar(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
     WHEN ''char''        THEN ''char(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
     WHEN ''nvarchar''    THEN ''nvarchar(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
     WHEN ''varchar''     THEN ''varchar(''+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN ''max'' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(5)) END +'')''
     WHEN ''text''        THEN ''text''
     WHEN ''time''        THEN ''time(0)''
     ELSE NULL 
   END
   +'' ''+ 
  CASE 
    WHEN IS_NULLABLE = ''NO'' 
    THEN ''NOT NULL'' 
    ELSE '''' 
   END
  FROM INFORMATION_SCHEMA.COLUMNS
 WHERE 1=1
   AND TABLE_NAME = '''+@INPUT_ENTITY+'''
   AND TABLE_SCHEMA = '''+@INPUT_SUBJECT+'''
   AND SUBSTRING(COLUMN_NAME,1,2) <> ''M_'' 
 ORDER BY ORDINAL_POSITION FOR XML PATH('''')
 ), 1, 1, '''') 
)'
-- END CREATE DYNAMIC COLUMN LIST

EXECUTE SP_EXECUTESQL @SQL1, N'@INPUT_COLUMNLIST NVARCHAR(MAX) OUTPUT', @INPUT_COLUMNLIST = @INPUT_COLUMNLIST OUTPUT

-- BEGIN CREATE DYNAMIC CREATE TABLE
SET @SQL1 = N'CREATE TABLE '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+'
([M_IDR]                  [BIGINT] IDENTITY(1,1) NOT NULL
,[M_COD_SOR]              [BIGINT]               NOT NULL
,[M_DAT_START]            [DATE]                 NOT NULL
,[M_DAT_END]              [DATE]                 NOT NULL
,[M_COD_PROCESS_INSERTED] [BIGINT]               NOT NULL
,[M_COD_PROCESS_UPDATED]  [BIGINT]                   NULL
,[M_UTC_RECORD_INSERTED]  [DATETIME2](0)         NOT NULL
,[M_UTC_RECORD_UPDATED]   [DATETIME2](0)             NULL
,[M_CRC]                  [NVARCHAR](50)         NOT NULL
,[M_COD_KEY]              [NVARCHAR](50)         NOT NULL
,'+@INPUT_COLUMNLIST+'
)
-- BEGIN PK00
ALTER TABLE '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
  ADD CONSTRAINT PK00_'+@OUTPUT_ENTITY+' PRIMARY KEY CLUSTERED 
   (M_IDR ASC) WITH (PAD_INDEX  = OFF
                    ,STATISTICS_NORECOMPUTE  = OFF
                    ,SORT_IN_TEMPDB = OFF
                    ,IGNORE_DUP_KEY = OFF
                    ,ONLINE = OFF
                    ,ALLOW_ROW_LOCKS  = ON
                    ,ALLOW_PAGE_LOCKS  = ON
                    ) ON [PRIMARY]
-- END   PK00
-- BEGIN UK01
CREATE UNIQUE NONCLUSTERED INDEX UK01_'+@OUTPUT_ENTITY+' 
    ON '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
      (M_DAT_START ASC
      ,M_COD_KEY   ASC
      )WITH (PAD_INDEX  = OFF
            ,STATISTICS_NORECOMPUTE  = OFF
            ,SORT_IN_TEMPDB = OFF
            ,IGNORE_DUP_KEY = OFF
            ,DROP_EXISTING = OFF
            ,ONLINE = OFF
            ,ALLOW_ROW_LOCKS  = ON
            ,ALLOW_PAGE_LOCKS  = ON
            ) ON [PRIMARY]
-- END   UK01
-- BEGIN UK02
CREATE UNIQUE NONCLUSTERED INDEX UK02_'+@OUTPUT_ENTITY+' 
    ON '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
      (M_DAT_END ASC
      ,M_COD_KEY ASC
      )WITH (PAD_INDEX  = OFF
            ,STATISTICS_NORECOMPUTE  = OFF
            ,SORT_IN_TEMPDB = OFF
            ,IGNORE_DUP_KEY = OFF
            ,DROP_EXISTING = OFF
            ,ONLINE = OFF
            ,ALLOW_ROW_LOCKS  = ON
            ,ALLOW_PAGE_LOCKS  = ON
            ) ON [PRIMARY]
-- END   UK02
-- BEGIN CN03
ALTER TABLE '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
  ADD CONSTRAINT CN03_'+@OUTPUT_ENTITY+' DEFAULT (GETUTCDATE()) FOR M_UTC_RECORD_INSERTED
-- END   CN03
-- BEGIN IX04
CREATE NONCLUSTERED INDEX IX04_'+@OUTPUT_ENTITY+' 
    ON '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
    (M_DAT_START ASC) WITH (PAD_INDEX  = OFF
                           ,STATISTICS_NORECOMPUTE  = OFF
                           ,SORT_IN_TEMPDB = OFF
                           ,IGNORE_DUP_KEY = OFF
                           ,DROP_EXISTING = OFF
                           ,ONLINE = OFF
                           ,ALLOW_ROW_LOCKS  = ON
                           ,ALLOW_PAGE_LOCKS  = ON
                           ) ON [PRIMARY]
-- END   IX04
-- BEGIN IX05
CREATE NONCLUSTERED INDEX IX05_'+@OUTPUT_ENTITY+' 
    ON '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
    (M_DAT_END ASC) WITH (PAD_INDEX  = OFF
                         ,STATISTICS_NORECOMPUTE  = OFF
                         ,SORT_IN_TEMPDB = OFF
                         ,IGNORE_DUP_KEY = OFF
                         ,DROP_EXISTING = OFF
                         ,ONLINE = OFF
                         ,ALLOW_ROW_LOCKS  = ON
                         ,ALLOW_PAGE_LOCKS  = ON
                         ) ON [PRIMARY]
-- END   IX05
-- BEGIN IX06
CREATE NONCLUSTERED INDEX IX06_'+@OUTPUT_ENTITY+' 
    ON '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
    (M_COD_KEY ASC) WITH (PAD_INDEX  = OFF
                         ,STATISTICS_NORECOMPUTE  = OFF
                         ,SORT_IN_TEMPDB = OFF
                         ,IGNORE_DUP_KEY = OFF
                         ,DROP_EXISTING = OFF
                         ,ONLINE = OFF
                         ,ALLOW_ROW_LOCKS  = ON
                         ,ALLOW_PAGE_LOCKS  = ON
                         ) ON [PRIMARY]
-- END   IX06
-- BEGIN IX07
CREATE NONCLUSTERED INDEX IX07_'+@OUTPUT_ENTITY+' 
    ON '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' 
    (M_COD_SOR ASC) WITH (PAD_INDEX  = OFF
                         ,STATISTICS_NORECOMPUTE  = OFF
                         ,SORT_IN_TEMPDB = OFF
                         ,IGNORE_DUP_KEY = OFF
                         ,DROP_EXISTING = OFF
                         ,ONLINE = OFF
                         ,ALLOW_ROW_LOCKS  = ON
                         ,ALLOW_PAGE_LOCKS  = ON
                         ) ON [PRIMARY]
-- END   IX07
' -- END DYNAMIC SQL
		
IF OBJECT_ID(@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY,'U') IS NULL 
  BEGIN
     EXECUTE SP_EXECUTESQL @SQL1
  END
ELSE PRINT '-- TABLE ALREADY EXISTS, NOT RECREATED (first manual delete) --'

SET @SQL1 = 
N'
-- BEGIN TRU
CREATE TRIGGER '+@OUTPUT_SUBJECT+'.TRU_'+@OUTPUT_ENTITY+' 
    ON '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+'
   FOR UPDATE AS
 BEGIN
   UPDATE T
      SET M_UTC_RECORD_UPDATED = GETUTCDATE()
     FROM '+@OUTPUT_SUBJECT+'.'+@OUTPUT_ENTITY+' T
     INNER JOIN INSERTED I
       ON T.M_IDR = I.M_IDR   
 END
-- END TRU
 '
-- BEGIN CREATE TRIGGER
BEGIN
  EXECUTE SP_EXECUTESQL @SQL1
END
-- END CREATE TRIGGER
----------------------------------------------------------------------------------
-- END create DYNAMIC SAT Table
----------------------------------------------------------------------------------
END -- PROCEDURE

GO


GO
/****** Object:  StoredProcedure [MDAPEL].[GF_1001_GENERIC_PRE_PROCESS]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_1001_GENERIC_PRE_PROCESS]
 @M_COD_PROCESS        BIGINT
,@M_COD_INSTANCE       BIGINT         OUTPUT
,@M_COD_PROCESS_STATUS NVARCHAR(22)   OUTPUT
----------------------------------------------------------------------------------
-- Author         : Michael Doves
-- Author Contact : michael.doves@dikw.com
-- Version        : 1
-- Creation Date  : 2012-06-08
-- Version Date   : 2012-06-08
-- Description    : Generic Pre handling of an instance of a process.
-- Modification   : 2012-06-08 Version 1: Initial Code
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
----------------------------------------------------------------------------------
-- Example call: 'EXECUTE MDAPEL.GF_1001_GENERIC_PRE_PROCESS @M_COD_PROCESS,@M_COD_INSTANCE OUTPUT'
AS

-- BEGIN BEGIN TRY
BEGIN TRY
-- END BEGIN TRY
  
-- BEGIN STEP 1 DECLARE UTCDATE()
DECLARE @M_UTC DATETIME2(7) = (SELECT GETUTCDATE());
-- END STEP 1 DECLARE UTCDATE()

-- BEGIN: STEP 2 Create INSTANCE 
INSERT INTO MDAPEL.INSTANCE
(COD_PROCESS
,COD_INSTANCE_STATUS
,UTC_INSTANCE_START
)
VALUES                              
(@M_COD_PROCESS
,'STARTED'
,@M_UTC
)

SET @M_COD_INSTANCE = (SELECT COD_INSTANCE
	                     FROM MDAPEL.INSTANCE
					    WHERE 1=1
						  AND COD_PROCESS         = @M_COD_PROCESS 
						  AND UTC_INSTANCE_START  = @M_UTC
					   )					   	
-- END: STEP 2 Create INSTANCE

-- BEGIN: STEP 3 DETERMINE IF PROCESS IS ACTIVATED
DECLARE @M_IND_ACTIVATED NCHAR(1) 
    SET @M_IND_ACTIVATED = (SELECT IND_ACTIVATED
                              FROM MDAPEL.PROCESS
                             WHERE COD_PROCESS = @M_COD_PROCESS
                           )
IF   @M_IND_ACTIVATED = 'Y'
BEGIN
  SET @M_COD_PROCESS_STATUS = 'ACTIVATED'
END

IF   @M_IND_ACTIVATED = 'N'
BEGIN
  SET @M_COD_PROCESS_STATUS = 'DEACTIVATED'
  
  -- BEGIN: INSERT LOG
    EXECUTE MDAPEL.GF_1000_INSERT_LOG
     @M_COD_PROCESS
    ,@M_COD_INSTANCE
    ,'INFORMATION'
    ,'STATUS = DEACTIVATED'
    -- END: INSERT LOG 
END
--   END: STEP 3 DETERMINE IF PROCESS IS ACTIVATED

-- BEGIN: STEP 3 DETERMINE IF NO INSTANCE OF PROCESS IS ALREADY RUNNING
-- IF NOT THAN LOCK THE PROCESS
IF @M_COD_PROCESS_STATUS = 'ACTIVATED'
BEGIN
  DECLARE @M_IND_INSTANCE_RUNNING NCHAR(1) 
      SET @M_IND_INSTANCE_RUNNING = (SELECT IND_INSTANCE_RUNNING
                                       FROM MDAPEL.PROCESS
                                      WHERE COD_PROCESS = @M_COD_PROCESS
                                    )
                                  
  IF @M_IND_INSTANCE_RUNNING = 'N'
  BEGIN
    UPDATE MDAPEL.PROCESS
       SET IND_INSTANCE_RUNNING = 'Y'
     WHERE COD_PROCESS = @M_COD_PROCESS
      
    SET  @M_COD_PROCESS_STATUS = 'ACTIVATED AND UNLOCKED'
    
    -- BEGIN: INSERT LOG
    EXECUTE MDAPEL.GF_1000_INSERT_LOG
     @M_COD_PROCESS
    ,@M_COD_INSTANCE
    ,'INFORMATION'
    ,'STATUS = ACTIVATED AND UNLOCKED'
    -- END: INSERT LOG 
  END       
  
  IF @M_IND_INSTANCE_RUNNING = 'Y'
  BEGIN
    SET  @M_COD_PROCESS_STATUS = 'ACTIVATED BUT LOCKED'
    
     -- BEGIN: INSERT LOG
    EXECUTE MDAPEL.GF_1000_INSERT_LOG
     @M_COD_PROCESS
    ,@M_COD_INSTANCE
    ,'INFORMATION'
    ,'COD_PROCESS_STATUS = ACTIVATED BUT LOCKED'
    -- END: INSERT LOG 
  END            
END            
--   END: STEP 3 DETERMINE IF NO INSTANCE OF PROCESS IS ALREADY RUNNING

-- BEGIN END TRY
END TRY
--   END END TRY

-- BEGIN BEGIN CATCH
BEGIN CATCH
--   END BEGIN CATCH
 DECLARE @ERROR_MESSAGE NVARCHAR(4000) = (SELECT ERROR_MESSAGE())
 -- BEGIN: INSERT LOG
    EXECUTE MDAPEL.GF_1000_INSERT_LOG
     @M_COD_PROCESS
    ,@M_COD_INSTANCE
    ,'ERROR'
    ,@ERROR_MESSAGE
 -- END: INSERT LOG 
-- BEGIN END CATCH
END CATCH
--   END END CATCH

GO
/****** Object:  StoredProcedure [MDAPEL].[GF_1002_GENERIC_POST_PROCESS]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[GF_1002_GENERIC_POST_PROCESS]
 @M_COD_PROCESS    BIGINT
,@M_COD_INSTANCE   BIGINT 
,@M_PROCESS_STATUS NVARCHAR(22)
----------------------------------------------------------------------------------
-- Author         : Michael Doves
-- Author Contact : michael.doves@dikw.com
-- Version        : 1
-- Creation Date  : 2012-06-08
-- Version Date   : 2012-06-08
-- Description    : Generic Post Handling of an instance of a process.
-- Modification   : 2012-06-08 Version 1: Initial Code
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
----------------------------------------------------------------------------------
-- Example call: 'EXECUTE MDAPEL.GF_101_GENERIC_PRE_PROCESS @M_COD_PROCESS,@M_COD_INSTANCE'
AS
-- BEGIN: BEGIN TRY
BEGIN TRY
--   ENDL BEGIN TRY

-- BEGIN DECLARE UTCDATE()
DECLARE @M_UTC DATETIME2(7) = (SELECT GETUTCDATE())
--   END DECLARE UTCDATE()

-- BEGIN: 'ACTIVATED AND UNLOCKED'
IF @M_PROCESS_STATUS = 'ACTIVATED AND UNLOCKED'
BEGIN

  -- BEGIN: STOP INSTANCE NORMALLY 
  UPDATE MDAPEL.INSTANCE
     SET UTC_INSTANCE_END      = @M_UTC
        ,COD_INSTANCE_STATUS   = 'FINNISHED'
        ,TIM_DURATION_INSTANCE = DATEDIFF(SS,UTC_INSTANCE_START,@M_UTC)
   WHERE COD_INSTANCE = @M_COD_INSTANCE				
  --   END: STOP INSTANCE NORMALLY
  
  -- BEGIN: UNLOCK PROCESS
  UPDATE MDAPEL.PROCESS
     SET IND_INSTANCE_RUNNING = 'N'
   WHERE COD_PROCESS = @M_COD_PROCESS	
  -- END UNLOCK PROCESS
  
  -- BEGIN: INSERT LOG
  EXECUTE MDAPEL.GF_1000_INSERT_LOG
   @M_COD_PROCESS
  ,@M_COD_INSTANCE
  ,'INFORMATION'
  ,'The instance has finnished corectly.'
  --   END: INSERT LOG
END 
--   END: 'ACTIVATED AND UNLOCKED'

-- BEGIN: 'DEACTIVATED'
IF @M_PROCESS_STATUS = 'DEACTIVATED'
BEGIN

  -- BEGIN: STOP INSTANCE NORMALLY 
  UPDATE MDAPEL.INSTANCE
     SET UTC_INSTANCE_END      = @M_UTC
        ,COD_INSTANCE_STATUS   = 'DEACTIVATED'
        ,TIM_DURATION_INSTANCE = DATEDIFF(SS,UTC_INSTANCE_START,@M_UTC)
   WHERE COD_INSTANCE = @M_COD_INSTANCE				
  --   END: STOP INSTANCE NORMALLY
  
  -- BEGIN: INSERT LOG
  EXECUTE MDAPEL.GF_1000_INSERT_LOG
   @M_COD_PROCESS
  ,@M_COD_INSTANCE
  ,'INFORMATION'
  ,'The process is deactivated.'
  --   END: INSERT LOG
END 
--   END: 'DEACTIVATED'

-- BEGIN: 'DEACTIVATED'
IF @M_PROCESS_STATUS = 'ACTIVATED BUT LOCKED'
BEGIN

  -- BEGIN: STOP INSTANCE NORMALLY 
  UPDATE MDAPEL.INSTANCE
     SET UTC_INSTANCE_END      = @M_UTC
        ,COD_INSTANCE_STATUS   = 'ACTIVATED BUT LOCKED'
        ,TIM_DURATION_INSTANCE = DATEDIFF(SS,UTC_INSTANCE_START,@M_UTC)
   WHERE COD_INSTANCE = @M_COD_INSTANCE				
  --   END: STOP INSTANCE NORMALLY
  
  -- BEGIN: INSERT LOG
  EXECUTE MDAPEL.GF_1000_INSERT_LOG
   @M_COD_PROCESS
  ,@M_COD_INSTANCE
  ,'INFORMATION'
  ,'The process is activated but locked.'
  --   END: INSERT LOG
END 
--   END: 'DEACTIVATED'

-- BEGIN: END TRY
END TRY
--   END: END TRY


-- BEGIN: END CATCH
BEGIN CATCH
  SELECT ERROR_MESSAGE()
  RETURN
END CATCH 
 -- END: END CATCH

GO



GO
/****** Object:  StoredProcedure [MDAPEL].[PROCESS_XXXXXXXX_TEMPLATE_V01]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [MDAPEL].[PROCESS_XXXXXXXX_TEMPLATE_V01]
-- =========================================================================================
-- Author(s)          : [Name]
-- Date Created       : [YYYY-MM-DD]
-- Version            : [Integer]
-- Date Last Modified : [YYYY-MM-DD]        
-- Description        :	
-- Parameters         :	
-- Modifications      : 
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
-- ========================================================================================
AS
--------------------------------------------------------------------------------------
-- BEGIN STEP 0: INITIALIZE AND DECLARE
--------------------------------------------------------------------------------------
-- BEGIN GENERIC INITIALIZE AND DECLARE
DECLARE @M_COD_PROCESS        BIGINT = 11111111 -- Fill in your process number
DECLARE @M_COD_INSTANCE       BIGINT
DECLARE @M_COD_PROCESS_STATUS NVARCHAR(22)
-- END   GENERIC INITIALIZE AND DECLARE
--------------------------------------------------------------------------------------
-- END  STEP 0: INITIALIZE DECLARATIONS
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
-- BEGIN STEP 1: GENERIC PRE PROCESS
--------------------------------------------------------------------------------------
EXECUTE MDAPEL.GF_100_GENERIC_PRE_PROCESS
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE       OUTPUT
/* PAR 3 */ ,@M_COD_PROCESS_STATUS OUTPUT
--------------------------------------------------------------------------------------
--   END STEP 1: GENERIC PRE PROCESS
--------------------------------------------------------------------------------------

-- BEGIN BEGIN TRY
BEGIN TRY
IF @M_COD_PROCESS_STATUS = 'ACTIVATED AND UNLOCKED'
BEGIN --  'ACTIVATED AND UNLOCKED'
--  END  BEGIN TRY

--------------------------------------------------------------------------------------
-- BEGIN STEP 2: SPECIFIC PRE PROCESS
--------------------------------------------------------------------------------------
-- BEGIN INSERT LOG
EXECUTE MDAPEL.GF_102_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Specific Pre Process has started.'
-- END INSERT LOG
--------------------------------------------------------------------------------------
-- END   STEP 2: SPECIFIC PRE PROCESS
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
-- BEGIN STEP 3: MAIN PROCESS
--------------------------------------------------------------------------------------
-- BEGIN: INSERT LOG
EXECUTE MDAPEL.GF_102_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 3 */ ,'Main Process has started.'
--   END: INSERT LOG



--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- BEGIN SPECIFIC CODE TO WRITE
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

-- Write your specific code here ....

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- END SPECIFIC CODE TO WRITE
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------
-- END   STEP 3: MAIN PROCESS
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
-- BEGIN STEP 4: SPECIFIC POST PROCESS
--------------------------------------------------------------------------------------
EXECUTE MDAPEL.GF_102_INSERT_LOG 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,'INFORMATION'
/* PAR 4 */ ,'Specific Post Process has started.'
--------------------------------------------------------------------------------------
--   END STEP 4: SPECIFIC POST PROCESS
--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
-- BEGIN STEP 5: GENERIC POST PROCESS
--------------------------------------------------------------------------------------
END -- 'ACTIVATED AND UNLOCKED'

-- BEGIN: STEP 5A CALL GENERIC POST PROCESS
EXECUTE MDAPEL.GF_101_GENERIC_POST_PROCESS 
/* PAR 1 */  @M_COD_PROCESS
/* PAR 2 */ ,@M_COD_INSTANCE
/* PAR 3 */ ,@M_COD_PROCESS_STATUS
-- END: STEP 5A CALL GENERIC POST PROCESS

-- BEGIN END TRY
END TRY
--   END END TRY

-- BEGIN: STEP 5Z ERROR HANDLING
BEGIN CATCH
  DECLARE @M_ERROR_MESSAGE NVARCHAR(4000) = (SELECT ERROR_MESSAGE())
  EXECUTE MDAPEL.GF_999_GENERIC_ERROR_HANDLING 
  /* PAR 1 */  @M_COD_PROCESS
  /* PAR 2 */ ,@M_COD_INSTANCE
  /* PAR 3 */ ,@M_ERROR_MESSAGE
END CATCH 
-- END:  STEP 5Z ERROR HANDLING
--------------------------------------------------------------------------------------
--   END STEP 5: GENERIC POST PROCESS
--------------------------------------------------------------------------------------

GO

GO
/****** Object:  UserDefinedFunction [MDAPEL].[GF_801_IS_INTEGER]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE ASTRAGY_TEMPLATE_V01
CREATE FUNCTION [MDAPEL].[GF_801_IS_INTEGER](@Value nvarchar(20))

-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.

Returns BIT
AS 
Begin
-- The maximum value for an Bigint in SQL Server is:
-- -9223372036854775808 through 9223372036854775807
-- Maximaal 19 digits en - teken = 20 digits  
  Return IsNull(
     (Select Case When CharIndex('.', @Value) > 0 
                  Then Case When Convert(bigint, ParseName(@Value, 1)) <> 0
                            Then 0
                            Else 1
                            End
                  Else 1
                  End
      Where IsNumeric(@Value + 'e0') = 1), 0)

End

GO
/****** Object:  UserDefinedFunction [MDAPEL].[GF_802_FORMAT_URL]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE ASTRAGY_TEMPLATE_V01
CREATE FUNCTION [MDAPEL].[GF_802_FORMAT_URL](@Value nvarchar(200))

-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.

RETURNS nvarchar(200)
AS
BEGIN -- GF_FORMAT_URL
RETURN
(SELECT 
 CASE
  when ltrim(rtrim(@Value)) = '' then '_^_'
   when ltrim(rtrim(@Value)) is null then '_^_'
  when not 
     (    CHARINDEX(' ',LTRIM(RTRIM(@Value))) = 0                                   -- No embedded spaces
      AND RIGHT(LTRIM(RTRIM(@Value)),1)   <> '.'                                    -- '.' can't be the last character of an url
      AND CHARINDEX('.',REVERSE(LTRIM(RTRIM(@Value)))) >= 3                         -- Domain name should end with at least 2 character extension
      AND (    CHARINDEX('.@',LTRIM(RTRIM(@Value))) = 0 
           AND CHARINDEX('..',LTRIM(RTRIM(@Value))) = 0
          )                                                                         -- can't have patterns like '.@' and '..'
      AND CHARINDEX(';',LTRIM(RTRIM(@Value))) = 0 -- No semicolon
      AND CHARINDEX('(',LTRIM(RTRIM(@Value))) = 0 -- No (
      AND CHARINDEX(')',LTRIM(RTRIM(@Value))) = 0 -- No ) 
      AND CHARINDEX('*',LTRIM(RTRIM(@Value))) = 0 -- No * 
      AND CHARINDEX('#',LTRIM(RTRIM(@Value))) = 0 -- No #
      AND CHARINDEX('$',LTRIM(RTRIM(@Value))) = 0 -- No $
      AND CHARINDEX('%',LTRIM(RTRIM(@Value))) = 0 -- No %
      AND CHARINDEX('^',LTRIM(RTRIM(@Value))) = 0 -- No ^
      AND CHARINDEX('"',LTRIM(RTRIM(@Value))) = 0 -- No "
      AND CHARINDEX('~',LTRIM(RTRIM(@Value))) = 0 -- No ~
      AND CHARINDEX('+',LTRIM(RTRIM(@Value))) = 0 -- No +  
      AND CHARINDEX('{',LTRIM(RTRIM(@Value))) = 0 -- No {
      AND CHARINDEX('}',LTRIM(RTRIM(@Value))) = 0 -- No }
      AND CHARINDEX('[',LTRIM(RTRIM(@Value))) = 0 -- No [
      AND CHARINDEX(']',LTRIM(RTRIM(@Value))) = 0 -- No ]
      AND CHARINDEX('|',LTRIM(RTRIM(@Value))) = 0 -- No |
	  AND CHARINDEX('>',LTRIM(RTRIM(@Value))) = 0 -- No >
      AND CHARINDEX('<',LTRIM(RTRIM(@Value))) = 0 -- No <
      AND CHARINDEX('''',LTRIM(RTRIM(@Value))) = 0 -- No '
	) 
   then '_~_'
   when CHARINDEX('WWW.',upper(ltrim(rtrim(@VALUE))),1) = 0
   then 'www.'+lower(ltrim(rtrim(@VALUE)))
   when CHARINDEX('WWW.',upper(ltrim(rtrim(@VALUE))),1) >= 1
   then lower(ltrim(rtrim(@VALUE)))
   else '_!_'
 END 
)

END -- PROCEDURE GF_FORMAT_URL

GO
/****** Object:  UserDefinedFunction [MDAPEL].[GF_803_FORMAT_TELEFOONNUMMER]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE ASTRAGY_TEMPLATE_V01
CREATE FUNCTION [MDAPEL].[GF_803_FORMAT_TELEFOONNUMMER](@Value nvarchar(20))

-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.

RETURNS nvarchar(20)
AS
BEGIN -- GF_FORMAT_TELEFOONNUMMER
RETURN
(SELECT 

 CASE
   when ltrim(rtrim(@Value)) is null then '_^_'
   when ltrim(rtrim(@Value)) = '' then '_^_'
   -- BEGIN Buitenlandse nummers 1
   when substring(ltrim(rtrim(@Value)),1,2) = '00' 
    and MDAPEL.GF_801_IS_INTEGER(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,15)) = 1
   then '+'+substring(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),3,15)
   -- EINDE Buitenlandse nummers 1

   -- BEGIN Buitenlandse nummers 2
   when substring(replace(ltrim(rtrim(@Value)), '.',''),1,1) = '+' 
    and MDAPEL.GF_801_IS_INTEGER(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,15)) = 1
   then substring(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),1,15)
   -- EINDE Buitenlandse nummers 2

   -- BEGIN Waarde kan geen telefoonnumer zijn 1
   when MDAPEL.GF_801_IS_INTEGER(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')','')) = 0
   then '_~1_'
   -- EINDE Waarde kan geen telefoonnumer zijn 1

   -- BEGIN Geldig buitenlands nummer 3
   when MDAPEL.GF_801_IS_INTEGER(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,15)) = 1
    and len(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,15)) > 10
    and substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,1) <> '0'
   then '+'+substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,15)
   -- EINDE Geldig buitenlands nummer 3

   -- BEGIN Geen geldig nummer 5
   when MDAPEL.GF_801_IS_INTEGER(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,15)) = 1
    and len(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,15)) > 10
    and substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,1) = '0'
   then '_~5_'
   -- EINDE Geen geldig nummer 5

   -- BEGIN Geldig nederlands nummer 1
   when MDAPEL.GF_801_IS_INTEGER(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,15)) = 1
    and len(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,15)) = 10
    and substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,1) = '0'
   then '+31'+substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),2,10)
   -- EINDE Geldig nederlands nummer 1

   -- BEGIN Geen gedlig nummer 4
   when MDAPEL.GF_801_IS_INTEGER(substring(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),1,15)) = 1
    and len(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,10)) = 10
    and substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,1) <> '0'
   then '_~4_'
   -- EINDE Geen gedlig nummer 4

   -- BEGIN Geldig nederlands nummer 2
   when MDAPEL.GF_801_IS_INTEGER(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,15)) = 1
    and len(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,10)) = 9
    and substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,1) <> '0'
   then '+31'+substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,1)
   -- EINDE Geldig nederlands nummer 2

   -- BEGIN Waarde kan geen telefoonnumer zijn 2
   when MDAPEL.GF_801_IS_INTEGER(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,15)) = 1
    and len(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,10)) = 9
    and substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,1) = '0'
   then '_~2_'
   -- EINDE Waarde kan geen telefoonnumer zijn 2

   -- BEGIN Waarde kan geen telefoonnumer zijn 3
   when MDAPEL.GF_801_IS_INTEGER(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,15)) = 1
    and len(substring(replace(replace(replace(replace(replace(ltrim(rtrim(@Value)), '.',''),' ',''),'-',''),'(',''),')',''),1,10)) < 9
   then '_~3_'
   -- EINDE Waarde kan geen telefoonnumer zijn 3
   else '_!_'
 END 
)

END -- PROCEDURE GF_FORMAT_TELEFOONNUMMER

GO
/****** Object:  UserDefinedFunction [MDAPEL].[GF_805_DETERMINE_EASTER_SUNDAY_PER_YEAR]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [MDAPEL].[GF_805_DETERMINE_EASTER_SUNDAY_PER_YEAR] 
-- Deze functie bepaald de eerste paasdag per jaar.
-- Veel christelijke vakantiedagen zijn gebaseerd op een constante + eerste paasdag.
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
(@Year char(4)) 
RETURNS DATE 
AS 
BEGIN 
--http://aa.usno.navy.mil/faq/docs/easter.php 
declare 
@c int 
, @n int 
, @k int 
, @i int 
, @j int 
, @l int 
, @m int 
, @d int 
, @Easter datetime 

set @c = (@Year / 100) 
set @n = @Year - 19 * (@Year / 19) 
set @k = (@c - 17) / 25 
set @i = @c - @c / 4 - ( @c - @k) / 3 + 19 * @n + 15 
set @i = @i - 30 * ( @i / 30 ) 
set @i = @i - (@i / 28) * (1 - (@i / 28) * (29 / (@i + 1)) * ((21 - @n) / 11)) 
set @j = @Year + @Year / 4 + @i + 2 - @c + @c / 4 
set @j = @j - 7 * (@j / 7) 
set @l = @i - @j 
set @m = 3 + (@l + 40) / 44 
set @d = @l + 28 - 31 * ( @m / 4 ) 

set @Easter = (select right('0' + convert(varchar(2),@m),2) + '/' + right('0' + convert(varchar(2),@d),2) + '/' + convert(char(4),@Year)) 

return @Easter 
END

GO
/****** Object:  UserDefinedFunction [MDAPEL].[GF_806_FORMAT_TEXT_TO_NUMBER]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [MDAPEL].[GF_806_FORMAT_TEXT_TO_NUMBER]
(@VALUE_RAW NVARCHAR(50)) 
 RETURNS NVARCHAR(50)
AS 
BEGIN -- FUNCTION BODY
  DECLARE @VALUE NVARCHAR(50) = REPLACE(REPLACE(LTRIM(RTRIM(@VALUE_RAW)),',','.'),' ','')
  IF PATINDEX('%[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz]%',@VALUE) <> 0  
    BEGIN 
      RETURN '_~_1'
    END
  IF PATINDEX('%[!@#$%^&*():;"[]{}-+=_<>?/]%',@VALUE) <> 0  
     BEGIN
       RETURN '_~_2'
     END
  IF PATINDEX('%[0123456789]%',@VALUE) <> 0 
    AND ISNUMERIC(@VALUE) = 1                                                        
     BEGIN
       RETURN CONVERT(NVARCHAR(50),CONVERT(NUMERIC(36,20),@VALUE))
     END 
  RETURN '_!_'     
END -- FUNCTION BODY

GO
/****** Object:  UserDefinedFunction [MDAPEL].[GF_807_GET_NAME_INITIALS_FROM_FIRSTNAMES]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [MDAPEL].[GF_807_GET_NAME_INITIALS_FROM_FIRSTNAMES]
   (@INPUT_TEXT_RAW NVARCHAR(200))
   RETURNS NVARCHAR(100)
AS
-------------------------------------------------------------------------------------
-- Author             : Michael Doves
-- Author Phone       : +31611044715
-- Author Email       : michael.doves@dikw.com
-- Purpose            : Extracting Initials from first name strings
-- Description        : Some characters will be filtered first.
-- Date Created       : 2012-04-10
-- Date Last Modified : 2012-04-10
-- Version            : 1
-- Modification(s)    : Version 1: Initial Code
-- Copyrights	      : Copyright © DIKW Consulting B.V. 2013 All Rights Reserved. 
-- 			No part of this code may be reproduced without DIKW Consulting B.V.express consent.
---------------------------------------------------------------------------------------
BEGIN
  DECLARE @INPUT_TEXT NVARCHAR(200)
      SET @INPUT_TEXT = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(@INPUT_TEXT_RAW))
                        ,'(',''),'.',''),'-',' '),')',''),'!',''),'1',''),'2',''),'3',''),'4',''),'5',''),'6',''),'7',''),'8',''),'9',''),'0',''),'   ',' '),'   ',' '),'  ',' ')
  DECLARE @I NVARCHAR(100) = UPPER(LEFT(@INPUT_TEXT,1)+'.');
  DECLARE @P INTEGER = CHARINDEX(' ',@INPUT_TEXT);
  WHILE (@P > 0)
    BEGIN
       SET @I = UPPER(@I + SUBSTRING(@INPUT_TEXT,@P+1,1)+'.')
       SET @P = CHARINDEX(' ',@INPUT_TEXT,@P+1)
    END
  RETURN @I
END

GO

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
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
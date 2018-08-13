/****** Object:  Table [MDAPEL].[DOMAIN_TRANSLATION_VALUE]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MDAPEL].[DOMAIN_TRANSLATION_VALUE](
	[COD_DOMAIN_TRANSLATION] [bigint] NOT NULL,
	[COD_DOMAIN_VALUE_FROM_01] [nvarchar](50) NOT NULL,
	[COD_DOMAIN_VALUE_FROM_02] [nvarchar](50) NOT NULL,
	[COD_DOMAIN_VALUE_FROM_03] [nvarchar](50) NOT NULL,
	[COD_DOMAIN_VALUE_FROM_04] [nvarchar](50) NOT NULL,
	[COD_DOMAIN_VALUE_FROM_05] [nvarchar](50) NOT NULL,
	[COD_DOMAIN_VALUE_TOO] [nvarchar](50) NOT NULL,
	[DAT_START] [date] NOT NULL,
	[DAT_END] [date] NOT NULL,
 CONSTRAINT [PK00_DOMAIN_TRANSLATION_VALUE] PRIMARY KEY CLUSTERED 
(
	[COD_DOMAIN_TRANSLATION] ASC,
	[COD_DOMAIN_VALUE_FROM_01] ASC,
	[COD_DOMAIN_VALUE_FROM_02] ASC,
	[COD_DOMAIN_VALUE_FROM_03] ASC,
	[COD_DOMAIN_VALUE_FROM_04] ASC,
	[COD_DOMAIN_VALUE_FROM_05] ASC,
	[COD_DOMAIN_VALUE_TOO] ASC,
	[DAT_START] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

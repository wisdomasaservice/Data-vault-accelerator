/****** Object:  Table [MDAPEL].[FUNCTION_PROCESS]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MDAPEL].[FUNCTION_PROCESS](
	[COD_FUNCTION] [bigint] NOT NULL,
	[COD_PROCESS] [bigint] NOT NULL,
 CONSTRAINT [PK00_FUNCTION_PROCESS] PRIMARY KEY CLUSTERED 
(
	[COD_FUNCTION] ASC,
	[COD_PROCESS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
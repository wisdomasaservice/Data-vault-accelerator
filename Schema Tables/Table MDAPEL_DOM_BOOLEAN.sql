/****** Object:  Table [MDAPEL].[DOM_BOOLEAN]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MDAPEL].[DOM_BOOLEAN](
	[IND_YES_NO] [nchar](1) NOT NULL,
	[DES_IND] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK00_DOM_BOOLEAN] PRIMARY KEY CLUSTERED 
(
	[IND_YES_NO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
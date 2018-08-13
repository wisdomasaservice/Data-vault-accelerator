/****** Object:  Table [MDAPEL].[DOM_ATTRIBUTE_TYPE]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MDAPEL].[DOM_ATTRIBUTE_TYPE](
	[COD_ATTRIBUTE_TYPE] [nvarchar](50) NOT NULL,
	[DES_ATTRIBUTE_TYPE] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK00_DOM_ATTRIBUTE_TYPE] PRIMARY KEY CLUSTERED 
(
	[COD_ATTRIBUTE_TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
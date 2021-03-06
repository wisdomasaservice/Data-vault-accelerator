/****** Object:  Table [MDAPEL].[DOM_DTI_CONTAINER_TYPE]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MDAPEL].[DOM_DTI_CONTAINER_TYPE](
	[COD_DTI_CONTAINER_TYPE] [bigint] NOT NULL,
	[DES_DTI_CONTAINER_TYPE] [nvarchar](400) NOT NULL,
 CONSTRAINT [PK00_DOM_CONTAINER_TYPE] PRIMARY KEY CLUSTERED 
(
	[COD_DTI_CONTAINER_TYPE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

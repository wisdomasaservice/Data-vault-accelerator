/****** Object:  Table [MDAPEL].[DOM_HUB_IDC]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MDAPEL].[DOM_HUB_IDC](
	[IDC] [bigint] IDENTITY(-4,1) NOT NULL,
	[M_COD_SOR] [bigint] NOT NULL,
	[IDI] [nvarchar](100) NOT NULL,
	[COD_HUB_ENTITY] [nvarchar](100) NOT NULL,
	[M_COD_PROCESS] [bigint] NOT NULL,
	[M_UTC_RECORD_INSERTED] [datetime2](7) NOT NULL,
	[M_UTC_RECORD_UPDATED] [datetime2](7) NULL,
 CONSTRAINT [PK00_DOM_HUB_IDC] PRIMARY KEY CLUSTERED 
(
	[IDC] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
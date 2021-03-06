/****** Object:  Table [MDAPEL].[INSTANCE]    Script Date: 2/19/2013 12:38:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [MDAPEL].[INSTANCE](
	[COD_INSTANCE] [bigint] IDENTITY(1,1) NOT NULL,
	[COD_PROCESS] [bigint] NOT NULL,
	[COD_INSTANCE_STATUS] [nvarchar](22) NOT NULL,
	[UTC_INSTANCE_START] [datetime2](7) NOT NULL,
	[UTC_INSTANCE_END] [datetime2](7) NULL,
	[TIM_DURATION_INSTANCE] [bigint] NULL,
 CONSTRAINT [PK00_INSTANCE] PRIMARY KEY CLUSTERED 
(
	[COD_INSTANCE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
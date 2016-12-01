USE [SharePoint2016Reporting]
GO

/****** Object:  Table [dbo].[tblColumns]    Script Date: 11/30/2016 6:56:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblColumns](
	[ID] [nvarchar](36) NOT NULL,
	[InProd] [bit] NULL,
	[GroupName] [nvarchar](max) NULL,
	[DisplayName] [nvarchar](max) NULL,
	[InternalName] [nvarchar](max) NULL,
	[Type] [nvarchar](max) NULL,
	[Multi] [nvarchar](max) NULL,
	[ManagedBy] [nvarchar](max) NULL,
	[DefaultValue] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[Date] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
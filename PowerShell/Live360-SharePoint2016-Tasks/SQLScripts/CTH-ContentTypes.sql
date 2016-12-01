USE [SharePoint2016Reporting]
GO

/****** Object:  Table [dbo].[tblContentTypes]    Script Date: 11/30/2016 6:56:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblContentTypes](
	[ID] [nvarchar](36) NOT NULL,
	[Source] [nvarchar](max) NULL,
	[InProd] [bit] NULL,
	[GroupName] [nvarchar](max) NULL,
	[Name] [nvarchar](max) NULL,
	[Parent] [nvarchar](max) NULL,
	[AssociatedRecordSeries] [nvarchar](max) NULL,
	[Date] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
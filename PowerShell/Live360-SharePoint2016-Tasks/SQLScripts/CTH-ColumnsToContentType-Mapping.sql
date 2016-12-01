USE [SharePoint2016Reporting]
GO

/****** Object:  Table [dbo].[tblColumnToContentType]    Script Date: 11/30/2016 6:56:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblColumnToContentType](
	[ID] [nvarchar](72) NOT NULL,
	[ColumnID] [nvarchar](36) NULL,
	[ContentTypeID] [nvarchar](36) NULL,
	[ContentTypeText] [nvarchar](max) NULL,
	[InProd] [bit] NULL,
	[Date] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
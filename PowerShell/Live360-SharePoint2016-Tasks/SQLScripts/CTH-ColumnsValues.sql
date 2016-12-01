USE [SharePoint2016Reporting]
GO

/****** Object:  Table [dbo].[tblColumnValues]    Script Date: 11/30/2016 6:56:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblColumnValues](
	[ID] [nvarchar](255) NOT NULL,
	[ColumnID] [nvarchar](36) NULL,
	[ColumnValue] [nvarchar](max) NULL,
	[InProd] [bit] NULL,
	[Date] [date] NULL,
	[Duplicates] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
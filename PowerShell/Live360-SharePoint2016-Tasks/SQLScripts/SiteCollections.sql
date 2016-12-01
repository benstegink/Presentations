-- Create a new table called 'SiteCollections' in schema 'SchemaName'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.SiteCollections', 'U') IS NOT NULL
DROP TABLE dbo.SiteCollections
GO
GO

/****** Object:  Table [dbo].[SiteCollections]    Script Date: 11/30/2016 7:45:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SiteCollections](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Date] [date] NULL,
	[SiteTitle] [nvarchar](max) NULL,
	[SiteUrl] [nvarchar](max) NULL,
	[SizeInMB] [float] NULL,
	[Documents] [int] NULL,
	[LastItemModified] [datetime] NULL,
	[SiteType] [nvarchar] (max) NULL,
	[Department] [nvarchar] (max) NULL,
	[SiteOwner] [nvarchar] (max) NULL,
	[SiteOwnerEmail] [nvarchar] (max) NULL
 CONSTRAINT [PK_SiteCollections] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UCUserSettings]    Script Date: 06/29/2011 10:28:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[UCUserSettings]') AND type in (N'U'))
DROP TABLE [UCUserSettings]
GO

DELETE FROM [umbracoAppTree]
      WHERE appAlias = 'courier';
GO
      
DELETE FROM [umbracoUser2app]
      WHERE app = 'courier';
GO

DELETE FROM [umbracoApp]
      WHERE appAlias = 'courier';
GO      
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[UCUserSettings]') AND type in (N'U'))
BEGIN
CREATE TABLE [UCUserSettings](
	[User] [nvarchar](50) NOT NULL,
	[Key] [nvarchar](250) NOT NULL,
	[Value] [nvarchar](2500) NULL,
 CONSTRAINT [PK_UCUserSettings] PRIMARY KEY CLUSTERED 
(
	[User] ASC,
	[Key] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
END

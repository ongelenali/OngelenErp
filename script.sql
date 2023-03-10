USE [WorkDB]
GO
/****** Object:  Schema [common]    Script Date: 6.08.2017 18:50:43 ******/
CREATE SCHEMA [common]
GO
/****** Object:  Schema [file]    Script Date: 6.08.2017 18:50:43 ******/
CREATE SCHEMA [file]
GO
/****** Object:  Schema [log]    Script Date: 6.08.2017 18:50:43 ******/
CREATE SCHEMA [log]
GO
/****** Object:  Schema [work]    Script Date: 6.08.2017 18:50:43 ******/
CREATE SCHEMA [work]
GO
/****** Object:  UserDefinedFunction [dbo].[InitCap]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[InitCap] ( @InputString NVARCHAR(4000) ) 
RETURNS NVARCHAR(4000)
AS
BEGIN

DECLARE @Index          INT
DECLARE @Char           CHAR(1)
DECLARE @PrevChar       CHAR(1)
DECLARE @OutputString   NVARCHAR(255)

SET @OutputString = LOWER(@InputString)
SET @Index = 1

WHILE @Index <= LEN(@InputString)
BEGIN
    SET @Char     = SUBSTRING(@InputString, @Index, 1)
    SET @PrevChar = CASE WHEN @Index = 1 THEN ' '
                         ELSE SUBSTRING(@InputString, @Index - 1, 1)
                    END

    IF @PrevChar IN (' ', ';', ':', '!', '?', ',', '.', '_', '-', '/', '&', '''', '(')
    BEGIN
        IF @PrevChar != '''' OR UPPER(@Char) != 'S'
            SET @OutputString = STUFF(@OutputString, @Index, 1, UPPER(@Char))
    END

    SET @Index = @Index + 1
END

RETURN @OutputString

END

GO
/****** Object:  UserDefinedFunction [dbo].[Initials]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Initials] ( @str NVARCHAR(4000) )
RETURNS NVARCHAR(2000)
AS
BEGIN
    DECLARE @retval NVARCHAR(2000);

    SET @str=RTRIM(LTRIM(@str));
    SET @retval=LEFT(@str,1);

    WHILE CHARINDEX(' ',@str,1)>0 BEGIN
        SET @str=LTRIM(RIGHT(@str,LEN(@str)-CHARINDEX(' ',@str,1)));
        SET @retval+=LEFT(@str,1);
    END

    RETURN @retval;
END

GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Split] (
      @InputString                  VARCHAR(Max),
      @Delimiter                    VARCHAR(50)
)

RETURNS @Items TABLE (
      Item                          VARCHAR(Max)
)

AS
BEGIN
      IF @Delimiter = ' '
      BEGIN
            SET @Delimiter = ','
            SET @InputString = REPLACE(@InputString, ' ', @Delimiter)
      END

      IF (@Delimiter IS NULL OR @Delimiter = '')
            SET @Delimiter = ','

--INSERT INTO @Items VALUES (@Delimiter) -- Diagnostic
--INSERT INTO @Items VALUES (@InputString) -- Diagnostic

      DECLARE @Item           VARCHAR(Max)
      DECLARE @ItemList       VARCHAR(Max)
      DECLARE @DelimIndex     INT

      SET @ItemList = @InputString
      SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
      WHILE (@DelimIndex != 0)
      BEGIN
            SET @Item = SUBSTRING(@ItemList, 0, @DelimIndex)
            INSERT INTO @Items VALUES (@Item)

            -- Set @ItemList = @ItemList minus one less item
            SET @ItemList = SUBSTRING(@ItemList, @DelimIndex+1, LEN(@ItemList)-@DelimIndex)
            SET @DelimIndex = CHARINDEX(@Delimiter, @ItemList, 0)
      END -- End WHILE

      IF @Item IS NOT NULL -- At least one delimiter was encountered in @InputString
      BEGIN
            SET @Item = @ItemList
            INSERT INTO @Items VALUES (@Item)
      END

      -- No delimiters were encountered in @InputString, so just return @InputString
      ELSE INSERT INTO @Items VALUES (@InputString)

      RETURN

END -- End Function

GO
/****** Object:  Table [common].[Lookup]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [common].[Lookup](
	[Id] [tinyint] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Lookup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [common].[LookupList]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [common].[LookupList](
	[Id] [smallint] NOT NULL,
	[ParentId] [smallint] NULL,
	[LookupId] [tinyint] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[LongName] [nvarchar](150) NULL,
	[IsActive] [bit] NOT NULL,
	[Color] [nvarchar](10) NULL,
	[Icon] [nvarchar](20) NULL,
	[Value] [nvarchar](300) NULL,
 CONSTRAINT [PK_LookupList] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [common].[Parameters]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [common].[Parameters](
	[Id] [tinyint] NOT NULL,
	[Code] [varchar](30) NOT NULL,
	[Name] [varchar](150) NOT NULL,
	[Value] [varchar](max) NOT NULL,
	[Description] [varchar](500) NOT NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_Parameters] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [common].[Person]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [common].[Person](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UnitId] [int] NOT NULL,
	[UserName] [nvarchar](50) NOT NULL,
	[Initials] [varchar](3) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Surname] [nvarchar](50) NOT NULL,
	[Password] [nvarchar](200) NOT NULL,
	[Email] [nvarchar](50) NOT NULL,
	[ImageId] [int] NULL,
	[IsActive] [bit] NOT NULL,
	[Phone] [decimal](11, 0) NULL,
 CONSTRAINT [PK_Person] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [common].[Unit]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [common].[Unit](
	[Id] [int] NOT NULL,
	[ParentId] [int] NULL,
	[UnitTypeId] [int] NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Code] [nvarchar](30) NULL,
	[IsActive] [bit] NOT NULL,
	[YbsUnitId] [int] NULL,
	[PdksUnitId] [int] NULL,
 CONSTRAINT [PK_Unit] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [file].[Media]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [file].[Media](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[MediaTypeId] [smallint] NOT NULL,
	[Value] [varbinary](max) NOT NULL,
	[FileName] [varchar](250) NOT NULL,
	[ContentType] [varchar](150) NOT NULL,
	[ContentLength] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_File] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [log].[ExceptionLog]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [log].[ExceptionLog](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[RequestId] [uniqueidentifier] NULL,
	[StackTrace] [nvarchar](max) NULL,
	[Message] [nvarchar](max) NOT NULL,
	[ExceptionUrl] [nvarchar](250) NOT NULL,
	[IpAdress] [nvarchar](200) NOT NULL,
	[HResult] [int] NULL,
	[BrowserInfo] [nvarchar](250) NULL,
	[IsForbidden] [bit] NULL,
	[CreatedBy] [int] NOT NULL,
	[ModifiedBy] [int] NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NULL,
	[ErrorCount] [int] NULL,
 CONSTRAINT [PK_ExceptionLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [log].[TempRequestLog]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [log].[TempRequestLog](
	[Id] [uniqueidentifier] NOT NULL,
	[PersonId] [int] NOT NULL,
	[RequestUrl] [nvarchar](50) NOT NULL,
	[IpAddress] [nvarchar](50) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RequestLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [work].[Comment]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [work].[Comment](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TaskId] [int] NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[CommentedDate] [datetime] NOT NULL,
	[CommentedBy] [int] NOT NULL,
 CONSTRAINT [PK_Comment] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [work].[Project]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [work].[Project](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UnitId] [int] NULL,
	[Name] [nvarchar](150) NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [work].[Task]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [work].[Task](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProjectId] [int] NOT NULL,
	[UnitId] [int] NOT NULL,
	[RequestedBy] [int] NOT NULL,
	[Title] [nvarchar](250) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[Queue] [int] NOT NULL,
	[RequestedDate] [datetime] NOT NULL,
	[Assigned] [int] NOT NULL,
	[TaskStatusId] [smallint] NOT NULL,
	[DueDate] [datetime] NULL,
	[ResultContent] [nvarchar](max) NULL,
	[Followers] [nvarchar](150) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
 CONSTRAINT [PK_Task] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [work].[TaskHistory]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [work].[TaskHistory](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[TaskId] [int] NOT NULL,
	[Assigned] [int] NOT NULL,
	[TaskStatusId] [smallint] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
 CONSTRAINT [PK_TaskHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [work].[TaskMedia]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [work].[TaskMedia](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[MediaId] [bigint] NOT NULL,
	[TaskId] [int] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TaskMedia] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [common].[GetUnitsByUnitId]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [common].[GetUnitsByUnitId] (	
	@UnitId int
)
RETURNS TABLE 
AS
RETURN 
(
WITH UnitView AS (
  SELECT Id ,ParentId,Name,Code,IsActive, 0 AS Level
  FROM common.Unit    
  where Id=@UnitId 
  UNION ALL
  
  SELECT u.Id,u.ParentId, u.Name,u.Code,u.IsActive,
  uv.Level +1 AS Level
  FROM UnitView AS uv
    INNER JOIN common.Unit  AS u
      ON uv.Id = u.ParentId
)
select * from UnitView a where a.IsActive = 1
)
GO
/****** Object:  UserDefinedFunction [work].[GetFilterableTasks]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [work].[GetFilterableTasks] 
(	
	@assigned int = null,
	@RequestedBy int = null,
	@UnitId int = null,
	@ProjectId int = null
)
RETURNS TABLE 
AS
RETURN 
(
SELECT a.Id,a.Queue, ProjectName = b.Name, RequestedBy = d.Name + ' ' + d.Surname,
a.Title, a.Description, RequestedDate = format(a.RequestedDate, 'dd MMMM yyy HH:mm', 'tr-TR'),
Assigned = e.Name + ' ' + e.Surname, TaskStatusName = f.Name, 
DueDate = format(a.DueDate, 'dd MMMM yyy HH:mm', 'tr-TR'), a.ResultContent,
CreatedDate = format(a.CreatedDate, 'dd MMMM yyy HH:mm', 'tr-TR'),a.TaskStatusId, 
ARequestedDate = a.RequestedDate,ACreatedDate = a.CreatedDate,ADueDate = a.DueDate,e.ImageId,
MediaIds =  substring(
    ( 
        Select ','+Convert(varchar,tm.MediaId )
        From work.TaskMedia tm 
        Where tm.TaskId = a.Id
        ORDER BY tm.Id 
        For XML PATH ('') 
    ), 2, 1000)
FROM work.Task a
INNER JOIN work.Project b ON b.Id = a.ProjectId 
INNER JOIN common.Person d ON d .Id = a.RequestedBy 
INNER JOIN common.Person e ON e.Id = a.Assigned 
INNER JOIN common.LookupList f ON f.Id = a.TaskStatusId 
INNER JOIN common.GetUnitsByUnitId(IIF(@UnitId is not null, @UnitId, 2380)) g ON g.Id = e.UnitId
where IIF(@assigned is not null, (IIF(a.Assigned=@assigned, 1, 0)), 1) = 1  and
IIF(@RequestedBy is not null, (IIF(a.RequestedBy=@RequestedBy, 1, 0)), 1) = 1   and
IIF(@ProjectId is not null, (IIF(a.ProjectId=@ProjectId, 1, 0)), 1) = 1   
)

GO
/****** Object:  UserDefinedFunction [work].[GetWorkFlow]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [work].[GetWorkFlow] 
(	
	@assigned int = null,
	@RequestedBy int = null,
	@UnitId int = null
)
RETURNS TABLE 
AS
RETURN 
(
select * from (
-- Yeni İş
select TaskId = a.Id, TaskStatusId = a.TaskStatusId, MessageType ='NewTask', Assigned = c.Name + ' ' + c.Surname, 
Title = a.Title,Text = REPLACE(a.Description, CHAR(10),'<br/>'), ADate = a.CreatedDate, CreatedBy = b.Name + ' ' + b.Surname,
AssignedId = a.Assigned, a.RequestedBy,a.UnitId
from work.Task a
inner join work.TaskHistory ba on ba.TaskId = a.Id and ba.TaskStatusId = 36
inner join common.Person b on b.Id = a.CreatedBy
inner join common.Person c on c.Id = a.Assigned
INNER JOIN common.GetUnitsByUnitId(IIF(@UnitId is not null, @UnitId, 2380)) h ON h.Id = c.UnitId
union all
-- Kapanan İş
select TaskId = a.Id, TaskStatusId = a.TaskStatusId, MessageType ='DueTask', Assigned = c.Name + ' ' + c.Surname, 
Title = a.Title,Text = REPLACE(a.ResultContent, CHAR(10),'<br/>'), ADate = ba.CreatedDate, CreatedBy = b.Name + ' ' + b.Surname ,
AssignedId = a.Assigned, a.RequestedBy,a.UnitId
from work.Task a
inner join work.TaskHistory ba on ba.TaskId = a.Id and ba.TaskStatusId = 38
inner join common.Person b on b.Id = ba.CreatedBy
inner join common.Person c on c.Id = a.Assigned
INNER JOIN common.GetUnitsByUnitId(IIF(@UnitId is not null, @UnitId, 2380)) h ON h.Id = c.UnitId
where a.DueDate is not null
union all
-- Yorum
select TaskId = a.TaskId, TaskStatusId = b.TaskStatusId, MessageType ='Comment', Assigned = d.Name + ' ' + d.Surname, 
Title = b.Title, Text = REPLACE(a.Description, CHAR(10),'<br/>'), ADate = a.CommentedDate, CreatedBy =  c.Name + ' ' + c.Surname ,
AssignedId = b.Assigned, b.RequestedBy,b.UnitId
from work.Comment a
inner join work.Task b on b.Id = a.TaskId
inner join common.Person c on c.Id = a.CommentedBy
inner join common.Person d on d.Id = b.Assigned
INNER JOIN common.GetUnitsByUnitId(IIF(@UnitId is not null, @UnitId, 2380)) h ON h.Id = d.UnitId
-- History
union all
select TaskId = a.Id, TaskStatusId = b.TaskStatusId, MessageType ='History', Assigned = c.Name + ' ' + c.Surname, 
Title = a.Title, Text = REPLACE(a.Description, CHAR(10),'<br/>'), ADate = b.CreatedDate, CreatedBy =  d.Name + ' ' + d.Surname, 
AssignedId = a.Assigned, a.RequestedBy,a.UnitId
from work.Task a
inner join work.TaskHistory b on b.TaskId = a.Id
inner join common.Person c on c.Id = b.Assigned
inner join common.Person d on d.Id = b.CreatedBy
INNER JOIN common.GetUnitsByUnitId(IIF(@UnitId is not null, @UnitId, 2380)) h ON h.Id = c.UnitId
where b.TaskStatusId!=36 and b.TaskStatusId!=38
) as a
where IIF(@assigned is not null, (IIF(a.AssignedId=@assigned, 1, 0)), 1) = 1  and
IIF(@RequestedBy is not null, (IIF(a.RequestedBy=@RequestedBy, 1, 0)), 1) = 1   --and
--IIF(@UnitId is not null, (IIF(a.UnitId=@UnitId, 1, 0)), 1) = 1   
)

GO
/****** Object:  UserDefinedFunction [work].[GetTaskList]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [work].[GetTaskList] 
(	
	@assigned int = null,
	@RequestedBy int = null,
	@UnitId int = null,
	@ProjectId int = null,
	@taskId int = null,
	@taskStatusId int = null,
	@title varchar(250) = null
)
RETURNS TABLE 
AS
RETURN 
(
SELECT a.Id,a.Queue, ProjectName = b.Name, RequestedBy = d.Name + ' ' + d.Surname,
a.Title, Description = REPLACE(a.Description, CHAR(10),'<br/>'), RequestedDate = format(a.RequestedDate, 'dd MMMM yyy HH:mm', 'tr-TR'),
Assigned = e.Name + ' ' + e.Surname, TaskStatusName = f.Name, 
DueDate = format(a.DueDate, 'dd MMMM yyy HH:mm', 'tr-TR'), a.ResultContent,
CreatedDate = format(a.CreatedDate, 'dd MMMM yyy HH:mm', 'tr-TR'),a.TaskStatusId, 
ARequestedDate = a.RequestedDate,ACreatedDate = a.CreatedDate,ADueDate = a.DueDate,e.ImageId,e.Initials,
CreatedBy = g.Name + ' ' + g.Surname,
MediaIds =  substring(
    ( 
        Select ','+Convert(varchar,tm.MediaId )
        From work.TaskMedia tm 
        Where tm.TaskId = a.Id
        ORDER BY tm.Id 
        For XML PATH ('') 
    ), 2, 1000)
FROM work.Task a
INNER JOIN work.Project b ON b.Id = a.ProjectId 
INNER JOIN common.Unit c ON c.Id = a.UnitId 
INNER JOIN common.Person d ON d .Id = a.RequestedBy 
INNER JOIN common.Person e ON e.Id = a.Assigned 
INNER JOIN common.Person g ON g.Id = a.CreatedBy
INNER JOIN common.LookupList f ON f.Id = a.TaskStatusId 
INNER JOIN common.GetUnitsByUnitId(IIF(@UnitId is not null, @UnitId, 2380)) h ON h.Id = e.UnitId
where IIF(@assigned is not null, (IIF(a.Assigned =@assigned, 1, 0)), 1) = 1 and 
IIF(@RequestedBy is not null, (IIF(a.RequestedBy=@RequestedBy, 1, 0)), 1) = 1 and 
IIF(@ProjectId is not null, (IIF(a.ProjectId=@ProjectId, 1, 0)), 1) = 1 and
IIF(@taskId is not null, (IIF(a.Id=@taskId, 1, 0)), 1) = 1  and
IIF(@taskStatusId is not null and @taskStatusId!= -1 , IIF(a.TaskStatusId=@taskStatusId, 1, 0), IIF(@taskStatusId = -1 ,1, IIF(a.TaskStatusId!=38 and a.TaskStatusId!=39, 1, 0))) = 1 and
IIF(@title is not null, (IIF(a.title like '%' + @title + '%', 1, 0)), 1) = 1
)

GO
/****** Object:  UserDefinedFunction [work].[GetPersonTaskList]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [work].[GetPersonTaskList] 
(	
	@projectId int = null,
	@unitId int = null,
	@personId int = null,
	@taskStatusId int = null,
	@startDate date = null,
	@endDate date = null
)
RETURNS TABLE 
AS
RETURN 
(
Select Person = b.Name +' '+b.Surname, a.Title, ARequestedDate = FORMAT(a.RequestedDate,'dd.MM.yyyy HH:mm'), 
RequestedDate = a.RequestedDate, DueDate = FORMAT(a.DueDate,'dd.MM.yyyy HH:mm'), TasktStatusName = c.Name
from work.Task a 
inner join common.Person b on b.Id = a.Assigned
inner join common.LookupList c on c.Id = a.TaskStatusId
--inner join common.GetUnitsByUnitId(@unitId) d on d.Id = b.UnitId
where
IIF(@projectId is not null, (IIF(a.ProjectId = @projectId, 1, 0)), 1) = 1  and
IIF(@unitId is not null, (IIF(b.UnitId in (select Id from common.GetUnitsByUnitId(@unitId)), 1, 0)), 1) = 1  and
IIF(@personId is not null, (IIF(b.Id = @personId, 1, 0)), 1) = 1  and
IIF(@taskStatusId is not null and @taskStatusId!=-1, IIF(a.TaskStatusId=@taskStatusId, 1, 0), IIF(@taskStatusId = -1 ,1, IIF(a.TaskStatusId!=38 and a.TaskStatusId!=39, 1, 0))) = 1 and
IIF(@startDate is not null and @endDate is not null, (IIF(Convert(date,a.RequestedDate) between Convert(date,@startDate) and Convert(date,@endDate) , 1, 0)), 1) = 1
)

GO
/****** Object:  UserDefinedFunction [work].[GetPersonTasktStatusCounts]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [work].[GetPersonTasktStatusCounts] 
(	
 	  @startDate datetime = null,
	  @endDate datetime = null,
	  @unitId int = null
)
RETURNS TABLE 
AS
RETURN 
(
select ab.* from (select Person = a.Name + ' ' + a.Surname,PersonId = a.Id,
IsAcmaSayisi=(select count(x.CreatedBy) 
from work.Task x
where x.CreatedBy = a.Id and 
IIF(Convert(date,@startDate,105) is not null, IIF(Convert(date,x.RequestedDate,105) between Convert(date,@startDate,105) and Convert(date,@endDate,105), 1, 0), 1) = 1
group by x.CreatedBy),
Yapilacak = (select count(x.Assigned) 
from work.Task x
where x.TaskStatusId = 36 and x.Assigned = a.Id and 
IIF(Convert(date,@startDate,105) is not null, IIF(Convert(date,x.RequestedDate,105) between Convert(date,@startDate,105) and Convert(date,@endDate,105), 1, 0), 1) = 1
group by x.Assigned),
DevamEden = (select count(x.Assigned) 
from work.Task x
where x.TaskStatusId = 37 and x.Assigned = a.Id and 
IIF(Convert(date,@startDate,105) is not null, IIF(Convert(date,x.RequestedDate,105) between Convert(date,@startDate,105) and Convert(date,@endDate,105), 1, 0), 1) = 1
group by x.Assigned),
Tamamlanan = (select count(x.Assigned) 
from work.Task x
where x.TaskStatusId = 38 and x.Assigned = a.Id and 
IIF(Convert(date,@startDate,105) is not null, IIF( Convert(date,x.RequestedDate,105) between Convert(date,@startDate,105) and Convert(date,@endDate,105), 1, 0), 1) = 1
group by x.Assigned),
Kaldirilan = (select count(x.Assigned) 
from work.Task x
where x.TaskStatusId = 39 and x.Assigned = a.Id and 
IIF(Convert(date,@startDate,105) is not null, IIF(Convert(date,x.RequestedDate,105) between Convert(date,@startDate,105) and Convert(date,@endDate,105), 1, 0), 1) = 1
group by x.Assigned),
Toplam = (select count(x.Assigned) 
from work.Task x
where x.Assigned = a.Id and
IIF(Convert(date,@startDate,105) is not null, IIF(Convert(date,x.RequestedDate,105) between Convert(date,@startDate,105) and Convert(date,@endDate,105), 1, 0), 1) = 1
group by x.Assigned)
from common.Person a 
inner join common.GetUnitsByUnitId(@unitId) b on b.Id = a.UnitId) as ab
where ab.Toplam is not null 
)

GO
/****** Object:  UserDefinedFunction [common].[GetParentUnitsByUnitId]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [common].[GetParentUnitsByUnitId] (	
	@UnitId int
)
RETURNS TABLE 
AS
RETURN 
(
WITH UnitView AS (
  SELECT Id ,ParentId, Name, IsActive,UnitTypeId
  FROM common.Unit    
  where Id=@UnitId 
  UNION ALL
  
  SELECT u.Id,u.ParentId,u.Name,u.IsActive,u.UnitTypeId
  FROM UnitView AS uv
    INNER JOIN common.Unit  AS u
      ON uv.ParentId = u.Id
)
select * from UnitView a where a.IsActive=1
)
GO
/****** Object:  UserDefinedFunction [work].[GetTasks]    Script Date: 6.08.2017 18:50:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [work].[GetTasks] 
(	
	---- Add the parameters for the function here
	@assigned int = null
	--<@param2, sysname, @p2> <Data_Type_For_Param2, , char>
)
RETURNS TABLE 
AS
RETURN 
(
SELECT a.Id,e.Initials,a.Queue, ProjectName = b.Name, RequestedBy = d.Name + ' ' + d.Surname,
a.Title,Description = REPLACE(a.Description, CHAR(10),'<br/>'), RequestedDate = format(a.RequestedDate, 'dd MMMM yyy HH:mm', 'tr-TR'),
Assigned = e.Name + ' ' + e.Surname, TaskStatusName = f.Name, 
DueDate = format(a.DueDate, 'dd MMMM yyy HH:mm', 'tr-TR'), a.ResultContent,
CreatedDate = format(a.CreatedDate, 'dd MMMM yyy HH:mm', 'tr-TR'),a.TaskStatusId, 
ARequestedDate = a.RequestedDate,ACreatedDate = a.CreatedDate,ADueDate = a.DueDate,e.ImageId,
MediaIds =  substring(
    ( 
        Select ','+Convert(varchar,tm.MediaId )
        From work.TaskMedia tm 
        Where tm.TaskId = a.Id
        ORDER BY tm.Id 
        For XML PATH ('') 
    ), 2, 1000)
FROM work.Task a
INNER JOIN work.Project b ON b.Id = a.ProjectId 
INNER JOIN common.Unit c ON c.Id = a.UnitId 
INNER JOIN common.Person d ON d .Id = a.RequestedBy 
LEFT JOIN common.Person e ON e.Id = a.Assigned 
INNER JOIN common.LookupList f ON f.Id = a.TaskStatusId 
where IIF(@assigned is not null, (IIF(a.Assigned=@assigned, 1, 0)), 1) = 1 
)

GO
INSERT [common].[Lookup] ([Id], [Name]) VALUES (1, N'Yasaklı Erişim Tipi')
INSERT [common].[Lookup] ([Id], [Name]) VALUES (2, N'Mesaj Tipleri')
INSERT [common].[Lookup] ([Id], [Name]) VALUES (5, N'Medya Tipleri')
INSERT [common].[Lookup] ([Id], [Name]) VALUES (8, N'İş Durumu')
INSERT [common].[Lookup] ([Id], [Name]) VALUES (10, N'Birim Tipleri')
INSERT [common].[Lookup] ([Id], [Name]) VALUES (11, N'Cinsi')
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (1, NULL, 1, N'CurrentPerson', N'Mevcut Kişi', 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (2, NULL, 1, N'Veritabanı İşlemi', NULL, 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (3, NULL, 2, N'info', N'Bilgilendirme', 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (4, NULL, 2, N'success', N'Tebrikler', 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (5, NULL, 2, N'warning', N'Eksik Bilgi', 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (6, NULL, 2, N'danger', N'Uyarı', 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (7, NULL, 2, N'func', NULL, 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (8, NULL, 2, N'funcAndMessage', N'Bilgilendirme', 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (9, NULL, 1, N'forbidden', NULL, 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (27, NULL, 5, N'Basında Biz', NULL, 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (36, NULL, 8, N'Yapılacak', NULL, 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (37, NULL, 8, N'Devam Ediyor', NULL, 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (38, NULL, 8, N'Tamamlandı', NULL, 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (39, NULL, 8, N'Kaldırıldı', NULL, 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (40, NULL, 5, N'İş Yönetimi', NULL, 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (43, NULL, 5, N'Etkinlik', NULL, 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (2090, NULL, 10, N'Genel Müdür', N'Genel Müdür', 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (2091, NULL, 10, N'Müdürlük', N'Müdürlük', 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (2092, NULL, 10, N'Daire Başkanlığı', N'Daire Başkanlığı', 1, NULL, NULL, NULL)
INSERT [common].[LookupList] ([Id], [ParentId], [LookupId], [Name], [LongName], [IsActive], [Color], [Icon], [Value]) VALUES (2093, NULL, 10, N'Şube Müdürlüğü', N'Şube Müdürlüğü', 1, NULL, NULL, NULL)
INSERT [common].[Parameters] ([Id], [Code], [Name], [Value], [Description], [IsActive]) VALUES (1, N'SistemMail', N'Sistem Mail Adresi', N'bildirim@domain.com', N'Üyelere sistem üzerinden mail gönderilmesini saglar', 1)
INSERT [common].[Parameters] ([Id], [Code], [Name], [Value], [Description], [IsActive]) VALUES (2, N'SistemMailSifre', N'Sistem Mail Sifresi', N'JxWUua/pDiAk+m7XkMCV2ZsTYwSQjfFun6J9KiIcLNeXhgjZ3sGMoCqesSusI6tq', N'Sistem mailin sifresi', 1)
INSERT [common].[Parameters] ([Id], [Code], [Name], [Value], [Description], [IsActive]) VALUES (3, N'SistemMailBaslik', N'Sistem Mail Basligi', N'Is Takip', N'Gönderilen maillerin baslik kismini belirtir', 1)
INSERT [common].[Parameters] ([Id], [Code], [Name], [Value], [Description], [IsActive]) VALUES (4, N'SistemMailSmtpClient', N'Sistem Mail Smtp Client', N'mail.domain.com', N'', 1)
INSERT [common].[Parameters] ([Id], [Code], [Name], [Value], [Description], [IsActive]) VALUES (5, N'ErrorCount', N'Hatali Giris Sayisi', N'5', N'', 1)
INSERT [common].[Parameters] ([Id], [Code], [Name], [Value], [Description], [IsActive]) VALUES (6, N'IsSendMailForWork', N'Is takibinde mai gönderilsin mi ?', N'False', N'Is takibinde maill gönderisin mi?', 1)
SET IDENTITY_INSERT [common].[Person] ON 

INSERT [common].[Person] ([Id], [UnitId], [UserName], [Initials], [Name], [Surname], [Password], [Email], [ImageId], [IsActive], [Phone]) VALUES (177, 6, N'cengiz177', N'CY', N'CENGİZ', N'YILMAZ', N'OekQZv7fhkZHw42xFwxcfd4xt9q2bekSRI7LYNAY1uJNUPl9kQgCCjLpfTXM9mTU', N'cengizyilmaz@ercanayhan.com.tr', 189, 1, NULL)
INSERT [common].[Person] ([Id], [UnitId], [UserName], [Initials], [Name], [Surname], [Password], [Email], [ImageId], [IsActive], [Phone]) VALUES (193, 1025, N'abuzer193', N'AY', N'ABUZER', N'YILMAZ', N'wx9BBay4qgVBhhW6FQu1r2RqOQhv39UjLIX660WpY+2SQ/84kkrGsjqV/2pUE+oz', N'abuzeryilmaz@ercanayhan.com.tr', 173, 1, NULL)
INSERT [common].[Person] ([Id], [UnitId], [UserName], [Initials], [Name], [Surname], [Password], [Email], [ImageId], [IsActive], [Phone]) VALUES (733, 1025, N'abdusselam733', N'AY', N'ABDUSSELAM', N'YILMAZ', N'kj08lrf8munc5bnrd4nYZFocs+ZV098MyFIvQwfKWLy+riw12T3+veMWw7eguhhS', N'abdusselamyilmaz@ercanayhan.com.tr', 2047, 1, NULL)
INSERT [common].[Person] ([Id], [UnitId], [UserName], [Initials], [Name], [Surname], [Password], [Email], [ImageId], [IsActive], [Phone]) VALUES (774, 1062, N'adem774', N'AY', N'ADEM', N'YILMAZ', N'JYI7rXrqUuZ1jwcsxA5YYdYQPrqe6j5ftA4Woc08kMRbSV5TUKEIeE7476eeqgF3', N'ademyilmaz@ercanayhan.com.tr', 2235, 1, NULL)
INSERT [common].[Person] ([Id], [UnitId], [UserName], [Initials], [Name], [Surname], [Password], [Email], [ImageId], [IsActive], [Phone]) VALUES (790, 1025, N'ercan790', N'EA', N'ERCAN', N'AYHAN', N'EpBLWdqo/6+01H+LZRzry5enS97DtuqqCAOBLdyeMFjMgkJ5WTFgd3sVBY/Yj5or', N'ercanayhan@ercanayhan.com.tr', 2332, 1, NULL)
SET IDENTITY_INSERT [common].[Person] OFF
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1, 2360, 2092, N'Abone İşleri Dairesi Başkanlığı', N'Abone', 1, 56, 1)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (2, 1023, 2092, N'Atıksu Arıtma Dairesi Başkanlığı', N'AtıkSu Arıtma', 1, 53, 2)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (6, 2360, 2092, N'Bilgi İşlem Dairesi Başkanlığı', N'Bilgi İşlem', 1, 21, 8)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (12, 2360, 2092, N'Destek Hizmetleri Dairesi Başkanlığı', N'Destek Hizmetleri', 1, 18, 4)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (14, 2380, 2090, N'Genel Müdürlük', N'Genel Müdürlük', 1, 6, 7)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1016, 14, 2091, N'1. Hukuk Müşavirliği', N'Hukuk', 1, 9, 13)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1017, 1023, 2092, N'İçmesuyu Dairesi Başkanlığı', N'İçmesuyu', 1, 47, 3)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1018, 1023, 2092, N'Kanalizasyon Dairesi Başkanlığı', N'Kanal', 1, 50, 14)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1019, 1034, 2092, N'İnsan Kaynakları Ve Eğitim Dairesi Başkanlığı', N'İnsan Kaynakları', 1, 19, 6)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1020, 1034, 2092, N'İşletmeler Dairesi Başkanlığı', N'İşletmeler', 1, 17, 10)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1021, 2381, 2121, N'Plan Proje Dairesi Başkanlığı', N'Plan Proje', 0, NULL, NULL)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1022, 1034, 2092, N'Strateji Geliştirme Dairesi Başkanlığı', N'Strateji', 1, 20, 16)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1023, 14, 2091, N'Genel Müdür Yardımcısı - 2', N'Genel Müdür Yrd. 2', 1, 10, 19)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1024, 2360, 2092, N'Yatırım ve İnşaat Dairesi Başkanlığı', N'Yatırım İnşaat', 1, 86, 5)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1025, 6, 2093, N'Yazılım Şube Müdürlüğü', N'Yazılım', 1, 44, 15)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1026, 6, 2093, N'Donanım Şube Müdürlüğü', N'Donanım', 1, 46, 13)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1027, 1, 2093, N'Abone Hizmetleri Şube Müdürlüğü', N'Abone Bağlantı', 1, 57, 2)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1028, 1, 2093, N'Kaçak Su Kontrol Şube Müdürlüğü', N'Abone Kaçak Su', 1, 58, 4)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1030, 1017, 2093, N'İçmesuyu Şebeke İşletme Şube Müdürlüğü', N'Şebeke&İşletme', 1, 48, 6)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1031, 1017, 2093, N'İçmesuyu Tesisler ve Otomasyon Şube Müdürlüğü', N'Tesisler&Otomasyon', 1, 49, NULL)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1032, 1018, 2093, N'Kanalizasyon İşletme Şube Müdürlüğü', N'Kanalizasyon', 1, 51, 29)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1033, 1018, 2093, N'Kanalizasyon ve Yağmursuyu Şube Müdürlüğü', N'Kanal Bağlantı', 1, 52, 30)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1034, 14, 2091, N'Genel Müdür Yardımcısı - 1', N'Genel Müdür Yrd. 1', 1, 12, 12)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1035, 2, 2093, N'Atıksu Arıtma Denetim Şube Müdürlüğü', N'Atıksu Denetim', 1, 54, 5)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1036, 2, 2093, N'İlçeler Atıksu Arıtma Şube Müdürlüğü', N'İlçeler Atıksu', 1, 55, 7)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1037, 6, 2093, N'Coğrafi Bilgi Sistemi Şube Müdürlüğü', N'CBS', 1, 45, 14)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1038, 1034, 2092, N'Cevre Koruma ve Kontrol Dairesi Başkanlığı', N'Çevre Koruma', 1, 13, 9)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1039, 1038, 2093, N'Cevre Şube Müdürlüğü', N'Çevre Müdürlüğü', 1, 22, 16)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1041, 1034, 2092, N'Tesisler Dairesi Başkanlığı', N'Tesisler', 1, 14, 11)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1042, 1041, 2093, N'Hidrojeoloji, Etüt Şube Müdürlüğü', N'Hidroloji Etüt', 1, 25, 37)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1043, 1041, 2093, N'Tesisler Bakım Onarım Şube Müdürlüğü', N'Bakım Onarım', 1, 26, 36)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1044, 1041, 2093, N'Su Kalite Kontrol ve Laboratuvar Şube Müdürlüğü', N'Su Kalite', 1, 27, 18)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1045, 1021, 2121, N'Plan Proje Şube Müdürlüğü', N'Plan Proje', 0, NULL, NULL)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1047, 1024, 2093, N'Yapım İşleri Şube Müdürlüğü', N'Yapım İşleri', 1, 30, 9)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1048, 1021, 2121, N'Harita Emlak ve Kamulaştırma Şube Müdürlüğü', N'Harita Emlak', 0, NULL, NULL)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1049, 1020, 2093, N'Güney İlçeler Şube Müdürlüğü', N'Güney İlçeler', 1, 32, 28)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1050, 1020, 2093, N'Kuzey İlçeler Şube Müdürlüğü', N'Kuzey İlçeler', 1, 33, 17)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1051, 1022, 2093, N'Bütçe ve Muhasebe Şube Müdürlüğü', N'Bütçe ve Muhasebe', 1, 41, 34)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1052, 1022, 2093, N'Gelir ve Kontrol Şube Müdürlüğü', N'Gelir Kontrol', 1, 42, 33)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1053, 1022, 2093, N'Strateji Geliştirme Şube Müdürlüğü', N'Strateji Geliştirme', 1, 43, 35)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1054, 1019, 2093, N'İnsan Kaynakları Şube Müdürlüğü', N'İnsan Kaynakları', 1, 38, 26)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1055, 1019, 2093, N'Yazı İşleri ve Kararlar Şube Müdürlüğü', N'Yazı İşleri', 1, 39, 11)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1056, 1023, 2092, N'İş Sağlığı Güvenliği ve Sivil Savunma Şube Müdürlüğü', N'İş Sağlığı', 1, 425, NULL)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1057, 12, 2093, N'Makine İkmal ve Atolye Şube Müdürlüğü', N'Makine İkmal', 1, 34, 19)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1058, 12, 2093, N'Satınalma Şube Müdürlüğü', N'Satınalma', 1, 368, 20)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1059, 12, 2093, N'Ambar ve İdari İşler Şube Müdürlüğü', N'Ambar ve İdari İşler', 1, 369, 8)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1060, 1024, 2093, N'İhale Şube Müdürlüğü', N'İhale', 1, 445, 38)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1061, 14, 2091, N'Yönetim Kurulu', N'Yönetim Kurulu', 1, 5, NULL)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1062, 14, 2091, N'Özel Kalem Müdürlüğü', N'Özel Kalem', 1, 8, 17)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1063, 14, 2092, N'Basın Yayın ve Halkla İlişkiler Şube Md.', N'Basın Yayın', 1, 82, 18)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1064, 14, 2091, N'Teftiş Kurulu', N'Teftiş Kurulu', 1, 7, NULL)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1065, 14, 2091, N'Genel Kurul', N'Genel Kurul', 1, 4, NULL)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (1066, 14, 2091, N'İç Denetçiler', N'İç Denetçiler', 1, 404, NULL)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (2355, 1038, 2093, N'Etüt Şube Müdürlüğü', N'Etüt Şube Müd.', 1, 684, 10)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (2360, 14, 2091, N'Genel Müdür Yardımcısı - 3', N'Genel Müdür Yrd. 3', 1, 385, 20)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (2361, 1041, 2093, N'Scada Şube Müdürlüğü', N'Scada Şb. Md.', 1, 364, 22)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (2362, 14, 2092, N'Kalite Yönetim Birimi', N'Kalite', 1, 304, NULL)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (2366, 1, 2093, N'Sayaç Hizmetleri Şube Müdürlüğü', N'Abone Sayaç', 1, 59, 3)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (2380, NULL, 2090, N'MASKİ', N'MASKİ', 1, 1, NULL)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (2413, 1019, 2093, N'Eğitim Şube Müdürlüğü', N'Eğitim', 1, 444, 27)
INSERT [common].[Unit] ([Id], [ParentId], [UnitTypeId], [Name], [Code], [IsActive], [YbsUnitId], [PdksUnitId]) VALUES (2626, 1024, 2093, N'Proje ve Kamulaştırma Şube Müdürlüğü', N'Proje', 1, 645, 32)
SET IDENTITY_INSERT [log].[ExceptionLog] ON 

INSERT [log].[ExceptionLog] ([Id], [RequestId], [StackTrace], [Message], [ExceptionUrl], [IpAdress], [HResult], [BrowserInfo], [IsForbidden], [CreatedBy], [ModifiedBy], [CreatedDate], [ModifiedDate], [ErrorCount]) VALUES (101, NULL, N'   konum: System.Security.Cryptography.RijndaelManagedTransform.DecryptData(Byte[] inputBuffer, Int32 inputOffset, Int32 inputCount, Byte[]& outputBuffer, Int32 outputOffset, PaddingMode paddingMode, Boolean fLast)
   konum: System.Security.Cryptography.RijndaelManagedTransform.TransformFinalBlock(Byte[] inputBuffer, Int32 inputOffset, Int32 inputCount)
   konum: System.Security.Cryptography.CryptoStream.Read(Byte[] buffer, Int32 offset, Int32 count)
   konum: System.IO.StreamReader.ReadBuffer()
   konum: System.IO.StreamReader.ReadToEnd()
   konum: Arch.Utilities.Manager.EnDeCode.DecryptWithAES(Byte[] ciphertextBytes, Byte[] keyBytes, Byte[] ivBytes) d:\Egitim\ProjectWork\Arch.Utilities\Manager\EnDeCode.cs içinde: satır 105
   konum: Arch.Utilities.Manager.EnDeCode.Decrypt(String ciphertext, String key) d:\Egitim\ProjectWork\Arch.Utilities\Manager\EnDeCode.cs içinde: satır 47
   konum: System.Dynamic.UpdateDelegates.UpdateAndExecute3[T0,T1,T2,TRet](CallSite site, T0 arg0, T1 arg1, T2 arg2)
   konum: System.Web.Mvc.MailHelper.SendMail(String title, String body, String to, List`1 cc, List`1 attachementList) d:\Egitim\ProjectWork\Arch.Web.Framework\Helpers\MailHelper.cs içinde: satır 29
   konum: Arch.Web.Controllers.WorkController.InsertTaskComment(Comment model) d:\Egitim\ProjectWork\Arch.Web\Controllers\WorkController.cs içinde: satır 520
   konum: lambda_method(Closure , ControllerBase , Object[] )
   konum: System.Web.Mvc.ActionMethodDispatcher.Execute(ControllerBase controller, Object[] parameters)
   konum: System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)
   konum: System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.<BeginInvokeSynchronousActionMethod>b__39(IAsyncResult asyncResult, ActionInvocation innerInvokeState)
   konum: System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)
   konum: System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResultBase`1.End()
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.<InvokeActionMethodFilterAsynchronouslyRecursive>b__3d()
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.<>c__DisplayClass46.<InvokeActionMethodFilterAsynchronouslyRecursive>b__3f()', N'Doldurma geçersiz ve kaldırılamaz.', N'/Work/InsertTaskComment', N'::1', -2146233296, N'Name : Chrome, Type : Chrome60, Version : 60.0', NULL, 790, NULL, CAST(0x0000A7C600ED838F AS DateTime), NULL, 1)
INSERT [log].[ExceptionLog] ([Id], [RequestId], [StackTrace], [Message], [ExceptionUrl], [IpAdress], [HResult], [BrowserInfo], [IsForbidden], [CreatedBy], [ModifiedBy], [CreatedDate], [ModifiedDate], [ErrorCount]) VALUES (102, NULL, N'   konum: System.Security.Cryptography.RijndaelManagedTransform.DecryptData(Byte[] inputBuffer, Int32 inputOffset, Int32 inputCount, Byte[]& outputBuffer, Int32 outputOffset, PaddingMode paddingMode, Boolean fLast)
   konum: System.Security.Cryptography.RijndaelManagedTransform.TransformFinalBlock(Byte[] inputBuffer, Int32 inputOffset, Int32 inputCount)
   konum: System.Security.Cryptography.CryptoStream.Read(Byte[] buffer, Int32 offset, Int32 count)
   konum: System.IO.StreamReader.ReadBuffer()
   konum: System.IO.StreamReader.ReadToEnd()
   konum: Arch.Utilities.Manager.EnDeCode.DecryptWithAES(Byte[] ciphertextBytes, Byte[] keyBytes, Byte[] ivBytes) d:\Egitim\ProjectWork\Arch.Utilities\Manager\EnDeCode.cs içinde: satır 105
   konum: Arch.Utilities.Manager.EnDeCode.Decrypt(String ciphertext, String key) d:\Egitim\ProjectWork\Arch.Utilities\Manager\EnDeCode.cs içinde: satır 47
   konum: System.Dynamic.UpdateDelegates.UpdateAndExecute3[T0,T1,T2,TRet](CallSite site, T0 arg0, T1 arg1, T2 arg2)
   konum: System.Web.Mvc.MailHelper.SendMail(String title, String body, String to, List`1 cc, List`1 attachementList) d:\Egitim\ProjectWork\Arch.Web.Framework\Helpers\MailHelper.cs içinde: satır 29
   konum: Arch.Web.Controllers.WorkController.InsertTaskComment(Comment model) d:\Egitim\ProjectWork\Arch.Web\Controllers\WorkController.cs içinde: satır 520
   konum: lambda_method(Closure , ControllerBase , Object[] )
   konum: System.Web.Mvc.ActionMethodDispatcher.Execute(ControllerBase controller, Object[] parameters)
   konum: System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)
   konum: System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.ActionInvocation.InvokeSynchronousActionMethod()
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.<BeginInvokeSynchronousActionMethod>b__39(IAsyncResult asyncResult, ActionInvocation innerInvokeState)
   konum: System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)
   konum: System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResultBase`1.End()
   konum: System.Web.Mvc.Async.AsyncResultWrapper.End[TResult](IAsyncResult asyncResult, Object tag)
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.<InvokeActionMethodFilterAsynchronouslyRecursive>b__3d()
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.<>c__DisplayClass46.<InvokeActionMethodFilterAsynchronouslyRecursive>b__3f()', N'Doldurma geçersiz ve kaldırılamaz.', N'/Work/InsertTaskComment', N'::1', -2146233296, N'Name : Chrome, Type : Chrome60, Version : 60.0', NULL, 790, NULL, CAST(0x0000A7C600EDF229 AS DateTime), NULL, 1)
INSERT [log].[ExceptionLog] ([Id], [RequestId], [StackTrace], [Message], [ExceptionUrl], [IpAdress], [HResult], [BrowserInfo], [IsForbidden], [CreatedBy], [ModifiedBy], [CreatedDate], [ModifiedDate], [ErrorCount]) VALUES (103, NULL, N'   konum: CallSite.Target(Closure , CallSite , Object )
   konum: System.Dynamic.UpdateDelegates.UpdateAndExecute1[T0,TRet](CallSite site, T0 arg0)
   konum: Arch.Web.Controllers.WorkController.InsertTaskComment(Comment model) d:\Egitim\ProjectWork\Arch.Web\Controllers\WorkController.cs içinde: satır 507
   konum: lambda_method(Closure , ControllerBase , Object[] )
   konum: System.Web.Mvc.ActionMethodDispatcher.Execute(ControllerBase controller, Object[] parameters)
   konum: System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)
   konum: System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.<BeginInvokeSynchronousActionMethod>b__39(IAsyncResult asyncResult, ActionInvocation innerInvokeState)
   konum: System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)
   konum: System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResultBase`1.End()
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.<InvokeActionMethodFilterAsynchronouslyRecursive>b__3d()
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.<>c__DisplayClass46.<InvokeActionMethodFilterAsynchronouslyRecursive>b__3f()', N'''string'' türü örtülü olarak ''bool'' türüne dönüştürülemez', N'/Work/InsertTaskComment', N'::1', -2146233088, N'Name : Chrome, Type : Chrome60, Version : 60.0', NULL, 790, NULL, CAST(0x0000A7C600EF0626 AS DateTime), NULL, 1)
INSERT [log].[ExceptionLog] ([Id], [RequestId], [StackTrace], [Message], [ExceptionUrl], [IpAdress], [HResult], [BrowserInfo], [IsForbidden], [CreatedBy], [ModifiedBy], [CreatedDate], [ModifiedDate], [ErrorCount]) VALUES (104, NULL, N'   konum: System.Security.Cryptography.RijndaelManagedTransform.DecryptData(Byte[] inputBuffer, Int32 inputOffset, Int32 inputCount, Byte[]& outputBuffer, Int32 outputOffset, PaddingMode paddingMode, Boolean fLast)
   konum: System.Security.Cryptography.RijndaelManagedTransform.TransformFinalBlock(Byte[] inputBuffer, Int32 inputOffset, Int32 inputCount)
   konum: System.Security.Cryptography.CryptoStream.Read(Byte[] buffer, Int32 offset, Int32 count)
   konum: System.IO.StreamReader.ReadBuffer()
   konum: System.IO.StreamReader.ReadToEnd()
   konum: Arch.Utilities.Manager.EnDeCode.DecryptWithAES(Byte[] ciphertextBytes, Byte[] keyBytes, Byte[] ivBytes) d:\Egitim\ProjectWork\Arch.Utilities\Manager\EnDeCode.cs içinde: satır 105
   konum: Arch.Utilities.Manager.EnDeCode.Decrypt(String ciphertext, String key) d:\Egitim\ProjectWork\Arch.Utilities\Manager\EnDeCode.cs içinde: satır 47
   konum: System.Dynamic.UpdateDelegates.UpdateAndExecute3[T0,T1,T2,TRet](CallSite site, T0 arg0, T1 arg1, T2 arg2)
   konum: System.Web.Mvc.MailHelper.SendMail(String title, String body, String to, List`1 cc, List`1 attachementList) d:\Egitim\ProjectWork\Arch.Web.Framework\Helpers\MailHelper.cs içinde: satır 29
   konum: Arch.Web.Controllers.WorkController.InsertTaskComment(Comment model) d:\Egitim\ProjectWork\Arch.Web\Controllers\WorkController.cs içinde: satır 530
   konum: lambda_method(Closure , ControllerBase , Object[] )
   konum: System.Web.Mvc.ActionMethodDispatcher.Execute(ControllerBase controller, Object[] parameters)
   konum: System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)
   konum: System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.<BeginInvokeSynchronousActionMethod>b__39(IAsyncResult asyncResult, ActionInvocation innerInvokeState)
   konum: System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)
   konum: System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResultBase`1.End()
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.<InvokeActionMethodFilterAsynchronouslyRecursive>b__3d()
   konum: System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.<>c__DisplayClass46.<InvokeActionMethodFilterAsynchronouslyRecursive>b__3f()', N'Doldurma geçersiz ve kaldırılamaz.', N'/Work/InsertTaskComment', N'::1', -2146233296, N'Name : Chrome, Type : Chrome60, Version : 60.0', NULL, 790, NULL, CAST(0x0000A7C600EF460E AS DateTime), NULL, 1)
INSERT [log].[ExceptionLog] ([Id], [RequestId], [StackTrace], [Message], [ExceptionUrl], [IpAdress], [HResult], [BrowserInfo], [IsForbidden], [CreatedBy], [ModifiedBy], [CreatedDate], [ModifiedDate], [ErrorCount]) VALUES (105, NULL, NULL, N'2', N'Dashboard/Index', N'::1', 0, N'Chrome##WinNT##tr-TR', 1, 0, NULL, CAST(0x0000A7C7012A20B0 AS DateTime), NULL, NULL)
INSERT [log].[ExceptionLog] ([Id], [RequestId], [StackTrace], [Message], [ExceptionUrl], [IpAdress], [HResult], [BrowserInfo], [IsForbidden], [CreatedBy], [ModifiedBy], [CreatedDate], [ModifiedDate], [ErrorCount]) VALUES (106, NULL, NULL, N'2', N'Work/GetProjectsPersonsUnits', N'::1', 0, N'Chrome##WinNT##tr-TR', 1, 0, NULL, CAST(0x0000A7C7012F5693 AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [log].[ExceptionLog] OFF
SET IDENTITY_INSERT [work].[Comment] ON 

INSERT [work].[Comment] ([Id], [TaskId], [Description], [CommentedDate], [CommentedBy]) VALUES (143, 494, N'test', CAST(0x0000A7C600ED82F4 AS DateTime), 790)
INSERT [work].[Comment] ([Id], [TaskId], [Description], [CommentedDate], [CommentedBy]) VALUES (144, 494, N'test2', CAST(0x0000A7C600EDD1A5 AS DateTime), 790)
INSERT [work].[Comment] ([Id], [TaskId], [Description], [CommentedDate], [CommentedBy]) VALUES (145, 494, N'test3', CAST(0x0000A7C600EF05E9 AS DateTime), 790)
INSERT [work].[Comment] ([Id], [TaskId], [Description], [CommentedDate], [CommentedBy]) VALUES (146, 494, N'test4', CAST(0x0000A7C600EF452D AS DateTime), 790)
INSERT [work].[Comment] ([Id], [TaskId], [Description], [CommentedDate], [CommentedBy]) VALUES (147, 494, N'test5', CAST(0x0000A7C600EF644C AS DateTime), 790)
INSERT [work].[Comment] ([Id], [TaskId], [Description], [CommentedDate], [CommentedBy]) VALUES (148, 494, N'test', CAST(0x0000A7C600F42E4F AS DateTime), 790)
SET IDENTITY_INSERT [work].[Comment] OFF
SET IDENTITY_INSERT [work].[Project] ON 

INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (1, 6, N'ABYS', 790, CAST(0x0000A740008C1360 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (2, 6, N'YBS', 790, CAST(0x0000A740008C1360 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (3, 6, N'EBYS', 790, CAST(0x0000A740008C1360 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (4, 6, N'BİM', 790, CAST(0x0000A740008C1360 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (5, 6, N'İş Zekası', 790, CAST(0x0000A740008C1360 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (6, 6, N'Kalite', 790, CAST(0x0000A740008C1360 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (7, 6, N'CBS', 790, CAST(0x0000A740008C1360 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (8, 6, N'Web Sitesi', 790, CAST(0x0000A740008C1360 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (9, 6, N'PDKS', 790, CAST(0x0000A740008C1360 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (10, 6, N'E-Maski', 790, CAST(0x0000A740008C1360 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (11, 6, N'Portal', 790, CAST(0x0000A740008C1360 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (12, 6, N'Yerel Uygulamalar', 790, CAST(0x0000A740008C1360 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (13, 6, N'Diğer', 790, CAST(0x0000A74000000000 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (14, 6, N'Sistem', 790, CAST(0x0000A74000000000 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (15, 6, N'Teknik Servis', 790, CAST(0x0000A74000000000 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (17, 6, N'Maski Akademi', 790, CAST(0x0000A74000000000 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (19, 6, N'Kurumsal Fatura Yönetimi', 790, CAST(0x0000A789011BD4E0 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (21, 1062, N'QDMS Doküman İşlemleri', 790, CAST(0x0000A78A011BB8D0 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (22, 1062, N'QDMS DÖİF İşlemleri', 790, CAST(0x0000A78B011BB8D0 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (23, 1062, N'QDMS Alt Yapı İşlemleri', 790, CAST(0x0000A78C011BB8D0 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (24, 1062, N'Bilgi Yönetim Sistemi (BYS)', 790, CAST(0x0000A78D011BB8D0 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (25, 1062, N'Kurumsal Zeka', 790, CAST(0x0000A78E011BB8D0 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (26, 1062, N'Kalite Yönetim Sistemi', 790, CAST(0x0000A78F011BB8D0 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (27, 1062, N'Çevre Yönetim Sistemi', 790, CAST(0x0000A790011BB8D0 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (28, 1062, N'İSG Yönetim Sistemi', 790, CAST(0x0000A791011BB8D0 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (29, 1062, N'Müşteri Memnuniyeti ve Şikayet Yönetim Sistemi', 790, CAST(0x0000A792011BB8D0 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (30, 1062, N'Eğitim', 790, CAST(0x0000A793011BB8D0 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (31, 1062, N'Diğer', 790, CAST(0x0000A794011BB8D0 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (32, 1062, N'Dış Kaynaklı Dokümanlar', 774, CAST(0x0000A7AE0116A602 AS DateTime))
INSERT [work].[Project] ([Id], [UnitId], [Name], [CreatedBy], [CreatedDate]) VALUES (33, 6, N'E-MASKi Android', 790, CAST(0x0000A7B500AAB3B3 AS DateTime))
SET IDENTITY_INSERT [work].[Project] OFF
SET IDENTITY_INSERT [work].[Task] ON 

INSERT [work].[Task] ([Id], [ProjectId], [UnitId], [RequestedBy], [Title], [Description], [Queue], [RequestedDate], [Assigned], [TaskStatusId], [DueDate], [ResultContent], [Followers], [CreatedDate], [CreatedBy]) VALUES (10, 8, 6, 177, N'Yeni Site Performans iyileştirilmesi', N'Yeni Site Performans iyileştirilmesi', 1, CAST(0x0000A6F500E59D40 AS DateTime), 790, 38, CAST(0x0000A79800CE7B75 AS DateTime), NULL, NULL, CAST(0x0000A74300E8FF32 AS DateTime), 790)
INSERT [work].[Task] ([Id], [ProjectId], [UnitId], [RequestedBy], [Title], [Description], [Queue], [RequestedDate], [Assigned], [TaskStatusId], [DueDate], [ResultContent], [Followers], [CreatedDate], [CreatedBy]) VALUES (59, 11, 6, 193, N'İşlere Resimler Eklenebilmeli', N'Talep edilen işe resim eklenebilmeli.', 1, CAST(0x0000A7430119CCA0 AS DateTime), 790, 38, CAST(0x0000A74400BE1040 AS DateTime), NULL, NULL, CAST(0x0000A743011A4787 AS DateTime), 790)
INSERT [work].[Task] ([Id], [ProjectId], [UnitId], [RequestedBy], [Title], [Description], [Queue], [RequestedDate], [Assigned], [TaskStatusId], [DueDate], [ResultContent], [Followers], [CreatedDate], [CreatedBy]) VALUES (71, 11, 6, 733, N'Yeni İş Kaydında Mail Gönderilebilmeli', N'Yeni bir iş talebi olduğu zaman iş detayı ile alakalı bilgilendirme maili gönderilebilmeli.', 1, CAST(0x0000A7430119CCA0 AS DateTime), 790, 38, CAST(0x0000A74400C042C0 AS DateTime), NULL, NULL, CAST(0x0000A74400BEB69E AS DateTime), 790)
INSERT [work].[Task] ([Id], [ProjectId], [UnitId], [RequestedBy], [Title], [Description], [Queue], [RequestedDate], [Assigned], [TaskStatusId], [DueDate], [ResultContent], [Followers], [CreatedDate], [CreatedBy]) VALUES (494, 11, 6, 177, N'YBS-CRM Ambar Çıkış Karşılaştırma', NULL, 1, CAST(0x0000A79B00A74450 AS DateTime), 790, 36, NULL, NULL, N'193,180,183', CAST(0x0000A79B00A7C783 AS DateTime), 177)
INSERT [work].[Task] ([Id], [ProjectId], [UnitId], [RequestedBy], [Title], [Description], [Queue], [RequestedDate], [Assigned], [TaskStatusId], [DueDate], [ResultContent], [Followers], [CreatedDate], [CreatedBy]) VALUES (1662, 11, 6, 177, N'Yardım Masası Mobil', NULL, 1, CAST(0x0000A7B7009C47D0 AS DateTime), 790, 37, NULL, NULL, N'193', CAST(0x0000A7B700E05CB2 AS DateTime), 177)
SET IDENTITY_INSERT [work].[Task] OFF
SET IDENTITY_INSERT [work].[TaskHistory] ON 

INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (12, 10, 790, 36, CAST(0x0000A74300E8FF37 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (65, 59, 790, 36, CAST(0x0000A743011A47AB AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (91, 71, 790, 36, CAST(0x0000A74400BEBB60 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (92, 71, 790, 37, CAST(0x0000A74400BFEB55 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (93, 71, 790, 38, CAST(0x0000A74400C05D3D AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (1038, 10, 790, 38, CAST(0x0000A79800CE7B9B AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (1055, 494, 790, 36, CAST(0x0000A79B00A7C788 AS DateTime), 177)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11370, 1662, 790, 36, CAST(0x0000A7B700E05CB6 AS DateTime), 177)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11484, 1662, 790, 37, CAST(0x0000A7C000FCA21C AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11485, 1662, 790, 36, CAST(0x0000A7C0010A0643 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11486, 1662, 790, 37, CAST(0x0000A7C0010A0E90 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11487, 1662, 790, 36, CAST(0x0000A7C0010A179C AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11488, 1662, 790, 37, CAST(0x0000A7C0010A1B77 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11489, 1662, 790, 36, CAST(0x0000A7C0011419CB AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11490, 1662, 790, 37, CAST(0x0000A7C001141D44 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11491, 494, 790, 37, CAST(0x0000A7C600F3E8B1 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11492, 494, 790, 36, CAST(0x0000A7C600F3ED1D AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11493, 494, 790, 37, CAST(0x0000A7C600F3F464 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11494, 494, 790, 36, CAST(0x0000A7C600F3F999 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11495, 1662, 790, 38, CAST(0x0000A7C600F3FF0E AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11496, 1662, 790, 37, CAST(0x0000A7C600F400DD AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11497, 494, 790, 38, CAST(0x0000A7C600F84C71 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11498, 494, 790, 36, CAST(0x0000A7C600F84F33 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11499, 494, 790, 37, CAST(0x0000A7C600F85820 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11500, 494, 790, 36, CAST(0x0000A7C600F85AFE AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11501, 1662, 790, 38, CAST(0x0000A7C700CFF035 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11502, 1662, 790, 37, CAST(0x0000A7C700CFF643 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11503, 1662, 790, 36, CAST(0x0000A7C700D08E65 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11504, 494, 790, 37, CAST(0x0000A7C700D0904B AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11505, 494, 790, 36, CAST(0x0000A7C701173A99 AS DateTime), 790)
INSERT [work].[TaskHistory] ([Id], [TaskId], [Assigned], [TaskStatusId], [CreatedDate], [CreatedBy]) VALUES (11506, 1662, 790, 37, CAST(0x0000A7C7011900E1 AS DateTime), 790)
SET IDENTITY_INSERT [work].[TaskHistory] OFF
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_LookupList_Name]    Script Date: 6.08.2017 18:50:43 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LookupList_Name] ON [common].[LookupList]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_Person_UserName]    Script Date: 6.08.2017 18:50:43 ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Person_UserName] ON [common].[Person]
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [log].[TempRequestLog] ADD  CONSTRAINT [DF_RequestLog_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [common].[LookupList]  WITH CHECK ADD  CONSTRAINT [FK_LookupList_Lookup] FOREIGN KEY([LookupId])
REFERENCES [common].[Lookup] ([Id])
GO
ALTER TABLE [common].[LookupList] CHECK CONSTRAINT [FK_LookupList_Lookup]
GO
ALTER TABLE [common].[Person]  WITH CHECK ADD  CONSTRAINT [FK_Person_Unit] FOREIGN KEY([UnitId])
REFERENCES [common].[Unit] ([Id])
GO
ALTER TABLE [common].[Person] CHECK CONSTRAINT [FK_Person_Unit]
GO
ALTER TABLE [file].[Media]  WITH CHECK ADD  CONSTRAINT [FK_Media_LookupList] FOREIGN KEY([MediaTypeId])
REFERENCES [common].[LookupList] ([Id])
GO
ALTER TABLE [file].[Media] CHECK CONSTRAINT [FK_Media_LookupList]
GO
ALTER TABLE [file].[Media]  WITH CHECK ADD  CONSTRAINT [FK_Media_Person] FOREIGN KEY([CreatedBy])
REFERENCES [common].[Person] ([Id])
GO
ALTER TABLE [file].[Media] CHECK CONSTRAINT [FK_Media_Person]
GO
ALTER TABLE [log].[ExceptionLog]  WITH CHECK ADD  CONSTRAINT [FK_ExceptionLog_RequestLog] FOREIGN KEY([RequestId])
REFERENCES [log].[TempRequestLog] ([Id])
GO
ALTER TABLE [log].[ExceptionLog] CHECK CONSTRAINT [FK_ExceptionLog_RequestLog]
GO
ALTER TABLE [work].[Comment]  WITH CHECK ADD  CONSTRAINT [FK_Comment_Person] FOREIGN KEY([CommentedBy])
REFERENCES [common].[Person] ([Id])
GO
ALTER TABLE [work].[Comment] CHECK CONSTRAINT [FK_Comment_Person]
GO
ALTER TABLE [work].[Comment]  WITH CHECK ADD  CONSTRAINT [FK_Comment_Task] FOREIGN KEY([TaskId])
REFERENCES [work].[Task] ([Id])
GO
ALTER TABLE [work].[Comment] CHECK CONSTRAINT [FK_Comment_Task]
GO
ALTER TABLE [work].[Project]  WITH CHECK ADD  CONSTRAINT [FK_Project_Person] FOREIGN KEY([CreatedBy])
REFERENCES [common].[Person] ([Id])
GO
ALTER TABLE [work].[Project] CHECK CONSTRAINT [FK_Project_Person]
GO
ALTER TABLE [work].[Task]  WITH CHECK ADD  CONSTRAINT [FK_Task_LookupList] FOREIGN KEY([TaskStatusId])
REFERENCES [common].[LookupList] ([Id])
GO
ALTER TABLE [work].[Task] CHECK CONSTRAINT [FK_Task_LookupList]
GO
ALTER TABLE [work].[Task]  WITH CHECK ADD  CONSTRAINT [FK_Task_Person] FOREIGN KEY([CreatedBy])
REFERENCES [common].[Person] ([Id])
GO
ALTER TABLE [work].[Task] CHECK CONSTRAINT [FK_Task_Person]
GO
ALTER TABLE [work].[Task]  WITH CHECK ADD  CONSTRAINT [FK_Task_Person_Assigned] FOREIGN KEY([Assigned])
REFERENCES [common].[Person] ([Id])
GO
ALTER TABLE [work].[Task] CHECK CONSTRAINT [FK_Task_Person_Assigned]
GO
ALTER TABLE [work].[Task]  WITH CHECK ADD  CONSTRAINT [FK_Task_Person_RequestedBy] FOREIGN KEY([RequestedBy])
REFERENCES [common].[Person] ([Id])
GO
ALTER TABLE [work].[Task] CHECK CONSTRAINT [FK_Task_Person_RequestedBy]
GO
ALTER TABLE [work].[Task]  WITH CHECK ADD  CONSTRAINT [FK_Task_Project] FOREIGN KEY([ProjectId])
REFERENCES [work].[Project] ([Id])
GO
ALTER TABLE [work].[Task] CHECK CONSTRAINT [FK_Task_Project]
GO
ALTER TABLE [work].[TaskHistory]  WITH CHECK ADD  CONSTRAINT [FK_TaskHistory_LookupList] FOREIGN KEY([TaskStatusId])
REFERENCES [common].[LookupList] ([Id])
GO
ALTER TABLE [work].[TaskHistory] CHECK CONSTRAINT [FK_TaskHistory_LookupList]
GO
ALTER TABLE [work].[TaskHistory]  WITH CHECK ADD  CONSTRAINT [FK_TaskHistory_Person] FOREIGN KEY([CreatedBy])
REFERENCES [common].[Person] ([Id])
GO
ALTER TABLE [work].[TaskHistory] CHECK CONSTRAINT [FK_TaskHistory_Person]
GO
ALTER TABLE [work].[TaskHistory]  WITH CHECK ADD  CONSTRAINT [FK_TaskHistory_Person_Assigned] FOREIGN KEY([Assigned])
REFERENCES [common].[Person] ([Id])
GO
ALTER TABLE [work].[TaskHistory] CHECK CONSTRAINT [FK_TaskHistory_Person_Assigned]
GO
ALTER TABLE [work].[TaskHistory]  WITH CHECK ADD  CONSTRAINT [FK_TaskHistory_Task] FOREIGN KEY([TaskId])
REFERENCES [work].[Task] ([Id])
GO
ALTER TABLE [work].[TaskHistory] CHECK CONSTRAINT [FK_TaskHistory_Task]
GO
ALTER TABLE [work].[TaskMedia]  WITH CHECK ADD  CONSTRAINT [FK_TaskMedia_Media] FOREIGN KEY([MediaId])
REFERENCES [file].[Media] ([Id])
GO
ALTER TABLE [work].[TaskMedia] CHECK CONSTRAINT [FK_TaskMedia_Media]
GO
ALTER TABLE [work].[TaskMedia]  WITH CHECK ADD  CONSTRAINT [FK_TaskMedia_Person] FOREIGN KEY([CreatedBy])
REFERENCES [common].[Person] ([Id])
GO
ALTER TABLE [work].[TaskMedia] CHECK CONSTRAINT [FK_TaskMedia_Person]
GO
ALTER TABLE [work].[TaskMedia]  WITH CHECK ADD  CONSTRAINT [FK_TaskMedia_Task] FOREIGN KEY([TaskId])
REFERENCES [work].[Task] ([Id])
GO
ALTER TABLE [work].[TaskMedia] CHECK CONSTRAINT [FK_TaskMedia_Task]
GO

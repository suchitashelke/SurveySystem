USE [master]
GO
/****** Object:  Database [PollSystem]    Script Date: 3/14/2016 6:34:29 AM ******/
CREATE DATABASE [PollSystem]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'PollSystem', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\PollSystem.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'PollSystem_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\PollSystem_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [PollSystem] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PollSystem].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [PollSystem] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [PollSystem] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [PollSystem] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [PollSystem] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [PollSystem] SET ARITHABORT OFF 
GO
ALTER DATABASE [PollSystem] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [PollSystem] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [PollSystem] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [PollSystem] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [PollSystem] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [PollSystem] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [PollSystem] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [PollSystem] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [PollSystem] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [PollSystem] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [PollSystem] SET  DISABLE_BROKER 
GO
ALTER DATABASE [PollSystem] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [PollSystem] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [PollSystem] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [PollSystem] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [PollSystem] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [PollSystem] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [PollSystem] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [PollSystem] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [PollSystem] SET  MULTI_USER 
GO
ALTER DATABASE [PollSystem] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [PollSystem] SET DB_CHAINING OFF 
GO
ALTER DATABASE [PollSystem] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [PollSystem] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [PollSystem]
GO
/****** Object:  StoredProcedure [dbo].[spDeletePoll]    Script Date: 3/14/2016 6:34:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeletePoll] 
	@PollId smallint
AS
BEGIN  
	
	SET NOCOUNT ON;

	Declare @tblQuestionIds Table ( id int )

	Insert into @tblQuestionIds 
	Select Distinct Id from  [dbo].[PollQuestions] where PollId = 1

	Declare @tblAnswerIds Table ( id int )

	Insert into @tblAnswerIds 
	Select Distinct Id from  [dbo].[PollQuesAnswers] 
	where QuestionId in (select id from @tblQuestionIds)

	DELETE FROM [dbo].[UserAnswers]
    WHERE AnswerId in (select id from @tblAnswerIds)

	DELETE FROM [dbo].[PollQuesAnswers]
    WHERE Id in (select id from @tblAnswerIds)

	DELETE FROM [dbo].[PollQuestions]
    WHERE Id in (select id from @tblQuestionIds)

	DELETE FROM [dbo].[UserPoll]
    WHERE PollId = @PollId

	DELETE FROM [dbo].[Poll]
    WHERE Id = @PollId

END

GO
/****** Object:  StoredProcedure [dbo].[spDeleteQuestionAnswers]    Script Date: 3/14/2016 6:34:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDeleteQuestionAnswers] 
	@QuestionId smallint
AS
BEGIN  
	
	SET NOCOUNT ON;
	
	Declare @tblAnswerIds Table ( id int )

	Insert into @tblAnswerIds 
	Select Distinct Id from  [dbo].[PollQuesAnswers] 
	where QuestionId = @QuestionId

	DELETE FROM [dbo].[UserAnswers]
    WHERE AnswerId in (select id from @tblAnswerIds)

	DELETE FROM [dbo].[PollQuesAnswers]
    WHERE QuestionId = @QuestionId

	DELETE FROM [dbo].[PollQuestions]
    WHERE Id = @QuestionId

	

END

GO
/****** Object:  StoredProcedure [dbo].[spGetAnswerPercentage]    Script Date: 3/14/2016 6:34:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetAnswerPercentage] 
	@QuestionId smallint
AS
BEGIN  
	
	SET NOCOUNT ON;
	
	Declare @tblAnswerIds Table ( id smallint, answer varchar(2000) )
	Declare @tblUserIds Table ( id smallint, answerid smallint )
	Declare @cntUser int
	
	Insert into @tblAnswerIds 
	Select Distinct Id, AnswerText from  [dbo].[PollQuesAnswers] 
	where QuestionId = @QuestionId

	Insert into @tblUserIds 
	Select Id, AnswerId from  [dbo].[UserAnswers] 
	WHERE AnswerId in (select id from @tblAnswerIds)

	select @cntUser = count(*) from @tblUserIds
	
	select TblAnswer.id, answer, count(TblUser.id) * 100.0 / @cntUser as percentage
	from @tblAnswerIds TblAnswer inner join @tblUserIds TblUser
	on TblUser.answerid = TblAnswer.id
	group by TblAnswer.id, answer
END

GO
/****** Object:  StoredProcedure [dbo].[spGetQuestionsByPollId]    Script Date: 3/14/2016 6:34:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetQuestionsByPollId] 
	@PollId smallint
AS
BEGIN  
	
	Select Id, PollId, Question from [dbo].[PollQuestions] where PollId = @PollId

END

GO
/****** Object:  StoredProcedure [dbo].[spGetUserPoll]    Script Date: 3/14/2016 6:34:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetUserPoll]
	@UserId smallint
AS
BEGIN  
	
	SET NOCOUNT ON;

	Declare @tblPollIds Table ( id int )

	Insert into @tblPollIds 
	Select Distinct PollId from [dbo].[UserPoll] where UserId = @UserId

	select Id, Title, Description from Poll where Id not in (select id from @tblPollIds)

END

GO
/****** Object:  StoredProcedure [dbo].[spInsertQuestionAnswers]    Script Date: 3/14/2016 6:34:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertQuestionAnswers] 
	@PollId smallint,
	@Question varchar(2000),
	@Option1 varchar(2000),
	@Option2 varchar(2000),
	@Option3 varchar(2000),
	@Option4 varchar(2000)
AS
BEGIN
	
	SET NOCOUNT ON;

	INSERT INTO [dbo].[PollQuestions]([PollId], [Question])
    VALUES(@PollId, @Question)

	declare @QuestionId smallint
	select @QuestionId = SCOPE_IDENTITY();

	INSERT INTO [dbo].[PollQuesAnswers]([QuestionId],[AnswerText])
    VALUES(@QuestionId, @Option1)

	INSERT INTO [dbo].[PollQuesAnswers]([QuestionId],[AnswerText])
    VALUES(@QuestionId, @Option2)

	INSERT INTO [dbo].[PollQuesAnswers]([QuestionId],[AnswerText])
    VALUES(@QuestionId, @Option3)

	INSERT INTO [dbo].[PollQuesAnswers]([QuestionId],[AnswerText])
    VALUES(@QuestionId, @Option4)

END

GO
/****** Object:  StoredProcedure [dbo].[spInsertUserAnswers]    Script Date: 3/14/2016 6:34:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spInsertUserAnswers] 
	@UserId smallint,
	@AnswerIds varchar(max)
AS
BEGIN  
	
	SET NOCOUNT ON;

	Declare @tblAnswerIds Table ( id int identity, AnswerId smallint )

	insert into @tblAnswerIds
	select * from dbo.SplitString(@AnswerIds, ',')	

	declare @count int, @i int, @AnsId smallint;
	set @i = 1;
	select @count = count(*) from @tblAnswerIds;

	while @i < @count 
	begin
	select @AnsId = AnswerId from @tblAnswerIds where id = @i;
		
		INSERT INTO [dbo].[UserAnswers] values(@UserId, @AnsId);

		set @i = @i + 1;
	end

END

GO
/****** Object:  UserDefinedFunction [dbo].[SplitString]    Script Date: 3/14/2016 6:34:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[SplitString]
(    
      @Input NVARCHAR(MAX),
      @Character CHAR(1)
)
RETURNS @Output TABLE (
      Item NVARCHAR(1000)
)
AS
BEGIN
      DECLARE @StartIndex INT, @EndIndex INT
 
      SET @StartIndex = 1
      IF SUBSTRING(@Input, LEN(@Input) - 1, LEN(@Input)) <> @Character
      BEGIN
            SET @Input = @Input + @Character
      END
 
      WHILE CHARINDEX(@Character, @Input) > 0
      BEGIN
            SET @EndIndex = CHARINDEX(@Character, @Input)
           
            INSERT INTO @Output(Item)
            SELECT SUBSTRING(@Input, @StartIndex, @EndIndex - 1)
           
            SET @Input = SUBSTRING(@Input, @EndIndex + 1, LEN(@Input))
      END
 
      RETURN
END

GO
/****** Object:  Table [dbo].[Poll]    Script Date: 3/14/2016 6:34:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Poll](
	[Id] [smallint] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](500) NOT NULL,
	[Description] [varchar](2000) NULL,
 CONSTRAINT [PK_Poll] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PollQuesAnswers]    Script Date: 3/14/2016 6:34:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PollQuesAnswers](
	[Id] [smallint] IDENTITY(1,1) NOT NULL,
	[QuestionId] [smallint] NOT NULL,
	[AnswerText] [varchar](2000) NOT NULL,
 CONSTRAINT [PK_PollQuesAnswers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PollQuestions]    Script Date: 3/14/2016 6:34:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PollQuestions](
	[Id] [smallint] IDENTITY(1,1) NOT NULL,
	[PollId] [smallint] NOT NULL,
	[Question] [varchar](2000) NOT NULL,
 CONSTRAINT [PK_PollQuestions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[UserAnswers]    Script Date: 3/14/2016 6:34:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserAnswers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [smallint] NULL,
	[AnswerId] [smallint] NULL,
 CONSTRAINT [PK_UserAnswers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserPoll]    Script Date: 3/14/2016 6:34:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserPoll](
	[Id] [smallint] IDENTITY(1,1) NOT NULL,
	[UserId] [smallint] NOT NULL,
	[PollId] [smallint] NOT NULL,
 CONSTRAINT [PK_UserPoll] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserRoles]    Script Date: 3/14/2016 6:34:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[UserRoles](
	[Id] [smallint] IDENTITY(1,1) NOT NULL,
	[Role] [varchar](50) NOT NULL,
 CONSTRAINT [PK_UserRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Users]    Script Date: 3/14/2016 6:34:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [smallint] IDENTITY(1,1) NOT NULL,
	[RoleId] [smallint] NOT NULL,
	[Name] [varchar](100) NOT NULL,
	[EmailId] [varchar](200) NOT NULL,
	[Password] [varchar](50) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[PollQuesAnswers]  WITH CHECK ADD  CONSTRAINT [FK_PollQuesAnswers_PollQuestions] FOREIGN KEY([QuestionId])
REFERENCES [dbo].[PollQuestions] ([Id])
GO
ALTER TABLE [dbo].[PollQuesAnswers] CHECK CONSTRAINT [FK_PollQuesAnswers_PollQuestions]
GO
ALTER TABLE [dbo].[PollQuestions]  WITH CHECK ADD  CONSTRAINT [FK_PollQuestions_Poll] FOREIGN KEY([PollId])
REFERENCES [dbo].[Poll] ([Id])
GO
ALTER TABLE [dbo].[PollQuestions] CHECK CONSTRAINT [FK_PollQuestions_Poll]
GO
ALTER TABLE [dbo].[UserAnswers]  WITH CHECK ADD  CONSTRAINT [FK_UserAnswers_PollQuesAnswers] FOREIGN KEY([AnswerId])
REFERENCES [dbo].[PollQuesAnswers] ([Id])
GO
ALTER TABLE [dbo].[UserAnswers] CHECK CONSTRAINT [FK_UserAnswers_PollQuesAnswers]
GO
ALTER TABLE [dbo].[UserAnswers]  WITH CHECK ADD  CONSTRAINT [FK_UserAnswers_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[UserAnswers] CHECK CONSTRAINT [FK_UserAnswers_Users]
GO
ALTER TABLE [dbo].[UserPoll]  WITH CHECK ADD  CONSTRAINT [FK_UserPoll_Poll] FOREIGN KEY([PollId])
REFERENCES [dbo].[Poll] ([Id])
GO
ALTER TABLE [dbo].[UserPoll] CHECK CONSTRAINT [FK_UserPoll_Poll]
GO
ALTER TABLE [dbo].[UserPoll]  WITH CHECK ADD  CONSTRAINT [FK_UserPoll_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[UserPoll] CHECK CONSTRAINT [FK_UserPoll_Users]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD  CONSTRAINT [FK_Users_UserRoles] FOREIGN KEY([RoleId])
REFERENCES [dbo].[UserRoles] ([Id])
GO
ALTER TABLE [dbo].[Users] CHECK CONSTRAINT [FK_Users_UserRoles]
GO
USE [master]
GO
ALTER DATABASE [PollSystem] SET  READ_WRITE 
GO

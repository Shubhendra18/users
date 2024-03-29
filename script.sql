USE [master]
GO
/****** Object:  Database [DEMODB]    Script Date: 11/18/2019 5:43:23 PM ******/
CREATE DATABASE [DEMODB] ON  PRIMARY 
( NAME = N'DEMODB', FILENAME = N'G:\sql_db\DEMODB.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'DEMODB_log', FILENAME = N'G:\sql_db\DEMODB_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [DEMODB] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DEMODB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [DEMODB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [DEMODB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [DEMODB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [DEMODB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [DEMODB] SET ARITHABORT OFF 
GO
ALTER DATABASE [DEMODB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [DEMODB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [DEMODB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [DEMODB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [DEMODB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [DEMODB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [DEMODB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [DEMODB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [DEMODB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [DEMODB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [DEMODB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [DEMODB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [DEMODB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [DEMODB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [DEMODB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [DEMODB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [DEMODB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [DEMODB] SET RECOVERY FULL 
GO
ALTER DATABASE [DEMODB] SET  MULTI_USER 
GO
ALTER DATABASE [DEMODB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [DEMODB] SET DB_CHAINING OFF 
GO
EXEC sys.sp_db_vardecimal_storage_format N'DEMODB', N'ON'
GO
USE [DEMODB]
GO
/****** Object:  Table [dbo].[AspNetRoles]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoles](
	[Id] [nvarchar](128) NOT NULL,
	[Name] [nvarchar](256) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserClaims]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.AspNetUserClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserLogins]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserLogins](
	[LoginProvider] [nvarchar](128) NOT NULL,
	[ProviderKey] [nvarchar](128) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUserLogins] PRIMARY KEY CLUSTERED 
(
	[LoginProvider] ASC,
	[ProviderKey] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserRoles]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserRoles](
	[UserId] [nvarchar](128) NOT NULL,
	[RoleId] [nvarchar](128) NOT NULL,
 CONSTRAINT [PK_dbo.AspNetUserRoles] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUsers]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUsers](
	[Id] [nvarchar](128) NOT NULL,
	[Email] [nvarchar](256) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[LockoutEndDateUtc] [datetime] NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
	[UserName] [nvarchar](256) NOT NULL,
	[FirstName] [nvarchar](256) NULL,
	[LastName] [nvarchar](256) NULL,
 CONSTRAINT [PK_dbo.AspNetUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ComposeMail]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ComposeMail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Priority] [int] NULL,
	[SMSAlert] [bit] NULL,
	[ToUser] [varchar](50) NULL,
	[Subject] [varchar](50) NULL,
	[Message] [varchar](max) NULL,
 CONSTRAINT [PK_ComposeMail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Employees]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Employees](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[Address] [varchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Fruits]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Fruits](
	[FruitId] [int] IDENTITY(1,1) NOT NULL,
	[FruitName] [nchar](10) NOT NULL,
 CONSTRAINT [PK_Fruits] PRIMARY KEY CLUSTERED 
(
	[FruitId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblEmployee]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblEmployee](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[Filepath] [varchar](max) NULL,
 CONSTRAINT [PK_tblEmployee] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Users]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[UserName] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[AspNetRoles] ([Id], [Name]) VALUES (N'1', N'Admin')
INSERT [dbo].[AspNetRoles] ([Id], [Name]) VALUES (N'2', N'User')
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'91c712c2-2044-43e1-b127-1a8e09a8fe36', N'2')
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'd196c9ac-a0f2-4fc1-83ab-bc1066a15476', N'1')
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName], [FirstName], [LastName]) VALUES (N'91c712c2-2044-43e1-b127-1a8e09a8fe36', N'u@gmail.com', 0, N'AD0MJPfSkARNESHrIUKjBj+0fh7vJmiXPwKHOfLhqo0bvMGlu47kD9XUo1HO+IsrHw==', N'b76f1e8c-cdac-413b-bd60-58c7ab5231ca', NULL, 0, 0, NULL, 0, 0, N'user', N'kavita', N'singh')
INSERT [dbo].[AspNetUsers] ([Id], [Email], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEndDateUtc], [LockoutEnabled], [AccessFailedCount], [UserName], [FirstName], [LastName]) VALUES (N'd196c9ac-a0f2-4fc1-83ab-bc1066a15476', N'amit@gmail.com', 0, N'AIa/G9d3iTHwYDzt6bp9zGESkoa83gitmlQYlbByUWaYaH+Qh8JvoCC3W7Y1knjmKA==', N'ffb4f62b-f7f1-4932-8a2b-1b674e8778e3', NULL, 0, 0, NULL, 0, 0, N'amt', N'Amit', N'Singh')
SET IDENTITY_INSERT [dbo].[ComposeMail] ON 

INSERT [dbo].[ComposeMail] ([Id], [Priority], [SMSAlert], [ToUser], [Subject], [Message]) VALUES (4, 1, 0, N'44', N'Hello User', N'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed')
INSERT [dbo].[ComposeMail] ([Id], [Priority], [SMSAlert], [ToUser], [Subject], [Message]) VALUES (5, 0, 0, N'44', N'About Your Phone', N'Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for ''lorem ipsum')
SET IDENTITY_INSERT [dbo].[ComposeMail] OFF
SET IDENTITY_INSERT [dbo].[Employees] ON 

INSERT [dbo].[Employees] ([Id], [Name], [Address]) VALUES (1, N'Mukesh Kumar', N'New Delhi')
INSERT [dbo].[Employees] ([Id], [Name], [Address]) VALUES (2, N'John Right', N'England')
INSERT [dbo].[Employees] ([Id], [Name], [Address]) VALUES (3, N'Chris Roy', N'France')
INSERT [dbo].[Employees] ([Id], [Name], [Address]) VALUES (4, N'Anand Mahajan', N'Canada')
INSERT [dbo].[Employees] ([Id], [Name], [Address]) VALUES (5, N'Prince Singh', N'India')
SET IDENTITY_INSERT [dbo].[Employees] OFF
SET IDENTITY_INSERT [dbo].[Fruits] ON 

INSERT [dbo].[Fruits] ([FruitId], [FruitName]) VALUES (1, N'Mango     ')
INSERT [dbo].[Fruits] ([FruitId], [FruitName]) VALUES (2, N'Orange    ')
INSERT [dbo].[Fruits] ([FruitId], [FruitName]) VALUES (3, N'Banana    ')
SET IDENTITY_INSERT [dbo].[Fruits] OFF
SET IDENTITY_INSERT [dbo].[tblEmployee] ON 

INSERT [dbo].[tblEmployee] ([Id], [Name], [Filepath]) VALUES (1, N'uuu', N'~/Uploads/E:\Virendra_03292019\DemoProject\DemoProject\Uploads\Pending_En.xlsx')
INSERT [dbo].[tblEmployee] ([Id], [Name], [Filepath]) VALUES (2, N'jj', N'~/Uploads/Old New Connection Data.xlsx')
SET IDENTITY_INSERT [dbo].[tblEmployee] OFF
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([Id], [Name], [UserName], [Password]) VALUES (1, N'Mukesh Kumar', N'Mukesh', N'AAAAAA')
SET IDENTITY_INSERT [dbo].[Users] OFF
ALTER TABLE [dbo].[AspNetUserClaims]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserClaims] CHECK CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserLogins]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserLogins] CHECK CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId]
GO
/****** Object:  StoredProcedure [dbo].[sp_ComposeMail]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[sp_ComposeMail]
@priority INT,
@smsalert BIT,
@to VARCHAR(50),
@subject VARCHAR(50),
@message VARCHAR(50)
AS
BEGIN
INSERT INTO dbo.ComposeMail
        ( Priority ,
          SMSAlert ,
          ToUser ,
          Subject ,
          Message
        )
VALUES  ( @priority , -- Priority - int
          @smsalert , -- SMSAlert - bit
          @to , -- ToUser - varchar(50)
          @subject , -- Subject - varchar(50)
          @message  -- Message - varchar(50)
        )
		  DECLARE @id INT 
                SET @id = ( SELECT  SCOPE_IDENTITY()
                          )
                  SELECT  
				  Id,
					  Priority,
				ToUser,
				SMSAlert,
				Subject,
				Message
                FROM    dbo.ComposeMail
                WHERE   ID = @id
END



GO
/****** Object:  StoredProcedure [dbo].[sp_Createuser]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_Createuser]
@Name VARCHAR(50),
@Address VARCHAR(50),
@Email VARCHAR(50),
@Password VARCHAR(50)
AS
BEGIN
INSERT INTO dbo.Users
        ( Name, Address, Email, Password )
VALUES  (  @Name, -- Name - varchar(50)
          @Address, -- Address - varchar(50)
          @Email, -- Email - varchar(50)
          @Password  -- Password - varchar(50)
          )
		  DECLARE @id int 
                SET @id = ( SELECT  SCOPE_IDENTITY()
                          )
                  SELECT  
				  Id,
					  Name,
				Address,
				Email,
				Password
                FROM    dbo.Users
                WHERE   ID = @id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_GetMails]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[sp_GetMails]
AS
BEGIN
SELECT * FROM dbo.ComposeMail 
END


GO
/****** Object:  StoredProcedure [dbo].[sp_userlist]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_userlist]
AS
BEGIN
SELECT * FROM dbo.Users 
END

GO
/****** Object:  StoredProcedure [dbo].[sp_UserLogin]    Script Date: 11/18/2019 5:43:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_UserLogin]
@email VARCHAR(50),
@password VARCHAR(100)
AS
BEGIN
SELECT * FROM dbo.Users u WHERE u.Email=@email AND u.Password=@password
END

GO
USE [master]
GO
ALTER DATABASE [DEMODB] SET  READ_WRITE 
GO

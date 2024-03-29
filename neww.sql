USE [master]
GO
/****** Object:  Database [GWDUP]    Script Date: 10/18/2019 6:00:15 PM ******/
CREATE DATABASE [GWDUP] ON  PRIMARY 
( NAME = N'GWDUP', FILENAME = N'G:\sql_db\GWDUP.mdf' , SIZE = 3072KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'GWDUP_log', FILENAME = N'G:\sql_db\GWDUP_log.ldf' , SIZE = 1280KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [GWDUP] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [GWDUP].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [GWDUP] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [GWDUP] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [GWDUP] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [GWDUP] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [GWDUP] SET ARITHABORT OFF 
GO
ALTER DATABASE [GWDUP] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [GWDUP] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [GWDUP] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [GWDUP] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [GWDUP] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [GWDUP] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [GWDUP] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [GWDUP] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [GWDUP] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [GWDUP] SET  DISABLE_BROKER 
GO
ALTER DATABASE [GWDUP] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [GWDUP] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [GWDUP] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [GWDUP] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [GWDUP] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [GWDUP] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [GWDUP] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [GWDUP] SET RECOVERY FULL 
GO
ALTER DATABASE [GWDUP] SET  MULTI_USER 
GO
ALTER DATABASE [GWDUP] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [GWDUP] SET DB_CHAINING OFF 
GO
EXEC sys.sp_db_vardecimal_storage_format N'GWDUP', N'ON'
GO
USE [GWDUP]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGenerateDrillingRegNo]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT dbo.fnGenerateDrillingRegNo ( )
CREATE FUNCTION [dbo].[fnGenerateDrillingRegNo] ( )
RETURNS VARCHAR(20)
AS
    BEGIN
        DECLARE @regNo VARCHAR(50)= 'DRL';
        DECLARE @year VARCHAR(10)= RIGHT(DATEPART(YEAR, GETDATE()), 2);

        SET @regNo = @regNo + @year;
        IF NOT EXISTS ( SELECT  1
                        FROM    dbo.T_DrillingRegistration
                        WHERE   AppNo LIKE @regNo + '%' )
            SET @regNo = @regNo + '00001';
        ELSE
            SET @regNo = @regNo + RIGHT('00000'
                                        + CAST(( SELECT RIGHT(MAX(AppNo), 5)
                                                 FROM   dbo.T_DrillingRegistration
                                                 WHERE  AppNo LIKE @regNo
                                                        + '%'
                                               ) + 1 AS VARCHAR), 5);

 

        RETURN @regNo;
 
    END;

GO
/****** Object:  UserDefinedFunction [dbo].[fnGenerateTempReg]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGenerateTempReg] ( )
RETURNS VARCHAR(20)
AS
    BEGIN
        DECLARE @regNo VARCHAR(50);
        DECLARE @year VARCHAR(10)= RIGHT(DATEPART(YEAR, GETDATE()), 2);

        IF NOT EXISTS ( SELECT  1
                        FROM    dbo.T_TempDrillingReg
                        WHERE   TempRegNo LIKE @year + '%' )
            SET @regNo = @year + '00001';
        ELSE
            SET @regNo = ( SELECT   MAX(TempRegNo)
                           FROM     dbo.T_TempDrillingReg
                           WHERE    TempRegNo LIKE @year + '%'
                         ) + 1;

        RETURN @regNo;
 
    END;
GO
/****** Object:  UserDefinedFunction [dbo].[fnStringList2Table]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE FUNCTION [dbo].[fnStringList2Table]    
(    
    @List VARCHAR(MAX)    
)    
RETURNS     
@ParsedList TABLE    
(    
    item INT    
)    
AS    
BEGIN    
    DECLARE @item VARCHAR(800), @Pos INT    
    
    SET @List = LTRIM(RTRIM(@List))+ ','    
    SET @Pos = CHARINDEX(',', @List, 1)    
    
    WHILE @Pos > 0    
    BEGIN    
        SET @item = LTRIM(RTRIM(LEFT(@List, @Pos - 1)))    
        IF @item <> ''    
        BEGIN    
            INSERT INTO @ParsedList (item)     
            VALUES (CAST(@item AS INT))    
        END    
        SET @List = RIGHT(@List, LEN(@List) - @Pos)    
        SET @Pos = CHARINDEX(',', @List, 1)    
    END    
    
    RETURN    
END    
    

GO
/****** Object:  UserDefinedFunction [dbo].[GenerateAppNo]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GenerateAppNo] ( @DistrictID INT,@FormTypeID INT,@UserCategoryID INT )
RETURNS VARCHAR(20)
AS -- Returns the AppNo District Wise.  
    BEGIN  
        DECLARE @appNo VARCHAR(20);
		DECLARE @ServiceCode VARCHAR(5)
		DECLARE @CategoryCode VARCHAR(5)
		SET @ServiceCode=(SELECT CASE WHEN @FormTypeID=22 THEN 'N'  WHEN @FormTypeID=23 THEN 'R' WHEN @FormTypeID=32 THEN 'D'END ) 
		SET @CategoryCode=(SELECT CASE WHEN @UserCategoryID=26 THEN 'DO' WHEN @UserCategoryID=27 THEN 'AG' WHEN @UserCategoryID=28 THEN 'CO' WHEN @UserCategoryID=29 THEN 'IN' WHEN @UserCategoryID=30 THEN 'IF' WHEN @UserCategoryID=31 THEN 'BU' END)
        SET @appNo = ( SELECT   ( b.DistrictCode+ RIGHT('00'+ CONVERT(VARCHAR(5), MONTH(GETDATE()), 2), 2)+ CONVERT(VARCHAR(10), RIGHT(YEAR(GETDATE()),2))+@ServiceCode+ @CategoryCode + RIGHT('0000'+ CONVERT(VARCHAR(4), ( ISNULL(MAX(RIGHT(AppNo,4)), 0) + 1 ), 4),4) ) AS AppNo
                       FROM     [dbo].[M_Registration] r
                                RIGHT JOIN [dbo].[M_District] b ON r.RDistrictID = b.DistrictID
                       WHERE    b.DistrictID = @DistrictID AND r.FormTypeID=@FormTypeID AND r.PurposeOfWellID=@UserCategoryID
					    --AND YEAR(r.CreatedOn)=YEAR(GETDATE()) AND MONTH(r.CreatedOn)=MONTH(GETDATE())
                       GROUP BY b.DistrictCode
                     );
        RETURN @appNo; 
    END; 

GO
/****** Object:  Table [dbo].[AdminMaster]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AdminMaster](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](150) NULL,
	[Password] [nvarchar](500) NULL,
	[DisplayPassword] [varchar](50) NOT NULL,
	[IsPassWordChange] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[FirstLogin] [bit] NULL,
	[LastLoginTime] [datetime] NULL,
	[LastLoginIP] [varchar](50) NULL,
	[WrongAttempt] [int] NULL,
	[IsActive] [bit] NULL,
	[Rollid] [int] NULL,
	[Mobile] [nvarchar](50) NULL,
	[Email] [nvarchar](50) NULL,
	[RefId] [bigint] NULL,
 CONSTRAINT [PK_AdminMaster] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Block]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Block](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](50) NULL,
	[Name] [varchar](50) NULL,
 CONSTRAINT [PK_Block] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CommonTable]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CommonTable](
	[CommonID] [smallint] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[Description] [nvarchar](150) NULL,
	[TypeID] [varchar](20) NULL,
	[IsDeleted] [bit] NULL,
 CONSTRAINT [PK_CommonTable] PRIMARY KEY CLUSTERED 
(
	[CommonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[M_Block]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[M_Block](
	[BlockID] [int] IDENTITY(1,1) NOT NULL,
	[DistrictID] [int] NOT NULL,
	[BlockCode] [varchar](10) NULL,
	[BlockName] [varchar](50) NULL,
	[BlockNameHindi] [nvarchar](50) NULL,
	[Status] [varchar](50) NULL,
 CONSTRAINT [PK_Blocks] PRIMARY KEY CLUSTERED 
(
	[BlockID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[M_District]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[M_District](
	[DistrictID] [int] IDENTITY(1,1) NOT NULL,
	[StateID] [int] NOT NULL,
	[DistrictCode] [varchar](10) NULL,
	[DistrictName] [varchar](100) NULL,
	[DistrictNameHindi] [nvarchar](100) NULL,
	[SortOrder] [int] NULL,
 CONSTRAINT [PK_M_District] PRIMARY KEY CLUSTERED 
(
	[DistrictID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[M_Registration]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[M_Registration](
	[RegistrationID] [bigint] IDENTITY(1,1) NOT NULL,
	[AppNo] [varchar](20) NULL,
	[FormTypeID] [smallint] NULL,
	[UserCategoryID] [smallint] NOT NULL,
	[UserTypeID] [smallint] NOT NULL,
	[RDistrictID] [smallint] NOT NULL,
	[RBlockID] [smallint] NOT NULL,
	[MobileNo] [nvarchar](50) NOT NULL,
	[EmailID] [varchar](150) NULL,
	[ApplicantName] [varchar](200) NOT NULL,
	[OTP] [varchar](50) NULL,
	[IsMobileVerified] [bit] NULL,
	[HaveNOC] [bit] NULL,
	[GWDCertificate] [bit] NULL,
	[ApplicationDate] [datetime] NULL,
	[OwnerName] [nvarchar](200) NULL,
	[DateOfBirth] [datetime] NULL,
	[CareOF] [nvarchar](200) NULL,
	[Gender] [smallint] NULL,
	[Nationality] [nvarchar](50) NULL,
	[Address] [nvarchar](200) NULL,
	[StateID] [smallint] NULL,
	[DistrictID] [smallint] NULL,
	[Pincode] [nvarchar](15) NULL,
	[P_DistrictID] [smallint] NULL,
	[P_BlockID] [smallint] NULL,
	[PlotKhasraNo] [nvarchar](50) NULL,
	[IDProofID] [smallint] NULL,
	[IDNumber] [nvarchar](50) NULL,
	[IDPath] [nvarchar](500) NULL,
	[MunicipalityCorporation] [nvarchar](50) NULL,
	[WardHoldingNo] [nvarchar](50) NULL,
	[DateOfConstruction] [datetime] NULL,
	[TypeOfTheWellID] [smallint] NULL,
	[DepthOfTheWell] [decimal](10, 2) NULL,
	[IsAdverseReport] [bit] NULL,
	[WaterQuality] [nvarchar](500) NULL,
	[TypeOfPumpID] [smallint] NULL,
	[LengthColumnPipe] [decimal](10, 2) NULL,
	[PumpCapacity] [decimal](10, 2) NULL,
	[HorsePower] [decimal](6, 2) NULL,
	[OperationalDeviceID] [smallint] NULL,
	[DateOfEnergization] [datetime] NULL,
	[PurposeOfWellID] [smallint] NULL,
	[AnnualRunningHours] [decimal](10, 2) NULL,
	[DailyRunningHours] [decimal](10, 2) NULL,
	[IsPipedWaterSupply] [bit] NULL,
	[ModeOfTreatment] [nvarchar](200) NULL,
	[IsObtainedNOC_UP] [bit] NULL,
	[IsRainWaterHarvesting] [bit] NULL,
	[Remarks] [nvarchar](500) NULL,
	[IAgree] [bit] NULL,
	[IsPaymentDone] [bit] NULL,
	[IPAddress] [varchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[LastModifiedOn] [datetime] NULL,
	[IsDeleted] [bit] NULL,
	[IsActive] [bit] NULL,
	[Relation] [int] NULL,
	[DiameterOfDugWell] [decimal](10, 2) NULL,
	[ApproxLengthOfPipe] [decimal](10, 2) NULL,
	[ApproxDiameterOfPipe] [decimal](10, 2) NULL,
	[ApproxLengthOfStrainer] [decimal](10, 2) NULL,
	[ApproxDiameterOfStrainer] [decimal](10, 2) NULL,
	[MaterialOfPipe] [int] NULL,
	[MaterialOfStrainer] [int] NULL,
	[StructureofdugWell] [int] NULL,
	[IfAny] [varchar](50) NULL,
	[RegCertificateIssueByGWD] [bit] NULL,
	[RegCertificateNumber] [varchar](50) NULL,
	[DateOfRegCertificateIssuance] [datetime] NULL,
	[DateOfRegCertificateExpiry] [datetime] NULL,
	[RegCertificatePath] [varchar](max) NULL,
	[CentralGroundWaterAuthority] [bit] NULL,
	[DateOfNOCIssuanceByCGWD] [datetime] NULL,
	[DateOfNOCExpiryByCGWD] [datetime] NULL,
	[NOCByCGWDCertificatePath] [varchar](max) NULL,
	[NOCCertificateNumberByCGWD] [nvarchar](50) NULL,
	[StepNo] [int] NULL CONSTRAINT [DF__M_Registr__StepN__72C60C4A]  DEFAULT ((0)),
	[RHaveNocByGWD] [bit] NULL,
 CONSTRAINT [PK_M_Registration] PRIMARY KEY CLUSTERED 
(
	[RegistrationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[M_State]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[M_State](
	[StateID] [int] IDENTITY(1,1) NOT NULL,
	[CountryID] [int] NULL,
	[StateName] [varchar](100) NULL,
	[StateNameHindi] [nvarchar](100) NULL,
	[IsDeleted] [bit] NULL,
	[SortOrder] [int] NULL,
 CONSTRAINT [PK_M_State] PRIMARY KEY CLUSTERED 
(
	[StateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Sec_UserMaster]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Sec_UserMaster](
	[UserID] [bigint] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](150) NULL,
	[Password] [nvarchar](500) NULL,
	[DisplayPassword] [varchar](50) NOT NULL,
	[AppNo] [varchar](15) NULL,
	[IsPassWordChange] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[FirstLogin] [bit] NULL,
	[LastLoginTime] [datetime] NULL,
	[LastLoginIP] [varchar](50) NULL,
	[WrongAttempt] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[IsActive] [bit] NULL,
	[RegistrationID] [bigint] NULL,
 CONSTRAINT [PK_Sec_UserMaster] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_DrillingDistrictMachine]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_DrillingDistrictMachine](
	[AutoId] [bigint] IDENTITY(1,1) NOT NULL,
	[RegId] [bigint] NOT NULL,
	[AppNo] [varchar](50) NOT NULL,
	[DistrictId] [int] NULL,
	[DrillingMachineDetail] [varchar](300) NULL,
	[DrillingPurposeId] [varchar](10) NULL,
	[Isdeleted] [bit] NULL CONSTRAINT [DF_T_DistrictMachine_Isdeleted]  DEFAULT ((0)),
	[TransDate] [datetime] NULL CONSTRAINT [DF_T_DistrictMachine_TransDate]  DEFAULT (getdate()),
	[TransIPAddress] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_DrillingRegistration]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_DrillingRegistration](
	[RegId] [bigint] IDENTITY(1,1) NOT NULL,
	[AppNo] [varchar](50) NOT NULL,
	[TempRegNo] [varchar](50) NULL,
	[UserTypeId] [int] NULL,
	[CompanyName] [varchar](200) NULL,
	[ApplicantName] [varchar](50) NULL,
	[FirmRegNo] [varchar](50) NULL,
	[FirmGSTNo] [varchar](30) NULL,
	[FirmPanNo] [varchar](10) NULL,
	[MobileNo] [varchar](10) NULL,
	[EmailId] [varchar](50) NULL,
	[TransDate] [datetime] NULL CONSTRAINT [DF_T_DrillingRegistration_TransDate]  DEFAULT (getdate()),
	[Isdeleted] [bit] NULL CONSTRAINT [DF_T_DrillingRegistration_Isdeleted]  DEFAULT ((0)),
	[IPAddress] [varchar](50) NULL,
	[OwnerName] [varchar](50) NULL,
	[SpouseTitle] [varchar](10) NULL,
	[SpouseWardName] [varchar](50) NULL,
	[DOB] [datetime] NULL,
	[Gender] [varchar](1) NULL,
	[Nationality] [varchar](1) NULL,
	[PanCardPath] [varchar](400) NULL,
	[GSTCertificatePath] [varchar](400) NULL,
	[Address] [varchar](150) NULL,
	[StateId] [int] NULL,
	[DistrictId] [int] NULL,
	[Pincode] [varchar](6) NULL,
	[StepNo] [int] NULL,
	[RegIPAddress] [varchar](50) NULL,
	[RegDate] [datetime] NULL,
 CONSTRAINT [PK_T_DrillingRegistration] PRIMARY KEY CLUSTERED 
(
	[AppNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_TempDrillingReg]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_TempDrillingReg](
	[autoId] [bigint] IDENTITY(1,1) NOT NULL,
	[TempRegNo] [varchar](50) NULL,
	[UserTypeId] [int] NULL,
	[CompanyName] [varchar](200) NULL,
	[ApplicantName] [varchar](50) NULL,
	[FirmRegNo] [varchar](50) NULL,
	[FirmGSTNo] [varchar](30) NULL,
	[FirmPanNo] [varchar](10) NULL,
	[MobileNo] [varchar](10) NULL,
	[EmailId] [varchar](50) NULL,
	[OTP] [varchar](10) NULL,
	[OTPDate] [datetime] NULL,
	[TransDate] [datetime] NULL CONSTRAINT [DF_T_TempDrillingReg_TransDate]  DEFAULT (getdate()),
	[Isdeleted] [bit] NULL CONSTRAINT [DF_T_TempDrillingReg_Isdeleted]  DEFAULT ((0)),
	[IPAddress] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblAssignedBlock]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAssignedBlock](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UId] [int] NULL,
	[BlockId] [int] NULL,
	[DistrictRefid] [int] NULL,
 CONSTRAINT [PK_tblAssignedBlock] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tbleBlockUserMaster]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tbleBlockUserMaster](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](50) NULL,
	[Password] [nvarchar](50) NULL,
	[DisplayPassword] [nvarchar](50) NULL,
	[Mobile] [varchar](50) NULL,
	[Email] [nvarchar](50) NULL,
	[IsPassWordChange] [bit] NULL,
	[IsDeleted] [bit] NULL,
	[FirstLogin] [bit] NULL,
	[LastLoginTime] [datetime] NULL,
	[LastLoginIP] [nvarchar](50) NULL,
	[WrongAttempt] [int] NULL,
	[IsActive] [bit] NULL,
	[Rollid] [int] NULL,
	[CreatedOn] [datetime] NULL,
 CONSTRAINT [PK_tbleBlockUserMaster] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblRollMaster]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblRollMaster](
	[Id] [int] NOT NULL,
	[RollName] [varchar](50) NULL,
 CONSTRAINT [PK_tblRollMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[AdminMaster] ON 

INSERT [dbo].[AdminMaster] ([ID], [UserName], [Password], [DisplayPassword], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [IsActive], [Rollid], [Mobile], [Email], [RefId]) VALUES (3, N'admin', N'21232F297A57A5A743894A0E4A801FC3', N'admin', NULL, 0, NULL, CAST(N'2019-10-15 17:32:58.400' AS DateTime), N'::1', NULL, 1, 1, N'9362514785', N'admin@gmail.com', 0)
INSERT [dbo].[AdminMaster] ([ID], [UserName], [Password], [DisplayPassword], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [IsActive], [Rollid], [Mobile], [Email], [RefId]) VALUES (4, N'Lucknow', N'A8C337E0D23E4937EDD0BC47ACD6AB21', N'Lucknow', NULL, 0, NULL, CAST(N'2019-10-18 17:48:14.353' AS DateTime), N'::1', NULL, 1, 2, N'9245784521', N'lucknow@gmail.com', 613)
INSERT [dbo].[AdminMaster] ([ID], [UserName], [Password], [DisplayPassword], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [IsActive], [Rollid], [Mobile], [Email], [RefId]) VALUES (8, N'Kanpur Nagar', N'0823C62779158494703EA3894FA8023E', N'Kanpur Nagar', NULL, 0, NULL, CAST(N'2019-10-16 17:42:43.603' AS DateTime), N'::1', NULL, 1, 2, N'9245784521', N'lucknow@gmail.com', 607)
SET IDENTITY_INSERT [dbo].[AdminMaster] OFF
SET IDENTITY_INSERT [dbo].[Block] ON 

INSERT [dbo].[Block] ([ID], [Code], [Name]) VALUES (1, N'ASBF', N'ABCDdd    ')
INSERT [dbo].[Block] ([ID], [Code], [Name]) VALUES (2, N'SDER', N'GGHTY')
SET IDENTITY_INSERT [dbo].[Block] OFF
SET IDENTITY_INSERT [dbo].[CommonTable] ON 

INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (1, N'Proposed Well', N'User Type', N'UT', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (2, N'Existing Well', N'User Type', N'UT', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (3, N'Aadhaar Card', N'ID Type', N'IDT', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (4, N'Electricity Bill', N'ID Type', N'IDT', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (5, N'Driving License', N'ID Type', N'IDT', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (6, N'Dug Well', N'Type Of Well', N'TW', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (7, N'Tube Well', N'Type Of Well', N'TW', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (8, N'Boring', N'Type Of Well', N'TW', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (9, N'Others', N'Type Of Well', N'TW', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (10, N'Centrifugal', N'Type of pump to be used', N'TP', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (11, N'Submersible', N'Type of pump to be used', N'TP', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (12, N'Turbine', N'Type of pump to be used', N'TP', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (13, N'Ejectro pump', N'Type of pump to be used', N'TP', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (14, N'Other pump', N'Type of pump to be used', N'TP', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (15, N'Electric Motor', N'Oprational Device', N'OD', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (16, N'Diesel Engine', N'Oprational Device', N'OD', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (17, N'Industrial', N'Purpose of the proposed well', N'PW', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (18, N'Commercial', N'Purpose of the proposed well', N'PW', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (19, N'Infrastructural', N'Purpose of the proposed well', N'PW', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (20, N'Bulk use', N'Purpose of the proposed well', N'PW', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (21, N'Others', N'Purpose of the proposed well', N'PW', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (22, N'NOC', N'NO OBJECTION CERTIFICATE', N'FT', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (23, N'Registration', N'Registration', N'FT', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (24, N'Domestic/Agricultural', N'Domestic/Agricultural', N'UC', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (25, N'Commercial/Industrial/Infrastructural/Bulk User', N'Commercial/Industrial/Infrastructural/Bulk User', N'UC', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (26, N'Domestic', N'Domestic', N'USC1', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (27, N'Agricultural', N'Agricultural', N'USC1', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (28, N'Commercial', N'Commercial', N'USC2', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (29, N'Industrial', N'Industrial', N'USC2', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (30, N'Infrastructural', N'Infrastructural', N'USC2', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (31, N'Bulk User', N'Bulk User', N'USC2', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (32, N'Drilling Agency', N'Registration', N'FT', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (33, N'Male', N'Male', N'GN', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (34, N'Female', N'Female', N'GN', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (35, N'Indian', N'Indian', N'NT', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (36, N'Other', N'Other', N'NT', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (37, N'PVC', N'PVC', N'TM', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (38, N'Iron', N'Iron', N'TM', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (39, N'Galvanized Iron', N'Galvanized Iron', N'TM', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (41, N'Son of', N'Son', N'RN', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (42, N'Daughter of', N'Daughter', N'RN', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (43, N'Wife of', N'Wife', N'RN', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (44, N'Husband of', N'Husband', N'RN', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (45, N'Voter ID', N'ID Type', N'IDT', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (46, N'Passport ', N'ID Type', N'IDT', 0)
INSERT [dbo].[CommonTable] ([CommonID], [Name], [Description], [TypeID], [IsDeleted]) VALUES (47, N'Others', N'ID Type', N'IDT', 0)
SET IDENTITY_INSERT [dbo].[CommonTable] OFF
SET IDENTITY_INSERT [dbo].[M_Block] ON 

INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (1, 565, NULL, N'FATEHPUR SIKRI', N'फतेहपुर सीकरी', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (2, 565, NULL, N'ACHHNERA', N'अछनेरा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (3, 565, NULL, N'AKOLA', N'अकोला', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (4, 565, NULL, N'BICHPURI', N'बिचपुरी', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (5, 565, NULL, N'BARULI AHIR', N'बरौली अहीर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (6, 565, NULL, N'KHANDAULI', N'खंदौली', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (7, 565, NULL, N'ETMADPUR', N'एतमादपुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (8, 565, NULL, N'JAGNER', N'जगनेर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (9, 565, NULL, N'KHERAGARH', N'खेरागढ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (10, 565, NULL, N'SAIYA', N'सैंयाँ', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (11, 565, NULL, N'SHAMSHABAD', N'शमसाबाद', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (12, 565, NULL, N'FATEHABAD', N'फतेहाबाद', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (13, 565, NULL, N'PINAHAT', N'पिनाहट', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (14, 565, NULL, N'BAH', N'बाह', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (15, 565, NULL, N'JAITPUR KALAN', N'जैतपुर कलां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (16, 617, NULL, N'NANDGAON', N'नन्दगांव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (17, 617, NULL, N'CHHATA', N'छाता', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (18, 617, NULL, N'CHAUMUHA', N'चैमुहा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (19, 617, NULL, N'GOVERDHAN', N'गोवर्धन', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (20, 617, NULL, N'MATHURA', N'मथुरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (21, 617, NULL, N'FARAH', N'फरह', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (22, 617, NULL, N'NAUJHIL', N'नौह झील', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (23, 617, NULL, N'MOTT', N'मोट', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (24, 617, NULL, N'RAYA', N'राया', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (25, 617, NULL, N'BALDEV', N'बल्देव', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (26, 592, NULL, N'NARKHI', N'नारखी', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (27, 592, NULL, N'FIROZABAD', N'फिरोजाबाद', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (28, 592, NULL, N'TUNDLA', N'टुण्डला', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (29, 592, NULL, N'EKA', N'एका', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (30, 592, NULL, N'HATHWANT', N'हाथवंत', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (31, 592, NULL, N'JASRANA', N'जसराना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (32, 592, NULL, N'SHIKOHABAD', N'शिकोहाबाद', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (33, 592, NULL, N'ARAO', N'अरावँ', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (34, 592, NULL, N'MADANPUR', N'मदनपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (35, 592, NULL, N'KHAIRGARH', N'खैरगढ', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (36, 616, NULL, N'GHIROR', N'घिरौर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (37, 616, NULL, N'KURAWALI', N'कुरावली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (38, 616, NULL, N'MAINPURI', N'मैनपुरी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (39, 616, NULL, N'BARNAHAL', N'बरनाहल', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (40, 616, NULL, N'SULTANGANJ', N'सुल्तानगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (41, 616, NULL, N'BEWAR', N'बेवर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (42, 616, NULL, N'ALAO', N'अलाव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (43, 616, NULL, N'BHOGOAN', N'भोगांव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (44, 616, NULL, N'KISHNI', N'किशनी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (45, 616, NULL, N'KARHAL', N'करहल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (46, 616, NULL, N'JAGIR', N'जगीर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (47, 566, NULL, N'TAPPAL', N'तप्पल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (48, 566, NULL, N'KHAIR', N'खैर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (49, 566, NULL, N'JAWAN', N'जवाँ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (50, 566, NULL, N'CHADAUS', N'चन्दौस', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (51, 566, NULL, N'LODA', N'लेधा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (52, 566, NULL, N'DHANIPUR', N'धनिपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (53, 566, NULL, N'AKRABAD', N'अकराबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (54, 566, NULL, N'JAWAN SIKANDER PUR', N'जवाँ सिकन्दरपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (55, 566, NULL, N'GONDA', N'गोण्डा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (56, 566, NULL, N'IGLAS', N'इगलास', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (57, 566, NULL, N'ATRAULI', N'अतरौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (58, 566, NULL, N'BIJAULI', N'बिजौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (59, 566, NULL, N'GANGIRI', N'गंगिरी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (60, 587, NULL, N'JALESAR', N'जलेसर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (61, 587, NULL, N'ABAGARH', N'अवागढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (62, 587, NULL, N'MARHARA', N'मरहरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (63, 587, NULL, N'NIDHAULI KALAN', N'निधौलीकलाँ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (64, 587, NULL, N'SHEETALPUR', N'शीतलपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (65, 587, NULL, N'SAKIT', N'सकित', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (66, 587, NULL, N'JAITHRA', N'जैथरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (67, 587, NULL, N'ALIGANJ', N'अलीगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (68, 608, NULL, N'SORO', N'सोरो', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (69, 608, NULL, N'KASGANJ', N'कासगंज', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (70, 608, NULL, N'AMANPUR', N'अमनपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (71, 608, NULL, N'SAHAWAR', N'सहावर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (72, 608, NULL, N'GANJ DUNDWARA', N'गंज डुंडवारा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (73, 608, NULL, N'PATIALI', N'पतियाली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (74, 608, NULL, N'SIRHPURA', N'सिढपुरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (75, 600, NULL, N'SASNI', N'सासनी', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (76, 600, NULL, N'HATHRAS', N'हाथरस', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (77, 600, NULL, N'MURSAN', N'मुरसान', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (78, 600, NULL, N'SADABAD', N'सादाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (79, 600, NULL, N'SAHPAU', N'सहपऊ', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (80, 600, NULL, N'SIKANDRARAU', N'सिकन्दर राव', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (81, 600, NULL, N'HASAYAN', N'हसायां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (82, 577, NULL, N'BAHEDI', N'बहेडी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (83, 577, NULL, N'SHERGARH', N'शेरगढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (84, 577, NULL, N'RICHCHHA', N'रिच्छा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (85, 577, NULL, N'MEERGANJ', N'मीरगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (86, 577, NULL, N'FATEHGANJ', N'फतेहगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (87, 577, NULL, N'BHOJIPURA', N'भोजीपुरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (88, 577, NULL, N'KYARA', N'क्यारा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (89, 577, NULL, N'RAMNAGAR', N'राम नगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (90, 577, NULL, N'MAJHGAWAN', N'मझगवां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (91, 577, NULL, N'ALAMPUR JAFARBAD', N'आलमपुर जफराबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (92, 577, NULL, N'BIDHARICHAINPUR', N'बिधारीचैनपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (93, 577, NULL, N'NAGRIYA KSHETRA', N'नगरीय क्षेत्र', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (94, 577, NULL, N'NAWABGANJ', N'नवाबगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (95, 577, NULL, N'BHADPURA', N'भाड़पुरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (96, 577, NULL, N'BHOOTA', N'भूटा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (97, 577, NULL, N'FARIDPUR', N'फरीदपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (98, 581, NULL, N'BISAULI', N'बिसौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (99, 581, NULL, N'VAJIRGANJ', N'वजीरगंज', N'UN')
GO
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (100, 581, NULL, N'ASAFPUR', N'आसफपुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (101, 581, NULL, N'ISLAMNAGAR', N'इस्लामनगर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (102, 581, NULL, N'AMBIAPUR', N'अम्बियापुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (103, 581, NULL, N'DAHGAWAN', N'दहगवां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (104, 581, NULL, N'SAHASWAN', N'सहसवान', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (105, 581, NULL, N'SALARPUR', N'सलारपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (106, 581, NULL, N'JAGAT', N'जगत', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (107, 581, NULL, N'UJHANI', N'उझानी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (108, 581, NULL, N'KADARCHOWK', N'कादर चैक', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (109, 581, NULL, N'SAMRER', N'समरेर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (110, 581, NULL, N'DATAGANJ', N'दातागंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (111, 581, NULL, N'MYAUN', N'मिऑन', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (112, 581, NULL, N'USAWAN', N'उसावां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (113, 624, NULL, N'AMRIA', N'अमरिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (114, 624, NULL, N'MARAURI', N'मरौरी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (115, 624, NULL, N'LALAURI KHEDA', N'ललौरी खेड़ा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (116, 624, NULL, N'BARKHEDA', N'बरखेडा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (117, 624, NULL, N'BILSANDA', N'बिलसण्डा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (118, 624, NULL, N'BISALPUR', N'बिसालपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (119, 624, NULL, N'PURANPUR', N'पूरनपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (120, 632, NULL, N'BUNDA', N'बुण्डा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (121, 632, NULL, N'KHUTAR', N'खुतार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (122, 632, NULL, N'PUWAYAN', N'पुवांया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (123, 632, NULL, N'SINDHAULI', N'सिंधौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (124, 632, NULL, N'KHUDAGANJ KATRA', N'खुदागंज कटरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (125, 632, NULL, N'JAITIPUR', N'जैतीपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (126, 632, NULL, N'TILHAR', N'तिलहर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (127, 632, NULL, N'NIGOHI', N'निगोही', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (128, 632, NULL, N'KANTH', N'कांठ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (129, 632, NULL, N'DADRAUL', N'ददरौल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (130, 632, NULL, N'BHAWAL KHEDA', N'भवल खेडा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (131, 632, NULL, N'MADNAPUR', N'मदनापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (132, 632, NULL, N'KALAN', N'कलां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (133, 632, NULL, N'MIRZAPUR', N'मिर्जापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (134, 632, NULL, N'JALALABAD', N'जलालाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (135, 621, NULL, N'THAKURDWARA', N'ठाकुरद्वारा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (136, 621, NULL, N'DILARI', N'दिलारी', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (137, 621, NULL, N'CHAJLAIT', N'छजलेट', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (138, 621, NULL, N'BHAGATPUR TANDA', N'भगतपुर टांडा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (139, 621, NULL, N'MORADABAD', N'मुरादाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (140, 621, NULL, N'MURHAPANDE', N'मुन्डा पाण्डेय', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (141, 621, NULL, N'DINGARPUR', N'डिंगरपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (142, 621, NULL, N'BILARI', N'बिलारी', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (143, 579, NULL, N'RAJPURA', N'राजपुरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (144, 579, NULL, N'GUNNAUR', N'गुन्नौर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (145, 579, NULL, N'JUNAMI', N'जूनावई', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (146, 579, NULL, N'ASMOLI', N'असमोली', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (147, 579, NULL, N'SAMBHAL', N'सम्भल', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (148, 579, NULL, N'PAWANSA', N'पवांसा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (149, 579, NULL, N'BANIAKHERA', N'बनियाखेड़ा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (150, 579, NULL, N'BAHJOI', N'बहजोई', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (151, 604, NULL, N'AMROHA', N'अमरोहा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (152, 604, NULL, N'ZOYA', N'जोया', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (153, 604, NULL, N'DHANORA', N'धनौरा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (154, 604, NULL, N'GAJRAULA', N'गजरौला', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (155, 604, NULL, N'HASANPUR', N'हसनपुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (156, 604, NULL, N'GANGESHWARI', N'गंगेश्वरी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (157, 580, NULL, N'NAZIBABAD', N'नजीबाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (158, 580, NULL, N'KIRATPUR', N'किरतपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (159, 580, NULL, N'MUHAMMADPUR DEVMAL', N'मुहम्मदपुर देवमल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (160, 580, NULL, N'HALDAUR KHARI JHALU', N'हलदौर खरी झालू', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (161, 580, NULL, N'KOTWALI', N'कोतवाली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (162, 580, NULL, N'AFJALGARH', N'अफजलगढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (163, 580, NULL, N'NAHTAUR', N'नहटौर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (164, 580, NULL, N'ALHEPUR', N'अल्हेपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (165, 580, NULL, N'BURHANPUR SYOHARA', N'बुधानपुर स्योहारा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (166, 580, NULL, N'JALILPUR', N'जलीलपुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (167, 580, NULL, N'NURPUR', N'नूरपुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (168, 628, NULL, N'SWAR', N'स्वार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (169, 628, NULL, N'BILASPUR', N'बिलासपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (170, 628, NULL, N'SAIDNAGAR', N'सैदनगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (171, 628, NULL, N'CHAMRAUAA (URBAN)', N'चमरौआ (शहर)', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (172, 628, NULL, N'SHAHABAD', N'शाहाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (173, 628, NULL, N'MILAK', N'मिलक', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (174, 619, NULL, N'SARURPUR KHURD', N'सरूरपुर खुर्द', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (175, 619, NULL, N'SARDHANA', N'सरधना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (176, 619, NULL, N'DAURALA', N'दौराला', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (177, 619, NULL, N'MAWANA KALA', N'मवाना कला', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (178, 619, NULL, N'HASTINAPUR', N'हस्तिनापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (179, 619, NULL, N'PARIKSHITGARH', N'परीक्षितगढ़', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (180, 619, NULL, N'MACHRA', N'माछरा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (181, 619, NULL, N'ROHTA', N'रोहता', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (182, 619, NULL, N'JANIKHURD', N'जानी खुर्द', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (183, 619, NULL, N'MEERUT (URBAN)', N'मेरठ शहर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (184, 619, NULL, N'RAJPURA', N'रजपुरा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (185, 619, NULL, N'KHARKHODA', N'खरखोदा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (186, 619, NULL, N'MEERUT', N'मेरठ', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (187, 582, NULL, N'SIKANDRABAD', N'सिकन्दराबाद', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (188, 582, NULL, N'GULAVATI', N'गुलावटी', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (189, 582, NULL, N'LAKHAVATI', N'लखौटी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (190, 582, NULL, N'BULANDSHAHAR', N'बुलन्दशहर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (191, 582, NULL, N'AGAUTA', N'अगौटा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (192, 582, NULL, N'PAHASU', N'पहासू', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (193, 582, NULL, N'SHIKARPUR', N'शिकारपुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (194, 582, NULL, N'BHAWAN BAHADUR NAGAR', N'भवन बहादुर नगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (195, 582, NULL, N'SYANA', N'सियाना', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (196, 582, NULL, N'JAHANGIRABAD', N'जहाँगीराबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (197, 582, NULL, N'UNCHAGOAN', N'ऊँचागाँव', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (198, 582, NULL, N'B.B.NAGAR', N'बी.बी. नगर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (199, 582, NULL, N'KHURJA', N'खुर्जा', N'N')
GO
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (200, 582, NULL, N'ARNIA', N'अर्निया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (201, 582, NULL, N'DANPUR', N'दानपुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (202, 582, NULL, N'DEBAI', N'देबई', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (203, 582, NULL, N'ANUPSHAHAR', N'अनूपशहर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (204, 594, NULL, N'BHOJPUR', N'भोजपुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (205, 594, NULL, N'MURADNAGAR', N'मुरादनगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (206, 594, NULL, N'RAJAPUR', N'रजापर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (207, 594, NULL, N'LONI', N'लोनी', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (208, 623, NULL, N'DHAULANA', N'धौलाना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (209, 623, NULL, N'HAPUR', N'हापुड़', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (210, 623, NULL, N'SINBHAWALI', N'सिम्भावली', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (211, 623, NULL, N'GARHMUKTESHWAR', N'गढ़मुक्तेश्वर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (212, 593, NULL, N'DANKAUR', N'धनकौर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (213, 593, NULL, N'JEWAR', N'जेवर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (214, 593, NULL, N'DADRI', N'दादरी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (215, 593, NULL, N'BISRAKH', N'बिसरख', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (216, 571, NULL, N'CHAPRAULI', N'छपरौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (217, 571, NULL, N'BARAOT', N'बड़ौत', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (218, 571, NULL, N'BINAULI', N'बिनौली', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (219, 571, NULL, N'BAGHPAT', N'बागपत', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (220, 571, NULL, N'PILANA', N'पिलाना', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (221, 571, NULL, N'KHEKDA', N'खेकड़ा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (222, 629, NULL, N'SADHULI KADEEM', N'सदौली कदीम', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (223, 629, NULL, N'MUZAFFARABAD', N'मुजफ्फराबाद', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (224, 629, NULL, N'PUVARKA', N'पुवारका', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (225, 629, NULL, N'BALLIA KHERI', N'बलिया खेडी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (226, 629, NULL, N'SARSAWA', N'सरसावा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (227, 629, NULL, N'NAKUD', N'नकुड़', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (228, 629, NULL, N'GANGOH', N'गंगोह', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (229, 629, NULL, N'RAMPUR MANIHARAN', N'रामपुर मनिहरन', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (230, 629, NULL, N'NAGAL', N'नागल', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (231, 629, NULL, N'NANAUTA', N'ननौता', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (232, 629, NULL, N'DEVBAND', N'देवबन्द', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (233, 622, NULL, N'CHARRTHAVAL', N'चरथावल', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (234, 622, NULL, N'PURKAJI', N'पुरकाजी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (235, 622, NULL, N'MUZAFFARNAGAR', N'मुजफ्फरनगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (236, 622, NULL, N'BAGHRA', N'बघरा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (237, 622, NULL, N'KUKDA SADAR', N'कुकडा सदर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (238, 622, NULL, N'KANDHLA', N'कंधला', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (239, 622, NULL, N'BUDHANA', N'बुढ़ाना', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (240, 622, NULL, N'SHAHPUR', N'शाहपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (241, 622, NULL, N'MORNA', N'मोरना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (242, 622, NULL, N'JANSATH', N'जनसाथ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (243, 622, NULL, N'KHATAULI', N'खतौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (244, 625, NULL, N'UAN', N'ऊन', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (245, 625, NULL, N'KAIRANA', N'कैराना', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (246, 625, NULL, N'KANDHLA ', N'कांधला', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (247, 625, NULL, N'THANA BHAWAN', N'थाना भवन', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (248, 625, NULL, N'SHAMLI', N'शामली', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (249, 607, NULL, N'KANPUR NAGAR SADAR (N.K.)', N'कानपुर नगर सदर (एन०के०)', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (250, 607, NULL, N'KALYANPUR', N'कल्यानपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (251, 607, NULL, N'VIDHNU', N'विधनु', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (252, 607, NULL, N'SARSAUL', N'सरसौल', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (253, 607, NULL, N'BILHAUR', N'बिल्हौर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (254, 607, NULL, N'KAKVAN', N'ककवन', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (255, 607, NULL, N'SHIVRAJPUR', N'शिवराजपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (256, 607, NULL, N'CHAUBEPUR', N'चौबेपुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (257, 607, NULL, N'PATARA', N'पतारा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (258, 607, NULL, N'BHITARGAON', N'भितरगांव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (259, 607, NULL, N'GHATAMPUR', N'घाटमपुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (260, 607, NULL, N'KANPUR SHAHAR', N'कानपुर शहर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (261, 606, NULL, N'RASULABAD', N'रसूलाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (262, 606, NULL, N'JHIJHAK', N'झींझक', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (263, 606, NULL, N'DERAPUR', N'डेरापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (264, 606, NULL, N'AKBARPUR', N'अकबरपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (265, 606, NULL, N'SARVANKHERA', N'सरवनखेडा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (266, 606, NULL, N'RAJPUR', N'राजपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (267, 606, NULL, N'SANDALPUR', N'संदलपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (268, 606, NULL, N'MALASA', N'मलासा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (269, 606, NULL, N'AMRAUDA', N'अमरौदा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (270, 606, NULL, N'MAITHA', N'मैथा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (271, 605, NULL, N'CHIBRAMAU', N'छिबरामऊ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (272, 605, NULL, N'TALGRAM', N'तालग्राम', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (273, 605, NULL, N'SAURIKH', N'सौरिख', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (274, 605, NULL, N'HASRAN', N'हासरन', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (275, 605, NULL, N'UMARDA', N'उर्मदा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (276, 605, NULL, N'GUGRAPUR', N'गुगरापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (277, 605, NULL, N'JALALABAD', N'जलालाबाद', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (278, 605, NULL, N'KANNAUJ', N'कन्नौज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (279, 588, NULL, N'JASWANTNAGAR', N'जसवन्तनगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (280, 588, NULL, N'BASREHAR', N'बसरेहर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (281, 588, NULL, N'BARHPOORA', N'बढपूरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (282, 588, NULL, N'BHARTHANA', N'भरथना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (283, 588, NULL, N'MAHEBA', N'महेबा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (284, 588, NULL, N'CHAKKARNAGAR', N'चक्करनगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (285, 588, NULL, N'SAIFAI', N'सैफई', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (286, 588, NULL, N'TAKHA', N'ताखा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (287, 569, NULL, N'ERVA KATRA', N'इरवा कटरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (288, 569, NULL, N'BIDHUNA', N'बिधूना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (289, 569, NULL, N'ACHALDA', N'अचालदा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (290, 569, NULL, N'SAHAR', N'शहर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (291, 569, NULL, N'BHAGYANAGAR', N'भग्यनगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (292, 569, NULL, N'AURAIYA', N'औरैया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (293, 569, NULL, N'AJITMAL', N'अजीतमल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (294, 569, NULL, N'AJITMAL', N'अजीतमल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (295, 590, NULL, N'KAYAMGANJ', N'कायमगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (296, 590, NULL, N'NAWABGANJ', N'नवाबगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (297, 590, NULL, N'SHAMSABAD', N'समसाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (298, 590, NULL, N'RAJEPUR', N'राजेपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (299, 590, NULL, N'BARHPUR', N'बढपुर', N'UN')
GO
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (300, 590, NULL, N'MOHAMMADABAD', N'मुहम्मदाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (301, 590, NULL, N'KAMALGANJ', N'कमालगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (302, 567, NULL, N'KAUDRIHAR', N'कौद्रीहार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (303, 567, NULL, N'HOLAGARH', N'होलागढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (304, 567, NULL, N'MUAIMA', N'मऊ आईमा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (305, 567, NULL, N'SORAON', N'सोरांव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (306, 567, NULL, N'BAHARIYA', N'बहेरिया', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (307, 567, NULL, N'PHULPUR', N'फूलपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (308, 567, NULL, N'BAHADURPUR', N'बहादुरपुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (309, 567, NULL, N'PRATAPPUR', N'प्रतापपुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (310, 567, NULL, N'SAIDABAD', N'सैदाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (311, 567, NULL, N'DHANUPUR', N'धनुपुर ', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (312, 567, NULL, N'HANDIA', N'हण्डिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (313, 567, NULL, N'JASRA', N'जसरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (314, 567, NULL, N'SHANKARGARH', N'शंकरगढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (315, 567, NULL, N'CHAKA', N'चाका', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (316, 567, NULL, N'KARCHANA', N'करछना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (317, 567, NULL, N'KAUDHIARA', N'कौधिआरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (318, 567, NULL, N'URUWA', N'उरूवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (319, 567, NULL, N'MEJA', N'मेजा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (320, 567, NULL, N'KORAON', N'कोरांव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (321, 567, NULL, N'MANDA', N'मंदा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (322, 567, NULL, N'ALLAHABAD SADAR (N.K)', N'इलाहाबा सदर (एन०के०)', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (323, 609, NULL, N'KADA', N'कड़ा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (324, 609, NULL, N'SIRATHU', N'सिराथू', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (325, 609, NULL, N'SARSAWAN', N'सरसवां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (326, 609, NULL, N'MANJHANPUR', N'मँझनपुर ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (327, 609, NULL, N'KAUSHAMBI', N'कौशाम्बी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (328, 609, NULL, N'MURATGANJ', N'मूरतगंत', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (329, 609, NULL, N'CHAYAL', N'चायल ', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (330, 609, NULL, N'NEVADA', N'नेवादा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (331, 591, NULL, N'DEVMAI', N'देवमई', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (332, 591, NULL, N'MALWAN', N'मलावाँ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (333, 591, NULL, N'AMAULI', N'अमौली', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (334, 591, NULL, N'KHAJUHA', N'खजुहा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (335, 591, NULL, N'TELIANI', N'तेलियानी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (336, 591, NULL, N'BHITAURA', N'भिटौरा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (337, 591, NULL, N'HASWA', N'हसवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (338, 591, NULL, N'BHUWA', N'बहुआ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (339, 591, NULL, N'ASOTHAR', N'असोथर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (340, 591, NULL, N'HATHGAM', N'हथगाँव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (341, 591, NULL, N'ERAYAN', N'ऐरायां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (342, 591, NULL, N'VIJAYIPUR', N'विजयीपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (343, 591, NULL, N'DHATA', N'धाता', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (344, 503, NULL, N'KALAKANKAR', N'कालाकांकर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (345, 503, NULL, N'BABAGANJ', N'बाबागंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (346, 503, NULL, N'KUNDA', N'कुण्डा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (347, 503, NULL, N'BIHAR', N'बिहार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (348, 503, NULL, N'SANGIPUR', N'संगीपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (349, 503, NULL, N'LALGANJ', N'लालगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (350, 503, NULL, N'LAXMANPUR', N'लक्ष्मणपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (351, 503, NULL, N'RAMPUR SANGRAMGARH', N'रामपुर संग्रामगढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (352, 503, NULL, N'SANDA CHANDRIKA', N'सण्डवाचन्द्रिका', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (353, 503, NULL, N'PRATAPGARH SADAR', N'प्रतापगढ सदर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (354, 503, NULL, N'MANDHATA', N'मान्धाता', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (355, 503, NULL, N'MANGRAURA', N'मंगरौरा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (356, 503, NULL, N'PATTI', N'पट्टी', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (357, 503, NULL, N'ASPUR DEVSARA', N'आसपुर देवसरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (358, 503, NULL, N'SHIVGARH', N'शिवगढ़', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (359, 503, NULL, N'GAURA', N'गौरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (360, 503, NULL, N'BABA BELKHARNATH', N'बेलखरनाथ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (361, 603, NULL, N'MOTH', N'मोंठ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (362, 603, NULL, N'CHIRGAON', N'चिरगांव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (363, 603, NULL, N'BAMAUR', N'बमौर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (364, 603, NULL, N'GURSARAY', N'गुरसराय', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (365, 603, NULL, N'BANGRA', N'बंगरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (366, 603, NULL, N'MURANIPUR', N'मऊरानीपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (367, 603, NULL, N'BABINA', N'बबीना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (368, 603, NULL, N'BARAGAON', N'बडागाँव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (369, 603, NULL, N'JHANSI SADAR', N'झांसी सदर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (370, 601, NULL, N'MADHOGARH', N'माधोगढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (371, 601, NULL, N'RAMPURA', N'रामपुरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (372, 601, NULL, N'KUTHAUND', N'कथौंड', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (373, 601, NULL, N'JALAUN', N'जालौन', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (374, 601, NULL, N'NADIGAON', N'नदीगांव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (375, 601, NULL, N'KONCH', N'कोंच', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (376, 601, NULL, N'DAKOR', N'डकोर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (377, 601, NULL, N'MAHEWA', N'महेवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (378, 601, NULL, N'KADAURA', N'कडौरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (379, 612, NULL, N'TALBAHET', N'तालबेहट ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (380, 612, NULL, N'JAKHAURA', N'जखोरा़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (381, 612, NULL, N'BIRDHA', N'बिरधा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (382, 612, NULL, N'MAHRAUNI', N'महरौनी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (383, 612, NULL, N'MONDAVARA', N'मडावरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (384, 612, NULL, N'BAR', N'बार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (385, 585, NULL, N'MANIKPUR', N'मानिकपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (386, 585, NULL, N'PAHARI', N'पहाड़ी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (387, 585, NULL, N'KARVY', N'कर्वी', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (388, 585, NULL, N'RAMNAGAR', N'राम नगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (389, 585, NULL, N'MAU', N'मऊ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (390, 585, NULL, N'MANIKPUR', N'मानिकपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (391, 615, NULL, N'PANWARI', N'पनवारी', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (392, 615, NULL, N'JAITPUR', N'जैतपुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (393, 615, NULL, N'CHARKHARI', N'चरखारी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (394, 615, NULL, N'KABRAI', N'कबरई', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (395, 575, NULL, N'JASPURA', N'जसपुरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (396, 575, NULL, N'TINDWARI', N'तिंदवारी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (397, 575, NULL, N'BADOKHARKHURD', N'बदोखर खुर्द', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (398, 575, NULL, N'BABERU', N'बबेरू', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (399, 575, NULL, N'KAMASIN', N'कमासिन', N'UN')
GO
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (400, 575, NULL, N'BISANDA', N'बिसण्डा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (401, 575, NULL, N'MAHUA', N'महुआ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (402, 575, NULL, N'ATARRA', N'अतर्रा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (403, 575, NULL, N'NARAINI', N'नरैनी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (404, 575, NULL, N'PAILANI', N'पैलानी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (405, 197, NULL, N'KURARA', N'कुरारा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (406, 197, NULL, N'SUMERPUR', N'सुमेरपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (407, 197, NULL, N'SARILA', N'सरीला', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (408, 197, NULL, N'GOHAND', N'गोहाण्ड', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (409, 197, NULL, N'RATH', N'राठ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (410, 197, NULL, N'MUSKRA', N'मुसक्‍रा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (411, 197, NULL, N'MODAHA', N'मौदहा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (412, 613, NULL, N'MALIHABAD', N'मलिहाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (413, 613, NULL, N'MAAL', N'माल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (414, 613, NULL, N'BAKSHI KA TALAB', N'बक्शी का तालाब', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (415, 613, NULL, N'KAKORI', N'काकोरी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (416, 613, NULL, N'CHINHAT', N'चिनहट', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (417, 613, NULL, N'SAROJINI NAGAR', N'सरोजनी नगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (418, 613, NULL, N'LUCKNOW SADAR (N.K.)', N'लखनऊ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (419, 613, NULL, N'GOSAIGANJ', N'गोसांईगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (420, 613, NULL, N'MOHANLALGANJ', N'मोहनलालगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (421, 599, NULL, N'BHARKHANI', N'भरखनी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (422, 599, NULL, N'HARPALPUR', N'हरपालपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (423, 599, NULL, N'SHAHABAD', N'शाहाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (424, 599, NULL, N'TODERPUR', N'टोडरपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (425, 599, NULL, N'PIHANI', N'पिहानी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (426, 599, NULL, N'BAWAN', N'बवन', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (427, 599, NULL, N'HARIYAWAN', N'हरियावां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (428, 599, NULL, N'TADIYAWAN', N'तडियावां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (429, 599, NULL, N'SURSA', N'सुरसा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (430, 599, NULL, N'AHIRORI', N'अहिरौरी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (431, 599, NULL, N'SANDI', N'सन्डी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (432, 599, NULL, N'BILGRAM', N'बिलग्राम', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (433, 599, NULL, N'MADHOGANJ', N'माधोगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (434, 599, NULL, N'MALLAWAN', N'मल्लावां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (435, 599, NULL, N'KOTHAWAN', N'कोठावां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (436, 599, NULL, N'KACHAUNA', N'कछौना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (437, 599, NULL, N'BEHANDER', N'बेहान्डर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (438, 599, NULL, N'SANDILA', N'सन्डीला', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (439, 599, NULL, N'BHARAWAN', N'भरावां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (440, 611, NULL, N'PALIA KALAN', N'पलियां कलां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (441, 611, NULL, N'NIGHASAN', N'निघासन', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (442, 611, NULL, N'RAMIA BEHAD', N'रमिया बेहड', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (443, 611, NULL, N'KUMBHI', N'कुम्भी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (444, 611, NULL, N'BIJUA', N'बिजुआ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (445, 611, NULL, N'BAKEGANJ', N'बांकेगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (446, 611, NULL, N'MOHAMMADI', N'मोहम्मदी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (447, 611, NULL, N'MITAULI', N'मितौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (448, 611, NULL, N'PASGAWAN', N'पासगवां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (449, 611, NULL, N'BEHZAM', N'बेहजम', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (450, 611, NULL, N'LAKHIMPUR', N'लखीमपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (451, 611, NULL, N'FULBEHAD', N'फूलबेहड', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (452, 611, NULL, N'NAKHA', N'नकहा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (453, 611, NULL, N'DHORHARA', N'धोरहरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (454, 611, NULL, N'ISANAGAR', N'ईसानगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (455, 635, NULL, N'MAHOLI', N'महोली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (456, 635, NULL, N'MISHRIKH', N'मिश्रिख', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (457, 635, NULL, N'MACHREHATA', N'मछरेटा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (458, 635, NULL, N'GODLAMU', N'गोदलामऊ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (459, 635, NULL, N'ELIYA', N'इलिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (460, 635, NULL, N'HARGAON', N'हरगांव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (461, 635, NULL, N'PARSENDI', N'परसेन्डी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (462, 635, NULL, N'KHERABAD', N'खेराबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (463, 635, NULL, N'NAGAR CHHETRA', N'नगर क्षेत्र', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (464, 635, NULL, N'LAHARPUR', N'लहरपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (465, 635, NULL, N'BEHTA', N'बेहटा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (466, 635, NULL, N'REUSA', N'रऊसा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (467, 635, NULL, N'SAKRAN', N'सकरां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (468, 635, NULL, N'BISWAN', N'बिसवां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (469, 635, NULL, N'KASMANDA', N'कसमन्डा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (470, 635, NULL, N'SIDHAULI', N'सिधौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (471, 635, NULL, N'PAHLA', N'पल्हा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (472, 635, NULL, N'MAHMUDABAD', N'महमूदाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (473, 635, NULL, N'RAMPURMATHURA', N'रामपुर मथुरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (474, 635, NULL, N'PISAWAN', N'पिसावां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (475, 635, NULL, N'PISAWAN', N'पिसावां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (476, 638, NULL, N'GANJ MORADABAD', N'गंज मोरादाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (477, 638, NULL, N'BANGARMAU', N'बांगरमऊ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (478, 638, NULL, N'FATEHPUR CHAURASI', N'फतेहपुर चौरासी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (479, 638, NULL, N'SAFIPUR', N'सफीपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (480, 638, NULL, N'AURAS', N'औरस', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (481, 638, NULL, N'MIYANGANJ', N'मियांगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (482, 638, NULL, N'HASANGANJ', N'हसनगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (483, 638, NULL, N'NAWABGANJ', N'नवाबगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (484, 638, NULL, N'SIKANDERPUR SARAUSI', N'सिकन्दरपुर सरौसी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (485, 638, NULL, N'BICHIA', N'बिछिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (486, 638, NULL, N'SIKANDERPUR KARAN', N'सिकन्दरपुर करन', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (487, 638, NULL, N'ASOHA', N'असोहा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (488, 638, NULL, N'HILAULI', N'हिलौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (489, 638, NULL, N'PURWA', N'पुरवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (490, 638, NULL, N'BIGHAPUR', N'बीघापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (491, 638, NULL, N'SUMERPUR', N'सुमेरपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (492, 627, NULL, N'BACHHRAWAN', N'बछरावां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (493, 627, NULL, N'SHIVGARH', N'शिवगढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (494, 627, NULL, N'MAHRAJGANJ', N'महाराजगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (495, 627, NULL, N'HARCHANDPUR', N'हरचन्दपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (496, 627, NULL, N'AMABA', N'अम्बा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (497, 627, NULL, N'SATAMB', N'सतम्ब', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (498, 627, NULL, N'RAAHI', N'राही', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (499, 627, NULL, N'KHIRO', N'खिरों', N'UN')
GO
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (500, 627, NULL, N'SARAINI', N'सरैनी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (501, 627, NULL, N'LALGANJ', N'लालगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (502, 627, NULL, N'DALMAU', N'डालमऊ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (503, 627, NULL, N'DINSHAHGAURA', N'डिंशाहगौरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (504, 627, NULL, N'JAGATPUR', N'जगतपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (505, 627, NULL, N'UNCHAHAR', N'ऊँचाहार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (506, 627, NULL, N'ROHNIA', N'रोहनिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (507, 627, NULL, N'SALON', N'सलोन', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (508, 589, NULL, N'SOHOWAL', N'सोहावल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (509, 589, NULL, N'MASUDHA', N'मसूधा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (510, 589, NULL, N'PURABAJAR', N'पुराबाजार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (511, 589, NULL, N'MAYABAJAR', N'मायाबाजार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (512, 589, NULL, N'AMANIGANJ', N'अमानीगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (513, 589, NULL, N'MILKIPUR', N'मिल्कीपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (514, 589, NULL, N'HARINGTGANJ', N'हरिंग्टगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (515, 589, NULL, N'BIKAPUR', N'बीकापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (516, 589, NULL, N'TARUN', N'तरूण', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (517, 589, NULL, N'MAWAI', N'मवई', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (518, 589, NULL, N'RUDAULI', N'रूदौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (519, 568, NULL, N'BHITI', N'भीटी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (520, 568, NULL, N'KATEHARI', N'भीती', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (521, 568, NULL, N'AKBARPUR', N'अकबरपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (522, 568, NULL, N'TANDA ', N'टांडा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (523, 568, NULL, N'BASKHARI', N'बसखरी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (524, 568, NULL, N'RAMNAGAR', N'रामनगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (525, 568, NULL, N'JAHANGIRGANJ', N'जहाँगीरगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (526, 568, NULL, N'JALALPUR', N'जलालपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (527, 568, NULL, N'BHIYAON', N'भियावं', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (528, 637, NULL, N'WALDI RAI', N'वल्दीराय', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (529, 637, NULL, N'DHANPATGANJ', N'धनपतगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (530, 637, NULL, N'KUREBHAR', N'कुरेभर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (531, 637, NULL, N'KURVAR', N'कुरवर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (532, 637, NULL, N'DUBEPUR', N'दुबेपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (533, 637, NULL, N'JAISINGHPUR', N'जैसिंहपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (534, 637, NULL, N'MOTIGARPUR', N'मोतीगढ़पुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (535, 637, NULL, N'LAMBHUA', N'लम्भुआ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (536, 637, NULL, N'PRATAPPUR KAMAICHA', N'प्रतापपुर कमैछा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (537, 637, NULL, N'BHADAIYA', N'भदैया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (538, 637, NULL, N'DOSTPUR', N'दोस्तपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (539, 637, NULL, N'AKHAND NAGAR', N'अखन्ड नगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (540, 637, NULL, N'KADIPUR', N'कादीपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (541, 637, NULL, N'KARUNDI KALAN', N'करौन्दी कलां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (542, 584, NULL, N'SHUKUL BAZAR', N'शुकुल बाजा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (543, 584, NULL, N'JAGDISHPUR', N'जगदीशपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (544, 584, NULL, N'MUSAFIRKHANA', N'मुसाफिरखाना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (545, 584, NULL, N'SIMHPUR', N'सिम्हपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (546, 584, NULL, N'TILOI', N'तिलोई', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (547, 584, NULL, N'BAHADURPUR', N'बहादुरपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (548, 584, NULL, N'GAURIGANJ', N'गौरीगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (549, 584, NULL, N'JAMON', N'जमों', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (550, 584, NULL, N'SHAHGARH', N'शाहगढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (551, 584, NULL, N'AMETHI', N'अमेठी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (552, 584, NULL, N'BHETUA', N'भेतुआ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (553, 584, NULL, N'BHADAR', N'भदर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (554, 584, NULL, N'SANGRAMPUR', N'संग्रामगढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (555, 584, NULL, N'DEEH', N'डीह', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (556, 584, NULL, N'CHATOH', N'चतोह', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (557, 584, NULL, N'SALON', N'सलोन', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (558, 576, NULL, N'NINDURA', N'निन्दुरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (559, 576, NULL, N'FATEHPUR CHAURASI', N'फतेहपुर चौरासी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (560, 576, NULL, N'SURATGANJ', N'सूतरगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (561, 576, NULL, N'RAMNAGAR', N'रामनगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (562, 576, NULL, N'DEVA', N'देवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (563, 576, NULL, N'BANKI', N'बंकी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (564, 576, NULL, N'HARAKH', N'हरख', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (565, 576, NULL, N'MASAULI', N'मसौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (566, 576, NULL, N'SIDDHAUR', N'सिधौर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (567, 576, NULL, N'TRIVEDIGANJ', N'त्रिवेदीगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (568, 576, NULL, N'HAIDARGARH', N'हैदरगढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (569, 576, NULL, N'DARIYABAD', N'दरियाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (570, 576, NULL, N'BANI KODAR', N'बनी कोडर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (571, 576, NULL, N'PURE DALAI', N'परे दलई', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (572, 576, NULL, N'SIRAULI GAUSPUR', N'सिरौली गौसपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (573, 572, NULL, N'SHIVPUR', N'शिवपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (574, 572, NULL, N'RISIA', N'रिसिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (575, 572, NULL, N'MIHIPURWA', N'मिहिपुरवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (576, 572, NULL, N'NAWABGANJ', N'नवाबगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (577, 572, NULL, N'BALHA', N'बल्हा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (578, 572, NULL, N'CHITTAURA', N'चित्तौरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (579, 572, NULL, N'PAYAGPUR', N'पयागपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (580, 572, NULL, N'VISHESHWARGANJ', N'विशेश्वरगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (581, 572, NULL, N'MAHSI', N'महसी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (582, 572, NULL, N'TAJWAPUR', N'तजवापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (583, 572, NULL, N'FAKHARPUR', N'फकहरपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (584, 572, NULL, N'HUJURPUR', N'हुजूरपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (585, 572, NULL, N'KAISARGANJ', N'कैसरगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (586, 572, NULL, N'JARWAL', N'जरवल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (587, 596, NULL, N'RUPIDIH', N'रूपीडीह', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (588, 596, NULL, N'ITIA THOK', N'ईतिया थोक', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (589, 596, NULL, N'PANDRI KRIPAL', N'पण्डरी कृपाल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (590, 596, NULL, N'JHANJHARI', N'झांझरी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (591, 596, NULL, N'MUJEHNA', N'मुजेहना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (592, 596, NULL, N'GONDA SADAR', N'गोण्डा सदर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (593, 596, NULL, N'KATRA BAZAR', N'कटरा बाजार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (594, 596, NULL, N'HALDHARMAU', N'हलधरमऊ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (595, 596, NULL, N'KARNAILGANJ', N'करनैलगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (596, 596, NULL, N'PARASPUR', N'पारसपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (597, 596, NULL, N'BELSAR', N'बेलसर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (598, 596, NULL, N'TARABGANJ', N'तरबगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (599, 596, NULL, N'VAJIRGANJ', N'वजीरगंज', N'UN')
GO
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (600, 596, NULL, N'NAWABGANJ', N'नवाबगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (601, 596, NULL, N'MANKAPUR', N'मनकापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (602, 596, NULL, N'BABHANJOT', N'बभानजोत', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (603, 596, NULL, N'CHAPIA', N'छपिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (604, 633, NULL, N'HARIHARPUR RANI', N'हरिहरपुर रानी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (605, 633, NULL, N'SIRSIA', N'सिरसिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (606, 633, NULL, N'JAMUNHA', N'जमुनहा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (607, 633, NULL, N'GILAULA', N'गिलौला', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (608, 633, NULL, N'IKAUNA', N'इकौना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (609, 102, NULL, N'HAREYA SATGHARWA', N'हरेया सतगढ़वा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (610, 102, NULL, N'BALRAMPUR', N'बलरामपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (611, 102, NULL, N'TULSIPUR', N'तुलसीपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (612, 102, NULL, N'GASDI', N'गसडी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (613, 102, NULL, N'PACHPEDWA', N'पचपेड़वा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (614, 102, NULL, N'SHRI DATTAGANJ', N'श्री दत्तागंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (615, 102, NULL, N'UTTRAULA', N'उतरौला', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (616, 102, NULL, N'GANDHAS BUJURG', N'गंधास बुजुर्ग', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (617, 102, NULL, N'REHRA BAZAR', N'रेहरा बाजार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (618, 639, NULL, N'BARAGAON', N'बड़ागाँव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (619, 639, NULL, N'PINDRA', N'पिण्डरा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (620, 639, NULL, N'CHOLAPUR', N'चोलापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (621, 639, NULL, N'CHIRAIGAON', N'चिरईगाँव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (622, 639, NULL, N'SEWAPURI', N'सेवापुरी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (623, 639, NULL, N'ARAJI LINE', N'अराजी लाइन', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (624, 639, NULL, N'KASHI VIDYAPITH (URBAN)', N'काशी विद्यापीठ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (625, 639, NULL, N'HARHUA', N'हरहुआ', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (626, 639, NULL, N'RAJA TALAB', N'राजा तालाब', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (627, 639, NULL, N'SHAHARI KSHETRA', N'शहरी क्षेत्र', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (628, 595, NULL, N'JAKHNIA', N'जखनिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (629, 595, NULL, N'MANIHARI', N'मनिहरि', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (630, 595, NULL, N'SAADAT', N'सादत', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (631, 595, NULL, N'SAIDPUR', N'सैदपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (632, 595, NULL, N'DEVKALI', N'देवकाली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (633, 595, NULL, N'VIRNO', N'विरनोपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (634, 595, NULL, N'MARDAH', N'मरदह', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (635, 595, NULL, N'GAZIPUR', N'गाजीपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (636, 595, NULL, N'KARANDA', N'करण्डा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (637, 595, NULL, N'KASIMABAD', N'कसीमाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (638, 595, NULL, N'WARACHAWAR', N'बाराचवर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (639, 595, NULL, N'MOHAMMADABAD', N'मुहम्मदाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (640, 595, NULL, N'BHAWARKOL', N'भवरकोल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (641, 595, NULL, N'JAMANIA', N'जमानिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (642, 595, NULL, N'REWATIPUR', N'रेवतीपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (643, 595, NULL, N'BHADAURA', N'भदौरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (644, 602, NULL, N'SODHI', N'सोढी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (645, 602, NULL, N'SUITHAKALAN', N'सुइथाकलां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (646, 602, NULL, N'SHAHGANJ', N'शाहगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (647, 602, NULL, N'KHUTHAN', N'खुटहन', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (648, 602, NULL, N'KARANJAKALAN', N'करन्जाकलां', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (649, 602, NULL, N'BAKSHA', N'बक्सा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (650, 602, NULL, N'SIKRARA', N'सिकरारा', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (651, 602, NULL, N'DHARMAPUR', N'धर्मापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (652, 602, NULL, N'SIRKONI', N'सिरकोनी', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (653, 602, NULL, N'BADLAPUR', N'बदलापुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (654, 602, NULL, N'MAHARAJGANJ SADAR', N'महराजगंज सदर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (655, 602, NULL, N'SUJANGANJ', N'सुजानगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (656, 602, NULL, N'MUGRABADSHAHPUR', N'मुंगराबादशाहपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (657, 602, NULL, N'MACHHALISHAHAR', N'मछलीशहर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (658, 602, NULL, N'MADHIYAHUN', N'मडियाहूं', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (659, 602, NULL, N'BARSATHI', N'बरसठी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (660, 602, NULL, N'RAMNAGAR', N'रामनगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (661, 602, NULL, N'RAMPUR', N'रामपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (662, 602, NULL, N'MUFTIGANJ', N'मुफ्तीगंज', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (663, 602, NULL, N'JALALPUR', N'जलालपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (664, 602, NULL, N'KERAKAT', N'केराकत', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (665, 602, NULL, N'DOBHI', N'डोभी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (666, 583, NULL, N'CHAHNIA', N'चहनिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (667, 583, NULL, N'DHANAPUR', N'धनापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (668, 583, NULL, N'SAKALDIHA', N'सकलडीहा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (669, 583, NULL, N'NIAMTABAD', N'नियमताबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (670, 583, NULL, N'CHANDAULI', N'चन्दौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (671, 583, NULL, N'BARHANI', N'बरहनी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (672, 583, NULL, N'CHAKIA', N'चकिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (673, 583, NULL, N'SHAHABGANJ', N'शाहबगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (674, 583, NULL, N'NAUGARH', N'नौगढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (675, 620, NULL, N'SADAR', N'सदर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (676, 620, NULL, N'CHHANVE', N'छानबे', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (677, 620, NULL, N'KONE', N'कोन', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (678, 620, NULL, N'MAJHWAN', N'मझवाँ', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (679, 620, NULL, N'NAGAR CITY', N'नगर सिटी', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (680, 620, NULL, N'PAHARI', N'पहाडी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (681, 620, NULL, N'LALGANJ', N'लालगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (682, 620, NULL, N'HALIA', N'हलिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (683, 620, NULL, N'MADIHAN', N'मडीहां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (684, 620, NULL, N'RAJGARH', N'राजगढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (685, 620, NULL, N'SIKHAD', N'सीखड़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (686, 620, NULL, N'NARAYANPUR', N'नारायणपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (687, 620, NULL, N'JAMALPUR', N'जमालपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (688, 636, NULL, N'GHORAWAL', N'घोरावल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (689, 636, NULL, N'ROBERTSGANJ', N'रार्बट्सगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (690, 636, NULL, N'CHATRA', N'छतरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (691, 636, NULL, N'NAGWA', N'नगवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (692, 636, NULL, N'CHOPAN', N'चोपन', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (693, 636, NULL, N'MYORPUR', N'मयूरपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (694, 636, NULL, N'DUDDHI', N'दुद्धी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (695, 636, NULL, N'BABHNI', N'बभनी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (696, 631, NULL, N'SURIAWAN', N'सुरियावाँ', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (697, 631, NULL, N'BHADOHI', N'भदोही', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (698, 631, NULL, N'ABHOLI', N'अभोली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (699, 631, NULL, N'AURAI', N'औराई', N'UN')
GO
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (700, 631, NULL, N'GYANPUR', N'ज्ञानपुर', N'N')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (701, 631, NULL, N'DEEGH', N'डीह', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (702, 570, NULL, N'ATRAULIA', N'अतरौलिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (703, 570, NULL, N'KOYALSA', N'कोयलसा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (704, 570, NULL, N'AHIRAULA', N'अहिरौला', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (705, 570, NULL, N'MAHRAJGANJ', N'महाराजगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (706, 570, NULL, N'HARAIYA', N'हरैया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (707, 570, NULL, N'BILARIAGANJ', N'बिलारियागंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (708, 570, NULL, N'AJMATGARH', N'अजमतगढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (709, 570, NULL, N'TAHBARPUR', N'तहबरपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (710, 570, NULL, N'MIRZAPUR', N'मिर्जापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (711, 570, NULL, N'MOHAMADPUR', N'मोहम्मदपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (712, 570, NULL, N'RANI KI SARAI', N'रानी की सराय', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (713, 570, NULL, N'PALHANI', N'पल्हनी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (714, 570, NULL, N'SATHIYAON', N'सठियांव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (715, 570, NULL, N'JAHANAGANJ', N'जहानागंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (716, 570, NULL, N'PAWAI', N'पवई', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (717, 570, NULL, N'PHULPUR', N'फूलपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (718, 570, NULL, N'MARTINGANJ', N'मार्टिनगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (719, 570, NULL, N'THEKMA', N'ठेकमा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (720, 570, NULL, N'LALGANJ', N'लालगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (721, 570, NULL, N'TARWA', N'तर्वा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (722, 570, NULL, N'PALHANA', N'पल्‍हना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (723, 570, NULL, N'MEHNAGAR', N'मेहनगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (724, 573, NULL, N'SIYAR', N'सियार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (725, 573, NULL, N'NAGRA', N'नगरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (726, 573, NULL, N'RASRA', N'रसडा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (727, 573, NULL, N'CHILKAHAR', N'चिलकहर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (728, 573, NULL, N'NAWANAGAR', N'नवानगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (729, 573, NULL, N'PANDAH', N'पंडाह', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (730, 573, NULL, N'MANIYAR', N'मनियार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (731, 573, NULL, N'BERUARBARI', N'बेरूआबरी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (732, 573, NULL, N'BASDIH', N'बांसडीह', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (733, 573, NULL, N'REVATI', N'रेवती', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (734, 573, NULL, N'GADWAR', N'गडवर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (735, 573, NULL, N'SOHAON', N'सोहांव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (736, 573, NULL, N'HANUMANGANJ', N'हनुमानगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (737, 573, NULL, N'DUBHAD', N'दुबहड', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (738, 573, NULL, N'BELHARI', N'बेलहरि', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (739, 573, NULL, N'BAIRIYA', N'बैरिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (740, 573, NULL, N'MURLI CHHAPRA', N'मुरली छपरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (741, 573, NULL, N'NAVAN NAGAR', N'नवां नगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (742, 573, NULL, N'SEEYAR', N'सीयर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (743, 618, NULL, N'DOHRI GHAT', N'दोहरीघाट', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (744, 618, NULL, N'FATEHPUR MANDWAN', N'फतेहपुर मण्डवां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (745, 618, NULL, N'GHOSI', N'घोसी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (746, 618, NULL, N'BADRAON', N'बदरावं', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (747, 618, NULL, N'KOPAGANJ', N'कोपागंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (748, 618, NULL, N'FARDAHA', N'फरदहा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (749, 618, NULL, N'RATANPURA', N'रतनपुरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (750, 618, NULL, N'MUHAMMADABAD', N'मुहम्मदाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (751, 618, NULL, N'RANIPUR', N'रानीपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (752, 578, NULL, N'DUBAULIA', N'दुबौलिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (753, 578, NULL, N'PARASRAMPUR', N'पारसरामपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (754, 578, NULL, N'GAUR', N'गौर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (755, 578, NULL, N'HARAIYA', N'हरैया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (756, 578, NULL, N'VIKRAM JOT', N'विक्रमजोत', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (757, 578, NULL, N'KAPTANGANJ', N'कप्तानगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (758, 578, NULL, N'RAMNAGAR', N'रामनगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (759, 578, NULL, N'SALTAUA GOPALPUR', N'सलतौआ गोपालपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (760, 578, NULL, N'RUDHAULI', N'रूधौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (761, 578, NULL, N'SAUNGHAT', N'सौनघाट', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (762, 578, NULL, N'BASTI SADAR', N'बस्ती सदर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (763, 578, NULL, N'BANKATI', N'बनकटी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (764, 578, NULL, N'BAHADURPUR', N'बहादुरपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (765, 578, NULL, N'KUDRAHA', N'कुडरहा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (766, 578, NULL, N'CHHARAUNCHHA', N'छरौंछा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (767, 630, NULL, N'BAGHAULI', N'बघौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (768, 630, NULL, N'KHALILABAD', N'खलीलाबाद', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (769, 630, NULL, N'SEMRIANWA', N'सेमरींवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (770, 630, NULL, N'MEHDAVAL', N'मेहदावल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (771, 630, NULL, N'SANTHA', N'सन्था', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (772, 630, NULL, N'BELHAR KALAN', N'बेलहर कलां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (773, 630, NULL, N'PAALI', N'पाली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (774, 630, NULL, N'NATHNAGAR', N'नाथनगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (775, 630, NULL, N'HAISAR BAZAR', N'हैसर बाजार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (776, 634, NULL, N'KHUNIYAWAN', N'खुनियावां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (777, 634, NULL, N'ITWA', N'इटवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (778, 634, NULL, N'BHANABAPUR', N'भनबापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (779, 634, NULL, N'BARHNI', N'बरहनी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (780, 634, NULL, N'SHOHARATGARH', N'शोहरतगढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (781, 634, NULL, N'BARDPUR', N'बर्दपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (782, 634, NULL, N'JOGIA', N'जोगिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (783, 634, NULL, N'USKA BAZAR', N'उसका बाजार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (784, 634, NULL, N'LOTAN', N'लोटन', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (785, 634, NULL, N'NAUGARH', N'नौगढ़', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (786, 634, NULL, N'DUMARIA GANJ', N'डुमरियागंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (787, 634, NULL, N'BANSI', N'बांसी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (788, 634, NULL, N'MITHVAL', N'मिथवल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (789, 634, NULL, N'KHESRAHA', N'खेसरहा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (790, 597, NULL, N'PALI', N'पाली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (791, 597, NULL, N'SAHJANWA', N'सहजनवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (792, 597, NULL, N'PIPRAULI', N'पिपरौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (793, 597, NULL, N'JANGAL KAUDIA', N'जंगल कौदिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (794, 597, NULL, N'CHARGAWAN', N'चरगवां', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (795, 597, NULL, N'BHATHAT', N'भतहत', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (796, 597, NULL, N'PIPRAICH', N'पिराईच', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (797, 597, NULL, N'SARDARNAGAR', N'सरदारनगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (798, 597, NULL, N'KHORABAR', N'खोराबर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (799, 597, NULL, N'GORAKHPUR SADAR (N.K.)', N'गोरखपुर सदर (एन०के०)', N'UN')
GO
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (800, 597, NULL, N'BRAHMAPUR', N'ब्रह्मापुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (801, 597, NULL, N'KAUDIRAM', N'कौडीराम', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (802, 597, NULL, N'BANSGAON', N'बांसगांव', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (803, 597, NULL, N'URUWA', N'ऊरूवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (804, 597, NULL, N'GANGHA', N'गंघा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (805, 597, NULL, N'KHAJANI', N'खजनी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (806, 597, NULL, N'BELGHAT', N'बेलघाट', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (807, 597, NULL, N'GOLA', N'गोला', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (808, 597, NULL, N'BARHALGANJ', N'बडहलगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (809, 597, NULL, N'CAMPIYARGANJ', N'कैम्पियरगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (810, 586, NULL, N'GAURI BAZAR', N'गौरी बाजार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (811, 586, NULL, N'BAITALPUR', N'बैतालपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (812, 586, NULL, N'DESI DEVARIA', N'देसी देवरिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (813, 586, NULL, N'PATHARDEWA', N'पत्थरदेवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (814, 586, NULL, N'RAMPUR KARKHANA', N'रामपुर कारखाना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (815, 586, NULL, N'DEORIA ', N'देवरिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (816, 586, NULL, N'TARKULWA', N'तरकुलवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (817, 586, NULL, N'RUDRAPUR', N'रूद्रपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (818, 586, NULL, N'BHULUANI', N'भुलुआनी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (819, 586, NULL, N'BARHAZ', N'बरहज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (820, 586, NULL, N'BHATNI', N'भटनी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (821, 586, NULL, N'BHATPARRANI', N'भाटपाररानी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (822, 586, NULL, N'BANKATA', N'बनकटा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (823, 586, NULL, N'SALEMPUR', N'सलेमपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (824, 586, NULL, N'BHAGALPUR', N'भागलपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (825, 586, NULL, N'LAR', N'लार', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (826, 614, NULL, N'NAUTANWAN', N'नौतनवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (827, 614, NULL, N'LAKSHMIPUR', N'लक्ष्मीपुर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (828, 614, NULL, N'NICHLAUL', N'निचलौल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (829, 614, NULL, N'MITAURA', N'मितौरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (830, 614, NULL, N'SISWA', N'सिसवा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (831, 614, NULL, N'VRIJMANGANJ', N'वृजमानगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (832, 614, NULL, N'DHANI', N'धनी', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (833, 614, NULL, N'FARENDA', N'फरेन्दा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (834, 614, NULL, N'MAHARAJGANJ SADAR', N'महाराजगंज सदर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (835, 614, NULL, N'GHUGLI', N'घुघली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (836, 614, NULL, N'PANIYARA', N'पनियारा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (837, 614, NULL, N'PARTAWAL', N'परतावाल', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (838, 610, NULL, N'KAPTANGANJ', N'कप्तानगंज', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (839, 610, NULL, N'RAMKOLA', N'रामकोला', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (840, 610, NULL, N'MOTICHAK', N'मोतीचक', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (841, 610, NULL, N'SUKRAULI', N'सुरौली', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (842, 610, NULL, N'HATA', N'हाटा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (843, 610, NULL, N'KHADDA', N'खद्दा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (844, 610, NULL, N'NEBUA NAURGIA', N'नेबुआ नौरगिया', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (845, 610, NULL, N'BISHUNPURA', N'बिशुनपुरा', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (846, 610, NULL, N'PADRAUNA', N'पडरौना', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (847, 610, NULL, N'KASYA', N'कस्या', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (848, 610, NULL, N'FAJILNAGAR', N'फाजिलनगर', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (849, 610, NULL, N'TAMKUHI', N'तमकुही', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (850, 610, NULL, N'SEVRAHI', N'सेवरही', N'UN')
INSERT [dbo].[M_Block] ([BlockID], [DistrictID], [BlockCode], [BlockName], [BlockNameHindi], [Status]) VALUES (851, 610, NULL, N'DUDHI', N'दुद्धी', N'UN')
SET IDENTITY_INSERT [dbo].[M_Block] OFF
SET IDENTITY_INSERT [dbo].[M_District] ON 

INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (1, 1, NULL, N'Nicobar', NULL, 1)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (2, 1, NULL, N'North and Middle Andaman', NULL, 2)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (3, 1, NULL, N'South Andaman', NULL, 3)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (4, 2, NULL, N'Anantapur', NULL, 4)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (5, 2, NULL, N'Chittoor', NULL, 5)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (6, 2, NULL, N'Cuddapah', NULL, 6)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (7, 2, NULL, N'East Godavari', NULL, 7)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (8, 2, NULL, N'Guntur', NULL, 8)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (9, 2, NULL, N'Krishna', NULL, 9)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (10, 2, NULL, N'Kurnool', NULL, 10)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (11, 2, NULL, N'Nellore', NULL, 11)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (12, 2, NULL, N'Prakasam', NULL, 12)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (13, 2, NULL, N'Srikakulam', NULL, 13)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (14, 2, NULL, N'Visakhapatnam', NULL, 14)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (15, 2, NULL, N'Vizianagaram', NULL, 15)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (16, 2, NULL, N'West Godavari', NULL, 16)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (17, 3, NULL, N'Anjaw', NULL, 17)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (18, 3, NULL, N'Changlang', NULL, 18)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (19, 3, NULL, N'Dibang Valley', NULL, 19)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (20, 3, NULL, N'East Kameng', NULL, 20)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (21, 3, NULL, N'East Siang', NULL, 21)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (22, 3, NULL, N'Kurung Kumey', NULL, 22)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (23, 3, NULL, N'Lohit', NULL, 23)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (24, 3, NULL, N'Longding', NULL, 24)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (25, 3, NULL, N'Lower Dibang Valley', NULL, 25)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (26, 3, NULL, N'Lower Subansiri', NULL, 26)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (27, 3, NULL, N'Papum Pare', NULL, 27)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (28, 3, NULL, N'Tawang', NULL, 28)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (29, 3, NULL, N'Tirap', NULL, 29)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (30, 3, NULL, N'Upper Siang', NULL, 30)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (31, 3, NULL, N'Upper Subansiri', NULL, 31)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (32, 3, NULL, N'West Kameng', NULL, 32)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (33, 3, NULL, N'West Siang', NULL, 33)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (34, 4, NULL, N'Baksa', NULL, 34)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (35, 4, NULL, N'Barpeta', NULL, 35)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (36, 4, NULL, N'Bongaigaon', NULL, 36)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (37, 4, NULL, N'Cachar', NULL, 37)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (38, 4, NULL, N'Chirang', NULL, 38)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (39, 4, NULL, N'Darrang', NULL, 39)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (40, 4, NULL, N'Dhemaji', NULL, 40)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (41, 4, NULL, N'Dhubri', NULL, 41)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (42, 4, NULL, N'Dibrugarh', NULL, 42)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (43, 4, NULL, N'Dima Hasao', NULL, 43)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (44, 4, NULL, N'Goalpara', NULL, 44)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (45, 4, NULL, N'Golaghat', NULL, 45)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (46, 4, NULL, N'Hailakandi', NULL, 46)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (47, 4, NULL, N'Jorhat', NULL, 47)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (48, 4, NULL, N'Kamrup Metropolitan', NULL, 48)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (49, 4, NULL, N'Kamrup', NULL, 49)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (50, 4, NULL, N'Karbi Anglong', NULL, 50)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (51, 4, NULL, N'Karimganj', NULL, 51)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (52, 4, NULL, N'Kokrajhar', NULL, 52)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (53, 4, NULL, N'Lakhimpur', NULL, 53)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (54, 4, NULL, N'Morigaon', NULL, 54)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (55, 4, NULL, N'Nagaon', NULL, 55)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (56, 4, NULL, N'Nalbari', NULL, 56)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (57, 4, NULL, N'Sivasagar', NULL, 57)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (58, 4, NULL, N'Sonitpur', NULL, 58)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (59, 4, NULL, N'Tinsukia', NULL, 59)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (60, 4, NULL, N'Udalguri', NULL, 60)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (61, 5, NULL, N'Araria', NULL, 61)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (62, 5, NULL, N'Arwal', NULL, 62)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (63, 5, NULL, N'Aurangabad', NULL, 63)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (64, 5, NULL, N'Banka', NULL, 64)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (65, 5, NULL, N'Begusarai', NULL, 65)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (66, 5, NULL, N'Bhagalpur', NULL, 66)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (67, 5, NULL, N'Bhojpur', NULL, 67)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (68, 5, NULL, N'Buxar', NULL, 68)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (69, 5, NULL, N'Darbhanga', NULL, 69)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (70, 5, NULL, N'East Champaran (Motihari)', NULL, 70)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (71, 5, NULL, N'Gaya', NULL, 71)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (72, 5, NULL, N'Gopalganj', NULL, 72)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (73, 5, NULL, N'Jamui', NULL, 73)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (74, 5, NULL, N'Jehanabad', NULL, 74)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (75, 5, NULL, N'Kaimur (Bhabua)', NULL, 75)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (76, 5, NULL, N'Katihar', NULL, 76)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (77, 5, NULL, N'Khagaria', NULL, 77)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (78, 5, NULL, N'Kishanganj', NULL, 78)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (79, 5, NULL, N'Lakhisarai', NULL, 79)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (80, 5, NULL, N'Madhepura', NULL, 80)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (81, 5, NULL, N'Madhubani', NULL, 81)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (82, 5, NULL, N'Munger (Monghyr)', NULL, 82)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (83, 5, NULL, N'Muzaffarpur', NULL, 83)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (84, 5, NULL, N'Nalanda', NULL, 84)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (85, 5, NULL, N'Nawada', NULL, 85)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (86, 5, NULL, N'Patna', NULL, 86)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (87, 5, NULL, N'Purnia (Purnea)', NULL, 87)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (88, 5, NULL, N'Rohtas', NULL, 88)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (89, 5, NULL, N'Saharsa', NULL, 89)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (90, 5, NULL, N'Samastipur', NULL, 90)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (91, 5, NULL, N'Saran', NULL, 91)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (92, 5, NULL, N'Sheikhpura', NULL, 92)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (93, 5, NULL, N'Sheohar', NULL, 93)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (94, 5, NULL, N'Sitamarhi', NULL, 94)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (95, 5, NULL, N'Siwan', NULL, 95)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (96, 5, NULL, N'Supaul', NULL, 96)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (97, 5, NULL, N'Vaishali', NULL, 97)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (98, 5, NULL, N'West Champaran', NULL, 98)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (99, 6, NULL, N'Chandigarh', NULL, 99)
GO
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (100, 7, NULL, N'Balod', NULL, 100)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (101, 7, NULL, N'Baloda Bazar', NULL, 101)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (102, 7, NULL, N'Balrampur', NULL, 102)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (103, 7, NULL, N'Bastar', NULL, 103)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (104, 7, NULL, N'Bemetara', NULL, 104)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (105, 7, NULL, N'Bijapur', NULL, 105)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (106, 7, NULL, N'Bilaspur', NULL, 106)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (107, 7, NULL, N'Dantewada (South Bastar)', NULL, 107)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (108, 7, NULL, N'Dhamtari', NULL, 108)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (109, 7, NULL, N'Durg', NULL, 109)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (110, 7, NULL, N'Gariaband', NULL, 110)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (111, 7, NULL, N'Janjgir-Champa', NULL, 111)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (112, 7, NULL, N'Jashpur', NULL, 112)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (113, 7, NULL, N'Kabirdham (Kawardha)', NULL, 113)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (114, 7, NULL, N'Kanker (North Bastar)', NULL, 114)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (115, 7, NULL, N'Kondagaon', NULL, 115)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (116, 7, NULL, N'Korba', NULL, 116)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (117, 7, NULL, N'Korea (Koriya)', NULL, 117)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (118, 7, NULL, N'Mahasamund', NULL, 118)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (119, 7, NULL, N'Mungeli', NULL, 119)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (120, 7, NULL, N'Narayanpur', NULL, 120)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (121, 7, NULL, N'Raigarh', NULL, 121)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (122, 7, NULL, N'Raipur', NULL, 122)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (123, 7, NULL, N'Rajnandgaon', NULL, 123)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (124, 7, NULL, N'Sukma', NULL, 124)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (125, 7, NULL, N'Surajpur', NULL, 125)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (126, 7, NULL, N'Surguja', NULL, 126)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (127, 8, NULL, N'Dadra & Nagar Haveli', NULL, 127)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (128, 9, NULL, N'Daman', NULL, 128)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (129, 9, NULL, N'Diu', NULL, 129)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (130, 10, NULL, N'Central Delhi', NULL, 130)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (131, 10, NULL, N'East Delhi', NULL, 131)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (132, 10, NULL, N'New Delhi', NULL, 132)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (133, 10, NULL, N'North Delhi', NULL, 133)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (134, 10, NULL, N'North East Delhi', NULL, 134)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (135, 10, NULL, N'North West Delhi', NULL, 135)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (136, 10, NULL, N'South Delhi', NULL, 136)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (137, 10, NULL, N'South West Delhi', NULL, 137)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (138, 10, NULL, N'West Delhi', NULL, 138)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (139, 11, NULL, N'North Goa', NULL, 139)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (140, 11, NULL, N'South Goa', NULL, 140)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (141, 12, NULL, N'Ahmedabad', NULL, 141)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (142, 12, NULL, N'Amreli', NULL, 142)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (143, 12, NULL, N'Anand', NULL, 143)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (144, 12, NULL, N'Aravalli', NULL, 144)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (145, 12, NULL, N'Banaskantha (Palanpur)', NULL, 145)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (146, 12, NULL, N'Bharuch', NULL, 146)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (147, 12, NULL, N'Bhavnagar', NULL, 147)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (148, 12, NULL, N'Botad', NULL, 148)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (149, 12, NULL, N'Chhota Udepur', NULL, 149)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (150, 12, NULL, N'Dahod', NULL, 150)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (151, 12, NULL, N'Dangs (Ahwa)', NULL, 151)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (152, 12, NULL, N'Devbhoomi Dwarka', NULL, 152)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (153, 12, NULL, N'Gandhinagar', NULL, 153)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (154, 12, NULL, N'Gir Somnath', NULL, 154)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (155, 12, NULL, N'Jamnagar', NULL, 155)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (156, 12, NULL, N'Junagadh', NULL, 156)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (157, 12, NULL, N'Kachchh', NULL, 157)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (158, 12, NULL, N'Kheda (Nadiad)', NULL, 158)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (159, 12, NULL, N'Mahisagar', NULL, 159)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (160, 12, NULL, N'Mehsana', NULL, 160)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (161, 12, NULL, N'Morbi', NULL, 161)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (162, 12, NULL, N'Narmada (Rajpipla)', NULL, 162)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (163, 12, NULL, N'Navsari', NULL, 163)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (164, 12, NULL, N'Panchmahal (Godhra)', NULL, 164)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (165, 12, NULL, N'Patan', NULL, 165)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (166, 12, NULL, N'Porbandar', NULL, 166)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (167, 12, NULL, N'Rajkot', NULL, 167)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (168, 12, NULL, N'Sabarkantha (Himmatnagar)', NULL, 168)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (169, 12, NULL, N'Surat', NULL, 169)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (170, 12, NULL, N'Surendranagar', NULL, 170)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (171, 12, NULL, N'Tapi (Vyara)', NULL, 171)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (172, 12, NULL, N'Vadodara', NULL, 172)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (173, 12, NULL, N'Valsad', NULL, 173)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (174, 13, NULL, N'Ambala', NULL, 174)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (175, 13, NULL, N'Bhiwani', NULL, 175)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (176, 13, NULL, N'Faridabad', NULL, 176)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (177, 13, NULL, N'Fatehabad', NULL, 177)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (178, 13, NULL, N'Gurgaon', NULL, 178)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (179, 13, NULL, N'Hisar', NULL, 179)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (180, 13, NULL, N'Jhajjar', NULL, 180)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (181, 13, NULL, N'Jind', NULL, 181)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (182, 13, NULL, N'Kaithal', NULL, 182)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (183, 13, NULL, N'Karnal', NULL, 183)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (184, 13, NULL, N'Kurukshetra', NULL, 184)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (185, 13, NULL, N'Mahendragarh', NULL, 185)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (186, 13, NULL, N'Mewat', NULL, 186)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (187, 13, NULL, N'Palwal', NULL, 187)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (188, 13, NULL, N'Panchkula', NULL, 188)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (189, 13, NULL, N'Panipat', NULL, 189)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (190, 13, NULL, N'Rewari', NULL, 190)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (191, 13, NULL, N'Rohtak', NULL, 191)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (192, 13, NULL, N'Sirsa', NULL, 192)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (193, 13, NULL, N'Sonipat', NULL, 193)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (194, 13, NULL, N'Yamunanagar', NULL, 194)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (195, 14, NULL, N'Bilaspur', NULL, 195)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (196, 14, NULL, N'Chamba', NULL, 196)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (197, 14, NULL, N'Hamirpur', NULL, 197)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (198, 14, NULL, N'Kangra', NULL, 198)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (199, 14, NULL, N'Kinnaur', NULL, 199)
GO
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (200, 14, NULL, N'Kullu', NULL, 200)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (201, 14, NULL, N'Lahaul & Spiti', NULL, 201)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (202, 14, NULL, N'Mandi', NULL, 202)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (203, 14, NULL, N'Shimla', NULL, 203)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (204, 14, NULL, N'Sirmaur (Sirmour)', NULL, 204)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (205, 14, NULL, N'Solan', NULL, 205)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (206, 14, NULL, N'Una', NULL, 206)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (207, 15, NULL, N'Anantnag', NULL, 207)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (208, 15, NULL, N'Bandipora', NULL, 208)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (209, 15, NULL, N'Baramulla', NULL, 209)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (210, 15, NULL, N'Budgam', NULL, 210)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (211, 15, NULL, N'Doda', NULL, 211)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (212, 15, NULL, N'Ganderbal', NULL, 212)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (213, 15, NULL, N'Jammu', NULL, 213)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (214, 15, NULL, N'Kargil', NULL, 214)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (215, 15, NULL, N'Kathua', NULL, 215)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (216, 15, NULL, N'Kishtwar', NULL, 216)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (217, 15, NULL, N'Kulgam', NULL, 217)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (218, 15, NULL, N'Kupwara', NULL, 218)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (219, 15, NULL, N'Leh', NULL, 219)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (220, 15, NULL, N'Poonch', NULL, 220)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (221, 15, NULL, N'Pulwama', NULL, 221)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (222, 15, NULL, N'Rajouri', NULL, 222)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (223, 15, NULL, N'Ramban', NULL, 223)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (224, 15, NULL, N'Reasi', NULL, 224)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (225, 15, NULL, N'Samba', NULL, 225)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (226, 15, NULL, N'Shopian', NULL, 226)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (227, 15, NULL, N'Srinagar', NULL, 227)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (228, 15, NULL, N'Udhampur', NULL, 228)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (229, 16, NULL, N'Bokaro', NULL, 229)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (230, 16, NULL, N'Chatra', NULL, 230)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (231, 16, NULL, N'Deoghar', NULL, 231)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (232, 16, NULL, N'Dhanbad', NULL, 232)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (233, 16, NULL, N'Dumka', NULL, 233)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (234, 16, NULL, N'East Singhbhum', NULL, 234)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (235, 16, NULL, N'Garhwa', NULL, 235)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (236, 16, NULL, N'Giridih', NULL, 236)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (237, 16, NULL, N'Godda', NULL, 237)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (238, 16, NULL, N'Gumla', NULL, 238)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (239, 16, NULL, N'Hazaribag', NULL, 239)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (240, 16, NULL, N'Jamtara', NULL, 240)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (241, 16, NULL, N'Khunti', NULL, 241)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (242, 16, NULL, N'Koderma', NULL, 242)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (243, 16, NULL, N'Latehar', NULL, 243)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (244, 16, NULL, N'Lohardaga', NULL, 244)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (245, 16, NULL, N'Pakur', NULL, 245)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (246, 16, NULL, N'Palamu', NULL, 246)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (247, 16, NULL, N'Ramgarh', NULL, 247)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (248, 16, NULL, N'Ranchi', NULL, 248)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (249, 16, NULL, N'Sahibganj', NULL, 249)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (250, 16, NULL, N'Seraikela-Kharsawan', NULL, 250)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (251, 16, NULL, N'Simdega', NULL, 251)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (252, 16, NULL, N'West Singhbhum', NULL, 252)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (253, 17, NULL, N'Bagalkot', NULL, 253)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (254, 17, NULL, N'Bangalore Rural', NULL, 254)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (255, 17, NULL, N'Bangalore Urban', NULL, 255)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (256, 17, NULL, N'Belgaum', NULL, 256)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (257, 17, NULL, N'Bellary', NULL, 257)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (258, 17, NULL, N'Bidar', NULL, 258)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (259, 17, NULL, N'Bijapur', NULL, 259)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (260, 17, NULL, N'Chamarajanagar', NULL, 260)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (261, 17, NULL, N'Chickmagalur', NULL, 261)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (262, 17, NULL, N'Chikballapur', NULL, 262)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (263, 17, NULL, N'Chitradurga', NULL, 263)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (264, 17, NULL, N'Dakshina Kannada', NULL, 264)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (265, 17, NULL, N'Davangere', NULL, 265)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (266, 17, NULL, N'Dharwad', NULL, 266)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (267, 17, NULL, N'Gadag', NULL, 267)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (268, 17, NULL, N'Gulbarga', NULL, 268)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (269, 17, NULL, N'Hassan', NULL, 269)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (270, 17, NULL, N'Haveri', NULL, 270)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (271, 17, NULL, N'Kodagu', NULL, 271)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (272, 17, NULL, N'Kolar', NULL, 272)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (273, 17, NULL, N'Koppal', NULL, 273)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (274, 17, NULL, N'Mandya', NULL, 274)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (275, 17, NULL, N'Mysore', NULL, 275)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (276, 17, NULL, N'Raichur', NULL, 276)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (277, 17, NULL, N'Ramnagara', NULL, 277)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (278, 17, NULL, N'Shimoga', NULL, 278)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (279, 17, NULL, N'Tumkur', NULL, 279)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (280, 17, NULL, N'Udupi', NULL, 280)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (281, 17, NULL, N'Uttara Kannada (Karwar)', NULL, 281)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (282, 17, NULL, N'Yadgir', NULL, 282)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (283, 18, NULL, N'Alappuzha', NULL, 283)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (284, 18, NULL, N'Ernakulam', NULL, 284)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (285, 18, NULL, N'Idukki', NULL, 285)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (286, 18, NULL, N'Kannur', NULL, 286)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (287, 18, NULL, N'Kasaragod', NULL, 287)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (288, 18, NULL, N'Kollam', NULL, 288)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (289, 18, NULL, N'Kottayam', NULL, 289)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (290, 18, NULL, N'Kozhikode', NULL, 290)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (291, 18, NULL, N'Malappuram', NULL, 291)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (292, 18, NULL, N'Palakkad', NULL, 292)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (293, 18, NULL, N'Pathanamthitta', NULL, 293)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (294, 18, NULL, N'Thiruvananthapuram', NULL, 294)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (295, 18, NULL, N'Thrissur', NULL, 295)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (296, 18, NULL, N'Wayanad', NULL, 296)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (297, 19, NULL, N'Lakshadweep', NULL, 297)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (298, 20, NULL, N'Alirajpur', NULL, 298)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (299, 20, NULL, N'Anuppur', NULL, 299)
GO
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (300, 20, NULL, N'Ashoknagar', NULL, 300)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (301, 20, NULL, N'Balaghat', NULL, 301)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (302, 20, NULL, N'Barwani', NULL, 302)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (303, 20, NULL, N'Betul', NULL, 303)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (304, 20, NULL, N'Bhind', NULL, 304)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (305, 20, NULL, N'Bhopal', NULL, 305)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (306, 20, NULL, N'Burhanpur', NULL, 306)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (307, 20, NULL, N'Chhatarpur', NULL, 307)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (308, 20, NULL, N'Chhindwara', NULL, 308)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (309, 20, NULL, N'Damoh', NULL, 309)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (310, 20, NULL, N'Datia', NULL, 310)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (311, 20, NULL, N'Dewas', NULL, 311)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (312, 20, NULL, N'Dhar', NULL, 312)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (313, 20, NULL, N'Dindori', NULL, 313)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (314, 20, NULL, N'Guna', NULL, 314)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (315, 20, NULL, N'Gwalior', NULL, 315)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (316, 20, NULL, N'Harda', NULL, 316)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (317, 20, NULL, N'Hoshangabad', NULL, 317)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (318, 20, NULL, N'Indore', NULL, 318)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (319, 20, NULL, N'Jabalpur', NULL, 319)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (320, 20, NULL, N'Jhabua', NULL, 320)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (321, 20, NULL, N'Katni', NULL, 321)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (322, 20, NULL, N'Khandwa', NULL, 322)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (323, 20, NULL, N'Khargone', NULL, 323)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (324, 20, NULL, N'Mandla', NULL, 324)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (325, 20, NULL, N'Mandsaur', NULL, 325)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (326, 20, NULL, N'Morena', NULL, 326)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (327, 20, NULL, N'Narsinghpur', NULL, 327)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (328, 20, NULL, N'Neemuch', NULL, 328)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (329, 20, NULL, N'Panna', NULL, 329)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (330, 20, NULL, N'Raisen', NULL, 330)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (331, 20, NULL, N'Rajgarh', NULL, 331)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (332, 20, NULL, N'Ratlam', NULL, 332)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (333, 20, NULL, N'Rewa', NULL, 333)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (334, 20, NULL, N'Sagar', NULL, 334)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (335, 20, NULL, N'Satna', NULL, 335)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (336, 20, NULL, N'Sehore', NULL, 336)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (337, 20, NULL, N'Seoni', NULL, 337)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (338, 20, NULL, N'Shahdol', NULL, 338)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (339, 20, NULL, N'Shajapur', NULL, 339)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (340, 20, NULL, N'Sheopur', NULL, 340)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (341, 20, NULL, N'Shivpuri', NULL, 341)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (342, 20, NULL, N'Sidhi', NULL, 342)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (343, 20, NULL, N'Singrauli', NULL, 343)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (344, 20, NULL, N'Tikamgarh', NULL, 344)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (345, 20, NULL, N'Ujjain', NULL, 345)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (346, 20, NULL, N'Umaria', NULL, 346)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (347, 20, NULL, N'Vidisha', NULL, 347)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (348, 21, NULL, N'Ahmednagar', NULL, 348)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (349, 21, NULL, N'Akola', NULL, 349)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (350, 21, NULL, N'Amravati', NULL, 350)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (351, 21, NULL, N'Aurangabad', NULL, 351)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (352, 21, NULL, N'Beed', NULL, 352)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (353, 21, NULL, N'Bhandara', NULL, 353)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (354, 21, NULL, N'Buldhana', NULL, 354)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (355, 21, NULL, N'Chandrapur', NULL, 355)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (356, 21, NULL, N'Dhule', NULL, 356)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (357, 21, NULL, N'Gadchiroli', NULL, 357)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (358, 21, NULL, N'Gondia', NULL, 358)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (359, 21, NULL, N'Hingoli', NULL, 359)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (360, 21, NULL, N'Jalgaon', NULL, 360)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (361, 21, NULL, N'Jalna', NULL, 361)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (362, 21, NULL, N'Kolhapur', NULL, 362)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (363, 21, NULL, N'Latur', NULL, 363)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (364, 21, NULL, N'Mumbai City', NULL, 364)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (365, 21, NULL, N'Mumbai Suburban', NULL, 365)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (366, 21, NULL, N'Nagpur', NULL, 366)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (367, 21, NULL, N'Nanded', NULL, 367)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (368, 21, NULL, N'Nandurbar', NULL, 368)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (369, 21, NULL, N'Nashik', NULL, 369)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (370, 21, NULL, N'Osmanabad', NULL, 370)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (371, 21, NULL, N'Parbhani', NULL, 371)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (372, 21, NULL, N'Pune', NULL, 372)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (373, 21, NULL, N'Raigad', NULL, 373)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (374, 21, NULL, N'Ratnagiri', NULL, 374)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (375, 21, NULL, N'Sangli', NULL, 375)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (376, 21, NULL, N'Satara', NULL, 376)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (377, 21, NULL, N'Sindhudurg', NULL, 377)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (378, 21, NULL, N'Solapur', NULL, 378)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (379, 21, NULL, N'Thane', NULL, 379)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (380, 21, NULL, N'Wardha', NULL, 380)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (381, 21, NULL, N'Washim', NULL, 381)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (382, 21, NULL, N'Yavatmal', NULL, 382)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (383, 22, NULL, N'Bishnupur', NULL, 383)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (384, 22, NULL, N'Chandel', NULL, 384)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (385, 22, NULL, N'Churachandpur', NULL, 385)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (386, 22, NULL, N'Imphal East', NULL, 386)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (387, 22, NULL, N'Imphal West', NULL, 387)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (388, 22, NULL, N'Senapati', NULL, 388)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (389, 22, NULL, N'Tamenglong', NULL, 389)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (390, 22, NULL, N'Thoubal', NULL, 390)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (391, 22, NULL, N'Ukhrul', NULL, 391)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (392, 23, NULL, N'East Garo Hills', NULL, 392)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (393, 23, NULL, N'East Jaintia Hills', NULL, 393)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (394, 23, NULL, N'East Khasi Hills', NULL, 394)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (395, 23, NULL, N'North Garo Hills', NULL, 395)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (396, 23, NULL, N'Ri Bhoi', NULL, 396)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (397, 23, NULL, N'South Garo Hills', NULL, 397)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (398, 23, NULL, N'South West Garo Hills', NULL, 398)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (399, 23, NULL, N'South West Khasi Hills', NULL, 399)
GO
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (400, 23, NULL, N'West Garo Hills', NULL, 400)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (401, 23, NULL, N'West Jaintia Hills', NULL, 401)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (402, 23, NULL, N'West Khasi Hills', NULL, 402)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (403, 24, NULL, N'Aizawl', NULL, 403)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (404, 24, NULL, N'Champhai', NULL, 404)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (405, 24, NULL, N'Kolasib', NULL, 405)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (406, 24, NULL, N'Lawngtlai', NULL, 406)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (407, 24, NULL, N'Lunglei', NULL, 407)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (408, 24, NULL, N'Mamit', NULL, 408)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (409, 24, NULL, N'Saiha', NULL, 409)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (410, 24, NULL, N'Serchhip', NULL, 410)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (411, 25, NULL, N'Dimapur', NULL, 411)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (412, 25, NULL, N'Kiphire', NULL, 412)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (413, 25, NULL, N'Kohima', NULL, 413)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (414, 25, NULL, N'Longleng', NULL, 414)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (415, 25, NULL, N'Mokokchung', NULL, 415)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (416, 25, NULL, N'Mon', NULL, 416)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (417, 25, NULL, N'Peren', NULL, 417)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (418, 25, NULL, N'Phek', NULL, 418)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (419, 25, NULL, N'Tuensang', NULL, 419)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (420, 25, NULL, N'Wokha', NULL, 420)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (421, 25, NULL, N'Zunheboto', NULL, 421)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (422, 26, NULL, N'Angul', NULL, 422)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (423, 26, NULL, N'Balangir', NULL, 423)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (424, 26, NULL, N'Balasore', NULL, 424)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (425, 26, NULL, N'Bargarh', NULL, 425)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (426, 26, NULL, N'Bhadrak', NULL, 426)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (427, 26, NULL, N'Boudh', NULL, 427)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (428, 26, NULL, N'Cuttack', NULL, 428)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (429, 26, NULL, N'Deogarh', NULL, 429)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (430, 26, NULL, N'Dhenkanal', NULL, 430)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (431, 26, NULL, N'Gajapati', NULL, 431)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (432, 26, NULL, N'Ganjam', NULL, 432)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (433, 26, NULL, N'Jagatsinghapur', NULL, 433)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (434, 26, NULL, N'Jajpur', NULL, 434)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (435, 26, NULL, N'Jharsuguda', NULL, 435)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (436, 26, NULL, N'Kalahandi', NULL, 436)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (437, 26, NULL, N'Kandhamal', NULL, 437)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (438, 26, NULL, N'Kendrapara', NULL, 438)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (439, 26, NULL, N'Kendujhar (Keonjhar)', NULL, 439)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (440, 26, NULL, N'Khordha', NULL, 440)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (441, 26, NULL, N'Koraput', NULL, 441)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (442, 26, NULL, N'Malkangiri', NULL, 442)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (443, 26, NULL, N'Mayurbhanj', NULL, 443)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (444, 26, NULL, N'Nabarangpur', NULL, 444)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (445, 26, NULL, N'Nayagarh', NULL, 445)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (446, 26, NULL, N'Nuapada', NULL, 446)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (447, 26, NULL, N'Puri', NULL, 447)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (448, 26, NULL, N'Rayagada', NULL, 448)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (449, 26, NULL, N'Sambalpur', NULL, 449)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (450, 26, NULL, N'Sonepur', NULL, 450)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (451, 26, NULL, N'Sundargarh', NULL, 451)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (452, 27, NULL, N'Karaikal', NULL, 452)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (453, 27, NULL, N'Mahe', NULL, 453)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (454, 27, NULL, N'Pondicherry', NULL, 454)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (455, 27, NULL, N'Yanam', NULL, 455)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (456, 28, NULL, N'Amritsar', NULL, 456)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (457, 28, NULL, N'Barnala', NULL, 457)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (458, 28, NULL, N'Bathinda', NULL, 458)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (459, 28, NULL, N'Faridkot', NULL, 459)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (460, 28, NULL, N'Fatehgarh Sahib', NULL, 460)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (461, 28, NULL, N'Fazilka', NULL, 461)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (462, 28, NULL, N'Ferozepur', NULL, 462)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (463, 28, NULL, N'Gurdaspur', NULL, 463)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (464, 28, NULL, N'Hoshiarpur', NULL, 464)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (465, 28, NULL, N'Jalandhar', NULL, 465)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (466, 28, NULL, N'Kapurthala', NULL, 466)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (467, 28, NULL, N'Ludhiana', NULL, 467)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (468, 28, NULL, N'Mansa', NULL, 468)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (469, 28, NULL, N'Moga', NULL, 469)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (470, 28, NULL, N'Muktsar', NULL, 470)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (471, 28, NULL, N'Nawanshahr', NULL, 471)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (472, 28, NULL, N'Pathankot', NULL, 472)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (473, 28, NULL, N'Patiala', NULL, 473)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (474, 28, NULL, N'Rupnagar', NULL, 474)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (475, 28, NULL, N'Sangrur', NULL, 475)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (476, 28, NULL, N'SAS Nagar (Mohali)', NULL, 476)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (477, 28, NULL, N'Tarn Taran', NULL, 477)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (478, 29, NULL, N'Ajmer', NULL, 478)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (479, 29, NULL, N'Alwar', NULL, 479)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (480, 29, NULL, N'Banswara', NULL, 480)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (481, 29, NULL, N'Baran', NULL, 481)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (482, 29, NULL, N'Barmer', NULL, 482)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (483, 29, NULL, N'Bharatpur', NULL, 483)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (484, 29, NULL, N'Bhilwara', NULL, 484)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (485, 29, NULL, N'Bikaner', NULL, 485)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (486, 29, NULL, N'Bundi', NULL, 486)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (487, 29, NULL, N'Chittorgarh', NULL, 487)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (488, 29, NULL, N'Churu', NULL, 488)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (489, 29, NULL, N'Dausa', NULL, 489)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (490, 29, NULL, N'Dholpur', NULL, 490)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (491, 29, NULL, N'Dungarpur', NULL, 491)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (492, 29, NULL, N'Hanumangarh', NULL, 492)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (493, 29, NULL, N'Jaipur', NULL, 493)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (494, 29, NULL, N'Jaisalmer', NULL, 494)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (495, 29, NULL, N'Jalore', NULL, 495)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (496, 29, NULL, N'Jhalawar', NULL, 496)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (497, 29, NULL, N'Jhunjhunu', NULL, 497)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (498, 29, NULL, N'Jodhpur', NULL, 498)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (499, 29, NULL, N'Karauli', NULL, 499)
GO
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (500, 29, NULL, N'Kota', NULL, 500)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (501, 29, NULL, N'Nagaur', NULL, 501)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (502, 29, NULL, N'Pali', NULL, 502)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (503, 29, NULL, N'Pratapgarh', NULL, 503)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (504, 29, NULL, N'Rajsamand', NULL, 504)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (505, 29, NULL, N'Sawai Madhopur', NULL, 505)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (506, 29, NULL, N'Sikar', NULL, 506)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (507, 29, NULL, N'Sirohi', NULL, 507)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (508, 29, NULL, N'Sri Ganganagar', NULL, 508)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (509, 29, NULL, N'Tonk', NULL, 509)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (510, 29, NULL, N'Udaipur', NULL, 510)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (511, 30, NULL, N'East Sikkim', NULL, 511)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (512, 30, NULL, N'North Sikkim', NULL, 512)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (513, 30, NULL, N'South Sikkim', NULL, 513)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (514, 30, NULL, N'West Sikkim', NULL, 514)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (515, 31, NULL, N'Ariyalur', NULL, 515)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (516, 31, NULL, N'Chennai', NULL, 516)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (517, 31, NULL, N'Bagpat', NULL, 517)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (518, 31, NULL, N'Cuddalore', NULL, 518)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (519, 31, NULL, N'Dharmapuri', NULL, 519)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (520, 31, NULL, N'Dindigul', NULL, 520)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (521, 31, NULL, N'Erode', NULL, 521)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (522, 31, NULL, N'Kanchipuram', NULL, 522)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (523, 31, NULL, N'Kanyakumari', NULL, 523)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (524, 31, NULL, N'Karur', NULL, 524)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (525, 31, NULL, N'Krishnagiri', NULL, 525)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (526, 31, NULL, N'Madurai', NULL, 526)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (527, 31, NULL, N'Nagapattinam', NULL, 527)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (528, 31, NULL, N'Namakkal', NULL, 528)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (529, 31, NULL, N'Nilgiris', NULL, 529)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (530, 31, NULL, N'Perambalur', NULL, 530)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (531, 31, NULL, N'Pudukkottai', NULL, 531)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (532, 31, NULL, N'Ramanathapuram', NULL, 532)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (533, 31, NULL, N'Salem', NULL, 533)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (534, 31, NULL, N'Sivaganga', NULL, 534)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (535, 31, NULL, N'Thanjavur', NULL, 535)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (536, 31, NULL, N'Theni', NULL, 536)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (537, 31, NULL, N'Thoothukudi (Tuticorin)', NULL, 537)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (538, 31, NULL, N'Tiruchirappalli', NULL, 538)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (539, 31, NULL, N'Tirunelveli', NULL, 539)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (540, 31, NULL, N'Tiruppur', NULL, 540)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (541, 31, NULL, N'Tiruvallur', NULL, 541)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (542, 31, NULL, N'Tiruvannamalai', NULL, 542)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (543, 31, NULL, N'Tiruvarur', NULL, 543)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (544, 31, NULL, N'Vellore', NULL, 544)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (545, 31, NULL, N'Viluppuram', NULL, 545)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (546, 31, NULL, N'Virudhunagar', NULL, 546)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (547, 32, NULL, N'Adilabad', NULL, 547)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (548, 32, NULL, N'Hyderabad', NULL, 548)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (549, 32, NULL, N'Karimnagar', NULL, 549)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (550, 32, NULL, N'Khammam', NULL, 550)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (551, 32, NULL, N'Mahabubnagar', NULL, 551)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (552, 32, NULL, N'Medak', NULL, 552)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (553, 32, NULL, N'Nalgonda', NULL, 553)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (554, 32, NULL, N'Nizamabad', NULL, 554)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (555, 32, NULL, N'Rangareddy', NULL, 555)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (556, 32, NULL, N'Warangal', NULL, 556)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (557, 33, NULL, N'Dhalai', NULL, 557)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (558, 33, NULL, N'Gomati', NULL, 558)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (559, 33, NULL, N'Khowai', NULL, 559)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (560, 33, NULL, N'North Tripura', NULL, 560)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (561, 33, NULL, N'Sepahijala', NULL, 561)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (562, 33, NULL, N'South Tripura', NULL, 562)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (563, 33, NULL, N'Unakoti', NULL, 563)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (564, 33, NULL, N'West Tripura', NULL, 564)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (565, 34, N'AGRA', N'Agra', N'आगरा', 565)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (566, 34, N'ALGH', N'Aligarh', N'अलीगढ़', 566)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (567, 34, N'PGRJ', N'Prayagraj', N'प्रयागराज', 567)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (568, 34, N'ABDN', N'Ambedkar Nagar', N'अंबेडकर नगर', 568)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (569, 34, N'AURY', N'Auraiya', N'औरैया', 569)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (570, 34, N'AZMG', N'Azamgarh', N'आजमगढ़', 570)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (571, 34, N'BGPT', N'Bagpat', N'बागपत', 571)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (572, 34, N'BHRC', N'Bahraich', N'बहराइच', 572)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (573, 34, N'BLIA', N'Ballia', N'बलिया', 573)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (574, 34, N'BLMP', N'Balrampur', N'बलरामपुर', 574)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (575, 34, N'BNDA', N'Banda', N'बाँदा', 575)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (576, 34, N'BRBK', N'Barabanki', N'बाराबंकी', 576)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (577, 34, N'BRLY', N'Bareilly', N'बरेली', 577)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (578, 34, N'BSTI', N'Basti', N'बस्ती', 578)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (579, 34, N'SMBL', N'Sambhal', N'संभल', 579)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (580, 34, N'BJNR', N'Bijnor', N'बिजनौर', 580)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (581, 34, N'BDUN', N'Budaun', N'बदायूं', 581)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (582, 34, N'BLND', N'Bulandshahr', N'बुलंदशहर', 582)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (583, 34, N'CHND', N'Chandauli', N'चंदौली', 583)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (584, 34, N'AMTH', N'Amethi', N'अमेठी', 584)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (585, 34, N'CTKT', N'Chitrakoot', N'चित्रकूट', 585)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (586, 34, N'DEOR', N'Deoria', N'देवरिया', 586)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (587, 34, N'ETAH', N'Etah', N'एटा', 587)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (588, 34, N'ETWH', N'Etawah', N'ईटावा', 588)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (589, 34, N'AYDH', N'Ayodhya', N'अयोध्या', 589)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (590, 34, N'FRKB', N'Farrukhabad', N'फर्रुखाबाद', 590)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (591, 34, N'FTPR', N'Fatehpur', N'फतेहपुर', 591)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (592, 34, N'FRZB', N'Firozabad', N'फ़िरोज़ाबाद', 592)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (593, 34, N'GTBN', N'Gautam Buddh Nagar', N'गौतम बुद्ध नगर', 593)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (594, 34, N'GZBD', N'Ghaziabad', N'गाज़ियाबाद', 594)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (595, 34, N'GZPR', N'Ghazipur', N'ग़ाज़ीपुर', 595)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (596, 34, N'GNDA', N'Gonda', N'गोंडा', 596)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (597, 34, N'GRKP', N'Gorakhpur', N'गोरखपुर', 597)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (598, 34, N'HMPR', N'Hamirpur', N'हमीरपुर', 598)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (599, 34, N'HRDO', N'Hardoi', N'हरदोई', 599)
GO
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (600, 34, N'HTRS', N'Hathras', N'हाथरस', 600)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (601, 34, N'JLUN', N'Jalaun', N'जालौन', 601)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (602, 34, N'JNPR', N'Jaunpur', N'जौनपुर', 602)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (603, 34, N'JHNS', N'Jhansi', N'झाँसी', 603)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (604, 34, N'AMRH', N'Amroha (J.P.Nagar)', N'अमरोहा', 604)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (605, 34, N'KNUJ', N'Kannauj', N'कन्नौज', 605)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (606, 34, N'KNPD', N'Kanpur Dehat', N'कानपुर देहात', 606)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (607, 34, N'KNPN', N'Kanpur Nagar', N'कानपुर नगर', 607)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (608, 34, N'KSGJ', N'Kansganj', N'कासगंज', 608)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (609, 34, N'KSMB', N'Kaushambi', N'कौशाम्बी', 609)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (610, 34, N'KSHN', N'Kushinagar', N'कुशीनगर', 610)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (611, 34, N'LMPK', N'Lakhimpur Kheri', N'लखीमपुर खीरी', 611)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (612, 34, N'LTPR', N'Lalitpur', N'ललितपुर', 612)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (613, 34, N'LKNW', N'Lucknow', N'लखनऊ', 0)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (614, 34, N'MHRG', N'Maharajganj', N'महाराजगंज', 614)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (615, 34, N'MHBA', N'Mahoba', N'महोबा', 615)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (616, 34, N'MNPR', N'Mainpuri', N'मैनपुरी', 616)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (617, 34, N'MTHR', N'Mathura', N'मथुरा', 617)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (618, 34, N'MAUD', N'Mau', N'मऊ', 618)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (619, 34, N'MERT', N'Meerut', N'मेरठ', 619)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (620, 34, N'MRZP', N'Mirzapur', N'मिर्ज़ापुर', 620)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (621, 34, N'MRBD', N'Moradabad', N'मुरादाबाद', 621)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (622, 34, N'MZFN', N'Muzaffar Nagar', N'मुज़फ्फरनगर', 622)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (623, 34, N'HPUR', N'Hapur', N'हापुड़', 623)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (624, 34, N'PLBH', N'Pilibhit', N'पीलीभीत', 624)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (625, 34, N'SHML', N'Shamli', N'शामली', 625)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (626, 34, N'PTPG', N'Pratapgarh', N'प्रतापगढ़', 626)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (627, 34, N'RBLI', N'Raibareli', N'रायबरेली', 627)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (628, 34, N'RMPR', N'Rampur', N'रामपुर', 628)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (629, 34, N'SRNP', N'Saharanpur', N'सहारनपुर', 629)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (630, 34, N'SKBN', N'Sant Kabir Nagar', N'संत कबीर नगर', 630)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (631, 34, N'SRVN', N'Sant Ravidas Nagar', N'संत रविदास नगर', 631)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (632, 34, N'SHJP', N'Shahjahanpur', N'शाहजहांपुर', 632)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (633, 34, N'SVST', N'Shravasti', N'श्रावस्ती', 633)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (634, 34, N'SDHN', N'Siddharth Nagar', N'सिद्धार्थनगर', 634)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (635, 34, N'STPR', N'Sitapur', N'सीतापुर', 635)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (636, 34, N'SNBD', N'Sonbhadra', N'सोनभद्र', 636)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (637, 34, N'SLTP', N'Sultanpur', N'सुल्तानपुर', 637)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (638, 34, N'UNAO', N'Unnao', N'उन्नाव', 638)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (639, 34, N'VRNS', N'Varanasi', N'वाराणसी', 639)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (640, 35, NULL, N'Almora', NULL, 640)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (641, 35, NULL, N'Bageshwar', NULL, 641)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (642, 35, NULL, N'Chamoli', NULL, 642)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (643, 35, NULL, N'Champawat', NULL, 643)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (644, 35, NULL, N'Dehradun', NULL, 644)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (645, 35, NULL, N'Haridwar', NULL, 645)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (646, 35, NULL, N'Nainital', NULL, 646)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (647, 35, NULL, N'Pauri Garhwal', NULL, 647)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (648, 35, NULL, N'Pithoragarh', NULL, 648)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (649, 35, NULL, N'Rudraprayag', NULL, 649)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (650, 35, NULL, N'Tehri Garhwal', NULL, 650)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (651, 35, NULL, N'Udham Singh Nagar', NULL, 651)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (652, 35, NULL, N'Uttarkashi', NULL, 652)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (653, 36, NULL, N'Bankura', NULL, 653)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (654, 36, NULL, N'Birbhum', NULL, 654)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (655, 36, NULL, N'Burdwan (Bardhaman)', NULL, 655)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (656, 36, NULL, N'Cooch Behar', NULL, 656)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (657, 36, NULL, N'Dakshin Dinajpur (South Dinajpur)', NULL, 657)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (658, 36, NULL, N'Darjeeling', NULL, 658)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (659, 36, NULL, N'Hooghly', NULL, 659)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (660, 36, NULL, N'Howrah', NULL, 660)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (661, 36, NULL, N'Jalpaiguri', NULL, 661)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (662, 36, NULL, N'Kolkata', NULL, 662)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (663, 36, NULL, N'Malda', NULL, 663)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (664, 36, NULL, N'Murshidabad', NULL, 664)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (665, 36, NULL, N'Nadia', NULL, 665)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (666, 36, NULL, N'North 24 Parganas', NULL, 666)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (667, 36, NULL, N'Paschim Medinipur (West Medinipur)', NULL, 667)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (668, 36, NULL, N'Purba Medinipur (East Medinipur)', NULL, 668)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (669, 36, NULL, N'Purulia', NULL, 669)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (670, 36, NULL, N'South 24 Parganas', NULL, 670)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (671, 36, NULL, N'Uttar Dinajpur (North Dinajpur)', NULL, 671)
INSERT [dbo].[M_District] ([DistrictID], [StateID], [DistrictCode], [DistrictName], [DistrictNameHindi], [SortOrder]) VALUES (677, 37, NULL, N'Not Applicable', NULL, 672)
SET IDENTITY_INSERT [dbo].[M_District] OFF
SET IDENTITY_INSERT [dbo].[M_Registration] ON 

INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (1, N'AMTH19100001', 22, 0, 1, 613, 418, N'8687430729', N'ankitam@otpl.local', N'Ankita', N'280506', 1, 0, 1, CAST(N'2019-10-05 13:01:42.670' AS DateTime), N'Amit Singh', CAST(N'2001-01-10 00:00:00.000' AS DateTime), N'DINESH MANI TRIPATHI', 33, N'35', N'455  block c  ', 34, 586, N'274509', 573, 742, N'455454545', 3, N'8787-8787-8787', N'/Content/UploadedDocs/AddressIdProof/UserIDProof3201910091914032922.jpg', N'Municipality and coporation', N'4845', CAST(N'2019-01-10 00:00:00.000' AS DateTime), 6, CAST(6.00 AS Decimal(10, 2)), 1, N'Best', 10, CAST(555.00 AS Decimal(10, 2)), CAST(555.00 AS Decimal(10, 2)), CAST(55.00 AS Decimal(6, 2)), 15, CAST(N'2019-01-10 00:00:00.000' AS DateTime), 17, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, N'submit mode of treatment of waste water', 0, 0, N'NO', 0, NULL, N'::1', CAST(N'2019-10-05 13:01:42.670' AS DateTime), NULL, 0, 1, 41, CAST(5555.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 1, NULL, 0, N'343545646', CAST(N'2019-10-07 00:00:00.000' AS DateTime), CAST(N'2019-10-16 00:00:00.000' AS DateTime), N'/gwd/Content/UploadedDocs/AddressIdProof/RegCertificateByGWD3201910151805072569.jpg', 0, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (2, NULL, 22, 0, 1, 573, 742, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'620470', 0, 1, 1, CAST(N'2019-10-05 13:02:20.953' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-05 13:02:20.953' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (3, NULL, 22, 0, 1, 573, 742, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'606889', 1, 1, 1, CAST(N'2019-10-05 13:06:01.857' AS DateTime), N'xcxcxc', CAST(N'2001-01-10 00:00:00.000' AS DateTime), N'xcxc', 33, N'35', N'cxcxc', 12, 151, N'555555', 573, 742, N'455454545', 3, N'444444444444', N'/Content/UploadedDocs/AddressIdProof/UserIDProof3201910091914032922.jpg', N'sdsd', N'', CAST(N'2019-01-10 00:00:00.000' AS DateTime), 6, CAST(11.00 AS Decimal(10, 2)), 0, N'', 10, CAST(555.00 AS Decimal(10, 2)), CAST(555.00 AS Decimal(10, 2)), CAST(55.00 AS Decimal(6, 2)), 15, CAST(N'2019-01-10 00:00:00.000' AS DateTime), 28, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, N'', 0, 0, N'', 1, NULL, N'::1', CAST(N'2019-10-05 13:06:01.857' AS DateTime), CAST(N'2019-10-15 18:07:03.970' AS DateTime), 0, 1, 41, CAST(5555.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 1, N'', 1, N'errerer', CAST(N'2019-10-07 00:00:00.000' AS DateTime), CAST(N'2019-10-16 00:00:00.000' AS DateTime), N'/gwd/Content/UploadedDocs/AddressIdProof/RegCertificateByGWD3201910151805072569.jpg', 0, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', N'', 5, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (4, NULL, 22, 0, 1, 573, 742, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'255881', 1, 1, 1, CAST(N'2019-10-05 13:13:43.223' AS DateTime), N'sdfsdf', CAST(N'2001-03-10 00:00:00.000' AS DateTime), N'sdfsdf', 33, N'35', N'dsdsdsdsdsd', 34, 0, N'855555', 573, 742, N'dfgdfg6', 4, N'8787-8787-8787', N'/Content/UploadedDocs/AddressIdProof/UserIDProof4201910151241503333.jpg', N'sdfsdf', N'sdfsd', CAST(N'2019-01-10 00:00:00.000' AS DateTime), 6, CAST(78585.00 AS Decimal(10, 2)), 1, N'werwrer', 10, CAST(78.00 AS Decimal(10, 2)), CAST(45.00 AS Decimal(10, 2)), CAST(54.00 AS Decimal(6, 2)), 15, CAST(N'2019-01-10 00:00:00.000' AS DateTime), 0, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, N'', 0, 0, N'', 0, NULL, N'::1', CAST(N'2019-10-05 13:13:43.223' AS DateTime), CAST(N'2019-10-15 12:45:22.437' AS DateTime), 0, 1, 41, CAST(454545.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 1, N'', 0, N'', CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', 0, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', N'', 3, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (5, NULL, 22, 0, 2, 573, 742, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'598407', 1, 0, 0, CAST(N'2019-10-05 13:14:56.890' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-05 13:14:56.890' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (6, NULL, 22, 0, 1, 573, 742, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'314701', 1, 0, 1, CAST(N'2019-10-05 13:19:11.917' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-05 13:19:11.917' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (7, NULL, 22, 0, 1, 573, 742, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'405836', 1, 1, 1, CAST(N'2019-10-05 13:25:12.230' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-05 13:25:12.230' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (8, NULL, 22, 0, 1, 573, 742, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'182157', 1, 1, 1, CAST(N'2019-10-05 14:11:30.977' AS DateTime), N'sushil', CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'abc', 33, N'35', N'fdfdf', 11, 139, N'545121', 0, 0, N'', 3, N'754454545', N'/Content/UploadedDocs/AddressIdProof/UserIDProof8201910051557041233.pdf', N'', N'', CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0, CAST(0.00 AS Decimal(10, 2)), 0, N'', 0, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(6, 2)), 0, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, N'', 0, 0, N'', 0, NULL, N'::1', CAST(N'2019-10-05 14:11:30.977' AS DateTime), CAST(N'2019-10-05 16:07:21.763' AS DateTime), 0, 1, 41, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 0, N'', 0, N'', CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (9, NULL, 22, 0, 2, 573, 742, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'900910', 1, 1, 0, CAST(N'2019-10-05 15:04:35.960' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-05 15:04:35.960' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (10, NULL, 22, 0, 1, 570, 702, N'9839849223', N'opbaba2005@gmail.com', N'TEST USER', N'777936', 1, 1, 1, CAST(N'2019-10-05 15:17:45.067' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'192.168.0.250', CAST(N'2019-10-05 15:17:45.067' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (11, NULL, 22, 0, 1, 581, 98, N'8318825710', N'opbaba2005@gmail.com', N'TEST USER', N'339286', 1, 1, 1, CAST(N'2019-10-05 15:38:16.683' AS DateTime), N'DINESH MANI TRIPATHI', CAST(N'2019-08-06 00:00:00.000' AS DateTime), N'DINESH MANI TRIPATHI', 33, N'35', N'1246', 34, 586, N'274509', 570, 714, N'4545', 3, N'45454445454545', N'/gwd/Content/UploadedDocs/AddressIdProof/UserIDProof11201910051542315087.pdf', N'uiuu', N'4845', CAST(N'2019-01-10 00:00:00.000' AS DateTime), 6, CAST(4.00 AS Decimal(10, 2)), 1, N'jjk', 0, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(6, 2)), 0, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, N'', 0, 0, N'', 0, NULL, N'192.168.0.250', CAST(N'2019-10-05 15:38:16.683' AS DateTime), CAST(N'2019-10-05 15:46:18.227' AS DateTime), 0, 1, 41, CAST(44.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 1, N'', 0, N'', CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (12, N'AMTH19100001', 22, 0, 1, 576, 565, N'9140675876', N'kkkmm@gmail.com', N'Nano', N'094110', 1, 1, 1, CAST(N'2019-10-05 17:11:02.943' AS DateTime), N'Ankarshita', CAST(N'2000-02-09 00:00:00.000' AS DateTime), N'mhjjk', 34, N'35', N'455  block c  ', 17, 267, N'226002', 584, 545, N'4234', 3, N'789955656565', N'/Content/UploadedDocs/AddressIdProof/UserIDProof12201910071822588680.jpg', N'Municipality and coporation', N'4323T', CAST(N'2019-10-17 00:00:00.000' AS DateTime), 8, CAST(23.00 AS Decimal(10, 2)), 1, N'fref', 10, CAST(78.00 AS Decimal(10, 2)), CAST(56.00 AS Decimal(10, 2)), CAST(8765.00 AS Decimal(6, 2)), 15, CAST(N'2019-10-08 00:00:00.000' AS DateTime), 18, CAST(76566.00 AS Decimal(10, 2)), CAST(20.00 AS Decimal(10, 2)), 1, N'submit mode of treatment of waste water', 1, 1, N'No', 0, NULL, N'::1', CAST(N'2019-10-05 17:11:02.943' AS DateTime), CAST(N'2019-10-09 17:47:30.450' AS DateTime), 0, 1, 44, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 0, N'', 1, N'343545646', CAST(N'2019-10-15 00:00:00.000' AS DateTime), CAST(N'2019-10-01 00:00:00.000' AS DateTime), N'/Content/UploadedDocs/AddressIdProof/RegCertificateByGWD12201910071827200010.pdf', NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (13, NULL, 22, 0, 1, 576, 562, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'705735', 0, 1, 1, CAST(N'2019-10-05 17:21:55.440' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-05 17:21:55.440' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (14, NULL, 22, 0, 1, 573, 738, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'816111', 0, 1, 1, CAST(N'2019-10-05 17:25:36.387' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-05 17:25:36.387' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (15, N'GRKP19100001', 22, 0, 1, 575, 397, N'9140675876', N'nano2gmail.com', N'Nano 2', N'060150', 1, 1, 1, CAST(N'2019-10-05 17:39:09.303' AS DateTime), N'nano', CAST(N'2000-05-10 00:00:00.000' AS DateTime), N'Nano1', 33, N'35', N'Anand Vihar, Near ravidas mandir, Gwalora road, Saharanpur 247001, U. P.', 10, 133, N'545453', 597, 801, N'45/12', 3, N'123457889655', N'/Content/UploadedDocs/AddressIdProof/UserIDProof15201910071321162846.jpg', N'', N'', CAST(N'1900-01-01 00:00:00.000' AS DateTime), 6, CAST(895.00 AS Decimal(10, 2)), 0, N'', 11, CAST(3654.00 AS Decimal(10, 2)), CAST(655.00 AS Decimal(10, 2)), CAST(6757.00 AS Decimal(6, 2)), 15, CAST(N'2019-10-08 00:00:00.000' AS DateTime), 18, CAST(7785.00 AS Decimal(10, 2)), CAST(48.00 AS Decimal(10, 2)), 1, N'submit mode of treatment of waste water', 1, 0, N'', 0, NULL, N'::1', CAST(N'2019-10-05 17:39:09.303' AS DateTime), CAST(N'2019-10-07 18:11:30.440' AS DateTime), 0, 1, 42, CAST(66876666.68 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 1, N'', 1, N'5464', CAST(N'2019-10-09 00:00:00.000' AS DateTime), CAST(N'2019-11-21 00:00:00.000' AS DateTime), N'/Content/UploadedDocs/AddressIdProof/RegCertificateByGWD15201910071322577443.jpg', NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (16, NULL, 22, 0, 1, 586, 823, N'9839849223', N'opbaba2005@gmail.com', N'TEST USER', N'721526', 1, 0, 1, CAST(N'2019-10-07 12:20:01.920' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'192.168.0.250', CAST(N'2019-10-07 12:20:01.920' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (17, NULL, 22, 0, 1, 576, 563, N'7239048784', N'opbaba2005@gmail.com', N'TEST USER', N'020675', 1, 0, 1, CAST(N'2019-10-07 12:28:34.210' AS DateTime), N'dsfsdf', CAST(N'2019-01-10 00:00:00.000' AS DateTime), N'dfdsf', 33, N'35', N'dsfsdfdsf', 13, 186, N'845515', 573, 742, N'7454545', 5, N'845615485475', N'/gwd/Content/UploadedDocs/AddressIdProof/UserIDProof17201910071236266425.pdf', N'jkjhkjkjhk54hj5k1', N'vnbnvbn', CAST(N'2019-01-10 00:00:00.000' AS DateTime), 6, CAST(455.00 AS Decimal(10, 2)), 1, N'hjjgj', 10, CAST(54.00 AS Decimal(10, 2)), CAST(4545.00 AS Decimal(10, 2)), CAST(454.00 AS Decimal(6, 2)), 15, CAST(N'2019-01-10 00:00:00.000' AS DateTime), 17, CAST(4545.00 AS Decimal(10, 2)), CAST(4545.00 AS Decimal(10, 2)), 1, N'', 1, 1, N'4545', 0, NULL, N'192.168.0.250', CAST(N'2019-10-07 12:28:34.210' AS DateTime), CAST(N'2019-10-07 12:41:24.447' AS DateTime), 0, 1, 42, CAST(7545.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 1, N'', 0, N'', CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (18, NULL, 22, 0, 2, 613, 414, N'8687430729', N'ankitam@otpl.local', N'Ankita', N'600829', 1, 0, 0, CAST(N'2019-10-07 18:44:52.850' AS DateTime), N'Ankita', CAST(N'2001-10-04 00:00:00.000' AS DateTime), N'BKKKKKKK', 34, N'35', N'Anand Vihar, Near ravidas mandir, Gwalora road, Saharanpur 247001, U. P.', 34, 623, N'220152', 613, 414, N'4234', 47, N'123647897875', N'/Content/UploadedDocs/AddressIdProof/UserIDProof18201910111438030056.pdf', N'Corporatione', N'45', CAST(N'2019-10-10 00:00:00.000' AS DateTime), 6, CAST(47.00 AS Decimal(10, 2)), 0, N'', 11, CAST(789.00 AS Decimal(10, 2)), CAST(85.00 AS Decimal(10, 2)), CAST(868.00 AS Decimal(6, 2)), 15, CAST(N'2019-10-17 00:00:00.000' AS DateTime), 30, CAST(76.00 AS Decimal(10, 2)), CAST(786.00 AS Decimal(10, 2)), 1, N'76', 0, 0, N'7768', 0, NULL, N'::1', CAST(N'2019-10-07 18:44:52.850' AS DateTime), CAST(N'2019-10-16 14:50:12.377' AS DateTime), 0, 1, 42, CAST(99.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 1, N'', 1, N'67576', CAST(N'2019-10-01 00:00:00.000' AS DateTime), CAST(N'2019-10-17 00:00:00.000' AS DateTime), N'/Content/UploadedDocs/AddressIdProof/RegCertificateByGWD18201910161445182440.pdf', 0, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', N'', 4, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (19, N'LKNW19100001', 22, 0, 2, 570, 723, N'7239048784', N'yadvendra.css@gmail.com', N'yadvendra', N'348151', 1, 0, 0, CAST(N'2019-10-09 10:47:10.497' AS DateTime), N'yadvendra', CAST(N'1990-02-10 00:00:00.000' AS DateTime), N'ghgfgfh', 33, N'35', N'481128 mohan meakin road daliganj kashyap nagar', 34, 570, N'276128', 613, 418, N'4546AG', 4, N'111111111111', N'/gwd/Content/UploadedDocs/AddressIdProof/UserIDProof19201910091627342597.pdf', N'Lucknow Nagar Nigam ', N'546', CAST(N'2000-01-08 00:00:00.000' AS DateTime), 8, CAST(55.00 AS Decimal(10, 2)), 1, N'gjvhc', 11, CAST(55.00 AS Decimal(10, 2)), CAST(700.00 AS Decimal(10, 2)), CAST(1000.00 AS Decimal(6, 2)), 15, CAST(N'2019-02-09 00:00:00.000' AS DateTime), 17, CAST(365.00 AS Decimal(10, 2)), CAST(1.00 AS Decimal(10, 2)), 1, N'dsfhsg', 1, 1, N'dfsxhxgf', 0, NULL, N'192.168.0.250', CAST(N'2019-10-09 10:47:10.497' AS DateTime), CAST(N'2019-10-09 17:30:41.007' AS DateTime), 0, 1, 44, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 0, N'', 0, N'', CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (20, NULL, 22, 0, 2, 613, 418, N'9696799138', N'ajaysinghkashyap21@gmail.com', N'ajay singh kashyap', N'830928', 1, 1, 1, CAST(N'2019-10-09 10:56:45.973' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'192.168.0.250', CAST(N'2019-10-09 10:56:45.973' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (21, NULL, 22, 0, 1, 613, 418, N'9696799138', N'ajay@otpl.co.in', N'ajay singh kashyap', N'041022', 1, 1, 1, CAST(N'2019-10-09 10:58:32.760' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'192.168.0.250', CAST(N'2019-10-09 10:58:32.760' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (22, NULL, 22, 0, 2, 613, 418, N'9696799138', N'ajay@otpl.co.in', N'ajay singh kashyap', N'271225', 1, 1, 1, CAST(N'2019-10-09 11:12:55.830' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'192.168.0.250', CAST(N'2019-10-09 11:12:55.830' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (23, NULL, 22, 0, 1, 570, 0, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'192246', 1, 1, 1, CAST(N'2019-10-09 11:19:47.350' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'192.168.0.250', CAST(N'2019-10-09 11:19:47.350' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (24, NULL, 22, 0, 1, 572, 575, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'224076', 1, 1, 1, CAST(N'2019-10-09 11:31:15.747' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-09 11:31:15.747' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (25, NULL, 22, 0, 2, 580, 158, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'893607', 1, 1, 0, CAST(N'2019-10-09 12:03:25.730' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-09 12:03:25.730' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (26, NULL, 22, 0, 1, 570, 712, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'466400', 0, 1, 1, CAST(N'2019-10-09 12:19:10.620' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-09 12:19:10.620' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (27, NULL, 22, 0, 2, 578, 754, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'939072', 0, 1, 1, CAST(N'2019-10-09 12:19:55.927' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-09 12:19:55.927' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (28, NULL, 22, 0, 1, 569, 287, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'086931', 0, 0, 0, CAST(N'2019-10-09 12:25:44.090' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-09 12:25:44.090' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (29, NULL, 22, 0, 1, 575, 396, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'935944', 0, 0, 1, CAST(N'2019-10-09 12:30:41.533' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-09 12:30:41.533' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (30, NULL, 22, 0, 1, 575, 0, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'395192', 1, 1, 0, CAST(N'2019-10-09 12:31:41.900' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-09 12:31:41.900' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (31, NULL, 22, 0, 1, 577, 96, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'849240', 0, 1, 1, CAST(N'2019-10-09 12:37:39.070' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-09 12:37:39.070' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (32, NULL, 22, 0, 1, 589, 509, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'544731', 1, 1, 1, CAST(N'2019-10-09 12:39:52.280' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-09 12:39:52.280' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (33, NULL, 22, 0, 1, 625, 245, N'8687430729', N'ankitam@otpl.local', N'Ankita', N'162081', 0, 1, 1, CAST(N'2019-10-09 12:53:57.577' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-09 12:53:57.577' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (34, NULL, 22, 0, 1, 569, 289, N'8795582569', N'', N'Sushil Kumar Sharma', N'122532', 0, 0, 0, CAST(N'2019-10-09 16:35:09.397' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-09 16:35:09.397' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (35, NULL, 22, 0, 2, 570, 709, N'8795582569', N'', N'Sushil Kumar Sharma', N'634847', 0, 1, 0, CAST(N'2019-10-09 17:29:22.730' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'192.168.0.250', CAST(N'2019-10-09 17:29:22.730' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (36, N'BJNR19100001', 22, 0, 2, 580, 158, N'8687430729', N'', N'Ankita', N'791927', 1, 0, 1, CAST(N'2019-10-09 18:16:28.110' AS DateTime), N'Ankita', CAST(N'1999-05-19 00:00:00.000' AS DateTime), N'KK Singh', 34, N'36', N'Anand Vihar, Near ravidas mandir, Gwalora road, Saharanpur 247001, U. P.', 17, 267, N'220152', 580, 158, N'4234', 5, N'123647897875', N'/Content/UploadedDocs/AddressIdProof/UserIDProof36201910091821052944.pdf', N'Corporation', N'45', CAST(N'2019-10-24 00:00:00.000' AS DateTime), 6, CAST(45.00 AS Decimal(10, 2)), 1, N'fdgfh', 10, CAST(78.00 AS Decimal(10, 2)), CAST(56.23 AS Decimal(10, 2)), CAST(8765.00 AS Decimal(6, 2)), 16, CAST(N'2019-10-17 00:00:00.000' AS DateTime), 19, CAST(7785.00 AS Decimal(10, 2)), CAST(48.00 AS Decimal(10, 2)), 1, N'tytutyuyu', 1, 0, N'erwer', 0, NULL, N'::1', CAST(N'2019-10-09 18:16:28.110' AS DateTime), CAST(N'2019-10-10 10:53:09.940' AS DateTime), 0, 1, 42, CAST(2563.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 1, N'', 1, N'54643243435', CAST(N'2019-10-15 00:00:00.000' AS DateTime), CAST(N'2026-01-06 00:00:00.000' AS DateTime), N'/Content/UploadedDocs/AddressIdProof/RegCertificateByGWD36201910091824456573.jpg', NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (37, NULL, 22, 0, 1, 629, 224, N'7239048784', N'', N'abcd', N'850450', 1, 0, 0, CAST(N'2019-10-09 19:30:55.160' AS DateTime), N'dfh', CAST(N'2001-10-03 00:00:00.000' AS DateTime), N'asg', 33, N'35', N'aseZ45', 34, 579, N'226001', 0, 0, N'gf', 3, N'111111111111', N'/gwd/Content/UploadedDocs/AddressIdProof/UserIDProof37201910091933373192.jpg', N'', N'', CAST(N'2019-10-02 00:00:00.000' AS DateTime), 7, CAST(257.00 AS Decimal(10, 2)), 1, N'weastrh', 10, CAST(78.00 AS Decimal(10, 2)), CAST(34.00 AS Decimal(10, 2)), CAST(8765.00 AS Decimal(6, 2)), 15, CAST(N'2019-10-01 00:00:00.000' AS DateTime), 17, CAST(4356.00 AS Decimal(10, 2)), CAST(34.00 AS Decimal(10, 2)), 0, N'', 0, 0, N'', 0, NULL, N'192.168.0.250', CAST(N'2019-10-09 19:30:55.160' AS DateTime), CAST(N'2019-10-09 19:37:27.153' AS DateTime), 0, 1, 41, CAST(0.00 AS Decimal(10, 2)), CAST(123.00 AS Decimal(10, 2)), CAST(34.00 AS Decimal(10, 2)), CAST(234.00 AS Decimal(10, 2)), CAST(234.00 AS Decimal(10, 2)), 37, 37, 0, N'', 1, N'cjgh fm', CAST(N'2018-01-10 00:00:00.000' AS DateTime), CAST(N'2019-01-10 00:00:00.000' AS DateTime), N'/gwd/Content/UploadedDocs/AddressIdProof/RegCertificateByGWD37201910091936422218.jpg', NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (38, NULL, 22, 0, 2, 570, 704, N'7239048784', N'', N'yadvendra', N'102857', 1, 0, 0, CAST(N'2019-10-10 11:08:36.923' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'192.168.0.250', CAST(N'2019-10-10 11:08:36.923' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (39, NULL, 22, 0, 1, 579, 143, N'9721777786', N'zuhairbs@rediffmail.com', N'spcl sec', N'344481', 1, 1, 0, CAST(N'2019-10-10 12:29:08.360' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'192.168.0.250', CAST(N'2019-10-10 12:29:08.360' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (40, NULL, 22, 0, 2, 579, 144, N'9721777786', N'ajay@otpl.co.in', N'ajay', N'940973', 0, 0, 0, CAST(N'2019-10-10 15:05:08.130' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'192.168.0.250', CAST(N'2019-10-10 15:05:08.130' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (41, NULL, 22, 0, 2, 579, 144, N'7007355085', N'ajay@otpl.co.in', N'sir', N'448140', 1, 0, 0, CAST(N'2019-10-10 15:06:56.657' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'192.168.0.250', CAST(N'2019-10-10 15:06:56.657' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (42, NULL, 22, 0, 1, 621, 135, N'7239048784', N'', N'asgfhd', N'473697', 1, 1, 0, CAST(N'2019-10-10 17:15:11.400' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'192.168.0.250', CAST(N'2019-10-10 17:15:11.400' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (43, NULL, 22, 0, 1, 573, 736, N'8687430729', N'', N'Ankita', N'486284', 0, 0, 0, CAST(N'2019-10-10 17:21:48.473' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-10 17:21:48.473' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (44, NULL, 22, 0, 2, 577, 93, N'8687430729', N'', N'AAAAAAAAAA', N'150357', 0, 0, 0, CAST(N'2019-10-10 17:27:12.153' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-10 17:27:12.153' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (45, N'BGPT19100002', 22, 0, 2, 571, 216, N'7239048784', N'', N'fguvkj', N'561856', 1, 0, 0, CAST(N'2019-10-10 17:31:02.273' AS DateTime), N'asfgr', CAST(N'2001-03-10 00:00:00.000' AS DateTime), N'fzxdbgjt', 33, N'35', N'awgert', 34, 579, N'226600', 571, 216, N'123', 3, N'111111111111', N'/gwd/Content/UploadedDocs/AddressIdProof/UserIDProof45201910101849237322.pdf', N'', N'', CAST(N'1900-01-01 00:00:00.000' AS DateTime), 6, CAST(12.00 AS Decimal(10, 2)), 1, N'12e', 11, CAST(1233.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)), CAST(2.00 AS Decimal(6, 2)), 15, CAST(N'2019-08-10 00:00:00.000' AS DateTime), 20, CAST(3800.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)), 0, N'', 0, 0, N'', 0, NULL, N'192.168.0.250', CAST(N'2019-10-10 17:31:02.273' AS DateTime), CAST(N'2019-10-10 18:51:40.273' AS DateTime), 0, 1, 41, CAST(12.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 1, N'', 0, N'', CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (46, NULL, 22, 0, 1, 582, 201, N'8687430729', N'', N'AAAAAAAAAA', N'548009', 1, 0, 0, CAST(N'2019-10-10 17:38:04.423' AS DateTime), N'eerreet', CAST(N'2001-10-10 00:00:00.000' AS DateTime), N'rrewrerwe', 34, N'35', N'sector -q aliganj thana near ABC restrurant', 34, 580, N'521541', 582, 201, N'4234', 3, N'123647897875', N'/Content/UploadedDocs/AddressIdProof/UserIDProof46201910101813296377.jpg', N'Corporation', N'45', CAST(N'2019-10-03 00:00:00.000' AS DateTime), 8, CAST(433.00 AS Decimal(10, 2)), 0, N'', 11, CAST(65.00 AS Decimal(10, 2)), CAST(65.00 AS Decimal(10, 2)), CAST(65.00 AS Decimal(6, 2)), 15, CAST(N'2019-10-16 00:00:00.000' AS DateTime), 29, CAST(441.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)), 0, N'65665trrt', 0, 0, N'trtryryy tyerte ry trytryu yytryhgf hh y yty ytry y', 1, NULL, N'::1', CAST(N'2019-10-10 17:38:04.423' AS DateTime), CAST(N'2019-10-17 12:12:51.660' AS DateTime), 0, 1, 42, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 0, N'', 1, N'5345654646', CAST(N'2019-10-08 00:00:00.000' AS DateTime), CAST(N'2019-10-03 00:00:00.000' AS DateTime), N'/Content/UploadedDocs/AddressIdProof/RegCertificateByGWD46201910111208291814.pdf', 0, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', N'', 5, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (47, NULL, 22, 0, 1, 572, 582, N'8795582569', N'sushil@otpl.local', N'dd', N'557958', 1, 0, 0, CAST(N'2019-10-10 17:47:57.930' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'::1', CAST(N'2019-10-10 17:47:57.930' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (48, NULL, 22, 0, 1, 579, 143, N'7239048784', N'', N'dfshrgx', N'850018', 1, 0, 0, CAST(N'2019-10-10 18:46:58.767' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'192.168.0.250', CAST(N'2019-10-10 18:46:58.767' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (49, NULL, 22, 0, 2, 613, 412, N'8960544335', N'', N'himanshu', N'378231', 1, 0, 0, CAST(N'2019-10-11 11:27:08.107' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, N'192.168.0.250', CAST(N'2019-10-11 11:27:08.107' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (50, NULL, 22, 0, 1, 565, 4, N'8687430729', N'', N'Ankita', N'059527', 1, 0, 0, CAST(N'2019-10-11 15:48:46.077' AS DateTime), N'Kusum', CAST(N'1985-02-13 00:00:00.000' AS DateTime), N'Kiran', 34, N'35', N'Anand Vihar, Near ravidas mandir, Gwalora road, Saharanpur 247001, U. P.', 9, 128, N'220152', 565, 4, N'456hf', 4, N'435546768899', N'/Content/UploadedDocs/AddressIdProof/UserIDProof50201910111610250649.pdf', N'Municipality ', N'12', CAST(N'2019-10-16 00:00:00.000' AS DateTime), 8, CAST(445.00 AS Decimal(10, 2)), 0, N'', 11, CAST(56464.00 AS Decimal(10, 2)), CAST(3434.00 AS Decimal(10, 2)), CAST(45.00 AS Decimal(6, 2)), 15, CAST(N'2019-10-15 00:00:00.000' AS DateTime), 30, CAST(45.00 AS Decimal(10, 2)), CAST(44.00 AS Decimal(10, 2)), 1, N'', 1, 0, N'', 1, NULL, N'::1', CAST(N'2019-10-11 15:48:46.077' AS DateTime), CAST(N'2019-10-18 11:23:58.383' AS DateTime), 0, 1, 42, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 0, N'', 1, N'3456665', CAST(N'2019-08-07 00:00:00.000' AS DateTime), CAST(N'2019-10-01 00:00:00.000' AS DateTime), N'/Content/UploadedDocs/AddressIdProof/RegCertificateByGWD50201910111617499720.pdf', 0, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', N'', 5, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (51, NULL, 23, 0, 1, 578, 764, N'8687430729', N'ankitamaurya2078@gmail.com', N'eqwrwe', N'255601', 0, 0, 0, CAST(N'2019-10-12 17:19:08.207' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'::1', CAST(N'2019-10-12 17:19:08.207' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (52, NULL, 22, 25, 1, 578, 763, N'8687430729', N'ankitamaurya2078@gmail.com', N'fghgf', N'285466', 0, 0, 0, CAST(N'2019-10-12 17:48:15.040' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'::1', CAST(N'2019-10-12 17:48:15.040' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (53, NULL, 23, 24, 1, 578, 756, N'8687430729', N'', N'Ankita', N'135847', 0, 0, 0, CAST(N'2019-10-13 13:00:47.573' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'::1', CAST(N'2019-10-13 13:00:47.573' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (54, NULL, 23, 24, 2, 570, 717, N'8687430729', N'', N'Ankita', N'800502', 0, 0, 0, CAST(N'2019-10-13 13:08:49.310' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'::1', CAST(N'2019-10-13 13:08:49.310' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (55, NULL, 23, 24, 1, 578, 754, N'8687430729', N'', N'Ankita', N'307169', 1, 0, 0, CAST(N'2019-10-13 13:11:50.053' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'::1', CAST(N'2019-10-13 13:11:50.053' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (56, NULL, 23, 24, 1, 576, 561, N'8687430729', N'', N'ankita', N'936650', 1, 0, 0, CAST(N'2019-10-13 14:11:49.017' AS DateTime), N'AAAAAAAAAaaaaaaaaaa', CAST(N'1998-05-13 00:00:00.000' AS DateTime), N'Test', 34, N'35', N'Anand Vihar, Near ravidas mandir, Gwalora road, Saharanpur 247001, U. P.', 14, 202, N'220152', 576, 561, N'453453', 5, N'7463-5656-4785-678', N'/Content/UploadedDocs/AddressIdProof/UserIDProof56201910131416058594.pdf', N'434343434', N'45', CAST(N'2019-10-16 00:00:00.000' AS DateTime), 6, CAST(7658.00 AS Decimal(10, 2)), 0, N'', 11, CAST(76567.00 AS Decimal(10, 2)), CAST(676578.00 AS Decimal(10, 2)), CAST(767.00 AS Decimal(6, 2)), 15, CAST(N'2019-10-04 00:00:00.000' AS DateTime), 17, CAST(885.00 AS Decimal(10, 2)), CAST(464.00 AS Decimal(10, 2)), 1, N'7875', 1, 1, N'7879', 0, NULL, N'::1', CAST(N'2019-10-13 14:11:49.017' AS DateTime), CAST(N'2019-10-14 14:23:54.367' AS DateTime), 0, 1, 43, CAST(768.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 2, N'', 1, N'7567687', CAST(N'2019-10-13 00:00:00.000' AS DateTime), CAST(N'2019-10-03 00:00:00.000' AS DateTime), N'/Content/UploadedDocs/AddressIdProof/NOCByGWD56201910131459324936.pdf', 1, CAST(N'2019-09-10 00:00:00.000' AS DateTime), CAST(N'2019-10-15 00:00:00.000' AS DateTime), N'/Content/UploadedDocs/AddressIdProof/NOCByCGWA56201910131509118455.pdf', N'767868', 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (57, NULL, 23, 25, 1, 579, 143, N'8795582569', N'sushil@otpl.local', N'Sushil Kumar Sharma', N'301008', 1, 0, 0, CAST(N'2019-10-13 15:49:21.180' AS DateTime), N'vxcvxv', CAST(N'2001-01-10 00:00:00.000' AS DateTime), N'xcvxcvxc', 33, N'35', N'dfdfdfd', 13, 186, N'888888', 579, 143, N'dfgdfg', 3, N'444444444444', N'/Content/UploadedDocs/AddressIdProof/UserIDProof57201910131558556041.jpg', N'dfgfdg', N'dfgfdg', CAST(N'2019-02-10 00:00:00.000' AS DateTime), 6, CAST(454.00 AS Decimal(10, 2)), 1, N'dfdfdfdf', 10, CAST(4545.00 AS Decimal(10, 2)), CAST(4545.00 AS Decimal(10, 2)), CAST(4545.00 AS Decimal(6, 2)), 15, CAST(N'2019-01-10 00:00:00.000' AS DateTime), 28, CAST(4545.00 AS Decimal(10, 2)), CAST(455.00 AS Decimal(10, 2)), 1, N'5454545', 1, 0, N'fgfgfg', 0, NULL, N'::1', CAST(N'2019-10-13 15:49:21.180' AS DateTime), CAST(N'2019-10-14 15:53:55.463' AS DateTime), 0, 1, 42, CAST(4545.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 1, N'', 0, N'', CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', 0, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', N'', 4, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (58, NULL, 23, 25, 1, 579, 143, N'7239048784', N'', N'Ajay Singh', N'470420', 1, 1, 0, CAST(N'2019-10-15 14:56:16.430' AS DateTime), N'Yadvendra Singh', CAST(N'1987-12-05 00:00:00.000' AS DateTime), N'J P Singh', 33, N'35', N'SS130 Alam bagh', 34, 613, N'226012', 579, 143, N'123', 3, N'6398-5542-3998', N'/gwd/Content/UploadedDocs/AddressIdProof/UserIDProof58201910151510279115.pdf', N'', N'', CAST(N'2019-10-15 00:00:00.000' AS DateTime), 7, CAST(98.00 AS Decimal(10, 2)), 1, N'', 11, CAST(78.00 AS Decimal(10, 2)), CAST(25.00 AS Decimal(10, 2)), CAST(3.50 AS Decimal(6, 2)), 15, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 28, CAST(2400.00 AS Decimal(10, 2)), CAST(8.00 AS Decimal(10, 2)), 0, N'', 0, 0, N'', 1, NULL, N'192.168.0.250', CAST(N'2019-10-15 14:56:16.430' AS DateTime), CAST(N'2019-10-15 19:06:35.870' AS DateTime), 0, 1, 41, CAST(0.00 AS Decimal(10, 2)), CAST(88.00 AS Decimal(10, 2)), CAST(35.00 AS Decimal(10, 2)), CAST(54.00 AS Decimal(10, 2)), CAST(45.00 AS Decimal(10, 2)), 37, 37, 0, N'', 1, N'cvcv', CAST(N'2019-10-14 00:00:00.000' AS DateTime), CAST(N'2019-10-15 00:00:00.000' AS DateTime), N'/gwd/Content/UploadedDocs/AddressIdProof/NOCByGWD58201910151607417229.jpg', 1, CAST(N'2019-10-14 00:00:00.000' AS DateTime), CAST(N'2019-10-15 00:00:00.000' AS DateTime), N'/gwd/Content/UploadedDocs/AddressIdProof/NOCByCGWA58201910151607382977.jpg', N'vcvcv', 5, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (59, NULL, 22, 25, 1, 578, 764, N'8795582569', N'sushil@otpl.local', N'ss', N'155429', 0, 0, 0, CAST(N'2019-10-15 18:23:03.130' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'::1', CAST(N'2019-10-15 18:23:03.130' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (60, NULL, 23, 25, 1, 579, 144, N'7239048784', N'', N'YADVENDRA SINGH', N'873709', 0, 0, 0, CAST(N'2019-10-15 19:03:00.053' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'192.168.0.250', CAST(N'2019-10-15 19:03:00.053' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (61, NULL, 23, 25, 1, 579, 144, N'7239048784', N'', N'SZGZS', N'231818', 0, 0, 0, CAST(N'2019-10-15 19:04:23.760' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'192.168.0.250', CAST(N'2019-10-15 19:04:23.760' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (62, NULL, 22, 25, 1, 577, 93, N'8795582569', N'sushil@otpl.local', N'6566', N'769200', 1, 0, 0, CAST(N'2019-10-16 09:37:42.867' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'::1', CAST(N'2019-10-16 09:37:42.867' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (63, NULL, 23, 25, 1, 578, 763, N'8687430729', N'ankitamaurya2078@gmail.com', N'Ankita', N'233556', 0, 1, 0, CAST(N'2019-10-16 11:18:39.497' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'::1', CAST(N'2019-10-16 11:18:39.497' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (64, NULL, 22, 25, 1, 589, 511, N'8795582569', N'sushil@otpl.local', N'dddddd', N'627640', 0, 0, 1, CAST(N'2019-10-16 11:25:25.117' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'192.168.0.250', CAST(N'2019-10-16 11:25:25.117' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (65, NULL, 23, 25, 1, 579, 143, N'9935536635', N'sudhir@otpl.co.in', N'abc', N'887206', 1, 0, 0, CAST(N'2019-10-16 11:28:12.820' AS DateTime), N'afsd', CAST(N'1991-09-05 00:00:00.000' AS DateTime), N'zsrgtr', 33, N'35', N'asa34353', 34, 579, N'223344', 579, 143, N'123', 3, N'1234-1234-1234', N'/gwd/Content/UploadedDocs/AddressIdProof/UserIDProof65201910161143548254.JPG', N'', N'', CAST(N'2019-10-09 00:00:00.000' AS DateTime), 6, CAST(232.00 AS Decimal(10, 2)), 0, N'', 11, CAST(2323.00 AS Decimal(10, 2)), CAST(23.00 AS Decimal(10, 2)), CAST(3.00 AS Decimal(6, 2)), 15, CAST(N'2019-10-07 00:00:00.000' AS DateTime), 28, CAST(300.00 AS Decimal(10, 2)), CAST(7.00 AS Decimal(10, 2)), 0, N'', 0, 0, N'', 0, NULL, N'192.168.0.250', CAST(N'2019-10-16 11:28:12.820' AS DateTime), CAST(N'2019-10-16 11:45:34.613' AS DateTime), 0, 1, 41, CAST(2323.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 1, N'', 1, N'weret', CAST(N'2019-10-12 00:00:00.000' AS DateTime), CAST(N'2020-10-11 00:00:00.000' AS DateTime), N'/gwd/Content/UploadedDocs/AddressIdProof/NOCByGWD65201910161145329911.JPG', 0, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', N'', 4, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (66, NULL, 23, 25, 1, 573, 731, N'8795582569', N'sushil@otpl.local', N'dd', N'263355', 0, 0, 0, CAST(N'2019-10-16 12:21:00.533' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'192.168.0.250', CAST(N'2019-10-16 12:21:00.533' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (67, NULL, 23, 25, 1, 579, 143, N'7239048784', N'yadvendra.css@gmail.com', N'abcd', N'059564', 1, 0, 0, CAST(N'2019-10-16 12:50:29.837' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'192.168.0.250', CAST(N'2019-10-16 12:50:29.837' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (68, NULL, 23, 25, 1, 571, 216, N'8795582569', N'sushil@otpl.local', N'dfdfdf', N'187266', 0, 0, 0, CAST(N'2019-10-16 13:05:47.903' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'192.168.0.250', CAST(N'2019-10-16 13:05:47.903' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (69, NULL, 23, 25, 1, 570, 723, N'7239048784', N'yadvendra.css@gmail.com', N'YADVENDRA SINGH', N'431688', 1, 0, 0, CAST(N'2019-10-16 13:19:33.367' AS DateTime), N'Yadvendra Singh', CAST(N'1987-12-05 00:00:00.000' AS DateTime), N'J P Singh', 33, N'35', N'206 CHAKWARA DIHA', 34, 570, N'276128', 570, 723, N'236', 3, N'6398-4236-3998', N'/gwd/Content/UploadedDocs/AddressIdProof/UserIDProof69201910161323423589.jpg', N'', N'', CAST(N'2019-10-08 00:00:00.000' AS DateTime), 8, CAST(160.00 AS Decimal(10, 2)), 1, N'GOOD', 11, CAST(120.00 AS Decimal(10, 2)), CAST(13.00 AS Decimal(10, 2)), CAST(5.00 AS Decimal(6, 2)), 15, CAST(N'2019-10-01 00:00:00.000' AS DateTime), 0, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, N'', 0, 0, N'', 0, NULL, N'192.168.0.250', CAST(N'2019-10-16 13:19:33.367' AS DateTime), CAST(N'2019-10-16 13:26:56.217' AS DateTime), 0, 1, 41, CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), CAST(0.00 AS Decimal(10, 2)), 0, 0, 0, N'', 0, N'', CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', 0, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', N'', 3, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (70, NULL, 23, 25, 1, 579, 143, N'9696799138', N'', N'fgfhg', N'518820', 0, 0, 0, CAST(N'2019-10-16 14:23:55.763' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'192.168.0.250', CAST(N'2019-10-16 14:23:55.763' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (71, NULL, 23, 25, 1, 589, 509, N'8795582569', N'sushil@otpl.local', N'12345', N'071058', 1, 0, 0, CAST(N'2019-10-16 14:31:33.273' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'192.168.0.250', CAST(N'2019-10-16 14:31:33.273' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (72, NULL, 23, 25, 2, 579, 143, N'8687430729', N'aaaaa@gmail.com', N'Test', N'257732', 1, 1, 0, CAST(N'2019-10-16 15:05:59.740' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'::1', CAST(N'2019-10-16 15:05:59.740' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (73, NULL, 23, 24, 2, 576, 563, N'8687430729', N'aaaaa@gmail.com', N'test', N'674269', 1, 0, 0, CAST(N'2019-10-16 15:16:36.233' AS DateTime), N'Ankita', CAST(N'2001-08-15 00:00:00.000' AS DateTime), N'BK Maurya', 34, N'35', N'Anand Vihar, Near ravidas mandir, Gwalora road, Saharanpur 247001, U. P.', 4, 46, N'220152', 576, 563, N'456', 3, N'3243-5435-6465', N'/Content/UploadedDocs/AddressIdProof/UserIDProof73201910161528000255.pdf', N'Corporation', N'4556', CAST(N'2019-10-18 00:00:00.000' AS DateTime), 7, CAST(45.00 AS Decimal(10, 2)), 1, N'no particulars regarding water quality of the well', 11, CAST(23.00 AS Decimal(10, 2)), CAST(5345.00 AS Decimal(10, 2)), CAST(4345.00 AS Decimal(6, 2)), 15, CAST(N'2019-10-17 00:00:00.000' AS DateTime), 29, CAST(69.00 AS Decimal(10, 2)), CAST(4.00 AS Decimal(10, 2)), 1, N'submit mode of treatment of waste water', 0, 1, N'No', 1, NULL, N'::1', CAST(N'2019-10-16 15:16:36.233' AS DateTime), CAST(N'2019-10-17 12:08:43.730' AS DateTime), 0, 1, 42, CAST(0.00 AS Decimal(10, 2)), CAST(55.00 AS Decimal(10, 2)), CAST(65.00 AS Decimal(10, 2)), CAST(435.00 AS Decimal(10, 2)), CAST(5454.00 AS Decimal(10, 2)), 38, 39, 0, N'', 1, N'4354657', CAST(N'2019-05-09 00:00:00.000' AS DateTime), CAST(N'2019-10-11 00:00:00.000' AS DateTime), N'/Content/UploadedDocs/AddressIdProof/NOCByGWD73201910171205173672.jpg', 1, CAST(N'2010-05-11 00:00:00.000' AS DateTime), CAST(N'2019-06-20 00:00:00.000' AS DateTime), N'/Content/UploadedDocs/AddressIdProof/NOCByCGWA73201910171205002226.jpg', N'2343546', 5, NULL)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (74, NULL, 23, 25, 1, 579, 145, N'8687430729', N'sd@gmail.com', N'Test', N'406417', 1, 1, 0, CAST(N'2019-10-16 17:37:02.277' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'::1', CAST(N'2019-10-16 17:37:02.277' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (75, NULL, 22, 25, 2, 579, 144, N'8687430729', N'aaa@gmail.com', N'testy', N'571549', 1, 1, 1, CAST(N'2019-10-16 18:16:06.950' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'192.168.0.250', CAST(N'2019-10-16 18:16:06.950' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (76, NULL, 23, 25, 1, 579, 144, N'8687430729', N'ankitamaurya@gmail.com', N'Test ', N'718583', 0, 0, 0, CAST(N'2019-10-16 18:26:50.783' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'192.168.0.250', CAST(N'2019-10-16 18:26:50.783' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 1)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (77, NULL, 23, 25, 1, 579, 143, N'8687430729', N'rrrrr@gmail.com', N'test onee', N'400102', 1, 0, 0, CAST(N'2019-10-16 18:30:10.947' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'192.168.0.250', CAST(N'2019-10-16 18:30:10.947' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (78, NULL, 23, 24, 1, 575, 396, N'8795582569', N'sushil@otpl.local', N'Xzxzxzxzxz', N'048647', 1, 0, 0, CAST(N'2019-10-17 10:05:32.200' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'192.168.0.250', CAST(N'2019-10-17 10:05:32.200' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 0)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (79, NULL, 23, 25, 1, 577, 90, N'8795582569', N'sushil@otpl.local', N'dfgdfg', N'279025', 0, 0, 0, CAST(N'2019-10-17 10:31:49.600' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'192.168.0.250', CAST(N'2019-10-17 10:31:49.600' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (80, NULL, 23, 24, 1, 579, 144, N'5687430729', N'aaa34w234@h.in', N'vastro', N'169596', 0, 0, 0, CAST(N'2019-10-17 11:40:18.690' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'::1', CAST(N'2019-10-17 11:40:18.690' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 0)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (81, NULL, 23, 25, 2, 575, 399, N'8687430729', N'wgergewrt@gmail.com', N'Test ty', N'270886', 1, 1, 0, CAST(N'2019-10-17 11:44:14.923' AS DateTime), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'::1', CAST(N'2019-10-17 11:44:14.923' AS DateTime), NULL, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 1)
INSERT [dbo].[M_Registration] ([RegistrationID], [AppNo], [FormTypeID], [UserCategoryID], [UserTypeID], [RDistrictID], [RBlockID], [MobileNo], [EmailID], [ApplicantName], [OTP], [IsMobileVerified], [HaveNOC], [GWDCertificate], [ApplicationDate], [OwnerName], [DateOfBirth], [CareOF], [Gender], [Nationality], [Address], [StateID], [DistrictID], [Pincode], [P_DistrictID], [P_BlockID], [PlotKhasraNo], [IDProofID], [IDNumber], [IDPath], [MunicipalityCorporation], [WardHoldingNo], [DateOfConstruction], [TypeOfTheWellID], [DepthOfTheWell], [IsAdverseReport], [WaterQuality], [TypeOfPumpID], [LengthColumnPipe], [PumpCapacity], [HorsePower], [OperationalDeviceID], [DateOfEnergization], [PurposeOfWellID], [AnnualRunningHours], [DailyRunningHours], [IsPipedWaterSupply], [ModeOfTreatment], [IsObtainedNOC_UP], [IsRainWaterHarvesting], [Remarks], [IAgree], [IsPaymentDone], [IPAddress], [CreatedOn], [LastModifiedOn], [IsDeleted], [IsActive], [Relation], [DiameterOfDugWell], [ApproxLengthOfPipe], [ApproxDiameterOfPipe], [ApproxLengthOfStrainer], [ApproxDiameterOfStrainer], [MaterialOfPipe], [MaterialOfStrainer], [StructureofdugWell], [IfAny], [RegCertificateIssueByGWD], [RegCertificateNumber], [DateOfRegCertificateIssuance], [DateOfRegCertificateExpiry], [RegCertificatePath], [CentralGroundWaterAuthority], [DateOfNOCIssuanceByCGWD], [DateOfNOCExpiryByCGWD], [NOCByCGWDCertificatePath], [NOCCertificateNumberByCGWD], [StepNo], [RHaveNocByGWD]) VALUES (82, N'LKNW1019NIF0001', 22, 25, 1, 613, 417, N'8687430729', N'ankita2212@gmail.com', N'Ankita Singh', N'884276', 1, 0, 1, CAST(N'2019-10-18 15:55:25.860' AS DateTime), N'Ankita Singh', CAST(N'1995-05-17 00:00:00.000' AS DateTime), N'BK Singh', 34, N'35', N'Anand Vihar, Near ravidas mandir, Gwalora road, Saharanpur 247001, U. P.', 34, 629, N'225632', 613, 417, N'4523', 3, N'4345-3454-6656-5765', N'/Content/UploadedDocs/AddressIdProof/UserIDProof82201910181558114799.pdf', N'Municipality ', N'4556', CAST(N'2019-10-16 00:00:00.000' AS DateTime), 7, CAST(32.00 AS Decimal(10, 2)), 1, N'Give particulars regarding water quality of the we', 13, CAST(44.00 AS Decimal(10, 2)), CAST(445.00 AS Decimal(10, 2)), CAST(77.00 AS Decimal(6, 2)), 15, CAST(N'2019-10-08 00:00:00.000' AS DateTime), 30, CAST(3323.00 AS Decimal(10, 2)), CAST(12.00 AS Decimal(10, 2)), 0, N'purifier', 0, 1, N'no information', 1, NULL, N'::1', CAST(N'2019-10-18 15:55:25.860' AS DateTime), CAST(N'2019-10-18 17:10:05.767' AS DateTime), 0, 1, 42, CAST(0.00 AS Decimal(10, 2)), CAST(23.00 AS Decimal(10, 2)), CAST(34.00 AS Decimal(10, 2)), CAST(234.00 AS Decimal(10, 2)), CAST(343.00 AS Decimal(10, 2)), 38, 39, 0, N'', 1, N'3325564353534', CAST(N'2011-02-09 00:00:00.000' AS DateTime), CAST(N'2019-09-17 00:00:00.000' AS DateTime), N'/Content/UploadedDocs/AddressIdProof/RegCertificateByGWD82201910181602294231.pdf', 0, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'', N'', 5, 1)
SET IDENTITY_INSERT [dbo].[M_Registration] OFF
SET IDENTITY_INSERT [dbo].[M_State] ON 

INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (1, 1, N'Andaman and Nicobar Island', NULL, 0, 1)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (2, 1, N'Andhra Pradesh', NULL, 0, 2)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (3, 1, N'Arunachal Pradesh', NULL, 0, 3)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (4, 1, N'Assam', NULL, 0, 4)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (5, 1, N'Bihar', NULL, 0, 5)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (6, 1, N'Chandigarh', NULL, 0, 6)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (7, 1, N'Chhattisgarh', NULL, 0, 7)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (8, 1, N'Dadra and Nagar Haveli', NULL, 0, 8)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (9, 1, N'Daman and Diu', NULL, 0, 9)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (10, 1, N'Delhi', NULL, 0, 10)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (11, 1, N'Goa', NULL, 0, 11)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (12, 1, N'Gujarat', NULL, 0, 12)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (13, 1, N'Haryana', NULL, 0, 13)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (14, 1, N'Himachal Pradesh', NULL, 0, 14)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (15, 1, N'Jammu and Kashmir', NULL, 0, 15)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (16, 1, N'Jharkhand', NULL, 0, 16)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (17, 1, N'Karnataka', NULL, 0, 17)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (18, 1, N'Kerala', NULL, 0, 18)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (19, 1, N'Lakshadweep', NULL, 0, 19)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (20, 1, N'Madhya Pradesh', NULL, 0, 20)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (21, 1, N'Maharashtra', NULL, 0, 21)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (22, 1, N'Manipur', NULL, 0, 22)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (23, 1, N'Meghalaya', NULL, 0, 23)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (24, 1, N'Mizoram', NULL, 0, 24)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (25, 1, N'Nagaland', NULL, 0, 25)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (26, 1, N'Odisha', NULL, 0, 27)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (27, 1, N'Puducherry', NULL, 0, 28)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (28, 1, N'Punjab', NULL, 0, 29)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (29, 1, N'Rajasthan', NULL, 0, 30)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (30, 1, N'Sikkim', NULL, 0, 31)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (31, 1, N'Tamil Nadu', NULL, 0, 32)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (32, 1, N'Telangana', NULL, 0, 33)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (33, 1, N'Tripura', NULL, 0, 34)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (34, 1, N'Uttar Pradesh', NULL, 0, 0)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (35, 1, N'Uttarakhand', NULL, 0, 36)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (36, 1, N'West Bengal', NULL, 0, 37)
INSERT [dbo].[M_State] ([StateID], [CountryID], [StateName], [StateNameHindi], [IsDeleted], [SortOrder]) VALUES (37, 1, N'Not Applicable', NULL, 0, 38)
SET IDENTITY_INSERT [dbo].[M_State] OFF
SET IDENTITY_INSERT [dbo].[Sec_UserMaster] ON 

INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (1, N'A8687430729', N'63E174241F0EC0947B885C9ABF46C691', N'OFj7Exxm', NULL, 0, 0, 0, CAST(N'2019-10-07 15:14:09.003' AS DateTime), N'::1', NULL, CAST(N'2019-10-05 13:06:37.613' AS DateTime), 1, 1)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (2, N'A8795582569', N'7EE632AFABE094B0981C02A3DA7B8765', N'bqEfVdWA', NULL, 0, 0, 0, CAST(N'2019-10-15 18:04:20.540' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-05 13:06:49.470' AS DateTime), 1, 3)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (3, N'B8795582569', N'9F8F236FB9497AB22E701F330FB93146', N'x5mOBRPP', NULL, 0, 0, 0, CAST(N'2019-10-15 12:36:32.710' AS DateTime), N'::1', NULL, CAST(N'2019-10-05 13:13:58.513' AS DateTime), 1, 4)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (4, N'C8795582569', N'B88561CB8E44443EB1DEA1C3D5D45D0B', N'IvIczYAE', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-05 13:15:12.950' AS DateTime), 1, 5)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (5, N'D8795582569', N'392EE8E93583D8D4CD955484CF4C62CE', N'VmqBne8S', NULL, 0, 0, 0, CAST(N'2019-10-16 14:24:38.217' AS DateTime), N'::1', NULL, CAST(N'2019-10-05 13:19:25.993' AS DateTime), 1, 6)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (6, N'E8795582569', N'839F1BA0DD83AC219555396BF4BFF091', N'RvBswf97', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-05 13:25:25.610' AS DateTime), 1, 7)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (7, N'F8795582569', N'5D8E9C1FBBE42BF1FAB8285280C419BE', N'xwpls0s5', NULL, 0, 0, 0, CAST(N'2019-10-05 16:05:20.623' AS DateTime), N'::1', NULL, CAST(N'2019-10-05 14:11:48.907' AS DateTime), 1, 8)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (8, N'G8795582569', N'7388EFEA95DAE7CB464731AB2E5A1008', N'rqyEPEnK', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-05 15:08:34.320' AS DateTime), 1, 9)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (9, N'A9839849223', N'5724C0AA4731F1F6B32C816CD50B1DED', N' ', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-05 15:18:08.970' AS DateTime), 1, 10)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (10, N'A8318825710', N'2B590E78A30B066BB148963C2EFB934A', N'eFqzmc2h', NULL, 0, 0, 0, CAST(N'2019-10-05 15:40:07.453' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-05 15:38:30.950' AS DateTime), 1, 11)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (11, N'DRL1900002', N'1989613119424195207612291582019915060', N'UD4J40', N'DRL1900002', 0, 0, 1, CAST(N'2019-10-09 10:41:54.783' AS DateTime), N'::1', 0, CAST(N'2019-10-05 15:38:51.370' AS DateTime), 1, NULL)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (12, N'A9140675876', N'8951C77A4D0E745B51857DA86D189328', N'b1bpSpGC', NULL, 0, 0, 0, CAST(N'2019-10-17 12:59:20.680' AS DateTime), N'::1', NULL, CAST(N'2019-10-05 17:20:46.740' AS DateTime), 1, 12)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (13, N'B9140675876', N'C78FF47518B3A42AAF99DED926DC956D', N'cGe2kuf0', NULL, 0, 0, 0, CAST(N'2019-10-07 17:38:22.877' AS DateTime), N'::1', NULL, CAST(N'2019-10-05 17:39:44.460' AS DateTime), 1, 15)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (14, N'B9839849223', N'A96CE1C12D81A26FAE20D50D2BBCA628', N'WXe6GhWy', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-07 12:20:49.997' AS DateTime), 1, 16)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (15, N'A7239048784', N'CAFDF4470D161EFDAF7B0C0E8E4CAF94', N'cRjPajXX', NULL, 0, 0, 0, CAST(N'2019-10-07 12:30:12.317' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-07 12:29:02.380' AS DateTime), 1, 17)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (16, N'B8687430729', N'202CB962AC59075B964B07152D234B70', N'123', NULL, 0, 0, 0, CAST(N'2019-10-16 14:26:13.223' AS DateTime), N'::1', NULL, CAST(N'2019-10-07 18:45:52.853' AS DateTime), 1, 18)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (17, N'B7239048784', N'202CB962AC59075B964B07152D234B70', N'123', NULL, 0, 0, 0, CAST(N'2019-10-09 19:11:51.690' AS DateTime), N'::1', NULL, CAST(N'2019-10-09 10:47:55.760' AS DateTime), 1, 19)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (18, N'A9696799138', N'E2282F83088422E4552385D5378B7C80', N'051e00Cp', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-09 10:57:17.747' AS DateTime), 1, 20)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (19, N'B9696799138', N'6B1B5409BC22FF57F4519F3023FC9F98', N'ZbkDGd4y', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-09 11:11:56.493' AS DateTime), 1, 21)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (20, N'C9696799138', N'FE4472AC7F53CC15F0340FD163A77205', N'0gJf6aAi', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-09 11:13:43.493' AS DateTime), 1, 22)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (21, N'H8795582569', N'85635BC64595F21C8739DC9E720FEBD3', N'Oq51WHnu', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-09 11:20:15.737' AS DateTime), 1, 23)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (22, N'I8795582569', N'DF3BE50C4BD8825386A881FA75008035', N'3DyoFA8a', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-09 11:31:33.573' AS DateTime), 1, 24)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (23, N'J8795582569', N'D2EECB35B995F3CE9E6156DE3EC6FF6C', N'9huKNA9u', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-09 12:04:03.990' AS DateTime), 1, 25)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (24, N'K8795582569', N'E46E2106F53FBDEBF1BD9148E3EE14D0', N'RHhTjYIt', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-09 12:33:39.963' AS DateTime), 1, 30)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (25, N'L8795582569', N'36A7AB4022347C222F8416CB46AE9E2A', N'Y9c3chgk', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-09 12:40:29.203' AS DateTime), 1, 32)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (26, N'DRL1900003', N'19414917824612512416159250136129211123248132207', N'5F51QL', N'DRL1900003', 0, 0, 1, CAST(N'2019-10-18 09:57:45.963' AS DateTime), N'::1', 0, CAST(N'2019-10-09 18:07:14.050' AS DateTime), 1, NULL)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (27, N'C8687430729', N'119C03E1159E050F48117C042283FC12', N'EZQs0e0L', NULL, 0, 0, 0, CAST(N'2019-10-10 15:19:11.853' AS DateTime), N'::1', NULL, CAST(N'2019-10-09 18:16:59.343' AS DateTime), 1, 36)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (28, N'C7239048784', N'202CB962AC59075B964B07152D234B70', N'123', NULL, 0, 0, 0, CAST(N'2019-10-10 12:32:48.010' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-09 19:31:35.933' AS DateTime), 1, 37)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (29, N'D7239048784', N'202CB962AC59075B964B07152D234B70', N'123', NULL, 0, 0, 0, CAST(N'2019-10-10 12:21:20.297' AS DateTime), N'::1', NULL, CAST(N'2019-10-10 11:09:16.537' AS DateTime), 1, 38)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (30, N'A9721777786', N'8C882D2585669DDF028C885F753C35B4', N'h4uDOLJ1', NULL, 0, 0, 0, CAST(N'2019-10-10 12:30:48.493' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-10 12:29:43.160' AS DateTime), 1, 39)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (31, N'A7007355085', N'F07A70E238CCA4A7907C386805AC600C', N'kfd7J9WU', NULL, 0, 0, 0, CAST(N'2019-10-10 15:12:50.823' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-10 15:07:22.303' AS DateTime), 1, 41)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (32, N'E7239048784', N'06EA6165FF6DDB814AF9B3FA477020F2', N'Al1vpMR9', NULL, 0, 0, 0, CAST(N'2019-10-10 17:22:13.723' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-10 17:19:28.037' AS DateTime), 1, 42)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (33, N'F7239048784', N'C846B4377161ABCA99A7EDCD9D2F13E4', N'Cd153VE2', NULL, 0, 0, 0, CAST(N'2019-10-10 18:48:44.437' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-10 17:37:28.470' AS DateTime), 1, 45)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (34, N'D8687430729', N'2DF7DC6928CCC26E9652EFE996659352', N'bIqnkIEw', NULL, 0, 0, 0, CAST(N'2019-10-17 13:02:39.803' AS DateTime), N'::1', NULL, CAST(N'2019-10-10 17:39:17.470' AS DateTime), 1, 46)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (35, N'M8795582569', N'A357CD24ADC6797ACF49E3A79973B8AF', N'6FTDbLqr', NULL, 0, 0, 0, CAST(N'2019-10-15 17:17:14.323' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-10 17:49:08.950' AS DateTime), 1, 47)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (36, N'G7239048784', N'66917D26DD752B49574712FA1DCD8F93', N'HJKtcWnz', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-10 18:47:34.720' AS DateTime), 1, 48)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (37, N'A8960544335', N'B02F8BF4A84AA511F206748CCA2DF0E8', N'9IxRdBYX', NULL, 0, 0, 0, CAST(N'2019-10-11 14:20:30.680' AS DateTime), N'::1', NULL, CAST(N'2019-10-11 11:27:32.333' AS DateTime), 1, 49)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (38, N'E8687430729', N'202CB962AC59075B964B07152D234B70', N'123', NULL, 0, 0, 0, CAST(N'2019-10-18 14:48:42.723' AS DateTime), N'::1', NULL, CAST(N'2019-10-11 15:50:58.780' AS DateTime), 1, 50)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (39, N'F8687430729', N'8E6777C42CCEADC20ECBD08AA7BE517F', N'HHCuoJLi', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-13 13:14:02.060' AS DateTime), 1, 55)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (40, N'G8687430729', N'7DD34CF922B0AC7E1E14B7791EF5F887', N'D9MwE9mI', NULL, 0, 0, 0, CAST(N'2019-10-14 16:24:09.803' AS DateTime), N'::1', NULL, CAST(N'2019-10-13 14:12:16.030' AS DateTime), 1, 56)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (41, N'N8795582569', N'E14E4B41ADA01C6A972651DB46FCB57E', N'sEVWutFq', NULL, 0, 0, 0, CAST(N'2019-10-15 18:02:43.507' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-13 15:49:48.530' AS DateTime), 1, 57)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (42, N'H7239048784', N'202CB962AC59075B964B07152D234B70', N'123', NULL, 0, 0, 0, CAST(N'2019-10-17 11:22:47.110' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-15 14:58:22.517' AS DateTime), 1, 58)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (43, N'DRL1900004', N'11167662483236411440462335275134168230', N'3YENGH', N'DRL1900004', 0, 0, 1, CAST(N'2019-10-15 16:03:37.787' AS DateTime), N'192.168.0.250', 0, CAST(N'2019-10-15 16:02:00.227' AS DateTime), 1, NULL)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (44, N'O8795582569', N'000F32F69BE9807FBB131A047AEC13BA', N'eEnQyiup', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-16 09:38:30.367' AS DateTime), 1, 62)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (45, N'A9935536635', N'7695654D47D421A630FE985E0EAF409E', N'QQYo1kZY', NULL, 0, 0, 0, CAST(N'2019-10-16 11:37:01.460' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-16 11:30:00.890' AS DateTime), 1, 65)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (46, N'I7239048784', N'FB548BBA8AA230F54463923D073DAB92', N'I3OBbyPy', NULL, 0, 0, 0, CAST(N'2019-10-16 13:08:32.530' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-16 13:02:44.927' AS DateTime), 1, 67)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (47, N'J7239048784', N'6161C5F0DEEAD1E72ABDE4C8F97FC6F9', N'0QW99Uud', NULL, 0, 0, 0, CAST(N'2019-10-16 13:21:53.940' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-16 13:20:44.030' AS DateTime), 1, 69)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (48, N'P8795582569', N'9894848AD2F2DB4BDC888F9A634ABD9A', N'bThRHdye', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-16 14:31:57.967' AS DateTime), 1, 71)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (49, N'H8687430729', N'D60E61C52C0ABF380EC77D174C8D9BAB', N'iTmLCJUH', NULL, 0, 0, 0, NULL, NULL, NULL, CAST(N'2019-10-16 15:06:50.680' AS DateTime), 1, 72)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (50, N'I8687430729', N'202CB962AC59075B964B07152D234B70', N'123', NULL, 0, 0, 0, CAST(N'2019-10-18 15:47:52.130' AS DateTime), N'::1', NULL, CAST(N'2019-10-16 15:17:07.253' AS DateTime), 1, 73)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (51, N'J8687430729', N'2D965D36D80ECB721A6FC28F2280E0DE', N'kSjkLG2p', NULL, 0, 0, 0, CAST(N'2019-10-16 18:41:29.727' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-16 17:38:22.197' AS DateTime), 1, 74)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (52, N'K8687430729', N'9AFFAA2E654811749AA250C405520DD0', N'1ArRIUDb', NULL, 0, 0, 0, CAST(N'2019-10-16 18:43:44.287' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-16 18:18:24.363' AS DateTime), 1, 75)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (53, N'L8687430729', N'202CB962AC59075B964B07152D234B70', N'123', NULL, 0, 0, 0, CAST(N'2019-10-18 15:11:13.913' AS DateTime), N'::1', NULL, CAST(N'2019-10-16 18:31:30.047' AS DateTime), 1, 77)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (54, N'Q8795582569', N'691CC9DE5D462D093F54250E6F6C7D11', N'QGHAhQEW', NULL, 0, 0, 0, CAST(N'2019-10-17 10:12:31.617' AS DateTime), N'192.168.0.250', NULL, CAST(N'2019-10-17 10:06:20.930' AS DateTime), 1, 78)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (55, N'M8687430729', N'58D358B9A84D4DE47BF24A1A8DA750BF', N'1JIv3jsM', NULL, 0, 0, 0, CAST(N'2019-10-18 11:17:39.767' AS DateTime), N'::1', NULL, CAST(N'2019-10-17 11:44:57.480' AS DateTime), 1, 81)
INSERT [dbo].[Sec_UserMaster] ([UserID], [UserName], [Password], [DisplayPassword], [AppNo], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [CreatedOn], [IsActive], [RegistrationID]) VALUES (56, N'N8687430729', N'5D8D1B605C0FAA26533CAFF07216D9D0', N'b0GFmek7', NULL, 0, 0, 0, CAST(N'2019-10-18 17:09:32.743' AS DateTime), N'::1', NULL, CAST(N'2019-10-18 15:56:34.850' AS DateTime), 1, 82)
SET IDENTITY_INSERT [dbo].[Sec_UserMaster] OFF
SET IDENTITY_INSERT [dbo].[T_DrillingDistrictMachine] ON 

INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (1, 1, N'DRL1900001', 565, N'test', NULL, 1, CAST(N'2019-10-04 12:31:48.053' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (2, 1, N'DRL1900001', 566, N'test', NULL, 1, CAST(N'2019-10-04 12:31:48.053' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (3, 1, N'DRL1900001', 568, N'test', NULL, 1, CAST(N'2019-10-04 12:31:48.053' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (4, 1, N'DRL1900001', 566, N'567', NULL, 1, CAST(N'2019-10-04 12:33:45.547' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (5, 1, N'DRL1900001', 568, N'567', NULL, 1, CAST(N'2019-10-04 12:33:45.547' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (6, 1, N'DRL1900001', 565, N'567', N'G', 1, CAST(N'2019-10-04 12:40:14.667' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (7, 1, N'DRL1900001', 566, N'567', N'G', 1, CAST(N'2019-10-04 12:40:14.667' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (8, 1, N'DRL1900001', 568, N'567', N'G', 1, CAST(N'2019-10-04 12:40:14.667' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (9, 1, N'DRL1900001', 574, N'567', N'G', 1, CAST(N'2019-10-04 12:40:31.303' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (10, 1, N'DRL1900001', 575, N'567', N'G', 1, CAST(N'2019-10-04 12:40:31.303' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (11, 1, N'DRL1900001', 576, N'567', N'G', 1, CAST(N'2019-10-04 12:40:31.303' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (12, 1, N'DRL1900001', 577, N'567', N'G', 1, CAST(N'2019-10-04 12:40:31.303' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (13, 1, N'DRL1900001', 565, N'567', N'G', 1, CAST(N'2019-10-04 12:41:59.080' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (14, 1, N'DRL1900001', 566, N'567', N'G', 1, CAST(N'2019-10-04 12:41:59.080' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (15, 1, N'DRL1900001', 568, N'567', N'G', 1, CAST(N'2019-10-04 12:41:59.080' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (16, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-04 13:15:14.877' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (17, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-04 13:15:14.877' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (18, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-04 13:15:14.877' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (19, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-05 11:43:01.303' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (20, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-05 11:43:01.303' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (21, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-05 11:43:01.303' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (22, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-05 11:43:26.463' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (23, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-05 11:43:26.463' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (24, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-05 11:43:26.463' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (25, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-05 11:43:48.900' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (26, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-05 11:43:48.900' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (27, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-05 11:43:48.900' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (28, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-05 11:44:19.310' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (29, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-05 11:44:19.310' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (30, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-05 11:44:19.310' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (31, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-05 11:44:48.537' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (32, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-05 11:44:48.537' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (33, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-05 11:44:48.537' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (34, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-05 11:48:05.263' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (35, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-05 11:48:05.263' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (36, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-05 11:48:05.263' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (37, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-05 11:49:02.880' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (38, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-05 11:49:02.880' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (39, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-05 11:49:02.880' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (40, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-05 11:50:37.303' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (41, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-05 11:50:37.303' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (42, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-05 11:50:37.303' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (43, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-05 11:51:15.493' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (44, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-05 11:51:15.493' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (45, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-05 11:51:15.493' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (46, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-05 11:56:23.580' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (47, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-05 11:56:23.580' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (48, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-05 11:56:23.580' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (49, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-05 11:57:21.290' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (50, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-05 11:57:21.290' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (51, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-05 11:57:21.290' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (52, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-05 11:58:15.757' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (53, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-05 11:58:15.757' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (54, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-05 11:58:15.757' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (55, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-05 11:58:54.027' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (56, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-05 11:58:54.027' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (57, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-05 11:58:54.027' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (58, 1, N'DRL1900001', 565, N'567', N'P', 1, CAST(N'2019-10-05 12:01:43.390' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (59, 1, N'DRL1900001', 566, N'567', N'P', 1, CAST(N'2019-10-05 12:01:43.390' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (60, 1, N'DRL1900001', 568, N'567', N'P', 1, CAST(N'2019-10-05 12:01:43.390' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (61, 1, N'DRL1900001', 565, N'567', N'P', 0, CAST(N'2019-10-05 12:14:35.480' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (62, 1, N'DRL1900001', 566, N'567', N'P', 0, CAST(N'2019-10-05 12:14:35.480' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (63, 1, N'DRL1900001', 568, N'567', N'P', 0, CAST(N'2019-10-05 12:14:35.480' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (64, 1, N'DRL1900001', 565, N'Test ', N'G', 0, CAST(N'2019-10-05 17:58:04.017' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (65, 2, N'DRL1900002', 565, N'Test ', N'G', 0, CAST(N'2019-10-05 17:58:04.017' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (66, 1, N'DRL1900001', 566, N'Test ', N'G', 0, CAST(N'2019-10-05 17:58:04.017' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (67, 2, N'DRL1900002', 566, N'Test ', N'G', 0, CAST(N'2019-10-05 17:58:04.017' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (68, 1, N'DRL1900001', 568, N'Test ', N'G', 0, CAST(N'2019-10-05 17:58:04.017' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (69, 2, N'DRL1900002', 568, N'Test ', N'G', 0, CAST(N'2019-10-05 17:58:04.017' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (70, 1, N'DRL1900001', 565, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-09 18:11:46.640' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (71, 2, N'DRL1900002', 565, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-09 18:11:46.640' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (72, 3, N'DRL1900003', 565, N'TEST DETAIL', N'G', 1, CAST(N'2019-10-09 18:11:46.640' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (73, 1, N'DRL1900001', 566, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-09 18:11:46.640' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (74, 2, N'DRL1900002', 566, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-09 18:11:46.640' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (75, 3, N'DRL1900003', 566, N'TEST DETAIL', N'G', 1, CAST(N'2019-10-09 18:11:46.640' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (76, 1, N'DRL1900001', 568, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-09 18:11:46.640' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (77, 2, N'DRL1900002', 568, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-09 18:11:46.640' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (78, 3, N'DRL1900003', 568, N'TEST DETAIL', N'G', 1, CAST(N'2019-10-09 18:11:46.640' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (79, 1, N'DRL1900001', 565, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-09 18:13:42.360' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (80, 2, N'DRL1900002', 565, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-09 18:13:42.360' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (81, 3, N'DRL1900003', 565, N'TEST DETAIL', N'G', 1, CAST(N'2019-10-09 18:13:42.360' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (82, 1, N'DRL1900001', 568, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-09 18:13:42.360' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (83, 2, N'DRL1900002', 568, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-09 18:13:42.360' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (84, 3, N'DRL1900003', 568, N'TEST DETAIL', N'G', 1, CAST(N'2019-10-09 18:13:42.360' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (85, 1, N'DRL1900001', 565, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-10 15:39:02.120' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (86, 2, N'DRL1900002', 565, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-10 15:39:02.120' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (87, 3, N'DRL1900003', 565, N'TEST DETAIL', N'G', 1, CAST(N'2019-10-10 15:39:02.120' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (88, 1, N'DRL1900001', 566, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-10 15:39:02.120' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (89, 2, N'DRL1900002', 566, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-10 15:39:02.120' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (90, 3, N'DRL1900003', 566, N'TEST DETAIL', N'G', 1, CAST(N'2019-10-10 15:39:02.120' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (91, 1, N'DRL1900001', 568, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-10 15:39:02.120' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (92, 2, N'DRL1900002', 568, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-10 15:39:02.120' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (93, 3, N'DRL1900003', 568, N'TEST DETAIL', N'G', 1, CAST(N'2019-10-10 15:39:02.120' AS DateTime), N'::1')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (94, 1, N'DRL1900001', 565, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-15 14:31:01.817' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (95, 2, N'DRL1900002', 565, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-15 14:31:01.817' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (96, 3, N'DRL1900003', 565, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-15 14:31:01.817' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (97, 1, N'DRL1900001', 566, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-15 14:31:01.817' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (98, 2, N'DRL1900002', 566, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-15 14:31:01.817' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (99, 3, N'DRL1900003', 566, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-15 14:31:01.817' AS DateTime), N'192.168.0.250')
GO
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (100, 1, N'DRL1900001', 568, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-15 14:31:01.817' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (101, 2, N'DRL1900002', 568, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-15 14:31:01.817' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (102, 3, N'DRL1900003', 568, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-15 14:31:01.817' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (103, 1, N'DRL1900001', 584, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-15 14:31:01.817' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (104, 2, N'DRL1900002', 584, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-15 14:31:01.817' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (105, 3, N'DRL1900003', 584, N'TEST DETAIL', N'G', 0, CAST(N'2019-10-15 14:31:01.817' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (106, 1, N'DRL1900001', 565, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (107, 2, N'DRL1900002', 565, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (108, 3, N'DRL1900003', 565, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (109, 4, N'DRL1900004', 565, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (110, 1, N'DRL1900001', 566, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (111, 2, N'DRL1900002', 566, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (112, 3, N'DRL1900003', 566, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (113, 4, N'DRL1900004', 566, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (114, 1, N'DRL1900001', 568, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (115, 2, N'DRL1900002', 568, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (116, 3, N'DRL1900003', 568, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (117, 4, N'DRL1900004', 568, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (118, 1, N'DRL1900001', 584, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (119, 2, N'DRL1900002', 584, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (120, 3, N'DRL1900003', 584, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (121, 4, N'DRL1900004', 584, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (122, 1, N'DRL1900001', 604, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (123, 2, N'DRL1900002', 604, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (124, 3, N'DRL1900003', 604, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
INSERT [dbo].[T_DrillingDistrictMachine] ([AutoId], [RegId], [AppNo], [DistrictId], [DrillingMachineDetail], [DrillingPurposeId], [Isdeleted], [TransDate], [TransIPAddress]) VALUES (125, 4, N'DRL1900004', 604, N'ASRDGR,MKDF', N'B', 0, CAST(N'2019-10-15 16:06:07.423' AS DateTime), N'192.168.0.250')
SET IDENTITY_INSERT [dbo].[T_DrillingDistrictMachine] OFF
SET IDENTITY_INSERT [dbo].[T_DrillingRegistration] ON 

INSERT [dbo].[T_DrillingRegistration] ([RegId], [AppNo], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [TransDate], [Isdeleted], [IPAddress], [OwnerName], [SpouseTitle], [SpouseWardName], [DOB], [Gender], [Nationality], [PanCardPath], [GSTCertificatePath], [Address], [StateId], [DistrictId], [Pincode], [StepNo], [RegIPAddress], [RegDate]) VALUES (1, N'DRL1900001', N'1900006', 1, N'Test 786786', N'Test Applicant Name', N'89374983', N'4r89347', N'AAAAA8979A', N'1231231234', N'akashditm93@gmail.com', CAST(N'2019-09-30 15:06:56.797' AS DateTime), 0, N'::1', N'test name', N'S', N'Test Spouse', CAST(N'1990-02-03 00:00:00.000' AS DateTime), N'M', N'I', N'PanCard_DRL1900001_637057107446350989.jpeg', N'GSTCertificate_DRL1900001_637057107484178502.jpg', N'test lko', 34, 613, N'226001', 3, N'::1', CAST(N'2019-10-05 12:01:36.683' AS DateTime))
INSERT [dbo].[T_DrillingRegistration] ([RegId], [AppNo], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [TransDate], [Isdeleted], [IPAddress], [OwnerName], [SpouseTitle], [SpouseWardName], [DOB], [Gender], [Nationality], [PanCardPath], [GSTCertificatePath], [Address], [StateId], [DistrictId], [Pincode], [StepNo], [RegIPAddress], [RegDate]) VALUES (2, N'DRL1900002', N'1900008', 1, N'test Company Name', N'Test Applicant', N'487347', N'897897', N'aaaaa1234A', N'0000000000', N'test@test.com', CAST(N'2019-10-05 15:38:51.370' AS DateTime), 0, N'::1', N'Test', N'S', N'test Ward', CAST(N'1981-05-06 00:00:00.000' AS DateTime), N'M', N'I', N'PanCard_DRL1900002_637058889010643903.jpeg', N'GSTCertificate_DRL1900002_637058889043377006.jpeg', N'Lucknow', 34, 613, N'226001', 3, N'::1', CAST(N'2019-10-05 16:34:37.823' AS DateTime))
INSERT [dbo].[T_DrillingRegistration] ([RegId], [AppNo], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [TransDate], [Isdeleted], [IPAddress], [OwnerName], [SpouseTitle], [SpouseWardName], [DOB], [Gender], [Nationality], [PanCardPath], [GSTCertificatePath], [Address], [StateId], [DistrictId], [Pincode], [StepNo], [RegIPAddress], [RegDate]) VALUES (3, N'DRL1900003', N'1900009', 1, N'test', N'test', N'5445yre', N'5765', N'adase5434e', N'9807256106', N'TEST@TEST.COM', CAST(N'2019-10-09 18:07:14.050' AS DateTime), 0, N'::1', N'TEST', N'S', N'TEST', CAST(N'2000-05-10 00:00:00.000' AS DateTime), N'M', N'I', N'PanCard_DRL1900003_637062414623451020.jpeg', N'GSTCertificate_DRL1900003_637062414644395871.jpg', N'LUCKNOW', 34, 613, N'226001', 3, N'192.168.0.250', CAST(N'2019-10-15 14:30:39.897' AS DateTime))
INSERT [dbo].[T_DrillingRegistration] ([RegId], [AppNo], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [TransDate], [Isdeleted], [IPAddress], [OwnerName], [SpouseTitle], [SpouseWardName], [DOB], [Gender], [Nationality], [PanCardPath], [GSTCertificatePath], [Address], [StateId], [DistrictId], [Pincode], [StepNo], [RegIPAddress], [RegDate]) VALUES (4, N'DRL1900004', N'1900011', 1, N'abc', N'xyz', N'123456789', N'0000000000', N'GTKPS2241L', N'7239048784', N'YADVENDRA.CSS@GMAIL.COM', CAST(N'2019-10-15 16:02:00.227' AS DateTime), 0, N'192.168.0.250', N'ADAM', N'S', N'AZEX', CAST(N'1987-05-12 00:00:00.000' AS DateTime), N'M', N'I', N'PanCard_DRL1900004_637067522907221592.jpg', N'GSTCertificate_DRL1900004_637067522955064329.jpg', N'DZHTXSR56788231', 34, 570, N'276128', 3, N'192.168.0.250', CAST(N'2019-10-15 16:05:51.297' AS DateTime))
SET IDENTITY_INSERT [dbo].[T_DrillingRegistration] OFF
SET IDENTITY_INSERT [dbo].[T_TempDrillingReg] ON 

INSERT [dbo].[T_TempDrillingReg] ([autoId], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [OTP], [OTPDate], [TransDate], [Isdeleted], [IPAddress]) VALUES (1, N'1900001', 2, N'Test Company Name', N'Test Applicant Name', N'I/8943/feri', N'384ERYIE', N'ABCDR0000E', N'9140586033', N'akashditm93@gmail.com', N'583175', CAST(N'2019-09-30 10:34:32.897' AS DateTime), CAST(N'2019-09-30 10:34:32.897' AS DateTime), 0, N'::1')
INSERT [dbo].[T_TempDrillingReg] ([autoId], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [OTP], [OTPDate], [TransDate], [Isdeleted], [IPAddress]) VALUES (2, N'1900002', 2, N'Test Company Name', N'Test Applicant Name', N'I/8943/feri', N'384ERYIE', N'ABCDR0000E', N'9140586033', N'akashditm93@gmail.com', N'079947', CAST(N'2019-09-30 10:38:07.050' AS DateTime), CAST(N'2019-09-30 10:38:07.050' AS DateTime), 0, N'::1')
INSERT [dbo].[T_TempDrillingReg] ([autoId], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [OTP], [OTPDate], [TransDate], [Isdeleted], [IPAddress]) VALUES (3, N'1900003', 1, N'Test Firm', N'Test Applicant', N'T0009TTT', N'GST/079876', N'abcdr9088e', N'9140586033', N'akashditm93@gmail.com', N'695240', CAST(N'2019-09-30 10:42:15.887' AS DateTime), CAST(N'2019-09-30 10:42:15.887' AS DateTime), 0, N'::1')
INSERT [dbo].[T_TempDrillingReg] ([autoId], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [OTP], [OTPDate], [TransDate], [Isdeleted], [IPAddress]) VALUES (4, N'1900004', 2, N'Test  Company Name', N'Applicant Name', N'645ert', N'34534rt', N'AAAAA2332a', N'0000000000', N'akashditm93@gmail.com', N'572013', CAST(N'2019-09-30 14:46:50.207' AS DateTime), CAST(N'2019-09-30 14:46:50.207' AS DateTime), 0, N'::1')
INSERT [dbo].[T_TempDrillingReg] ([autoId], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [OTP], [OTPDate], [TransDate], [Isdeleted], [IPAddress]) VALUES (5, N'1900005', 1, N'Test', N'test Applicant', N'4897tuy', N'4893yreiu', N'aaaaa0000t', N'0000000000', N'akashditm93@gmail.com', N'965502', CAST(N'2019-09-30 14:51:53.383' AS DateTime), CAST(N'2019-09-30 14:51:53.383' AS DateTime), 0, N'::1')
INSERT [dbo].[T_TempDrillingReg] ([autoId], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [OTP], [OTPDate], [TransDate], [Isdeleted], [IPAddress]) VALUES (6, N'1900006', 1, N'Test 786786', N'Test Applicant Name', N'89374983', N'4r89347', N'AAAAA8979A', N'1231231234', N'akashditm93@gmail.com', NULL, CAST(N'2019-09-30 15:06:02.130' AS DateTime), CAST(N'2019-09-30 15:06:02.130' AS DateTime), 0, N'::1')
INSERT [dbo].[T_TempDrillingReg] ([autoId], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [OTP], [OTPDate], [TransDate], [Isdeleted], [IPAddress]) VALUES (7, N'1900007', 1, N'TEST', N'TEST aPPLICANT', N'8934798', N'39847589', N'AAAAA8888A', N'0000000000', N'TEST@TEST.COM', N'746088', CAST(N'2019-10-05 15:21:15.610' AS DateTime), CAST(N'2019-10-05 15:21:15.610' AS DateTime), 0, N'::1')
INSERT [dbo].[T_TempDrillingReg] ([autoId], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [OTP], [OTPDate], [TransDate], [Isdeleted], [IPAddress]) VALUES (8, N'1900008', 1, N'test Company Name', N'Test Applicant', N'487347', N'897897', N'aaaaa1234A', N'0000000000', N'test@test.com', NULL, CAST(N'2019-10-05 15:29:02.080' AS DateTime), CAST(N'2019-10-05 15:29:02.080' AS DateTime), 0, N'::1')
INSERT [dbo].[T_TempDrillingReg] ([autoId], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [OTP], [OTPDate], [TransDate], [Isdeleted], [IPAddress]) VALUES (9, N'1900009', 1, N'test', N'test', N'5445yre', N'5765', N'adase5434e', N'9807256106', N'TEST@TEST.COM', NULL, CAST(N'2019-10-09 18:06:40.213' AS DateTime), CAST(N'2019-10-09 18:06:40.213' AS DateTime), 0, N'::1')
INSERT [dbo].[T_TempDrillingReg] ([autoId], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [OTP], [OTPDate], [TransDate], [Isdeleted], [IPAddress]) VALUES (10, N'1900010', 1, N'SS ENTERPRISES', N'ABHAY SINGH', N'RJP1452687312', N'0000000000', N'GTKPS2241L', N'7239048784', N'YADVENDRA.CSS@GMAIL.COM', N'996637', CAST(N'2019-10-14 18:30:14.437' AS DateTime), CAST(N'2019-10-14 18:30:14.437' AS DateTime), 0, N'192.168.0.250')
INSERT [dbo].[T_TempDrillingReg] ([autoId], [TempRegNo], [UserTypeId], [CompanyName], [ApplicantName], [FirmRegNo], [FirmGSTNo], [FirmPanNo], [MobileNo], [EmailId], [OTP], [OTPDate], [TransDate], [Isdeleted], [IPAddress]) VALUES (11, N'1900011', 1, N'abc', N'xyz', N'123456789', N'0000000000', N'GTKPS2241L', N'7239048784', N'YADVENDRA.CSS@GMAIL.COM', NULL, CAST(N'2019-10-15 15:22:04.660' AS DateTime), CAST(N'2019-10-15 15:22:04.660' AS DateTime), 0, N'192.168.0.250')
SET IDENTITY_INSERT [dbo].[T_TempDrillingReg] OFF
SET IDENTITY_INSERT [dbo].[tblAssignedBlock] ON 

INSERT [dbo].[tblAssignedBlock] ([Id], [UId], [BlockId], [DistrictRefid]) VALUES (8, 53, 412, 613)
INSERT [dbo].[tblAssignedBlock] ([Id], [UId], [BlockId], [DistrictRefid]) VALUES (9, 53, 415, 613)
SET IDENTITY_INSERT [dbo].[tblAssignedBlock] OFF
SET IDENTITY_INSERT [dbo].[tbleBlockUserMaster] ON 

INSERT [dbo].[tbleBlockUserMaster] ([ID], [UserName], [Password], [DisplayPassword], [Mobile], [Email], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [IsActive], [Rollid], [CreatedOn]) VALUES (8, N'Kanpur Nagar-5b660', N'6A71CAA5F2032B592D0BA88BB27E2D2D', N'GUYxyviX', N'8924023274', N'amit@gmail.com', 0, 0, 0, CAST(N'2019-10-16 15:42:53.737' AS DateTime), N'1', 0, 1, 2, CAST(N'2019-10-16 15:42:53.737' AS DateTime))
INSERT [dbo].[tbleBlockUserMaster] ([ID], [UserName], [Password], [DisplayPassword], [Mobile], [Email], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [IsActive], [Rollid], [CreatedOn]) VALUES (52, N'Lucknow-2ff04', N'5F0AA55FD34BA3F578CEC866DCB3C7ED', N'V06iL3iP', N'2323', N'ssdsd', 0, 0, 0, CAST(N'2019-10-18 11:05:07.890' AS DateTime), N'1', 0, 1, 2, CAST(N'2019-10-18 11:05:07.890' AS DateTime))
INSERT [dbo].[tbleBlockUserMaster] ([ID], [UserName], [Password], [DisplayPassword], [Mobile], [Email], [IsPassWordChange], [IsDeleted], [FirstLogin], [LastLoginTime], [LastLoginIP], [WrongAttempt], [IsActive], [Rollid], [CreatedOn]) VALUES (53, N'Lucknow-2fa4a', N'949973FCD885E37E2B6AC2EB545214F3', N'PltxEYd9', N'9125160344', N'amit@gmail.com', 0, 0, 0, CAST(N'2019-10-18 11:07:59.660' AS DateTime), N'1', 0, 1, 2, CAST(N'2019-10-18 11:07:59.660' AS DateTime))
SET IDENTITY_INSERT [dbo].[tbleBlockUserMaster] OFF
INSERT [dbo].[tblRollMaster] ([Id], [RollName]) VALUES (1, N'State')
INSERT [dbo].[tblRollMaster] ([Id], [RollName]) VALUES (2, N'District')
INSERT [dbo].[tblRollMaster] ([Id], [RollName]) VALUES (3, N'Block')
/****** Object:  StoredProcedure [dbo].[proc_AssignedBlock]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_AssignedBlock]
    (
	  @BlockId INT ,
	  @Uid NVARCHAR(20) ,
      @DistrictRefid INT
	 )
AS
    BEGIN
        INSERT  INTO tblAssignedBlock 
                ( 
				BlockId,
				Uid ,
				DistrictRefid
                )
        VALUES  (   @BlockId  ,@Uid ,@DistrictRefid);
				 DECLARE @id BIGINT 
                SET @id = ( SELECT  SCOPE_IDENTITY()
                          )
                  SELECT  
                       [ID] ,
					   [BlockId],
	                   [UId],
	                   [DistrictRefid] 
	
                FROM    tblAssignedBlock
                WHERE   ID = @id
       END;




GO
/****** Object:  StoredProcedure [dbo].[proc_CheckAdminLogin]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[proc_CheckAdminLogin]
    @UserName NVARCHAR(20) ,
    @Password NVARCHAR(MAX) ,
    @LastLoginIP NVARCHAR(50)
AS
    BEGIN
        IF EXISTS ( SELECT  1
                    FROM    AdminMaster
                    WHERE   UserName = @UserName
                            AND Password = @Password
                            AND IsDeleted = 0
                            AND IsActive = 1 )
            BEGIN
     
                UPDATE  AdminMaster
                SET     [LastLoginTime] = GETDATE() ,
                        [LastLoginIP] = @LastLoginIP
                WHERE   UserName = @UserName
                        AND Password = @Password
                        AND IsDeleted = 0;
                SELECT  a.ID ,
                        a.UserName ,
                        a.Password ,
                        a.DisplayPassword ,
                        a.IsPassWordChange ,
                        a.IsDeleted ,
                        a.FirstLogin ,
						a.LastLoginTime,
						a.LastLoginIP,
						a.WrongAttempt,
                        a.IsActive,
						a.Rollid,
						a.Mobile,
						a.Email,
						a.Refid 
                FROM    AdminMaster a
                WHERE   a.UserName = @UserName
                        AND a.Password = @Password;
                            
            END; 
    END;




GO
/****** Object:  StoredProcedure [dbo].[proc_CheckBlockMaster]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---Created By Sushil Kumar Sharma
---Created On 02/10/2019

create   PROCEDURE [dbo].[proc_CheckBlockMaster]
    (
      @BlockID INT 
	)
AS
    BEGIN
       SELECT * FROM [dbo].[M_Block] WHERE BlockID=@BlockID
    END;


GO
/****** Object:  StoredProcedure [dbo].[proc_CheckPassword]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--create by Sushil Kumar Sharma
--created on 03/10/2019

CREATE PROC [dbo].[proc_CheckPassword]
    @Password VARCHAR(500),
    @RegistrationID BIGINT
AS
    BEGIN
        SELECT  * FROM dbo.Sec_UserMaster 
        WHERE   RegistrationID = @RegistrationID AND DisplayPassword = @Password
    END
GO
/****** Object:  StoredProcedure [dbo].[proc_CheckUserLogin]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_CheckUserLogin]
    @UserName NVARCHAR(20) ,
    @Password NVARCHAR(MAX) ,
    @IPAddress NVARCHAR(50)
AS
    BEGIN
        IF EXISTS ( SELECT  1
                    FROM    [dbo].[Sec_UserMaster]
                    WHERE   UserName = @UserName
                            AND Password = @Password
                            AND IsDeleted = 0
                            AND IsActive = 1 )
            BEGIN
     
                UPDATE  [dbo].[Sec_UserMaster]
                SET     [LastLoginTime] = GETDATE() ,
                        [LastLoginIP] = @IPAddress
                WHERE   UserName = @UserName
                        AND Password = @Password
                        AND IsDeleted = 0;
                SELECT  r.RegistrationID ,
                        ISNULL(r.AppNo, '') AppNo ,
                        r.FormTypeID ,
                        r.UserCategoryID ,
                        r.UserTypeID ,
                        r.RDistrictID ,
                        r.RBlockID ,
                        r.MobileNo ,
                        r.EmailID ,
                        r.ApplicantName ,
                        r.IsMobileVerified ,
                        r.HaveNOC ,
                        r.GWDCertificate ,
                        r.ApplicationDate ,
                        r.IsPaymentDone ,
                        u.UserID ,
                        u.UserName ,
                        u.Password ,
                        u.DisplayPassword ,
                        u.IsPassWordChange ,
                        u.FirstLogin ,
                        u.IsActive ,
                        u.RegistrationID,
						r.StepNo
                FROM    [dbo].[M_Registration] r
                        INNER JOIN [dbo].[Sec_UserMaster] u ON r.RegistrationID = u.RegistrationID
                WHERE   u.UserName = @UserName
                        AND u.Password = @Password;
                            
            END; 
    END;


GO
/****** Object:  StoredProcedure [dbo].[proc_CreateBlockUser]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[proc_CreateBlockUser]
    (
	 
	  @UserName NVARCHAR(20) ,
      @MobileNo NVARCHAR(50) = NULL ,
	  @Email NVARCHAR(50)=NULL,
      @Password VARCHAR(500),
      @DisplayPassword VARCHAR(50), 
    
	  @Rollid INT
	 )
AS
    BEGIN
        INSERT  INTO tbleBlockUserMaster 
                ( 
			
				UserName ,
                  Password ,
                  DisplayPassword ,
				 
				  Mobile,
				  Email,
                  IsPassWordChange ,
                  IsDeleted ,
                  FirstLogin ,
				  LastLoginTime,
				  LastLoginIP,
                  CreatedOn ,
				  WrongAttempt,
                  IsActive ,
                  Rollid
                )
        VALUES  (  @UserName, @Password ,@DisplayPassword ,@MobileNo,@Email,'False' ,
                  'False' ,
                  'False' ,
                  GETDATE() ,
                  '1' ,
				   GETDATE() ,
				   0,
                  'True' ,
				   @Rollid			  						
                );
				 DECLARE @id BIGINT 
                SET @id = ( SELECT  SCOPE_IDENTITY()
                          )
                  SELECT  
                       [ID] ,
					  
	[UserName],
	[Password],
	[DisplayPassword],
	[Mobile] ,
	[Email],
	[IsPassWordChange] ,
	[IsDeleted] ,
	[FirstLogin] ,
	[LastLoginTime] ,
	[LastLoginIP] ,
	[WrongAttempt] ,
	[IsActive] ,
	[Rollid] ,
	[CreatedOn] 
                FROM    tbleBlockUserMaster
                WHERE   ID = @id
       END;





GO
/****** Object:  StoredProcedure [dbo].[proc_CreateUserLogin]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---Created By Sushil Kumar Sharma
---Created On 05/10/2019

CREATE PROCEDURE [dbo].[proc_CreateUserLogin]
    (
      @MobileNo VARCHAR(50) = NULL ,
      @Password VARCHAR(500) = NULL ,
      @DisplayPassword VARCHAR(50) = NULL ,
      @RegistrationID BIGINT = NULL      
	 )
AS
    BEGIN
        DECLARE @Uname VARCHAR(20);
        SET @Uname = ( SELECT TOP 1
                                ( CASE WHEN UserName = ( 'A' + @MobileNo )
                                       THEN ( 'B' + @MobileNo )
                                       WHEN UserName = ( 'B' + @MobileNo )
                                       THEN ( 'C' + @MobileNo )
                                       WHEN UserName = ( 'C' + @MobileNo )
                                       THEN ( 'D' + @MobileNo )
                                       WHEN UserName = ( 'D' + @MobileNo )
                                       THEN ( 'E' + @MobileNo )
                                       WHEN UserName = ( 'E' + @MobileNo )
                                       THEN ( 'F' + @MobileNo )
                                       WHEN UserName = ( 'F' + @MobileNo )
                                       THEN ( 'G' + @MobileNo )
                                       WHEN UserName = ( 'G' + @MobileNo )
                                       THEN ( 'H' + @MobileNo )
                                       WHEN UserName = ( 'H' + @MobileNo )
                                       THEN ( 'I' + @MobileNo )
                                       WHEN UserName = ( 'I' + @MobileNo )
                                       THEN ( 'J' + @MobileNo )
                                       WHEN UserName = ( 'J' + @MobileNo )
                                       THEN ( 'K' + @MobileNo )
                                       WHEN UserName = ( 'K' + @MobileNo )
                                       THEN ( 'L' + @MobileNo )
                                       WHEN UserName = ( 'L' + @MobileNo )
                                       THEN ( 'M' + @MobileNo )
                                       WHEN UserName = ( 'M' + @MobileNo )
                                       THEN ( 'N' + @MobileNo )
                                       WHEN UserName = ( 'N' + @MobileNo )
                                       THEN ( 'O' + @MobileNo )
                                       WHEN UserName = ( 'O' + @MobileNo )
                                       THEN ( 'P' + @MobileNo )
                                       WHEN UserName = ( 'P' + @MobileNo )
                                       THEN ( 'Q' + @MobileNo )
                                       WHEN UserName = ( 'Q' + @MobileNo )
                                       THEN ( 'R' + @MobileNo )
                                       WHEN UserName = ( 'R' + @MobileNo )
                                       THEN ( 'S' + @MobileNo )
                                       WHEN UserName = ( 'S' + @MobileNo )
                                       THEN ( 'T' + @MobileNo )
                                       WHEN UserName = ( 'T' + @MobileNo )
                                       THEN ( 'U' + @MobileNo )
                                       WHEN UserName = ( 'U' + @MobileNo )
                                       THEN ( 'V' + @MobileNo )
                                       WHEN UserName = ( 'V' + @MobileNo )
                                       THEN ( 'W' + @MobileNo )
                                       WHEN UserName = ( 'W' + @MobileNo )
                                       THEN ( 'X' + @MobileNo )
                                       WHEN UserName = ( 'X' + @MobileNo )
                                       THEN ( 'Y' + @MobileNo )
                                       WHEN UserName = ( 'Y' + @MobileNo )
                                       THEN ( 'Z' + @MobileNo )
                                       ELSE ( 'A' + @MobileNo )
                                  END ) AS UserName
                       FROM     dbo.Sec_UserMaster
                       WHERE    SUBSTRING(UserName, 2, 10) = @MobileNo
                       ORDER BY UserID DESC
                     );	
        IF ( @Uname IS NULL )
            BEGIN 
                SET @Uname = 'A' + @MobileNo;
            END;	
        INSERT  INTO dbo.Sec_UserMaster
                ( UserName ,
                  Password ,
                  DisplayPassword ,
                  IsPassWordChange ,
                  IsDeleted ,
                  FirstLogin ,
                  CreatedOn ,
                  IsActive ,
                  RegistrationID   
						
                )
        VALUES  ( @Uname ,
                  @Password ,
                  @DisplayPassword ,
                  'False' ,
                  'False' ,
                  'False' ,
                  GETDATE() ,
                  'True' ,
                  @RegistrationID				  						
                );

        UPDATE  dbo.M_Registration
        SET     StepNo = 1
        WHERE   RegistrationID = @RegistrationID;
        SELECT  *
        FROM    dbo.Sec_UserMaster
        WHERE   RegistrationID = @RegistrationID;
    END;


GO
/****** Object:  StoredProcedure [dbo].[proc_DeleteBlockUser]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_DeleteBlockUser]
    @ID int
AS
    BEGIN
        UPDATE tbleBlockUserMaster SET IsDeleted='True'
        WHERE ID =@ID
    END

GO
/****** Object:  StoredProcedure [dbo].[Proc_DrillingRegistration]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[Proc_DrillingRegistration]
    @UserTypeId INT ,
    @CompanyName VARCHAR(150) ,
    @ApplicantName VARCHAR(50) ,
    @FirmRegNo VARCHAR(20) ,
    @FirmGSTNo VARCHAR(20) ,
    @FirmPanNo VARCHAR(10) ,
    @MobileNo VARCHAR(10) ,
    @EmailId VARCHAR(50) ,
    @IPAddress VARCHAR(50)
 AS
    BEGIN
        DECLARE @OTP VARCHAR(6) ,
            @tempRegNo VARCHAR(50);
        SET @OTP = ( SELECT RIGHT(ABS(CHECKSUM(NEWID())), 6)
                   );

        SET @tempRegNo = ( SELECT   dbo.fnGenerateTempReg()
                         );
        INSERT  INTO dbo.T_TempDrillingReg
                ( TempRegNo ,
                  UserTypeId ,
                  CompanyName ,
                  ApplicantName ,
                  FirmRegNo ,
                  FirmGSTNo ,
                  FirmPanNo ,
                  MobileNo ,
                  EmailId ,
                  OTP ,
                  OTPDate ,
                  TransDate ,
                  Isdeleted ,
                  IPAddress
				 )
        VALUES  ( @tempRegNo , -- TempRegNo - varchar(50)
                  @UserTypeId , -- UserTypeId - int
                  @CompanyName , -- CompanyName - varchar(200)
                  @ApplicantName , -- ApplicantName - varchar(50)
                  @FirmRegNo , -- FirmRegNo - varchar(50)
                  @FirmGSTNo , -- FirmGSTNo - varchar(30)
                  @FirmPanNo , -- FirmPanNo - varchar(10)
                  @MobileNo , -- MobileNo - varchar(10)
                  @EmailId , -- EmailId - varchar(50)
                  @OTP , -- OTP - varchar(10)
                  GETDATE() , -- OTPDate - datetime
                  GETDATE() , -- TransDate - datetime
                  0 , -- Isdeleted - bit
                  @IPAddress  -- IPAddress - varchar(50)
				 );
        IF ( @@ROWCOUNT > 0 )
            BEGIN	
                SELECT  TempRegNo ,
                        OTP,
						CAST(1 AS bit)IsSuccess
                FROM    T_TempDrillingReg
                WHERE   TempRegNo = @tempRegNo
                        AND OTP IS NOT NULL;
            END;
    END;

GO
/****** Object:  StoredProcedure [dbo].[proc_DrillingUserAuth]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[proc_DrillingUserAuth] -- proc_DrillingUserAuth'DRL1900001','24617219173170201672816178213244251926248',''
    @Username NVARCHAR(20) ,
    @Password NVARCHAR(50) ,
    @IPAddress NVARCHAR(50)
AS
    BEGIN
        DECLARE @IsExists BIT ,
            @IsValid BIT ,
            @IsSuccess BIT ,
            @IsNotMatch BIT ,
            @IsInvalid BIT ,
            @IsInvalidCaptcha BIT;
        IF EXISTS ( SELECT  1
                    FROM    [dbo].[Sec_UserMaster]
                    WHERE   UserName = @Username
                            AND IsDeleted = 0
                            AND IsActive = 1 )
            BEGIN
                PRINT 'A';
                PRINT @Username;
                PRINT @Password;

                IF EXISTS ( SELECT  1
                            FROM    [dbo].[Sec_UserMaster]
                            WHERE   UserName = @Username
                                    AND [Password] = @Password
                                    AND IsDeleted = 0
                                    AND IsActive = 1 )
                    BEGIN
                        PRINT 'A1';
                        UPDATE  [dbo].[Sec_UserMaster]
                        SET     [LastLoginTime] = GETDATE() ,
                                [LastLoginIP] = @IPAddress
                        WHERE   UserName = @Username
                                AND Password = @Password
                                AND IsDeleted = 0;
                        SELECT  u.UserID ,
                                r.AppNo ,
                                r.UserTypeId ,
                                r.CompanyName ,
                                r.ApplicantName ,
                                r.MobileNo ,
                                ISNULL(r.StepNo,0) AS StepNo ,
                                CAST(1 AS BIT) IsExists ,
                                CAST(1 AS BIT) IsSuccess
                        FROM    [dbo].T_DrillingRegistration r
                                INNER JOIN [dbo].[Sec_UserMaster] u ON r.AppNo = u.AppNo
                        WHERE   u.UserName = @Username
                                AND u.Password = @Password;
                        
                    END;
                ELSE
                    BEGIN
                        SELECT  CAST(1 AS BIT) AS IsNotMatch; 
                    END;

            END;
        ELSE
            BEGIN
                SELECT  CAST(1 AS BIT) AS IsInvalid;  
            END;
    END;


GO
/****** Object:  StoredProcedure [dbo].[Proc_FinalSubmitDrillingDetail]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_FinalSubmitDrillingDetail]
    @AppNo VARCHAR(50) ,
    @IPAddress VARCHAR(50)
AS
    BEGIN
	
        IF EXISTS ( SELECT  *
                    FROM    dbo.T_DrillingRegistration
                    WHERE   Isdeleted = 0
                            AND AppNo = @AppNo
                            AND StepNo = 2 )
            BEGIN
		
                UPDATE  T_DrillingRegistration
                SET     StepNo = 3
                WHERE   Isdeleted = 0
                        AND AppNo = @AppNo
                      --  AND StepNo = 2;
                SELECT  AppNo ,
                        StepNo
                FROM    dbo.T_DrillingRegistration
                WHERE   Isdeleted = 0
                        AND AppNo = @AppNo
                        AND StepNo = 3;
            END;

    END;
GO
/****** Object:  StoredProcedure [dbo].[proc_getAllUserByMobile]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- proc_getAllUserByMobile '8795582569'
CREATE  PROCEDURE [dbo].[proc_getAllUserByMobile] @MobileNo VARCHAR(50)
AS
    BEGIN 
        IF EXISTS ( SELECT  1
                    FROM    dbo.M_Registration R
                            INNER JOIN dbo.Sec_UserMaster U ON R.RegistrationID = U.RegistrationID
                    WHERE   MobileNo = @MobileNo
                            AND R.IsDeleted = 0
                            AND R.IsMobileVerified = 1
                            AND R.IsActive = 1 )
            BEGIN 
                SELECT  U.UserName ,
                        R.OwnerName ,
                        R.ApplicantName ,
                        R.MobileNo
                FROM    dbo.M_Registration R
                        INNER JOIN dbo.Sec_UserMaster U ON R.RegistrationID = U.RegistrationID
                WHERE   MobileNo = @MobileNo
                        AND R.IsDeleted = 0
                        AND R.IsMobileVerified = 1
                        AND R.IsActive = 1;
						
            END; 
    END; 
    

GO
/****** Object:  StoredProcedure [dbo].[Proc_GetApplicantDetail]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[Proc_GetApplicantDetail] -- Proc_GetApplicantDetail 'DRL1900002',1
    @AppNo VARCHAR(50) ,
    @StepNo INT
AS
    BEGIN
        IF ( @StepNo = 0 )
            BEGIN
                SELECT  AppNo ,
                        FirmPanNo ,
                        FirmGSTNo ,
                        OwnerName ,
                        SpouseTitle ,
                        SpouseWardName ,
                        CONVERT(VARCHAR, DOB, 105) DOB ,
                        Gender ,
                        Nationality ,
                        ISNULL(PanCardPath, '') AS PanCardPath ,
                        ISNULL(GSTCertificatePath, '') AS GSTCertificatePath ,
                        Address ,
                        ISNULL(StateId, 0) StateId ,
                        ISNULL(DistrictId, 0) DistrictId ,
                        Pincode ,
                        ISNULL(StepNo, 0) StepNo
                FROM    dbo.T_DrillingRegistration
                WHERE   AppNo = @AppNo;
            END; 
        ELSE
            IF ( @StepNo = 1 )
                BEGIN
                    SELECT DISTINCT
                            a.AppNo ,
                            ISNULL(StateId, 0) StateId ,
                           -- CAST(ISNULL(ddm.DistrictId, 0) AS VARCHAR)
                            STUFF(( SELECT  ',' + CAST(DistrictId AS VARCHAR)
                                    FROM    ( SELECT    AppNo ,
                                                        DistrictId
                                              FROM      dbo.T_DrillingDistrictMachine
                                              WHERE     Isdeleted = 0
                                                           -- AND AppNo = @AppNo
                                            ) t2
                                    WHERE   t2.AppNo = ddm.AppNo
                                  FOR
                                    XML PATH('')
                                  ), 1, 1, '') DistrictIds ,
                            ddm.DrillingMachineDetail ,
                            ddm.DrillingPurposeId AS DrillingPurpose ,
                            ISNULL(StepNo, 0) StepNo
                    FROM    dbo.T_DrillingRegistration a
                            left JOIN ( SELECT *
                                         FROM   dbo.T_DrillingDistrictMachine
                                         WHERE  Isdeleted = 0
                                       ) ddm ON ddm.AppNo = a.AppNo
                    WHERE   a.AppNo = @AppNo;
                END; 
            ELSE
                IF ( @StepNo = 2 )
                    BEGIN
                        SELECT DISTINCT
                                a.AppNo ,
                                FirmPanNo ,
                                FirmGSTNo ,
                                OwnerName ,
                                SpouseTitle ,
                                SpouseWardName ,
                                CONVERT(VARCHAR, DOB, 105) DOB ,
                                CASE Gender
                                  WHEN 'M' THEN 'Male'
                                  WHEN 'F' THEN 'Female'
                                  WHEN 'T' THEN 'Transgender'
                                END Gender ,
                                CASE Nationality
                                  WHEN 'I' THEN 'Indian'
                                  ELSE 'Other'
                                END Nationality ,
                                ISNULL(PanCardPath, '') AS PanCardPath ,
                                ISNULL(GSTCertificatePath, '') AS GSTCertificatePath ,
                                Address ,
                                st.StateName ,
                                dt.DistrictName ,
                                Pincode ,
                                STUFF(( SELECT  ', '
                                                + CAST(d.DistrictName AS VARCHAR)
                                        FROM    ( SELECT    AppNo ,
                                                            DistrictId
                                                  FROM      dbo.T_DrillingDistrictMachine
                                                  WHERE     Isdeleted = 0
                                                           -- AND AppNo = @AppNo
                                                ) t2
                                                INNER JOIN dbo.M_District d ON d.DistrictID = t2.DistrictId
                                        WHERE   t2.AppNo = ddm.AppNo
                                      FOR
                                        XML PATH('')
                                      ), 1, 1, '') AS DrillingDistrict ,
                                ddm.DrillingMachineDetail ,
                                CASE ddm.DrillingPurposeId
                                  WHEN 'B' THEN 'BOTH'
                                  WHEN 'G' THEN 'Government'
                                  WHEN 'P' THEN 'Private'
                                END DrillingPurpose ,
                                ISNULL(StepNo, 0) StepNo
                        FROM    dbo.T_DrillingRegistration a
                                LEFT JOIN dbo.M_State st ON st.StateID = a.StateId
                                LEFT JOIN dbo.M_District dt ON dt.DistrictID = a.DistrictId
                                INNER JOIN ( SELECT *
                                             FROM   dbo.T_DrillingDistrictMachine
                                             WHERE  Isdeleted = 0
                                           ) ddm ON ddm.AppNo = a.AppNo
                        WHERE   a.AppNo = @AppNo;
                    END;
        IF ( @StepNo = 3 )
            BEGIN
                SELECT  AppNo ,
                        FirmPanNo ,
                        FirmGSTNo ,
                        OwnerName ,
                        SpouseTitle ,
                        SpouseWardName ,
                        CONVERT(VARCHAR, DOB, 105) DOB ,
                        Gender ,
                        Nationality ,
                        ISNULL(PanCardPath, '') AS PanCardPath ,
                        ISNULL(GSTCertificatePath, '') AS GSTCertificatePath ,
                        Address ,
                        ISNULL(StateId, 0) StateId ,
                        ISNULL(DistrictId, 0) DistrictId ,
                        Pincode ,
                        ISNULL(StepNo, 0) StepNo
                FROM    dbo.T_DrillingRegistration
                WHERE   AppNo = @AppNo;
            END;
			 
    END;
	

GO
/****** Object:  StoredProcedure [dbo].[proc_GetApplicationForRegistration]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[proc_GetApplicationForRegistration]
    (
      @DistrictID BIGINT = 0      
	)
AS
    BEGIN
            
     SELECT  RegistrationID ,
                AppNo ,
                ct4.Name AS ApplicationType,
				ct3.Name AS UserType,
                ApplicantName ,
                HaveNOC ,
                ct2.Name AS WellType ,
			     CASE bl.Status
                                  WHEN 'N' THEN 'Notified'
                                  WHEN 'UN' THEN 'Non-Notified'
                                END Status 
        FROM    dbo.M_Registration a
              LEFT JOIN [dbo].[CommonTable] ct2 ON a.TypeOfTheWellID = ct2.CommonID
              LEFT JOIN [dbo].[CommonTable] ct3 ON a.UserTypeID = ct3.CommonID
              LEFT JOIN [dbo].[CommonTable] ct4 ON a.PurposeOfWellID = ct4.CommonID
			  LEFT JOIN dbo.M_Block bl ON bl.BlockID = a.RBlockID
        WHERE   a.RDistrictID = @DistrictID;   

    END;




GO
/****** Object:  StoredProcedure [dbo].[proc_GetApplicationForRegistrationByID]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[proc_GetApplicationForRegistrationByID]
    (
      @RegistrationID BIGINT = 0      
	)
AS
    BEGIN
            
        SELECT  RegistrationID ,
                AppNo ,
                FormTypeID ,
                UserCategoryID ,
                UserTypeID ,
                RDistrictID ,
                d3.DistrictName AS RegDistrictName ,
                d.DistrictName AS RDistrictName ,
                RBlockID ,
                bl.BlockName AS RegBlockName ,
                MobileNo ,
                EmailID ,
                ApplicantName ,
                OTP ,
                IsMobileVerified ,
                HaveNOC ,
                GWDCertificate ,
              -- ISNULL(CONVERT(VARCHAR(50), ApplicationDate, 103),'01/01/1999')
                ApplicationDate ,
                OwnerName ,
              -- ISNULL(CONVERT(VARCHAR(50), DateOfBirth, 103),'01/01/1999')
                DateOfBirth ,
                CareOF ,
                Gender ,
                ct6.Name AS GenderName ,
                Nationality ,
                ct7.Name AS NationalityName ,
                Address ,
                a.StateID ,
                s.StateName AS StateName ,
                a.DistrictID ,
                d1.DistrictName AS ADistrictName ,
                Pincode ,
                P_DistrictID ,
                d2.DistrictName AS PDistrictName ,
                P_BlockID ,
                b.BlockName AS BlockName ,
                PlotKhasraNo ,
                IDProofID ,
                ct1.Name AS IDName ,
                IDNumber ,
                IDPath ,
                MunicipalityCorporation ,
                WardHoldingNo ,
                --ISNULL(CONVERT(VARCHAR(50), DateOfConstruction, 103),'01/01/1999') 
                DateOfConstruction ,
                TypeOfTheWellID ,
                ct2.Name AS WTName ,
                DepthOfTheWell ,
                IsAdverseReport ,
                WaterQuality ,
                TypeOfPumpID ,
                ct3.Name AS PumpTypeName ,
                LengthColumnPipe ,
                PumpCapacity ,
                HorsePower ,
                OperationalDeviceID ,
                ct4.Name AS ODName ,
                DateOfEnergization ,
                PurposeOfWellID ,
                ct5.Name AS PWName ,
                AnnualRunningHours ,
                DailyRunningHours ,
                IsPipedWaterSupply ,
                ModeOfTreatment ,
                IsObtainedNOC_UP ,
                IsRainWaterHarvesting ,
                Remarks ,
                ISNULL(IAgree, 'False') IAgree ,
                IsPaymentDone ,
                IPAddress ,
                CreatedOn ,
                LastModifiedOn ,
                a.IsDeleted ,
                IsActive ,
                Relation ,
                ct8.Name AS Relationof ,
                DiameterOfDugWell ,
                StructureofdugWell ,
                ApproxLengthOfPipe ,
                ApproxDiameterOfPipe ,
                ApproxLengthOfStrainer ,
                ApproxDiameterOfStrainer ,
                MaterialOfPipe ,
                ct9.Name PMaterialName ,
                MaterialOfStrainer ,
                ct10.Name SMaterialName ,
                IfAny ,
                RegCertificateIssueByGWD ,
                RegCertificateNumber ,
               -- ISNULL(CONVERT(VARCHAR(50), DateOfRegCertificateIssuance, 103),'01/01/1999') 
                DateOfRegCertificateIssuance ,
               -- ISNULL(CONVERT(VARCHAR(50), DateOfRegCertificateExpiry, 103),'01/01/1999')
                DateOfRegCertificateExpiry ,
                RegCertificatePath ,
                CentralGroundWaterAuthority ,
                DateOfNOCIssuanceByCGWD ,
                DateOfNOCExpiryByCGWD ,
                NOCByCGWDCertificatePath ,
                NOCCertificateNumberByCGWD ,
                a.StepNo
        FROM    dbo.M_Registration a
                LEFT  JOIN [dbo].[M_District] d ON a.RDistrictID = d.DistrictID
                LEFT JOIN dbo.M_State s ON a.StateID = s.StateID
                LEFT JOIN dbo.M_Block b ON a.P_BlockID = b.BlockID
                LEFT JOIN dbo.CommonTable ct1 ON a.IDProofID = ct1.CommonID
                LEFT JOIN [dbo].[CommonTable] ct2 ON a.TypeOfTheWellID = ct2.CommonID
                LEFT JOIN [dbo].[CommonTable] ct3 ON a.TypeOfPumpID = ct3.CommonID
                LEFT JOIN [dbo].[CommonTable] ct4 ON a.OperationalDeviceID = ct4.CommonID
                LEFT JOIN [dbo].[CommonTable] ct5 ON a.PurposeOfWellID = ct5.CommonID
                LEFT JOIN [dbo].[CommonTable] ct6 ON a.Gender = ct6.CommonID
                LEFT JOIN [dbo].[CommonTable] ct7 ON a.Nationality = ct7.CommonID
                LEFT JOIN [dbo].[CommonTable] ct8 ON a.Relation = ct8.CommonID
                LEFT JOIN [dbo].[CommonTable] ct9 ON a.MaterialOfPipe = ct9.CommonID
                LEFT JOIN [dbo].[CommonTable] ct10 ON a.MaterialOfStrainer = ct10.CommonID
                LEFT JOIN [dbo].[M_District] d1 ON a.DistrictID = d1.DistrictID
                LEFT JOIN [dbo].[M_District] d2 ON a.P_DistrictID = d2.DistrictID
                LEFT JOIN [dbo].[M_District] d3 ON a.RDistrictID = d3.DistrictID
                LEFT JOIN dbo.M_Block bl ON bl.BlockID = a.RBlockID
        WHERE   RegistrationID = @RegistrationID;       

    END;



GO
/****** Object:  StoredProcedure [dbo].[proc_GetBlockUser]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[proc_GetBlockUser]
@DistrictRefid INT
AS
BEGIN
	WITH AllData(ID,UserName,Mobile,Email,BlockName) AS(SELECT  t.ID , t.UserName,t.Mobile,t.Email,b.BlockName 
	FROM tbleBlockUserMaster t 
	JOIN tblAssignedBlock a 
	ON t.ID=a.Uid

	JOIN M_Block b 
	ON b.BlockID=a.BlockID
	WHERE  a.DistrictRefid = @DistrictRefid AND t.IsDeleted='False')

	SELECT DISTINCT ID, UserName,Mobile,Email,
    BlockName =  STUFF(
                 (SELECT  DISTINCT ', '  + BlockName  FROM AllData X WHERE x.ID = A.ID  FOR XML PATH ('')), 1, 1, ''
               ) 
    FROM AllData  A
END





GO
/****** Object:  StoredProcedure [dbo].[Proc_GetDistrictByState]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[Proc_GetDistrictByState] @StateID INT=0
AS
BEGIN


	SELECT *  FROM dbo.M_District 
	WHERE  StateID = @StateID
	ORDER BY DistrictName 
END

GO
/****** Object:  StoredProcedure [dbo].[Proc_GetState]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_GetState]
AS
    BEGIN
        SELECT  stateID StateID ,
                stateName stateName
        FROM    dbo.M_State
        WHERE   ISNULL(isDeleted, 0) = 0 AND stateID<>37
	
    END;


GO
/****** Object:  StoredProcedure [dbo].[proc_GetUserMobileNoUpdateOtp]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[proc_GetUserMobileNoUpdateOtp]
    @UserName VARCHAR(50) = NULL ,
    @Otp VARCHAR(10) = NULL ,
    @ProcId INT = 0
AS
    BEGIN
        IF ( @ProcId = 1 )
            BEGIN 

                DECLARE @regId BIGINT;  
                IF EXISTS ( SELECT  1
                            FROM    dbo.Sec_UserMaster U
                                    INNER JOIN dbo.M_Registration R ON U.RegistrationID = R.RegistrationID
                            WHERE   UserName = @UserName
                                    AND R.IsMobileVerified = 1
                                    AND R.IsActive = 1
                                    AND R.IsDeleted = 0 )
                    BEGIN
                        SET @regId = ( SELECT   R.RegistrationID
                                       FROM     dbo.Sec_UserMaster U
                                                INNER JOIN dbo.M_Registration R ON U.RegistrationID = R.RegistrationID
                                       WHERE    UserName = @UserName
                                                AND R.IsMobileVerified = 1
                                                AND R.IsActive = 1
                                                AND R.IsDeleted = 0
                                     );
					    
                        UPDATE  M_Registration
                        SET     OTP = @Otp
                        WHERE   RegistrationID = @regId; 

                        SELECT  ISNULL(R.AppNo, '') AppNo ,
                                R.MobileNo ,
                                R.RegistrationID ,
                                UserName
                        FROM    dbo.Sec_UserMaster U
                                INNER JOIN dbo.M_Registration R ON U.RegistrationID = R.RegistrationID
                        WHERE   UserName = @UserName
                                AND R.IsMobileVerified = 1
                                AND R.IsActive = 1
                                AND R.IsDeleted = 0;
                    END; 
            END; 
    END; 
GO
/****** Object:  StoredProcedure [dbo].[Proc_InsertUpdateApplicantDetail]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_InsertUpdateApplicantDetail]
    @AppNo VARCHAR(50) ,
    @OwnerName VARCHAR(50) ,
    @SpouseTitle VARCHAR(5) ,
    @SpouseWardName VARCHAR(50) ,
    @DOB DATETIME ,
    @Gender CHAR(1) ,
    @Nationality VARCHAR(1) ,
    @PanCardPath VARCHAR(300) ,
    @GSTCertificatePath VARCHAR(300) ,
    @ADDRESS VARCHAR(150) ,
    @StateId INT ,
    @DistrictId INT ,
    @Pincode CHAR(6) ,
    @IpAddress VARCHAR(50)
AS
    BEGIN
        IF   EXISTS ( SELECT  *
                        FROM    dbo.T_DrillingRegistration
                        WHERE   ( ISNULL(StepNo, 0) >= 0 )
                                AND AppNo = @AppNo )
            BEGIN
                UPDATE  T_DrillingRegistration
                SET     OwnerName = @OwnerName ,
                        SpouseTitle = @SpouseTitle ,
                        SpouseWardName = @SpouseWardName ,
                        DOB = @DOB ,
                        Gender = @Gender ,
                        Nationality = @Nationality ,
                        PanCardPath = @PanCardPath ,
                        GSTCertificatePath = @GSTCertificatePath ,
                        Address = @ADDRESS ,
                        StateId = @StateId ,
                        DistrictId = @DistrictId ,
                        Pincode = @Pincode ,
                        RegIPAddress = @IpAddress ,
                        RegDate = GETDATE() ,
                        StepNo = CASE ISNULL(StepNo,0)
                                   WHEN 0 THEN 1
                                   ELSE StepNo
                                 END
                WHERE   ( ISNULL(StepNo, 0) >= 0 )
                        AND AppNo = @AppNo; 

                SELECT  AppNo ,
                        StepNo
                FROM    dbo.T_DrillingRegistration
                WHERE   ( ISNULL(StepNo, 0) >= 0 )
                        AND AppNo = @AppNo;
            END;
       
    END;
GO
/****** Object:  StoredProcedure [dbo].[proc_InsertUpdateApplication]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---Created By Sushil Kumar Sharma
---Created On 27/09/2019

CREATE PROCEDURE [dbo].[proc_InsertUpdateApplication]
    (
      @RegistrationID BIGINT = 0 ,
      @OwnerName NVARCHAR(200) = NULL ,
      @DateOfBirth DATETIME = NULL ,
      @CareOF NVARCHAR(200) = NULL ,
      @Gender SMALLINT = NULL ,
      @Nationality NVARCHAR(50) = NULL ,
      @Address NVARCHAR(200) = NULL ,
      @StateID SMALLINT = NULL ,
      @DistrictID SMALLINT = NULL ,
      @Pincode NVARCHAR(15) = NULL ,
      @P_DistrictID SMALLINT = NULL ,
      @P_BlockID SMALLINT = NULL ,
      @PlotKhasraNo NVARCHAR(50) = NULL ,
      @IDProofID SMALLINT = NULL ,
      @IDNumber NVARCHAR(50) = NULL ,
      @IDPath NVARCHAR(500) = NULL ,
      @MunicipalityCorporation NVARCHAR(50) = NULL ,
      @WardHoldingNo NVARCHAR(50) = NULL ,
      @DateOfConstruction DATETIME = NULL ,
      @TypeOfTheWellID SMALLINT = NULL ,
      @DepthOfTheWell DECIMAL(10, 2) = NULL ,
      @IsAdverseReport BIT = NULL ,
      @WaterQuality NVARCHAR(50) = NULL ,
      @TypeOfPumpID SMALLINT = NULL ,
      @LengthColumnPipe DECIMAL(10, 2) = NULL ,
      @PumpCapacity DECIMAL(10, 2) = NULL ,
      @HorsePower DECIMAL(6, 2) = NULL ,
      @OperationalDeviceID SMALLINT = NULL ,
      @DateOfEnergization DATETIME = NULL ,
      @PurposeOfWellID SMALLINT = NULL ,
      @AnnualRunningHours DECIMAL(10, 2) = NULL ,
      @DailyRunningHours DECIMAL(10, 2) = NULL ,
      @IsPipedWaterSupply BIT = NULL ,
      @ModeOfTreatment NVARCHAR(200) = NULL ,
      @IsObtainedNOC_UP BIT = NULL ,
      @IsRainWaterHarvesting BIT = NULL ,
      @Remarks NVARCHAR(500) = NULL ,
      @ProcId INT = 0 ,
      @Relation INT = NULL ,
      @DiameterOfDugWell DECIMAL(10, 2) = NULL ,
      @StructureofdugWell INT = 0 ,
      @ApproxLengthOfPipe DECIMAL(10, 2) = NULL ,
      @ApproxDiameterOfPipe DECIMAL(10, 2) = NULL ,
      @IfAny VARCHAR(50) = NULL ,
      @ApproxLengthOfStrainer DECIMAL(10, 2) = NULL ,
      @ApproxDiameterOfStrainer DECIMAL(10, 2) = NULL ,
      @MaterialOfPipe DECIMAL(10, 2) = NULL ,
      @MaterialOfStrainer DECIMAL(10, 2) = NULL ,
      @RegCertificateIssueByGWD BIT = NULL ,
      @RegCertificateNumber VARCHAR(50) = NULL ,
      @DateOfRegCertificateIssuance DATETIME = NULL ,
      @DateOfRegCertificateExpiry DATETIME = NULL ,
      @RegCertificatePath VARCHAR(MAX) = NULL ,
      @IAgree BIT = NULL ,
      @StepNo INT = NULL ,
      @CentralGroundWaterAuthority BIT = NULL ,
      @NOCCertificateNumberByCGWD VARCHAR(50) = NULL ,
      @DateOfNOCIssuanceByCGWD DATETIME = NULL ,
      @DateOfNOCExpiryByCGWD DATETIME = NULL ,
      @NOCByCGWDCertificatePath VARCHAR(MAX) = NULL ,
      @FormTypeID INT = NULL ,
      @UserCategoryID INT = NULL	
	)
AS
    BEGIN
        IF ( @ProcId = 1 )  -- Create
            DECLARE @Appno VARCHAR(20); 
        IF ( @IAgree = 'True' )
            BEGIN
                SET @Appno = ( SELECT   [dbo].[GenerateAppNo](@P_DistrictID,
                                                              @FormTypeID,
                                                              @PurposeOfWellID)
                             );
                DECLARE @AppNo_1 VARCHAR(20)
                SET @AppNo_1 = ( SELECT AppNo
                                 FROM   dbo.M_Registration
                                 WHERE  RegistrationID = @RegistrationID
                               )
                IF ( @AppNo_1 IS NULL )
                    BEGIN 
                        UPDATE  dbo.M_Registration
                        SET     AppNo = @Appno
                        WHERE   RegistrationID = @RegistrationID
                    END 
            END; 
        BEGIN
            UPDATE  dbo.M_Registration
            SET     OwnerName = @OwnerName ,
                    DateOfBirth = @DateOfBirth ,
                    CareOF = @CareOF ,
                    Gender = @Gender ,
                    Nationality = @Nationality ,
                    Address = @Address ,
                    StateID = @StateID ,
                    DistrictID = @DistrictID ,
                    Pincode = @Pincode ,
                    P_DistrictID = @P_DistrictID ,
                    P_BlockID = @P_BlockID ,
                    PlotKhasraNo = @PlotKhasraNo ,
                    IDProofID = @IDProofID ,
                    IDNumber = @IDNumber ,
                    IDPath = @IDPath ,
                    MunicipalityCorporation = @MunicipalityCorporation ,
                    WardHoldingNo = @WardHoldingNo ,
                    DateOfConstruction = @DateOfConstruction ,
                    TypeOfTheWellID = @TypeOfTheWellID ,
                    DepthOfTheWell = @DepthOfTheWell ,
                    IsAdverseReport = @IsAdverseReport ,
                    WaterQuality = @WaterQuality ,
                    TypeOfPumpID = @TypeOfPumpID ,
                    LengthColumnPipe = @LengthColumnPipe ,
                    PumpCapacity = @PumpCapacity ,
                    HorsePower = @HorsePower ,
                    OperationalDeviceID = @OperationalDeviceID ,
                    DateOfEnergization = @DateOfEnergization ,
                    PurposeOfWellID = @PurposeOfWellID ,
                    AnnualRunningHours = @AnnualRunningHours ,
                    DailyRunningHours = @DailyRunningHours ,
                    IsPipedWaterSupply = @IsPipedWaterSupply ,
                    ModeOfTreatment = @ModeOfTreatment ,
                    IsObtainedNOC_UP = @IsObtainedNOC_UP ,
                    IsRainWaterHarvesting = @IsRainWaterHarvesting ,
                    LastModifiedOn = GETDATE() ,
                    Remarks = @Remarks ,
                    Relation = @Relation ,
                    DiameterOfDugWell = @DiameterOfDugWell ,
                    StructureofdugWell = @StructureofdugWell ,
                    ApproxLengthOfPipe = @ApproxLengthOfPipe ,
                    ApproxDiameterOfPipe = @ApproxDiameterOfPipe ,
                    IfAny = @IfAny ,
                    ApproxLengthOfStrainer = @ApproxLengthOfStrainer ,
                    ApproxDiameterOfStrainer = @ApproxDiameterOfStrainer ,
                    MaterialOfPipe = @MaterialOfPipe ,
                    MaterialOfStrainer = @MaterialOfStrainer ,
                    RegCertificateIssueByGWD = @RegCertificateIssueByGWD ,
                    RegCertificateNumber = @RegCertificateNumber ,
                    DateOfRegCertificateIssuance = CONVERT(DATETIME, @DateOfRegCertificateIssuance, 103) ,
                    DateOfRegCertificateExpiry = CONVERT(DATETIME, @DateOfRegCertificateExpiry, 103) ,
                    RegCertificatePath = @RegCertificatePath ,
                    IAgree = @IAgree ,
                    StepNo = @StepNo ,
                    CentralGroundWaterAuthority = @CentralGroundWaterAuthority ,
                    DateOfNOCIssuanceByCGWD = @DateOfNOCIssuanceByCGWD ,
                    DateOfNOCExpiryByCGWD = @DateOfNOCExpiryByCGWD ,
                    NOCByCGWDCertificatePath = @NOCByCGWDCertificatePath ,
                    NOCCertificateNumberByCGWD = @NOCCertificateNumberByCGWD
            WHERE   RegistrationID = @RegistrationID; 
				
				        
            SELECT  RegistrationID ,
                    AppNo ,
                    FormTypeID ,
                    UserCategoryID ,
                    UserTypeID ,
                    RDistrictID ,
                    d3.DistrictName AS RegDistrictName ,
                    d.DistrictName AS RDistrictName ,
                    RBlockID ,
                    bl.BlockName AS RegBlockName ,
                    MobileNo ,
                    EmailID ,
                    ApplicantName ,
                    OTP ,
                    IsMobileVerified ,
                    HaveNOC ,
                    GWDCertificate ,
              -- ISNULL(CONVERT(VARCHAR(50), ApplicationDate, 103),'01/01/1999')
                    ApplicationDate ,
                    OwnerName ,
              -- ISNULL(CONVERT(VARCHAR(50), DateOfBirth, 103),'01/01/1999')
                    DateOfBirth ,
                    CareOF ,
                    Gender ,
                    ct6.Name AS GenderName ,
                    Nationality ,
                    ct7.Name AS NationalityName ,
                    Address ,
                    a.StateID ,
                    s.StateName AS StateName ,
                    a.DistrictID ,
                    d1.DistrictName AS ADistrictName ,
                    Pincode ,
                    P_DistrictID ,
                    d2.DistrictName AS PDistrictName ,
                    P_BlockID ,
                    b.BlockName AS BlockName ,
                    PlotKhasraNo ,
                    IDProofID ,
                    ct1.Name AS IDName ,
                    IDNumber ,
                    IDPath ,
                    MunicipalityCorporation ,
                    WardHoldingNo ,
                --ISNULL(CONVERT(VARCHAR(50), DateOfConstruction, 103),'01/01/1999') 
                    DateOfConstruction ,
                    TypeOfTheWellID ,
                    ct2.Name AS WTName ,
                    DepthOfTheWell ,
                    IsAdverseReport ,
                    WaterQuality ,
                    TypeOfPumpID ,
                    ct3.Name AS PumpTypeName ,
                    LengthColumnPipe ,
                    PumpCapacity ,
                    HorsePower ,
                    OperationalDeviceID ,
                    ct4.Name AS ODName ,
                    DateOfEnergization ,
                    PurposeOfWellID ,
                    ct5.Name AS PWName ,
                    AnnualRunningHours ,
                    DailyRunningHours ,
                    IsPipedWaterSupply ,
                    ModeOfTreatment ,
                    IsObtainedNOC_UP ,
                    IsRainWaterHarvesting ,
                    Remarks ,
                    ISNULL(IAgree, 'False') IAgree ,
                    IsPaymentDone ,
                    IPAddress ,
                    CreatedOn ,
                    LastModifiedOn ,
                    a.IsDeleted ,
                    IsActive ,
                    Relation ,
                    ct8.Name AS Relationof ,
                    DiameterOfDugWell ,
                    StructureofdugWell ,
                    ApproxLengthOfPipe ,
                    ApproxDiameterOfPipe ,
                    ApproxLengthOfStrainer ,
                    ApproxDiameterOfStrainer ,
                    MaterialOfPipe ,
                    ct9.Name PMaterialName ,
                    MaterialOfStrainer ,
                    ct10.Name SMaterialName ,
                    IfAny ,
                    RegCertificateIssueByGWD ,
                    RegCertificateNumber ,
               -- ISNULL(CONVERT(VARCHAR(50), DateOfRegCertificateIssuance, 103),'01/01/1999') 
                    DateOfRegCertificateIssuance ,
               -- ISNULL(CONVERT(VARCHAR(50), DateOfRegCertificateExpiry, 103),'01/01/1999')
                    DateOfRegCertificateExpiry ,
                    RegCertificatePath ,
                    a.StepNo ,
                    CentralGroundWaterAuthority ,
                    DateOfNOCIssuanceByCGWD ,
                    DateOfNOCExpiryByCGWD ,
                    NOCByCGWDCertificatePath ,
                    NOCCertificateNumberByCGWD
            FROM    dbo.M_Registration a
                    LEFT  JOIN [dbo].[M_District] d ON a.RDistrictID = d.DistrictID
                    LEFT JOIN dbo.M_State s ON a.StateID = s.StateID
                    LEFT JOIN dbo.M_Block b ON a.P_BlockID = b.BlockID
                    LEFT JOIN dbo.CommonTable ct1 ON a.IDProofID = ct1.CommonID
                    LEFT JOIN [dbo].[CommonTable] ct2 ON a.TypeOfTheWellID = ct2.CommonID
                    LEFT JOIN [dbo].[CommonTable] ct3 ON a.TypeOfPumpID = ct3.CommonID
                    LEFT JOIN [dbo].[CommonTable] ct4 ON a.OperationalDeviceID = ct4.CommonID
                    LEFT JOIN [dbo].[CommonTable] ct5 ON a.PurposeOfWellID = ct5.CommonID
                    LEFT JOIN [dbo].[CommonTable] ct6 ON a.Gender = ct6.CommonID
                    LEFT JOIN [dbo].[CommonTable] ct7 ON a.Nationality = ct7.CommonID
                    LEFT JOIN [dbo].[CommonTable] ct8 ON a.Relation = ct8.CommonID
                    LEFT JOIN [dbo].[CommonTable] ct9 ON a.MaterialOfPipe = ct9.CommonID
                    LEFT JOIN [dbo].[CommonTable] ct10 ON a.MaterialOfStrainer = ct10.CommonID
                    LEFT JOIN [dbo].[M_District] d1 ON a.DistrictID = d1.DistrictID
                    LEFT JOIN [dbo].[M_District] d2 ON a.P_DistrictID = d2.DistrictID
                    LEFT JOIN [dbo].[M_District] d3 ON a.RDistrictID = d3.DistrictID
                    LEFT JOIN dbo.M_Block bl ON bl.BlockID = a.RBlockID
            WHERE   a.RegistrationID = @RegistrationID;       
        END; 
    END;


GO
/****** Object:  StoredProcedure [dbo].[Proc_InsertUpdateDistrictDetail]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[Proc_InsertUpdateDistrictDetail]
    @AppNo VARCHAR(50) ,
    @Districtids VARCHAR(50) ,
    @DrillingMachineDetail VARCHAR(300) ,
    @DrillingPurposeId VARCHAR(10) ,
    @IPAddress VARCHAR(50)
 AS
    BEGIN
  --[dbo].[fnStringList2Table]    

        IF EXISTS ( SELECT  *
                    FROM    dbo.T_DrillingDistrictMachine
                    WHERE   Isdeleted = 0
                            AND AppNo = @AppNo )
            BEGIN
                UPDATE  dbo.T_DrillingDistrictMachine
                SET     Isdeleted = 1
                WHERE   Isdeleted = 0
                        AND AppNo = @AppNo; 
            END;
        INSERT  INTO dbo.T_DrillingDistrictMachine
                ( RegId ,
                  AppNo ,
                  DistrictId ,
                  DrillingMachineDetail ,
                  DrillingPurposeId ,
                  Isdeleted ,
                  TransDate ,
                  TransIPAddress
			    )
                SELECT  drilling.RegId ,
                        drilling.AppNo ,
                        item ,
                        @DrillingMachineDetail ,
                        @DrillingPurposeId ,
                        0 ,
                        GETDATE() ,
                        @IPAddress
                FROM    [dbo].[fnStringList2Table](@Districtids)
                        CROSS JOIN (SELECT * FROM dbo.T_DrillingRegistration WHERE AppNo=@AppNo) drilling; 
     
        UPDATE  dbo.T_DrillingRegistration
        SET     StepNo = CASE StepNo WHEN 1 THEN 2 ELSE StepNo end
        WHERE   ( ISNULL(StepNo, 0) >= 1 )
                AND AppNo = @AppNo;
       
        SELECT  AppNo ,
                StepNo
        FROM    dbo.T_DrillingRegistration
        WHERE   ( ISNULL(StepNo, 0) >= 1 )
                AND AppNo = @AppNo;
    END;

GO
/****** Object:  StoredProcedure [dbo].[proc_LoadApplicationForm]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---Created By Sushil Kumar Sharma
---Created On 30/09/2019

CREATE PROCEDURE [dbo].[proc_LoadApplicationForm]  -- proc_LoadApplicationForm
    (
      @RegistrationID BIGINT = 0      
	)
AS
    BEGIN
            
        SELECT  RegistrationID ,
                AppNo ,
                FormTypeID ,
                UserCategoryID ,
                UserTypeID ,
                RDistrictID ,
                d3.DistrictName AS RegDistrictName ,
                d.DistrictName AS RDistrictName ,
                RBlockID ,
                bl.BlockName AS RegBlockName ,
                MobileNo ,
                EmailID ,
                ApplicantName ,
                OTP ,
                IsMobileVerified ,
                HaveNOC ,
                GWDCertificate ,
              -- ISNULL(CONVERT(VARCHAR(50), ApplicationDate, 103),'01/01/1999')
                ApplicationDate ,
                OwnerName ,
              -- ISNULL(CONVERT(VARCHAR(50), DateOfBirth, 103),'01/01/1999')
                DateOfBirth ,
                CareOF ,
                Gender ,
                ct6.Name AS GenderName ,
                Nationality ,
                ct7.Name AS NationalityName ,
                Address ,
                a.StateID ,
                s.StateName AS StateName ,
                a.DistrictID ,
                d1.DistrictName AS ADistrictName ,
                Pincode ,
                P_DistrictID ,
                d2.DistrictName AS PDistrictName ,
                P_BlockID ,
                b.BlockName AS BlockName ,
                PlotKhasraNo ,
                IDProofID ,
                ct1.Name AS IDName ,
                IDNumber ,
                IDPath ,
                MunicipalityCorporation ,
                WardHoldingNo ,
                --ISNULL(CONVERT(VARCHAR(50), DateOfConstruction, 103),'01/01/1999') 
                DateOfConstruction ,
                TypeOfTheWellID ,
                ct2.Name AS WTName ,
                DepthOfTheWell ,
                IsAdverseReport ,
                WaterQuality ,
                TypeOfPumpID ,
                ct3.Name AS PumpTypeName ,
                LengthColumnPipe ,
                PumpCapacity ,
                HorsePower ,
                OperationalDeviceID ,
                ct4.Name AS ODName ,
                DateOfEnergization ,
                PurposeOfWellID ,
                ct5.Name AS PWName ,
                AnnualRunningHours ,
                DailyRunningHours ,
                IsPipedWaterSupply ,
                ModeOfTreatment ,
                IsObtainedNOC_UP ,
                IsRainWaterHarvesting ,
                Remarks ,
                ISNULL(IAgree, 'False') IAgree ,
                IsPaymentDone ,
                IPAddress ,
                CreatedOn ,
                LastModifiedOn ,
                a.IsDeleted ,
                IsActive ,
                Relation ,
                ct8.Name AS Relationof ,
                DiameterOfDugWell ,
                StructureofdugWell ,
                ApproxLengthOfPipe ,
                ApproxDiameterOfPipe ,
                ApproxLengthOfStrainer ,
                ApproxDiameterOfStrainer ,
                MaterialOfPipe ,
                ct9.Name PMaterialName ,
                MaterialOfStrainer ,
                ct10.Name SMaterialName ,
                IfAny ,
                RegCertificateIssueByGWD ,
                RegCertificateNumber ,
               -- ISNULL(CONVERT(VARCHAR(50), DateOfRegCertificateIssuance, 103),'01/01/1999') 
                DateOfRegCertificateIssuance ,
               -- ISNULL(CONVERT(VARCHAR(50), DateOfRegCertificateExpiry, 103),'01/01/1999')
                DateOfRegCertificateExpiry ,
                RegCertificatePath ,
                CentralGroundWaterAuthority ,
                DateOfNOCIssuanceByCGWD ,
                DateOfNOCExpiryByCGWD ,
                NOCByCGWDCertificatePath ,
                NOCCertificateNumberByCGWD ,
                a.StepNo
        FROM    dbo.M_Registration a
                LEFT  JOIN [dbo].[M_District] d ON a.RDistrictID = d.DistrictID
                LEFT JOIN dbo.M_State s ON a.StateID = s.StateID
                LEFT JOIN dbo.M_Block b ON a.P_BlockID = b.BlockID
                LEFT JOIN dbo.CommonTable ct1 ON a.IDProofID = ct1.CommonID
                LEFT JOIN [dbo].[CommonTable] ct2 ON a.TypeOfTheWellID = ct2.CommonID
                LEFT JOIN [dbo].[CommonTable] ct3 ON a.TypeOfPumpID = ct3.CommonID
                LEFT JOIN [dbo].[CommonTable] ct4 ON a.OperationalDeviceID = ct4.CommonID
                LEFT JOIN [dbo].[CommonTable] ct5 ON a.PurposeOfWellID = ct5.CommonID
                LEFT JOIN [dbo].[CommonTable] ct6 ON a.Gender = ct6.CommonID
                LEFT JOIN [dbo].[CommonTable] ct7 ON a.Nationality = ct7.CommonID
                LEFT JOIN [dbo].[CommonTable] ct8 ON a.Relation = ct8.CommonID
                LEFT JOIN [dbo].[CommonTable] ct9 ON a.MaterialOfPipe = ct9.CommonID
                LEFT JOIN [dbo].[CommonTable] ct10 ON a.MaterialOfStrainer = ct10.CommonID
                LEFT JOIN [dbo].[M_District] d1 ON a.DistrictID = d1.DistrictID
                LEFT JOIN [dbo].[M_District] d2 ON a.P_DistrictID = d2.DistrictID
                LEFT JOIN [dbo].[M_District] d3 ON a.RDistrictID = d3.DistrictID
                LEFT JOIN dbo.M_Block bl ON bl.BlockID = a.RBlockID
        WHERE   RegistrationID = @RegistrationID;       

    END;


GO
/****** Object:  StoredProcedure [dbo].[Proc_OTPVerification]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[Proc_OTPVerification] -- Proc_OTPVerification '1900008','075693','1989613119424195207612291582019915060','UD4J40',''
    @TempRegNo INT ,
    @OTP VARCHAR(150) ,
    @Password VARCHAR(150) ,
    @pswdDisp VARCHAR(20) ,
    @IPAddress VARCHAR(50)
AS
    BEGIN
       
        IF EXISTS ( SELECT  1
                    FROM    dbo.T_TempDrillingReg
                    WHERE   TempRegNo = @TempRegNo
                            AND Isdeleted = 0 )
            BEGIN
			PRINT '1'
                IF EXISTS ( SELECT  1
                            FROM    dbo.T_TempDrillingReg
                            WHERE   TempRegNo = @TempRegNo
                                    AND Isdeleted = 0
                                    AND OTP = @OTP )
                    BEGIN
            PRINT '2'           
                        BEGIN TRY
                            BEGIN TRAN;
                            DECLARE @AppNo VARCHAR(50)= ( SELECT
                                                              dbo.fnGenerateDrillingRegNo()
                                                        );

							PRINT @AppNo
                            INSERT  INTO dbo.T_DrillingRegistration
                                    ( AppNo ,
                                      TempRegNo ,
                                      UserTypeId ,
                                      CompanyName ,
                                      ApplicantName ,
                                      FirmRegNo ,
                                      FirmGSTNo ,
                                      FirmPanNo ,
                                      MobileNo ,
                                      EmailId ,
                                      TransDate ,
                                      Isdeleted ,
                                      IPAddress
			                        )
                                    SELECT  @AppNo ,
                                            TempRegNo ,
                                            UserTypeId ,
                                            CompanyName ,
                                            ApplicantName ,
                                            FirmRegNo ,
                                            FirmGSTNo ,
                                            FirmPanNo ,
                                            MobileNo ,
                                            EmailId ,
                                            GETDATE() TransDate ,
                                            0 Isdeleted ,
                                            @IPAddress IPAddress
                                    FROM    dbo.T_TempDrillingReg
                                    WHERE   TempRegNo = @TempRegNo
                                            AND Isdeleted = 0
                                            AND OTP = @OTP;

                            UPDATE  T_TempDrillingReg
                            SET     OTP = NULL
                            WHERE   TempRegNo = @TempRegNo
                                    AND Isdeleted = 0
                                    AND OTP = @OTP; 

                            INSERT  INTO dbo.Sec_UserMaster
                                    ( UserName ,
                                      Password ,
                                      AppNo ,
                                      IsPassWordChange ,
                                      IsDeleted ,
                                      FirstLogin ,
                                      LastLoginTime ,
                                      LastLoginIP ,
                                      WrongAttempt ,
                                      CreatedOn ,
                                      IsActive ,
                                      DisplayPassword 									  
									  --LoginType
									 )
                            VALUES  ( @AppNo , -- UserName - varchar(150)
                                      @Password , -- Password - nvarchar(max)
                                      @AppNo , -- AppNo - varchar(15)
                                      0 , -- IsPassWordChange - bit
                                      0 , -- IsDeleted - bit
                                      1 , -- FirstLogin - bit
                                      GETDATE() , -- LastLoginTime - datetime
                                      @IPAddress , -- LastLoginIP - varchar(50)
                                      0 , -- WrongAttempt - int
                                      GETDATE() , -- CreatedOn - datetime
                                      1 , -- IsActive - bit
                                      @pswdDisp --, -- PswDisp - varchar(12)
									  
									 );

                            SELECT  AppNo ,
                                    CAST(1 AS BIT) IsSuccess
                            FROM    Sec_UserMaster
                            WHERE   AppNo = @AppNo;
                            COMMIT TRAN; 
                        END TRY
                        BEGIN CATCH
                            ROLLBACK TRAN;
							PRINT '3'
                        END CATCH;

                    END;
                ELSE
                    BEGIN
				
                        SELECT  CAST(0 AS BIT) IsSuccess ,
                                CAST(0 AS BIT) IsInvalid ,
                                CAST(1 AS BIT) IsNotMatch;
                    END;
            END;
        ELSE
            BEGIN
				
                SELECT  CAST(0 AS BIT) IsSuccess ,
                        CAST(1 AS BIT) IsInvalid ,
                        CAST(0 AS BIT) IsNotMatch;
            END;
       
    END;

GO
/****** Object:  StoredProcedure [dbo].[proc_SelectBlockMaster]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



---Created By Sushil Kumar Sharma
---Created On 02/10/2019

CREATE   PROCEDURE [dbo].[proc_SelectBlockMaster]
    (
      @DistrictID INT 
	)
AS
    BEGIN
      
	   WITH Blocks
AS
( SELECT * FROM M_Block x WHERE x.DistrictID=@DistrictID )

  SELECT * FROM Blocks WHERE BlockID NOT IN(SELECT BlockID FROM tblAssignedBlock)
    END;



GO
/****** Object:  StoredProcedure [dbo].[proc_SelectCommonMaster]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---Created By Sushil Kumar Sharma
---Created On 27/09/2019

CREATE   PROCEDURE [dbo].[proc_SelectCommonMaster]
    (
      @TypeID VARCHAR(10)
	)
AS
    BEGIN
       SELECT * FROM [dbo].[CommonTable] WHERE TypeID=@TypeID
    END;


GO
/****** Object:  StoredProcedure [dbo].[proc_SelectDistrictMaster]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---Created By Sushil Kumar Sharma
---Created On 02/10/2019

CREATE   PROCEDURE [dbo].[proc_SelectDistrictMaster]
    (
      @StateID INT 
	)
AS
    BEGIN
       SELECT * FROM [dbo].[M_District] WHERE StateID=@StateID ORDER BY DistrictName ASC 
    END;


GO
/****** Object:  StoredProcedure [dbo].[proc_SelectStateMaster]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---Created By Sushil Kumar Sharma
---Created On 02/10/2019

CREATE   PROCEDURE [dbo].[proc_SelectStateMaster]
    (
      @CountryID INT 
	)
AS
    BEGIN
       SELECT * FROM [dbo].[M_State] WHERE CountryID=@CountryID
    END;


GO
/****** Object:  StoredProcedure [dbo].[proc_UpdateBlockUser]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_UpdateBlockUser]
@ID INT,
@Mobile VARCHAR(50),
@Email NVARCHAR(50)
AS
BEGIN
UPDATE tbleBlockUserMaster  SET Mobile=@Mobile , Email=@Email
	WHERE   IsDeleted='False'  AND ID=@ID
END




GO
/****** Object:  StoredProcedure [dbo].[proc_UpdateOTP]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---Created By Sushil Kumar Sharma
---Created On 05/10/2019

create   PROCEDURE [dbo].[proc_UpdateOTP]
    (
      @OTP VARCHAR(50)=NULL,
	  @RegistrationID INT =NULL
	)
AS
    BEGIN

                UPDATE  [dbo].[M_Registration]
                SET     OTP = @OTP
                WHERE   RegistrationID = @RegistrationID;
                SELECT  'Success' AS Status; 

    END;


GO
/****** Object:  StoredProcedure [dbo].[proc_UpdatePassword]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--create by Sushil Kumar Sharma
--created on 03/10/2019

CREATE PROC [dbo].[proc_UpdatePassword]
    @RegistrationID BIGINT,
    @Password VARCHAR(500),
    @ConfirmPassowrd VARCHAR(500)
AS
    BEGIN
        UPDATE dbo.Sec_UserMaster SET Password=@Password ,
		DisplayPassword=@ConfirmPassowrd
        WHERE RegistrationID =@RegistrationID
    END
GO
/****** Object:  StoredProcedure [dbo].[proc_UpdateUserPassword]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[proc_UpdateUserPassword]
    @MobileNo VARCHAR(50) = NULL ,
    @Password VARCHAR(150) = NULL ,
    @DisplayPassword VARCHAR(50) = NULL ,
    @RegistrationID BIGINT ,
    @UserName VARCHAR(20) = NULL ,
    @ProcId INT = 0
AS
    BEGIN
        IF ( @ProcId = 1 )
            BEGIN 
                UPDATE  dbo.Sec_UserMaster
                SET     Password = @Password ,
                        DisplayPassword = @DisplayPassword
                WHERE   RegistrationID = @RegistrationID
                        AND UserName = @UserName
                        AND IsActive = 1
                        AND IsDeleted = 0;

                SELECT  DisplayPassword ,
                        UserName
                FROM    Sec_UserMaster
                WHERE   RegistrationID = @RegistrationID
                        AND UserName = @UserName
                        AND IsActive = 1
                        AND IsDeleted = 0;
            END; 
    END; 

GO
/****** Object:  StoredProcedure [dbo].[proc_UserRegistration]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---Created By Sushil Kumar Sharma
---Created On 26/09/2019

CREATE PROCEDURE [dbo].[proc_UserRegistration]
    @ProcId INT = 0 ,
    @FormTypeID SMALLINT = NULL ,
    @UserCategoryID SMALLINT = NULL ,
    @UserTypeID SMALLINT = NULL ,
    @RDistrictID SMALLINT = NULL ,
    @RBlockID SMALLINT = NULL ,
    @EmailID VARCHAR(150) = NULL ,
    @ApplicantName VARCHAR(200) = NULL ,
    @IPAddress VARCHAR(100) = NULL ,
    @IsMobileVerified BIT = NULL ,
    @MobileNo VARCHAR(15) = NULL ,
    @OTP VARCHAR(10) = NULL ,
    @GWDCertificate BIT = NULL ,
    @HaveNOC BIT = NULL ,
    @RHaveNocByGWD BIT = NULL
AS
    BEGIN
        IF ( @ProcId = 1 )  -- Create User And Registration
            BEGIN
                DECLARE @AppNo VARCHAR(15) = NULL;
                INSERT  INTO dbo.M_Registration
                        ( AppNo ,
                          FormTypeID ,
                          UserCategoryID ,
                          UserTypeID ,
                          RDistrictID ,
                          RBlockID ,
                          MobileNo ,
                          EmailID ,
                          ApplicantName ,
                          OTP ,
                          ApplicationDate ,
                          IPAddress ,
                          CreatedOn ,
                          IsMobileVerified ,
                          HaveNOC ,
                          GWDCertificate ,
                          IsDeleted ,
                          IsActive ,
                          RHaveNocByGWD
							 
							  
                        )
                VALUES  ( @AppNo ,
                          @FormTypeID ,
                          @UserCategoryID ,
                          @UserTypeID ,
                          @RDistrictID ,
                          @RBlockID ,
                          @MobileNo ,
                          @EmailID ,
                          @ApplicantName ,
                          @OTP ,
                          GETDATE() ,
                          @IPAddress ,
                          GETDATE() ,
                          @IsMobileVerified ,
                          @HaveNOC ,
                          @GWDCertificate ,
                          'False' ,
                          'True' ,
                          @RHaveNocByGWD
                        );   
                DECLARE @id BIGINT; 
                SET @id = ( SELECT  SCOPE_IDENTITY()
                          );
                SELECT  RegistrationID ,
                        AppNo ,
                        RHaveNocByGWD ,
                        FormTypeID ,
                        UserCategoryID ,
                        UserTypeID ,
                        RDistrictID ,
                        d3.DistrictName AS RegDistrictName ,
                        d.DistrictName AS RDistrictName ,
                        RBlockID ,
                        bl.BlockName AS RegBlockName ,
                        MobileNo ,
                        EmailID ,
                        ApplicantName ,
                        OTP ,
                        IsMobileVerified ,
                        HaveNOC ,
                        GWDCertificate ,
              -- ISNULL(CONVERT(VARCHAR(50), ApplicationDate, 103),'01/01/1999')
                        ApplicationDate ,
                        OwnerName ,
              -- ISNULL(CONVERT(VARCHAR(50), DateOfBirth, 103),'01/01/1999')
                        DateOfBirth ,
                        CareOF ,
                        Gender ,
                        ct6.Name AS GenderName ,
                        Nationality ,
                        ct7.Name AS NationalityName ,
                        Address ,
                        a.StateID ,
                        s.StateName AS StateName ,
                        a.DistrictID ,
                        d1.DistrictName AS ADistrictName ,
                        Pincode ,
                        P_DistrictID ,
                        d2.DistrictName AS PDistrictName ,
                        P_BlockID ,
                        b.BlockName AS BlockName ,
                        PlotKhasraNo ,
                        IDProofID ,
                        ct1.Name AS IDName ,
                        IDNumber ,
                        IDPath ,
                        MunicipalityCorporation ,
                        WardHoldingNo ,
                --ISNULL(CONVERT(VARCHAR(50), DateOfConstruction, 103),'01/01/1999') 
                        DateOfConstruction ,
                        TypeOfTheWellID ,
                        ct2.Name AS WTName ,
                        DepthOfTheWell ,
                        IsAdverseReport ,
                        WaterQuality ,
                        TypeOfPumpID ,
                        ct3.Name AS PumpTypeName ,
                        LengthColumnPipe ,
                        PumpCapacity ,
                        HorsePower ,
                        OperationalDeviceID ,
                        ct4.Name AS ODName ,
                        DateOfEnergization ,
                        PurposeOfWellID ,
                        ct5.Name AS PWName ,
                        AnnualRunningHours ,
                        DailyRunningHours ,
                        IsPipedWaterSupply ,
                        ModeOfTreatment ,
                        IsObtainedNOC_UP ,
                        IsRainWaterHarvesting ,
                        Remarks ,
                        ISNULL(IAgree, 'False') IAgree ,
                        IsPaymentDone ,
                        IPAddress ,
                        CreatedOn ,
                        LastModifiedOn ,
                        a.IsDeleted ,
                        IsActive ,
                        Relation ,
                        ct8.Name AS Relationof ,
                        DiameterOfDugWell ,
                        StructureofdugWell ,
                        ApproxLengthOfPipe ,
                        ApproxDiameterOfPipe ,
                        ApproxLengthOfStrainer ,
                        ApproxDiameterOfStrainer ,
                        MaterialOfPipe ,
                        ct9.Name PMaterialName ,
                        MaterialOfStrainer ,
                        ct10.Name SMaterialName ,
                        IfAny ,
                        RegCertificateIssueByGWD ,
                        RegCertificateNumber ,
               -- ISNULL(CONVERT(VARCHAR(50), DateOfRegCertificateIssuance, 103),'01/01/1999') 
                        DateOfRegCertificateIssuance ,
               -- ISNULL(CONVERT(VARCHAR(50), DateOfRegCertificateExpiry, 103),'01/01/1999')
                        DateOfRegCertificateExpiry ,
                        RegCertificatePath
                FROM    dbo.M_Registration a
                        LEFT  JOIN [dbo].[M_District] d ON a.RDistrictID = d.DistrictID
                        LEFT JOIN dbo.M_State s ON a.StateID = s.StateID
                        LEFT JOIN dbo.M_Block b ON a.P_BlockID = b.BlockID
                        LEFT JOIN dbo.CommonTable ct1 ON a.IDProofID = ct1.CommonID
                        LEFT JOIN [dbo].[CommonTable] ct2 ON a.TypeOfTheWellID = ct2.CommonID
                        LEFT JOIN [dbo].[CommonTable] ct3 ON a.TypeOfPumpID = ct3.CommonID
                        LEFT JOIN [dbo].[CommonTable] ct4 ON a.OperationalDeviceID = ct4.CommonID
                        LEFT JOIN [dbo].[CommonTable] ct5 ON a.PurposeOfWellID = ct5.CommonID
                        LEFT JOIN [dbo].[CommonTable] ct6 ON a.Gender = ct6.CommonID
                        LEFT JOIN [dbo].[CommonTable] ct7 ON a.Nationality = ct7.CommonID
                        LEFT JOIN [dbo].[CommonTable] ct8 ON a.Relation = ct8.CommonID
                        LEFT JOIN [dbo].[CommonTable] ct9 ON a.MaterialOfPipe = ct9.CommonID
                        LEFT JOIN [dbo].[CommonTable] ct10 ON a.MaterialOfPipe = ct10.CommonID
                        LEFT JOIN [dbo].[M_District] d1 ON a.DistrictID = d1.DistrictID
                        LEFT JOIN [dbo].[M_District] d2 ON a.P_DistrictID = d2.DistrictID
                        LEFT JOIN [dbo].[M_District] d3 ON a.RDistrictID = d3.DistrictID
                        LEFT JOIN dbo.M_Block bl ON bl.BlockID = a.RBlockID
                WHERE   RegistrationID = @id;
            END; 
        
    END;


GO
/****** Object:  StoredProcedure [dbo].[proc_VerifyUserMobile]    Script Date: 10/18/2019 6:00:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--create by Sushil Kumar Sharma
--created on 27/09/2019

CREATE PROC [dbo].[proc_VerifyUserMobile]
    @OTP VARCHAR(20) ,
    @RegistrationID BIGINT
AS
    BEGIN
	IF EXISTS( SELECT * FROM dbo.M_Registration WHERE  RegistrationID = @RegistrationID AND OTP = @OTP )
	BEGIN 
	UPDATE dbo.M_Registration SET IsMobileVerified='True' WHERE RegistrationID=@RegistrationID
	END 
        SELECT [RegistrationID]
      ,[AppNo]
      ,[FormTypeID]
      ,[UserCategoryID]
      ,[UserTypeID]
      ,[RDistrictID]
      ,[RBlockID]
      ,[MobileNo]
      ,[EmailID]
      ,[ApplicantName]
      ,[OTP]
      ,[IsMobileVerified]
      ,[HaveNOC]
      ,[GWDCertificate]
      ,[ApplicationDate]
      ,[OwnerName]
      ,[DateOfBirth]
      ,[CareOF]
      ,[Gender]
      ,[Nationality]
      ,[Address]
      ,[StateID]
      ,[DistrictID]
      ,[Pincode]
      ,[P_DistrictID]
      ,[P_BlockID]
      ,[PlotKhasraNo]
      ,[IDProofID]
      ,[IDNumber]
      ,[IDPath]
      ,[MunicipalityCorporation]
      ,[WardHoldingNo]
      ,[DateOfConstruction]
      ,[TypeOfTheWellID]
      ,[DepthOfTheWell]
      ,[IsAdverseReport]
      ,[WaterQuality]
      ,[TypeOfPumpID]
      ,[LengthColumnPipe]
      ,[PumpCapacity]
      ,[HorsePower]
      ,[OperationalDeviceID]
      ,[DateOfEnergization]
      ,[PurposeOfWellID]
      ,[AnnualRunningHours]
      ,[DailyRunningHours]
      ,[IsPipedWaterSupply]
      ,[ModeOfTreatment]
      ,[IsObtainedNOC_UP]
      ,[IsRainWaterHarvesting]
      ,[Remarks]
      ,ISNULL([IAgree],'False')IAgree
      ,[IsPaymentDone]
      ,[IPAddress]
      ,[CreatedOn]
      ,[LastModifiedOn]
      ,[IsDeleted]
      ,[IsActive]
      ,[Relation]
      ,[DiameterOfDugWell]
      ,[ApproxLengthOfPipe]
      ,[ApproxDiameterOfPipe]
      ,[ApproxLengthOfStrainer]
      ,[ApproxDiameterOfStrainer]
      ,[MaterialOfPipe]
      ,[MaterialOfStrainer]
      ,[StructureofdugWell]
      ,[IfAny]
      ,[RegCertificateIssueByGWD]
      ,[RegCertificateNumber]
      ,[DateOfRegCertificateIssuance]
      ,[DateOfRegCertificateExpiry]
      ,[RegCertificatePath],'Success' AS Status FROM    [dbo].[M_Registration]
        WHERE   RegistrationID = @RegistrationID AND OTP = @OTP 
    END
GO
USE [master]
GO
ALTER DATABASE [GWDUP] SET  READ_WRITE 
GO

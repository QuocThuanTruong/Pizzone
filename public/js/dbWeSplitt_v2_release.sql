USE [master]
GO
/****** Object:  Database [WeSplit]    Script Date: 12/15/2020 4:55:08 AM ******/
CREATE DATABASE [WeSplit]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'WeSplit', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\WeSplit.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'WeSplit_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\WeSplit_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [WeSplit] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [WeSplit].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [WeSplit] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [WeSplit] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [WeSplit] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [WeSplit] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [WeSplit] SET ARITHABORT OFF 
GO
ALTER DATABASE [WeSplit] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [WeSplit] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [WeSplit] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [WeSplit] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [WeSplit] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [WeSplit] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [WeSplit] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [WeSplit] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [WeSplit] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [WeSplit] SET  ENABLE_BROKER 
GO
ALTER DATABASE [WeSplit] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [WeSplit] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [WeSplit] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [WeSplit] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [WeSplit] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [WeSplit] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [WeSplit] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [WeSplit] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [WeSplit] SET  MULTI_USER 
GO
ALTER DATABASE [WeSplit] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [WeSplit] SET DB_CHAINING OFF 
GO
ALTER DATABASE [WeSplit] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [WeSplit] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [WeSplit] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [WeSplit] SET QUERY_STORE = OFF
GO
USE [WeSplit]
GO
/****** Object:  UserDefinedFunction [dbo].[CalcRemainByIDMemberAndIDJourney]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CalcRemainByIDMemberAndIDJourney](@idMember int, @idJourney int)
RETURNS money
AS
	BEGIN
		DECLARE @remain money
	
		IF(EXISTS(SELECT* FROM [dbo].[Advance] WHERE ID_Journey = @idJourney AND ID_Lender = @idMember))
		BEGIN
			SET @remain = [dbo].[GetRecieivablesByIDMemberAndIDJourney](@idMember, @idJourney) - (SELECT Advance_Money FROM [dbo].[CalcSumAdvanceMoneyByIDMemberAndIDJourney](@idMember, @idJourney))
		END
		ELSE
		BEGIN
			SET @remain = [dbo].[GetRecieivablesByIDMemberAndIDJourney](@idMember, @idJourney)
		END
		return @remain
	END
GO
/****** Object:  UserDefinedFunction [dbo].[CalcSumAdvanceByIDJourney]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CalcSumAdvanceByIDJourney](@idJourney int)
RETURNS money
AS
	BEGIN
		DECLARE @sum money
		SET @sum = (SELECT SUM(Advance_Money) FROM [dbo].[Advance] WHERE ID_Journey = @idJourney)
		RETURN @sum
	END
GO
/****** Object:  UserDefinedFunction [dbo].[CalcSumExpensesByIDJourney]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CalcSumExpensesByIDJourney](@idJourney int)
RETURNS money
AS
	BEGIN
		DECLARE @res money
		set @res = (SELECT SUM(Expenses_Money) FROM [dbo].[Expenses] WHERE ID_Journey = @idJourney)
		return @res
	END
GO
/****** Object:  UserDefinedFunction [dbo].[CalcSumReceivablesByIDJourney]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CalcSumReceivablesByIDJourney](@idJourney int)
RETURNS money
AS
	BEGIN
		DECLARE @res money
		SET @res = (SELECT SUM([dbo].[GetRecieivablesByIDMemberAndIDJourney](JA.ID_Member, @idJourney))
					FROM [dbo].[JourneyAttendance] JA
					WHERE JA.ID_Journey = @idJourney)
		RETURN @res
	END
GO
/****** Object:  UserDefinedFunction [dbo].[GetRecieivablesByIDMemberAndIDJourney]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetRecieivablesByIDMemberAndIDJourney](@idMember int, @idJourney int)
RETURNS money
AS
	BEGIN
		DECLARE @res money
		SET @res = (SELECT Receivables_Money FROM [dbo].[JourneyAttendance] WHERE ID_Journey = @idJourney AND ID_Member = @idMember)
		RETURN @res
	END
GO
/****** Object:  Table [dbo].[JourneyImage]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JourneyImage](
	[ID_Journey] [int] NOT NULL,
	[Ordinal_Number] [int] NOT NULL,
	[Link_Image] [nvarchar](max) NULL,
 CONSTRAINT [PK_JourneyImage] PRIMARY KEY CLUSTERED 
(
	[ID_Journey] ASC,
	[Ordinal_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetLinkImageByIDJourneyAndOrdinalNumber]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetLinkImageByIDJourneyAndOrdinalNumber](@idJourney int, @ordinalNumber int)
RETURNS table
AS
	return (SELECT Link_Image FROM [dbo].[JourneyImage] WHERE ID_Journey = @idJourney AND Ordinal_Number = @ordinalNumber)
GO
/****** Object:  Table [dbo].[Member]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Member](
	[ID_Member] [int] IDENTITY(1,1) NOT NULL,
	[Member_Name] [nvarchar](200) NULL,
	[Phone_Number] [nchar](20) NULL,
	[Member_Link_Avt] [nvarchar](max) NULL,
 CONSTRAINT [PK_Member] PRIMARY KEY CLUSTERED 
(
	[ID_Member] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[JourneyAttendance]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JourneyAttendance](
	[ID_Member] [int] NOT NULL,
	[ID_Journey] [int] NOT NULL,
	[Receivables_Money] [money] NULL,
	[Role] [nvarchar](50) NULL,
 CONSTRAINT [PK_JourneyAttendance] PRIMARY KEY CLUSTERED 
(
	[ID_Member] ASC,
	[ID_Journey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetMemberByIDJourney]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetMemberByIDJourney](@idJourney int)
RETURNS table
AS
	return(SELECT M.Member_Name, M.Phone_Number, JA.Receivables_Money, JA.Role
			FROM [dbo].[Member] M, [dbo].[JourneyAttendance] JA
			WHERE M.ID_Member = JA.ID_Member AND JA.ID_Journey = @idJourney)
GO
/****** Object:  Table [dbo].[Site]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Site](
	[ID_Site] [int] IDENTITY(1,1) NOT NULL,
	[ID_Province] [int] NULL,
	[Site_Name] [nvarchar](200) NULL,
	[Site_Description] [nvarchar](max) NULL,
	[Site_Link_Avt] [nvarchar](max) NULL,
	[Site_Address] [nvarchar](200) NULL,
 CONSTRAINT [PK_Site] PRIMARY KEY CLUSTERED 
(
	[ID_Site] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAllFromSite]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetAllFromSite]()
RETURNS table
AS
	return(SELECT* FROM [dbo].[Site])

GO
/****** Object:  Table [dbo].[Route]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Route](
	[ID_Journey] [int] NOT NULL,
	[Ordinal_Number] [int] NOT NULL,
	[Place] [nvarchar](200) NULL,
	[Province] [nvarchar](200) NULL,
	[Route_Description] [nvarchar](max) NULL,
	[Route_Status] [int] NULL,
 CONSTRAINT [PK_Route] PRIMARY KEY CLUSTERED 
(
	[ID_Journey] ASC,
	[Ordinal_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetRouteByIDJourney]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetRouteByIDJourney](@idJourney int)
RETURNS table
AS
	return(SELECT Ordinal_Number, Place, Province, Route_Description, Route_Status
		   FROM [dbo].[Route]
		   WHERE ID_Journey = @idJourney)
GO
/****** Object:  Table [dbo].[Journey]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Journey](
	[ID_Journey] [int] IDENTITY(1,1) NOT NULL,
	[ID_Site] [int] NULL,
	[Start_Place] [nvarchar](200) NULL,
	[Start_Province] [nvarchar](200) NULL,
	[Status] [int] NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
 CONSTRAINT [PK_Journey] PRIMARY KEY CLUSTERED 
(
	[ID_Journey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetJourneyByStatus]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetJourneyByStatus](@status int)
RETURNS table
AS
	return(SELECT* FROM [dbo].[Journey] WHERE Status = @Status)
GO
/****** Object:  UserDefinedFunction [dbo].[GetAllFromJourney]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetAllFromJourney]()
RETURNS table
AS
	return (SELECT* FROM [dbo].[Journey])
GO
/****** Object:  Table [dbo].[Advance]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Advance](
	[ID_Journey] [int] NOT NULL,
	[ID_Borrower] [int] NOT NULL,
	[ID_Lender] [int] NOT NULL,
	[Advance_Money] [money] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_Journey] ASC,
	[ID_Borrower] ASC,
	[ID_Lender] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[DevideMoney]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
			
CREATE FUNCTION [dbo].[DevideMoney](@idJourney int)
RETURNS table
AS
		return(SELECT M.Member_Name, [dbo].[CalcRemainByIDMemberAndIDJourney](M.ID_Member, @idJourney) AS Remain, A.Advance_Money, A.ID_Lender
				FROM ([dbo].[Member] M lEFT JOIN [dbo].[Advance] A ON A.ID_Borrower = M.ID_Member AND A.ID_Journey = @idJourney) 
				LEFT JOIN [dbo].[JourneyAttendance] JA ON A.ID_Journey = JA.ID_Journey AND M.ID_Member = JA.ID_Member)
GO
/****** Object:  UserDefinedFunction [dbo].[Result]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Result] (@idJourney int)
RETURNS table
AS
		RETURN (SELECT ([dbo].[CalcSumReceivablesByIDJourney](@idJourney) - [dbo].[CalcSumAdvanceByIDJourney](@idJourney)) AS SumReceivable, 
					[dbo].[CalcSumExpensesByIDJourney](@idJourney) AS SumExpense, 
					[dbo].[CalcSumReceivablesByIDJourney](@idJourney) - [dbo].[CalcSumAdvanceByIDJourney](@idJourney) - [dbo].[CalcSumExpensesByIDJourney](@idJourney) AS CurrentMoney)
		
GO
/****** Object:  Table [dbo].[Expenses]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Expenses](
	[ID_Expenses] [int] IDENTITY(1,1) NOT NULL,
	[ID_Journey] [int] NULL,
	[Expenses_Money] [money] NULL,
	[Expenses_Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_Expenses] PRIMARY KEY CLUSTERED 
(
	[ID_Expenses] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Province]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Province](
	[ID_Province] [int] IDENTITY(1,1) NOT NULL,
	[Province_Name] [nvarchar](200) NULL,
 CONSTRAINT [PK_Province] PRIMARY KEY CLUSTERED 
(
	[ID_Province] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[Advance] ([ID_Journey], [ID_Borrower], [ID_Lender], [Advance_Money]) VALUES (2, 1, 2, 10.0000)
INSERT [dbo].[Advance] ([ID_Journey], [ID_Borrower], [ID_Lender], [Advance_Money]) VALUES (2, 1, 4, 20.0000)
INSERT [dbo].[Advance] ([ID_Journey], [ID_Borrower], [ID_Lender], [Advance_Money]) VALUES (2, 2, 1, 5.0000)
INSERT [dbo].[Advance] ([ID_Journey], [ID_Borrower], [ID_Lender], [Advance_Money]) VALUES (2, 2, 3, 3.0000)
INSERT [dbo].[Advance] ([ID_Journey], [ID_Borrower], [ID_Lender], [Advance_Money]) VALUES (2, 3, 1, 15.0000)
INSERT [dbo].[Advance] ([ID_Journey], [ID_Borrower], [ID_Lender], [Advance_Money]) VALUES (2, 3, 2, 2.0000)
INSERT [dbo].[Advance] ([ID_Journey], [ID_Borrower], [ID_Lender], [Advance_Money]) VALUES (3, 1, 3, 20.0000)
INSERT [dbo].[Advance] ([ID_Journey], [ID_Borrower], [ID_Lender], [Advance_Money]) VALUES (3, 2, 3, 10.0000)
INSERT [dbo].[Advance] ([ID_Journey], [ID_Borrower], [ID_Lender], [Advance_Money]) VALUES (4, 1, 2, 10.0000)
INSERT [dbo].[Advance] ([ID_Journey], [ID_Borrower], [ID_Lender], [Advance_Money]) VALUES (4, 2, 3, 3.0000)
GO
SET IDENTITY_INSERT [dbo].[Expenses] ON 

INSERT [dbo].[Expenses] ([ID_Expenses], [ID_Journey], [Expenses_Money], [Expenses_Description]) VALUES (1, 4, 20.0000, N'nước uống')
INSERT [dbo].[Expenses] ([ID_Expenses], [ID_Journey], [Expenses_Money], [Expenses_Description]) VALUES (2, 4, 10.0000, N'thức ăn')
SET IDENTITY_INSERT [dbo].[Expenses] OFF
GO
SET IDENTITY_INSERT [dbo].[Journey] ON 

INSERT [dbo].[Journey] ([ID_Journey], [ID_Site], [Start_Place], [Start_Province], [Status], [StartDate], [EndDate]) VALUES (2, 1, N'ktx khu b', N'bình dương', 1, CAST(N'2020-10-20' AS Date), CAST(N'2020-10-23' AS Date))
INSERT [dbo].[Journey] ([ID_Journey], [ID_Site], [Start_Place], [Start_Province], [Status], [StartDate], [EndDate]) VALUES (3, 2, N'khu b', N'bd', 1, CAST(N'2020-12-12' AS Date), CAST(N'2020-12-20' AS Date))
INSERT [dbo].[Journey] ([ID_Journey], [ID_Site], [Start_Place], [Start_Province], [Status], [StartDate], [EndDate]) VALUES (4, 4, N'khub', N'bduong', 1, CAST(N'2020-12-10' AS Date), CAST(N'2020-12-18' AS Date))
SET IDENTITY_INSERT [dbo].[Journey] OFF
GO
INSERT [dbo].[JourneyAttendance] ([ID_Member], [ID_Journey], [Receivables_Money], [Role]) VALUES (1, 2, 200000.0000, N'Trưởng nhóm')
INSERT [dbo].[JourneyAttendance] ([ID_Member], [ID_Journey], [Receivables_Money], [Role]) VALUES (1, 3, 1000.0000, N'thành viên')
INSERT [dbo].[JourneyAttendance] ([ID_Member], [ID_Journey], [Receivables_Money], [Role]) VALUES (1, 4, 100.0000, N'thành viên')
INSERT [dbo].[JourneyAttendance] ([ID_Member], [ID_Journey], [Receivables_Money], [Role]) VALUES (2, 2, 200.0000, N'Thành viên')
INSERT [dbo].[JourneyAttendance] ([ID_Member], [ID_Journey], [Receivables_Money], [Role]) VALUES (2, 3, 200.0000, N'trưởng nhóm')
INSERT [dbo].[JourneyAttendance] ([ID_Member], [ID_Journey], [Receivables_Money], [Role]) VALUES (2, 4, 20.0000, N'thành viên')
INSERT [dbo].[JourneyAttendance] ([ID_Member], [ID_Journey], [Receivables_Money], [Role]) VALUES (3, 2, 100.0000, N'Thành viên')
INSERT [dbo].[JourneyAttendance] ([ID_Member], [ID_Journey], [Receivables_Money], [Role]) VALUES (3, 3, 1500.0000, N'thành viên')
INSERT [dbo].[JourneyAttendance] ([ID_Member], [ID_Journey], [Receivables_Money], [Role]) VALUES (3, 4, 250.0000, N'nhóm trưởng')
INSERT [dbo].[JourneyAttendance] ([ID_Member], [ID_Journey], [Receivables_Money], [Role]) VALUES (4, 2, 10000.0000, N'thành viên')
INSERT [dbo].[JourneyAttendance] ([ID_Member], [ID_Journey], [Receivables_Money], [Role]) VALUES (4, 4, 180.0000, N'thành viên')
GO
INSERT [dbo].[JourneyImage] ([ID_Journey], [Ordinal_Number], [Link_Image]) VALUES (2, 1, N'gfdsdfghj')
GO
SET IDENTITY_INSERT [dbo].[Member] ON 

INSERT [dbo].[Member] ([ID_Member], [Member_Name], [Phone_Number], [Member_Link_Avt]) VALUES (1, N'Hoàng Thị Thùy Trang', N'0347893452          ', N'yuhewhfbeqnvnqeomv')
INSERT [dbo].[Member] ([ID_Member], [Member_Name], [Phone_Number], [Member_Link_Avt]) VALUES (2, N'Trương Quốc Thuận', N'12345678            ', N'fgsgjhjk')
INSERT [dbo].[Member] ([ID_Member], [Member_Name], [Phone_Number], [Member_Link_Avt]) VALUES (3, N'Lê Nhật Tuấn', N'2435678             ', N'2345hfbcsd')
INSERT [dbo].[Member] ([ID_Member], [Member_Name], [Phone_Number], [Member_Link_Avt]) VALUES (4, N'Thùy Trang', N'1345678             ', N'dgfhjytgrfe')
SET IDENTITY_INSERT [dbo].[Member] OFF
GO
SET IDENTITY_INSERT [dbo].[Province] ON 

INSERT [dbo].[Province] ([ID_Province], [Province_Name]) VALUES (1, N'Đồng Nai')
INSERT [dbo].[Province] ([ID_Province], [Province_Name]) VALUES (2, N'Bình Dương')
INSERT [dbo].[Province] ([ID_Province], [Province_Name]) VALUES (5, N'Bình Dương')
INSERT [dbo].[Province] ([ID_Province], [Province_Name]) VALUES (6, N'22')
INSERT [dbo].[Province] ([ID_Province], [Province_Name]) VALUES (7, N'5')
INSERT [dbo].[Province] ([ID_Province], [Province_Name]) VALUES (8, N'7')
INSERT [dbo].[Province] ([ID_Province], [Province_Name]) VALUES (9, N'Bình Dươggg')
INSERT [dbo].[Province] ([ID_Province], [Province_Name]) VALUES (10, N'Bình Dươgggfhfghfgg')
INSERT [dbo].[Province] ([ID_Province], [Province_Name]) VALUES (11, N'Bình Dươgggfhfghfgg')
INSERT [dbo].[Province] ([ID_Province], [Province_Name]) VALUES (12, N'Bình Dươgggfhfghfgg')
SET IDENTITY_INSERT [dbo].[Province] OFF
GO
INSERT [dbo].[Route] ([ID_Journey], [Ordinal_Number], [Place], [Province], [Route_Description], [Route_Status]) VALUES (4, 1, N'Bãi sau', N'Vũng Tàu', N'Ngắm bình minh', 0)
GO
SET IDENTITY_INSERT [dbo].[Site] ON 

INSERT [dbo].[Site] ([ID_Site], [ID_Province], [Site_Name], [Site_Description], [Site_Link_Avt], [Site_Address]) VALUES (1, 12, N'Phong nha', N'đẹp', N'https/image', NULL)
INSERT [dbo].[Site] ([ID_Site], [ID_Province], [Site_Name], [Site_Description], [Site_Link_Avt], [Site_Address]) VALUES (2, 1, N'Hội An', N'hgdhnc', N'gchjdkns', N'hcbjdac')
INSERT [dbo].[Site] ([ID_Site], [ID_Province], [Site_Name], [Site_Description], [Site_Link_Avt], [Site_Address]) VALUES (3, 10, N'Đà Lạt', N'vfdsb', N'dvs', N'sfdba')
INSERT [dbo].[Site] ([ID_Site], [ID_Province], [Site_Name], [Site_Description], [Site_Link_Avt], [Site_Address]) VALUES (4, 12, N'Vũng Tàu', N'hkhdvbk', N'ewrgthjythrgewfqd', N'rtyukyjthgref')
SET IDENTITY_INSERT [dbo].[Site] OFF
GO
ALTER TABLE [dbo].[Advance]  WITH CHECK ADD  CONSTRAINT [FK_ADVANCE_JOURNEY] FOREIGN KEY([ID_Journey])
REFERENCES [dbo].[Journey] ([ID_Journey])
GO
ALTER TABLE [dbo].[Advance] CHECK CONSTRAINT [FK_ADVANCE_JOURNEY]
GO
ALTER TABLE [dbo].[Advance]  WITH CHECK ADD  CONSTRAINT [FK_ADVANCE_MEMBER_01] FOREIGN KEY([ID_Borrower])
REFERENCES [dbo].[Member] ([ID_Member])
GO
ALTER TABLE [dbo].[Advance] CHECK CONSTRAINT [FK_ADVANCE_MEMBER_01]
GO
ALTER TABLE [dbo].[Advance]  WITH CHECK ADD  CONSTRAINT [FK_ADVANCE_MEMBER_02] FOREIGN KEY([ID_Lender])
REFERENCES [dbo].[Member] ([ID_Member])
GO
ALTER TABLE [dbo].[Advance] CHECK CONSTRAINT [FK_ADVANCE_MEMBER_02]
GO
ALTER TABLE [dbo].[Expenses]  WITH CHECK ADD  CONSTRAINT [FK_Expenses_Journey] FOREIGN KEY([ID_Journey])
REFERENCES [dbo].[Journey] ([ID_Journey])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Expenses] CHECK CONSTRAINT [FK_Expenses_Journey]
GO
ALTER TABLE [dbo].[Journey]  WITH CHECK ADD  CONSTRAINT [FK_Journey_Site] FOREIGN KEY([ID_Site])
REFERENCES [dbo].[Site] ([ID_Site])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Journey] CHECK CONSTRAINT [FK_Journey_Site]
GO
ALTER TABLE [dbo].[JourneyAttendance]  WITH CHECK ADD  CONSTRAINT [FK_JourneyAttendance_Journey] FOREIGN KEY([ID_Journey])
REFERENCES [dbo].[Journey] ([ID_Journey])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[JourneyAttendance] CHECK CONSTRAINT [FK_JourneyAttendance_Journey]
GO
ALTER TABLE [dbo].[JourneyAttendance]  WITH CHECK ADD  CONSTRAINT [FK_JourneyAttendance_Member] FOREIGN KEY([ID_Member])
REFERENCES [dbo].[Member] ([ID_Member])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[JourneyAttendance] CHECK CONSTRAINT [FK_JourneyAttendance_Member]
GO
ALTER TABLE [dbo].[JourneyImage]  WITH CHECK ADD  CONSTRAINT [FK_JourneyImage_Journey] FOREIGN KEY([ID_Journey])
REFERENCES [dbo].[Journey] ([ID_Journey])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[JourneyImage] CHECK CONSTRAINT [FK_JourneyImage_Journey]
GO
ALTER TABLE [dbo].[Route]  WITH CHECK ADD  CONSTRAINT [FK_Route_Journey] FOREIGN KEY([ID_Journey])
REFERENCES [dbo].[Journey] ([ID_Journey])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Route] CHECK CONSTRAINT [FK_Route_Journey]
GO
ALTER TABLE [dbo].[Site]  WITH CHECK ADD  CONSTRAINT [FK_Site_Province] FOREIGN KEY([ID_Province])
REFERENCES [dbo].[Province] ([ID_Province])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Site] CHECK CONSTRAINT [FK_Site_Province]
GO
/****** Object:  StoredProcedure [dbo].[AddExpense]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddExpense] @idExpenses int, @idJourney int, @expense money, @des nvarchar(MAX)
AS
	IF(NOT EXISTS(SELECT* FROM [dbo].[Expenses] WHERE ID_Expenses = @idExpenses))
	BEGIN
		IF(EXISTS(SELECT* FROM [dbo].[Journey] WHERE ID_Journey = @idJourney))
		BEGIN
			INSERT INTO [dbo].[Expenses](ID_Expenses, ID_Journey, Expenses_Money, Expenses_Description)
			VALUES(@idExpenses, @idJourney, @expense, @des)
		END
		ELSE
			RAISERROR(N'Not exist journey', 16, 2)
	END
	ELSE
		RAISERROR(N'Invalid', 16,1 )
GO
/****** Object:  StoredProcedure [dbo].[AddJourney]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddJourney] @idSite int, @startPlace nvarchar(200), @startProvince nvarchar(200), @status int, @startDate date, @endDate date
AS
	IF(EXISTS(SELECT* FROM [dbo].[Site] WHERE ID_Site = @idSite))
	BEGIN
		IF(@status = -1 OR @status = 0 OR @status = 1)
		BEGIN
			INSERT INTO [dbo].[Journey] (ID_Site, Start_Place, Start_Province, Status, StartDate, EndDate)
			VALUES (@idSite, @startPlace, @startProvince, @status, @startDate, @endDate)
		END
		ELSE
			RAISERROR(N'Status is invalid, must be -1 or 0 or 1',16,3)
	END
		ELSE
			RAISERROR(N'Not exist site', 16, 1)
GO
/****** Object:  StoredProcedure [dbo].[AddJourneyAttendance]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddJourneyAttendance] @idMember int, @idJourney int, @Receivable money, @role nvarchar(50)
AS
	IF(EXISTS(SELECT* FROM [dbo].[Journey] WHERE ID_Journey = @idJourney))
	BEGIN
		IF(EXISTS(SELECT* FROM [dbo].[Member] WHERE ID_Member = @idMember))
		BEGIN
			IF(NOT EXISTS(SELECT* FROM [dbo].[JourneyAttendance] WHERE ID_Member = @idMember AND ID_Journey = @idJourney))
				INSERT INTO [dbo].[JourneyAttendance](ID_Member, ID_Journey, Receivables_Money, Role)
				VALUES (@idMember, @idJourney, @Receivable, @role)
			ELSE 
				RAISERROR(N'Invalidddd', 16,3)
		END
		ELSE
			RAISERROR(N'Not exist Member', 16, 2)
	END
	ELSE
		RAISERROR(N'Not exist Journey', 16, 1)
GO
/****** Object:  StoredProcedure [dbo].[AddJourneyImages]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddJourneyImages] @idJourney int, @oridnalNum int, @linkImage nvarchar(MAX)
AS
	IF(EXISTS(SELECT* FROM [dbo].[Journey] WHERE ID_Journey = @idJourney))
	BEGIN
		IF(NOT EXISTS(SELECT* FROM [dbo].[JourneyImage] WHERE ID_Journey = @idJourney AND Ordinal_Number = @oridnalNum))
			INSERT INTO [dbo].[JourneyImage] (ID_Journey, Ordinal_Number, Link_Image)
			VALUES (@idJourney, @oridnalNum, @linkImage)
		ELSE
			RAISERROR(N'Invalid', 16, 2)
	END
	ELSE
		RAISERROR(N'Not exists this Journey', 16, 1)
GO
/****** Object:  StoredProcedure [dbo].[AddMember]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--sp AddMember
CREATE PROCEDURE [dbo].[AddMember] @memberName nvarchar(200), @phoneNumber nchar(20), @memberLinkAvt nvarchar(MAX)
AS
		INSERT INTO [dbo].[Member](Member_Name, Phone_Number, Member_Link_Avt)
		VALUES (@memberName, @phoneNumber, @memberLinkAvt)

GO
/****** Object:  StoredProcedure [dbo].[AddRoute]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddRoute] @idJourney int, @ordinalNumber int, @place nvarchar(200), @province nvarchar(200), @routeDescription nvarchar(MAX), @routeStatus int
AS
	IF(EXISTS(SELECT* FROM [dbo].[Journey] WHERE ID_Journey = @idJourney))
	BEGIN
		IF(NOT EXISTS(SELECT* FROM  [dbo].[Route] WHERE ID_Journey = @idJourney AND Ordinal_Number = @ordinalNumber))
		BEGIN
			INSERT INTO [dbo].[Route] (ID_Journey, Ordinal_Number, Place, Province, Route_Description, Route_Status)
			VALUES (@idJourney, @ordinalNumber, @place, @province, @routeDescription, @routeStatus)
		END
		ELSE
			RAISERROR (N'Rout existed in this Journey', 16, 2)
	END
	ELSE
		RAISERROR (N'Not exist journey', 16, 1)
GO
/****** Object:  StoredProcedure [dbo].[AddSite]    Script Date: 12/15/2020 4:55:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddSite] @idProvince int, @siteName nvarchar(200), @siteDescription nvarchar(MAX), @siteLinkAvt nvarchar(MAX), @siteAddress nvarchar(200)
AS
	IF(EXISTS(SELECT* FROM [dbo].[Province] WHERE ID_Province = @idProvince))
	BEGIN
		INSERT INTO [dbo].[Site] (ID_Province, Site_Name, Site_Description, Site_Link_Avt, Site_Address)
		VALUES (@idProvince, @siteName, @siteDescription, @siteLinkAvt, @siteAddress)
	END
	ELSE
		RAISERROR (N'Not exist Province', 16, 1)
GO
USE [master]
GO
ALTER DATABASE [WeSplit] SET  READ_WRITE 
GO

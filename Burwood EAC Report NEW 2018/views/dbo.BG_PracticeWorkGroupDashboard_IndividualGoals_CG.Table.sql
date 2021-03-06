USE [Changepoint]
GO
/****** Object:  Table [dbo].[BG_PracticeWorkGroupDashboard_IndividualGoals_CG]    Script Date: 11/8/2019 5:01:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BG_PracticeWorkGroupDashboard_IndividualGoals_CG](
	[Resource] [nvarchar](255) NULL,
	[ResourceId] [uniqueidentifier] NULL,
	[MonthName] [nvarchar](30) NULL,
	[Month] [int] NULL,
	[Year] [int] NULL,
	[Budget] [numeric](11, 2) NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[IndividualYearlyGoal] [decimal](10, 2) NULL,
	[IndividualMonthlyGoal] [decimal](10, 2) NULL,
	[DaysInMonth] [int] NULL,
	[IndividualDailyGoal] [decimal](10, 2) NULL,
	[Utilization] [decimal](10, 2) NULL,
	[IndividualQuarterlyGoal] [decimal](10, 2) NULL,
	[Quarter] [int] NULL
) ON [PRIMARY]
GO

USE [Changepoint]
GO
/****** Object:  View [dbo].[BG_WeeklyResourceLoading_Report_PB]    Script Date: 10/17/2019 3:46:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[BG_WeeklyResourceLoading_Report_PB] as 
select 
	SUBSTRING(l.Region, 1,2) as RegionShortName,
	l.Region,
	l.Practice,
	l.Workgroup,
	l.Resource,
	l.ResourceId,
	l.Manager,
	l.Manager_ResourceId,
	l.Title,
	l.PayrollGroup,
	l.EmployeeType,
	case when Billable=1 then 'Billable'
		 when Billable=0 then 'Non-Billable'
	end as Billable,
	l.YTDUtilization,
	l.QTDUtilization,
	l.[Contribution%]
	,l.[Period0]
      ,l.[StartDate0]
      ,l.[CurrentWeek]
      ,l.[Period1]
      ,l.[StartDate1]
      ,l.[Week1]
      ,l.[Period2]
      ,l.[StartDate2]
      ,l.[Week2]
      ,l.[Period3]
      ,l.[StartDate3]
      ,l.[Week3]
      ,l.[Period4]
      ,l.[StartDate4]
      ,l.[Week4]
      ,l.[Period5]
      ,l.[StartDate5]
      ,l.[Week5]
      ,l.[Period6]
      ,l.[StartDate6]
      ,l.[Week6]
      ,l.[Period7]
      ,l.[StartDate7]
      ,l.[Week7]
      ,l.[Period8]
      ,l.[StartDate8]
      ,l.[Week8]
      ,l.[Period9]
      ,l.[StartDate9]
      ,l.[Week9]
      ,l.[Period10]
      ,l.[StartDate10]
      ,l.[Week10]
      ,l.[Period11]
      ,l.[StartDate11]
      ,l.[Week11]
      ,l.[Period12]
      ,l.[StartDate12]
      ,l.[Week12]
      ,l.[Period13]
      ,l.[StartDate13]
      ,l.[Week13]
      ,l.[Period14]
      ,l.[StartDate14]
      ,l.[Week14]
	  ,q.Area
	  ,q.Category
	  ,q.Skill
	  ,q.Rating
from 
	BG_WeeklyResourceLoading_CG l with (nolock)
		left outer join
	BG_ResourceQualifications_CG q with (nolock) on l.ResourceId=q.ResourceId and (q.Rating<>'0' or q.Rating is NULL)
GO

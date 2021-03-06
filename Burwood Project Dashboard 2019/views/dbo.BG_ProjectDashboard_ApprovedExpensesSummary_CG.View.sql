USE [Changepoint]
GO
/****** Object:  View [dbo].[BG_ProjectDashboard_ApprovedExpensesSummary_CG]    Script Date: 9/30/2019 5:00:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


--select * from [BG_ProjectDashboard_ApprovedExpensesSummary_CG] where EngagementStatus='W'





create view [dbo].[BG_ProjectDashboard_ApprovedExpensesSummary_CG] AS 
select
	e.Name as Engagement,
	e.EngagementStatus,
	e.EngagementId,
	p.Name as Project,
	p.ProjectStatus,
	p.ProjectId,
	count(*) as UnapprovedExpenses,
	sum(ex.Quantity*ex.UnitPrice) as TotalExpense
from 
	Expense ex with (nolock)
		join
	Project p with (nolock) on ex.ProjectId=p.ProjectId
		join
	Engagement e with (nolock) on p.EngagementId=e.EngagementId
where
	ApprovalStatus='A'
group by 
	e.Name, 
	e.EngagementStatus,
	e.EngagementId, 
	p.Name, 
	p.ProjectStatus,
	p.ProjectId

GO

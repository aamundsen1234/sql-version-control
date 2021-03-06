USE [Changepoint]
GO
/****** Object:  View [dbo].[BG_ProjectDashboard_EngagementProjectFILTER_CG]    Script Date: 11/8/2019 5:01:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[BG_ProjectDashboard_EngagementProjectFILTER_CG] as 
select
	rg.Description as Region,
	c.Name as Customer,
	e.Name as Engagement,
	es.Description as EngagementStatus,
	e.EngagementStatus as EngagementStatusCode,
	bt.Description as BillingType,
	p.Name as Project,
	ps.Description as ProjectStatus,
	p.ProjectStatus as ProjectStatusCode,
	pm.ProjectManager,
	ae.Name as AccountExecutive,
	e.EngagementId,
	p.ProjectId
from	
	Engagement e with (nolock)
		join
	Project p with (nolock) on e.EngagementId=p.EngagementId
		join
	BillingOffice rg with (nolock) on e.BillingOfficeId=rg.BillingOfficeId
		join
	Customer c with (nolock) on e.CustomerId=c.CustomerId
		join
	Resources ae with (nolock) on e.InternalContactId=ae.ResourceId
		join
	BG_ProjectManager_CG pm with (nolock) on p.ProjectId=pm.ProjectId
		join
	dbo.BillingType bt with (nolock) on e.BillingType=bt.Code
		join
	ProjectStatus ps with (nolock) on p.ProjectStatus=ps.Code
		join
	EngagementStatus es with (nolock) on e.EngagementStatus=es.Code
where
	e.Deleted=0
	and p.Deleted=0
	and e.Billable=1

GO

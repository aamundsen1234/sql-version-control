USE [Changepoint]
GO
/****** Object:  View [dbo].[BG_ProjectDashboard_FixedFeeSchedule_CG]    Script Date: 10/14/2019 11:47:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO







--select distinct Deliverable from [BG_ProjectDashboard_FixedFeeSchedule_CG] where Deliverable like '%master%' or Deliverable like 'Masteer%'


CREATE VIEW [dbo].[BG_ProjectDashboard_FixedFeeSchedule_CG] AS 
SELECT 
	f.EngagementID,
	f.FixedFeeID,
	f.Billed,
	f.DoNotInvoice,
	--distinct
	f.Deliverable,
    f.BillingDate,
    f.BillingAmount,
	f.InvoicedAmount,
    f.TotalHours,
	f.RevPrev,
	f.RevPrevDate,
	f.RevRec,
	f.RevRecDate,
	f.RevAdj,
	p.Name as Project,
	p.ProjectId,
	case when (f.DoNotInvoice=1 and (Deliverable like '%FF Schedule%' 
		or Deliverable like 'Master%' 
		or Deliverable like '%fixed Fee schedule%' 
		or Deliverable like '%master ff%' 
		or Deliverable like '%schedule%'
		or Deliverable like 'MASTEER%'
		or Deliverable like 'MASTER FIXED FEE%'
		or Deliverable like 'Master FF%'))
		 then 1
		 else 2
	end as FFSort,
	f.CreatedOn
FROM 
	dbo.FixedFeeSchedule f with (nolock)
		join
	dbo.Project p with (nolock) on f.EngagementID=p.EngagementID
	--	left outer join
	--BG_ProjectManager_CG pm with (nolock) on p.ProjectId=pm.ProjectId
where 
	f.Deleted=0
	and p.Deleted=0


GO

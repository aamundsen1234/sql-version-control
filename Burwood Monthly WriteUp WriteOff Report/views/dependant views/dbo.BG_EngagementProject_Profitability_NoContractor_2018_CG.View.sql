USE [Changepoint2018]
GO
/****** Object:  View [dbo].[BG_EngagementProject_Profitability_NoContractor_2018_CG]    Script Date: 10/11/2019 1:49:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create VIEW [dbo].[BG_EngagementProject_Profitability_NoContractor_2018_CG] AS
SELECT 
	'Burwood Group' as Company,
	case when b.Description in ('PE-Peoria', 'QC-Quad Cities', 'SL-St. Louis') 
		 then 'BL-Heartland Region' 
		 else b.Description 
	end as Region,
	isnull(cc.Name, 'No Practice Assigned') as Practice,
	c.Name as Customer,
	tw.EngagementId, 
	e.OpportunityId,
	e.Name as Engagement,
	datepart(year, e.CreatedOn) CreatedYear,
	pgm.Project,
	pgm.ProjectId,
	pgm.ProjectManager,
	es.Description as EngagementStatus, 
	cast(d.UDFDate as date) as CloseDate,
	datepart(year, d.UDFDate) as CloseYear,
	datepart(month, d.UDFDate) as CloseMonth#,
	datename(month, d.UDFDate) as CloseMonthName,
	tw.Resource,
	--ra.Description as AdjustmentReason,
	tw.AdjustmentReasonCode,
	tw.ApprovalStatus,
	tw.AdjustmentTimeStatus,
	--and (tw.Billable=1 and tw.ApprovalStatus='A' and(tw.AdjustmentTimeStatus <> 'A' OR tw.AdjustmentTimeStatus is null))
	tw.RegularHours+tw.OvertimeHours as RegularHours,
	(tw.RegularHours+tw.OvertimeHours)*tw.HourlyCostRate as Cost,
	coalesce(tw.RateTimesHours,0) as RateTimesHours,
	--Potential Fees
	case when tw.AdjustmentReasonCode IS NULL and coalesce(tw.RateTimesHours,0)<>0 and coalesce(tw.RevRec,0)<>0 and round(coalesce(tw.RateTimesHours,0),2)<> coalesce(tw.RevRec,0)
		 then tw.RevRec 
		 else round(tw.RateTimesHours,2)
	end as PotentialFees,
	coalesce(tw.RevRec,0) as RevenueRecognized,
	case when tw.AdjustmentReasonCode IS NULL --or tw.AdjustmentReasonCode = 'Adjustment to Close a Project'
		 then (case when coalesce(tw.RateTimesHours,0)<>0 and coalesce(tw.RevRec,0)<>0 and round(coalesce(tw.RateTimesHours,0),2)<> coalesce(tw.RevRec,0)
					then coalesce(tw.RevRec,0)
					else round(tw.RateTimesHours,2)
				end) 
		- (coalesce(tw.RevRec,0)) 
		 else 0
	end AS FixedFeeOverage, 
	coalesce(tw.RateTimesHours,0) - coalesce(tw.RevRec,0) as OrgFixedFeeOverage,
	case when tw.AdjustmentReasonCode IS NULL
		 then coalesce(tw.RegularHours,  0) + coalesce(tw.OvertimeHours, 0) * coalesce(tw.HourlyCostRate,0) 
		 else 0
	end as InternalCost, 
	coalesce(tw.RegularHours,  0) + coalesce(tw.OvertimeHours, 0) * coalesce(tw.HourlyCostRate,0) as OrgInternalCost,
	case when tw.AdjustmentReasonCode IS NULL
		 then coalesce(tw.RevRec,0) + coalesce(tw.AmountWrittenOff,0) 
		 else 0
	end as BillingAmount,
	coalesce(tw.RevRec,0) + coalesce(tw.AmountWrittenOff,0)  as OrgBillingAmount,
	--Adjustment to Close a Project
	case when tw.AdjustmentReasonCode='E41156CF-35B1-49E4-868C-C1F4E8121B5A'
		 then tw.RevRec
		 else 0
	end as 'Adjustment to Close a Project',
	case when tw.AdjustmentReasonCode='5C8E8318-9CC2-4C51-BE7A-A3482AE82355'
		 then tw.RevRec
		 else 0
	end as 'Expense Adjustment',
	case when tw.AdjustmentReasonCode='F8C23509-9294-4D55-A310-4921458A56E4'
		 then tw.RevRec
		 else 0
	end as 'Contractor Pass-Through',
	case when tw.AdjustmentReasonCode='D4C4B9A6-2699-415B-BB28-5579E78E428B'
		 then tw.RevRec
		 else 0
	end as 'Contractor Margin'

	--coalesce((select sum(r.RevenueAmount) from RevenueDetail r with (nolock) 
	--	where tw.EngagementId=r.EngagementId and r.ReasonCode in ('E41156CF-35B1-49E4-868C-C1F4E8121B5A')
	--	group by r.EngagementID),0)
	--as 'Adjustment to Close a Project1',--'Write-Up Adjustment',
	--isnull((select sum(r.RevenueAmount) from RevenueDetail r with (nolock) 
	--	where tw.EngagementId=r.EngagementId and r.ReasonCode in ('5C8E8318-9CC2-4C51-BE7A-A3482AE82355')
	--	group by r.EngagementID),0)
	--as 'Expense Adjustment1',
	--isnull((select sum(r.RevenueAmount) from RevenueDetail r with (nolock) 
	--	where tw.EngagementId=r.EngagementId and r.ReasonCode in ('F8C23509-9294-4D55-A310-4921458A56E4')
	--	group by r.EngagementID),0)
	--as 'Contractor Pass-Through1',
	--isnull((select sum(r.RevenueAmount) from RevenueDetail r with (nolock) 
	--	where tw.EngagementId=r.EngagementId and r.ReasonCode in ('D4C4B9A6-2699-415B-BB28-5579E78E428B')
	--	group by r.EngagementID),0)
	--as 'Contractor Margin1'
FROM 
	BG_Time_and_Writeoff_with_Effective_BillingRate_CG  tw with (nolock)  --BG_Time_and_WriteOff_VIEW
	--	left outer join
	--RevRecAdjCodes ra with (nolock) on tw.AdjustmentReasonCode=ra.RRARCID
		INNER JOIN 
	Customer c with (nolock) ON tw.CustomerId=c.CustomerId 
		INNER JOIN 
	Engagement e with (nolock) on tw.EngagementId=e.EngagementId
		join
	EngagementStatus es with (nolock) on e.EngagementStatus=es.Code
		left outer join
	BG_ProjectManager_CG pgm with (nolock) on tw.EngagementId=pgm.EngagementId
	--(select p.Name as Project, p.EngagementId, pm.Name as ProjectManager, p.ProjectId 
	-- from	Project p with (nolock) 
	--			left outer join 
	--		dbo.managemember mm with (nolock) on p.ProjectId=mm.ProjectId and p.EngagementId=mm.EngagementId
	--			left outer join 
	--		Resources pm with (nolock) on mm.ResourceId=pm.ResourceId) as pgm on tw.EngagementId=pgm.EngagementId
		left outer JOIN 
	CostCenters cc with (nolock) on e.CostCenterId=cc.CostCenter
		inner join
	BillingOffice AS b  WITH (NOLOCK) ON b.BillingOfficeId = e.BillingOfficeId
	--	left outer join 
	--Resources r with (nolock) on tw.ResourceId=r.ResourceId 
		left outer join 
	UDFDate d with (nolock) on e.EngagementId=d.EntityId and d.ItemName='EngagementText1'
		left outer join 
	EngRequestBillingRule er with (nolock) on tw.EngagementId=er.EngagementId and er.RequestType='TM'
WHERE 
	e.Name IS NOT NULL 
	AND tw.ProjectCostCenter IS NOT NULL
	and ((tw.Billable=1 and tw.ApprovalStatus='A' and(tw.AdjustmentTimeStatus <> 'A' OR tw.AdjustmentTimeStatus is null)) or tw.Resource='* Adjustment, *')
	and e.EngagementStatus='F'
	and e.Deleted=0
	and b.Description not in ('LA-LATAM Region', 'BG-Burwood Corporate')
	and er.EngRequestBillingRuleId is NULL
	and e.Name = 'Wake Forest Baptist Health - Access Center Refresh'
--group by 
--	tw.Billable,
--	b.Description, 
--	cc.Name,
--	c.Name, 
--	tw.EngagementId,
--	e.OpportunityId,
--	e.Name,
--	datepart(year, e.CreatedOn),
--	pgm.Project,
--	pgm.ProjectId,
--	pgm.ProjectManager,
--	e.EngagementStatus,
--	d.UDFDate




GO

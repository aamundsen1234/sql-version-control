USE [Changepoint2018]
GO
/****** Object:  View [dbo].[BG_EngagementProject_Profitability_2018_CG]    Script Date: 10/11/2019 1:49:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--truncate table BG_EngagementProject_Profitability_2018_Table_CG
--insert into BG_EngagementProject_Profitability_2018_Table_CG select * from BG_EngagementProject_Profitability_2018_CG


CREATE VIEW [dbo].[BG_EngagementProject_Profitability_2018_CG] AS
with a as (
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
	--pgm.Project,
	--pgm.ProjectId,
	--pgm.ProjectManager,
	(select top 1 ProjectManager from BG_ProjectManager_CG pm with (nolock) where tw.EngagementId=pm.EngagementId) as ProjectManager,
	(select count(p1.Name) from Project p1 with (nolock) where p1.EngagementId=tw.EngagementId and p1.Deleted=0) as NumberProjects,
	es.Description as EngagementStatus, 
	coalesce(ec.Description, 'Undefined') as ProjectType,
	cast(d.UDFDate as date) as CloseDate,
	datepart(year, d.UDFDate) as CloseYear,
	datepart(month, d.UDFDate) as CloseMonth#,
	datename(month, d.UDFDate) as CloseMonthName,
	tw.Resource,
	tw.AdjustmentReasonCode,
	tw.ApprovalStatus,
	tw.AdjustmentTimeStatus,

	--Billable Hours

	tw.RegularHours+tw.OvertimeHours as RegularHours,

	--Rate Times Hours

	coalesce(tw.RateTimesHours,0) as RateTimesHours,

	--Potential Fees
	
	case when tw.AdjustmentReasonCode is not null
		 then round(0,2)
		 when tw.AdjustmentReasonCode IS NULL 
		  and coalesce(tw.RevRec,0)<>0 
		  and round(coalesce(tw.RateTimesHours,0),2)<> coalesce(tw.RevRec,0)
		 then coalesce(tw.RevRec,0)
		 else round(coalesce(tw.RateTimesHours,0),2)
	end as PotentialFees,
	--case when tw.AdjustmentReasonCode IS NULL 
		--and coalesce(tw.RateTimesHours,0)<>0 
		--and coalesce(tw.RevRec,0)<>0 
		--and round(coalesce(tw.RateTimesHours,0),2)<> coalesce(tw.RevRec,0)
	--	 then tw.RevRec 
	--	 else round(tw.RateTimesHours,2)
	--end as PotentialFees,
	
	--Revenue Recognized
	
	coalesce(tw.RevRec,0) as RevenueRecognized,

	--Fixed Fee Overage

	case when tw.AdjustmentReasonCode IS NULL --or tw.AdjustmentReasonCode = 'Adjustment to Close a Project'
		 then (case when tw.AdjustmentReasonCode is not null
					then round(0,2)
					when tw.AdjustmentReasonCode IS NULL 
						and coalesce(tw.RevRec,0)<>0 
						and round(coalesce(tw.RateTimesHours,0),2)<> coalesce(tw.RevRec,0)
					then coalesce(tw.RevRec,0)
					else round(coalesce(tw.RateTimesHours,0),2)
				end) 
		- (coalesce(tw.RevRec,0)) 
		 else 0
	end AS FixedFeeOverage, 
	--coalesce(tw.RateTimesHours,0) - coalesce(tw.RevRec,0) as OrgFixedFeeOverage,

	--Internal Cost

	case when tw.AdjustmentReasonCode IS NULL
		 then (coalesce(tw.RegularHours,  0) + coalesce(tw.OvertimeHours, 0)) * coalesce(tw.HourlyCostRate,0) 
		 else 0
	end as InternalCost, 

	-- Internal Billing Amount (time worked)

	case when tw.AdjustmentReasonCode IS NULL --or tw.AdjustmentReasonCode in ('Contractor Margin', 'Other Adjustment', 'Adjustment to Close a Project')
		 then coalesce(tw.RevRec,0) + coalesce(tw.AmountWrittenOff,0) 
		 else 0
	end as InternalBillingAmount,

	-- All Adjustments

	case when tw.AdjustmentReasonCode IS not NULL --or tw.AdjustmentReasonCode in ('Contractor Margin', 'Other Adjustment', 'Adjustment to Close a Project')
		 then coalesce(tw.RevRec,0)
		 else 0
	end as TotalAdjustments,

	-- All Revenue - Time worked and Adjustments
	coalesce(tw.RevRec,0) + coalesce(tw.AmountWrittenOff,0)  as AdjustedBillingAmount,

	--Adjustment to Close a Project

	case when tw.AdjustmentReasonCode='Adjustment to Close a Project'
		 then coalesce(tw.RevRec,0)
		 else 0
	end as 'AdjustmenttoCloseaProject',

	--Expense Adjustments

	case when tw.AdjustmentReasonCode='Expense Recognition'
		 then coalesce(tw.RevRec,0)
		 else 0
	end as 'ExpenseAdjustment',

	--Contractor Pass-Through Adjustments

	case when tw.AdjustmentReasonCode='Contractor Pass-through'
		 then coalesce(tw.RevRec,0)
		 else 0
	end as 'ContractorPassThroughAdjustment',

	--Contractor Margin Adjustments

	case when tw.AdjustmentReasonCode='Contractor Margin'
		 then coalesce(tw.RevRec,0)
		 else 0
	end as 'ContractorMarginAdjustment',

	-- Other Adjustments

	case when tw.AdjustmentReasonCode='Other Adjustment'
		 then coalesce(tw.RevRec,0)
		 else 0
	end as 'OtherAdjustment'

	--select distinct tw.AdjustmentReasonCode
FROM 
	BG_Time_and_Writeoff_with_Effective_BillingRate_CG  tw with (nolock)
		INNER JOIN 
	Customer c with (nolock) ON tw.CustomerId=c.CustomerId 
		INNER JOIN 
	Engagement e with (nolock) on tw.EngagementId=e.EngagementId
		join
	EngagementStatus es with (nolock) on e.EngagementStatus=es.Code
	--	left outer join
	--BG_ProjectManager_CG pgm with (nolock) on tw.EngagementId=pgm.EngagementId
		left outer JOIN 
	CostCenters cc with (nolock) on e.CostCenterId=cc.CostCenter
		inner join
	BillingOffice AS b  WITH (NOLOCK) ON b.BillingOfficeId = e.BillingOfficeId
		INNER JOIN 
	Resources r with (nolock) on tw.ResourceId=r.ResourceId 
		left outer join 
	UDFDate d with (nolock) on e.EngagementId=d.EntityId and d.ItemName='EngagementText1'
		left outer join 
	EngRequestBillingRule er with (nolock) on tw.EngagementId=er.EngagementId and er.RequestType='TM'
		left outer join
	UDFCode u with (nolock) on tw.EngagementId=u.EntityId and u.ItemName='EngagementCode4'
		left outer join
	EngagementCodeDetail ec with (nolock) on u.UDFCode=ec.EngagementCodeDetailId
WHERE 
	e.Name IS NOT NULL 
	and e.Deleted=0
	and e.EngagementStatus='F'
	and e.Billable=1
	and er.EngRequestBillingRuleId is NULL
	and tw.Billable=1
	and tw.EngagementId not in ('9F24B4FB-212C-4359-87E5-DA52BB6F61F6', '4B009190-F3AC-41FA-9474-FF3A050001BB')
	and (tw.ApprovalStatus='A' or tw.Resource='* Adjustment, *')
	and(tw.AdjustmentTimeStatus <> 'A' OR tw.AdjustmentTimeStatus is null)
	and b.Description not in ('LA-LATAM Region', 'BG-Burwood Corporate')
	AND tw.ProjectCostCenter IS NOT NULL
	--deleted 10242018 - and ((tw.Billable=1 and tw.ApprovalStatus='A' and(tw.AdjustmentTimeStatus <> 'A' OR tw.AdjustmentTimeStatus is null)) or tw.Resource='* Adjustment, *')
	--and (tw.Billable=1 and tw.ApprovalStatus='A' and(tw.AdjustmentTimeStatus <> 'A' OR tw.AdjustmentTimeStatus is null))
	--and cast(d.UDFDate as date)>='20180101'
	--and cast(d.UDFDate as date)<='20181025'
	--and tw.AdjustmentReasonCode is not null
  
	
	


)
--select
--	*
--from
--	a
--where
--	BillingAmount<>OrgBillingAmount

select
	a.Company,
	a.Region,
	a.Practice,
	a.Customer,
	a.EngagementId,
	a.OpportunityId,
	a.Engagement,
	a.ProjectManager,
	a.ProjectType,
	a.CreatedYear,
	a.EngagementStatus,
	a.CloseDate,
	max(NumberProjects) as CountProjects,
	sum(a.RegularHours) as BillableHours,
	sum(a.RateTimesHours) as RateTimesHours,
	-sum(a.PotentialFees) as PotentialFees,
	sum(a.RevenueRecognized) as RevenueRecognized,
	sum(a.FixedFeeOverage) as FixedFeeOverage,
	sum(a.InternalCost) as InternalCost,
	sum(a.InternalBillingAmount) as InternalBillingAmount,
	sum(a.TotalAdjustments) as TotalAdjustments,
	sum(a.AdjustedBillingAmount) as AdjustedBillingAmount,
	sum(a.AdjustmenttoCloseaProject) as [Adjustment to Close a Project],
	sum(a.[ExpenseAdjustment]) as [Expense Adjustment],
	sum(a.ContractorPassThroughAdjustment) as [Contractor Pass-Through],
	sum(a.ContractorMarginAdjustment) as [Contractor Margin],
	sum(a.OtherAdjustment) as [Other Adjustment]
from
	a
group by 
	a.Company,
	a.Region,
	a.Practice,
	a.Customer,
	a.EngagementId,
	a.OpportunityId,
	a.Engagement,
	a.ProjectManager,
	a.ProjectType,
	a.CreatedYear,
	a.EngagementStatus,
	a.CloseDate


GO

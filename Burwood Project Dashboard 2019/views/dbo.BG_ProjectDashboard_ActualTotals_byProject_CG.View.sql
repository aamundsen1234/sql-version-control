USE [Changepoint]
GO
/****** Object:  View [dbo].[BG_ProjectDashboard_ActualTotals_byProject_CG]    Script Date: 9/30/2019 5:00:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













--select * from 'baptist healthcare citrix staff aug'

--select * from [BG_ProjectDashboard_ActualTotals_byEngagement_CG]  where EngagementStatus='W' order by Engagement


CREATE view [dbo].[BG_ProjectDashboard_ActualTotals_byProject_CG] as 
with a as
(
select
	tw.Engagement,
	tw.EngagementId,
	tw.ProjectId,
	e.ContractAmount,
	e.EngagementStatus,
	e.BillingType,
	(select sum(AdjustmentAmount) from BG_ProjectDashboard_AdjustmentsAllTotal_CG(tw.EngagementId)) as Adjustments,
	sum(tw.RegularHours+tw.OvertimeHours) as BillableHours,
	sum(case when tw.AdjustmentReasonCode is not null
		 then round(0,2)

		 when tw.AdjustmentReasonCode IS NULL 
		  and coalesce(tw.RevRec,0)<>0 
		  and round(coalesce(tw.RateTimesHours,0),2)<> coalesce(tw.RevRec,0)
		 then case when coalesce(tw.AdjustmentTimeStatus,'')='P' and tw.RegularHours<>0
		 then (coalesce(tw.RegularHours,0)+coalesce(tw.OvertimeHours,0))*tw.RevRate
		 when coalesce(tw.AdjustmentTimeStatus,'')='P' and tw.RegularHours=0
		 then (coalesce(tw.RegularHours,0)+coalesce(tw.OvertimeHours,0))*tw.RevRate
		 else tw.RevRec end
		 else round(coalesce(tw.RateTimesHours,0),2)
	end) as PotentialFees,
	sum(round(coalesce(tw.RateTimesHours,0),2)) as RateTimesHours,
	sum(case when coalesce(tw.AdjustmentTimeStatus,'')='P' and tw.RegularHours<>0
		 then (coalesce(tw.RegularHours,0)+coalesce(tw.OvertimeHours,0))*tw.RevRate
		 when coalesce(tw.AdjustmentTimeStatus,'')='P' and tw.RegularHours=0
		 then (coalesce(tw.RegularHours,0)+coalesce(tw.OvertimeHours,0))*tw.RevRate
		 else tw.RevRec end) as RevenueRecognized,
	sum((tw.RegularHours+tw.OvertimeHours)*tw.HourlyCostRate) as ActualCost,
	sum(case when tw.AdjustmentReasonCode IS NULL
		 then (coalesce(tw.RegularHours,  0) + coalesce(tw.OvertimeHours, 0)) * coalesce(tw.HourlyCostRate,0) 
		 else 0
	end) as newActualCost,
	(select sum(f.ForecastRevenue) from BG_ProjectDashboard_ForecastSummary_CG f where tw.EngagementId=f.EngagementId and tw.ProjectId=f.ProjectId) as ForecastRevenue
from
	BG_Time_and_Writeoff_with_Effective_BillingRate_CG tw with (nolock)
		join
	(select EngagementId, ContractAmount, EngagementStatus, BillingType from Engagement with (nolock)) e on tw.EngagementId=e.EngagementId
	--	left outer join
	--(select EngagementId, ProjectId, Name as Project from Project with (nolock)) p on tw.EngagementId=p.EngagementId and tw.ProjectId=p.ProjectId
		left outer join
	dbo.DS_AllResourceRate rr WITH (NOLOCK) on tw.ResourceId=rr.ResourceId and rr.EffectiveDate=(select EffectiveDate from dbo.DS_CurrentEffectiveDate where rr.ResourceId=dbo.DS_CurrentEffectiveDate.ResourceId)
where
	tw.Billable=1
	and coalesce(tw.ApprovalStatus, '')<>'R'
	and (tw.ADJUSTMENTTIMESTATUS not in ('A') OR tw.ADJUSTMENTTIMESTATUS IS NULL)
	--and tw.ProjectId='080DAAA9-4800-44B9-B6CC-78872C0F1432'
	--and(tw.AdjustmentTimeStatus not in ('A', 'P') OR tw.AdjustmentTimeStatus is null)
	--and tw.EngagementId='04820470-1AA6-499D-B5F4-50899237D988'
	--and tw.EngagementId='1735A71E-3ED4-4B62-9DBB-9004CBFEB883'--'164812D4-24D5-4DC2-94D8-835CFB5E6490'
group by
	tw.Engagement,
	tw.EngagementId,
	e.ContractAmount,
	e.EngagementStatus,
	e.BillingType,
	--p.Project,
	tw.ProjectId
)
select
	Engagement,
	EngagementId,
	--Project,
	ProjectId,
	ContractAmount,
	EngagementStatus,
	BillingType,
	sum(BillableHours) as BillableHours,
	case when BillingType='H' 
		 then sum(round(RateTimesHours,2))
		 else sum(round(PotentialFees,2)) 
	end as PotentialFees,
	sum(round(PotentialFees,2)) as PotentialFees2,
	sum(round(RateTimesHours,2)) as RateTimesHours,
	sum(RevenueRecognized) as RevenueRecognized,
	sum(ActualCost) as ActualCost,
	sum(NewActualCost) as NewActualCost,
	max(coalesce(Adjustments,0)) as Adjustments,
	max(coalesce(ForecastRevenue,0)) as ForecastRevenue,
	max(ContractAmount)-(case when BillingType='H' then sum(round(RateTimesHours,2)) else sum(round(PotentialFees,2)) end)+max(coalesce(Adjustments,0))-max(coalesce(ForecastRevenue,0)) as WriteUpWriteOff
	
	--max(ContractAmount)-sum(PotentialFees)+max(coalesce(Adjustments,0))-max(coalesce(ForecastRevenue,0)) as WriteUpWriteOff2
from
	a
group by
	Engagement,
	EngagementId,
	--Project,
	ProjectId,
	ContractAmount,
	EngagementStatus,
	BillingTYpe



	--projectinfo 'True Value Novell File Migration'

GO

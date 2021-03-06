USE [Changepoint2018]
GO
/****** Object:  View [dbo].[BG_EngagementProfitability_2018_CG]    Script Date: 10/11/2019 1:49:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[BG_EngagementProfitability_2018_CG] as 
select
	Company,
	Region,
	Practice,
	Engagement,
	ProjectManager,
	ProjectType,
	CloseDate,
	sum(BillableHours) as BillableHours,
	--sum(Cost) as Cost,
	-sum(FixedFeeOverage) as WriteUpWriteOff,
	sum(InternalCost) as InternalCost,
	sum(OrgInternalCost) as OrgInternalCost,
	sum(BillingAmount) as BillingAmount,
	sum(OrgBillingAmount) as OrgBillingAmount,
	sum([Adjustment to Close a Project]) as WriteUpAdjustment,
	sum([Expense Adjustment]) as ExpenseAdjustment,
	sum([Contractor Pass-Through]) as [Contractor Pass-Through Adjustment],
	sum([Contractor Margin]) as [Contractor Margin Adjustment],
	sum([Other Adjustment]) as [Other Adjustment],
	sum([Adjustment to Close a Project])+sum([Contractor Margin]) as Adjustments,
	(sum(BillingAmount)-sum([Adjustment to Close a Project])-sum([Contractor Margin])) as AdjustedBillingAmount,
	case when (sum(BillingAmount)-sum([Adjustment to Close a Project])-sum([Contractor Margin])) =0 then 0 else ((sum(BillingAmount)-sum([Adjustment to Close a Project])-sum([Contractor Margin]))-sum(InternalCost))/(sum(BillingAmount)-sum([Adjustment to Close a Project])-sum([Contractor Margin])) end as Profitability
from
	BG_EngagementProject_Profitability_2018_CG--BG_ProjectProfitability_NoContractor_2017_CG
group by
	Company,
	Region,
	Practice,
	Engagement,
	ProjectManager,
	ProjectType,
	CloseDate
GO

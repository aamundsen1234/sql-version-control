USE [Changepoint]
GO
/****** Object:  UserDefinedFunction [dbo].[BG_ProjectProfitability_ProjectType_Summary_byMonth_CG]    Script Date: 10/11/2019 12:19:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[BG_ProjectProfitability_ProjectType_Summary_byMonth_CG](@StartDate date, @EndDate date)
returns table
as
return
select
	ProjectType,
	year(CloseDate) as CloseYear,
	month(CloseDate) as CloseMonth#,
	datename(month, CloseDate) as CloseMonthName,
	sum(RegularHours) as BillableHours,
	sum(Cost) as Cost,
	-sum(FixedFeeOverage) as WriteUpWriteOff,
	sum(InternalCost) as InternalCost,
	sum(BillingAmount) as BillingAmount,
	sum([Write-Up Adjustment]) as WriteUpAdjustment,
	sum([Expense Adjustment]) as ExpenseAdjustment,
	sum([Contractor Adjustment]) as ContractorAdjustment,
	sum([Write-Up Adjustment])+sum([Expense Adjustment]) as Adjustments,
	(sum(BillingAmount)+sum([Write-Up Adjustment]))-sum([Expense Adjustment]) as AdjustedBillingAmount,
	case when ((sum(BillingAmount)+sum([Write-Up Adjustment]))-sum([Expense Adjustment])) =0 then 0 else ((sum(BillingAmount)+sum([Write-Up Adjustment]))-sum([Expense Adjustment])-sum(InternalCost))/((sum(BillingAmount)+sum([Write-Up Adjustment]))-sum([Expense Adjustment])) end as Profitability
from
	BG_ProjectProfitability_NoContractor_2017_CG
where
	CloseDate>=@StartDate
	and CloseDate<=@EndDate
group by
	ProjectType,
	year(CloseDate),
	month(CloseDate),
	datename(month, CloseDate)

GO

USE [Changepoint]
GO
/****** Object:  UserDefinedFunction [dbo].[BG_ResourceDashboardResourceSummary_CG]    Script Date: 10/17/2019 3:12:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--select * from [BG_ResourceDashboardResourceSummary_CG]('20180101', '20180412') where Resource='Minshall, Anne'


CREATE FUNCTION [dbo].[BG_ResourceDashboardResourceSummary_CG] 
(@StartDate date, @EndDate date)
RETURNS TABLE 
AS
RETURN 

SELECT 
	Region,
	--Workgroup,
	Resource,
	ResourceId,
	(SELECT max(Salary)/1.2 as BaseSalary FROM BG_ResourceSalary_All_History_Ranked_CG s where s.ResourceId=r.ResourceId ) as BaseSalary,
	Manager,
	Manager_ResourceId,
	Terminated,
	sum(BillableHours) as BillableHours,
	sum(BillableHours)*100.00 as StandardMarginCredit,
	sum(RevenueRecognized) as RevenueRecognized,
	sum(WriteUpWriteOff) as WriteUpWriteOff,
	case when sum(BillableHours)=0 then 0 else (sum(RevenueRecognized)+sum(WriteUpWriteOff))/sum(BillableHours) end as RealizationRate,
	sum(Sales) as Sales,
	sum(MSMargin) as MSMargin,
	--sum(distinct Month1Cost)+sum(distinct Month2Cost)+sum(distinct Month3Cost)+sum(distinct Month4Cost)+sum(distinct Month5Cost)+sum(distinct Month6Cost)+sum(distinct Month7Cost)+sum(distinct Month8Cost)+sum(distinct Month9Cost)+sum(distinct Month10Cost)+sum(distinct Month11Cost)+sum(distinct Month12Cost) as ResourceCost,
	--(sum(RevenueRecognized)+sum(WriteUpWriteOff)+sum(Sales)+sum(MSMargin))-(sum(distinct Month1Cost)+sum(distinct Month2Cost)+sum(distinct Month3Cost)+sum(distinct Month4Cost)+sum(distinct Month5Cost)+sum(distinct Month6Cost)+sum(distinct Month7Cost)+sum(distinct Month8Cost)+sum(distinct Month9Cost)+sum(distinct Month10Cost)+sum(distinct Month11Cost)+sum(distinct Month12Cost)) as ResourceMarginwithSales,
	--(sum(RevenueRecognized)+sum(WriteUpWriteOff)+sum(MSMargin))-(sum(distinct Month1Cost)+sum(distinct Month2Cost)+sum(distinct Month3Cost)+sum(distinct Month4Cost)+sum(distinct Month5Cost)+sum(distinct Month6Cost)+sum(distinct Month7Cost)+sum(distinct Month8Cost)+sum(distinct Month9Cost)+sum(distinct Month10Cost)+sum(distinct Month11Cost)+sum(distinct Month12Cost)) as ResourceMarginWithOutSales,
	--case when (sum(distinct Month1Cost)+sum(distinct Month2Cost)+sum(distinct Month3Cost)+sum(distinct Month4Cost)+sum(distinct Month5Cost)+sum(distinct Month6Cost)+sum(distinct Month7Cost)+sum(distinct Month8Cost)+sum(distinct Month9Cost)+sum(distinct Month10Cost)+sum(distinct Month11Cost)+sum(distinct Month12Cost))=0 then 0 
	--else 	((sum(RevenueRecognized)+sum(WriteUpWriteOff)+sum(MSMargin))-(sum(distinct Month1Cost)+sum(distinct Month2Cost)+sum(distinct Month3Cost)+sum(distinct Month4Cost)+sum(distinct Month5Cost)+sum(distinct Month6Cost)+sum(distinct Month7Cost)+sum(distinct Month8Cost)+sum(distinct Month9Cost)+sum(distinct Month10Cost)+sum(distinct Month11Cost)+sum(distinct Month12Cost)))/(sum(distinct Month1Cost)+sum(distinct Month2Cost)+sum(distinct Month3Cost)+sum(distinct Month4Cost)+sum(distinct Month5Cost)+sum(distinct Month6Cost)+sum(distinct Month7Cost)+sum(distinct Month8Cost)+sum(distinct Month9Cost)+sum(distinct Month10Cost)+sum(distinct Month11Cost)+sum(distinct Month12Cost)) end as 'ContributionPercent'
	max(Month1Cost)+max(Month2Cost)+max(Month3Cost)+max(Month4Cost)+max(Month5Cost)+max(Month6Cost)+max(Month7Cost)+max(Month8Cost)+max(Month9Cost)+max(Month10Cost)+max(Month11Cost)+max(Month12Cost) as ResourceCost,
	sum(NewMonth1Cost)+sum(NewMonth2Cost)+sum(NewMonth3Cost)+sum(NewMonth4Cost)+sum(NewMonth5Cost)+sum(NewMonth6Cost)+sum(NewMonth7Cost)+sum(NewMonth8Cost)+sum(NewMonth9Cost)+sum(NewMonth10Cost)+sum(NewMonth11Cost)+sum(NewMonth12Cost) as NewCost,
	sum(NewMonth1Cost+NewMonth2Cost+NewMonth3Cost+ NewMonth4Cost+NewMonth5Cost+NewMonth6Cost+ NewMonth7Cost+NewMonth8Cost+NewMonth9Cost+ NewMonth10Cost+NewMonth11Cost+NewMonth12Cost) as NewCost2,
	(sum(RevenueRecognized)+sum(WriteUpWriteOff)+sum(Sales)+sum(MSMargin))-(max(Month1Cost)+max(Month2Cost)+max(Month3Cost)+max(Month4Cost)+max(Month5Cost)+max(Month6Cost)+max(Month7Cost)+max(Month8Cost)+max(Month9Cost)+max(Month10Cost)+max(Month11Cost)+max(Month12Cost)) as ResourceMarginwithSales,
	(sum(RevenueRecognized)+sum(WriteUpWriteOff)+sum(MSMargin))-(max(Month1Cost)+max(Month2Cost)+max(Month3Cost)+max(Month4Cost)+max(Month5Cost)+max(Month6Cost)+max(Month7Cost)+max(Month8Cost)+max(Month9Cost)+max(Month10Cost)+max(Month11Cost)+max(Month12Cost)) as ResourceMarginWithOutSales,
	case when (max(Month1Cost)+max(Month2Cost)+max(Month3Cost)+max(Month4Cost)+max(Month5Cost)+max(Month6Cost)+max(Month7Cost)+max(Month8Cost)+max(Month9Cost)+max(Month10Cost)+max(Month11Cost)+max(Month12Cost))=0 then 0 
	else 	((sum(RevenueRecognized)+sum(WriteUpWriteOff)+sum(MSMargin))-(max(Month1Cost)+max(Month2Cost)+max(Month3Cost)+max(Month4Cost)+max(Month5Cost)+max(Month6Cost)+max(Month7Cost)+max(Month8Cost)+max(Month9Cost)+max(Month10Cost)+max(Month11Cost)+max(Month12Cost)))/(max(Month1Cost)+max(Month2Cost)+max(Month3Cost)+max(Month4Cost)+max(Month5Cost)+max(Month6Cost)+max(Month7Cost)+max(Month8Cost)+max(Month9Cost)+max(Month10Cost)+max(Month11Cost)+max(Month12Cost)) end as 'ContributionPercent',
	(sum(BillableHours)*100.00)+sum(WriteUpWriteOff) as ResourceMargin,
	case when (sum(NewMonth1Cost)+sum(NewMonth2Cost)+sum(NewMonth3Cost)+sum(NewMonth4Cost)+sum(NewMonth5Cost)+sum(NewMonth6Cost)+sum(NewMonth7Cost)+sum(NewMonth8Cost)+sum(NewMonth9Cost)+sum(NewMonth10Cost)+sum(NewMonth11Cost)+sum(NewMonth12Cost))=0 then 0 else ((sum(BillableHours)*100.00)+sum(WriteUpWriteOff))/(sum(NewMonth1Cost)+sum(NewMonth2Cost)+sum(NewMonth3Cost)+sum(NewMonth4Cost)+sum(NewMonth5Cost)+sum(NewMonth6Cost)+sum(NewMonth7Cost)+sum(NewMonth8Cost)+sum(NewMonth9Cost)+sum(NewMonth10Cost)+sum(NewMonth11Cost)+sum(NewMonth12Cost)) end as PercentToGoal

FROM 
	[BG_ResourceDashboardDetail_CG] (@StartDate, @EndDate) r
group by
	Region,
	--Workgroup,
	Resource,
	ResourceId,
	Manager,
	Manager_ResourceId,
	Terminated
GO

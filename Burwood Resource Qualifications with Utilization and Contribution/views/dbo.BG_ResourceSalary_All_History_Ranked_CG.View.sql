USE [Changepoint]
GO
/****** Object:  View [dbo].[BG_ResourceSalary_All_History_Ranked_CG]    Script Date: 10/17/2019 3:05:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[BG_ResourceSalary_All_History_Ranked_CG] AS

with BG_ResourceSalary_All_History_CG as 
(
select 
	r.ResourceId,
	r.Name as Resource,
	convert(date, r.HireDate) as HireDate,
	convert(date, r.TerminationDate) as TerminationDate,
	r.Deleted,
	rr.Rate1 as Salary,
	case when r.Name in ('Tennant, Ryan', 'Miller, Harvey', 'Cacioppo, Doug') then (cast(rr.Rate1 as float) / (select dbo.FN_Days_In_Year(datepart(year, getdate()))))/2
	 else cast(rr.Rate1 as float) / (select dbo.FN_Days_In_Year(datepart(year, getdate()))) end as Daily_Cost,
	146000.00/(select dbo.FN_Days_In_Year(datepart(year, getdate()))) as NewDailyCost,
	cast(rr.Rate1 as float) / 52 as Weekly_Cost,
	cast(rr.Rate1 as float) / 12 as Monthly_Cost,
	cast(rr.Rate1 as float) / 4 as Quarterly_Cost,
	cast(rr.Rate1 as float) as Yearly_Cost,
	rr.EffectiveDate,
	--DATEADD(yy, DATEDIFF(yy,0,getdate()) + 2, -1) as EndDate,
	case when (DATEADD(yy, DATEDIFF(yy,0,getdate()) + 2, -1))>convert(date, r.TerminationDate) then convert(date, r.TerminationDate) else DATEADD(yy, DATEDIFF(yy,0,getdate()) + 2, -1) end as EndDate
from 
	Resources r with (nolock)
		join
	ResourceRate rr with (nolock) on rr.ResourceId=r.ResourceId and rr.Active=1
	
where
	rr.Rate1>0
	--and r.Name='Abdelrahman, Amr'

union all

select 
	r.ResourceId,
	r.Name as Resource,
	convert(date, r.HireDate) as HireDate,
	convert(date, r.TerminationDate) as TerminationDate,
	r.Deleted,
	rr.Rate1 as Salary,
	case when r.Name in ('Miller, Harvey', 'Tennant, Ryan', 'Cacioppo, Doug') then (cast(rr.Rate1 as float) / (select dbo.FN_Days_In_Year(datepart(year, getdate()))))/2
	 else cast(rr.Rate1 as float) / (select dbo.FN_Days_In_Year(datepart(year, getdate()))) end as Daily_Cost,
	146000.00/(select dbo.FN_Days_In_Year(datepart(year, getdate()))) as NewDailyCost,
	cast(rr.Rate1 as float) / 52 as Weekly_Cost,
	cast(rr.Rate1 as float) / 12 as Monthly_Cost,
	cast(rr.Rate1 as float) / 4 as Quarterly_Cost,
	cast(rr.Rate1 as float) as Yearly_Cost,
	rr.EffectiveDate,
	rr.EffectiveDate as EndDate
	--rr.EffectiveDate as NewEndDate
from 
	Resources r with (nolock)
		join
	ResourceRate rr with (nolock) on rr.ResourceId=r.ResourceId and rr.Active=0
	
where
	rr.Rate1>0 and rr.Rate1 is not NULL
)

select 
Resource,
ResourceId,
Salary,
Daily_Cost,
NewDailyCost,
Weekly_Cost,
Monthly_Cost,
Quarterly_Cost,
Yearly_Cost,
EffectiveDate,
EndDate,
row_number() over (partition by Resource order by EndDate desc, EffectiveDate Desc) as Sequence
--cast(max(EffectiveDate) as date) as EffectiveDate,
--cast(max(EndDate) as date) as EndDate
from
	BG_ResourceSalary_All_History_CG
--group by 
	--Resource,
	--ResourceId










GO

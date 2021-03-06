USE [Changepoint]
GO
/****** Object:  UserDefinedFunction [dbo].[BG_GetUtilizationForecast_CG]    Script Date: 10/17/2019 4:33:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[BG_GetUtilizationForecast_CG](@FiscalYear nvarchar(281), @StartDate as date)
returns table
as
return


--select * from BG_GetUtilizationForecast_CG('2019 [2018-12-29 - 2019-12-27]', '20190330')


select
	Resource,
	Title,
	Region,
	Practice,
	Workgroup,
	FiscalYear,
	PeriodStartDate,
	case when PeriodStartDate=@StartDate then UtilizationHours else 0 end as UtilizationHours,
	case when PeriodStartDate=@StartDate then TotalHours else 0 end as TotalHours,
	case when PeriodStartDate=@StartDate then UtilizationWeekly else 0 end as UtilizationWeekly,
	case when PeriodStartDate=@StartDate then HoursPerWeek else 0 end as HoursPerWeek,
	case when PeriodStartDate=@StartDate then ForecastHours else 0 end as ForecastHours,
	coalesce(UtilizationHours,0) as YTDUtilizationHours,
	coalesce(HoursPerWeek,0) as YTDHoursPerWeek,
	coalesce(ForecastHours,0) as YTDForecastHours,
	UtilizationGoal
from	
	BG_New_UtilizationForecast_Table_CG --where PeriodStartDate>='20190301' and FiscalYear='2019 [2018-12-29 - 2019-12-27]'
where
	FiscalYear = @FiscalYear
--	(case when month(getdate())=1 then (select 
--	distinct
--	fy.Name+' ['+LEFT(CONVERT(VARCHAR, fy.StartDate, 120), 10)+' - '+LEFT(CONVERT(VARCHAR, fy.EndDate, 120), 10)+']' as FiscalYear
--from
--	FiscalYear fy with (nolock)
--		join
--	FiscalPeriod fp with (nolock) on fy.FiscalYearId=fp.FiscalYearId and fp.Deleted=0
--		join
--	BillingOffice b with (nolock) on fy.BillingOfficeId=b.BillingOfficeId
--where
--	fy.BillingOfficeId='A688AC3B-03DA-44C3-8A05-CBE069E1A6F2'
--	and (fy.name=convert(varchar(4), year(getdate())-1))) else @FiscalYear end)
	and PeriodStartDate<=@StartDate

	--FiscalYear=@FiscalYear
	--and PeriodStartDate<=@StartDate
GO

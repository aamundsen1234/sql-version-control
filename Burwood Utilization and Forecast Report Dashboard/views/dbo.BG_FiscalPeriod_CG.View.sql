USE [Changepoint]
GO
/****** Object:  View [dbo].[BG_FiscalPeriod_CG]    Script Date: 10/17/2019 4:47:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


--truncate table BG_FiscalPeriod_Table_CG
--select * into BG_FiscalPeriod_Table_CG from BG_FiscalPeriod_CG
-- insert into BG_FiscalPeriod_Table_CG select * from BG_FiscalPeriod_CG



CREATE VIEW [dbo].[BG_FiscalPeriod_CG] AS
select 
	--cast(fy.Name as int) as FYear,
	fy.Name+' ['+LEFT(CONVERT(VARCHAR, fy.StartDate, 120), 10)+' - '+LEFT(CONVERT(VARCHAR, fy.EndDate, 120), 10)+']' as FiscalYear,
	fp.Period+' ['+LEFT(CONVERT(VARCHAR, fp.StartDate, 120), 10)+' - '+LEFT(CONVERT(VARCHAR, fp.EndDate, 120), 10)+']' as FiscalPeriod,
	cast(fp.StartDate as date) as PeriodStartDate,
	cast(fp.EndDate as date) as PeriodEndDate

from
	FiscalYear fy with (nolock) 
		join
	FiscalPeriod fp with (nolock) on fp.FiscalYearId = fy.FiscalYearId AND fp.Deleted = CAST(0 AS BIT) 
where	
	fy.BillingOfficeId = '{A688AC3B-03DA-44C3-8A05-CBE069E1A6F2}' 
	AND fy.Deleted = CAST(0 AS BIT)
	and fy.Name not like '%Weekly%'


GO

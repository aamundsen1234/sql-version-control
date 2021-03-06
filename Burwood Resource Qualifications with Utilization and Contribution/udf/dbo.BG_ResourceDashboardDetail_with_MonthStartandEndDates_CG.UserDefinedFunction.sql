USE [Changepoint]
GO
/****** Object:  UserDefinedFunction [dbo].[BG_ResourceDashboardDetail_with_MonthStartandEndDates_CG]    Script Date: 10/17/2019 3:12:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create FUNCTION [dbo].[BG_ResourceDashboardDetail_with_MonthStartandEndDates_CG] 
(@StartDate date, @EndDate date)
RETURNS TABLE 
AS
RETURN 

SELECT 
	*,
	@StartDate as Month1Start,
	case when @EndDate>=EOMonth(@StartDate) then EOMonth(@StartDate) 
		 when @EndDate<=EOMonth(@StartDate) then @EndDate
		 else NULL
	end as Month1End,
	case when @EndDate>dateadd(month, 1, @StartDate)
		 then dateadd(month, 1, @StartDate)
		 else NULL
	end as Month2Start,
	case when @EndDate>=EOMONTH(case when @EndDate>dateadd(month, 1, @StartDate) then dateadd(month, 1, @StartDate) else NULL end)
		 then EOMONTH(case when @EndDate>dateadd(month, 1, @StartDate) then dateadd(month, 1, @StartDate) else NULL end)
		 when @EndDate<=EOMONTH(case when @EndDate>dateadd(month, 1, @StartDate) then dateadd(month, 1, @StartDate) else NULL end)
		 then @EndDate
		 else NULL
	end as Month2End,
	case when @EndDate>dateadd(month, 2, @StartDate)
		 then dateadd(month, 2, @StartDate)
		 else NULL
	end as Month3Start,
	case when @EndDate>=EOMONTH(case when @EndDate>dateadd(month, 2, @StartDate) then dateadd(month, 2, @StartDate) else NULL end)
		 then EOMONTH(case when @EndDate>dateadd(month, 2, @StartDate) then dateadd(month, 2, @StartDate) else NULL end)
		 when @EndDate<=EOMONTH(case when @EndDate>dateadd(month, 2, @StartDate) then dateadd(month, 2, @StartDate) else NULL end)
		 then @EndDate
		 else NULL
	end as Month3End,
	case when @EndDate>dateadd(month, 3, @StartDate)
		 then dateadd(month, 3, @StartDate)
		 else NULL
	end as Month4Start,
	case when @EndDate>=EOMONTH(case when @EndDate>dateadd(month, 3, @StartDate) then dateadd(month, 3, @StartDate) else NULL end)
		 then EOMONTH(case when @EndDate>dateadd(month, 3, @StartDate) then dateadd(month, 3, @StartDate) else NULL end)
		 when @EndDate<=EOMONTH(case when @EndDate>dateadd(month, 3, @StartDate) then dateadd(month, 3, @StartDate) else NULL end)
		 then @EndDate
		 else NULL
	end as Month4End,
	case when @EndDate>dateadd(month, 4, @StartDate)
		 then dateadd(month, 4, @StartDate)
		 else NULL
	end as Month5Start,
	case when @EndDate>=EOMONTH(case when @EndDate>dateadd(month, 4, @StartDate) then dateadd(month, 4, @StartDate) else NULL end)
		 then EOMONTH(case when @EndDate>dateadd(month, 4, @StartDate) then dateadd(month, 4, @StartDate) else NULL end)
		 when @EndDate<=EOMONTH(case when @EndDate>dateadd(month, 4, @StartDate) then dateadd(month, 4, @StartDate) else NULL end)
		 then @EndDate
		 else NULL
	end as Month5End,
	case when @EndDate>dateadd(month, 5, @StartDate)
		 then dateadd(month, 5, @StartDate)
		 else NULL
	end as Month6Start,
	case when @EndDate>=EOMONTH(case when @EndDate>dateadd(month, 5, @StartDate) then dateadd(month, 5, @StartDate) else NULL end)
		 then EOMONTH(case when @EndDate>dateadd(month, 5, @StartDate) then dateadd(month, 5, @StartDate) else NULL end)
		 when @EndDate<=EOMONTH(case when @EndDate>dateadd(month, 5, @StartDate) then dateadd(month, 5, @StartDate) else NULL end)
		 then @EndDate
		 else NULL
	end as Month6End,
	case when @EndDate>dateadd(month, 6, @StartDate)
		 then dateadd(month, 6, @StartDate)
		 else NULL
	end as Month7Start,
	case when @EndDate>=EOMONTH(case when @EndDate>dateadd(month, 6, @StartDate) then dateadd(month, 6, @StartDate) else NULL end)
		 then EOMONTH(case when @EndDate>dateadd(month, 6, @StartDate) then dateadd(month, 6, @StartDate) else NULL end)
		 when @EndDate<=EOMONTH(case when @EndDate>dateadd(month, 6, @StartDate) then dateadd(month, 6, @StartDate) else NULL end)
		 then @EndDate
		 else NULL
	end as Month7End,
	case when @EndDate>dateadd(month, 7, @StartDate)
		 then dateadd(month, 7, @StartDate)
		 else NULL
	end as Month8Start,
	case when @EndDate>=EOMONTH(case when @EndDate>dateadd(month, 7, @StartDate) then dateadd(month, 7, @StartDate) else NULL end)
		 then EOMONTH(case when @EndDate>dateadd(month, 7, @StartDate) then dateadd(month, 7, @StartDate) else NULL end)
		 when @EndDate<=EOMONTH(case when @EndDate>dateadd(month, 7, @StartDate) then dateadd(month, 7, @StartDate) else NULL end)
		 then @EndDate
		 else NULL
	end as Month8End,
	case when @EndDate>dateadd(month, 8, @StartDate)
		 then dateadd(month, 8, @StartDate)
		 else NULL
	end as Month9Start,
	case when @EndDate>=EOMONTH(case when @EndDate>dateadd(month, 8, @StartDate) then dateadd(month, 8, @StartDate) else NULL end)
		 then EOMONTH(case when @EndDate>dateadd(month, 8, @StartDate) then dateadd(month, 8, @StartDate) else NULL end)
		 when @EndDate<=EOMONTH(case when @EndDate>dateadd(month, 8, @StartDate) then dateadd(month, 8, @StartDate) else NULL end)
		 then @EndDate
		 else NULL
	end as Month9End,
	case when @EndDate>dateadd(month, 9, @StartDate)
		 then dateadd(month, 9, @StartDate)
		 else NULL
	end as Month10Start,
	case when @EndDate>=EOMONTH(case when @EndDate>dateadd(month, 9, @StartDate) then dateadd(month, 9, @StartDate) else NULL end)
		 then EOMONTH(case when @EndDate>dateadd(month, 9, @StartDate) then dateadd(month, 9, @StartDate) else NULL end)
		 when @EndDate<=EOMONTH(case when @EndDate>dateadd(month, 9, @StartDate) then dateadd(month, 9, @StartDate) else NULL end)
		 then @EndDate
		 else NULL
	end as Month10End,
	case when @EndDate>dateadd(month, 10, @StartDate)
		 then dateadd(month, 10, @StartDate)
		 else NULL
	end as Month11Start,
	case when @EndDate>=EOMONTH(case when @EndDate>dateadd(month, 10, @StartDate) then dateadd(month, 10, @StartDate) else NULL end)
		 then EOMONTH(case when @EndDate>dateadd(month, 10, @StartDate) then dateadd(month, 10, @StartDate) else NULL end)
		 when @EndDate<=EOMONTH(case when @EndDate>dateadd(month, 10, @StartDate) then dateadd(month, 10, @StartDate) else NULL end)
		 then @EndDate
		 else NULL
	end as Month11End,
	case when @EndDate>dateadd(month, 11, @StartDate)
		 then dateadd(month, 11, @StartDate)
		 else NULL
	end as Month12Start,
	case when @EndDate>=EOMONTH(case when @EndDate>dateadd(month, 11, @StartDate) then dateadd(month, 11, @StartDate) else NULL end)
		 then EOMONTH(case when @EndDate>dateadd(month, 11, @StartDate) then dateadd(month, 11, @StartDate) else NULL end)
		 when @EndDate<=EOMONTH(case when @EndDate>dateadd(month, 11, @StartDate) then dateadd(month, 11, @StartDate) else NULL end)
		 then @EndDate
		 else NULL
	end as Month12End
FROM 
	BG_WorkgroupDashboard_Table_CG
WHERE 
	(EffectiveEndDate>=@StartDate or Type in ('EX', 'CS') or TerminationDate is not NULL)
	and not (Type='SE' and InvoiceType like '%services%')
	and (TerminationDate is NULL or TerminationDate='' or datepart(year, TerminationDate)>=datepart(year, @StartDate) or HireDate='20120101' or Type in ('WO', 'CM'))
	and ((TransDate>=@StartDate and TransDate<=@EndDate) or (Type in ('CS') and Year_Close=datepart(year, @StartDate) and Month_Close>=datepart(month, @StartDate) and Month_Close<=datepart(month, @EndDate)))
	and (datepart(year, [HireDate])< datepart(year, @StartDate) or datepart(year, [HireDate])=datepart(year, @StartDate) and datepart(month, [HireDate])<=datepart(month, @EndDate) or [HireDate]='2012-01-01' or HireDate is NULL)
	and ([EffectiveEndDate]>=@StartDate or [TerminationDate] is not NULL)
	and Resource<>'Jaimes, Tino'
GO

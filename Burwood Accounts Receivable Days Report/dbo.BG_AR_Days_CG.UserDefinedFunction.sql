﻿USE [BGINC]
GO
/****** Object:  UserDefinedFunction [dbo].[BG_AR_Days_CG]    Script Date: 10/11/2019 4:29:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--select count (*) from BG_AR_Days_CG('20170731')
--here is a new comment
	

CREATE function [dbo].[BG_AR_Days_CG](@EndDate date)
returns table
as
return
select
	'Burwood Group, Inc.' as Company,
	coalesce(ar.Region, rr.Region) as Region,
	rvp.RVP,
	rvp.EmailAddress as RVP_EmailAddress,
	pm.ProjectManager,
	pm.EmailAddress as PM_EmailAddress,
	c.Resource as AccountExecutive,
	case when ae.new_terminationDate is not null then case when mae.new_terminationDate is not null then 'gbueltmann@burwood.com' else mae.InternalEmailAddress end
		 else ae.InternalEmailAddress 
	end as AE_EmailAddress,
	'tshepherd@burwood.com' as TestBurst,
	 'rgibson@burwood.com, bsingh@burwood.com, kholland@burwood.com, tshepherd@burwood.com, jcourtney@burwood.com' as AR_EmailBurst,
	a.Name as Account,
	o.Name as Opportunity,
	es.Description as EngagementStatus,
	c.SOPNUMBE as 'Invoice#',
	c.ORIGNUMB as 'Order#',
	convert(date, c.INVODATE) as InvoiceDate,
	c.DOCAMNT as InvoiceAmount,
	case when c.Unpaid is NULL then c.DOCAMNT else c.Unpaid end as UnpaidAmount,
	case when c.DSO is NULL 
		 then datediff(day, convert(date, c.INVODATE), @EndDate)
		 else c.DSO
	end as ARDays
from
	BG_2019_CommissionsData_Owner_CurrentYear_Table_CG c with (nolock) --BG_CommissionsData_Owner_Table_CG c with (nolock)
		join
	[chil-crm-04].[BurwoodGroupInc_MSCRM].dbo.OpportunityBase o with (nolock) on c.OpportunityId=o.OpportunityId
		join
	[chil-crm-04].[BurwoodGroupInc_MSCRM].dbo.AccountBase a with (nolock) on o.CustomerId=a.AccountId
		join
	[chil-crm-04].[BurwoodGroupInc_MSCRM].dbo.SystemUserBase ae with (nolock) on o.OwnerId=ae.SystemUserId
		left outer join
	[chil-crm-04].[BurwoodGroupInc_MSCRM].dbo.SystemUserBase mae with (nolock) on ae.ParentSystemUserId=mae.SystemUserId
		left outer join
	[chil-sql-01].[Changepoint].dbo.BG_AccountExecutives_CG ar with (nolock) on c.Resource collate database_default=ar.BDM
		left outer join
	[chil-sql-01].[Changepoint].dbo.BG_ResourceRegion_CG rr with (nolock) on c.Resource collate database_default=rr.Resource
	--	left outer join
	--[chil-crm-04].[BurwoodGroupInc_MSCRM].dbo.SystemUserBase pm with (nolock) on o.new_ProjectLeadId=pm.SystemUserId and pm.IsDisabled=0
		left outer join
	[chil-sql-01].[Changepoint].dbo.[BG_RVP_AR_email_CG] rvp with (nolock) on coalesce(ar.Region, rr.Region)=rvp.Region
		left outer join
	[chil-sql-01].[Changepoint].dbo.Engagement e with (nolock) on o.OpportunityId=e.OpportunityId
		left outer join
	[chil-sql-01].[Changepoint].dbo.EngagementStatus es with (nolock) on e.EngagementStatus=es.Code
		left outer join
	[chil-sql-01].[Changepoint].dbo.[BG_ProjectManager_CG] pm with (nolock) on e.EngagementId=pm.EngagementId
	
where
	c.TypeCode in (7, 8)
	and coalesce(c.Unpaid, c.DOCAMNT)>0
	--and case when c.Unpaid is NULL then c.DOCAMNT else c.Unpaid end >0
	and c.SoldToID not like 'CISCAP%'
	and c.SOPNUMBE not like 'RTN%'
	and case when c.DSO is NULL 
		 then datediff(day, convert(date, c.INVODATE), @EndDate)
		 else c.DSO
	end >=45
	--and c.IsSolutionArchitect='No'
	--and c.IsSolutionExpert='No'
	--and c.Resource='Andrew, Greg'
	--and o.Name like '%managed%'

GO

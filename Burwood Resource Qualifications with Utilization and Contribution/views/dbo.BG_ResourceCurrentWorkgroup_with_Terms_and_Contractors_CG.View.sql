USE [Changepoint]
GO
/****** Object:  View [dbo].[BG_ResourceCurrentWorkgroup_with_Terms_and_Contractors_CG]    Script Date: 10/17/2019 3:05:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--select * from [BG_ResourceCurrentWorkgroup_with_Terms_and_Contractors_CG] where Resource='SCHAFER, DANIEL'

--select * from WorkgroupMember where ResourceId='CEF0BEC9-1A0C-40C3-8708-33C4F7F477AE'


--select ResourceId, Resource, count(Workgroup) as WorkgroupCount from BG_ResourceCurrentWorkgroup_with_Terms_and_Contractors_CG group by ResourceId, Resource order by WorkgroupCount desc


CREATE view [dbo].[BG_ResourceCurrentWorkgroup_with_Terms_and_Contractors_CG] as 
select
	rr.Region,
	cc.Name as Practice,
	wp.Name as ParentWorkgroup,
	w.Name as Workgroup,
	r.Name as Resource,
	convert(date, r.HireDate) as HireDate,
	convert(date, r.TerminationDate) as TerminationDate,
	r.Title,
	r.ResourceId,
	r.EmployeeType,
	m.Name as Manager,
	m.ResourceId as Manager_ResourceId,
	w.WorkgroupId, 
	wp.WorkgroupId as ParentWorkgroupId,
	wt.Description as WorkgroupType
from
	Resources r with (nolock)
		join
	WorkgroupMember wm with (nolock) on r.ResourceId=wm.ResourceId and (wm.Historical=0 or (year(r.TerminationDate)=case when month(getdate())=1 then year(getdate())-1 else year(getdate()) end and wm.Historical=1))
		join
	Workgroup w with (nolock) on wm.WorkgroupId=w.WorkgroupId
		left outer join
	Resources m with (nolock) on r.ReportsTo=m.ResourceId
		left outer join
	BG_ResourceRegion_CG rr with (nolock) on r.ResourceId=rr.ResourceId
		left outer join
	WorkgroupType wt with (nolock) on w.WorkgroupTypeId=wt.Code
		left outer join
	CostCenters cc with (nolock) on r.CostCenterId=cc.CostCenter
		left outer JOIN
	WorkgroupRelation AS WR WITH (NOLOCK) on w.WorkgroupId=wr.ChildWorkgroupId 
		left outer  JOIN
    Workgroup AS wp ON WR.ParentWorkgroupID = wp.WorkgroupId
where
	wm.Historical=0
	or (wm.Historical=1 and wm.CreatedOn = (select max(wm2.CreatedOn) from WorkgroupMember wm2 where wm2.ResourceId=r.ResourceId))





GO

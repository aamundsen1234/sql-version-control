USE [Changepoint]
GO
/****** Object:  View [dbo].[BG_ResourceQualifications_with_Utilization_and_Contribution_CG]    Script Date: 10/17/2019 3:46:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





--SELECT distinct Workgroup2 FROM BG_ResourceQualifications_with_Utilization_and_Contribution_CG WHERE Resource='Lindberg, Craig'


CREATE VIEW [dbo].[BG_ResourceQualifications_with_Utilization_and_Contribution_CG] AS
SELECT
	q.Resource,
	r.Title,
	q.ResourceId,
	c.Description AS Region,
	q.Practice,
	q.Workgroup,
	wg.Name as Workgroup2,
	COALESCE(qu.Utilization, 0) AS QTDUtilization,
	COALESCE(qy.Utilization, 0) AS YTDUtilization,
	COALESCE(ct.[Contribution%],0) AS 'Contribution%',
	q.Area,
	q.Category,
	q.Skill,
	Rating
FROM
	BG_ResourceQualifications_CG q WITH (NOLOCK)
		LEFT OUTER JOIN
	BG_WeeklyResourceLoading_QTD_Utilization_CG qu WITH (NOLOCK) ON q.ResourceId=qu.ResourceId
		LEFT OUTER JOIN
	BG_WeeklyResourceLoading_YTD_Utilization_CG qy WITH (NOLOCK) ON q.ResourceId=qy.ResourceId
		LEFT OUTER JOIN
	BG_WeeklyLoading_YTD_ContributionPercent_CG ct WITH (NOLOCK) ON q.ResourceId=ct.ResourceId
		LEFT OUTER JOIN 
	UDFCode u WITH (NOLOCK) ON q.ResourceId=u.EntityId AND u.ItemName='ResourceCode1'
		LEFT OUTER JOIN 
	CodeDetail c WITH (NOLOCK) ON u.UDFCode=c.CodeDetail
		LEFT OUTER JOIN
	Resources r WITH (NOLOCK) ON q.ResourceId=r.ResourceId 
		left outer join
	WorkgroupMember wm with (nolock) on wm.ResourceId=r.ResourceId and wm.Historical=0
		left outer join
	Workgroup wg with (nolock) on wg.WorkgroupId=wm.WorkgroupId
WHERE
	CASE WHEN [Rating]='0' THEN 0 
		 WHEN [Rating]='1' THEN 1
		 WHEN [Rating]='2' THEN 2
		 WHEN [Rating]='3' THEN 3
		 WHEN [Rating]='3.5' THEN 4
		 WHEN [Rating]='4' THEN 4
		 WHEN [Rating]='5' THEN 5
	END >= 0
	and r.TerminationDate is NULL
	and r.Deleted=0
	and r.EmployeeType<>'CO'
	and wg.Name not in ('Burwood Corporate', 'Business Development-EA', 'Business Development-HL', 'Business Development-WE', 'Business Operations & Finance', 
						'Eastern Region', 'Heartland Region', 'Leave of Absence', 'Marketing', 'NOC Personnel', 'Owners', 'Product Sales Operations', 
						'Product Sales Operations-EA', 'Sales Engineers', 'Western Region')



GO

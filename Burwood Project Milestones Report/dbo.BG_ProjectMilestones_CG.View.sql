USE [Changepoint]
GO
/****** Object:  View [dbo].[BG_ProjectMilestones_CG]    Script Date: 10/14/2019 4:16:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO








CREATE VIEW [dbo].[BG_ProjectMilestones_CG] AS
select 
	e.Name as Engagement,
	b.Description as Region,
	p.Name as Project,
	mmr.Name as ProjectManager,
	case when p.ProjectStatus='A' then 'Active' when p.ProjectStatus='C' then 'Complete' end as ProjectStatus,
	case when t.Completed=0 then 'No' when t.Completed=1 then 'Yes' end as Completed,
	p.BaselineFinish,
	p.PlannedFinish,
	p.ActualFinish,
	r.Name as Resource,
	t.Name as Task,
	t.Milestone,
	cast(t.BaselineFinish as date) as TaskBaselineFinish,
	coalesce(t.BaselineHours,0) as TaskBaselineHours,
	cast(t.PlannedStart as date) as TaskPlannedStart,
	cast(t.PlannedFinish as date) as TaskPlannedFinish,
	cast(t.RollupActualFinish as date) as TaskActualFinish,
	t.PlannedHours as TaskPlannedHours,
	t.RollupActualHours as TaskActualHours,
	case when t.PlannedHours-t.RollupActualHours <0 then 0 else t.PlannedHours-t.RollupActualHours end as TaskRemainingHours,
	case when t.PlannedHours=0 then 0 else t.RollupActualHours/t.PlannedHours end as TaskPercentComplete,
	cast(ta.PlannedFinish as date) as TaskAssignmentPlannedFinish,
	cast(ta.ActualFinish as date) as TaskAssignmentActualFinish,
	coalesce(ta.PlannedHours,0) as TaskAssignmentPlannedHours,
	coalesce(ta.ActualHours,0) as TaskAssignmentActualHours,
	coalesce(ta.RemainingHours,0) as TaskAssignmentRemainingHours,
	ta.PercentComplete as TaskAssignmentPercentComplete
from 
	Project p with (nolock)
		join 
	Tasks t with (nolock) on p.ProjectId=t.ProjectId
		join
	TaskAssignment ta with (nolock) on t.TaskId=ta.TaskId
		join
	Resources r with (nolock) on ta.ResourceId=r.ResourceId
		JOIN 
	managemember AS mm  WITH (NOLOCK) ON mm.CustomerId = p.CustomerId and mm.EngagementId=p.EngagementId and mm.ProjectId=p.ProjectId 
		JOIN 
	resources AS mmr  WITH (NOLOCK) ON mmr.resourceid=mm.resourceid
		join
	Engagement e with (nolock) on p.EngagementId=e.EngagementId
		join
	BillingOffice b with (nolock) on e.BillingOfficeId=b.BillingOfficeId
where
	ta.deleted=0
	and t.Milestone=1
	--and p.Name='Alliance of Chicago - Citrix Upgrade'

GO

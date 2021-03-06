USE [Changepoint]
GO
/****** Object:  View [dbo].[BG_EAC_ProjectPendingClose_CG]    Script Date: 10/18/2019 4:57:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[BG_EAC_ProjectPendingClose_CG] as 
SELECT
	p.Name as Project,
	p.ProjectId,
	p.ProjectStatus,
	coalesce(wd.Name, 'Active Project') as WorkflowProcess,
	coalesce(ws.Completed,0) as Completed
FROM
	Project p with (nolock)
		join
	WorkflowProcessInstance ws with (nolock) on p.ProjectId=ws.EntityId and ws.Entity='PROJECT'
		join
	WorkflowProcessDefinition wd with (nolock) on ws.WFDefinitionProcessId=wd.WorkflowProcessDefinitionId
where
	coalesce(ws.Completed,0)<>1
	--and wd.Name in ('Pending Close', 'Verify Time & Expense Approval')
	--and p.ProjectStatus='C'
	--and coalesce(wd.Name, 'No Active Workflow') not in ('Pending Close', 'No Active Workflow')
--order by
--	p.Name
GO

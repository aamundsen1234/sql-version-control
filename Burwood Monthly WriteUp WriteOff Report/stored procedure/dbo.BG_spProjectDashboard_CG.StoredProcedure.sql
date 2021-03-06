USE [Changepoint2018]
GO
/****** Object:  StoredProcedure [dbo].[BG_spProjectDashboard_CG]    Script Date: 10/11/2019 2:24:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[BG_spProjectDashboard_CG] AS

BEGIN

truncate table [BG_EngagementBillingRates_Table_CG]
insert into [BG_EngagementBillingRates_Table_CG] select * from [BG_EngagementBillingRates_All_CG]
--select * into BG_ProjectDashboard_Engagement_Closed_Table_CG from [BG_ProjectDashboard_Engagement_2018_CG] where EngagementStatus='Closed'

truncate table BG_ProjectDashboard_Engagement_Table_CG 
insert into BG_ProjectDashboard_Engagement_Table_CG select * from [BG_ProjectDashboard_Engagement_2018_CG] where EngagementStatus<>'Closed'
	
delete BG_ProjectDashboard_Resource_BillingRates_Table_CG where ProjectStatus<>'C'
insert into [BG_ProjectDashboard_Resource_BillingRates_Table_CG] select * from [BG_ProjectDashboard_Resource_BillingRates_CG] where ProjectStatus<>'C'

truncate table BG_EAC_Summary2018_Table_Temp_CG
insert into BG_EAC_Summary2018_Table_Temp_CG select * from BG_EAC_Summary2018_CG where ProjectStatus='Active'

truncate table BG_ProjectDashboard_EngagementProject_Comments_CG


	insert into BG_ProjectDashboard_EngagementProject_Comments_CG
	select
		e.Name as Engagement,
		e.EngagementId,
		p.Name as Project,
		p.ProjectId, 
		p.LabourBudget,
		p.BaselineHours as Hours,
		cast(p.BaselineStart as date) as StartDate,
		e.ContractNumber,
		coalesce(f.Number, 0) as CommentSequence, 
		coalesce(f.Item, p.Description) as Comments
	from 
		Engagement e with (nolock)
			join
		Project p with (nolock) on e.EngagementId=p.EngagementId
			cross apply dbo.BG_SplitStrings(p.Description, '-') as f




END


/*select
		e.Name as Engagement,
		e.EngagementId,
		p.Name as Project,
		p.ProjectId, 
		p.LabourBudget,
		p.BaselineHours as Hours,
		cast(p.BaselineStart as date) as StartDate,
		e.ContractNumber,
		coalesce(f.Number, 0) as CommentSequence, 
		coalesce(f.Item, p.Description) as Comments
 into BG_ProjectDashboard_EngagementProject_Comments_CG
	from 
		Engagement e with (nolock)
			join
		Project p with (nolock) on e.EngagementId=p.EngagementId
			cross apply dbo.BG_SplitStrings(p.Description, '-') as f*/
GO

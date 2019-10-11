USE [Changepoint2018]
GO
/****** Object:  StoredProcedure [dbo].[BG_spProjectDashboard_OnceDaily_CG]    Script Date: 10/11/2019 2:24:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[BG_spProjectDashboard_OnceDaily_CG] AS

BEGIN

--select * into BG_ProjectDashboard_Engagement_Closed_Table_CG from [BG_ProjectDashboard_Engagement_2018_CG] where EngagementStatus='Closed'

truncate table BG_ProjectDashboard_Engagement_Closed_Table_CG
insert into BG_ProjectDashboard_Engagement_Closed_Table_CG select * from BG_ProjectDashboard_Engagement_2018_CG where EngagementStatus='Closed'

truncate table [BG_ProjectDashboard_Resource_BillingRates_Table_CG]
insert into [BG_ProjectDashboard_Resource_BillingRates_Table_CG] select * from [BG_ProjectDashboard_Resource_BillingRates_CG] where ProjectStatus='C'


--select top 10 * from [BG_ProjectDashboard_Resource_BillingRates_CG]
--select top 10 * from [BG_ProjectDashboard_Resource_BillingRates_Table_CG]


END

--delete from [BG_ProjectDashboard_Resource_BillingRates_Table_CG] where ProjectStatus<>'C' 1003
GO

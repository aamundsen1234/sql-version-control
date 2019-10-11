USE [Changepoint2018]
GO
/****** Object:  View [dbo].[BG_ResourceWeeklyScheduleAcknowledgeSummary_PWApps]    Script Date: 10/11/2019 1:49:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[BG_ResourceWeeklyScheduleAcknowledgeSummary_PWApps] as
select
	distinct
	ResourceName,
	ResourceId,
	Resource,
	PeriodStartDate,
	PeriodEndDate,
	Comments,
	Acknowledge
from
	BG_ResourceWeeklyScheduleAcknowledgeDetail_PWApps



GO

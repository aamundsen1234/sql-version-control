USE [Changepoint]
GO
/****** Object:  StoredProcedure [dbo].[BG_spResourceQualificationsSnapshot_CG]    Script Date: 10/17/2019 3:46:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BG_spResourceQualificationsSnapshot_CG] AS

insert into BG_ResourceQualifications_Table_CG
	SELECT [Resource]
      ,[ResourceId]
      ,[Practice]
      ,[Workgroup]
      ,[Area]
      ,[Category]
      ,[Skill]
      ,case when [Rating] is NULL then '0' else Rating end as Rating
      ,cast(DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0) as date) as Updated
  FROM [Changepoint].[dbo].[BG_ResourceQualifications_CG]  
  where Rating is not null and Rating>1
 
GO

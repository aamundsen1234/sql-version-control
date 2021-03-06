USE [Changepoint]
GO
/****** Object:  View [dbo].[BG_SkillsByResource_CG_TAB]    Script Date: 10/17/2019 3:46:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[BG_SkillsByResource_CG_TAB] AS
SELECT resqual.[ResourceId]
      ,resqual.[Resource]
	  ,[Title]
      ,[Practice]
      ,[Workgroup]
      ,[Area]
      ,[Category]
      ,[Skill]
      ,[Rating]
      ,[Updated] as DateLastUpdated
  FROM [Changepoint].[dbo].[BG_ResourceQualifications_CG] as resqual,
       [Changepoint].[dbo].[BG_Resources_CG] as res
 WHERE resqual.ResourceID = res.ResourceID
GO

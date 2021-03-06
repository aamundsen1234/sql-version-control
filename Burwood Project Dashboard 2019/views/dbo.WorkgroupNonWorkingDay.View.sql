USE [Changepoint2018]
GO
/****** Object:  View [dbo].[WorkgroupNonWorkingDay]    Script Date: 10/10/2019 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WorkgroupNonWorkingDay]
AS 
SELECT 	w.WorkgroupId, nwds.NonWorkingDate 'NonWorkingDate'
FROM	Workgroup w  WITH (NOLOCK) , NonWorkingdaySettings nwds  WITH (NOLOCK) 
WHERE	nwds.Deleted = 0x0
		AND nwds.Type = 'SYS'
UNION
SELECT 	w.WorkgroupId, nwds.NonWorkingDate 'NonWorkingDate'
FROM	Workgroup w  WITH (NOLOCK) 			
		INNER JOIN NonWorkingdaySettings nwds  WITH (NOLOCK)  ON w.GlobalWorkgroupId = nwds.LevelId
WHERE	w.Deleted = 0x0
		AND nwds.Deleted = 0x0
UNION
SELECT 	w.WorkgroupId, nwds.NonWorkingDate 'NonWorkingDate'
FROM	Workgroup w  WITH (NOLOCK) 					
		INNER JOIN NonWorkingdaySettings nwds  WITH (NOLOCK)  ON w.WorkgroupId = nwds.LevelId
WHERE	w.Deleted = 0x0
		AND nwds.Deleted = 0x0
UNION
SELECT 	wr.ChildWorkgroupId, nwds.NonWorkingDate 'NonWorkingDate'  
FROM	Workgroup w  WITH (NOLOCK) 					
		INNER JOIN WorkgroupRelation wr  WITH (NOLOCK)  ON w.WorkgroupId = wr.ParentWorkgroupId		
		INNER JOIN NonWorkingdaySettings nwds  WITH (NOLOCK)  ON w.WorkgroupId = nwds.LevelId
WHERE	w.Deleted = 0x0
		AND w.IncludeChildren = 0x1
		AND nwds.Deleted = 0x0
UNION
SELECT	vrns.WorkgroupId, W.WorkingDate 'NonWorkingDate'
FROM	WorkgroupNonWorkingDaySettings vrns 
		INNER JOIN Workingdays w  WITH (NOLOCK)  ON 
		CASE
			WHEN DATEPART(DW,w.WorkingDate)+@@DATEFIRST>7 THEN 
				POWER(2,DATEPART(DW,w.WorkingDate)+@@DATEFIRST-8) 
			ELSE 
				POWER(2,DATEPART(DW,w.WorkingDate) + @@DATEFIRST - 1) 
		END & vrns.NonWorkingDay > 0

GO

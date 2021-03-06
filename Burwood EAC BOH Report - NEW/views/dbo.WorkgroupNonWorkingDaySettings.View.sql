USE [Changepoint]
GO
/****** Object:  View [dbo].[WorkgroupNonWorkingDaySettings]    Script Date: 10/14/2019 3:05:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WorkgroupNonWorkingDaySettings]
 
AS 
SELECT	wnwd.WorkgroupId, max(wnwd.Sunday) + max(wnwd.Monday) + max(wnwd.Tuesday) + max(wnwd.Wednesday) + max(wnwd.Thursday) + max(wnwd.Friday) + max(wnwd.Saturday) 'NonWorkingDay'
FROM	(
			
			SELECT 	w.WorkgroupId,  1 & s.NonWorkingDay 'Sunday', 2 & s.NonWorkingDay 'Monday', 4 & s.NonWorkingDay 'Tuesday', 
					8 & s.NonWorkingDay 'Wednesday', 16 & s.NonWorkingDay 'Thursday', 32 & s.NonWorkingDay 'Friday', 
					64 & s.NonWorkingDay 'Saturday'
			FROM	Workgroup w  WITH (NOLOCK) , ServerSettings s  WITH (NOLOCK) 	
			UNION ALL
			
			SELECT 	w.WorkgroupId,  1 & gw.NonWorkingDay 'Sunday', 2 & gw.NonWorkingDay 'Monday', 4 & gw.NonWorkingDay 'Tuesday', 
					8 & gw.NonWorkingDay 'Wednesday', 16 & gw.NonWorkingDay 'Thursday', 32 & gw.NonWorkingDay 'Friday', 
					64 & gw.NonWorkingDay 'Saturday'
			FROM	GlobalWorkgroup gw  WITH (NOLOCK) 
					INNER JOIN Workgroup w  WITH (NOLOCK)  ON gw.GlobalWorkgroupId = w.GlobalWorkgroupId
			WHERE	w.Deleted = 0x0
					AND gw.Deleted = 0x0	
			UNION ALL
			
			SELECT 	w.WorkgroupId,  1 & w.NonWorkingDay 'Sunday', 2 & w.NonWorkingDay 'Monday', 4 & w.NonWorkingDay 'Tuesday', 
					8 & w.NonWorkingDay 'Wednesday', 16 & w.NonWorkingDay 'Thursday', 32 & w.NonWorkingDay 'Friday', 
					64 & w.NonWorkingDay 'Saturday'
			FROM	Workgroup w  WITH (NOLOCK) 					
			WHERE	w.Deleted =0x0		
			UNION ALL
			
			SELECT 	wr.ChildWorkgroupId 'WorkgroupId',  1 & w.NonWorkingDay 'Sunday', 2 & w.NonWorkingDay 'Monday', 4 & w.NonWorkingDay 'Tuesday', 
					8 & w.NonWorkingDay 'Wednesday', 16 & w.NonWorkingDay 'Thursday', 32 & w.NonWorkingDay 'Friday', 
					64 & w.NonWorkingDay 'Saturday'
			FROM	Workgroup w  WITH (NOLOCK) 					
					INNER JOIN WorkgroupRelation wr  WITH (NOLOCK)  ON w.WorkgroupId = wr.ParentWorkgroupID					
			WHERE	w.Deleted = 0x0
					AND w.IncludeChildren = 0x1
		) wnwd
GROUP BY wnwd.WorkgroupId

GO

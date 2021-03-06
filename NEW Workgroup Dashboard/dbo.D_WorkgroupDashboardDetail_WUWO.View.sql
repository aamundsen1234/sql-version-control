USE [Changepoint]
GO
/****** Object:  View [dbo].[D_WorkgroupDashboardDetail_WUWO]    Script Date: 2/11/2020 4:26:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[D_WorkgroupDashboardDetail_WUWO]
AS
--Get time for non-Contractors where RateTimesHours is Revenue
/*
SELECT		'Time' AS DetailType, t.ResourceID, t.CustomerId, t.EngagementId, t.ProjectId, t.TimeDate AS Date, t.Name AS EngagementName, r.Name AS ResourceName,
			(t.RegularHours + t.OvertimeHours) AS Hours, t.Billable, t.HourlyCostRate, t.BillingRate, t.RevRec, t.RateTimesHours, NULL AS WorkgroupName, p.Name AS ProjectName
FROM		dbo.D_Time_and_WriteOff t WITH (nolock)
INNER JOIN	dbo.Resources r WITH (nolock) ON t.ResourceId = r.ResourceId AND r.EmployeeType <> 'CO'
LEFT OUTER JOIN dbo.Project p WITH (nolock) ON t.ProjectId = p.ProjectId
WHERE		ISNULL(t.BatchNumber, 'RR-') LIKE 'RR-%' AND t.TimeDate >= '2019-01-01'

UNION ALL

--Get time for Contractors where RateTimesHours is Margin
SELECT		'Time' AS DetailType, t.ResourceID, t.CustomerId, t.EngagementId, t.ProjectId, t.TimeDate AS Date, t.Name AS EngagementName, r.Name AS ResourceName,
			(t.RegularHours + t.OvertimeHours) AS Hours, t.Billable, 
			CASE
				WHEN t.HourlyCostRate = 0 THEN rr.HourlyCostRate
				ELSE t.HourlyCostRate
			END AS HourlyCostRate, 
			t.BillingRate, t.RevRec, 
			CASE
				WHEN t.HourlyCostRate = 0 THEN ((t.RegularHours + t.OvertimeHours)*(t.BillingRate - rr.HourlyCostRate))
				ELSE ((t.RegularHours + t.OvertimeHours)*(t.BillingRate - t.HourlyCostRate))
			END AS RateTimesHours, NULL AS WorkgroupName, p.Name AS ProjectName
FROM		dbo.D_Time_and_WriteOff t WITH (nolock)
INNER JOIN	dbo.Resources r WITH (nolock) ON t.ResourceId = r.ResourceId AND r.EmployeeType = 'CO'
INNER JOIN ResourceRate rr WITH (nolock) ON r.ResourceId = rr.ResourceId AND rr.Active = 1
LEFT OUTER JOIN dbo.Project p WITH (nolock) ON t.ProjectId = p.ProjectId
WHERE		ISNULL(t.BatchNumber, 'RR-') LIKE 'RR-%' AND t.TimeDate >= '2019-01-01'

UNION ALL
*/
-- Get Write-Up/Write-Off amount allocated to each employee based on hours worked on the entire engagement
SELECT		'Write-Up' AS DetailType, w.ResourceID, w.CustomerId, w.EngagementId, NULL AS ProjectId, w.PostingDate AS Date, w.Name AS EngagementName, r.Name AS ResourceName, 
			0 AS Hours, 1 AS Billable, NULL AS HourlyCostRate, 
			NULL AS BillingRate, w.ResourceAmount AS RevRec, w.ResourceAmount AS RateTimesHours, NULL AS WorkgroupName, NULL AS ProjectName
FROM		dbo.D_WriteUpsByResource w WITH (nolock)
INNER JOIN	dbo.Resources r WITH (nolock) ON w.ResourceId = r.ResourceId
WHERE		PostingDate >= '2019-01-01'
/*
UNION ALL

/*
-------------- Non-Workgroup Contractors section
-- Retrieve Non-Workgroup Contractors associated with Engagements tagged to the Parent Staffing Workgroup
SELECT 'Non-Workgroup Contractors' AS DetailType, '00000000-0000-0000-0000-000000000000' AS ResourceId, t.CustomerId, t.EngagementId, t.ProjectId, t.TimeDate AS Date, e.Name AS EngagementName, r.Name AS ResourceName, 
	(t.RegularHours + t.OvertimeHours) AS Hours, t.Billable, 
	CASE
		WHEN ISNULL(t.HourlyCostRate, 0) = 0 THEN rr.HourlyCostRate
		ELSE t.HourlyCostRate
	END AS HourlyCostRate, 
	t.BillingRate, t.RevRec, 
	CASE
		WHEN ISNULL(t.HourlyCostRate, 0) = 0 THEN ((t.RegularHours + t.OvertimeHours)*(t.BillingRate - rr.HourlyCostRate))
		ELSE ((t.RegularHours + t.OvertimeHours)*(t.BillingRate - t.HourlyCostRate))
	END AS RateTimesHours, 
	w.Name AS WorkgroupName, p.Name AS ProjectName
FROM Engagement e WITH (nolock)
INNER JOIN Time t WITH (nolock) ON e.EngagementId = t.EngagementId
INNER JOIN Resources r WITH (nolock) ON t.ResourceId = r.ResourceId AND r.EmployeeType = 'CO'
INNER JOIN Workgroup w WITH (nolock) ON e.AssociatedWorkgroup = w.WorkgroupId 
INNER JOIN WorkgroupMember m WITH (nolock) ON r.ResourceId = m.ResourceId AND m.Historical = 0
INNER JOIN Workgroup w2 WITH (nolock) ON m.WorkgroupId = w2.WorkgroupId
LEFT OUTER JOIN Workgroup w3 WITH (nolock) ON w2.Parent = w3.WorkgroupId
LEFT OUTER JOIN Workgroup w4 WITH (nolock) ON w3.Parent = w4.WorkgroupId
INNER JOIN ResourceRate rr WITH (nolock) ON r.ResourceId = rr.ResourceId AND rr.Active = 1
LEFT OUTER JOIN dbo.Project p WITH (nolock) ON t.ProjectId = p.ProjectId
WHERE (ISNULL(w2.Name, '') <> ISNULL(w.Name, '') AND ISNULL(w3.Name, '') <> ISNULL(w.Name, '') AND ISNULL(w4.Name, '') <> ISNULL(w.Name, '')) AND t.TimeDate >= '2019-01-01'

UNION ALL

-- Retrieve Non-Workgroup Contractors associated with Engagements tagged to the Child Staffing Workgroup
SELECT 'Non-Workgroup Contractors' AS DetailType, '00000000-0000-0000-0000-000000000000' AS ResourceId, t.CustomerId, t.EngagementId, t.ProjectId, t.TimeDate AS Date, e.Name AS EngagementName, r.Name AS ResourceName, 
	(t.RegularHours + t.OvertimeHours) AS Hours, t.Billable, 
	CASE
		WHEN ISNULL(t.HourlyCostRate, 0) = 0 THEN rr.HourlyCostRate
		ELSE t.HourlyCostRate
	END AS HourlyCostRate, 
	t.BillingRate, t.RevRec, 
	CASE
		WHEN ISNULL(t.HourlyCostRate, 0) = 0 THEN ((t.RegularHours + t.OvertimeHours)*(t.BillingRate - rr.HourlyCostRate))
		ELSE ((t.RegularHours + t.OvertimeHours)*(t.BillingRate - t.HourlyCostRate))
	END AS RateTimesHours, 
	wp.Name AS WorkgroupName, p.Name AS ProjectName
FROM Engagement e WITH (nolock)
INNER JOIN Time t WITH (nolock) ON e.EngagementId = t.EngagementId
INNER JOIN Resources r WITH (nolock) ON t.ResourceId = r.ResourceId AND r.EmployeeType = 'CO'
INNER JOIN Workgroup w WITH (nolock) ON e.AssociatedWorkgroup = w.WorkgroupId 
INNER JOIN Workgroup wp WITH (nolock) ON w.Parent = wp.WorkgroupId 
INNER JOIN WorkgroupMember m WITH (nolock) ON r.ResourceId = m.ResourceId AND m.Historical = 0
INNER JOIN Workgroup w2 WITH (nolock) ON m.WorkgroupId = w2.WorkgroupId
LEFT OUTER JOIN Workgroup w3 WITH (nolock) ON w2.Parent = w3.WorkgroupId
LEFT OUTER JOIN Workgroup w4 WITH (nolock) ON w3.Parent = w4.WorkgroupId
INNER JOIN ResourceRate rr WITH (nolock) ON r.ResourceId = rr.ResourceId AND rr.Active = 1
LEFT OUTER JOIN dbo.Project p WITH (nolock) ON t.ProjectId = p.ProjectId
WHERE (ISNULL(w2.Name, '') <> ISNULL(w.Name, '') AND ISNULL(w3.Name, '') <> ISNULL(w.Name, '') AND ISNULL(w4.Name, '') <> ISNULL(w.Name, '')) AND t.TimeDate >= '2019-01-01'

UNION ALL

-- Retrieve Non-Workgroup Contractors associated with Engagements tagged to the Child of a Child Staffing Workgroup
SELECT 'Non-Workgroup Contractors' AS DetailType, '00000000-0000-0000-0000-000000000000' AS ResourceId, t.CustomerId, t.EngagementId, t.ProjectId, t.TimeDate AS Date, e.Name AS EngagementName, r.Name AS ResourceName, 
	(t.RegularHours + t.OvertimeHours) AS Hours, t.Billable, 
	CASE
		WHEN ISNULL(t.HourlyCostRate, 0) = 0 THEN rr.HourlyCostRate
		ELSE t.HourlyCostRate
	END AS HourlyCostRate, 
	t.BillingRate, t.RevRec, 
	CASE
		WHEN ISNULL(t.HourlyCostRate, 0) = 0 THEN ((t.RegularHours + t.OvertimeHours)*(t.BillingRate - rr.HourlyCostRate))
		ELSE ((t.RegularHours + t.OvertimeHours)*(t.BillingRate - t.HourlyCostRate))
	END AS RateTimesHours, 
	wp2.Name AS WorkgroupName, p.Name AS ProjectName
FROM Engagement e WITH (nolock)
INNER JOIN Time t WITH (nolock) ON e.EngagementId = t.EngagementId
INNER JOIN Resources r WITH (nolock) ON t.ResourceId = r.ResourceId AND r.EmployeeType = 'CO'
INNER JOIN Workgroup w WITH (nolock) ON e.AssociatedWorkgroup = w.WorkgroupId 
INNER JOIN Workgroup wp WITH (nolock) ON w.Parent = wp.WorkgroupId 
INNER JOIN Workgroup wp2 WITH (nolock) ON wp.Parent = wp2.WorkgroupId 
INNER JOIN WorkgroupMember m WITH (nolock) ON r.ResourceId = m.ResourceId AND m.Historical = 0
INNER JOIN Workgroup w2 WITH (nolock) ON m.WorkgroupId = w2.WorkgroupId
LEFT OUTER JOIN Workgroup w3 WITH (nolock) ON w2.Parent = w3.WorkgroupId
LEFT OUTER JOIN Workgroup w4 WITH (nolock) ON w3.Parent = w4.WorkgroupId
INNER JOIN ResourceRate rr WITH (nolock) ON r.ResourceId = rr.ResourceId AND rr.Active = 1
LEFT OUTER JOIN dbo.Project p WITH (nolock) ON t.ProjectId = p.ProjectId
WHERE (ISNULL(w2.Name, '') <> ISNULL(w.Name, '') AND ISNULL(w3.Name, '') <> ISNULL(w.Name, '') AND ISNULL(w4.Name, '') <> ISNULL(w.Name, '')) AND t.TimeDate >= '2019-01-01'

UNION ALL
-------------------------------------------
*/

-- Get the margin for Associates in the 'Associates' workgrooup that have hours on an engagement tagged to the workgroup through the 'Staffing Workgroup' field in the engagement
SELECT 'Associates' AS DetailType, '00000000-0000-0000-0000-000000000000' AS ResourceId, t.CustomerId, t.EngagementId, t.ProjectId, t.TimeDate AS Date, e.Name AS EngagementName, r.Name AS ResourceName, 
	(t.RegularHours + t.OvertimeHours) AS Hours, t.Billable, 
	CASE
		WHEN ISNULL(t.HourlyCostRate, 0) = 0 THEN rr.HourlyCostRate
		ELSE t.HourlyCostRate
	END AS HourlyCostRate, 
	t.BillingRate, t.RevRec, 
	CASE
		WHEN ISNULL(t.HourlyCostRate, 0) = 0 THEN ((t.RegularHours + t.OvertimeHours)*(t.BillingRate - rr.HourlyCostRate))
		ELSE ((t.RegularHours + t.OvertimeHours)*(t.BillingRate - t.HourlyCostRate))
	END AS RateTimesHours, 
	w.Name AS WorkgroupName, p.Name AS ProjectName
FROM Engagement e WITH (nolock)
INNER JOIN Time t WITH (nolock) ON e.EngagementId = t.EngagementId
INNER JOIN Resources r WITH (nolock) ON t.ResourceId = r.ResourceId
INNER JOIN Workgroup w WITH (nolock) ON e.AssociatedWorkgroup = w.WorkgroupId
INNER JOIN WorkgroupMember m WITH (nolock) ON r.ResourceId = m.ResourceId AND m.WorkgroupId = '702985ab-f8fb-44e4-829b-61c80454104f' AND m.Historical = 0
INNER JOIN ResourceRate rr WITH (nolock) ON r.ResourceId = rr.ResourceId AND rr.Active = 1
LEFT OUTER JOIN dbo.Project p WITH (nolock) ON t.ProjectId = p.ProjectId

UNION ALL

-- Get the margin for Associates in the 'Associates' workgrooup that have hours on an engagement tagged to the workgroup through the 'Staffing Workgroup' field in the engagement - Child
SELECT 'Associates' AS DetailType, '00000000-0000-0000-0000-000000000000' AS ResourceId, t.CustomerId, t.EngagementId, t.ProjectId, t.TimeDate AS Date, e.Name AS EngagementName, r.Name AS ResourceName, 
	(t.RegularHours + t.OvertimeHours) AS Hours, t.Billable, 
	CASE
		WHEN ISNULL(t.HourlyCostRate, 0) = 0 THEN rr.HourlyCostRate
		ELSE t.HourlyCostRate
	END AS HourlyCostRate, 
	t.BillingRate, t.RevRec, 
	CASE
		WHEN ISNULL(t.HourlyCostRate, 0) = 0 THEN ((t.RegularHours + t.OvertimeHours)*(t.BillingRate - rr.HourlyCostRate))
		ELSE ((t.RegularHours + t.OvertimeHours)*(t.BillingRate - t.HourlyCostRate))
	END AS RateTimesHours, 
	wp.Name AS WorkgroupName, p.Name AS ProjectName
FROM Engagement e WITH (nolock)
INNER JOIN Time t WITH (nolock) ON e.EngagementId = t.EngagementId
INNER JOIN Resources r WITH (nolock) ON t.ResourceId = r.ResourceId
INNER JOIN Workgroup w WITH (nolock) ON e.AssociatedWorkgroup = w.WorkgroupId
LEFT OUTER JOIN Workgroup wp WITH (nolock) ON wp.WorkgroupId = w.Parent AND wp.Deleted = 0
INNER JOIN WorkgroupMember m WITH (nolock) ON r.ResourceId = m.ResourceId AND m.WorkgroupId = '702985ab-f8fb-44e4-829b-61c80454104f' AND m.Historical = 0
INNER JOIN ResourceRate rr WITH (nolock) ON r.ResourceId = rr.ResourceId AND rr.Active = 1
LEFT OUTER JOIN dbo.Project p WITH (nolock) ON t.ProjectId = p.ProjectId
WHERE wp.Name IS NOT NULL

UNION ALL

-- Get the margin for Associates in the 'Associates' workgrooup that have hours on an engagement tagged to the workgroup through the 'Staffing Workgroup' field in the engagement - Child of Child
SELECT 'Associates' AS DetailType, '00000000-0000-0000-0000-000000000000' AS ResourceId, t.CustomerId, t.EngagementId, t.ProjectId, t.TimeDate AS Date, e.Name AS EngagementName, r.Name AS ResourceName, 
	(t.RegularHours + t.OvertimeHours) AS Hours, t.Billable, 
	CASE
		WHEN ISNULL(t.HourlyCostRate, 0) = 0 THEN rr.HourlyCostRate
		ELSE t.HourlyCostRate
	END AS HourlyCostRate, 
	t.BillingRate, t.RevRec, 
	CASE
		WHEN ISNULL(t.HourlyCostRate, 0) = 0 THEN ((t.RegularHours + t.OvertimeHours)*(t.BillingRate - rr.HourlyCostRate))
		ELSE ((t.RegularHours + t.OvertimeHours)*(t.BillingRate - t.HourlyCostRate))
	END AS RateTimesHours, 
	wp2.Name AS WorkgroupName, p.Name AS ProjectName
FROM Engagement e WITH (nolock)
INNER JOIN Time t WITH (nolock) ON e.EngagementId = t.EngagementId
INNER JOIN Resources r WITH (nolock) ON t.ResourceId = r.ResourceId
INNER JOIN Workgroup w WITH (nolock) ON e.AssociatedWorkgroup = w.WorkgroupId
LEFT OUTER JOIN Workgroup wp WITH (nolock) ON wp.WorkgroupId = w.Parent AND wp.Deleted = 0
LEFT OUTER JOIN Workgroup wp2 WITH (nolock) ON wp2.WorkgroupId = wp.Parent AND wp2.Deleted = 0
INNER JOIN WorkgroupMember m WITH (nolock) ON r.ResourceId = m.ResourceId AND m.WorkgroupId = '702985ab-f8fb-44e4-829b-61c80454104f' AND m.Historical = 0
INNER JOIN ResourceRate rr WITH (nolock) ON r.ResourceId = rr.ResourceId AND rr.Active = 1
LEFT OUTER JOIN dbo.Project p WITH (nolock) ON t.ProjectId = p.ProjectId
WHERE wp2.Name IS NOT NULL

UNION ALL

--Retrieve the Revenue Adjustments for Engagements tagged to the workgroup through the 'Staffing Workgroup' field in the engagement with Reason Code - Fixed Fee Contractor Margin
SELECT 'Fixed Fee Contractors' AS DetailType, '00000000-0000-0000-0000-000000000000' AS ResourceId, e.CustomerId, r.EngagementId, NULL AS ProjectId, r.PostingDate AS Date, e.Name AS EngagementName, 
	'FF Contractor Margin' AS ResourceName, 0 AS Hours, 1 AS Billable, NULL AS HourlyCostRate, NULL AS BillingRate, r.RevenueAmount AS RevRec, r.RevenueAmount AS RateTimesHours, 
	w.Name AS WorkgroupName, NULL AS ProjectName
FROM Engagement e WITH (nolock)
INNER JOIN RevenueDetail r WITH (nolock) ON e.EngagementId = r.EngagementId AND ReasonCode = 'd4c4b9a6-2699-415b-bb28-5579e78e428b'
INNER JOIN Workgroup w WITH (nolock) ON e.AssociatedWorkgroup = w.WorkgroupId 
WHERE PostingDate >= '2019-01-01'

UNION ALL

--Retrieve the Revenue Adjustments for Engagements tagged to the workgroup through the 'Staffing Workgroup' field in the engagement with Reason Code - Fixed Fee Contractor Margin - Child
SELECT 'Fixed Fee Contractors' AS DetailType, '00000000-0000-0000-0000-000000000000' AS ResourceId, e.CustomerId, r.EngagementId, NULL AS ProjectId, r.PostingDate AS Date, e.Name AS EngagementName, 
	'FF Contractor Margin' AS ResourceName, 0 AS Hours, 1 AS Billable, NULL AS HourlyCostRate, NULL AS BillingRate, r.RevenueAmount AS RevRec, r.RevenueAmount AS RateTimesHours, 
	wp.Name AS WorkgroupName, NULL AS ProjectName
FROM Engagement e WITH (nolock)
INNER JOIN RevenueDetail r WITH (nolock) ON e.EngagementId = r.EngagementId AND ReasonCode = 'd4c4b9a6-2699-415b-bb28-5579e78e428b'
INNER JOIN Workgroup w WITH (nolock) ON e.AssociatedWorkgroup = w.WorkgroupId 
LEFT OUTER JOIN Workgroup wp WITH (nolock) ON wp.WorkgroupId = w.Parent AND wp.Deleted = 0
WHERE wp.Name IS NOT NULL AND PostingDate >= '2019-01-01'

UNION ALL

--Retrieve the Revenue Adjustments for Engagements tagged to the workgroup through the 'Staffing Workgroup' field in the engagement with Reason Code - Fixed Fee Contractor Margin - Child of Child
SELECT 'Fixed Fee Contractors' AS DetailType, '00000000-0000-0000-0000-000000000000' AS ResourceId, e.CustomerId, r.EngagementId, NULL AS ProjectId, r.PostingDate AS Date, e.Name AS EngagementName, 
	'FF Contractor Margin' AS ResourceName, 0 AS Hours, 1 AS Billable, NULL AS HourlyCostRate, NULL AS BillingRate, r.RevenueAmount AS RevRec, r.RevenueAmount AS RateTimesHours, 
	wp2.Name AS WorkgroupName, NULL AS ProjectName
FROM Engagement e WITH (nolock)
INNER JOIN RevenueDetail r WITH (nolock) ON e.EngagementId = r.EngagementId AND ReasonCode = 'd4c4b9a6-2699-415b-bb28-5579e78e428b'
INNER JOIN Workgroup w WITH (nolock) ON e.AssociatedWorkgroup = w.WorkgroupId 
LEFT OUTER JOIN Workgroup wp WITH (nolock) ON wp.WorkgroupId = w.Parent AND wp.Deleted = 0
LEFT OUTER JOIN Workgroup wp2 WITH (nolock) ON wp2.WorkgroupId = wp.Parent AND wp2.Deleted = 0
WHERE wp2.Name IS NOT NULL AND PostingDate >= '2019-01-01'
*/
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "ActivityStatus"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'D_WorkgroupDashboardDetail_WUWO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'D_WorkgroupDashboardDetail_WUWO'
GO

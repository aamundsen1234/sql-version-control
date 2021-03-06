USE [Changepoint]
GO
/****** Object:  View [dbo].[PBI_WorkgroupDashboardDetail]    Script Date: 2/11/2020 4:26:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW [dbo].[PBI_WorkgroupDashboardDetail]
AS
--Get time for non-Contractors where RateTimesHours is Revenue 
SELECT 'Time'                               AS DetailType, 
       t.resourceid, 
       t.customerid, 
       t.engagementid, 
       t.projectid, 
       t.timedate                           AS Date, 
       t.NAME                               AS EngagementName, 
       r.NAME                               AS ResourceName, 
       ra.emailaddress                      AS ResourceEmail, 
       ( t.regularhours + t.overtimehours ) AS Hours, 
       t.billable, 
       t.hourlycostrate, 
       t.billingrate, 
       t.revrec, 
       t.ratetimeshours, 
       w.workgroupid                        AS WorkgroupID, 
       w.workgroup                          AS WorkgroupName, 
       p.NAME                               AS ProjectName, 
       r.NAME 
       + Cast(w.workgroupid AS VARCHAR(36)) AS WorkgroupResourceId 
FROM   dbo.d_time_and_writeoff t WITH (nolock) 
       INNER JOIN dbo.resources r WITH (nolock) 
               ON t.resourceid = r.resourceid 
                  AND r.employeetype <> 'CO' 
       JOIN resourceaddress ra 
         ON r.resourceid = ra.resourceid 
       LEFT JOIN [dbo].[PBI_ResourcesByWorkgroup] w WITH (nolock) 
              ON t.resourceid = w.resourceid 
       LEFT OUTER JOIN dbo.project p WITH (nolock) 
                    ON t.projectid = p.projectid 
WHERE  Isnull(t.batchnumber, 'RR-') LIKE 'RR-%' 
       AND t.timedate >= '2019-01-01' 
       AND ( t.timedate >= w.hiredate 
             AND t.timedate <= w.terminationdate ) 
       AND w.workgroup IS NOT NULL 
UNION ALL 
--Get time for Contractors where RateTimesHours is Margin 
SELECT 'Time'                               AS DetailType, 
       t.resourceid, 
       t.customerid, 
       t.engagementid, 
       t.projectid, 
       t.timedate                           AS Date, 
       t.NAME                               AS EngagementName, 
       r.NAME                               AS ResourceName, 
       ra.emailaddress                      AS ResourceEmail, 
       ( t.regularhours + t.overtimehours ) AS Hours, 
       t.billable, 
       CASE 
         WHEN t.hourlycostrate = 0 THEN rr.hourlycostrate 
         ELSE t.hourlycostrate 
       END                                  AS HourlyCostRate, 
       t.billingrate, 
       t.revrec, 
       CASE 
         WHEN t.hourlycostrate = 0 THEN ( 
         ( t.regularhours + t.overtimehours ) * ( 
         t.billingrate - rr.hourlycostrate ) ) 
         ELSE ( ( t.regularhours + t.overtimehours ) * ( 
                t.billingrate - t.hourlycostrate ) ) 
       END                                  AS RateTimesHours, 
       w.workgroupid                        AS WorkgroupID, 
       w.workgroup                          AS WorkgroupName, 
       p.NAME                               AS ProjectName, 
       r.NAME 
       + Cast(w.workgroupid AS VARCHAR(36)) AS WorkgroupResourceId 
FROM   dbo.d_time_and_writeoff t WITH (nolock) 
       INNER JOIN dbo.resources r WITH (nolock) 
               ON t.resourceid = r.resourceid 
                  AND r.employeetype = 'CO' 
       JOIN resourceaddress ra 
         ON r.resourceid = ra.resourceid 
       LEFT JOIN [dbo].[PBI_ResourcesByWorkgroup] w WITH (nolock) 
              ON t.resourceid = w.resourceid 
       INNER JOIN resourcerate rr WITH (nolock) 
               ON r.resourceid = rr.resourceid 
                  AND rr.active = 1 
       LEFT OUTER JOIN dbo.project p WITH (nolock) 
                    ON t.projectid = p.projectid 
WHERE  Isnull(t.batchnumber, 'RR-') LIKE 'RR-%' 
       AND t.timedate >= '2019-01-01' 
       AND ( t.timedate >= w.hiredate 
             AND t.timedate <= w.terminationdate ) 
       AND w.workgroup IS NOT NULL 
UNION ALL 
-- Get Write-Up/Write-Off amount allocated to each employee based on hours worked on the entire engagement 
SELECT 'Write-Up/Overage'                           AS DetailType, 
       w.resourceid, 
       w.customerid, 
       w.engagementid, 
       NULL                                 AS ProjectId, 
       w.postingdate                        AS Date, 
       w.NAME                               AS EngagementName, 
       r.NAME                               AS ResourceName, 
       ra.emailaddress                      AS ResourceEmail, 
       0                                    AS Hours, 
       1                                    AS Billable, 
       NULL                                 AS HourlyCostRate, 
       NULL                                 AS BillingRate, 
       w.resourceamount                     AS RevRec, 
       w.resourceamount                     AS RateTimesHours, 
       wg.workgroupid                       AS WorkgroupID, 
       wg.workgroup                         AS WorkgroupName, 
       NULL                                 AS ProjectName, 
       r.NAME 
       + Cast(wg.workgroupid AS VARCHAR(36)) AS WorkgroupResourceId 
FROM   dbo.d_writeupsbyresource w WITH (nolock) 
       INNER JOIN dbo.resources r WITH (nolock) 
               ON w.resourceid = r.resourceid 
       JOIN resourceaddress ra 
         ON r.resourceid = ra.resourceid 
       LEFT JOIN [dbo].[PBI_ResourcesByWorkgroup] wg WITH (nolock) 
               ON w.resourceid = wg.resourceid 
	   WHERE  postingdate >= '2019-01-01'        
       AND (w.postingdate >= wg.hiredate
	   AND wg.terminationdate = (SELECT MAX(terminationdate) FROM [dbo].[PBI_ResourcesByWorkgroup] WHERE resourceid = r.ResourceId AND HireDate < w.postingdate))
       AND wg.workgroup IS NOT NULL
UNION ALL 
-- Get the margin for Associates in the 'Associates' workgrooup that have hours on an engagement tagged to the workgroup through the 'Staffing Workgroup' field in the engagement
SELECT 'Associates'                         AS DetailType, 
       r.resourceid                         AS ResourceId, 
       t.customerid, 
       t.engagementid, 
       t.projectid, 
       t.timedate                           AS Date, 
       e.NAME                               AS EngagementName, 
       r.NAME                               AS ResourceName, 
       ra.emailaddress                      AS ResourceEmail, 
       ( t.regularhours + t.overtimehours ) AS Hours, 
       t.billable, 
       CASE 
         WHEN Isnull(t.hourlycostrate, 0) = 0 THEN rr.hourlycostrate 
         ELSE t.hourlycostrate 
       END                                  AS HourlyCostRate, 
       t.billingrate, 
       t.revrec, 
       CASE 
         WHEN Isnull(t.hourlycostrate, 0) = 0 THEN ( 
         ( t.regularhours + t.overtimehours ) * ( 
         t.billingrate - rr.hourlycostrate ) ) 
         ELSE ( ( t.regularhours + t.overtimehours ) * ( 
                t.billingrate - t.hourlycostrate ) ) 
       END                                  AS RateTimesHours, 
       w.workgroupid                        AS WorkgroupID, 
       w.NAME                               AS WorkgroupName, 
       p.NAME                               AS ProjectName, 
       'Associate' 
       + Cast(w.workgroupid AS VARCHAR(36)) AS WorkgroupResourceId 
FROM   engagement e WITH (nolock) 
       INNER JOIN time t WITH (nolock) 
               ON e.engagementid = t.engagementid 
       INNER JOIN resources r WITH (nolock) 
               ON t.resourceid = r.resourceid 
       JOIN resourceaddress ra 
         ON r.resourceid = ra.resourceid 
       INNER JOIN workgroup w WITH (nolock) 
               ON e.associatedworkgroup = w.workgroupid 
        INNER JOIN workgrouphistorymember m WITH (nolock) 
               ON r.resourceid = m.resourceid 
                  AND m.workgroupid = '702985ab-f8fb-44e4-829b-61c80454104f' 
                  AND ( t.timedate >= m.EffectiveDate 
                        AND t.timedate <= ISNULL (m.enddate, '2099-12-31')  ) 
       INNER JOIN resourcerate rr WITH (nolock) 
               ON r.resourceid = rr.resourceid 
                  AND rr.active = 1 
       LEFT OUTER JOIN dbo.project p WITH (nolock) 
                    ON t.projectid = p.projectid 
WHERE  t.timedate >= '2019-01-01' 
UNION ALL 
-- Get the margin for Associates in the 'Associates' workgrooup that have hours on an engagement tagged to the workgroup through the 'Staffing Workgroup' field in the engagement - Child
SELECT 'Associates'                          AS DetailType, 
       r.resourceid                          AS ResourceId, 
       t.customerid, 
       t.engagementid, 
       t.projectid, 
       t.timedate                            AS Date, 
       e.NAME                                AS EngagementName, 
       r.NAME                                AS ResourceName, 
       ra.emailaddress                       AS ResourceEmail, 
       ( t.regularhours + t.overtimehours )  AS Hours, 
       t.billable, 
       CASE 
         WHEN Isnull(t.hourlycostrate, 0) = 0 THEN rr.hourlycostrate 
         ELSE t.hourlycostrate 
       END                                   AS HourlyCostRate, 
       t.billingrate, 
       t.revrec, 
       CASE 
         WHEN Isnull(t.hourlycostrate, 0) = 0 THEN ( 
         ( t.regularhours + t.overtimehours ) * ( 
         t.billingrate - rr.hourlycostrate ) ) 
         ELSE ( ( t.regularhours + t.overtimehours ) * ( 
                t.billingrate - t.hourlycostrate ) ) 
       END                                   AS RateTimesHours, 
       wp.workgroupid                        AS WorkgroupID, 
       wp.NAME                               AS WorkgroupName, 
       p.NAME                                AS ProjectName, 
       'Associate' 
       + Cast(wp.workgroupid AS VARCHAR(36)) AS WorkgroupResourceId 
FROM   engagement e WITH (nolock) 
       INNER JOIN time t WITH (nolock) 
               ON e.engagementid = t.engagementid 
       INNER JOIN resources r WITH (nolock) 
               ON t.resourceid = r.resourceid 
       JOIN resourceaddress ra 
         ON r.resourceid = ra.resourceid 
       INNER JOIN workgroup w WITH (nolock) 
               ON e.associatedworkgroup = w.workgroupid 
       LEFT OUTER JOIN workgroup wp WITH (nolock) 
                    ON wp.workgroupid = w.parent 
                       AND wp.deleted = 0 
       INNER JOIN workgrouphistorymember m WITH (nolock) 
               ON r.resourceid = m.resourceid 
                  AND m.workgroupid = '702985ab-f8fb-44e4-829b-61c80454104f' 
                  AND ( t.timedate >= m.EffectiveDate 
                        AND t.timedate <= ISNULL (m.enddate, '2099-12-31')  ) 
       INNER JOIN resourcerate rr WITH (nolock) 
               ON r.resourceid = rr.resourceid 
                  AND rr.active = 1 
       LEFT OUTER JOIN dbo.project p WITH (nolock) 
                    ON t.projectid = p.projectid 
WHERE  wp.NAME IS NOT NULL 
       AND t.timedate >= '2019-01-01' 
UNION ALL 
-- Get the margin for Associates in the 'Associates' workgrooup that have hours on an engagement tagged to the workgroup through the 'Staffing Workgroup' field in the engagement - Child of Child
SELECT 'Associates'                           AS DetailType, 
       r.resourceid                           AS ResourceId, 
       t.customerid, 
       t.engagementid, 
       t.projectid, 
       t.timedate                             AS Date, 
       e.NAME                                 AS EngagementName, 
       r.NAME                                 AS ResourceName, 
       ra.emailaddress                        AS ResourceEmail, 
       ( t.regularhours + t.overtimehours )   AS Hours, 
       t.billable, 
       CASE 
         WHEN Isnull(t.hourlycostrate, 0) = 0 THEN rr.hourlycostrate 
         ELSE t.hourlycostrate 
       END                                    AS HourlyCostRate, 
       t.billingrate, 
       t.revrec, 
       CASE 
         WHEN Isnull(t.hourlycostrate, 0) = 0 THEN ( 
         ( t.regularhours + t.overtimehours ) * ( 
         t.billingrate - rr.hourlycostrate ) ) 
         ELSE ( ( t.regularhours + t.overtimehours ) * ( 
                t.billingrate - t.hourlycostrate ) ) 
       END                                    AS RateTimesHours, 
       wp2.workgroupid                        AS WorkgroupID, 
       wp2.NAME                               AS WorkgroupName, 
       p.NAME                                 AS ProjectName, 
       'Associate' 
       + Cast(wp2.workgroupid AS VARCHAR(36)) AS WorkgroupResourceId 
FROM   engagement e WITH (nolock) 
       INNER JOIN time t WITH (nolock) 
               ON e.engagementid = t.engagementid 
       INNER JOIN resources r WITH (nolock) 
               ON t.resourceid = r.resourceid 
       JOIN resourceaddress ra 
         ON r.resourceid = ra.resourceid 
       INNER JOIN workgroup w WITH (nolock) 
               ON e.associatedworkgroup = w.workgroupid 
       LEFT OUTER JOIN workgroup wp WITH (nolock) 
                    ON wp.workgroupid = w.parent 
                       AND wp.deleted = 0 
       LEFT OUTER JOIN workgroup wp2 WITH (nolock) 
                    ON wp2.workgroupid = wp.parent 
                       AND wp2.deleted = 0 
      INNER JOIN workgrouphistorymember m WITH (nolock) 
               ON r.resourceid = m.resourceid 
                  AND m.workgroupid = '702985ab-f8fb-44e4-829b-61c80454104f' 
                  AND ( t.timedate >= m.EffectiveDate 
                        AND t.timedate <= ISNULL (m.enddate, '2099-12-31')  ) 
       INNER JOIN resourcerate rr WITH (nolock) 
               ON r.resourceid = rr.resourceid 
                  AND rr.active = 1 
       LEFT OUTER JOIN dbo.project p WITH (nolock) 
                    ON t.projectid = p.projectid 
WHERE  wp2.NAME IS NOT NULL 
       AND t.timedate >= '2019-01-01' 
UNION ALL 
--Retrieve the Revenue Adjustments for Engagements tagged to the workgroup through the 'Staffing Workgroup' field in the engagement with Reason Code - Fixed Fee Contractor Margin
SELECT 'Fixed Fee Contractors'                AS DetailType, 
       '00000000-0000-0000-0000-000000000000' AS ResourceId, 
       e.customerid, 
       r.engagementid, 
       NULL                                   AS ProjectId, 
       r.postingdate                          AS Date, 
       e.NAME                                 AS EngagementName, 
       'FF Contractor Margin'                 AS ResourceName, 
       NULL                                   AS ResourceEmail, 
       0                                      AS Hours, 
       1                                      AS Billable, 
       NULL                                   AS HourlyCostRate, 
       NULL                                   AS BillingRate, 
       r.revenueamount                        AS RevRec, 
       r.revenueamount                        AS RateTimesHours, 
       w.workgroupid                          AS WorkgroupID, 
       w.NAME                                 AS WorkgroupName, 
       NULL                                   AS ProjectName, 
       'FF Contractor Margin' 
       + Cast(w.workgroupid AS VARCHAR(36))   AS WorkgroupResourceId 
FROM   engagement e WITH (nolock) 
       INNER JOIN revenuedetail r WITH (nolock) 
               ON e.engagementid = r.engagementid 
                  AND reasoncode = 'd4c4b9a6-2699-415b-bb28-5579e78e428b' 
       INNER JOIN workgroup w WITH (nolock) 
               ON e.associatedworkgroup = w.workgroupid 
WHERE  postingdate >= '2019-01-01' 
UNION ALL 
--Retrieve the Revenue Adjustments for Engagements tagged to the workgroup through the 'Staffing Workgroup' field in the engagement with Reason Code - Fixed Fee Contractor Margin - Child
SELECT 'Fixed Fee Contractors'                AS DetailType, 
       '00000000-0000-0000-0000-000000000000' AS ResourceId, 
       e.customerid, 
       r.engagementid, 
       NULL                                   AS ProjectId, 
       r.postingdate                          AS Date, 
       e.NAME                                 AS EngagementName, 
       'FF Contractor Margin'                 AS ResourceName, 
       NULL                                   AS ResourceEmail, 
       0                                      AS Hours, 
       1                                      AS Billable, 
       NULL                                   AS HourlyCostRate, 
       NULL                                   AS BillingRate, 
       r.revenueamount                        AS RevRec, 
       r.revenueamount                        AS RateTimesHours, 
       wp.workgroupid                         AS WorkgroupID, 
       wp.NAME                                AS WorkgroupName, 
       NULL                                   AS ProjectName, 
       'FF Contractor Margin' 
       + Cast(wp.workgroupid AS VARCHAR(36))  AS WorkgroupResourceId 
FROM   engagement e WITH (nolock) 
       INNER JOIN revenuedetail r WITH (nolock) 
               ON e.engagementid = r.engagementid 
                  AND reasoncode = 'd4c4b9a6-2699-415b-bb28-5579e78e428b' 
       INNER JOIN workgroup w WITH (nolock) 
               ON e.associatedworkgroup = w.workgroupid 
       LEFT OUTER JOIN workgroup wp WITH (nolock) 
                    ON wp.workgroupid = w.parent 
                       AND wp.deleted = 0 
WHERE  wp.NAME IS NOT NULL 
       AND postingdate >= '2019-01-01' 
UNION ALL 
--Retrieve the Revenue Adjustments for Engagements tagged to the workgroup through the 'Staffing Workgroup' field in the engagement with Reason Code - Fixed Fee Contractor Margin - Child of Child
SELECT 'Fixed Fee Contractors'                AS DetailType, 
       '00000000-0000-0000-0000-000000000000' AS ResourceId, 
       e.customerid, 
       r.engagementid, 
       NULL                                   AS ProjectId, 
       r.postingdate                          AS Date, 
       e.NAME                                 AS EngagementName, 
       'FF Contractor Margin'                 AS ResourceName, 
       NULL                                   AS ResourceEmail, 
       0                                      AS Hours, 
       1                                      AS Billable, 
       NULL                                   AS HourlyCostRate, 
       NULL                                   AS BillingRate, 
       r.revenueamount                        AS RevRec, 
       r.revenueamount                        AS RateTimesHours, 
       wp2.workgroupid                        AS WorkgroupID, 
       wp2.NAME                               AS WorkgroupName, 
       NULL                                   AS ProjectName, 
       'FF Contractor Margin' 
       + Cast(wp2.workgroupid AS VARCHAR(36)) AS WorkgroupResourceId 
FROM   engagement e WITH (nolock) 
       INNER JOIN revenuedetail r WITH (nolock) 
               ON e.engagementid = r.engagementid 
                  AND reasoncode = 'd4c4b9a6-2699-415b-bb28-5579e78e428b' 
       INNER JOIN workgroup w WITH (nolock) 
               ON e.associatedworkgroup = w.workgroupid 
       LEFT OUTER JOIN workgroup wp WITH (nolock) 
                    ON wp.workgroupid = w.parent 
                       AND wp.deleted = 0 
       LEFT OUTER JOIN workgroup wp2 WITH (nolock) 
                    ON wp2.workgroupid = wp.parent 
                       AND wp2.deleted = 0 
       LEFT OUTER JOIN workgrouphistorymember whm WITH (nolock) 
                    ON wp2.workgroupid = whm.workgroupid 
                       AND Datediff(d, whm.effectivedate, 
                           Isnull(whm.enddate, '2099-12-31')) > 1 
WHERE  wp2.NAME IS NOT NULL 
       AND postingdate >= '2019-01-01' 

	    --Get forecast
	   
	   UNION ALL
	  
	   SELECT 
  t.Type AS DetailType, 
  t.ResourceID, 
  p.CustomerId, 
  p.EngagementId, 
  t.ProjectId, 
  t.PeriodEndDate AS Date, 
  t.ProjectName AS EngagementName, 
  r.Name AS ResourceName, 
  ra.emailaddress AS ResourceEmail, 
  t.PlannedHours AS Hours, 
  1 AS Billable, 
  t.CostRate, 
  t.BillingRate, 
  0 AS RevRec, 
  (t.PlannedHours * t.BillingRate) AS RateTimesHours, 
 w.workgroupid AS WorkgroupID, 
 w.workgroup AS WorkgroupName,
  t.TaskName AS ProjectName,
  r.NAME + Cast(w.workgroupid AS VARCHAR(36)) AS WorkgroupResourceId 
FROM 
  [dbo].[D_ForecastTimeAndOpportunities] t WITH (nolock) 
  INNER JOIN dbo.Resources r WITH (nolock) ON t.ResourceId = r.ResourceId 
  AND r.EmployeeType <> 'CO' 
   JOIN resourceaddress ra 
         ON r.resourceid = ra.resourceid 
       LEFT JOIN [dbo].[PBI_ResourcesByWorkgroup] w WITH (nolock) 
              ON t.resourceid = w.resourceid 
       LEFT OUTER JOIN dbo.Project p WITH (nolock) ON t.ProjectId = p.ProjectId

GO

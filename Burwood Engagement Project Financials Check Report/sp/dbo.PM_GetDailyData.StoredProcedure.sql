USE [Changepoint]
GO
/****** Object:  StoredProcedure [dbo].[PM_GetDailyData]    Script Date: 10/14/2019 2:31:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PM_GetDailyData]  @SessionId UNIQUEIDENTIFIER,   @TransactionXML XML=NULL, @PMViewId  UNIQUEIDENTIFIER =NULL
	
AS
BEGIN
	DECLARE @NULLID				UNIQUEIDENTIFIER
	DECLARE @TIMECONTROL CHAR(1), @FloorConvert INT 
	SET @FloorConvert=100000
	DEClARE @PM_StartLogTime		DATETIME
	IF NOT @TransactionXML IS NULL SET @PM_StartLogTime=GETUTCDATE()
	
	
	
	SET @NULLID ='00000000-0000-0000-0000-000000000000' 
	SELECT  @TIMECONTROL=CODE  FROM TimeControl  WITH (NOLOCK)  WHERE Selected=1
	CREATE TABLE #PM_DemandTaskAssignment_1 
	(
		
		ProjectId			UNIQUEIDENTIFIER,
		TaskId				UNIQUEIDENTIFIER,
 		TaskAssignmentId  	UNIQUEIDENTIFIER,
		ResourceId			UNIQUEIDENTIFIER,
 		WorkingDays   		INT, 
 		PlannedHours   		NUMERIC (12,5), 
 		PStart    			DATETIME,
 		PEnd    			DATETIME, 
 		LastDate   			DATETIME,
 		LastDateValue   	NUMERIC (12,5) DEFAULT 0,
 		RegularDateValue  	NUMERIC (12,5) DEFAULT 0
	)
	
	
	CREATE TABLE #PM_FiscalAssign_1
	(
		ProjectId				UNIQUEIDENTIFIER,
		TasKid					UNIQUEIDENTIFIER,	
		TaskAssignmentId  		UNIQUEIDENTIFIER,
		BillingOfficeId			UNIQUEIDENTIFIER,
		ResourceId				UNIQUEIDENTIFIER,
		PlannedStart			DATETIME,
		PlannedFinish			DATETIME
	
	)
	CREATE TABLE #PM_GetFiscalPeriod_1 
	(
		TaskAssignmentId 		UNIQUEIDENTIFIER,
		FiscalPeriodId			UNIQUEIDENTIFIER,
		WorkingDays				INT,
		PlannedHours			NUMERIC(12,5),
		PStart					DATETIME,
		PEND					DATETIME,
		LASTDATE				DATETIME,
		LastDateValue			NUMERIC (12,5) DEFAULT 0,
		RegularDateValue		NUMERIC (12,5) DEFAULT 0, 
		GetExistingDaily				BIT DEFAULT 0
									
	)
	CREATE TABLE #PastPeriodAssignmets_1
	(	
		TaskId							UNIQUEIDENTIFIER,
		TaskAssignmentId				UNIQUEIDENTIFIER,
		ResourceId						UNIQUEIDENTIFIER,
		StartPeriod						DATETIME, 
		EndPeriod						DATETIME,
		PlannedStart					DATETIME
	)
	IF OBJECT_ID('tempdb..#ResourceDates') IS NOT NULL DROP TABLE #ResourceDates
	CREATE TABLE #ResourceDates
	(
		ResourceId		UNIQUEIDENTIFIER, 
		StartDate		DATETIME,
		EndDate			DATETIME
	)
	IF OBJECT_ID('tempdb..#RMV_ResourceNonWorkingDays') IS NOT NULL DROP TABLE #RMV_ResourceNonWorkingDays
	CREATE TABLE #RMV_ResourceNonWorkingDays
	(
		ResourceId		UNIQUEIDENTIFIER, 
		NonWorkingDate		DATETIME
	)
	IF OBJECT_ID('tempdb..#RMV_WorkingDays') IS NOT NULL DROP TABLE #RMV_WorkingDays
	CREATE TABLE #RMV_WorkingDays
	(	
		WorkingDate		DATETIME
	)
	DECLARE @MinStart DATETIME, @MaxFinish DATETIME,  @projectId  UNIQUEIDENTIFIER,  @ResourceId UNIQUEIDENTIFIER
	
	SELECT  @projectId=ProjectId,  @ResourceId=ResourceId FROM TaskDepRequest  WITH (NOLOCK)  WHERE RequestId=@SessionId
			
			
	
		IF (@PMViewId IS NULL  OR  (@PMViewId IS NOT NULL AND EXISTS(SELECT * FROM  PMTimescaleSetting WITH (NOLOCK) WHERE ViewId=@PMViewId AND ProjectId=@ProjectId AND ResourceId=@ResourceId 
		AND  UPPER(TimeScaleType)='DA')))
		BEGIN
				UPDATE #PM_Assignments_1 SET NewDailyExists=1 FROM #PM_Assignments_1 pa
				INNER JOIN 
				( SELECT  DISTINCT EntityId FROM PMEntityDailyChanges  WITH (NOLOCK) WHERE SessionId=@SessionId) tt 
				ON pa.TaskAssignmentId=tt.EntityId  
				WHERE pa.Changed=0x1 
		END 
		
	
		UPDATE #PM_Assignments_1 SET LoadingMethod=ISNULL(pr.LoadingMethod, ta.LoadingMethod),
		PlannedStart = ISNULL(pr.PlannedStart, ta.PlannedStart)
		FROM #PM_Assignments_1 pa
		LEFT JOIN PMEntityRollupChanges pr WITH (NOlOCK) ON pr.SessionId=@SessionId AND pr.EntityId=pa.TaskAssignmentId
		LEFT JOIN TaskAssignment ta WITH (NOLOCK) ON ta.TaskAssignmentId=pa.TaskAssignmentId
		WHERE  pa.Changed=0x1 
		INSERT INTO #PastPeriodAssignmets_1 (TaskId,TaskAssignmentId,ResourceId,EndPeriod, PlannedStart)
		SELECT  ta.TaskId, ta.TaskAssignmentId, ta.ResourceId, fp.StartDate, ta.PlannedStart
		FROM #PM_Assignments_1 ta 
		INNER JOIN ProjectFiscalOffice po WITH (NOLOCK) ON po.ProjectId=ta.ProjectId  
		AND ta.LoadingMethod IN (0,1,2)
		INNER JOIN FiscalPeriod fp WITH (NOlOCK) ON fp.Deleted=0 AND fp.BillingOfficeId=po.FPBillingOfficeId
		AND DATEADD(dd,0, DATEDIFF(dd,0,GETDATE()))  BETWEEN fp.StartDate AND fp.EndDate
		WHERE  ta.Changed=0x1
		
		INSERT INTO  #ResourceDates (ResourceId, StartDate,EndDate	)
		SELECT ResourceId, MIN(PlannedStart),MAX(PlannedFinish)
		FROM
		(
				
			SELECT pc.ResourceId, pr.PlannedStart, pr.PlannedFinish
			FROM #PM_Assignments_1 tt 
			INNER JOIN PMEntityChanges pc WITH (NOLOCK) ON pc.SessionId=@SessionId AND tt.TaskAssignmentId=pc.EntityId  AND tt.NewDailyExists=0 AND pc.EntityType='ta'
			INNER JOIN PMEntityRollupChanges pr WITH (NOLOCK) ON pr.SessionId=@SessionId AND pr.EntityId=pc.EntityId 
			WHERE tt.Changed=1
		) t
		GROUP BY ResourceId
			
		SELECT @MinStart = MIN(StartDate), @MaxFinish = MAX(EndDate) FROM #ResourceDates 
		
		INSERT INTO #RMV_ResourceNonWorkingDays (ResourceId, NonWorkingDate)
		SELECT  rb.ResourceId, rnw.NonWorkingDate 
		FROM #ResourceDates rb
		INNER JOIN ResourceNonWorkingDays rnw WITH (NOLOCK) ON rb.ResourceId=rnw.ResourceId
		AND rnw.NonWorkingDate BETWEEN rb.StartDate AND rb.EndDate
		INSERT INTO #RMV_WorkingDays (WorkingDate)
		SELECT  WorkingDate 
		FROM WorkingDays   WITH (NOLOCK) WHERE WorkingDate BETWEEN @MinStart AND @MaxFinish
			
		
		INSERT INTO #PM_DemandTaskAssignment_1(ProjectId,TasKid,TaskAssignmentId,ResourceId,WorkingDays,PlannedHours,PStart,PEnd,LastDate)
		SELECT pc.ProjectId,pc.tasKid,pc.EntityId,pc.ResourceId, tt2.CNT,
		pr.PlannedHours, pr.PlannedStart, pr.PlannedFinish, tt2.MaxWorkingDate			
		FROM #PM_Assignments_1 tt 
		INNER JOIN PMEntityChanges pc WITH (NOLOCK) ON pc.SessionId=@SessionId AND tt.TaskAssignmentId=pc.EntityId  AND tt.NewDailyExists=0 AND pc.EntityType='ta'
		INNER JOIN PMEntityRollupChanges pr WITH (NOLOCK) ON pr.SessionId=@SessionId AND pr.EntityId=pc.EntityId 			
		AND NOT EXISTS (SELECT TOP 1  1 FROM   PMEntityFiscalChanges   pf  WITH (NOLOCK) WHERE pf.SessionId= @SessionId AND pc.EntityId=pf.EntityId )
		CROSS APPLY
		(
			SELECT	COUNT(1) CNT, MAX(wd.WorkingDate) MaxWorkingDate
			FROM	#RMV_WorkingDays wd  WITH (NOLOCK) 
			WHERE	pr.PlannedStart -1 < wd.WorkingDate AND  pr.PlannedFinish +1 > wd.WorkingDate
			AND NOT EXISTS(SELECT TOP 1 1 FROM #RMV_ResourceNonWorkingDays rd  WITH (NOLOCK) WHERE rd.ResourceId =ISNULL(pc.ResourceId,@NullID) AND rd.NonWorkingDate = wd.WorkingDate)
		) tt2
		WHERE tt.Changed=0x1
		UPDATE #PM_DemandTaskAssignment_1 SET RegularDateValue=(FLOOR((PlannedHours/WorkingDays)*@FloorConvert)/@FloorConvert),
		LastDateValue=PlannedHours - ((FLOOR((PlannedHours/WorkingDays)*@FloorConvert)/@FloorConvert) * WorkingDays)
		WHERE   WorkingDays> 0   AND PlannedHours> 0
			
		
		
		INSERT INTO  #PM_FiscalAssign_1 ( ProjectId, TasKid,TaskAssignmentId, BillingOfficeId, ResourceId,  PlannedStart, PlannedFinish)
		SELECT pc.ProjectId, pc.TasKid, pc.EntityId,tf.BillingOfficeId, pc.ResourceId,  pr.PlannedStart, pr.PlannedFinish
		FROM #PM_Assignments_1   tt  WITH (NOLOCK) 
		INNER JOIN PMEntityChanges pc WITH (NOLOCK) ON pc.SessionId=@SessionId AND tt.TaskAssignmentId=pc.EntityId AND pc.EntityType='ta' 
		INNER JOIN PMEntityRollupChanges pr WITH (NOLOCK) ON pr.SessionId=@SessionId AND pr.EntityId=pc.EntityId 
		INNER JOIN (SELECT DISTINCT EntityId, BillingOfficeId FROM   PMEntityFiscalChanges  pf  WITH (NOLOCK) WHERE pf.SessionId= @SessionId)
		tf ON  pc.EntityId=tf.EntityId
		WHERE tt.Changed=0x1
		
		INSERT INTO #PM_GetFiscalPeriod_1(TaskAssignmentId,FiscalPeriodId,WorkingDays,PlannedHours,PStart,PEND,LASTDATE)
		SELECT fa.TaskAssignmentId,fp.FiscalPeriodId, tt2.CNT,			
		pf.PlannedHours,
		CASE WHEN fa.PlannedStart > fp.StartDate THEN fa.PlannedStart ELSE fp.StartDate END,
		CASE WHEN fa.PlannedFinish > fp.EndDate THEN fp.EndDate ELSE fa.PlannedFinish END, 			
		tt2.MaxWorkingDate
		FROM   #PM_Assignments_1 pa 
		INNER JOIN #PM_FiscalAssign_1 fa  ON pa.TaskAssignmentId= fa.TaskAssignmentId 
		INNER JOIN FiscalPeriod fp  WITH (NOLOCK) ON fa.BillingOfficeId = fp.BillingOfficeId AND fp.Deleted = 0 
		INNER JOIN 	PMEntityFiscalChanges   pf  WITH (NOLOCK) ON pf.SessionId= @SessionId AND fa.TaskAssignmentId=pf.EntityId AND fp.FiscalPeriodId = pf.FiscalPeriodId
		CROSS APPLY
		(
			SELECT	COUNT(1) CNT, MAX(wd.WorkingDate) MaxWorkingDate
			FROM	#RMV_WorkingDays wd  WITH (NOLOCK) 
			WHERE (CASE WHEN fp.StartDate > fa.PlannedStart THEN fp.StartDate ELSE fa.PlannedStart END) -1 < wd.WorkingDate 
			AND   (CASE WHEN fp.EndDate > fa.PlannedFinish THEN fa.PlannedFinish ELSE fp.EndDate END) +1 > wd.WorkingDate
			AND NOT EXISTS(SELECT TOP 1 1 FROM #RMV_ResourceNonWorkingDays rd  WITH (NOLOCK) WHERE rd.ResourceId =ISNULL(fa.ResourceId,@NullID) AND rd.NonWorkingDate = wd.WorkingDate)
		) tt2
		WHERE pa.NewDailyExists=0x0 
			
			
			
		
		UPDATE #PM_GetFiscalPeriod_1  SET GetExistingDaily=0x1
		FROM  #PM_GetFiscalPeriod_1 pf 
		INNER  JOIN FiscalPeriod fp WITH (NOLoCK) ON fp.Deleted=0x0  AND fp.FiscalPeriodId=pf.FiscalPeriodId
		INNER JOIN   #PM_FiscalAssign_1 fa ON fa.TaskAssignmentId=pf.TaskAssignmentId AND fa.BillingOfficeId=fp.BillingOfficeId
		INNER JOIN AssignmentFiscalRollup afr WITH (NOlOCK) ON afr.TaskAssignmentId=pf.TaskAssignmentId AND 
		afr.FiscalPeriodId=pf.FiscalPeriodId AND afr.PlannedHours=pf.PlannedHours
		AND EXISTS(SELECT TOP 1 1 FROM DemandItems di WITH (NOLOCK) WHERE di.EntityId=pf.TaskAssignmentId)
		
		UPDATE  #PM_Assignments_1  SET ID=tt.ID
		FROM  #PM_Assignments_1 pa
		CROSS APPLY 
		(
			SELECT MAX(di.Id) ID  FROM  DemandItems di WITH (NOLOCK) WHERE di.EntityId=pa.TaskAssignmentId
		)tt
		WHERE pa.Changed=0x0  OR EXISTS(SELECT TOP 1 1 FROM  #PM_GetFiscalPeriod_1 pf WHERE   pa.TaskAssignmentId=pf.TaskAssignmentId AND pf.GetExistingDaily=0x1)
		
		UPDATE #PM_GetFiscalPeriod_1 SET RegularDateValue=(FLOOR((PlannedHours/WorkingDays)*@FloorConvert)/@FloorConvert),
		LastDateValue=PlannedHours - ((FLOOR((PlannedHours/WorkingDays)*@FloorConvert)/@FloorConvert) * WorkingDays)
		WHERE   GetExistingDaily =0x0 AND WorkingDays> 0 AND PlannedHours > 0
			
		
		INSERT INTO #PM_DailyHours ( TaskAssignmentId,WorkingDate,PlannedHours)
		SELECT pa.TaskAssignmentId,wd.WorkingDate ,CASE WHEN  wd.WorkingDate =ta.LastDate THEN (ta.RegularDateValue+ta.LastDateValue)ELSE ta.RegularDateValue END CommittedHours  
		FROM #PM_Assignments_1 pa
		INNER JOIN #PM_DemandTaskAssignment_1 ta  ON pa.TaskAssignmentId=ta.TaskAssignmentId AND pa.NewDailyExists=0 AND ta.WorkingDays > 0 
		INNER JOIN #RMV_WorkingDays wd  WITH (NOLOCK)  ON (ta.PStart -1 < wd.WorkingDate AND ta.PEnd +1 > wd.WorkingDate)
		AND NOT EXISTS(SELECT TOP 1 1 FROM #RMV_ResourceNonWorkingDays rd  WITH (NOLOCK) WHERE rd.ResourceId =ISNULL(pa.ResourceId,@NULLID) AND rd.NonWorkingDate = wd.WorkingDate)
		INNER JOIN ProjectFiscalOffice po WITH (NOLOCK) ON pa.ProjectId=po.ProjectId 
		INNER JOIN FiscalPeriod fp WITH (NOLOCK) ON fp.Deleted=0 AND fp.BillingOfficeId=po.FPBillingOfficeId
		AND wd.WorkingDate BETWEEN fp.StartDate AND fp.EndDate 
		INNER JOIN 
		(SELECT pa.TaskAssignmentId,  ISNULL(pas.EndPeriod, DATEADD(yy,-100,GETDATE())) EndPeriod FROM #PM_Assignments_1 pa   
			LEFT JOIN 	#PastPeriodAssignmets_1 pas  ON  pa.TaskAssignmentId=pas.TaskAssignmentId
		) tt  ON tt.TaskAssignmentId = pa.TaskAssignmentId AND wd.WorkingDate >=tt.EndPeriod
		WHERE pa.Changed=0x1
		UNION 
		SELECT pa.TaskAssignmentId,wd.WorkingDate ,CASE WHEN  wd.WorkingDate =ta.LastDate THEN (ta.RegularDateValue+ta.LastDateValue)ELSE ta.RegularDateValue END CommittedHours  
		FROM #PM_Assignments_1 pa
		INNER JOIN #PM_DemandTaskAssignment_1 ta  ON pa.TaskAssignmentId=ta.TaskAssignmentId  AND pa.NewDailyExists=0 
		INNER JOIN #RMV_WorkingDays wd  WITH (NOLOCK)  ON (ta.PStart -1 < wd.WorkingDate AND ta.PEnd +1 > wd.WorkingDate)
		AND NOT EXISTS(SELECT TOP 1 1 FROM #RMV_ResourceNonWorkingDays rd  WITH (NOLOCK) WHERE rd.ResourceId =ISNULL( pa.ResourceId,@NULLID) AND rd.NonWorkingDate = wd.WorkingDate)
		AND ta.WorkingDays  > 0
		AND NOT EXISTS(SELECT TOP  1 1 FROM ProjectFiscalOffice po WITH (NOLOCK) WHERE pa.ProjectId=po.ProjectId) 
		INNER JOIN 
		(SELECT  pa.TaskAssignmentId, ISNULL(pas.EndPeriod, DATEADD(yy,-100,GETDATE())) EndPeriod FROM #PM_Assignments_1 pa   
			LEFT JOIN 	#PastPeriodAssignmets_1 pas   ON  pa.TaskAssignmentId=pas.TaskAssignmentId
		) tt  ON tt.TaskAssignmentId = pa.TaskAssignmentId AND wd.WorkingDate >=tt.EndPeriod
		WHERE pa.Changed=0x1
		UNION 
		
		SELECT pa.TaskAssignmentId , wd.WorkingDate,CASE WHEN  wd.WorkingDate =fp.LastDate THEN (fp.RegularDateValue+fp.LastDateValue)ELSE fp.RegularDateValue END   CommittedHours
		FROM #PM_Assignments_1 pa 
		INNER JOIN #PM_FiscalAssign_1 fa ON fa.TaskAssignmentId=pa.TaskAssignmentId   AND pa.Changed=0x1
		INNER JOIN #PM_GetFiscalPeriod_1 fp  ON  fp.GetExistingDaily =0x0 AND fp.TaskAssignmentId=fa.TaskAssignmentId
		INNER JOIN #RMV_WorkingDays wd  WITH (NOLOCK)  ON  (fp.PStart -1 < wd.WorkingDate AND fp.PEnd +1 > wd.WorkingDate)
		AND NOT EXISTS(SELECT TOP 1 1 FROM #RMV_ResourceNonWorkingDays rd WITH (NOLOCK) WHERE rd.ResourceId =ISNULL ( pa.ResourceId,@NULLID) AND rd.NonWorkingDate = wd.WorkingDate)
		INNER JOIN 
		(SELECT   pa.TaskAssignmentId, ISNULL(pas.EndPeriod, DATEADD(yy,-100,GETDATE())) EndPeriod FROM #PM_Assignments_1 pa   
			LEFT JOIN 	#PastPeriodAssignmets_1 pas   ON  pa.TaskAssignmentId=pas.TaskAssignmentId
		) tt  ON tt.TaskAssignmentId = pa.TaskAssignmentId AND wd.WorkingDate >=tt.EndPeriod
		WHERE pa.Changed=0x1
		UNION 
		
	
		SELECT fp.TaskAssignmentId ,  da.DemandDate, da.DemandHours CommittedHours
		FROM   #PM_GetFiscalPeriod_1 fp 
		INNER JOIN #PM_Assignments_1 pa  ON fp.TaskAssignmentId=pa.TaskAssignmentId  AND fp.GetExistingDaily=0x1
		INNER JOIN  DailyDistribution da   WITH (NOLOCK)   ON pa.ID=da.ID AND da.DemandDate BETWEEN fp.PStart AND fp.PEND
		INNER JOIN 
		(SELECT  pa1.TaskAssignmentId,ISNULL(pas.EndPeriod, DATEADD(yy,-100,GETDATE())) EndPeriod FROM #PM_Assignments_1 pa1   
			LEFT JOIN 	#PastPeriodAssignmets_1 pas   ON  pa1.TaskAssignmentId=pas.TaskAssignmentId
		) tt  ON tt.TaskAssignmentId = pa.TaskAssignmentId AND da.DemandDate >=tt.EndPeriod
		WHERE pa.Changed=0x1
		UNION 
		
		SELECT tt.TaskAssignmentId ,tt.TimeDate , CAST(tt.ActualHours AS NUMERIC(12, 5)) CommittedHours
		FROM #PM_Assignments_1 pa 
		INNER JOIN
		(
			SELECT pa.TaskAssignmentId, t.TimeDate, SUM(ISNULL(RegularHours,0) + ISNULL(OvertimeHours,0)) ActualHours 
			FROM #PastPeriodAssignmets_1 pa  
			INNER JOIN  Time t WITH (NOLOCK)  ON t.TaskId=pa.TaskId AND t.ResourceId=pa.ResourceId AND t.TimeDate< pa.EndPeriod
				AND t.TimeDate >= pa.PlannedStart 
				AND ((UPPER(@TIMECONTROL)='A' AND t.ApprovalStatus='A') OR (UPPER(@TIMECONTROL)='S' 
				AND t.SubmittedForApproval=CAST(1 AS BIT)) OR (UPPER(@TIMECONTROL)='C'))
			GROUP BY  pa.TaskId, pa.TaskAssignmentId, pa.ResourceId,  t.TimeDate
		)tt ON pa.TaskAssignmentId=tt.TaskAssignmentId AND pa.Changed=0x1
		INNER JOIN ProjectFiscalOffice po WITH (NOLOCK) ON pa.ProjectId=po.ProjectId 
		INNER JOIN FiscalPeriod fp WITH (NOLOCK) ON fp.Deleted=0 AND fp.BillingOfficeId=po.FPBillingOfficeId
		AND tt.TimeDate BETWEEN fp.StartDate AND fp.EndDate 
		
			
		UNION 
		SELECT  pa.TaskAssignmentId, pd.FiscalStartDate, pd.PlannedHours 
		FROM #PM_Assignments_1 pa
		INNER JOIN PMEntityDailyChanges  pd WITH (NOLOCK) ON   pa.NewDailyExists=1  AND pd.SessionId=@SessionId
		AND pa.TaskAssignmentId=pd.EntityId 
		INNER JOIN 
		(SELECT  pa.TaskAssignmentId,ISNULL(pas.EndPeriod, DATEADD(yy,-100,GETDATE())) EndPeriod FROM #PM_Assignments_1 pa   
			LEFT JOIN 	#PastPeriodAssignmets_1 pas   ON  pa.TaskAssignmentId=pas.TaskAssignmentId AND pa.NewDailyExists=1
		) tt  ON tt.TaskAssignmentId = pa.TaskAssignmentId AND pd.FiscalStartDate >=tt.EndPeriod
		WHERE pa.Changed=0x1
		
		UNION 
			
		
		SELECT pa.TaskAssignmentId , da.DemandDate, da.DemandHours CommittedHours
		FROM   #PM_Assignments_1 pa  
		INNER JOIN  DailyDistribution da   WITH (NOLOCK)   ON  pa.ID=da.ID 
		WHERE pa.Changed=0x0
					
TRUNCATE TABLE #PM_DemandTaskAssignment_1 
TRUNCATE TABLE #PM_FiscalAssign_1
TRUNCATE TABLE #PM_GetFiscalPeriod_1 
TRUNCATE TABLE #PastPeriodAssignmets_1
TRUNCATE TABLE #ResourceDates
TRUNCATE TABLE #RMV_ResourceNonWorkingDays
TRUNCATE TABLE #RMV_WorkingDays
IF NOT @TransactionXML IS NULL 
BEGIN
	EXEC SaveTransactionLog @@PROCID, @PM_StartLogTime, @TransactionXML
END 
		
END 

GO

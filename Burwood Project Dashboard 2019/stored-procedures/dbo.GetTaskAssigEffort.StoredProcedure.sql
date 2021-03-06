USE [Changepoint]
GO
/****** Object:  StoredProcedure [dbo].[GetTaskAssigEffort]    Script Date: 10/10/2019 2:41:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetTaskAssigEffort]
(
	@RequestId 			UNIQUEIDENTIFIER , 
	@sDate				DATETIME, 
	@eDate				DATETIME, 
	@ReportType			CHAR(1)='', 
	@ViewType			VARCHAR(3)='', 
	@GroupByCommit		BIT=0, 
	@ForPlannedCost		BIT=0x0, 
	@TransactionXML		XML=NULL
)
AS
BEGIN
	
    SET NOCOUNT ON 
	DEClARE @PM_StartLogTime	DATETIME
	IF NOT @TransactionXML IS NULL SET @PM_StartLogTime=GETUTCDATE()
	
	DECLARE @BillingOfficeId UNIQUEIDENTIFIER
	
	CREATE TABLE #TaskAssignment 
	(
		ID					BIGINT DEFAULT 0,
		ProjectId			UNIQUEIDENTIFIER,
		TaskAssignmentId  	UNIQUEIDENTIFIER,
		ResourceId			UNIQUEIDENTIFIER,
		WorkgroupId			UNIQUEIDENTIFIER,
		FunctionId			UNIQUEIDENTIFIER,
		[Committed]			BIT DEFAULT 0
	)
	INSERT INTO #TaskAssignment(ProjectId,TaskAssignmentId,ResourceId,WorkgroupId, FunctionId, [Committed])
	SELECT ta.ProjectId,ta.TaskAssignmentId,ta.ResourceId, dr.WorkgroupId, dr.FunctionId, dr.[Committed]
	FROM   DemandItemRequest dr  WITH (NOLOCK) 
	INNER JOIN TaskAssignment ta  WITH (NOLOCK) ON dr.ItemId = ta.TaskAssignmentId
	AND dr.RequestId = @RequestId AND ta.PlannedHours > 0				
	UPDATE  #TaskAssignment  SET ID=tt.ID
	FROM  #TaskAssignment ta
	CROSS APPLY 
	(
		SELECT MAX(di.Id) ID  FROM  DemandItems di WITH (NOLOCK) WHERE di.EntityId=ta.TaskAssignmentId
	)tt
	
	
	IF ((@sDate IS NULL)  OR (@eDate IS NULL ))
		BEGIN
			 SET @sDate=DATEADD(yy,-100,dbo.F_DROPTIME(GETDATE()))
			 SET @eDate=DATEADD(yy,100,dbo.F_DROPTIME(GETDATE()))
		END 
		
	IF @ViewType='BU'
	BEGIN
			SELECT TOP 1 @BillingOfficeId=BillingOfficeId FROM DemandItemRequest  WITH (NOLOCK)  WHERE RequestId=@RequestId 
			INSERT INTO #ResourceDemandEffort (ItemId, SecondItemId, Effort)
			SELECT ta.TaskAssignmentId, fp.FiscalPeriodId, SUM(da.DemandHours)
			FROM   #TaskAssignment ta
			INNER JOIN  DailyDistribution da   WITH (NOLOCK)   ON ta.ID=da.ID AND  da.DemandDate BETWEEN @sDate AND @eDate 
			INNER JOIN FiscalPeriod fp  WITH (NOLOCK)  ON fp.Deleted=0 AND fp.BillingOfficeId=@BillingOfficeId
			AND da.DemandDate  BETWEEN fp.StartDate AND fp.EndDate
			GROUP BY ta.TaskAssignmentId, fp.FiscalPeriodId 
     END
	IF @ViewType='RS'
		INSERT INTO #ResourceDemandEffort (ItemId, Effort)
		SELECT ta.ResourceId,  SUM(da.DemandHours)
		FROM   #TaskAssignment ta
		INNER JOIN  DailyDistribution da   WITH (NOLOCK)   ON ta.ID=da.ID AND  da.DemandDate BETWEEN @sDate AND @eDate 
		GROUP BY ta.ResourceId
	IF @ViewType='PTL'
		INSERT INTO ProjectTeamBalance (RequestId, Type, ProjectId, ResourceId, SubItemId, ResDate, AssignmentHours )
		SELECT @RequestId, 'PRJ', ta.ProjectId, ta.ResourceId, ta.TaskAssignmentId, da.DemandDate, da.DemandHours
		FROM   #TaskAssignment ta
		INNER JOIN  DailyDistribution da   WITH (NOLOCK)   ON ta.ID=da.ID AND  da.DemandDate BETWEEN @sDate AND @eDate 
			
	IF @ViewType=''
		INSERT INTO #ResourceDemandEffort (Type, ItemId, ResDemandDate, Effort)
		SELECT 'PRJ', ta.TaskAssignmentId, da.DemandDate, da.DemandHours
		FROM   #TaskAssignment ta
		INNER JOIN  DailyDistribution da   WITH (NOLOCK)   ON ta.ID=da.ID AND  da.DemandDate BETWEEN @sDate AND @eDate 
		
	IF @ViewType='VI'
		BEGIN
			IF @ReportType='G'
				INSERT INTO #ResourceDemandEffort (Type, ItemId, ResDemandDate, Effort)
				SELECT 'PRJ', ta.ProjectId, da.DemandDate, SUM(da.DemandHours)
				FROM   #TaskAssignment ta
				INNER JOIN  DailyDistribution da   WITH (NOLOCK)   ON ta.ID=da.ID AND  da.DemandDate BETWEEN @sDate AND @eDate 
				GROUP BY   ta.ProjectId, da.DemandDate
			
			ELSE
				BEGIN
					If @GroupByCommit=0 
						INSERT INTO #ResourceDemandEffort (ResDemandDate, Effort)
						SELECT  da.DemandDate, SUM(da.DemandHours)
						FROM   #TaskAssignment ta
						INNER JOIN  DailyDistribution da   WITH (NOLOCK)   ON ta.ID=da.ID AND  da.DemandDate BETWEEN @sDate AND @eDate 
						GROUP BY   da.DemandDate
						
				ELSE
					
						INSERT INTO #ResourceDemandEffort (ResDemandDate, [Committed],Effort)
						SELECT  da.DemandDate, ta.[Committed], SUM(da.DemandHours)
						FROM   #TaskAssignment ta
						INNER JOIN  DailyDistribution da   WITH (NOLOCK)   ON ta.ID=da.ID AND  da.DemandDate BETWEEN @sDate AND @eDate 
						GROUP BY   da.DemandDate,  ta.[Committed]
				END 
		END 
	IF @ViewType='VW'
		INSERT INTO #ResourceDemandEffort (ItemId, ResDemandDate,Effort)
		SELECT ta.WorkgroupId, da.DemandDate,  SUM(da.DemandHours)
		FROM   #TaskAssignment ta
		INNER JOIN  DailyDistribution da   WITH (NOLOCK)   ON ta.ID=da.ID AND  da.DemandDate BETWEEN @sDate AND @eDate 
		GROUP BY  ta.WorkgroupId,da.DemandDate
	IF (@ViewType)='VF'
		INSERT INTO #ResourceDemandEffort (ItemId, ResDemandDate,Effort)
		SELECT  ta.FunctionId, da.DemandDate,  SUM(da.DemandHours)
		FROM   #TaskAssignment ta
		INNER JOIN  DailyDistribution da   WITH (NOLOCK)   ON ta.ID=da.ID AND  da.DemandDate BETWEEN @sDate AND @eDate 
		GROUP BY   ta.FunctionId,da.DemandDate
		
	IF @ViewType IN ('VRW', 'VRF')
		INSERT INTO #ResourceDemandEffort (ItemId, ResDemandDate,Effort)
		SELECT ta.ResourceId, da.DemandDate, SUM(da.DemandHours)
		FROM   #TaskAssignment ta
		INNER JOIN  DailyDistribution da   WITH (NOLOCK)   ON ta.ID=da.ID AND  da.DemandDate BETWEEN @sDate AND @eDate 
		GROUP BY ta.ResourceId, da.DemandDate
	IF @ViewType='VRD'
		INSERT INTO #ResourceDemandEffort (Type, ResDemandDate,Effort)
		SELECT 'PRJ', da.DemandDate, SUM(da.DemandHours)
		FROM   #TaskAssignment ta
		INNER JOIN  DailyDistribution da   WITH (NOLOCK)   ON ta.ID=da.ID AND  da.DemandDate BETWEEN @sDate AND @eDate 
		GROUP BY  da.DemandDate
	DELETE DemandItemRequest WHERE  RequestId=@RequestId
	IF NOT @TransactionXML IS NULL 
		EXEC SaveTransactionLog @@PROCID, @PM_StartLogTime, @TransactionXML
SET NOCOUNT OFF
END

GO

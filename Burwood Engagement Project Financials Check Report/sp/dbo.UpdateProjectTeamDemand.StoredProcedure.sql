USE [Changepoint]
GO
/****** Object:  StoredProcedure [dbo].[UpdateProjectTeamDemand]    Script Date: 10/14/2019 2:31:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateProjectTeamDemand]
(
	@RequestId		UNIQUEIDENTIFIER,
	@TYPE			VARCHAR(3),
	@TransactionXML XML=NULL
)
 
	
AS
BEGIN
	
	DEClARE @PM_StartLogTime	DATETIME
	IF NOT @TransactionXML IS NULL SET @PM_StartLogTime=GETUTCDATE()
	DELETE ProjectTeamDailyAllocation
	FROM ProjectTeamDailyAllocation ptd  WITH (NOLOCK) 
	INNER JOIN 
	(
		SELECT ptr.ProjectTeamId FROM ProjectTeamRequest ptr  WITH (NOLOCK)  WHERE ptr.LevRequestId=@RequestId 
		AND
		(
			(ptr.Cancel=1) 
			OR  
				(
				  EXISTS
					( SELECT  TOP 1 1 FROM ProjectTeam pt  WITH (NOLOCK)  WHERE ptr.ProjectTeamId=pt.ProjectTeamId
						AND ((ptr.DemandHours <>pt.DemandHours) OR (pt.StartDate<>ptr.StartDate) OR (pt.FinishDate<>ptr.FinishDate))
					)
				)
			OR 
				(
					EXISTS(SELECT TOP 1 1 FROM  PTeamDailyallocationRequest pda WITH (NOLOCK)  WHERE pda.RequestId=@RequestId 
					AND pda.ProjectTeamId=ptr.ProjectTeamId)
				)
		)
	) tt ON tt.ProjectTeamId=ptd.ProjectTeamId 
	
	UPDATE ProjectTeam 
	SET EstimatedHours=ptr.EstimatedHours, DemandHours=CASE WHEN ptr.DemandHours < 0 THEN 0 ELSE ptr.DemandHours END , 
		UpdatedOn=GETDATE(), ConversionToDay = ptr.ConversionToDay, WorkingDays = ptr.WorkingDays,
		WorkingDaysUpdatedOn=GETDATE()
	FROM ProjectTeam pt  WITH (NOLOCK) 
	INNER JOIN ProjectTeamRequest ptr  WITH (NOLOCK)  ON ptr.LevRequestId=@RequestId AND ptr.Cancel=0 AND ptr.ProjectTeamId=pt.ProjectTeamId 
	INSERT INTO  ProjectTeamDailyAllocation(ProjectTeamId, StartDate, EndDate, Effort)
	SELECT ptd.ProjectTeamId, ptd.StartDate, ptd.EndDate, ptd.Effort FROM PTeamDailyallocationRequest ptd  WITH (NOLOCK)   
	INNER JOIN ProjectTeamRequest ptr  WITH (NOLOCK)  ON ptr.LevRequestId=@RequestId AND ptr.ProjectTeamId=ptd.ProjectTeamId AND ptr.Cancel=0 
	WHERE ptd.RequestId=@RequestId
	IF NOT @TransactionXML IS NULL 
		EXEC SaveTransactionLog @@PROCID, @PM_StartLogTime, @TransactionXML
	
	
END

GO

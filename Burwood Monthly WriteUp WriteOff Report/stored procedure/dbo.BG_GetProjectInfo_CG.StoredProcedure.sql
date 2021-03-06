USE [Changepoint2018]
GO
/****** Object:  StoredProcedure [dbo].[BG_GetProjectInfo_CG]    Script Date: 10/11/2019 2:24:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[BG_GetProjectInfo_CG]
@Project varchar(200)
as
set nocount on;




select
	rg.Description as Region,
	 coalesce(pra.Name, 'No Practice Defined') as Practice,
	w.Name as Workgroup,
	c.Name as Customer,
	ae1.Name as AccountExecutive,
	pm.ProjectManager,
	e.Name as Engagement,
	e.EngagementId,
	--es.Description as EngagementStatus,
	e.EngagementStatus as EngStatus,
	p.Name as Project,
	p.ProjectId,
	--ps.Description as ProjectStatus,
	p.ProjectStatus as PrjStatus,
	case when coalesce(p.AllowTaskExpenses,0)=0 then 'No' else 'Yes' end as AllowTaskExpenses,
	convert(date, p.BaselineStart) as BaselineStart,
	convert(date, p.BaselineFinish) as BaselineFinish,
	case when p.BaselineFinish is null
		 then 'No Baseline Defined'
		 when (DATEDIFF(yy, getdate(), p.BaselineFinish))=0 and DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate()), p.BaselineFinish)=0
		 then (case when (DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate()), p.BaselineFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate())), p.BaselineFinish))<0
					then '-'+CAST(-DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate()), p.BaselineFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate())), p.BaselineFinish) AS varchar(2))
					else CAST(-DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate()), p.BaselineFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate())), p.BaselineFinish) AS varchar(2))
					end +' day')
		 
		 when (DATEDIFF(yy, getdate(), p.BaselineFinish))=0
		 then (CAST(DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate()), p.BaselineFinish) AS varchar(2)) +' month '+
			   case when (DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate()), p.BaselineFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate())), p.BaselineFinish))<0
					then '-'+CAST(-DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate()), p.BaselineFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate())), p.BaselineFinish) AS varchar(2))
					else CAST(-DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate()), p.BaselineFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate())), p.BaselineFinish) AS varchar(2))
					end +' day')
		 else (CAST(DATEDIFF(yy, getdate(), p.BaselineFinish) AS varchar(4)) +' year '+
			   CAST(DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate()), p.BaselineFinish) AS varchar(2)) +' month '+
			   case when (DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate()), p.BaselineFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate())), p.BaselineFinish))<0
					then '-'+CAST(-DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate()), p.BaselineFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate())), p.BaselineFinish) AS varchar(2))
					else CAST(-DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate()), p.BaselineFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate())), p.BaselineFinish) AS varchar(2))
					end +' day')
	end as BaselineLag,
	DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate()), p.BaselineFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.BaselineFinish), getdate())), p.BaselineFinish) as BaselineDaysLag,
	case when BaselineFinish is null
		 then 'No Baseline Defined'
		 when datediff(day, getdate(), BaselineFinish)<0
		 then 'Behind Schedule'
		 else 'On Track'
	end BaselineLagStatus,
	convert(date, p.PlannedStart) as PlannedStart,
	convert(date, p.PlannedFinish) as PlannedFinish,
	case when (DATEDIFF(yy, getdate(), p.PlannedFinish))=0 and DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate()), p.PlannedFinish)=0
		 then (case when (DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate()), p.PlannedFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate())), p.PlannedFinish))<0
					then '-'+CAST(-DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate()), p.PlannedFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate())), p.PlannedFinish) AS varchar(2))
					else CAST(-DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate()), p.PlannedFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate())), p.PlannedFinish) AS varchar(2))
					end +' day')
		 
		 when (DATEDIFF(yy, getdate(), p.PlannedFinish))=0
		 then (CAST(DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate()), p.PlannedFinish) AS varchar(2)) +' month '+
			   case when (DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate()), p.PlannedFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate())), p.PlannedFinish))<0
					then '-'+CAST(-DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate()), p.PlannedFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate())), p.PlannedFinish) AS varchar(2))
					else CAST(-DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate()), p.PlannedFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate())), p.PlannedFinish) AS varchar(2))
					end +' day')
		 else (CAST(DATEDIFF(yy, getdate(), p.PlannedFinish) AS varchar(4)) +' year '+
			   CAST(DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate()), p.PlannedFinish) AS varchar(2)) +' month '+
			   case when (DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate()), p.PlannedFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate())), p.PlannedFinish))<0
					then '-'+CAST(-DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate()), p.PlannedFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate())), p.PlannedFinish) AS varchar(2))
					else CAST(-DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate()), p.PlannedFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate())), p.PlannedFinish) AS varchar(2))
					end +' day')
	end as PlannedLag,
	DATEDIFF(dd, DATEADD(mm, DATEDIFF(mm, DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate()), p.PlannedFinish), DATEADD(yy, DATEDIFF(yy, getdate(), p.PlannedFinish), getdate())), p.PlannedFinish) as PlannedDaysLag,
	case when datediff(day, getdate(), PlannedFinish)<0
		 then 'Behind Schedule'
		 else 'On Track'
	end PlannedLagStatus,
	coalesce(p.LabourBudget,0) as LaborBudget,
	coalesce(p.ExpenseBudget,0) as ExpenseBudget,
	coalesce(p.OtherExpenseBudget,0) as OtherExpenseBudget,
	--case when coalesce(p.BaselineHours,0)=0 or p.BaselineHours='' then coalesce(fv.EstimatedHours,0) end as BaselineHours,
	p.BaselineHours,
	--case when coalesce(p.BaselineHours,coalesce(fv.EstimatedHours,0))=0 then coalesce(fv.EstimatedHours,0) end as BaselineHours,
	coalesce(p.ActualHours,0) as ActualHours,
	coalesce(p.PlannedHours,0) as PlannedHours,
	e.ContractNumber,
	coalesce(e.ContractAmount,0) as ContractAmount,
	coalesce(e.RevRec,0) as RevRec,
	coalesce(e.RevAdjTotal,0) as RevAdjTotal,

	--coalesce(ab.PotentialFees,0) as ProjectPotentialFees,
	--coalesce(ab.RevenueRecognized,0) as ProjectRevenueRecognized,
	--coalesce(ab.NewA	coalesce(ab.BillableHours,0) as ProjectBillableHours,ctualCost,0) as ProjectActualCost,
	--(select sum(AdjustmentAmount) from BG_ProjectDashboard_AdjustmentsAllTotal_CG(e.EngagementId)) as Adjustments,
	--coalesce(ab.Adjustments,0) as Adjustments,
	--coalesce(ab.WriteUpWriteOff,0) as WriteUpWriteOff,
	--coalesce(f.ForecastHours,0) as ForecastHours,
	--coalesce(f.ForecastRevenue,0) as ForecastRevenue,
	--coalesce(f.ForecastCost,0) as ForecastCost,
	e.RevRecDate,
	coalesce(e.ContractAmount,0)-coalesce(e.RevRec,0)-coalesce(e.RevAdjTotal,0) as RemainingContractAmount,
	bt.Description as BillingType,
	pt.Description as PaymentTerms,
	e.OtherBillingInformation,
	ebt.Description as ExpenseBillingType
	  --(select sum(ExpectedInternalCost) from [BG_EAC_Summary_CG] eac where eac.EngagementId=e.EngagementId) as ExpectedInternalCost
from 
	dbo.Engagement e with (nolock)
		left outer join
	CostCenters pra with (nolock) on e.CostCenterId=pra.CostCenter
		left outer join
	Workgroup w with (nolock) on e.AssociatedWorkgroup=w.WorkgroupId
	--	join
	--EngagementStatus es with (nolock) on e.EngagementStatus=es.Code
		join
	Customer c with (nolock) on e.CustomerId=c.CustomerId
		join
	BillingOffice rg with (nolock) on e.BillingOfficeId=rg.BillingOfficeId
		join
	dbo.BillingType bt with (nolock) on e.BillingType=bt.Code
		join
	dbo.PaymentTerms pt with (nolock) on e.PaymentTerms=pt.Code
		join
	dbo.Project p with (nolock) on e.EngagementId=p.EngagementId
	--	join
	--ProjectStatus ps with (nolock) on p.ProjectStatus=ps.Code
		join
	BG_ProjectManager_CG pm with (nolock) on p.ProjectId=pm.ProjectId
		left outer join
	Resources ae1 with (nolock) on e.InternalContactId=ae1.ResourceId
		join
	ExpenseBillingType ebt with (nolock) on e.ExpenseBillingType=ebt.Code
where
	p.Deleted=0
	and e.Deleted=0
	and p.Name like '%'+@Project+'%'
	
GO

USE [Changepoint]
GO
/****** Object:  View [dbo].[BG_ProjectDashboard_Engagement_2018v2_CG]    Script Date: 10/14/2019 3:21:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








----select TotalBudget, TotalActualBudget, TotalForecastAmount, FixedFeeContractorPassThroughBudget, FixedFeeSubContractorMarginBudget, ForecastFFContractorPassThrough, ExpenseBillingType, ExpenseAmount, * from [BG_ProjectDashboard_Engagement_2018_CG] where Project='Wake Forest Baptist Health - Access Center Refresh'


----select * from [BG_ProjectDashboard_Engagement_2018_CG] where Project='Cornerstone--Americore Ellwood City Site Assesment'--'True Value Novell File Migration'


CREATE VIEW [dbo].[BG_ProjectDashboard_Engagement_2018v2_CG] AS
with en as 
(
select
	e.Name as Engagement,
	e.EngagementId,
	--p.AllowTaskExpenses as AllowTaskExpenseFlag,
	es.Description as EngagementStatus,
	e.EngagementStatus as EngagementStatusCode,
	p.Name as Project,
	ps.Description as ProjectStatus,
	p.ProjectStatus as ProjectStatusCode,
	case when coalesce(p.AllowTaskExpenses,0)=0 then 'No' else 'Yes' end as AllowTaskExpenses,
	p.ProjectId,
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
	case when coalesce(p.BaselineHours,0)<>0
		 then coalesce(p.BaselineHours,0)
		 when coalesce(p.BaselineHours,coalesce(fv.EstimatedHours,0))=0 then coalesce(fv.EstimatedHours,0) 
	end as BaselineHours,
	coalesce(p.ActualHours,0) as ActualHours,
	coalesce(p.PlannedHours,0) as PlannedHours,
	e.ContractNumber,
	coalesce(e.ContractAmount,0) as ContractAmount,
	coalesce(e.RevRec,0) as RevRec,
	coalesce(e.RevAdjTotal,0) as RevAdjTotal,
	coalesce(ab.BillableHours,0) as ProjectBillableHours,
	coalesce(ab.PotentialFees,0) as ProjectPotentialFees,
	coalesce(ab.RevenueRecognized,0) as ProjectRevenueRecognized,
	coalesce(ab.NewActualCost,0) as ProjectActualCost,
	(select sum(AdjustmentAmount) from BG_ProjectDashboard_AdjustmentsAllTotal_CG(e.EngagementId)) as Adjustments,
	--coalesce(ab.Adjustments,0) as Adjustments,
	coalesce(ab.WriteUpWriteOff,0) as WriteUpWriteOff,
	coalesce(f.ForecastHours,0) as ForecastHours,
	case when p.ProjectStatus='C' then 0 else coalesce(f.ForecastRevenue,0) end as ForecastRevenue,
	coalesce(f.ForecastCost,0) as ForecastCost,
	e.RevRecDate,
	coalesce(e.ContractAmount,0)-coalesce(e.RevRec,0)-coalesce(e.RevAdjTotal,0) as RemainingContractAmount,
	bt.Description as BillingType,
	pt.Description as PaymentTerms,
	e.OtherBillingInformation,
	ebt.Description as ExpenseBillingType,
	fv.POContractAmountCalculated,
      fv.ServicesAmount,
      coalesce(fv.ExpenseAmount,0) as ExpenseAmount,
      fv.FixedFeeContractorPassThroughAmount as FixedFeeContractorPassThroughBudget,
      fv.FixedFeeSubContractorMargin as FixedFeeSubContractorMarginBudget,

      fv.EstimationCost,
      fv.EstimationSell,
      fv.PlannedMarginPercent,
      fv.PlannedCostBudget,
      fv.PlannedProfitability,
      fv.[Risk$],
      fv.[Risk%],
      fv.NumberOfProjects,
      fv.MultipleProjects,
      fv.POContractAmountDifference,
      fv.POContractAmountMatches,
      fv.MultipleProjectsDisplay,
	  coalesce(fv.EstimatedHours,0) as EstimatedHours,
	  (select sum(ExpectedInternalCost) from [BG_EAC_Summary_CG] eac where eac.EngagementId=e.EngagementId) as ExpectedInternalCost,
	  ajt.[Adjustment to Close a Project] as [Adjustment to Close a Project],
	  ajt.[Contractor Margin Adjustment],
	  ajt.[Contractor Pass-through Adjustment],
	  ajt.[Expense Recognition Adjustment],
	  ajt.[Other Adjustment],
	  case when ebt.Description='All Expenses' 
		   then 0 
		   else coalesce(ue.TotalExpense,0) 
	  end as UnapprovedExpenses,
	  coalesce(ae.TotalExpense,0) as ApprovedExpenses,
	  convert(varchar(5555), case when coalesce(p.Description, 'No Comments')='' then 'No Comments' else coalesce(p.Description, 'No Comments') end) as Comments,
	  --case when rg.Description = 'EA-Eastern Region' then 'East'
		 --  when rg.Description = 'WE-Western Region' then 'West'
		 --  else rg.Description
	  --end as Region,
	  rg.Description as Region,
	  c.Name as Customer,
	  ae1.Name as AccountExecutive,
	  pm.ProjectManager,
	  py.ProjectType,
	  coalesce(pra.Name, 'No Practice Defined') as Practice,
	  w.Name as Workgroup,
	  fv.POContractAmountMatchesCRM,
      fv.ServicesAmountMatches,
      fv.ExpenseAmountMatches,
      fv.FixedFeeContractorPassThroughAmountMatches,
      fv.FixedFeeSubContractorMarginMatches,
      fv.EstimationCostMatches,
      fv.EstimationSellMatches,
      fv.EstimatedHoursMatches,
      fv.PlannedMarginPercentMatches,
      fv.PlannedProfitabilityMatches,
	   fv.POContractAmountCRM,
      fv.ServicesAmountCRM,
      fv.ExpenseAmountCRM,
      fv.FixedFeeContractorPassThroughAmountCRM,
      fv.FixedFeeSubcontractorMarginCRM,
      fv.EstimationCostCRM,
      fv.EstimationSellCRM,
      fv.EstimatedHoursCRM,
      fv.PlannedMarginPercentCRM,
      fv.PlannedProfitabilityCRM,
	  fv.TechnicalArchitect,
	  fv.TechnicalArchitect2,
	  fv.TechnicalArchitect3,
	  ew.Error as RateChangeError
from
	dbo.Engagement e with (nolock)
		left outer join
	CostCenters pra with (nolock) on e.CostCenterId=pra.CostCenter
		left outer join
	Workgroup w with (nolock) on e.AssociatedWorkgroup=w.WorkgroupId
		join
	EngagementStatus es with (nolock) on e.EngagementStatus=es.Code
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
		left outer join
	BG_ProjectDashboard_FinancialValues_CG fv with (nolock) on p.EngagementId=fv.EngagementId and fv.ProjectId=p.ProjectId
		join
	ProjectStatus ps with (nolock) on p.ProjectStatus=ps.Code
		join
	BG_ProjectManager_CG pm with (nolock) on p.ProjectId=pm.ProjectId
		left outer join
	Resources ae1 with (nolock) on e.InternalContactId=ae1.ResourceId
		join
	ExpenseBillingType ebt with (nolock) on e.ExpenseBillingType=ebt.Code
		left outer join
	BG_ProjectDashboard_ForecastSummary_CG f with (nolock) on e.EngagementId=f.EngagementId and p.ProjectId=f.ProjectId
	--	left outer join
	--UDFText u with (nolock) on u.EntityId=e.EngagementId and u.ItemName='EngagementText7'
		left outer join
	BG_ProjectDashboard_ActualTotals_byProject_CG  ab with (nolock) on p.EngagementId=ab.EngagementId  and p.ProjectId=ab.ProjectId
	--BG_ProjectDashboard_ActualTotals_byEngagement_CG ab with (nolock) on e.EngagementId=ab.EngagementId
		left outer join
	BG_ProjectDashboard_AdjustmentsByType_byEngagement_CG ajt with (nolock) on e.EngagementId=ajt.EngagementId
		left outer join
	BG_ProjectDashboard_UnapprovedExpensesSummary_CG ue with (nolock) on e.EngagementId=ue.EngagementId and p.ProjectId=ue.ProjectId
		left outer join
	[BG_ProjectDashboard_ApprovedExpensesSummary_CG] ae with (nolock) on e.EngagementId=ae.EngagementId and p.ProjectId=ae.ProjectId
		left outer join
	BG_ProjectTypeUDF_CG py with (nolock) on p.ProjectId=py.ProjectId
		left outer join
	BG_ProjectDashboard_CRMValueCheck_CG crm with (nolock) on p.EngagementId=crm.EngagementId and p.ProjectId=crm.ProjectId
		left outer join
	(SELECT distinct ProjectId, 'Retro-Active Rate Change' as Error FROM BG_ProjectDashboard_Resource_BillingRates_Table_CG where RevRecMatches='No') ew on p.ProjectId=ew.ProjectId
where	
	p.Deleted=0
	and e.Deleted=0
	--and e.EngagementId='47B200B0-7C10-46CC-A7F8-1B0E81C91BF1'
	--and p.Name='AMITA Health- HQ Move- Video'
--where p.Name='Rush University Medical Center - Cybersecurity Strategy'--'Baptist Health Care Quarterly Citrix Health Checks 2016'--'CEFCU Core and Datacenter Refresh Project '--'Advocate HealthCare - CTS 1300 Replacement Services'--'OUMI - AD and Network Strategy Assessment'
),
b as (
select
	Region,
	Practice,
	Workgroup,
	Customer,
	ProjectManager,
	AccountExecutive,
	Engagement,
	EngagementId,
	BillingType,
	PaymentTerms,
	OtherBillingInformation,
	ExpenseBillingType,
	EngagementStatus,
	EngagementStatusCode,
	Project,
	ProjectStatus,
	ProjectStatusCode,
	ProjectType,
	ProjectId,
	BaselineStart,
	BaselineFinish,
	BaselineLag,
	BaselineLagStatus,
	PlannedStart,
	PlannedFinish,
	PlannedLag,
	PlannedLagStatus,
	LaborBudget,
	ExpenseBudget,
	OtherExpenseBudget,
	coalesce(BaselineHours, EstimatedHours) as BaselineHours,
	ActualHours,
	PlannedHours,
	ForecastHours,
	coalesce([Risk$],0) as ContingencyAmount,
	ContractNumber,
	ContractAmount,
	RevRec,
	coalesce(Adjustments,0) as RevAdjTotal,
	ProjectBillableHours,
	ProjectPotentialFees,
	ProjectRevenueRecognized,
	0 as EngagementBillableHours,
	0 as EngagementPotentialFees,
	0 as EngagementRevenueRecognized,
	ForecastRevenue,
	RevRecDate,
	RemainingContractAmount as RemainingContractAmount1,
	ContractAmount-ProjectPotentialFees+coalesce(Adjustments,0) as RemainingContractAmount,
	WriteUpWriteOff as ForecastRemainingContractAmount,
	LaborBudget-ProjectPotentialFees as ProjectRemainingAmount,
	LaborBudget-ProjectPotentialFees-ForecastRevenue as ProjectPlannedRemainingAmount,
	--case when ProjectStatusCode='C' then 0 else LaborBudget-ProjectPotentialFees-ForecastRevenue end ProjectPlannedRemainingAmount,
	0 as EngagementWriteUpWriteOff,--ContractAmount-EngagementPotentialFees+Adjustments-ForecastRevenue as EngagementWriteUpWriteOff,
	WriteUpWriteOff as TheRealWriteUpWriteOff,
	LaborBudget-ProjectPotentialFees-ForecastRevenue as NewWriteUpWriteOff,  --ProjectWriteUpWriteOff Amount
	0 as EngagementRealizationRate,
	--divide by 0 
	case when ActualHours=0 
		 then 0 
		 else case when (ActualHours+ForecastHours)=0 then 0 else (coalesce(ProjectRevenueRecognized,0)+coalesce(ForecastRevenue,0))/(ActualHours+ForecastHours) end
	end as ProjectRealizationRate,
	POContractAmountCalculated,
	ServicesAmount,
		ExpenseAmount,
		FixedFeeContractorPassThroughBudget,
		FixedFeeSubContractorMarginBudget,
		EstimationCost,
		EstimationSell,
		PlannedMarginPercent,
		PlannedCostBudget,
		PlannedProfitability,
		[Risk$],
		[Risk%],
		NumberOfProjects,
		MultipleProjects,
		POContractAmountDifference,
		POContractAmountMatches,
		MultipleProjectsDisplay,
		POContractAmountMatchesCRM,
		ServicesAmountMatches,
		ExpenseAmountMatches,
		FixedFeeContractorPassThroughAmountMatches,
		FixedFeeSubContractorMarginMatches,
		EstimationCostMatches,
		EstimationSellMatches,
		EstimatedHoursMatches,
		PlannedMarginPercentMatches,
		PlannedProfitabilityMatches,
		POContractAmountCRM,
		ServicesAmountCRM,
		ExpenseAmountCRM,
		FixedFeeContractorPassThroughAmountCRM,
		FixedFeeSubcontractorMarginCRM,
		EstimationCostCRM,
		EstimationSellCRM,
		EstimatedHoursCRM,
		PlannedMarginPercentCRM,
		PlannedProfitabilityCRM,
		TechnicalArchitect,
		TechnicalArchitect2,
		TechnicalArchitect3,
		RateChangeError,
		ExpectedInternalCost,
		case when (ProjectPotentialFees)=0 then 0 else ((ProjectPotentialFees)-(ProjectActualCost)) / (ProjectPotentialFees) end as 'ActualBillingMargin%',
		case when (ProjectPotentialFees+ForecastRevenue)=0 then 0 else ((ProjectPotentialFees+ForecastRevenue)-(ProjectActualCost+ForecastCost)) / (ProjectPotentialFees+ForecastRevenue) end as 'ForecastBillingMargin%',
		case when LaborBudget=0 then 0 else (LaborBudget-ProjectPotentialFees-ForecastRevenue)/LaborBudget end as ServicesDifference,
		case when AllowTaskExpenses='Yes' then 'OK'
			when ExpenseBillingType='No Expenses' and ExpenseBudget=0
			then 'Burwood Absorbs Expenses'
			when BillingType='Hourly' and ExpenseBillingType='No expenses' 
			then 'INVALID Expense Configuration'
			when BillingType='Fixed Fee' and ExpenseBillingType='No expenses' and ExpenseBudget=0 
			then 'FF Expense Configured but no Budget defined!'--'No Expense Budget Defined'
			else 'OK'
		end as BillingTypeErrorCheck,
		case when BillingTYpe= 'fixed fee' 
			then 'Fixed Fee'
			when (LaborBudget + ExpenseBudget + FixedFeeContractorPassThroughBudget + FixedFeeSubContractorMarginBudget) = ContractAmount
			then 'PO Includes NTE Expenses'
			when (LaborBudget + FixedFeeContractorPassThroughBudget + FixedFeeSubContractorMarginBudget)=ContractAmount
			then 'PO includes services only'
			else 'Validation Error'
		end as ContractAmountIncludesErrorCheck,
		--case when BillingType='Hourly' and (LaborBudget+ExpenseBudget)=ContractAmount 
			--  then 'Customer PO amount includes expenses'
			--  when BillingType='Hourly' and LaborBudget=ContractAmount
			--  then 'Customer PO only includes services'
			--  when 
			--  else 'Other'
		--end as ContractAmountIncludesErrorCheck,

	  
		AllowTaskExpenses,
		--AllowTaskExpenseFlag,
		ProjectActualCost as ProjectActualCost,
		-coalesce(Adjustments,0) as Adjustments,
		ForecastCost as ForecastCost,
		-[Adjustment to Close a Project] as [Adjustment to Close a Project],
		-[Contractor Margin Adjustment] as [Contractor Margin Adjustment],
		-[Contractor Pass-through Adjustment] as [Contractor Pass-through Adjustment],
		-[Expense Recognition Adjustment] as [Expense Recognition Adjustment],
		-[Other Adjustment] as [Other Adjustment],
		case when [EstimationCost]<>0 and [EstimationSell]<>0 then 'Yes' else 'Not Configured' end as NewFieldsConfigured,
		case when MultipleProjects='NO' and RateCHangeError is NULL
			then 'OK' 
			when MultipleProjects='NO' and RateCHangeError ='Retro-Active Rate Change'
			then 'Retro-Active Rate Change'
			when MultipleProjects='Yes' and RateCHangeError='Retro-Active Rate Change'
			then 'Retro-Active Rate Change & Multiple Projects'
			when MultipleProjects='Yes' and RateCHangeError is null 
			then 'Multiple Projects in this Engagement' 
		end as EngagementWarning,
		case when [ContractAmount]=[POContractAmountCalculated] then 'OK' else 'NO' end as FinancialConfigCheck,
		case when ExpenseBillingType='All Expenses' then 0 else ExpenseAmount end as FixedFeeExpenseBudget,
		case when ExpenseBillingType='All Expenses' then 0 else (-[Expense Recognition Adjustment]+coalesce(ApprovedExpenses,0)) end as FixedFeeExpenseActual,
		--case when ExpenseBillingType='All Expenses' then 0 else -[Expense Recognition Adjustment] end as FixedFeeExpenseActual,
		LaborBudget+(case when ExpenseBillingType='All Expenses' then 0 else ExpenseAmount end)+(FixedFeeContractorPassThroughBudget)+(FixedFeeSubContractorMarginBudget) as TotalBudget,
		(-coalesce(Adjustments,0))+ProjectPotentialFees as TotalActualBudget,
		UnapprovedExpenses as UnapprovedExpenses,
		case when ExpenseBillingType='No Expenses' and ExpenseBudget=0 then 0 else ApprovedExpenses end as ApprovedExpenses,
		case when ProjectStatusCode='C' then 0 else (FixedFeeContractorPassThroughBudget+[Contractor Pass-through Adjustment]) end as ForecastFFContractorPassThrough,
		case when ProjectStatusCode='C' then 0 else (FixedFeeSubContractorMarginBudget+[Contractor Margin Adjustment]) end as ForecastContractorMargin,
	--Write-Up (Write-Off) Calculations
		(LaborBudget-ProjectPotentialFees-ForecastRevenue) 
		--Adjustments
			+ (((case when ExpenseBillingType='All Expenses' then 0 else ExpenseAmount end)
				+(FixedFeeContractorPassThroughBudget)+(FixedFeeSubContractorMarginBudget))
		--Forecast
			- ((((case when ExpenseBillingType='All Expenses' then 0 else ExpenseAmount end)-(case when ExpenseBillingType='All Expenses' then 0 else -[Expense Recognition Adjustment] end))-UnapprovedExpenses)
				+ (case when ProjectStatusCode='C' then 0 else (FixedFeeContractorPassThroughBudget+[Contractor Pass-through Adjustment]) end)
				+ (case when ProjectStatusCode='C' then 0 else (FixedFeeSubContractorMarginBudget+[Contractor Margin Adjustment]) end))
		
			+ (coalesce(Adjustments,0))) as WUWO,
	  
		--(LaborBudget-ProjectPotentialFees-ForecastRevenue)+(((case when ExpenseBillingType='All Expenses' then 0 else ExpenseAmount end)+(FixedFeeContractorPassThroughBudget)+(FixedFeeSubContractorMarginBudget))-(UnapprovedExpenses+(FixedFeeContractorPassThroughBudget+[Contractor Pass-through Adjustment])+(FixedFeeSubContractorMarginBudget+[Contractor Margin Adjustment]))+(Adjustments)) as WUWO,
	  

		(	ForecastRevenue--UnapprovedExpenses
		+	(case when ProjectStatusCode='C' then 0 else (FixedFeeContractorPassThroughBudget+[Contractor Pass-through Adjustment]) end)
		+	(case when ProjectStatusCode='C' then 0 else (FixedFeeSubContractorMarginBudget+[Contractor Margin Adjustment]) end)) 
		+((case when ExpenseBillingType='All Expenses' then 0 else ([Expense Recognition Adjustment]+ApprovedExpenses) end))-UnapprovedExpenses
		--+  (((case when ExpenseBillingType='All Expenses' then 0 else ExpenseAmount end)-(case when ExpenseBillingType='All Expenses' then 0 else [ExpenseForecast]-[Expense Recognition Adjustment] end))-UnapprovedExpenses)
		as TotalForecastAmount,
	  
		--case when ProjectStatusCode='C' then 0 else (FixedFeeContractorPassThroughBudget+[Contractor Pass-through Adjustment]) end as ContractorPassThroughForecastCalcCheck,
		--case when ProjectStatusCode='C' then 0 else (FixedFeeSubContractorMarginBudget+[Contractor Margin Adjustment]) end  as ContractMarginForecastCalcCheck,
		--(((case when ExpenseBillingType='All Expenses' then 0 else ExpenseAmount end)-(case when ExpenseBillingType='All Expenses' then 0 else -[Expense Recognition Adjustment] end))-UnapprovedExpenses) as ExpenseForecastCalcCheck,



		--((case when ExpenseBillingType='All Expenses' then 0 else ExpenseAmount end) + (FixedFeeContractorPassThroughBudget) + (FixedFeeSubContractorMarginBudget))
		-- -	(UnapprovedExpenses+(case when ProjectStatusCode='C' then 0 else (FixedFeeContractorPassThroughBudget+[Contractor Pass-through Adjustment]) end)
		-- +	(case when ProjectStatusCode='C' then 0 else (FixedFeeSubContractorMarginBudget+[Contractor Margin Adjustment]) end))
		-- +	(coalesce(Adjustments,0)) 
	  
		-- as EACTotalRemaining,
		case when ExpenseBillingType='No Expenses' and ExpenseBudget=0 then 0 else ExpenseAmount end as FixedFeeBAAExpenseBudget,
		case when ExpenseBillingType='No Expenses' and ExpenseBudget=0 then 0 else (ExpenseAmount - ApprovedExpenses)-UnapprovedExpenses end as FFBAAExpenseRemaining,
		case when ExpenseBillingType='No expenses' or (ExpenseBillingType<>'No expenses' and ExpenseAmount=0) 
			 then 0 
			 when ExpenseAmount=0
			 then 0
			 else ((ExpenseAmount - ApprovedExpenses)-UnapprovedExpenses)/ExpenseAmount 
		end as FFBAAExpenseRemainDiff,
		EstimationCost-ProjectActualCost-ForecastCost as EstimationCostRemaining,
		case when EstimationCost=0 
			 then 0 
			 else (EstimationCost-ProjectActualCost-ForecastCost)/EstimationCost 
		end as EstimationCostRemainDiff,
		PlannedCostBudget-ProjectActualCost-ForecastCost as PlannedCostRemaining,
		case when PlannedCostBudget=0 
			 then 0 
			 else (PlannedCostBudget-ProjectActualCost-ForecastCost)/PlannedCostBudget 
		end as PlannedCostRemainDiff,
		--(ProjectPotentialFees+ForecastRevenue)+ForecastCost as 'Margin$Forecast1',
	  
		round(((case when (ProjectPotentialFees+ForecastRevenue)=0 
					 then 0 
					 else ((ProjectPotentialFees+ForecastRevenue)-(ProjectActualCost+ForecastCost)) / (ProjectPotentialFees+ForecastRevenue) end))*100 - (PlannedMarginPercent*100),2) 
		as 'ActualBillingMargin%Check',
		EstimatedHours,
		BaselineHours-ActualHours as EACRemainingHours,
		case when BaselineHours=0 
			 then 0 
			 else (BaselineHours-ActualHours)/BaselineHours 
		end as EACHoursDifference,
	  
		case when ExpenseBillingType='All Expenses' then 0 
			when (case when ExpenseBillingType='All Expenses' then 0 else ExpenseAmount end)-([Expense Recognition Adjustment]+UnapprovedExpenses+ApprovedExpenses)<0
			then (case when ExpenseBillingType='All Expenses' then 0 else ExpenseAmount end)-([Expense Recognition Adjustment]+UnapprovedExpenses+ApprovedExpenses)
			else 0
		end	as EACExpenseAmount,

	case when FixedFeeContractorPassThroughBudget+[Contractor Pass-through Adjustment]<0
			then FixedFeeContractorPassThroughBudget+[Contractor Pass-through Adjustment]
			else 0
	end as EACContractorPassThroughAmount,

	case when FixedFeeSubContractorMarginBudget+[Contractor Margin Adjustment]<0
			then FixedFeeSubContractorMarginBudget+[Contractor Margin Adjustment]
			else 0
	end as EACContractorMarginAmount,


	(case when (case when ExpenseBillingType='All Expenses' then 0 else ExpenseAmount end)-([Expense Recognition Adjustment]+UnapprovedExpenses)<0
			then (case when ExpenseBillingType='All Expenses' then 0 else ExpenseAmount end)-([Expense Recognition Adjustment]+UnapprovedExpenses)
			else 0
	end)
	+(case when FixedFeeContractorPassThroughBudget+[Contractor Pass-through Adjustment]<0
			then FixedFeeContractorPassThroughBudget+[Contractor Pass-through Adjustment]
			else 0
	end)
	+(case when FixedFeeSubContractorMarginBudget+[Contractor Margin Adjustment]<0
			then FixedFeeSubContractorMarginBudget+[Contractor Margin Adjustment]
			else 0
	end) as EACTotalAdjustments,
		Comments
		--NewProjectActualCost
	from
	en
	)
	select
	*,
	ProjectPlannedRemainingAmount+EACExpenseAmount+EACContractorPassThroughAmount+EACContractorMarginAmount as EACTotalRemaining,
	(ProjectPotentialFees+ForecastRevenue)-(ForecastCost+ProjectActualCost) as 'Margin$Forecast',
	(ProjectPotentialFees)-ProjectActualCost as 'Margin$Actual',
	case when (ProjectPotentialFees+ForecastRevenue)=0 
		 then 0 
		 else ( (ProjectPotentialFees+ForecastRevenue)-(ForecastCost+ProjectActualCost) )/ (ProjectPotentialFees+ForecastRevenue) 
	end as 'Margin%Forecast',
	--case when (ProjectPotentialFees)=0 
	--	 then 0 
	--here51
	case
		 when BillingType='Fixed Fee' 
		 then case when LaborBudget=0 then 0 else ((ProjectPotentialFees)-(ProjectActualCost))/LaborBudget end
		 else case when ProjectPotentialFees=0 then 0 else ((ProjectPotentialFees)-(ProjectActualCost))/ProjectPotentialFees end
	end as 'Margin%Actual',
	(LaborBudget-ForecastCost-ProjectActualCost)+(ProjectPlannedRemainingAmount+EACExpenseAmount+EACContractorPassThroughAmount+EACContractorMarginAmount) as 'Margin$EAC',
	((LaborBudget-ForecastCost-ProjectActualCost)+(ProjectPlannedRemainingAmount+EACExpenseAmount+EACContractorPassThroughAmount+EACContractorMarginAmount))-(PlannedProfitability) as 'Margin$Diff',
	case when LaborBudget=0 then 0 else ((LaborBudget-ForecastCost-ProjectActualCost)+(ProjectPlannedRemainingAmount+EACExpenseAmount+EACContractorPassThroughAmount+EACContractorMarginAmount))/LaborBudget end as 'Margin%EAC',
	(case when LaborBudget=0 then 0 else ((LaborBudget-ForecastCost-ProjectActualCost)+(ProjectPlannedRemainingAmount+EACExpenseAmount+EACContractorPassThroughAmount+EACContractorMarginAmount))/LaborBudget end)-PlannedMarginPercent as 'Margin%Diff',
	case when LaborBudget=0 then 0 else ProjectPotentialFees/LaborBudget end as ServicesConsumed,
	case when FixedFeeExpenseBudget=0 then 0 else FixedFeeExpenseActual/FixedFeeExpenseBudget end  as ExpensesConsumed,
	case when FixedFeeContractorPassThroughBudget=0 then 0 else -[Contractor Pass-through Adjustment]/FixedFeeContractorPassThroughBudget end  as FFContractorPassthroughConsumed,
	case when FixedFeeSubContractorMarginBudget=0 then 0 else -[Contractor Margin Adjustment]/FixedFeeSubContractorMarginBudget end  as FFContractorMarginConsumed,
	case when FixedFeeBAAExpenseBudget=0 then 0 else ApprovedExpenses/FixedFeeBAAExpenseBudget end as ExpensesChargedtoCustomerConsumed, 
	case when EstimationCost=0 then 0 else ProjectActualCost/EstimationCost end as EstimationCostConsumed, 
	case when PlannedCostBudget=0 then 0 else ProjectActualCost/PlannedCostBudget end as PlannedCostConsumed,
	case when PlannedMarginPercent=0 then 0 else (case when (ProjectPotentialFees)=0 then 0 else ((ProjectPotentialFees)-(ProjectActualCost))/ProjectPotentialFees end)/PlannedMarginPercent end as 'Margin%Consumed',
	case when PlannedProfitability=0 then 0 else ((ProjectPotentialFees)-ProjectActualCost)/PlannedProfitability end as 'Margin$Consumed',
	case when BaselineHours=0 then 0 else ActualHours/BaselineHours end as EstimatedHoursConsumed,
	case when WUWO>=0 then 'On Track'
			when WUWO<0 then 'Troubled'
	end as WOWUStatus,
	case when ExpenseBillingType='No Expenses'
			then 'Burwood Absorbs Expenses'
			when BillingType='Hourly' and ExpenseBillingType='No expenses' 
			then 'INVALID Expense Configuration'
			when BillingType='Fixed Fee' and ExpenseBillingType='No expenses' and ExpenseBudget=0 
			then 'FF Expense Configured but no Budget defined!'--'No Expense Budget Defined'
			else 'OK'
		end as ExpenseConfigurationCheck,
		case when [POContractAmountCRM]>0 and [ContractAmount]>[POContractAmountCRM]
			then 'Change Request Applied'
			when [FixedFeeContractorPassThroughAmountMatches] ='No'
				or [FixedFeeSubContractorMarginMatches] ='No'
				or [EstimationCostMatches] ='No'
				or [EstimationSellMatches] ='No'
			then 'No - click here for details'
			else 'Yes'
	end as [CRM Data Matches],
	FixedFeeExpenseBudget+FixedFeeContractorPassThroughBudget+FixedFeeSubContractorMarginBudget as TotalAdjustmentBudget,
	--case when FixedFeeExpenseBudget=0 then UnapprovedExpenses else (FixedFeeExpenseBudget+FixedFeeExpenseActual)-UnapprovedExpenses end as ExpenseForecast,
	 
	(FixedFeeExpenseBudget+(case when ExpenseBillingType='All Expenses' then 0 else (-[Expense Recognition Adjustment]+ApprovedExpenses) end))-UnapprovedExpenses as ExpenseForecast,
	--(FixedFeeExpenseBudget+FixedFeeExpenseActual)-UnapprovedExpenses as ExpenseForecast,
	
	
	--THE REAL WriteUpWriteOff for Project Dashboard
		(LaborBudget+FixedFeeContractorPassThroughBudget+FixedFeeSubContractorMarginBudget+FixedFeeExpenseBudget)
	-	(ProjectPotentialFees+ForecastRevenue)
	-	([Contractor Pass-through Adjustment]+[Contractor Margin Adjustment]-[Expense Recognition Adjustment]+UnapprovedExpenses+[Adjustment to Close a Project])
	as WriteUpWriteOff,
	
	
	
	
	
	--Project Dashboard
	(LaborBudget-ProjectPotentialFees-ForecastRevenue) 
		--Adjustments
			+ (((case when ExpenseBillingType='All Expenses' then 0 else ExpenseAmount end)
				+(FixedFeeContractorPassThroughBudget)+(FixedFeeSubContractorMarginBudget))
		--Forecast
			- (((FixedFeeExpenseBudget-FixedFeeExpenseActual)-UnapprovedExpenses)
				+ (case when ProjectStatusCode='C' then 0 else (FixedFeeContractorPassThroughBudget+[Contractor Pass-through Adjustment]) end)
				+ (case when ProjectStatusCode='C' then 0 else (FixedFeeSubContractorMarginBudget+[Contractor Margin Adjustment]) end))
		
			- (coalesce(Adjustments,0))) as OriginalWUWO,

	--THE REAL WriteUpWriteOff for Project Dashboard
	--	(LaborBudget+FixedFeeContractorPassThroughBudget+FixedFeeSubContractorMarginBudget+FixedFeeExpenseBudget)
	---	(ProjectPotentialFees+ForecastRevenue)
	---	([Contractor Pass-through Adjustment]+[Contractor Margin Adjustment]+[Expense Recognition Adjustment]+UnapprovedExpenses)
	--+	(EACExpenseAmount)
	--+(EACContractorPassThroughAmount)
	--+(EACContractorMarginAmount)
	---	(ForecastFFContractorPassThrough+ForecastContractorMargin+((FixedFeeExpenseBudget-FixedFeeExpenseActual)-UnapprovedExpenses)+[Adjustment to Close a Project])
	--as WriteUpWriteOffwithForecast,

	TotalBudget-TotalActualBudget-TotalForecastAmount as WriteUpWriteOffwithForecast
	
	--case when FixedFeeExpenseBudget-([Expense Recognition Adjustment]+UnapprovedExpenses)<0
	--	 then FixedFeeExpenseBudget-([Expense Recognition Adjustment]+UnapprovedExpenses)
	--	 else 0
	--end	as EACExpenseAmount,

	--case when FixedFeeContractorPassThroughBudget-[Contractor Pass-through Adjustment]<0
	--	 then FixedFeeContractorPassThroughBudget-[Contractor Pass-through Adjustment]
	--	 else 0
	--end as EACContractorPassThroughAmount,

	--case when FixedFeeSubContractorMarginBudget-[Contractor Margin Adjustment]<0
	--	 then FixedFeeSubContractorMarginBudget-[Contractor Margin Adjustment]
	--	 else 0
	--end as EACContractorMarginAmount,


	--(case when FixedFeeExpenseBudget-([Expense Recognition Adjustment]+UnapprovedExpenses)<0
	--	 then FixedFeeExpenseBudget-([Expense Recognition Adjustment]+UnapprovedExpenses)
	--	 else 0
	--end)
	--+(case when FixedFeeContractorPassThroughBudget-[Contractor Pass-through Adjustment]<0
	--	 then FixedFeeContractorPassThroughBudget-[Contractor Pass-through Adjustment]
	--	 else 0
	--end)
	--+(case when FixedFeeSubContractorMarginBudget-[Contractor Margin Adjustment]<0
	--	 then FixedFeeSubContractorMarginBudget-[Contractor Margin Adjustment]
	--	 else 0
	--end) as EACTotalAdjustments

	----Write-Up (Write-Off) Calculations
	--  (LaborBudget-ProjectPotentialFees-ForecastRevenue)
	--  --Adjustments
	--  --+(FixedFeeExpenseBudget+FixedFeeContractorPassThroughBudget+FixedFeeSubContractorMarginBudget)
	--  --Forecast
	--		- (((FixedFeeExpenseBudget-FixedFeeExpenseActual)-UnapprovedExpenses) + ForecastFFContractorPassThrough + ForecastContractorMargin)
		
	--		--+ Adjustments 
	--		as WriteUpWriteOff



	--case when AllowTaskExpenses='No' 
	--	 then 'Burwood Absorbs Expenses'
	--	 else ExpenseBillingType+' Charged to the Customer'
	--end as ExpenseConfigurationCheck


	

	from
	b


	--alter table BG_ProjectDashboard_Engagement_Table_CG
	--alter column [ActualBillingMargin%Check] numeric(38,2) null;

	--select PlannedMarginPercent, [ActualBillingMargin%], [ActualBillingMargin%og], [ProjectPotentialFees], ForecastRevenue, ProjectActualCost, ForecastCost, ExpectedInternalCost, * from BG_ProjectDashboard_Engagement_2018_CG where Project='AHA - AWS Cloud Remediation'
	--reportid 'incidents'

	----drop table BG_ProjectDashboard_Engagement_Table_CG select * into BG_ProjectDashboard_Engagement_Table_CG from [BG_ProjectDashboard_Engagement_2018_CG] where EngagementStatus<>'Closed'

	----truncate table BG_ProjectDashboard_Engagement_Table_CG insert into BG_ProjectDashboard_Engagement_Table_CG select * from [BG_ProjectDashboard_Engagement_2018_CG] where EngagementStatus<>'Closed'

	----select Project, ExpenseBillingType, ExpenseAmount, FixedFeeExpenseBudget, FixedFeeExpenseActual, UnapprovedExpenses, ExpenseForecast, [Expense Recognition Adjustment],  * from BG_ProjectDashboard_Engagement_Table_CG where Project='LACCD-UC District Wide Design and Oversight'--Project='Alliant - Active Directory and Exchange Migration'

	----select Project, ExpenseBillingType, ExpenseAmount, FixedFeeExpenseBudget, FixedFeeExpenseActual, UnapprovedExpenses, ExpenseForecast, [Expense Recognition Adjustment],  * from BG_ProjectDashboard_Engagement_Table_CG where UnapprovedExpenses<>0 or ExpenseForecast<>0




	--alter table BG_ProjectDashboard_Engagement_Closed_Table_CG
	--add WriteUpWriteOffwithForecast numeric(38,2) null;



	--alter table BG_ProjectDashboard_Engagement_Table_CG
	--add WriteUpWriteOffwithForecast numeric(38,2) null;




GO

USE [Changepoint2018]
GO
/****** Object:  View [dbo].[BG_ProjectDashboardSummaryScheduledV2_CG]    Script Date: 10/11/2019 1:49:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[BG_ProjectDashboardSummaryScheduledV2_CG] as 
select
	--'Burwood Group Inc.' as Company,
		p.Engagement,
	p.BillingType,
	p.Project,
	p.ProjectManager,
	p.POContractAmount,
	p.ServicesAmount,
	p.EmailAddress,
	p.ProjectStatus,
	p.BilledAmount,
	p.UnBilledAmount,
	p.TotalInvoiceAmount,
	p.WriteUpWriteOff,
	p.PlannedMarginPercent,
	p.[ActualBillingMargin%],
	p.[ActualBillingMargin%Check],
	p.ProjectId,
	p.EngagementId,
	f.Billed,
	f.DoNotInvoice,
	f.Deliverable,
	f.BillingDate,
	f.BillingAmount as BillingAmount,
	f.InvoicedAmount,
	f.TotalHours,
	f.RevPrev,
	f.RevPrevDate,
	f.RevRec,
	f.RevRecDate,
	f.RevAdj,
	f.FFSort,
	f.CreatedOn,
	si.Invoice as SentInvoice,
	si.InvoiceID as SentInvoiceId,
	si.InvoiceDate as SentInvoiceDate,
	coalesce(si.InvoiceTotal,0) as SentInvoiceTotal,
	si.Status as SentStatus,
	si.Paid as SentPaidStatus,
	sp.Invoice as PendingInvoice,
	sp.InvoiceID as PendingInvoiceId,
	sp.InvoiceDate as PendingInvoiceDate,
	coalesce(sp.InvoiceTotal,0) as PendingInvoiceTotal,
	sp.Status as PendingStatus,
	sp.Paid as PendingPaidStatus,
	'tshepherd@burwood.com' as TestBurst,
	p.EmailAddress+', tshepherd@burwood.com' as EmailBurst,
	p.EmailAddress+', tshepherd@burwood.com, jcourtney@burwood.com' as EmailBurstTest,
	'jcourtney@burwood.com, tshepherd@burwood.com' as VPEmailBurst


from
	BG_ProjectDashboardSummaryScheduled_CG p with (nolock)
		left outer join
	BG_ProjectDashboard_FixedFeeSchedule_CG f with (nolock) on p.ProjectId=f.ProjectId and f.FFSort<>1
		left outer join
	(select * from BG_ProjectDashboard_Invoices_CG where [Status] in ('Paid', 'Sent to Great Plains', 'Partially paid')) si on p.ProjectId=si.ProjectId
		left outer join
	(select * from BG_ProjectDashboard_Invoices_CG where [Status] not in ('Discarded', 'Credited', 'Paid', 'Sent to Great Plains', 'Partially paid', 'Archived', 'Committed')) sp on p.ProjectId=sp.ProjectId
where
	p.ProjectStatus<>'C'
	--and f.FFSort<>1
GO

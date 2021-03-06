USE [Changepoint2018]
GO
/****** Object:  View [dbo].[BG_ProjectDashboardSummaryPendingInvoices_CG]    Script Date: 10/11/2019 1:49:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[BG_ProjectDashboardSummaryPendingInvoices_CG] as 
select
	--'Burwood Group Inc.' as Company,
	p.*,
	sp.Invoice as PendingInvoice,
	sp.InvoiceID as PendingInvoiceId,
	sp.InvoiceDate as PendingInvoiceDate,
	coalesce(sp.InvoiceTotal,0) as PendingInvoiceTotal,
	sp.Status as PendingStatus,
	sp.Paid as PendingPaidStatus
from
	BG_ProjectDashboardSummaryScheduled_CG p with (nolock)
	--	left outer join
	--BG_ProjectDashboard_FixedFeeSchedule_CG f with (nolock) on p.ProjectId=f.ProjectId and f.FFSort<>1
	--	left outer join
	--(select * from BG_ProjectDashboard_Invoices_CG where [Status] in ('Paid', 'Sent to Great Plains', 'Partially paid')) si on p.ProjectId=si.ProjectId
		join
	(select * from BG_ProjectDashboard_Invoices_CG where [Status] not in ('Discarded', 'Credited', 'Paid', 'Sent to Great Plains', 'Partially paid', 'Archived', 'Committed')) sp on p.ProjectId=sp.ProjectId
where
	p.ProjectStatus<>'C'
	--and p.Project='Akorn Pharmaceuticals- Network Services Staff Augmentation October 2017 (Stephen Lotho)'--'LACCD-UC District Wide Design and Oversight'
	--and f.FFSort<>1

GO

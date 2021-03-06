USE [Changepoint2018]
GO
/****** Object:  View [dbo].[BG_ProjectDashboardSummaryScheduledV3_CG]    Script Date: 10/11/2019 1:49:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[BG_ProjectDashboardSummaryScheduledV3_CG] as 
with a as (
select
	'Burwood Group Inc.' as Company,
	p.*,
	case when coalesce(f.Billed,0)=1 then 'Yes' else 'No' end as Billed,
	f.DoNotInvoice,
	f.Deliverable,
	f.BillingDate,
	coalesce(f.BillingAmount,0) as BillingAmount,
	f.InvoicedAmount,
	f.TotalHours,
	f.RevPrev,
	f.RevPrevDate,
	f.RevRec,
	f.RevRecDate,
	f.RevAdj,
	f.FFSort,
	f.CreatedOn,
	NULL as SentInvoice,
	NULL as SentInvoiceId,
	NULL as SentInvoiceDate,
	NULL as SentInvoiceTotal,
	NULL as SentStatus,
	NULL as SentPaidStatus,
	NULL as PendingInvoice,
	NULL as PendingInvoiceId,
	NULL as PendingInvoiceDate,
	NULL as PendingInvoiceTotal,
	NULL as PendingStatus,
	NULL as PendingPaidStatus,
	'tshepherd@burwood.com' as TestBurst,
	p.EmailAddress+', tshepherd@burwood.com' as EmailBurst,
	p.EmailAddress+', tshepherd@burwood.com, jcourtney@burwood.com' as EmailBurstTest,
	'jcourtney@burwood.com, tshepherd@burwood.com' as VPEmailBurst


from
	BG_ProjectDashboardSummaryScheduled_CG p with (nolock)
		left outer join
	BG_ProjectDashboard_FixedFeeSchedule_CG f with (nolock) on p.ProjectId=f.ProjectId and f.FFSort<>1
	--	left outer join
	--(select * from BG_ProjectDashboard_Invoices_CG where [Status] in ('Paid', 'Sent to Great Plains', 'Partially paid')) si on p.ProjectId=si.ProjectId
	--	left outer join
	--(select * from BG_ProjectDashboard_Invoices_CG where [Status] not in ('Discarded', 'Credited', 'Paid', 'Sent to Great Plains', 'Partially paid', 'Archived', 'Committed')) sp on p.ProjectId=sp.ProjectId
where
	p.ProjectStatus<>'C'
	and p.Project='LACCD-UC District Wide Design and Oversight'
	--and f.FFSort<>1
),
b as (
select
	'Burwood Group Inc.' as Company,
	p.*,
	NULL as Billed,
	NULL as DoNotInvoice,
	NULL as Deliverable,
	NULL as BillingDate,
	NULL as BillingAmount,
	NULL as InvoicedAmount,
	NULL as TotalHours,
	NULL as RevPrev,
	NULL as RevPrevDate,
	NULL as RevRec,
	NULL as RevRecDate,
	NULL as RevAdj,
	NULL as FFSort,
	NULL as CreatedOn,
	si.Invoice as SentInvoice,
	si.InvoiceID as SentInvoiceId,
	si.InvoiceDate as SentInvoiceDate,
	coalesce(si.InvoiceTotal,0) as SentInvoiceTotal,
	si.Status as SentStatus,
	si.Paid as SentPaidStatus,
	NULL as PendingInvoice,
	NULL as PendingInvoiceId,
	NULL as PendingInvoiceDate,
	NULL as PendingInvoiceTotal,
	NULL as PendingStatus,
	NULL as PendingPaidStatus,
	'tshepherd@burwood.com' as TestBurst,
	p.EmailAddress+', tshepherd@burwood.com' as EmailBurst,
	p.EmailAddress+', tshepherd@burwood.com, jcourtney@burwood.com' as EmailBurstTest,
	'jcourtney@burwood.com, tshepherd@burwood.com' as VPEmailBurst


from
	BG_ProjectDashboardSummaryScheduled_CG p with (nolock)
	--	left outer join
	--BG_ProjectDashboard_FixedFeeSchedule_CG f with (nolock) on p.ProjectId=f.ProjectId and f.FFSort<>1
		join
	(select * from BG_ProjectDashboard_Invoices_CG where [Status] in ('Paid', 'Sent to Great Plains', 'Partially paid')) si on p.ProjectId=si.ProjectId
	--	left outer join
	--(select * from BG_ProjectDashboard_Invoices_CG where [Status] not in ('Discarded', 'Credited', 'Paid', 'Sent to Great Plains', 'Partially paid', 'Archived', 'Committed')) sp on p.ProjectId=sp.ProjectId
where
	p.ProjectStatus<>'C'
	and p.Project='LACCD-UC District Wide Design and Oversight'
	--and f.FFSort<>1
),
c as (
select
	'Burwood Group Inc.' as Company,
	p.*,
	NULL as Billed,
	NULL as DoNotInvoice,
	NULL as Deliverable,
	NULL as BillingDate,
	NULL as BillingAmount,
	NULL as InvoicedAmount,
	NULL as TotalHours,
	NULL as RevPrev,
	NULL as RevPrevDate,
	NULL as RevRec,
	NULL as RevRecDate,
	NULL as RevAdj,
	NULL as FFSort,
	NULL as CreatedOn,
	NULL as SentInvoice,
	NULL as SentInvoiceId,
	NULL as SentInvoiceDate,
	NULL as SentInvoiceTotal,
	NULL as SentStatus,
	NULL as SentPaidStatus,
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
	--	left outer join
	--BG_ProjectDashboard_FixedFeeSchedule_CG f with (nolock) on p.ProjectId=f.ProjectId and f.FFSort<>1
	--	left outer join
	--(select * from BG_ProjectDashboard_Invoices_CG where [Status] in ('Paid', 'Sent to Great Plains', 'Partially paid')) si on p.ProjectId=si.ProjectId
		join
	(select * from BG_ProjectDashboard_Invoices_CG where [Status] not in ('Discarded', 'Credited', 'Paid', 'Sent to Great Plains', 'Partially paid', 'Archived', 'Committed')) sp on p.ProjectId=sp.ProjectId
where
	p.ProjectStatus<>'C'
	and p.Project='LACCD-UC District Wide Design and Oversight'
	--and f.FFSort<>1
),
d as (
select
	*
from
	a

union all

select
	*
from
	b

union all

select
	*
from
	c
)
select
	distinct
	d.*
from
	d
GO

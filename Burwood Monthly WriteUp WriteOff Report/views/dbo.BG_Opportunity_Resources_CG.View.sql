USE [BurwoodGroupInc_MSCRM]
GO
/****** Object:  View [dbo].[BG_Opportunity_Resources_CG]    Script Date: 10/11/2019 3:01:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [dbo].[BG_Opportunity_Resources_CG] AS
select 
a.Name 'Account Name',
ar.Value as AccountRegion,
ao.FullName as AccountOwner,
a.AccountNumber,
a.AccountId,
o.OpportunityId,
o.New_QuoteWerksDocumentNumber,
o.Name 'Opportunity Name',
o.StateCode,
convert(date, o.new_wondate) as WonDate,
sm.Value as PracticeArea,
--.new_quotasplit,
cast(o.Description as nvarchar(200)) as 'Opportunity Description',
o.EstimatedValue 'Opportunity Est Value',
o.New_RevisedCloseDate,
datename (year,o.New_RevisedCloseDate) RevisedClose_Year,
datename (month,o.New_RevisedCloseDate) RevisedClose_Month,
month(o.New_RevisedCloseDate) RevisedClose_Month#,
o.ActualCloseDate,
datename (year,o.ActualCloseDate) ActualClose_Year,
datename (month,o.ActualCloseDate) ActualClose_Month,
month(o.ActualCloseDate) ActualClose_Month#,
own.FullName as Owner,
own.InternalEMailAddress as 'Owner email',
ownman.FullName as OwnerManager,
ownman.InternalEMailAddress as 'Owner Manager email',
src.FullName as Source,
src.InternalEMailAddress 'Source email',
cast(srcman.FullName as varchar(200)) as Source_Manager,
srcman.InternalEMailAddress as 'Source Manager email',
src.New_Commission as 'Source Commission',
ovr.FullName as Overlay,
ovr.InternalEMailAddress 'Overlay email',
cast(ovrman.FullName as varchar(200)) as Overlay_Manager,
ovrman.InternalEMailAddress as 'Overlay Manager email',
ovr2.FullName as Overlay2,
ovr2.InternalEMailAddress 'Overlay2 email',
cast(ovr2man.FullName as varchar(200)) as Overlay2_Manager,
ovr2man.InternalEMailAddress as 'Overlay2 Manager email',
cast(se.FullName as varchar(200)) as Solutions_Expert,
r.ResourceId as SE_ResourceID,
se.InternalEMailAddress as 'SolutionsExpert email',
cast(seman.FullName as varchar(200)) as Solutions_Expert_Manager,
seman.InternalEMailAddress as 'SolutionsExpert Manager email',
case when a.new_SAEffectiveDate<=o.new_wondate then sa.FullName else NULL end as SolutionArchitect,
case when a.new_SAEffectiveDate<=o.new_wondate then sa.InternalEMailAddress else NULL end as SA_email,
datepart(year, o.CreatedOn) as CreatedYear,
ps1.FullName as PreSalesResource,
ps1.SystemUserId as PreSalesSystemUserId,
	coalesce(o.new_presalesidqualify,0) as PreSalesIdQualify,
	coalesce(o.new_presalesscope,0) as PreSalesScope,
	coalesce(o.new_PreSalesSOWBOM,0) as PreSalesSOWBOMBOM,
	coalesce(o.new_presalesclose,0) as PreSalesClose,
	case when (coalesce(o.new_presalesidqualify,0)+coalesce(o.new_presalesscope,0)+coalesce(o.new_PreSalesSOWBOM,0)+coalesce(o.new_presalesclose,0))=4
		 then 1
		 when (coalesce(o.new_presalesidqualify,0)+coalesce(o.new_presalesscope,0)+coalesce(o.new_PreSalesSOWBOM,0)+coalesce(o.new_presalesclose,0))=3
		 then .75
		 when (coalesce(o.new_presalesidqualify,0)+coalesce(o.new_presalesscope,0)+coalesce(o.new_PreSalesSOWBOM,0)+coalesce(o.new_presalesclose,0))=2
		 then .50
		 when (coalesce(o.new_presalesidqualify,0)+coalesce(o.new_presalesscope,0)+coalesce(o.new_PreSalesSOWBOM,0)+coalesce(o.new_presalesclose,0))=1
		 then .25
		 else 0
	end as PreSalesRate,
ps2.FullName as PreSalesResource2,
ps2.SystemUserId as PreSalesSystemUserId2,
	coalesce(o.new_presalesidqualify2,0) as PreSalesIdQualify2,
	coalesce(o.new_presalesscope2,0) as PreSalesScope2,
	coalesce(o.new_PreSalesSOWBOM2,0) as PreSalesSOWBOM2,
	coalesce(o.new_presalesclose2,0) as PreSalesClose2,
	case when (coalesce(o.new_presalesidqualify2,0)+coalesce(o.new_presalesscope2,0)+coalesce(o.new_PreSalesSOWBOM2,0)+coalesce(o.new_presalesclose2,0))=4
		 then 1
		 when (coalesce(o.new_presalesidqualify2,0)+coalesce(o.new_presalesscope2,0)+coalesce(o.new_PreSalesSOWBOM2,0)+coalesce(o.new_presalesclose2,0))=3
		 then .75
		 when (coalesce(o.new_presalesidqualify2,0)+coalesce(o.new_presalesscope2,0)+coalesce(o.new_PreSalesSOWBOM2,0)+coalesce(o.new_presalesclose2,0))=2
		 then .50
		 when (coalesce(o.new_presalesidqualify2,0)+coalesce(o.new_presalesscope2,0)+coalesce(o.new_PreSalesSOWBOM2,0)+coalesce(o.new_presalesclose2,0))=1
		 then .25
		 else 0
	end as PreSalesRate2,
ps3.FullName as PreSalesResource3,
ps3.SystemUserId as PreSalesSystemUserId3,
	coalesce(o.new_presalesidqualify3,0) as PreSalesIdQualify3,
	coalesce(o.new_presalesscope3,0) as PreSalesScope3,
	coalesce(o.new_PreSalesSOWBOM3,0) as PreSalesSOWBOM3,
	coalesce(o.new_presalesclose3,0) as PreSalesClose3,
	case when (coalesce(o.new_presalesidqualify3,0)+coalesce(o.new_presalesscope3,0)+coalesce(o.new_PreSalesSOWBOM3,0)+coalesce(o.new_presalesclose3,0))=4
		 then 1
		 when (coalesce(o.new_presalesidqualify3,0)+coalesce(o.new_presalesscope3,0)+coalesce(o.new_PreSalesSOWBOM3,0)+coalesce(o.new_presalesclose3,0))=3
		 then .75
		 when (coalesce(o.new_presalesidqualify3,0)+coalesce(o.new_presalesscope3,0)+coalesce(o.new_PreSalesSOWBOM3,0)+coalesce(o.new_presalesclose3,0))=2
		 then .50
		 when (coalesce(o.new_presalesidqualify3,0)+coalesce(o.new_presalesscope3,0)+coalesce(o.new_PreSalesSOWBOM3,0)+coalesce(o.new_presalesclose3,0))=1
		 then .25
		 else 0
	end as PreSalesRate3,
own.FullName as SalesResource1,
	coalesce(o.new_salesidqualify,0) as SalesIdQualify1,
	coalesce(o.new_salesscope,0) as SalesScope1,
	coalesce(o.new_salessow,0) as SalesSOW1,
	coalesce(o.new_salesclose,0) as SalesClose1,
	case when (coalesce(o.new_salesidqualify,0)+coalesce(o.new_salesscope,0)+coalesce(o.new_salessow,0)+coalesce(o.new_salesclose,0))=4
		 then 1
		 when (coalesce(o.new_salesidqualify,0)+coalesce(o.new_salesscope,0)+coalesce(o.new_salessow,0)+coalesce(o.new_salesclose,0))=3
		 then .75
		 when (coalesce(o.new_salesidqualify,0)+coalesce(o.new_salesscope,0)+coalesce(o.new_salessow,0)+coalesce(o.new_salesclose,0))=2
		 then .50
		 when (coalesce(o.new_salesidqualify,0)+coalesce(o.new_salesscope,0)+coalesce(o.new_salessow,0)+coalesce(o.new_salesclose,0))=1
		 then .25
		 else 0
	end as SalesRate1,
su2.FullName as SalesResource2,
	coalesce(o.new_salesidqualify2,0) as SalesIdQualify2,
	coalesce(o.new_salesscope2,0) as SalesScope2,
	coalesce(o.new_salessow2,0) as SalesSOW2,
	coalesce(o.new_salesclose2,0) as SalesClose2,
	case when (coalesce(o.new_salesidqualify2,0)+coalesce(o.new_salesscope2,0)+coalesce(o.new_salessow2,0)+coalesce(o.new_salesclose2,0))=4
		 then 1
		 when (coalesce(o.new_salesidqualify2,0)+coalesce(o.new_salesscope2,0)+coalesce(o.new_salessow2,0)+coalesce(o.new_salesclose2,0))=3
		 then .75
		 when (coalesce(o.new_salesidqualify2,0)+coalesce(o.new_salesscope2,0)+coalesce(o.new_salessow2,0)+coalesce(o.new_salesclose2,0))=2
		 then .50
		 when (coalesce(o.new_salesidqualify2,0)+coalesce(o.new_salesscope2,0)+coalesce(o.new_salessow2,0)+coalesce(o.new_salesclose2,0))=1
		 then .25
		 else 0
	end as SalesRate2,
su3.FullName as SalesResource3,
	coalesce(o.new_salesidqualify3,0) as SalesIdQualify3,
	coalesce(o.new_salesscope3,0) as SalesScope3,
	coalesce(o.new_salessow3,0) as SalesSOW3,
	coalesce(o.new_salesclose3,0) as SalesClose3,
	case when (coalesce(o.new_salesidqualify3,0)+coalesce(o.new_salesscope3,0)+coalesce(o.new_salessow3,0)+coalesce(o.new_salesclose3,0))=4
		 then 1
		 when (coalesce(o.new_salesidqualify3,0)+coalesce(o.new_salesscope3,0)+coalesce(o.new_salessow3,0)+coalesce(o.new_salesclose3,0))=3
		 then .75
		 when (coalesce(o.new_salesidqualify3,0)+coalesce(o.new_salesscope3,0)+coalesce(o.new_salessow3,0)+coalesce(o.new_salesclose3,0))=2
		 then .50
		 when (coalesce(o.new_salesidqualify3,0)+coalesce(o.new_salesscope3,0)+coalesce(o.new_salessow3,0)+coalesce(o.new_salesclose3,0))=1
		 then .25
		 else 0
	end as SalesRate3,
su4.FullName as SalesResource4,
	coalesce(o.new_salesidqualify4,0) as SalesIdQualify4,
	coalesce(o.new_salesscope4,0) as SalesScope4,
	coalesce(o.new_salessow4,0) as SalesSOW4,
	coalesce(o.new_salesclose4,0) as SalesClose4,
	case when (coalesce(o.new_salesidqualify4,0)+coalesce(o.new_salesscope4,0)+coalesce(o.new_salessow4,0)+coalesce(o.new_salesclose4,0))=4
		 then 1
		 when (coalesce(o.new_salesidqualify4,0)+coalesce(o.new_salesscope4,0)+coalesce(o.new_salessow4,0)+coalesce(o.new_salesclose4,0))=3
		 then .75
		 when (coalesce(o.new_salesidqualify4,0)+coalesce(o.new_salesscope4,0)+coalesce(o.new_salessow4,0)+coalesce(o.new_salesclose4,0))=2
		 then .50
		 when (coalesce(o.new_salesidqualify4,0)+coalesce(o.new_salesscope4,0)+coalesce(o.new_salessow4,0)+coalesce(o.new_salesclose4,0))=1
		 then .25
		 else 0
	end as SalesRate4
from dbo.Opportunity o with (nolock)
left outer join dbo.AccountBase a with (nolock) on o.parentaccountid=a.AccountId
left outer join dbo.SystemUserBase own with (nolock) on o.OwnerId=own.SystemUserId
left outer join dbo.SystemUserBase ownman with (nolock) on own.ParentSystemUserId=ownman.SystemUserId
left outer join dbo.SystemUserBase src with (nolock) on o.New_BurwoodSourceId=src.SystemUserId
left outer join dbo.SystemUserBase srcman with (nolock) on src.ParentSystemUserId=srcman.SystemUserId
left outer join dbo.SystemUserBase ovr with (nolock) on o.New_SecondarySalesLeadId=ovr.SystemUserId
left outer join dbo.SystemUserBase ovrman with (nolock) on ovr.ParentSystemUserId=ovrman.SystemUserId
left outer join dbo.SystemUserBase ovr2 with (nolock) on o.New_TertiarySalesLeadId=ovr2.SystemUserId
left outer join dbo.SystemUserBase ovr2man with (nolock) on ovr2.ParentSystemUserId=ovr2man.SystemUserId
left outer join dbo.SystemUserBase se with (nolock) on o.new_solutionsexpert=se.SystemUserId
left outer join SystemUserBase sa with (nolock) on a.new_solutionarchitect=sa.SystemUserId
left outer join SystemUserBase ao with (nolock) on a.OwnerId=ao.SystemUserId
left outer join StringMapBase ar with (nolock) on a.new_BillingOffice=ar.AttributeValue and ar.AttributeName='new_billingoffice' and ar.ObjectTypeCode=1
left outer join [chil-sql-01].[Changepoint].[dbo].[Resources] r on se.FullName COLLATE Latin1_General_CI_AI =r.Name
left outer join dbo.SystemUserBase seman with (nolock) on se.ParentSystemUserId=seman.SystemUserId
left outer join dbo.StringMap sm with (nolock) on o.new_PracticeArea=sm.AttributeValue and sm.AttributeName='new_PracticeArea'
left outer join 
	SystemUserBase ps1 with (nolock) on o.new_presalesuser1=ps1.SystemUserId
		left outer join 
	SystemUserBase ps2 with (nolock) on o.new_presalesuser2=ps2.SystemUserId
		left outer join 
	SystemUserBase ps3 with (nolock) on o.new_presalesuser3=ps3.SystemUserId
		left outer join 
	SystemUserBase su2 with (nolock) on o.new_salesuser2=su2.SystemUserId
		left outer join 
	SystemUserBase su3 with (nolock) on o.new_salesuser3=su3.SystemUserId
		left outer join 
	SystemUserBase su4 with (nolock) on o.new_salesuser4=su4.SystemUserId
where o.StateCode=1
--where se.IsDisabled=0 and own.IsDisabled=0























GO

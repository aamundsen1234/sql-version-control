USE [Changepoint]
GO
/****** Object:  StoredProcedure [dbo].[BG_spSales_CG]    Script Date: 10/11/2019 3:24:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[BG_spSales_CG] AS

BEGIN
		
truncate TABLE BG_AE_Manager_ResourceId_Table_CG
truncate Table BG_AccountExecutives_Table_CG

	insert into BG_AE_Manager_ResourceId_Table_CG select * from BG_AE_Manager_ResourceId_CG
	insert into BG_AccountExecutives_Table_CG select * from BG_AccountExecutives_CG 


END


--select * into BG_AE_Manager_ResourceId_Table_CG from BG_AE_Manager_ResourceId_CG
GO

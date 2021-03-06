USE [Changepoint]
GO
/****** Object:  StoredProcedure [dbo].[LockRecord]    Script Date: 10/10/2019 2:41:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[LockRecord] (@RecordType varchar(3),
			      @RecordID uniqueidentifier,
			      @Description nvarchar(255), 
			      @CreatedBy uniqueidentifier,
				  @LockedFrom VARCHAR(3) = NULL)
 AS
set nocount on
declare @CB uniqueidentifier,
		@CName nvarchar(255), 
		@TEL bit,
		@LFrom VARCHAR(3)
set @tel = 0
SELECT @CB = CreatedBy,@LFrom=LockedFrom from RecordLock  WITH (NOLOCK)  where RecordId = @RecordID and  RecordType = @RecordType
if @CB IS NULL AND @RecordType = 'ENI'
BEGIN
	
	SELECT @CB = CreatedBy from RecordLock  WITH (NOLOCK)  where RecordId = @RecordID and RecordType = 'TEL'
	set @tel = 1
END
IF @CB is not NUll
BEGIN
  IF @CB = @Createdby
  BEGIN
	
	IF @RecordType = 'ENI' and ISNULL(@LFrom,'') = '' and ISNULL(@LFrom,'') <> ISNULL(@LockedFrom, '')
	BEGIN
		select @CName = Name from Resources where resourceid = @CB
		if @CName is null set @CName = 'Nobody'
	END
    ELSE IF ISNULL(@LFrom,'') IN ('RMV', 'SC')
	  BEGIN
		select @CName = Name from Resources where resourceid = @CB
		if @CName is null set @CName = 'Nobody'
	  END
    ELSE
	  BEGIN
		IF @tel = 0
		BEGIN
			set @CName = 'Nobody'
			IF @LockedFrom='TSK' AND @LFrom IS NULL
				Update RecordLock set CreatedOn = getdate(),LockedFrom='TSK' where RecordId = @RecordID and	RecordType = @RecordType
			ELSE
				Update RecordLock set CreatedOn = getdate() where RecordId = @RecordID and	RecordType = @RecordType
		END
		ELSE
		BEGIN
			set @CName = 'Updating Request Time Records'
		END
	  END
  END
  ELSE
  BEGIN
	select @CName = Name from Resources where resourceid = @CB
	if @CName is null set @CName = 'Nobody'
  END 
  select @CB, @Cname
END
ELSE
BEGIN
  IF LEN(ISNULL(@LockedFrom, '')) > 0
	  Insert into RecordLock (RecordId, RecordType, CreatedBy, CreatedOn, Description,LockedFrom)
		   values (@RecordID, @RecordType, @CreatedBy, GetDate(), @Description,@LockedFrom)
  ELSE
	  Insert into RecordLock (RecordId, RecordType, CreatedBy, CreatedOn, Description)
		   values (@RecordID, @RecordType, @CreatedBy, GetDate(), @Description)
  IF @@Error = 0
  BEGIN
    Select @CreatedBy, 'Nobody'
  END
  ELSE 
  BEGIN
    Select rl.CreatedBy, r.Name from RecordLock rl  WITH (NOLOCK)  join Resources r  WITH (NOLOCK)  on 
		rl.CreatedBy = R.Resourceid where rl.RecordId = @RecordID and
		rl.RecordType = @RecordType
  END
END
SET NOCOUNT OFF

GO

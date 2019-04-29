use tempdb
go
--patch for implementing soft deletes

--01. modifications to dbo.Swimmer table
if not exists(
    select 1 
    from INFORMATION_SCHEMA.COLUMNS 
    where TABLE_SCHEMA = 'dbo' and TABLE_NAME = 'Swimmer' and COLUMN_NAME = 'IsDeleted'
    )
begin    
	alter table dbo.Swimmer add IsDeleted bit not null constraint DF_Swimmer_IsDeleted default (0) 
end
go
    
--02. new version of v_Swimmer view (to be able to handle soft deletes)
if OBJECT_ID('dbo.v_Swimmers') is not null
   drop view dbo.v_Swimmers
go

create view dbo.v_Swimmers
as  
    select s.SwimmerID, s.FirstName, s.LastName, s.YearOfBirth, s.Gender, 
            sc.[Name] Club, sc.City, c.[Name] Category
    from dbo.Swimmer s
    left join dbo.SwimmingClub sc on s.SwimmingClubID = sc.SwimmingClubID
    left join dbo.Category c      on s.CategoryID     = c.CategoryID
	where IsDeleted = 0
go


--03. trigger to replace hard-delete with its soft version
if OBJECT_ID('dbo.t_Swimmer_Delete') is not null
   drop trigger dbo.t_Swimmer_Delete
go

create trigger t_Swimmer_Delete
on dbo.Swimmer
instead of delete
as
begin
	set nocount on

	update s
	set IsDeleted = 1
	from dbo.Swimmer s
	inner join deleted d on s.SwimmerID = d.SwimmerID
	where s.IsDeleted = 0
end
go

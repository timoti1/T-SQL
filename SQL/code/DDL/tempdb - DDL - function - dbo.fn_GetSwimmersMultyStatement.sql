use tempdb
go

if OBJECT_ID('dbo.fn_GetSwimmersMultyStatement') is not null
   drop function dbo.fn_GetSwimmersMultyStatement
go

-------------------------------------------------------------------------------------------
-- function returns all swimmers for given club (@ClubID)
-- created by:   Timofey Gavrilenko
-- created date: 4/26/2019
-- sample call:  
-- select * from dbo.fn_GetSwimmersMultyStatement(N'ж', 2006)
-----------------------------------------------------------------------------------

create function dbo.fn_GetSwimmersMultyStatement(
    @Gender nchar(1) = null,
    @YearOfBirth int = null
) returns @Swimmers table
(
    SwimmerID       int             not null,
    FirstName       nvarchar(20)    not null,
    LastName        nvarchar(30)    not null,
    YearOfBirth     smallint        not null,
    Gender          nchar(1)        not null,
    Club            nvarchar(100), 
	City            nvarchar(30), 
    Category        nvarchar(20)    
)
as  
begin
  insert into @Swimmers (SwimmerID, FirstName, LastName, YearOfBirth, Gender, Club, City, Category)
      select SwimmerID, FirstName, LastName, YearOfBirth, Gender, sc.[Name] Club, sc.City, c.[Name] Category
      from dbo.Swimmer s
      left join dbo.SwimmingClub sc on s.SwimmingClubID = sc.SwimmingClubID
      left join dbo.Category c      on s.CategoryID     = c.CategoryID
      where (Gender = @Gender            or @Gender is null) and
            (YearOfBirth = @YearOfBirth  or @YearOfBirth is null)

  return
end
go
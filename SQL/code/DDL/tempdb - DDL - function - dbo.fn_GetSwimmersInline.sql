use tempdb
go

if OBJECT_ID('dbo.fn_GetSwimmersInline') is not null
   drop function dbo.fn_GetSwimmersInline
go

-------------------------------------------------------------------------------------------
-- function returns all swimmers for given club (@ClubID)
-- created by:   Timofey Gavrilenko
-- created date: 4/26/2019
-- sample call:  
-- select * from dbo.fn_GetSwimmersInline(N'ж', 2006)
-----------------------------------------------------------------------------------

create function dbo.fn_GetSwimmersInline(
    @Gender nchar(1) = null,
    @YearOfBirth int = null
) returns table
as  
  return (
      select s.SwimmerID, s.FirstName, s.LastName, s.YearOfBirth, s.Gender, 
             sc.[Name] Club, sc.City, c.[Name] Category
      from dbo.Swimmer s
      left join dbo.SwimmingClub sc on s.SwimmingClubID = sc.SwimmingClubID
      left join dbo.Category c      on s.CategoryID     = c.CategoryID
      where (Gender = @Gender            or @Gender is null) and
            (YearOfBirth = @YearOfBirth  or @YearOfBirth is null)
 )
go
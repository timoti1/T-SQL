use tempdb
go

if OBJECT_ID('dbo.v_Swimmers') is not null
   drop view dbo.v_Swimmers
go

-----------------------------------------------------------------------------------
-- view returns all swimmers 
-- created by:   Timofey Gavrilenko
-- created date: 4/29/2019
-- sample call:  select * from dbo.v_Swimmers
-----------------------------------------------------------------------------------

create view dbo.v_Swimmers
as  
    select s.SwimmerID, s.FirstName, s.LastName, s.YearOfBirth, s.Gender, 
            sc.[Name] Club, sc.City, c.[Name] Category
    from dbo.Swimmer s
    left join dbo.SwimmingClub sc on s.SwimmingClubID = sc.SwimmingClubID
    left join dbo.Category c      on s.CategoryID     = c.CategoryID
go
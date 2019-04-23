use tempdb
go

if OBJECT_ID('dbo.usp_GetSwimmersList', 'P') is not null
   drop procedure dbo.usp_GetSwimmersList
go

---------------------------------------------------------------------------------------
-- procedure returns list of Swimmers from given clubs
-- created by:   Timofey Gavrilenko
-- created date: 4/22/2019
-- sample call:  
-- exec dbo.usp_GetSwimmersList @parameters = N'[{"Club": "Трактор", "City": "Минск"}]'
---------------------------------------------------------------------------------------

create procedure dbo.usp_GetSwimmersList
    @parameters nvarchar(1000) = null
as    
begin
    select  s.FirstName,
            s.LastName,
            s.YearOfBirth,
            ISNULL(sc.[Name] + ' ' + sc.City, '-') Club,
            ISNULL(c.[Name], '-') Category
    from dbo.Swimmer s
    left join dbo.SwimmingClub sc   on s.SwimmingClubID = sc.SwimmingClubID
    left join dbo.Category c        on s.CategoryID = c.CategoryID
    outer apply (
        select  [Name], 
				City
        from openjson(@parameters) 
            with (
                     [Name] nvarchar(100) '$.Club',
                     City nvarchar(100) '$.City'
                 ) j
        where (j.[Name] = sc.[Name] or j.[Name] is null) and
              (j.City = sc.City or j.City is null)
    ) f
    where (f.City is not null or f.[Name] is not null) or @parameters is null
end
go
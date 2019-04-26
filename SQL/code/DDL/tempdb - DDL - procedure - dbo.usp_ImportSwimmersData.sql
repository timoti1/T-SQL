use tempdb
go

if OBJECT_ID('dbo.usp_ImportSwimmersData', 'P') is not null
   drop procedure dbo.usp_ImportSwimmersData
go

---------------------------------------------------------------------------------------
-- procedure imports data from incoming JSON-parameter into a number of relation tables
-- created by:   Timofey Gavrilenko
-- created date: 4/26/2019
-- sample call:  
-- exec dbo.usp_ImportSwimmersData @parameters = 
--N'
--[
--    {
--        "FirstName": "Илья",
--        "LastName": "Гавриленко",
--        "YearOfBirth": 2006,
--        "Gender": "м",
--        "Club": {
--            "Name": "ГЦОР Трактор",
--            "City": "Минск"
--        },
--        "Category": "II",
--        "Coach": [
--            {"FirstName": "Алла", "LastName": "Усенок"},
--            {"FirstName": "Виталий", "LastName": "Барташевич"}
--        ]
--    } 
--]'
---------------------------------------------------------------------------------------

create procedure dbo.usp_ImportSwimmersData
    @parameters nvarchar(max) = null
as
begin
    set nocount on

    --if @parameters is null
    --    return
   
    create table #Swimmer
    (
        id              int             not null    identity    primary key,
        FirstName       nvarchar(20)    not null,
        LastName        nvarchar(30)    not null,
        YearOfBirth     smallint        not null,
        Gender          nchar(1)        not null,
        Category        nvarchar(20),
        Club            nvarchar(max), 
        Coach           nvarchar(max)
    ) 

    create table #Club
    (
        id              int             not null    identity    primary key,
        [Name]          nvarchar(100)   not null,
        City            nvarchar(30)    not null,
        [Address]       nvarchar(200),
        Phone           nvarchar(15),
        YearEstablished smallint,
    ) 

    create table #Coach 
    (
        id              int             not null    identity    primary key,
        FirstName       nvarchar(20)    not null,
        LastName        nvarchar(30)    not null,
        DateOfBirth     date,
        Category        nvarchar(20) 
    )

    --get list of swimmers
    insert into  #Swimmer(FirstName, LastName, YearOfBirth, Gender, Category, Club, Coach)
    select *
    from openjson(@parameters) 
        with 
        (
            FirstName       nvarchar(20)    N'$.FirstName',
            LastName        nvarchar(30)    N'$.LastName',
            YearOfBirth     smallint        N'$.YearOfBirth',
            Gender          nchar(1)        N'$.Gender',
            Category        nvarchar(20)    N'$.Category',
            Club            nvarchar(max)   N'$.Club'          as json, 
            Coach           nvarchar(max)   N'$.Coach'         as json
        )  js  

    --get list of clubs
    insert into  #Club([Name], City, [Address], Phone, YearEstablished)
    select distinct jc.[Name], jc.City, jc.[Address], jc.Phone, jc.YearEstablished
    from #Swimmer s
    cross apply openjson(s.Club) 
        with
        (
            [Name]          nvarchar(100)   N'$.Name',
            City            nvarchar(30)    N'$.City',
            [Address]       nvarchar(200)   N'$.Address',
            Phone           nvarchar(15)    N'$.Phone',
            YearEstablished smallint        N'$.YearEstablished'
        )  jc    

    --get list of coaches
    insert into  #Coach(FirstName, LastName, DateOfBirth, Category)
    select distinct jc.FirstName, jc.LastName, jc.DateOfBirth, jc.Category
    from #Swimmer s
    cross apply openjson(s.Coach) 
        with
        (
            FirstName       nvarchar(20)    N'$.FirstName',
            LastName        nvarchar(30)    N'$.LastName',
            DateOfBirth     date            N'$.DateOfBirth',
            Category        nvarchar(20)    N'$.Category'
        )  jc 

     --let's first insert what what is easy (data without foreign keys)

    --insert new categories
    insert into dbo.Category ([Name])
    select jc.[Name]
    from
    (
        select Category as [Name] from #Swimmer
        union 
        select Category from #Coach
    ) jc
    left join dbo.Category c           on jc.[Name] = c.[Name]
    where c.CategoryID is null and 
          jc.[Name] is not null

    
    --below we'll use natural/alternative keys from JSON data to get ids (foreign keys)

    --insert new clubs
    insert into dbo.SwimmingClub ([Name], City, [Address], Phone, YearEstablished)
    select jsc.[Name], jsc.City, jsc.[Address], jsc.Phone, jsc.YearEstablished
    from
    (
        select distinct [Name], City, [Address], Phone, YearEstablished from #Club
    ) jsc
    left join dbo.SwimmingClub sc      on jsc.[Name] = sc.[Name] and 
                                          jsc.City   = sc.City
    where sc.SwimmingClubID is null

    --insert new coaches
    insert into dbo.Coach (FirstName, LastName, DateOfBirth, CategoryID)
    select jc.FirstName, jc.LastName, jc.DateOfBirth, jc.CategoryID 
    from
    (
        --dbo.Coach table has dependency on dbo.Category (not required however)
        select distinct FirstName, LastName, DateOfBirth, c.CategoryID 
        from #Coach
        left join dbo.Category c on #Coach.Category = c.[Name]
    ) jc
    left join dbo.Coach c              on jc.FirstName = c.FirstName and 
                                          jc.LastName  = c.LastName
    where c.CoachID is null

    --insert new swimmers
    insert into dbo.Swimmer (FirstName, LastName, YearOfBirth, Gender, SwimmingClubID, CategoryID)
    select js.FirstName, js.LastName, js.YearOfBirth, js.Gender, js.SwimmingClubID, js.CategoryID
    from
    (
        --dbo.Swimmer table has dependency on dbo.Club (not required)
        select distinct FirstName, LastName, YearOfBirth, Gender, sc.SwimmingClubID, c.CategoryID
        from #Swimmer s
        left join dbo.Category c       on s.Category = c.[Name]
        outer apply openjson(s.Club) 
            with
            (
                [Name]          nvarchar(100)   N'$.Name',
                City            nvarchar(30)    N'$.City'
            )  jsc    
        left join dbo.SwimmingClub sc  on jsc.[Name] = sc.[Name] and jsc.City = sc.City
    ) js
    left join dbo.Swimmer s            on js.FirstName  = s.FirstName and 
                                          js.LastName   = s.LastName and 
                                          js.YearOfBirth = s.YearOfBirth and 
                                          js.Gender     = s.Gender
    where s.SwimmerID is null

    --insert new relationships between swimmers and coaches
    insert into dbo.SwimmerCoach (SwimmerID, CoachID)
    select s.SwimmerID, c.CoachID
    from #Swimmer js
    join dbo.Swimmer s                 on js.FirstName  = s.FirstName and 
                                          js.LastName    = s.LastName and 
                                          js.YearOfBirth = s.YearOfBirth and 
                                          js.Gender      = s.Gender
    
    cross apply openjson(js.Coach) 
        with
        (
            FirstName       nvarchar(20)    N'$.FirstName',
            LastName        nvarchar(30)    N'$.LastName'
        )  jc 
    join dbo.Coach c                   on jc.FirstName  = c.FirstName and
                                          jc.LastName   = c.LastName

    left join dbo.SwimmerCoach sc      on s.SwimmerID   = sc.SwimmerID and
                                          c.CoachID     = sc.CoachID
    where sc.SwimmerID is null and sc.CoachID is null
end
go    
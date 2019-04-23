use tempdb
go

if OBJECT_ID('dbo.Swimmer', 'U') is not null
   drop table dbo.Swimmer
go

create table dbo.Swimmer
(
    SwimmerID       int             not null    identity,
    FirstName       nvarchar(20)    not null,
    LastName        nvarchar(30)    not null,
    YearOfBirth     smallint        not null,
    Gender          nchar(1)        not null,
    SwimmingClubID  int, 
    CategoryId      tinyint,
    ModifiedDate    datetime        not null,

    constraint PK_Swimmer primary key (
        SwimmerID
    )
)
go
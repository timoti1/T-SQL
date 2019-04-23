use tempdb
go

if OBJECT_ID('dbo.Coach', 'U') is not null
   drop table dbo.Coach
go

create table dbo.Coach 
(
    CoachID         int             not null    identity,
    FirstName       varchar(20)     not null,
    LastName        varchar(30)     not null,
    DateOfBirth     date,
    CategoryID      tinyint,
    ModifiedDate    datetime        not null,

	constraint PK_Coach primary key (
        CoachID
    )
)
go
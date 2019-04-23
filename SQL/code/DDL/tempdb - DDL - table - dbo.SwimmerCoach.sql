use tempdb
go

if OBJECT_ID('dbo.SwimmerCoach', 'U') is not null
   drop table dbo.SwimmerCoach
go

create table dbo.SwimmerCoach 
(
    SwimmerID       int             not null,
    CoachID         int             not null, 
    ModifiedDate    datetime        not null
)
go
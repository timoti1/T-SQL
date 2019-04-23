use tempdb
go

if OBJECT_ID('dbo.SwimmingClub', 'U') is not null
   drop table dbo.SwimmingClub
go

--выполнен data-profiling (изменены типы полей). код отформатирован и отрефакторен
create table dbo.SwimmingClub 
(
	SwimmingClubID  int             not null	identity,
	[Name]          nvarchar(100)   not null,
	City            nvarchar(30)    not null,
	[Address]       nvarchar(200),
	Phone           nvarchar(15),
	YearEstablished smallint,
	ModifiedDate    datetime        not null,

	constraint PK_SwimmingClub primary key (
        SwimmingClubID
    )
)
go
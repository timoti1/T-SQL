--выбираем активную БД
use tempdb
go

--DF_SwimmerCoach_ModifiedDate
if object_id('DF_SwimmerCoach_ModifiedDate', 'D') is not null
   alter table dbo.SwimmerCoach drop constraint DF_SwimmerCoach_ModifiedDate
go

alter table dbo.SwimmerCoach add constraint DF_SwimmerCoach_ModifiedDate default GETDATE() for ModifiedDate
go

--FK_SwimmerCoach_Swimmer
if exists(select 1 from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_NAME = 'FK_SwimmerCoach_Swimmer')
   alter table dbo.SwimmerCoach drop constraint FK_SwimmerCoach_Swimmer
go

alter table dbo.SwimmerCoach 
    add constraint FK_SwimmerCoach_Swimmer foreign key (SwimmerID) references dbo.Swimmer(SwimmerID)
go

--FK_Swimmer_SwimmingClub
if exists(select 1 from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_NAME = 'FK_SwimmerCoach_Coach')
   alter table dbo.SwimmerCoach drop constraint FK_SwimmerCoach_Coach
go

alter table dbo.SwimmerCoach 
    add constraint FK_SwimmerCoach_Coach foreign key (CoachID) references dbo.Coach(CoachID)
go
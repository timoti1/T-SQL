--выбираем активную БД
use tempdb
go

--удаляем констрейнт если он был создан ранее

--DF_SwimmerCoach_ModifiedDate
if object_id('DF_SwimmerCoach_ModifiedDate', 'D') is not null
   alter table dbo.SwimmerCoach drop constraint DF_SwimmerCoach_ModifiedDate
go

alter table dbo.SwimmerCoach add constraint DF_SwimmerCoach_ModifiedDate default GETDATE() for ModifiedDate
go


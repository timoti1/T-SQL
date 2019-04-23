--выбираем активную БД
use tempdb
go

--удаляем констрейнт если он был создан ранее
--AK_Swimmer_FirstName_LastName_YearOfBirth
if exists(select 1 from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_NAME = 'AK_Swimmer_FirstName_LastName_YearOfBirth')
   alter table dbo.Swimmer drop constraint AK_Swimmer_FirstName_LastName_YearOfBirth
go

alter table dbo.Swimmer add constraint AK_Swimmer_FirstName_LastName_YearOfBirth unique 
(
    FirstName,
    LastName,
    YearOfBirth
)
go

--DF_Swimmer_ModifiedDate
if object_id('DF_Swimmer_ModifiedDate', 'D') is not null
   alter table dbo.Swimmer drop constraint DF_Swimmer_ModifiedDate
go

alter table dbo.Swimmer add constraint DF_Swimmer_ModifiedDate default GETDATE() for ModifiedDate
go

--FK_Swimmer_Category
if exists(select 1 from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_NAME = 'FK_Swimmer_Category')
   alter table dbo.Swimmer drop constraint FK_Swimmer_Category
go

alter table dbo.Swimmer 
    add constraint FK_Swimmer_Category foreign key (CategoryID) references dbo.Category (CategoryID)
go

--FK_Swimmer_SwimmingClub
if exists(select 1 from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_NAME = 'FK_Swimmer_SwimmingClub')
   alter table dbo.Swimmer drop constraint FK_Swimmer_SwimmingClub
go

alter table dbo.Swimmer 
    add constraint FK_Swimmer_SwimmingClub foreign key (SwimmingClubID) references dbo.SwimmingClub (SwimmingClubID)
go
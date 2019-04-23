--выбираем активную БД
use tempdb
go

--удаляем констрейнт если он был создан ранее
--AK_Coach_FirstName_LastName_DateOfBirth
if exists(select 1 from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_NAME = 'AK_Coach_FirstName_LastName_DateOfBirth')
   alter table dbo.Coach drop constraint AK_Coach_FirstName_LastName_DateOfBirth
go

alter table dbo.Coach add constraint AK_Coach_FirstName_LastName_DateOfBirth unique 
(
    FirstName,
    LastName,
    DateOfBirth
)
go

--DF_Coach_ModifiedDate
if object_id('DF_Coach_ModifiedDate', 'D') is not null
   alter table dbo.Coach drop constraint DF_Coach_ModifiedDate
go

alter table dbo.Coach add constraint DF_Coach_ModifiedDate default GETDATE() for ModifiedDate
go

--FK_Coach_Category
if exists(select 1 from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_NAME = 'FK_Coach_Category')
   alter table dbo.Coach drop constraint FK_Coach_Category
go

alter table dbo.Coach 
    add constraint FK_Coach_Category foreign key (CategoryID) references dbo.Category (CategoryID)
go

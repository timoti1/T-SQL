--выбираем активную БД
use tempdb
go

--удаляем констрейнт если он был создан ранее
--AK_Category_Name
if exists(select 1 from INFORMATION_SCHEMA.TABLE_CONSTRAINTS where CONSTRAINT_NAME = 'AK_Category_Name')
   alter table dbo.Category drop constraint AK_Category_Name
go

alter table dbo.Category add constraint AK_Category_Name unique 
(
    [Name]
)
go

--DF_Category_ModifiedDate
if object_id('DF_Category_ModifiedDate', 'D') is not null
   alter table dbo.Category drop constraint DF_Category_ModifiedDate
go

alter table dbo.Category add constraint DF_Category_ModifiedDate default GETDATE() for ModifiedDate
go
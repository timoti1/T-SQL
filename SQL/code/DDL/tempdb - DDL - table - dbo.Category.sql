--выбираем активную БД
use tempdb
go

--создаем объект, предварительно проверяя был ли он создан ранее
--стараемся использовать "классический" подход

--drop table if exists #Category
if OBJECT_ID('dbo.Category', 'U') is not null
   drop table dbo.Category
go

create table dbo.Category 
(
    CategoryID      tinyint         not null    identity,
    [Name]          nvarchar(20)    not null, 
    ModifiedDate    datetime        not null,

    constraint PK_Category primary key (
        CategoryID
    )
)
go
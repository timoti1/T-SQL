use tempdb
go

if not exists(select 1 from INFORMATION_SCHEMA.SCHEMATA where [SCHEMA_NAME] = 'admin')
    exec('create schema [admin]')
go

if object_id('[admin].usp_ClearTables', 'P') is not null
   drop procedure [admin].usp_ClearTables
go

---------------------------------------------------------------------------------------
-- procedure removes data from given list of tables (input json-parameter)
-- created by:   Timofey Gavrilenko
-- created date: 4/23/2019
-- sample call:  
-- exec [admin].usp_ClearTables N'["dbo.SwimmerCoach", "dbo.SwimmingClub", "dbo.Swimmer", "dbo.Category", "dbo.Coach"]'
---------------------------------------------------------------------------------------

create procedure [admin].usp_ClearTables
    @list  nvarchar(max) = null,
    @debug tinyint       = 1 
as    
begin
    set nocount on

    if @list is null
        return

   	--table to store sql scripts
	create table #scripts
	(
		id           int             not null    identity    primary key,
		[object_id]  int             not null,
		table_name   sysname         not null,
		add_sql      nvarchar(max),
		drop_sql     nvarchar(max),
		truncate_sql nvarchar(max)
	)

    --get table list from input json
	create table #tables 
    (
        id          int             not null    identity    primary key,
        table_name  sysname         not null,
		[object_id] int     
    )    

    insert into #tables(table_name, [object_id])
    select  [value], 
	        object_id([value])
    from openjson(@list) 

	--get drop-scripts
	insert into #scripts ([object_id], table_name, drop_sql)
	select t.[object_id],
	       t.[name], 
		   formatmessage(N'alter table %s.%s drop constraint %s', quotename(s.[name]), quotename(t.[name]), quotename(fk.[name])) 
	from sys.foreign_keys  fk
	join sys.tables  t           on fk.[parent_object_id] = t.[object_id]
	join sys.schemas s           on s.[schema_id]         = t.[schema_id]
	join #tables tl              on tl.[object_id]        = t.[object_id]
	order by t.[object_id]

	--get add-scripts
	update s
	   set add_sql      = q.add_sql,
	       truncate_sql = case
						    when exists(select 1 from #scripts where id > s.id and table_name = s.table_name)
						    then null
							else formatmessage(N'truncate table %s.%s', quotename(q.[schema_name]), quotename(q.table_name))
                          end
    from #scripts s
	join (
		   select 
			   t2.[object_id],
			   s2.[name] [schema_name],
			   t2.[name] table_name,
			   formatmessage(N'alter table %s.%s add constraint %s foreign key (%s) references %s.%s (%s)',
				  --alter table 
				  quotename(s2.[name]), 
				  quotename(t2.[name]),
				  --add constraint
				  quotename(fk.[name]),
				  --foreign key		
				  stuff(
						 (
							 select ',' + quotename(c.[name])
							 from sys.columns as c 
							 join sys.foreign_key_columns fkc on fkc.parent_column_id = c.column_id	and fkc.parent_object_id = c.[object_id]
							 where fkc.constraint_object_id = fk.[object_id]
							 order by fkc.constraint_column_id 
							 for xml path(N''), type
						 ).value(N'.[1]', N'nvarchar(max)'), 
						 1, 1, N''
					   ),
				  --references
				  quotename(s1.[name]),
				  quotename(t1.[name]),
	          
				  stuff(
						 (
							 select ',' + quotename(c.[name])
							 from sys.columns as c 
							 join sys.foreign_key_columns fkc on fkc.referenced_column_id = c.column_id	and fkc.referenced_object_id = c.[object_id]
							 where fkc.constraint_object_id = fk.[object_id]
							 order by fkc.constraint_column_id 
							 for xml path(N''), type
						  ).value(N'.[1]', N'nvarchar(max)'), 
						  1, 1, N''
					   ) 
		       ) add_sql
		from sys.foreign_keys fk
		join sys.tables  t1 	     on fk.referenced_object_id = t1.[object_id]
		join sys.schemas s1          on t1.[schema_id]          = s1.[schema_id]
		join sys.tables  t2          on fk.parent_object_id     = t2.[object_id]
		join sys.schemas s2          on t2.[schema_id]          = s2.[schema_id]
	) q on q.[object_id] = s.[object_id]	


	--get list of sql scripts to execute in right order
	create table #scripts_in_order
	(
	    id     int			 not null identity	primary key,
		script nvarchar(max) not null
	)

	insert into #scripts_in_order(script)
	select N'-- pass @debug = 0 for executing scripts'
	union all
	select N'-- drop all fk constraints...'
	union all
	select drop_sql from #scripts
	union all
	select N'-- truncate all tables...'
	union all
	select truncate_sql from #scripts where truncate_sql is not null
	union all
	select formatmessage(N'truncate table %s', t.table_name) 
	from #tables t
	left join #scripts s on t.[object_id] = s.[object_id]
	where s.[object_id] is null
	union all
	select N'-- recreate fk constraints...'
	union all
	select add_sql from #scripts
	union all
	select N'-- done!'	

	--run drop constraint, truncate table, add constraint scripts
	declare @id           int = 1,
	        @maxid        int = @@rowcount,
			@sql          nvarchar(max)

	begin try
		begin tran
			while @id <= @maxid
			begin
				select @sql = script
				from #scripts_in_order
				where id = @id

				if @debug <> 0
					print @sql
				else
					execute(@sql)

				set @id +=1
			end --while

		commit
	end try
	begin catch
		print 'Oops. There were issues when executing [admin].[usp_ClearTables]'
		rollback
	end catch	 
end
go
use tempdb
go

if OBJECT_ID('dbo.t_Swimmer_Notification') is not null
   drop view dbo.t_Swimmer_Notification
go

-----------------------------------------------------------------------------------
-- trigger sends email-notifications whenever dbo.Swimmer table gets updated
-- created by:   Timofey Gavrilenko
-- created date: 4/29/2019
-----------------------------------------------------------------------------------
create trigger t_Swimmer_Notification
on dbo.Swimmer
after insert, update, delete
as  
begin
   declare @_records_affected varchar(max)
   if exists(select 1 from deleted)
        select top 3 @_records_affected += LastName + ' ' + FirstName + ', '
        from deleted
   else
        select top 3 @_records_affected += LastName + ' ' + FirstName
        from inserted
   set @_records_affected += '...'

   declare @_body varchar(max)
   set @_body = formatmessage('There are changes to dbo.Swimmer table [%s]. Made by: [%s]', @_records_affected, user_name())

   exec msdb.dbo.sp_send_dbmail  
        @profile_name = 'system',  
        @recipients = 'manager@swimmer.com',  
        @body = @_body,  
        @subject = 'notification';  
end        
go
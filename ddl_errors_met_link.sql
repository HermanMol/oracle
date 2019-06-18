select owner
      ,name
      ,type
      ,sequence
      ,line
      ,position
      ,text
      ,attribute
      ,message_number
      ,'SQLDEV:LINK:'
     ||owner
     ||':'||type
     ||':'||name
      ||':'||line
      ||':'||position
      ||':'||'DoubleClick'
     ||':oracle.dbtools.raptor.controls.grid.DefaultDrillLink' Link2Object
from all_errors 
where owner in ('CRM', 'ALF', 'SRG', 'KCS')
and (instr(lower(name),:ObjectName) > 0 or :ObjectName is NULL)
order by owner, name, sequence

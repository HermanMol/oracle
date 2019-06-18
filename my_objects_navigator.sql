-- reports athe objects you need, with a link
-- parts of the object names in case-insensitive semicolon separated
select 'SQLDEV:LINK:'
     ||ao.owner
     ||':'||ao.object_type
     ||':'||ao.object_name
     ||':oracle.dbtools.raptor.controls.grid.DefaultDrillLink' FoundObjects
      ,ao.object_type
      ,ao.owner
      ,ao.object_name
     ,case status
        when 'VALID' then ao.status
        else '<html><body style="background-color: yellow;">'
        || ao.status
        || '</body></html>'
        end as status
      ,CREATED
      ,LAST_DDL_TIME
      ,TIMESTAMP        
from all_objects ao
      ,table(apex_string.split(lower(:searchfor),';')) zoekie
where ao.owner in ('SRG', 'ALF', 'KCS', 'CRM')
and instr(lower(object_name),lower(column_value)) > 0
order by ao.status
    ,decode(ao.object_type
            ,'SEQUENCE'      ,99
            ,'SCHEDULE'      ,99
            ,'PROCEDURE'     ,14
            ,'PACKAGE'       ,10
            ,'PACKAGE BODY'  ,11
            ,'TYPE BODY'     ,99
            ,'TRIGGER'       ,12
            ,'TABLE'         ,01
            ,'INDEX'         ,99
            ,'VIEW'          ,02
            ,'SYNONYM'       ,99
            ,'FUNCTION'      ,13
            ,'JAVA CLASS'    ,99
            ,'JAVA SOURCE'   ,99
            ,'TYPE'          ,99
            ,'JOB'           ,99
            )
      ,ao.object_type
    ,ao.object_name
    ,ao.owner

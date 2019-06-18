prompt *I: Start of file exp_dbobj_ddl.sql
-- Export DDL of Oracle database objects into separate directories and files per DB\schema\type
-- Build using: Oracle SQLcl 19.1 on Oracle 11 db
--
-- Syntax: exp_dbobj_ddl.sql <object_owner> <object_type_code>
-- - Arguments are case insensitive.
-- - Current valid object_type_codes:
--   - pks = Package specification
--   - pkb = Package body
--   - pkg = Package specification and body in one file
--   - fnc = Stand alone function
--   - prc = Stand alone procedure
--   - trg = Trigger
--   - svw = View ("simple view" as opposed to mvw = Materialized View) (including triggers)
--   - idx = Index
--   - seq = Sequence
--   - syn = Synonym
--   - tab = Table (includes triggers)
--   - tps = Type specification
--   - tpb = Type body
--   - typ = Type specification and body in one file
-- Other types not supported yet.
--
-- example: @exp_dbobj_ddl kcs pkg
--
-- Types not supported yet:
-- - Scheduler, see O:\70_source_repository\tools\export_DDL_all_jobs.sql
-- - MATERIALIZED VIEW
-- - Java sources
-- 
-- Date: 14-06-2019
-- Author: Herman Mol
set define on
set serveroutput on size unlimited
set pagesize 0
set linesize 2000
set trimout on
set trimspool on
set feedback off
set verify off

-- Define local variables
column col_object_owner new_value lv_object_owner noprint
column col_object_type  new_value lv_object_type  noprint
column col_yyyymmdd     new_value lv_yyyymmdd     noprint
column col_hhmiss       new_value lv_hhmiss       noprint
column col_dbname	    new_value lv_dbname       noprint
-- Set values to the local variables
select to_char(sysdate, 'yyyymmdd')     as col_yyyymmdd			-- = lv_yyyymmdd
	,to_char(sysdate, 'hh24miss')       as col_hhmiss			-- = lv_hhmiss
	,sys_context('userenv', 'db_name')	as col_dbname			-- = lv_dbname
	,upper('&1') 						as col_object_owner		-- = lv_object_owner
	,upper('&2')						as col_object_type		-- = lv_object_type
from dual;
-- check that folders exist using the host command
host if not exist .\&lv_dbname. mkdir &lv_dbname.
cd .\&lv_dbname.
host if not exist .\&lv_object_owner. mkdir &lv_object_owner.
cd .\&lv_object_owner.
host if not exist .\&lv_object_type. mkdir &lv_object_type.
cd .\&lv_object_type.

spool export_&lv_object_owner._&lv_object_type._ddl.sql

prompt set long 2000000
prompt set pagesize 0

declare
    procedure prt (pi_txt in varchar2) is begin dbms_output.put_line(pi_txt); end prt;
begin
	dbms_metadata.set_transform_param(dbms_metadata.session_transform,'DEFAULT',true);

	if '&lv_object_type.' = 'PKS'
	then
		prt('-- Requested: &lv_object_type. Do not export PACKAGE BODY');
		dbms_metadata.set_transform_param(dbms_metadata.session_transform,'BODY',false);
	elsif '&lv_object_type.' = 'TPS'
	then
		prt('-- Requested: &lv_object_type. Do not export TYPE BODY');
		dbms_metadata.set_transform_param(dbms_metadata.session_transform,'BODY',false);
	elsif '&lv_object_type.' = 'PKB'
	then
		prt('-- Requested: &lv_object_type. Do not export PACKAGE SPEC');
		dbms_metadata.set_transform_param(dbms_metadata.session_transform,'BODY',TRUE);
		dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SPECIFICATION',FALSE);
	elsif '&lv_object_type.' = 'TPB'
	then
		prt('-- Requested: &lv_object_type. Do not export TYPE SPEC');
		dbms_metadata.set_transform_param(dbms_metadata.session_transform,'BODY',TRUE);
		dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SPECIFICATION',FALSE);
	elsif '&lv_object_type.' = 'TAB'
	then
		prt('-- Requested: &lv_object_type. Do not export segment and storage info');
		dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES', false);
		dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'STORAGE', false);
		dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'TABLESPACE', true);
		-- dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'TRIGGER', false); -- does not work!
	elsif '&lv_object_type.' = 'IDX'
	then
		prt('-- Requested: &lv_object_type. Do not export segment and storage info');
		dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'SEGMENT_ATTRIBUTES', false);
		dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'STORAGE', false);
		dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'TABLESPACE', true);
	end if;
	<<r_object>>
	for r_object in
	(
		with my_object_types as
		-- Conversion/translation of the object types:
		-- filetype = the requested type as received through the second argument of the command line
		--            and the object type abbreviation used in the file system
		-- objtype  = the object type as used in the Oracle repository views like ALL_OBJECTS
		-- ddltype  = the object type as used in the DDL export command. See the Oracle DBMS_METADATA
		--            package documentation. But (unfortunately!) that specification differs from the
		--            SQLcl DLL requirements/specification !!??! For heavens sake: WHY!!!!
		(               select 'PKS' as filetype, 'PACKAGE'           as objtype, 'PACKAGE'           as ddltype from dual	-- only the spec, see set_transform_param, do not use DBMS_METADATA 'PACKAGE_SPEC'
			  union all select 'PKB' as filetype, 'PACKAGE BODY'      as objtype, 'PACKAGE BODY'      as ddltype from dual	-- only the body, see set_transform_param, do not use DBMS_METADATA 'PACKAGE_BODY'
			  union all select 'PKG' as filetype, 'PACKAGE'           as objtype, 'PACKAGE'           as ddltype from dual	-- the spec and body in one file
			  union all select 'FNC' as filetype, 'FUNCTION'          as objtype, 'FUNCTION'          as ddltype from dual
			  union all select 'PRC' as filetype, 'PROCEDURE'         as objtype, 'PROCEDURE'         as ddltype from dual
			  union all select 'TRG' as filetype, 'TRIGGER'           as objtype, 'TRIGGER'           as ddltype from dual
			  union all select 'SVW' as filetype, 'VIEW'              as objtype, 'VIEW'              as ddltype from dual
			  union all select 'IDX' as filetype, 'INDEX'             as objtype, 'INDEX'             as ddltype from dual
			  union all select 'SEQ' as filetype, 'SEQUENCE'          as objtype, 'SEQUENCE'          as ddltype from dual
			  union all select 'SYN' as filetype, 'SYNONYM'           as objtype, 'SYNONYM'           as ddltype from dual
			  union all select 'TAB' as filetype, 'TABLE'             as objtype, 'TABLE'             as ddltype from dual
			  union all select 'TPS' as filetype, 'TYPE'              as objtype, 'TYPE'              as ddltype from dual	-- only the spec, see set_transform_param
			  union all select 'TPB' as filetype, 'TYPE BODY'         as objtype, 'TYPE BODY'         as ddltype from dual	-- only the body, see set_transform_param
			  union all select 'TYP' as filetype, 'TYPE'              as objtype, 'TYPE'              as ddltype from dual	-- the spec and body in one file
-- NEXT DOES NOT WORK YET ...
--			  union all select 'JVS' as filetype, 'JAVA SOURCE'       as objtype, 'JAVA SOURCE'       as ddltype from dual
--			  union all select 'JVS' as filetype, 'JAVA SOURCE'       as objtype, 'PROCOBJ'           as ddltype from dual
--			  union all select 'JVS' as filetype, 'JAVA SOURCE'       as objtype, 'JAVA_SOURCE'       as ddltype from dual
--			  union all select 'JOB' as filetype, 'JOB'               as objtype, 'DBMS_SCHEDULER'    as ddltype from dual
--			  union all select 'JOB' as filetype, 'JOB'               as objtype, 'SCHEDULER'         as ddltype from dual
--			  union all select 'JOB' as filetype, 'JOB'               as objtype, 'PROCOBJ'           as ddltype from dual
--			  union all select 'JSC' as filetype, 'SCHEDULE'          as objtype, 'PROCOBJ'           as ddltype from dual
--			  union all select 'MVW' as filetype, 'MATERIALIZED VIEW' as objtype, 'MATERIALIZED'      as ddltype from dual
--			  union all select 'MVW' as filetype, 'MATERIALIZED VIEW' as objtype, 'MATERIALIZED VIEW' as ddltype from dual
--			  union all select 'MVW' as filetype, 'MATERIALIZED VIEW' as objtype, 'MATERIALIZED_VIEW' as ddltype from dual
--			  union all select 'MVW' as filetype, 'MATERIALIZED VIEW' as objtype, 'MVIEW' as ddltype from dual
		)
		select obj.owner
			,obj.object_name
			,obt.objtype
			,obt.ddltype
			,obt.filetype
		from all_objects		obj
			,my_object_types	obt
		where '&lv_object_type.' = obt.filetype
		and obj.owner = '&lv_object_owner.'
		and obj.object_type = obt.objtype
		and not (	obj.object_type = 'TYPE'
				and regexp_like(obj.object_name,'SYS_PLSQL_[0-9]{1}','i')
				)
		order by obj.object_name
	)
	loop
		prt('ddl ' || r_object.owner || '.' || r_object.object_name
			|| ' ' || r_object.ddltype
			|| chr(10) || 'save ' || lower(r_object.object_name) || '.sql REPLACE; '
			);
	end loop r_object;

end;
/
spool off
--
@spoolme export_&lv_object_owner._&lv_object_type._ddl.sql
@export_&lv_object_owner._&lv_object_type._ddl.sql
spool off
cd ..
cd ..
cd ..
prompt *I: End of file exp_dbobj_ddl.sql

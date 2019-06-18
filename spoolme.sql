-- =================================================================================================
-- Krinkels Automatisering B.V. - Oracle Script to initiate SQL/Plus
--
-- Script version history:
-- yyyymmdd engineer notes
-- 20170214 hhmo     New
--
--   Example:   @spoolme.sql deploy_this_folder.sql
--
-- =================================================================================================
set appinfo on
set time on
set serverout on size unlimited
set pagesize 50000
set linesize 32767
set trimout on
set trimspool on
set head off
set define on
set sqlblanklines on
define v_script_name = &1
--
-- Construct spoolfile name
set verify off
column ali_spoolfile new_value var_spoolfile noprint
select replace(regexp_substr('&v_script_name.','[/\\]?([^\/:.]+)[.a-z0-9]*$',1,1,'i',1),' ','_')
      || '_' || sys_context('userenv', 'db_name')
      || '_' || sys_context('userenv', 'current_schema')
      || '_' || to_char(sysdate, 'yyyymmdd_hh24miss')
      || '.lst'
      as ali_spoolfile
from dual;
set verify on
prompt *I: Spoolfile var_spoolfile = &var_spoolfile.;
prompt --------------------------------------------------------------------------------;

spool &var_spoolfile.

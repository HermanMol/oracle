prompt *I: ScriptBOF deploy_string_stack_object.sql
/* [HM7A9_20240512_120400] */
-- Check we are in the proper schema for deploying this
--@hmxt_check_deployment_schema gdb_tools

-- Generate a unique spoolfile name
--@hmxt_spoolstart deploy_string_stack_object.sql
spool deploy_string_stack_object_SPOOLFILE.lst

--prompt *I: Pre-deployment report invalid objects:
--@hmxt_report_invalid_all.sql

@typ_t_string_varray50.sql
show errors

@tps_string_stack_object.sql
show errors

@tpb_string_stack_object.sql
show errors

--prompt *I: Post-deployment re-compile invalid objects:
--@hmxt_recompile_invalid_all.sql

--prompt *I: Post-deployment report invalid objects:
--@hmxt_report_invalid_all.sql

--@hmxt_spoolfinish
spool off
prompt *I: ScriptEOF deploy_string_stack_object.sql

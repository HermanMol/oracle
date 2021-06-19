-- Some code to test the HMO_APEX_SESSION_UTL package

-- 01: Set the APEX workspace and DB parsing schema
begin
	hmo_apex_session_utl.set_workspace_and_schema
		(pi_workspace		=> '???put_your_workspace_name_here'
		,pi_parsing_schema	=> '???put_your_DB_parsing_schema_name_here'
		);
end;
/		

-- 02: Connect to the APEX session
begin
    hmo_apex_session_utl.attach_session(pi_url=>'https://apexapps.oracle.com/pls/apex/f?p=55447:1:10390348077089:::::');
end;
/

-- 03: query values form the session's session state
select 'P101_USERNAME' as var_name, v('P101_USERNAME') as var_value from dual
union all
select 'APP_DTE_FMT' as var_name, v('APP_DTE_FMT') as var_value from dual
union all
select 'MY_VISITED_PAGE_IDS_STACK' as var_name, v('MY_VISITED_PAGE_IDS_STACK') as var_value from dual
/

-- 04: You even can change values in the application runtime:
begin
    apex_util.set_session_state('P101_USERNAME','ANYONE ELSE');
end;
/

-- 05: query the apex_collection used by the APEX session
select *
from apex_collections
/

-- 06: disconnect from the APEX session
begin
    hmo_apex_session_utl.detach_session();
end;
/

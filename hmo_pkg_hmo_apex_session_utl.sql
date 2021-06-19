prompt *I: Start of file hmo_pkg_hmo_apex_session_utl.sql
create or replace package hmo_apex_session_utl
authid definer
as
	-- =============================================================================================
	-- Package: hmo_apex_session_utl
	-- Purpose: Extra or wrapped-and-simplified functionality for the Oracle APEX session.
	--
	-- Active user must be the parsing schema hence "Definer Rights"!
	-- This "Apex attach"-feature uses an APEX_COLLECTION, see c_sqldev_collection, below.
	--
	-- Version history
	-- yyyymmdd Eng.	Notes
	-- -------- -------- ---------------------------------------------------------------------------
	-- 20210612 HMO		 Attach/Detach to APEX sessions, especially with queries having the V('...')
	--					 function, so we can now connect to the session and reference the same
	--					 values in SQL Developer as in the session! Also in the attached SQL
	--					 you can query other runtime data (and even change it :-)
	--					 Baseline: new!
	-- =============================================================================================

	-- Public constants
	c_connected			constant varchar2(08 char) := 'ATTACHED';
	c_disconnected		constant varchar2(08 char) := 'DETACHED';

	-- ---------------------------------------------------------------------------------------------
	-- Public procedure to set the APEX workspace and de parsing schema to be attaching to.
	procedure set_workspace_and_schema
		(pi_workspace		in varchar2
		,pi_parsing_schema	in varchar2
		);
		
	-- ---------------------------------------------------------------------------------------------
	-- Public procedure to attach to an APEX session specially meant for use with SQL Developer
	-- Argument: pi_url = The URL of the active APEX session to be connected to
	procedure attach_session
		(pi_url		in varchar2);

	-- ---------------------------------------------------------------------------------------------
	-- Public procedure to detach from an APEX session specially meant for use with SQL Developer
	-- Argument: Keep (false) or remove (true) the internally used collection. Default is remove
	procedure detach_session
		(pi_remove	in boolean := true);	-- true/false
		
	-- ---------------------------------------------------------------------------------------------
	-- Public procedure that displays the APEX workspace and parsing schema to be attaching to.
	procedure report_workspace_and_schema;
		
end hmo_apex_session_utl;
/
create or replace package body hmo_apex_session_utl
as
	-- =============================================================================================
	-- Package: hmo_apex_session_utl
	-- Purpose: Extra or wrapped-and-simplified functionality for the Oracle APEX session.
	--
	-- Active user must be the APEX parsing schema hence "Definer Rights"|!
	-- This "Apex attach"-feature uses an APEX_COLLECTION, see c_sqldev_collection, below.
	--
	-- Version history
	-- yyyymmdd Eng.	Notes
	-- -------- -------- ---------------------------------------------------------------------------
	-- 20210612 HMO	New package
	--				Attach/Detach to an APEX sessions, especially with queries having the V('...')
	--				function, so we can now connect to the session and reference the same
	--				values in SQL Developer as in the session! Also in the attached SQL
	--				you can query other runtime data (and even change it :-)
	--				Baseline: new!
	-- =============================================================================================

	-- Private constants
	c_sqldev_collection	constant varchar2(50 char) := upper(sys_context('USERENV','OS_USER') || '_SQLDEVELOPER_DATA');

	type strings is table of varchar2(32767);

	-- Collection of application items that could be reported
	c_items			strings :=
		strings
			('APP_USER','APP_ID','APP_PAGE_ID');

	-- Private global field
	g_workspace_name	varchar2( 30 char)  := 'MOLWS01';
	g_parsing_scheme	varchar2( 30 char)  := 'MOLDB01';
	g_my_status			varchar2(  8 char)	:= null;	-- holds the c_connected / c_disconnected values
	g_last_update		varchar2(100 char)	:= null;	-- holds the last connect-time

	-- ---------------------------------------------------------------------------------------------
	-- Private procedure to get the connection status into the g_my_status variable.
	procedure p_get_connection_status
	as
	begin
		if apex_collection.collection_exists (c_sqldev_collection)
		then
			begin
				select c001
					,c002
				into g_my_status
					,g_last_update
				from apex_collections
				where collection_name = c_sqldev_collection;
				g_my_status := nvl(g_my_status,c_disconnected);
			exception
				when no_data_found
				then
					g_my_status:= c_disconnected;
			end;
		else
			g_my_status := c_disconnected;
		end if;
	end p_get_connection_status;

	-- ---------------------------------------------------------------------------------------------
	-- Private procedure set status to connected
	procedure p_set_status_connected
	as
	begin
		if not apex_collection.collection_exists (c_sqldev_collection)
		then
			apex_collection.create_collection(p_collection_name => c_sqldev_collection);
			apex_collection.add_member
				(p_collection_name => c_sqldev_collection
				,p_c001	=> c_connected
				,p_c002	=> 'last_change='	|| to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')
				,p_c003	=> 'APP_ID='		|| gp.nvlc(v('APP_ID'))
				,p_c004	=> 'APP_PAGE_ID='	|| gp.nvlc(v('APP_PAGE_ID'))
				,p_c005	=> 'APP_USER='		|| gp.nvlc(v('APP_USER'))
				);
		else
			apex_collection.update_member_attribute
				(p_collection_name => c_sqldev_collection
				,p_seq			=> 1
				,p_attr_number	=> 1		-- c001
				,p_attr_value	=> c_connected
				);
			apex_collection.update_member_attribute
				(p_collection_name => c_sqldev_collection
				,p_seq			=> 1
				,p_attr_number	=> 2		-- c002
				,p_attr_value	=> 'last_change=' || to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')
				);
		end if;
		g_my_status := c_connected;
	end p_set_status_connected;

	-- ---------------------------------------------------------------------------------------------
	-- Private procedure set status to disconnected
	procedure p_set_status_disconnected
	as
	begin
		if apex_collection.collection_exists (c_sqldev_collection)
		then
			apex_collection.update_member_attribute 
				(p_collection_name => c_sqldev_collection
				,p_seq			=> 1
				,p_attr_number	=> 1		-- c001
				,p_attr_value	=> c_disconnected
				);
			apex_collection.update_member_attribute 
				(p_collection_name => c_sqldev_collection
				,p_seq			=> 1
				,p_attr_number	=> 2		-- c002
				,p_attr_value	=> 'last_change=' || to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')
				);
		else
			null;
			-- The collection was not found, so no further action
			-- apex_collection.create_collection(p_collection_name => c_sqldev_collection);
			-- apex_collection.add_member 
			--	(p_collection_name => c_sqldev_collection
			--	,p_c001			=> pi_status
			--	,p_c002			=> 'last_change=' || to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')
			--	);
		end if;
		g_my_status := c_disconnected;
	end p_set_status_disconnected;

	-- ---------------------------------------------------------------------------------------------
	-- Private function to attach to an APEX session based on the APEX url
	-- Input: pi_apex_url = a copy-paste of the full url from your browser
	-- Output: boolean true if is succeeded, else false.
	-- ---------------------------------------------------------------------------------------------
	function f_connect_to_apex_session
		(pi_apex_url	in varchar2)
	return boolean	-- true = connected
	as

		l_url_session		varchar2(100 char);
		l_url_app			varchar2(100 char);
		l_url_page			varchar2(100 char);
		l_session_id		number;
		l_app_id			number;
		l_page_id			number;
		sw_connected		boolean := false;
		
		l_app_name			varchar2(255 char);
		l_page_name			varchar2(255 char);
		
		-- Local function to convert a char to a number
		-- (A likewise functionality is available in Oracle 19 for the to_number function.)
		function lf_to_num (pi_char in varchar2, pi_default number := 0)
		return number
		as
		begin
			return to_number(pi_char);
		exception
			when others 
			then
				return nvl(pi_default,0);
		end lf_to_num;
		
	begin

		-- Extract items from the URL: APP and PAGE could be tyhe ID or the ALIAS:
		l_url_session	:= coalesce(v('app_session'),regexp_substr(pi_apex_url,'([^:]?+):?',1,4,'i',1));
		l_url_app		:= coalesce(v('app_id'	   ),regexp_substr(pi_apex_url,'f\?p=([^:]?+):?',1,1,'i',1));
		l_url_page		:= coalesce(v('app_page_id'),regexp_substr(pi_apex_url,'([^:]?+):?',1,3,'i',1));

		gp.prt('*I: Info extracted from url "'|| pi_apex_url||'":'
			|| gp.c_lf || '- session	= >' || gp.nvlc(l_url_session) || '<'
			|| gp.c_lf || '- application= >' || gp.nvlc(l_url_app)	|| '<'
			|| gp.c_lf || '- page		= >' || gp.nvlc(l_url_page)	|| '<'
			);

		-- Try to convert to numbers. If it fails we probably have the ALIAS: set the number to -1
		-- so we can get the ID's later.
		l_session_id := lf_to_num(l_url_session,-1);
		l_app_id	 := lf_to_num(l_url_app,-1);
		l_page_id	 := lf_to_num(l_url_page,-1);

		-- Session *MUST* be numeric
		if l_session_id < 0
		then
			raise_application_error(-20000,'*E: APEX Session from url is not numeric.',true);
		end if;

		-- If the url contained the application alias, get the application ID right here.
		if l_app_id < 0
		then
			select max(application_id)
			into l_app_id
			from apex_applications
			where workspace = g_workspace_name
			and alias = l_url_app;
			gp.prt('*I: Application_id based on alias = ' || gp.nvlc(l_app_id)||'.');
		end if;

		-- If the url contained the page alias, get the page ID right here.
		if l_page_id < 0
		then
			select max(page_id)
			into l_page_id
			from apex_application_pages
			where workspace = g_workspace_name
			and application_id = l_app_id
			and page_alias = l_url_page;
			gp.prt('*I: Page_id based on alias = ' || gp.nvlc(l_page_id)||'.');
		end if;
		
		-- check that the application exists in the workspace
		<<verify_app_workspace>>
		begin
			select application_name
			into l_app_name
			from apex_applications
			where workspace = g_workspace_name
			and application_id = l_app_id;
		exception
			when no_data_found
			then
				raise_application_error(-20002,apex_string.format('Application ID %0 not found in workspace %1',l_app_id,g_workspace_name),true);
		end verify_app_workspace;

		-- check that the application page exists
		<<verify_app_page>>
		begin
			select page_name
			into l_page_name
			from apex_application_pages
			where workspace = g_workspace_name
			and application_id = l_app_id
			and page_id = l_page_id;
		exception
			when no_data_found
			then
				raise_application_error(-20003,apex_string.format('Page %0 for application ID %1 not found in workspace %2',l_page_id,l_app_id,g_workspace_name),true);
		end verify_app_page;
		

		-- Print the result before we get to the real stuff
		gp.prt('*I: Attaching to APEX session:'
			|| gp.c_lf || '- session_id	= ' || gp.nvlc(l_session_id)
			|| gp.c_lf || '- application= ' || gp.nvlc(l_app_id)  
						|| nullif( ' ' || gp.nvlc(l_app_name) ,' ' ) 
						|| nullif( ' (' || gp.nvlc(l_url_app)  || ')',' ()' )
			|| gp.c_lf || '- page		= ' || gp.nvlc(l_page_id) 
						|| nullif( ' ' || gp.nvlc(l_page_name),' ' ) 
						|| nullif( ' (' || gp.nvlc(l_url_page)  || ')',' ()' )
			);

		<<attach_to_apex>>
		begin
			apex_session.attach
				(p_app_id		=> l_app_id
				,p_page_id		=> l_page_id
				,p_session_id	=> l_session_id
				);
			sw_connected := true;	-- Hurraaay!
			-- If using an application user session dedicated context; make it available to SQL Developer
			-- dbms_session.set_identifier(<the_user_session_context_identifier>);
		exception
			when others
			then
				gp.prt('*** ERROR ***' || gp.c_lf || sqlerrm);
				gp.prt(dbms_utility.format_error_stack);
		end attach_to_apex;

		return sw_connected;
	end f_connect_to_apex_session;

	-- ---------------------------------------------------------------------------------------------
	-- Private procedure to check the user is allowed to attach/detach to APEX sessions
	-- Only developers in this workspace
	procedure p_check_user_attaching
	as
		l_cnt	number;
	begin
		select count(*)
		into l_cnt
		from apex_workspace_developers
		where workspace_name = g_workspace_name
		and (	(	user_name = sys_context('USERENV','SESSION_USER')
				and upper(account_locked) = 'NO'
				)
				or	sys_context('USERENV','SESSION_USER') = g_parsing_scheme
			);
		if sign(nvl(l_cnt,0)) <> 1
		then
			raise_application_error(-20001,'*** Only APEX workspace developers are allowed to use this feature ***',true);
		end if;
	end p_check_user_attaching;

	-- ---------------------------------------------------------------------------------------------
	-- Private procedure to check the right schema is current
	procedure p_check_schema_attaching
	as
	begin
		if sys_context('userenv','current_user') <> g_parsing_scheme
		then
			raise_application_error(-20004,'*** Session current_user must be the parsing scheme ***',true);
		end if;
	end p_check_schema_attaching;

	-- ---------------------------------------------------------------------------------------------
	-- Public function to attach to an APEX session specially meant for use with SQL Developer
	-- Argument: pi_url = The URL of the active APEX session to be connected to
	procedure attach_session
		(pi_url		in varchar2)
	as
		l_verb		varchar2(200 char);
		sw_attached	boolean := false;
		l_void		number;
	begin

		p_check_user_attaching;		-- Only developers in this workspace. Exception -20001 if not
		p_check_schema_attaching;	-- Running in the parsing schema? Exception -20000 if not

		gp.prt('*I: Attaching to the APEX session ' || pi_url || '...');

		p_get_connection_status; -- into g_my_status

		if g_my_status = c_connected
		then
			gp.prt('*A: You are already attached');
			l_verb := 'were already ('||g_last_update||')';
			sw_attached := true;
		else
			sw_attached := f_connect_to_apex_session(pi_apex_url => pi_url);
			l_verb := 'are now';
		end if;

		if sw_attached
		then
			-- report the application items
			<<report_app_items>>
			begin
				gp.prt('*I: WebAtak values:');
				for i in c_items.first .. c_items.last
				loop
					gp.prt(apex_string.format('- %0 %1 = %2',i,gp.nvlc(c_items(i)),gp.nvlc(v(c_items(i)))));
				end loop;
			end report_app_items;

			if g_my_status <> c_connected
			then
				p_set_status_connected();
			end if;

			gp.prt(rpad('*I: ',80,'+')
				|| gp.c_lf || '*I: You ' || l_verb || ' attached to application '
				|| v('app_id') || ' and page ' || v('app_page_id')
				|| ' in APEX session ' || v('session') || '.'
				|| gp.c_lf || rpad('*I: ',80,'+')
				);
		else
			gp.prt(rpad('*E: ',80,'-')
				|| gp.c_lf || '*E: YOU ARE NOT ATTACHED ***'
				|| gp.c_lf || rpad('*E: ',80,'-')
				);
		end if;
	end attach_session;

	-- ---------------------------------------------------------------------------------------------
	-- Public function to detach from an APEX session specially meant for use with SQL Developer
	-- Argument: Keep (false) or remove (true) the internally used collection. Default is remove
	procedure detach_session
		(pi_remove	in boolean := true)	-- true/false
	as
	begin

		p_check_user_attaching;		-- Only developers in this workspace. Exception -20001 if not
		p_check_schema_attaching;	-- Running in the parsing schema? Exception -20000 if not

		p_get_connection_status;	-- into g_my_status

		if g_my_status = c_connected
		then
			p_set_status_disconnected();
			if pi_remove
			then
				apex_collection.delete_collection(c_sqldev_collection);
				gp.prt('*I: Apex collection supporting this feature is DELETED from the Apex session.');
			else
				gp.prt('*I: Apex collection supporting this feature is KEPT in the Apex session.');
			end if;
			apex_session.detach;
			gp.prt('*I: You are now detached from the APEX session.');
		else
			gp.prt('*I: You were already detached from the APEX session.');
		end if;
	end detach_session;

	-- ---------------------------------------------------------------------------------------------
	-- Public procedure to set the APEX workspace and de parsing schema to be attaching to.
	procedure set_workspace_and_schema
		(pi_workspace		in varchar2
		,pi_parsing_schema	in varchar2
		)
	as
	
	begin
		g_workspace_name := upper(pi_workspace);
		g_parsing_scheme := upper(pi_parsing_schema);
		report_workspace_and_schema;
	end set_workspace_and_schema;
		
	-- ---------------------------------------------------------------------------------------------
	-- Public procedure that displays the APEX workspace and parsing schema to be attaching to.
	procedure report_workspace_and_schema
	as
	begin
		gp.prt(apex_string.format('*I: Current APEX workspace is %0 and the parsing schema is %1.'
				,g_workspace_name
				, g_parsing_scheme
				)
			);
	end report_workspace_and_schema;

end hmo_apex_session_utl;
/
prompt *I: End of file hmo_pkg_hmo_apex_session_utl.sql

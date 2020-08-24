prompt *I: Start of file test_string_stack.sql
--@spoolme test_string_stack.sql
DECLARE
	l_msg  string_stack_object := string_stack_object();	-- instantiate

	l_line_start	number;
	l_char			varchar2(4000);
	l_num			number;

	-- simple wrapper for cumbersome d-b-m-s-_-o-u-t-p-u-t-.-p-u-t-_-l-i-n-e
	procedure prt (pi_txt in varchar2)
	as
	begin
		dbms_output.put_line(pi_txt);
	end prt;

	-- wrapper to print a number as text
	function nvlc(pi_num in number)
	return varchar2
	as
	begin
		return nvl(to_char(pi_num),'nill');
	end nvlc;

	-- a local procedure to print the strings from the stack, one by one...
	procedure print_stack
	is
	begin
		for r_string in
		(
			select column_value as a_string
			from table(l_msg.get_strings())
		)
		loop
			prt(r_string.a_string);
		end loop;
	end print_stack;

--	------------------------------------------ MAIN LINE -------------------------------------------
BEGIN
	l_line_start := $$plsql_line;
	prt('Lines start at: ' || l_line_start);

	prt(rpad('=',100,'='));
	prt('*I: The initial string stack ...' || '[' || $$plsql_line || ']');
	print_stack;
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Add one string ...' || '[' || $$plsql_line || ']');
	l_msg.push('This first string was added ' || to_char(sysdate, 'dy dd Month yyyy HH24:mi:ss') || '.');
	print_stack;
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Add a second string ...' || '[' || $$plsql_line || ']');
	l_msg.push('Another string added to the stack!');
	print_stack;
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Add 53 entries, check FIFO (max stack size is ' || l_msg.g_string_stack.limit || ' entries.'
		|| chr(10) || '    See schema level type T_STRING_STACK IS VARRAY(50) OF VARCHAR2(4000).' || '[' || $$plsql_line || ']');
	for i in 1..53
	loop
		l_msg.push('Loop #' || trim(to_char(i,'000')));
	end loop;
	print_stack;
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Get string stack entries serialized as one string ...' || '[' || $$plsql_line || ']');
	prt(l_msg.get_serialized());
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Can we access the stack entries direct?' || '[' || $$plsql_line || ']');
	begin
		prt('    Yes we can, the first entry is: ' || l_msg.g_string_stack(1));
		prt('    Yes we can, the last entry is: ' || l_msg.g_string_stack(l_msg.g_string_stack.last));
	exception
		when others
		then
			prt('*W: No. You cannot access the strings in the stack.');
	end;
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Initialise the stack ...' || '[' || $$plsql_line || ']');
	l_msg.init_stack();
	print_stack;
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));
	
	prt(rpad('=',100,'='));
	prt('*I: Access an entry in initialised stack ...' || '[' || $$plsql_line || ']');
	<<access_entry_1>>
	begin
		prt('*I: Access fifth entry in initialised stack: ' || l_msg.g_string_stack(5) );
	exception
		when others
		then
			prt('*E: Access fifth entry in initialised stack: ' || sqlerrm);
	end access_entry_1;
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Remove 3rd entry ...' || '[' || $$plsql_line || ']');
	l_msg.remove(3);
	print_stack;
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Add 10 entries in the stack ...' || '[' || $$plsql_line || ']');
	for i in 1..10
	loop
		l_msg.push('Loop #' || trim(to_char(i,'000')));
	end loop;
	print_stack;
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Pop 9th entry ...' || '[' || $$plsql_line || ']');
	l_char := l_msg.pop(9);
	--l_msg.remove(9);
	print_stack;
	prt('*I: The pop-ped entry was: ' || l_char || '.');
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Remove 4th entry ...' || '[' || $$plsql_line || ']');
--	l_char := l_msg.pop(4);
	l_msg.remove(3);
	print_stack;
--	prt('*I: The pop-ped entry was: ' || l_char || '.');
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Pop last entry ...' || '[' || $$plsql_line || ']');
	l_char := l_msg.pop(l_msg.g_string_stack.last());
	--l_msg.remove(l_msg.last);
	print_stack;
	prt('*I: The pop-ped entry was: ' || l_char || '.');
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Pop 2nd from last entry ...' || '[' || $$plsql_line || ']');
	l_char := l_msg.pop(-2);
	--l_msg.remove(-2);
	print_stack;
	prt('*I: The pop-ped entry was: ' || l_char || '.');
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Initialise the stack ...' || '[' || $$plsql_line || ']');
	l_msg.init_stack();
	print_stack;
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Add max entries ...' || '[' || $$plsql_line || ']');
	for i in 1..l_msg.g_string_stack.limit
	loop
		l_msg.push('Loop #' || trim(to_char(i,'000')));
	end loop;
	print_stack;
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Remove 1st from last entry ...' || '[' || $$plsql_line || ']');
	--l_char := l_msg.pop(-1);
	l_msg.remove(-1);
	print_stack;
	--prt('*I: The pop-ped entry was: ' || l_char || '.');
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Initialise the stack ...' || '[' || $$plsql_line || ']');
	l_msg.init_stack();
	print_stack;
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Add 1 entry ...' || '[' || $$plsql_line || ']');
	l_msg.push('Yeayeah, one entry!');
	print_stack;
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('*I: Remove 1st from last entry ...' || '[' || $$plsql_line || ']');
	--l_char := l_msg.pop(-1);
	l_msg.remove(-1);
	print_stack;
	--prt('*I: The pop-ped entry was: ' || l_char || '.');
	prt('*I: Stack entries (First/Last/Count): ' || nvlc(l_msg.g_string_stack.first()) || ' / ' || nvlc(l_msg.g_string_stack.last()) || ' / ' || nvlc(l_msg.g_string_stack.last()));

	prt(rpad('=',100,'='));
	prt('= THE END =');
	prt(rpad('=',100,'='));
END;
/
--spool off
prompt *I: End of file test_string_stack.sql

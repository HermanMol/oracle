-- Create the base varray type so we can use this type in the Advances Data Type (ADT)
--create or replace type t_string_stack is varray(50) of varchar2(4000)
--/
create or replace type string_stack_object
authid current_user
as object
	(c_version        varchar2(10)
	,g_string_stack	  t_string_stack		-- collect string data, log when exception occurs. see string_stack* methods in this package body
	-- ---------------------------------------------------------------------------------------------
	-- Public procedure to initialise the stack
	,member procedure init_stack
	-- ---------------------------------------------------------------------------------------------
	-- Public procedure to add a string to the stack
	,member procedure push (SELF IN OUT NOCOPY string_stack_object, pi_string in varchar2 )
	-- ---------------------------------------------------------------------------------------------
	-- Public function to get a specific entry from the stack (entry remains on the stack)
	-- pi_idx:
	-- - when null, zero or beyond last, then null is retrieved
	-- - when < zero, counted back from the last of the stack
	-- Choosen never to throw an exception SUBSCRIPT_BEYOND_COUNT.
	,member function get (SELF IN OUT NOCOPY string_stack_object, pi_idx in number := null) return varchar2
	-- ---------------------------------------------------------------------------------------------
	-- Public procedure to remove a specific entry from the stack
	-- pi_idx:
	-- - when null, zero or beyond last, then null is retrieved
	-- - when < zero, counted back from the last of the stack
	-- Choosen never to throw an exception SUBSCRIPT_BEYOND_COUNT.
	,member procedure remove (SELF IN OUT NOCOPY string_stack_object, pi_idx in number := null)
	-- ---------------------------------------------------------------------------------------------
	-- Public function to get a specific entry and remove it from the stack
	-- So in fact the get + remove.
	-- pi_idx:
	-- - when null, zero or beyond last, then null is retrieved
	-- - when < zero, counted back from the last of the stack
	-- Choosen never to throw an exception SUBSCRIPT_BEYOND_COUNT.
	,member function pop (SELF IN OUT NOCOPY string_stack_object, pi_idx in number := null) return varchar2
	-- ---------------------------------------------------------------------------------------------
	-- Public function to return all strings from the stack as a string
	,member function get_serialized return varchar2
	-- ---------------------------------------------------------------------------------------------
	-- Public function to return all strings from the stack pipelined
	,member function get_strings return t_string_stack pipelined
	-- ---------------------------------------------------------------------------------------------
	-- Constructor initialising the object instance
	,constructor function string_stack_object
		(self in out nocopy string_stack_object)
		return self as result
);
/
create or replace type body string_stack_object
is
	
	-- ---------------------------------------------------------------------------------------------
	-- Public procedure to initialise the stack
	member procedure init_stack
	as
	begin
		g_string_stack.delete;	-- initialise stack
	end init_stack;

	-- ---------------------------------------------------------------------------------------------
	-- Public procedure to add a string to the stack
	member procedure push (SELF IN OUT NOCOPY string_stack_object, pi_string in varchar2 )
	is
	begin
		if g_string_stack.last = g_string_stack.limit
		then
			for i in 2..g_string_stack.last
			loop
				-- remove oldest message
				g_string_stack(i - 1) := g_string_stack(i);
			end loop;
		else
			g_string_stack.extend;
		end if;
		g_string_stack(g_string_stack.last) := substr(pi_string,1,4000);
	end push;

	-- ---------------------------------------------------------------------------------------------
	-- Public function to get a specific entry from the stack (entry remains on the stack)
	-- pi_idx:
	-- - when null, zero or beyond last, then null is retrieved
	-- - when < zero, counted back from the last of the stack
	-- Choosen never to throw an exception SUBSCRIPT_BEYOND_COUNT.
	member function get (SELF IN OUT NOCOPY string_stack_object, pi_idx in number := null) return varchar2
	is
		l_idx		number;
		l_string	varchar2(4000);
	begin
		if g_string_stack is null
		then
			return null;		-- stack does not exist
		elsif g_string_stack.first is null
		then
			return null;		-- stack is empty
		elsif abs(pi_idx) > g_string_stack.last()
		then
			return null;		-- beyond size
		elsif nvl(pi_idx,0) = 0
		then
			return null;		-- serious?
		end if;
		
		if pi_idx < 0			-- count from the back
		then
			-- calculate equivalent as if from begin of stack
			l_idx := g_string_stack.last() + pi_idx + 1;
		else			-- count from the begin
			l_idx := pi_idx;
		end if;

		l_string := g_string_stack(l_idx);
		return g_string_stack(l_idx);
		--return l_string;
	end get;

	-- ---------------------------------------------------------------------------------------------
	-- Public procedure to remove a specific entry from the stack
	-- pi_idx:
	-- - when null, zero or beyond last, then null is retrieved
	-- - when < zero, counted back from the last of the stack
	-- Choosen never to throw an exception SUBSCRIPT_BEYOND_COUNT.
	member procedure remove (SELF IN OUT NOCOPY string_stack_object, pi_idx in number := null)
	is
		l_idx	number;
	begin
		if g_string_stack is null
		then
			return;		-- stack does not exist
		elsif g_string_stack.first() is null
		then
			return;		-- stack is empty
		elsif abs(pi_idx) > g_string_stack.last()
		then
			return;		-- beyond size
		elsif nvl(pi_idx,0) = 0
		then
			return;		-- serious?
		end if;
		
		if pi_idx < 0	-- count from the back
		then
			-- calculate equivalent as if from begin of stack
			l_idx := g_string_stack.last() + pi_idx + 1;
		else			-- count from the begin
			l_idx := pi_idx;
		end if;

		-- If not removing the last entry, then shift all entries from pi_idx+1 to 
		-- the 1 lower entry in the stack
		if l_idx <> g_string_stack.last()
		then
			for i in l_idx..g_string_stack.last()
			loop
				g_string_stack(i - 1) := g_string_stack(i);
			end loop;
		end if;
		g_string_stack.trim();	-- remove the last entry
	end remove;

	-- ---------------------------------------------------------------------------------------------
	-- Public function to get a specific entry and remove it from the stack
	-- So in fact the get + remove.
	-- pi_idx:
	-- - when null, zero or beyond last, then null is retrieved
	-- - when < zero, counted back from the last of the stack
	-- Choosen never to throw an exception SUBSCRIPT_BEYOND_COUNT.
	member function pop (SELF IN OUT NOCOPY string_stack_object, pi_idx in number := null) return varchar2
	is
		l_retval	varchar2(4000);	-- same as type t_string_stack -> varchar2(4000)
	begin
		l_retval := get(pi_idx);
		remove (pi_idx);
		return l_retval;
	end pop;

	-- ---------------------------------------------------------------------------------------------
	-- Public function to return all strings from the stack as a string
	member function get_serialized return varchar2
	is
		c_lf		constant varchar2(1)	:= chr(10);
		l_retval	varchar2(32767)			:= null;
		l_sep		varchar2(1)				:= null;
	begin
		if g_string_stack.count() = 0
		then
			l_retval := 'No strings in string_stack_object.';
		else
			for i in g_string_stack.first .. g_string_stack.last
			loop
				exit when length(l_retval || l_sep || g_string_stack(i)) > 32767;
				l_retval := l_retval || l_sep || g_string_stack(i);
				l_sep := c_lf;
			end loop;
		end if;

		return l_retval;
	end get_serialized;

	-- ---------------------------------------------------------------------------------------------
	-- Public function to return all strings from the stack pipelined
	member function get_strings return t_string_stack pipelined
	is
	begin
		if g_string_stack.count() > 0
		then
			for i in g_string_stack.first .. g_string_stack.last
			loop
				pipe row (g_string_stack(i));
			end loop;
		end if;
		return;
	end get_strings;

	-- ---------------------------------------------------------------------------------------------
	-- Constructor initialising the object instance
	constructor function string_stack_object
		(self in out nocopy string_stack_object)
	return self as result
	is
	begin
		g_string_stack := t_string_stack();
		c_version := '1.00';
		return;
	end;
end;
/

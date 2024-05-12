prompt *I: ScriptBOF tps_string_stack_object.sql
create or replace type string_stack_object 
authid current_user
as object
/* [HM7A9_20240512_120400] */
    -- An Oracle Advanced Data type (ADT)
	-- A stack for maximum 50 strings each of maximum 4000 characters long
	-- hmol version 1, 20211005
	(c_version        varchar2(10)
	,g_string_stack	  t_string_varray50		-- collect string data, log when exception occurs. see string_stack* methods in this package body
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
	-- Public function to return maximum size of the stack
	,member function max_idx return number
	-- ---------------------------------------------------------------------------------------------
	-- Public function to return the index of the first entry
	-- Always 1 unless the stack is empty. I.s.o. null we return zero
	,member function first_idx return number
	-- ---------------------------------------------------------------------------------------------
	-- Public function to return the index of the last entry
	,member function last_idx return number
	-- ---------------------------------------------------------------------------------------------
	-- Public function to return all strings from the stack as a string
	,member function get_serialized return varchar2
	-- ---------------------------------------------------------------------------------------------
	-- Public function to return all strings from the stack pipelined
	,member function get_strings return t_string_varray50 pipelined
	-- ---------------------------------------------------------------------------------------------
	-- Constructor initialising the object instance
	,constructor function string_stack_object
		(self in out nocopy string_stack_object)
		return self as result
);
/
prompt *I: ScriptEOF tps_string_stack_object.sql

prompt *I: Begin of file hmo_pkg_gp.sql
create or replace package gp
as
	-- =============================================================================================
	-- Package: GP = General Procedures
	-- HMO, 20210612 New
	-- =============================================================================================
	--
	-- ---------------------------------------------------------------------------------------------
	-- public wrapper for the tedious dbms_output.put_line
	procedure prt (pi_text in varchar2);

	-- constants implemented as DETERMINISTIC so they can be used in DML statements
	function c_tab  return varchar2 deterministic;  -- an AscII TAB character
	function c_lf   return varchar2 deterministic;  -- an AscII line feed character
	function c_cr   return varchar2 deterministic;  -- an AscII carriage return character
	function c_nak  return varchar2 deterministic;  -- an AscII negative acknowledgement character
	function c_ack  return varchar2 deterministic;  -- an AscII (positive) acknowledgement character
	function c_fs   return varchar2 deterministic;  -- an AscII file separator character
	function c_rs   return varchar2 deterministic;  -- an AscII record separator character
	function c_us   return varchar2 deterministic;  -- an AscII unit separator character
	function c_etx  return varchar2 deterministic;  -- an AscII end of text character
	function c_eot  return varchar2 deterministic;  -- an AscII end of transmission character

	function c_amp  return varchar2 deterministic;  -- an AscII ampersand character
	function c_1q   return varchar2 deterministic;  -- an AscII single quote character
	function c_2q   return varchar2 deterministic;  -- an AscII double quote character
	-- --------------------------------------------------------------------------------------------
	-- Return a ridiculous/impossible character value to be used in comparissons with NULL, like:
	--	coalesce(char_A, gp.c_nullchar) = coalesce(char_B, gp.c_nullchar)
	function c_nullchar return varchar2 deterministic;
	-- --------------------------------------------------------------------------------------------
	-- Return a ridiculous/impossible date value to be used in comparissons with NULL, like
	--   coalesce(date_A, gp.c_nulldate) = coalesce(date_B, gp.c_nulldate)
	function c_nulldate return date     deterministic;
	-- --------------------------------------------------------------------------------------------
	-- Return a ridiculous/impossible value to be used in comparissons with NULL, like
	-- 		coalesce(num_A, gp.c_nullnum) = coalesce(num_B, gp.c_nullnum)
	function c_nullnum return number    deterministic;
	-- --------------------------------------------------------------------------------------------
	-- Return higest possible date, infinity = 31-12-999 23:59:59
	function c_infinity return date deterministic;
	-- --------------------------------------------------------------------------------------------
	-- Return systems interpretation of Rata Die epoch = 01 January 0001 00:00:00
	function c_RataDie return date deterministic;

	-- ---------------------------------------------------------------------------------------------
	-- Public, overloaded function to return the received argument value as a char, no matter what
	-- type the argument is: char, date, number, boolean
	function nvlc(pi_char in varchar2)   return varchar2 deterministic;
	function nvlc(pi_date in date)       return varchar2 deterministic;
	function nvlc(pi_number in number)   return varchar2 deterministic;
	function nvlc(pi_boolean in boolean) return varchar2 deterministic;
	-- ---------------------------------------------------------------------------------------------
	-- Function returning the argument value enclosed in single quotes or null
	function f_1q (pi_text in varchar2) return varchar2 deterministic;
	-- ---------------------------------------------------------------------------------------------
	-- Function returning the argument value enclosed in double quotes or null
	function f_2q (pi_text in varchar2) return varchar2 deterministic;
	-- ---------------------------------------------------------------------------------------------
	-- Function with the argument value stripped of all leading and trailing white space: space,
	-- tab, line feed, carriage return etc.
	function f_trimws (pi_text in varchar2) return varchar2 deterministic;
	-- -------------------------------------------------------------------------------------------------
	-- Overloaded public function which checks that two varchar values are equal and when both
	-- values are null this is regarded as equal (opposite of Oracle's standard NULL <> NULL).
	function f_isequal
		(pi_char1	in varchar2	:= null
		,pi_char2	in varchar2	:= null
		)
	return number	-- 1 means equal, 0 means not equal
	deterministic;
	-- -------------------------------------------------------------------------------------------------
	-- Overloaded public function which checks that two varchar values are equal and when both
	-- values are null this is regarded as equal (opposite of Oracle's standard NULL <> NULL).
	function f_isequal
		(pi_date1	in date	:= null
		,pi_date2	in date	:= null
		)
	return number	-- 1 means equal, 0 means not equal
	deterministic;
	-- -------------------------------------------------------------------------------------------------
	-- Overloaded public function which checks that two number values are equal and when both
	-- values are null this is regarded as equal (opposite of Oracle's standard NULL <> NULL).
	function f_isequal
		(pi_num1	in number	:= null
		,pi_num2	in number	:= null
		)
	return number	-- 1 means equal, 0 means not equal
	deterministic;
	-- ---------------------------------------------------------------------------------------------
	-- Public function returning proper text:
	-- 0 -> "No records"
	-- 1 -> "1 record"
	-- else -> "nnn records"
	function f_nr_of_items
		(pi_number		in	number
		,pi_singular	in	varchar2	:= NULL	-- defaults to "record"
		,pi_plural		in	varchar2	:= NULL	-- defaults to singular+s or "records"
		)
	return varchar2
	deterministic;
	-- ---------------------------------------------------------------------------------------------
	-- Procedure to increment the first argument input field, default increment = 1
	procedure incr
		(pio_num in out number
		,pi_incr in		number := null
		);
	-- ---------------------------------------------------------------------------------------------
	-- Procedure to decrement the input field, default decrement = 1
	procedure decr
		(pio_num in out number
		,pi_decr in		number := null
		);
	-- ---------------------------------------------------------------------------------------------
	-- Public function to get a part (or: "piece") from a string based on a given separator 
	--character rather then positions.
	-- pi_sep should be exactly 1 character long
	-- Examples:
	-- m2l.str_part(l_string,l_sep) -> returns the first string piece
	-- m2l.str_part(l_string,l_sep,2) -> returns the second string piece
	-- m2l.str_part(l_string,l_sep,5,9) -> returns the fifth through nineth pieces in one string 
	--	INCLUDING the pi_seps between
	function str_part
		(pi_string		in varchar2
		,pi_sep			in varchar2
		,pi_first		in number default null
		,pi_last		in number default null
		)
	return varchar2
	deterministic;

end gp;
/
create or replace package body gp
as
	-- =============================================================================================
	-- Package: GP = General Procedures
	-- HMO, 20210612 New
	-- ---------------------------------------------------------------------------------------------

	-- ---------------------------------------------------------------------------------------------
	-- public wrapper for the tedious dbms_output.put_line
	procedure prt (pi_text in varchar2)
	as
	begin
		dbms_output.put_line(pi_text);
	end prt;

	-- constants implemented as DETERMINISTIC so they can be used in DML statements
	function c_tab  return varchar2 deterministic as begin return chr(09); end;  -- an AscII TAB character
	function c_lf   return varchar2 deterministic as begin return chr(10); end;  -- an AscII line feed character
	function c_cr   return varchar2 deterministic as begin return chr(13); end;  -- an AscII carriage return character
	function c_nak  return varchar2 deterministic as begin return chr(21); end;  -- an AscII negative acknowledgement character
	function c_ack  return varchar2 deterministic as begin return chr(06); end;  -- an AscII (positive) acknowledgement character
	function c_fs   return varchar2 deterministic as begin return chr(28); end;  -- an AscII file separator character
	function c_rs   return varchar2 deterministic as begin return chr(30); end;  -- an AscII record separator character
	function c_us   return varchar2 deterministic as begin return chr(31); end;  -- an AscII unit separator character
	function c_etx  return varchar2 deterministic as begin return chr(03); end;  -- an AscII end of text character
	function c_eot  return varchar2 deterministic as begin return chr(04); end;  -- an AscII end of transmission character

	function c_amp  return varchar2 deterministic as begin return chr(38); end;  -- an AscII ampersand character
	function c_1q   return varchar2 deterministic as begin return chr(39); end;  -- an AscII single quote character
	function c_2q   return varchar2 deterministic as begin return chr(34); end;  -- an AscII double quote character

	-- ---------------------------------------------------------------------------------------------
	-- Public, overloaded function to return the received argument value as a char, no matter what
	-- type the argument is: char, date, number, boolean
	function nvlc(pi_char in varchar2)
	return varchar2
	deterministic
	as
	begin
		return coalesce(to_char(pi_char),'nill');
	end nvlc;
	-- overloaded function return the received datae as a character
	function nvlc(pi_date in date)
	return varchar2
	deterministic
	as
	begin
		return coalesce(to_char(pi_date,'dd-mm-yyyy') || nullif( ' ' || to_char(pi_date,'hh21:mi:ss'), ' 00:00:00'),'nill');
	end nvlc;
	-- overloaded function return the received number as a character
	function nvlc(pi_number in number)
	return varchar2
	deterministic
	as
	begin
		return coalesce(to_char(pi_number),'nill');
	end nvlc;
	-- overloaded function return the received boolean as a character
	function nvlc(pi_boolean in boolean)
	return varchar2
	deterministic
	as
	begin
		return case
				when pi_boolean is null then 'nill'
				when pi_boolean = true  then 'TRUE'
				else 'FALSE'
				end;
	end nvlc;

	-- ---------------------------------------------------------------------------------------------
	-- Function returning the argument value enclosed in single quotes or null
	function f_1q (pi_text in varchar2)
	return varchar2
	deterministic
	as
	begin
		if pi_text is null
		then
			return null;
		end if;
		return c_1q || pi_text || c_1q;
	end f_1q;
	-- ---------------------------------------------------------------------------------------------
	-- Function returning the argument value enclosed in double quotes or null
	function f_2q (pi_text in varchar2)
	return varchar2
	deterministic
	as
	begin
		if pi_text is null
		then
			return null;
		end if;
		return c_2q || pi_text || c_2q;
	end f_2q;
	-- ---------------------------------------------------------------------------------------------
	-- Function with the argument value stripped of all leading and trailing white space: space,
	-- tab, line feed, carriage return etc.
	function f_trimws (pi_text in varchar2)
	return varchar2
	deterministic
	as
	begin
		if pi_text is null
		then
			return null;
		end if;
		return regexp_replace(pi_text,'^\s*|\s*$');
	end f_trimws;

	-- --------------------------------------------------------------------------------------------
	-- Return a ridiculous/impossible character value to be used in comparissons with NULL, like:
	--	coalesce(char_A, gp.c_nullchar) = coalesce(char_B, gp.c_nullchar)
	-- --------------------------------------------------------------------------------------------
	function c_nullchar
	return varchar2
	deterministic
	is
	begin
		return chr(00);
	end c_nullchar;
	-- --------------------------------------------------------------------------------------------
	-- Return a ridiculous/impossible date value to be used in comparissons with NULL, like
	--   coalesce(date_A, gp.c_nulldate) = coalesce(date_B, gp.c_nulldate)
	-- --------------------------------------------------------------------------------------------
	function c_nulldate
	return date
	deterministic
	is
	begin
		return to_date('47120101BC000000', 'YYYYMMDDBCHH24MISS', 'NLS_DATE_LANGUAGE = AMERICAN');
	end c_nulldate;
	-- --------------------------------------------------------------------------------------------
	-- Return a ridiculous/impossible value to be used in comparissons with NULL, like
	-- 		coalesce(num_A, gp.c_nullnum) = coalesce(num_B, gp.c_nullnum)
	-- --------------------------------------------------------------------------------------------
	function c_nullnum
	return number
	deterministic
	is
	begin
		return power(10,40) - 1;
	end c_nullnum;

	-- --------------------------------------------------------------------------------------------
	-- Return higest possible date, infinity = 31-12-999 23:59:59
	-- --------------------------------------------------------------------------------------------
	function c_infinity
	return date
	deterministic
	is
	begin
		return to_date('99991231235959', 'yyyymmddhh24miss');
	end c_infinity;

	-- --------------------------------------------------------------------------------------------
	-- Return systems interpretation of Rata Die epoch = 01 January 0001 00:00:00
	-- --------------------------------------------------------------------------------------------
	function c_RataDie
	return date
	deterministic
	is
	begin
		return to_date('00010101000000', 'yyyymmddhh24miss');
	end c_RataDie;

-- -------------------------------------------------------------------------------------------------
-- Overloaded public function which checks that two varchar values are equal and when both
-- values are null this is regarded as equal (opposite of Oracle's standard NULL <> NULL).
	function f_isequal
		(pi_char1	in varchar2	:= null
		,pi_char2	in varchar2	:= null
		)
	return number	-- 1 means equal, 0 means not equal
	deterministic
	is
	begin
		if pi_char1 = pi_char2
		or	(	pi_char1 is null
			and pi_char2 is null
			)
		then
			return 1;
		else
			return 0;
		end if;
	end f_isequal;
-- -------------------------------------------------------------------------------------------------
-- Overloaded public function which checks that two varchar values are equal and when both
-- values are null this is regarded as equal (opposite of Oracle's standard NULL <> NULL).
	function f_isequal
		(pi_date1	in date	:= null
		,pi_date2	in date	:= null
		)
	return number	-- 1 means equal, 0 means not equal
	deterministic
	is
	begin
		if pi_date1 = pi_date2
		or	(	pi_date1 is null
			and pi_date2 is null
			)
		then
			return 1;
		else
			return 0;
		end if;
	end f_isequal;
-- -------------------------------------------------------------------------------------------------
-- Overloaded public function which checks that two number values are equal and when both
-- values are null this is regarded as equal (opposite of Oracle's standard NULL <> NULL).
	function f_isequal
		(pi_num1	in number	:= null
		,pi_num2	in number	:= null
		)
	return number	-- 1 means equal, 0 means not equal
	deterministic
	is
	begin
		if pi_num1 = pi_num2
		or	(	pi_num1 is null
			and pi_num2 is null
			)
		then
			return 1;
		else
			return 0;
		end if;
	end f_isequal;

	-- ---------------------------------------------------------------------------------------------
	-- Public function returning proper text:
	-- 0 -> "No records"
	-- 1 -> "1 record"
	-- else -> "nnn records"
	function f_nr_of_items
		(pi_number		in	number
		,pi_singular	in	varchar2	:= NULL	-- defaults to "record"
		,pi_plural		in	varchar2	:= NULL	-- defaults to singular+s or "records"
		)
	return varchar2
	deterministic
	as
		l_number 	number;
	begin
		l_number := nvl(pi_number,0);
		case l_number
			when 0 then return 'No '           || trim(coalesce(pi_plural,pi_singular||'s','records'));
			when 1 then return l_number || ' ' || trim(coalesce(pi_singular,'record'));
			else        return l_number || ' ' || trim(coalesce(pi_plural,pi_singular||'s','records'));
		end case;
	exception
		when others
		then
			return to_char(c_nak);
	end f_nr_of_items;

	-- ---------------------------------------------------------------------------------------------
	-- Procedure to increment the first argument input field, default increment = 1
	procedure incr
		(pio_num in out number
		,pi_incr in		number := null
		)
	is
	begin
		pio_num := coalesce(pio_num,0) + coalesce(pi_incr,1);
	end incr;

	-- ---------------------------------------------------------------------------------------------
	-- Procedure to decrement the input field, default decrement = 1
	procedure decr
		(pio_num in out number
		,pi_decr in		number := null
		)
	is
	begin
		pio_num := coalesce(pio_num,0) - coalesce(pi_decr,1);
	end decr;

	-- ---------------------------------------------------------------------------------------------
	-- Public function to get a part (or: "piece") from a string based on a given separator 
	--character rather then positions.
	-- pi_sep should be exactly 1 character long
	-- Examples:
	-- m2l.str_part(l_string,l_sep) -> returns the first string piece
	-- m2l.str_part(l_string,l_sep,2) -> returns the second string piece
	-- m2l.str_part(l_string,l_sep,5,9) -> returns the fifth through nineth pieces in one string 
	--	INCLUDING the pi_seps between
	function str_part
		(pi_string		in varchar2
		,pi_sep			in varchar2
		,pi_first		in number default null
		,pi_last		in number default null
		)
	return varchar2
	deterministic
	is
		l_output		varchar2(32767)	:= null;
		l_start			pls_integer;
		l_pos_occ1		pls_integer;
		l_pos_occ2		pls_integer;
		l_occ1			pls_integer;
		l_occ2			pls_integer;
		l_pos_from		pls_integer;
		l_pos_thru		pls_integer;
	begin
		if pi_string is null then return to_char(null); end if;

		l_start    := nvl( nullif(pi_first,0) ,1);
		l_occ2     := nvl( nullif(pi_last,0) ,l_start);

		l_occ1     := nullif ( (l_start - 1), 0);

		l_pos_occ1 := instr(pi_string, pi_sep, 1, l_occ1 );
		l_pos_occ2 := instr(pi_string, pi_sep, 1, l_occ2 );

		l_pos_from := case when l_occ1 is null then 1
					  else case when l_pos_occ1 = 0 then 4000
		                   else l_pos_occ1 + length(pi_sep)
		                   end
		              end;

		l_pos_thru := case when l_pos_occ2 = 0 then 4000
		              else l_pos_occ2
		              end - 1;

		l_output := substr(pi_string, l_pos_from, ( l_pos_thru - l_pos_from + 1 ) );
		return (l_output);
	end str_part;

end gp;
/
prompt *I: End of file hmo_pkg_gp.sql

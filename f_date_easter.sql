/* [HM7A9_20240512_120400] */
-- When is Christian Easter in a given Gregorian Calender year?
-- Algorithm as published in Nature, 1876 April 20, vol. 13, p. 487.
-- Implementation for Oracle PL/SQL by Herman Mol, 29-05-2012
function f_date_easter (p_year number )
return date
as
	li_p_year	integer;
	li_a		integer;
	li_b		integer;
	li_c		integer;
	li_d		integer;
	li_e		integer;
	li_f		integer;
	li_g		integer;
	li_h		integer;
	li_i		integer;
	li_k		integer;
	li_l		integer;
	li_m		integer;
	li_v_month	integer;
	li_p		integer;
	li_v_day	integer;
	ld_easter	date;

begin

		li_p_year := p_year;

		li_a := mod(li_p_year, 19);
		li_b := trunc(li_p_year / 100);
		li_c := mod(li_p_year, 100);
		li_d := trunc(li_b / 4);
		li_e := mod(li_b, 4);
		li_f := trunc(( li_b + 8) / 25);
		li_g := trunc(( li_b - li_f + 1 ) / 3);
		li_h := mod(( (19 * li_a) + li_b - li_d - li_g + 15 ), 30);
		li_i := trunc(li_c / 4);
		li_k := mod(li_c, 4);
		li_l := mod(( 32 + (2 * li_e) + (2 * li_i) - li_h - li_k ), 7);
		li_m := trunc(( li_a + (11 * li_h) + (22 * li_l) ) / 451);
		li_v_month := trunc(( li_h + li_l - (7 * li_m) + 114 ) / 31);
		li_p := mod(( li_h + li_l - (7 * li_m) + 114 ), 31);
		li_v_day := trunc(li_p + 1);
		ld_easter := to_date(to_char(li_v_day, 'fm00')
				|| '-' || to_char(li_v_month, 'fm00')
				|| '-' || to_char(li_p_year, 'fm0000')
			,'dd-mm-yyyy');

		-- dbms_output.put_line ('In ' || li_p_year || ' easter on '
		-- 	|| to_char(li_v_day, 'fm00')
		-- 	|| '-' || to_char(li_v_month, 'fm00')
		-- 	|| '-' || to_char(li_p_year, 'fm0000')
		-- 	|| '; Ash Wednesday on ' || to_char(ld_easter - 46, 'day dd-mm-yyyy') );
		-- Ash Wednesday - 46
		-- Ascension Day + 39
		-- Whitsun + 49

	return ld_easter;

end f_date_easter;
-- Determine the date of Easter of each year
-- Arguments:
-- startyear = first year to calculate the dates for. 4 digits like 2019
-- years = the number of years to calculate the dates for. Any number
with parms as
	(	select :startyear + level -1 as the_year
		from dual 
		connect by level <= :years
	)
,formats as
	(	select 'dy dd-mon-yyyy' as date_format
			,'nls_date_language = AMERICAN' as date_language
		from dual
	)
,easter_dates as
(	-- this is the core: calculate the date of Easter in any year (Algorithm as published in Nature, 1876 April 20, vol. 13, p. 487. Implementation for Oracle by Herman Mol, 29MAR2016)
	select to_date(to_char(trunc(mod(( mod(( (19 * mod(the_year, 19)) + trunc(the_year / 100) - trunc(trunc(the_year / 100) / 4) - trunc(( trunc(the_year / 100) - trunc(( trunc(the_year / 100) + 8) / 25) + 1 ) / 3) + 15 ), 30) + mod(( 32 + (2 * mod(trunc(the_year / 100), 4)) + (2 * trunc(mod(the_year, 100) / 4)) - mod(( (19 * mod(the_year, 19)) + trunc(the_year / 100) - trunc(trunc(the_year / 100) / 4) - trunc(( trunc(the_year / 100) - trunc(( trunc(the_year / 100) + 8) / 25) + 1 ) / 3) + 15 ), 30) - mod(mod(the_year, 100), 4) ), 7) - (7 * trunc(( mod(the_year, 19) + (11 * mod(( (19 * mod(the_year, 19)) + trunc(the_year / 100) - trunc(trunc(the_year / 100) / 4) - trunc(( trunc(the_year / 100) - trunc(( trunc(the_year / 100) + 8) / 25) + 1 ) / 3) + 15 ), 30)) + (22 * mod(( 32 + (2 * mod(trunc(the_year / 100), 4)) + (2 * trunc(mod(the_year, 100) / 4)) - mod(( (19 * mod(the_year, 19)) + trunc(the_year / 100) - trunc(trunc(the_year / 100) / 4) - trunc(( trunc(the_year / 100) - trunc(( trunc(the_year / 100) + 8) / 25) + 1 ) / 3) + 15 ), 30) - mod(mod(the_year, 100), 4) ), 7)) ) / 451)) + 114 ), 31) + 1), 'fm00')
				|| '-' || to_char(trunc(( mod(( (19 * mod(the_year, 19)) + trunc(the_year / 100) - trunc(trunc(the_year / 100) / 4) - trunc(( trunc(the_year / 100) - trunc(( trunc(the_year / 100) + 8) / 25) + 1 ) / 3) + 15 ), 30) + mod(( 32 + (2 * mod(trunc(the_year / 100), 4)) + (2 * trunc(mod(the_year, 100) / 4)) - mod(( (19 * mod(the_year, 19)) + trunc(the_year / 100) - trunc(trunc(the_year / 100) / 4) - trunc(( trunc(the_year / 100) - trunc(( trunc(the_year / 100) + 8) / 25) + 1 ) / 3) + 15 ), 30) - mod(mod(the_year, 100), 4) ), 7) - (7 * trunc(( mod(the_year, 19) + (11 * mod(( (19 * mod(the_year, 19)) + trunc(the_year / 100) - trunc(trunc(the_year / 100) / 4) - trunc(( trunc(the_year / 100) - trunc(( trunc(the_year / 100) + 8) / 25) + 1 ) / 3) + 15 ), 30)) + (22 * mod(( 32 + (2 * mod(trunc(the_year / 100), 4)) + (2 * trunc(mod(the_year, 100) / 4)) - mod(( (19 * mod(the_year, 19)) + trunc(the_year / 100) - trunc(trunc(the_year / 100) / 4) - trunc(( trunc(the_year / 100) - trunc(( trunc(the_year / 100) + 8) / 25) + 1 ) / 3) + 15 ), 30) - mod(mod(the_year, 100), 4) ), 7)) ) / 451)) + 114 ) / 31), 'fm00') 
				|| '-' || to_char(the_year, 'fm0000')
			,'dd-mm-yyyy') as date_easter
	from parms
)
select to_char(to_date( to_char(date_easter,'yyyy')||'0101','yyyymmdd'), date_format, date_language) as new_year
	,to_char(date_easter - 46, date_format, date_language) as ash_wednesday
	,to_char(date_easter, date_format, date_language) as easter
	,to_char(date_easter + 39, date_format, date_language) as ascension_day
	,to_char(date_easter + 49, date_format, date_language) as whitsun
	,to_char(to_date( to_char(date_easter,'yyyy')||'1225','yyyymmdd'), date_format, date_language) as Xmas_1st
	,to_char(to_date( to_char(date_easter,'yyyy')||'1226','yyyymmdd'), date_format, date_language) as Xmas_2nd
	,decode(sign(to_number(to_char(date_easter,'yyyy')) - 2013)
		,1, to_char(to_date( to_char(date_easter,'yyyy')||'0427','yyyymmdd'), date_format, date_language)
		,to_char(to_date( to_char(date_easter,'yyyy')||'0430','yyyymmdd'), date_format, date_language)
		) as kings_day
	,decode(mod(to_char(date_easter,'yyyy'),5)
		,0,to_char(to_date( to_char(date_easter,'yyyy')||'0505','yyyymmdd'), date_format, date_language)
		,'-')  as liberation_day
from easter_dates
	,formats
/

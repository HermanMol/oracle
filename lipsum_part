create or replace function kcs.get_lipsum_part (pi_type in varchar2, pi_nr in number)
return varchar2 deterministic
as
	-- Get a part of the Lipsum https://www.lipsum.com/feed/html 5 paragrahps.
	-- get_lipsum_part('P',3) returns the 3rd paragraph. Last=5.
	-- get_lipsum_part('S',61) returns the 61st sentence. Last=61.
	-- get_lipsum_part('W',90) returns the 34th word. Last=490.
	-- hhmo, 22/jul-2019
	l_rc varchar2(32767);
begin
	with lipsum as
	(	select 
'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin maximus est ut arcu volutpat mollis. Nulla nisl orci, semper convallis lacinia eu, malesuada sit amet justo. Sed consequat, lectus nec mollis ornare, ante sem viverra justo, eget pellentesque dolor elit id ligula. Etiam porttitor ex eget erat convallis finibus. Aenean fermentum ipsum finibus varius pretium. Maecenas vulputate, nibh vel posuere aliquam, ligula dui varius mauris, quis vestibulum orci tortor eget nunc. Praesent quis sodales ipsum. Nulla ac molestie urna, vestibulum venenatis eros. Suspendisse ultrices condimentum maximus. Pellentesque maximus, arcu vel tristique commodo, erat sem mattis quam, ut imperdiet dui tellus ac augue. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Praesent dictum in quam vel iaculis. Fusce et porttitor felis, in laoreet tortor. Donec viverra tellus vel ultricies gravida. Sed dignissim maximus nisl, nec malesuada neque iaculis eget.'
|| chr(10)	
|| 'Curabitur convallis arcu sit amet sapien dictum, rutrum dictum nulla fringilla. Etiam sit amet libero lorem. Nunc sollicitudin elit eu lacus tincidunt semper. Integer euismod in ipsum eu consectetur. Donec id quam vestibulum, commodo elit eget, volutpat nunc. Sed pharetra lorem ut consequat facilisis. Donec lobortis semper nunc, ac congue ex sagittis non.'
|| chr(10)	
|| 'Nulla non ligula diam. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Vivamus placerat mauris ac dui tincidunt consectetur. Sed in pretium nisl, in finibus magna. Mauris placerat molestie ligula, nec consequat neque dapibus id. Suspendisse potenti. Interdum et malesuada fames ac ante ipsum primis in faucibus. Quisque at lacus quis magna elementum consequat a vel sapien. Praesent ante risus, dignissim ac dignissim sed, imperdiet id massa. Ut imperdiet dolor quis fermentum imperdiet. Ut tristique euismod sagittis. Cras rhoncus erat vitae lacus scelerisque elementum.'
|| chr(10)	
|| 'Donec ut finibus odio, et gravida sem. Nam non nibh libero. Maecenas a justo ullamcorper felis semper eleifend. Donec orci tellus, vehicula vel molestie ut, vestibulum nec leo. Integer vitae bibendum leo, ut rhoncus magna. Mauris magna mauris, lacinia vel lectus sit amet, accumsan elementum nunc. Ut erat ipsum, consectetur vel porta in, lobortis eu risus. Quisque scelerisque ex non eros sagittis pharetra. Aenean at neque ac erat scelerisque iaculis id in nisl. Suspendisse potenti. Mauris orci urna, bibendum venenatis sodales a, sodales eget massa. In hac habitasse platea dictumst.'
|| chr(10)	
|| 'Phasellus porttitor hendrerit porta. Nam at ante eu justo pulvinar tincidunt. Nullam arcu nisi, suscipit et felis at, egestas iaculis leo. Nam volutpat lectus eget enim convallis, vitae molestie massa convallis. Sed pellentesque, mauris non mollis tincidunt, sem diam pulvinar mi, id ullamcorper dolor felis ac leo. Phasellus ex leo, tempor at placerat non, mattis nec ligula. Nam vestibulum vehicula odio eu commodo. Maecenas augue turpis, consectetur ac nunc sit amet, finibus hendrerit ante. Nam eget quam interdum, porta nibh ac, vehicula justo. Nulla facilisi. Aliquam erat volutpat. Morbi dui ligula, ullamcorper non nibh vel, consequat elementum urna. Cras sed finibus augue. Aenean dictum auctor congue. Nam elementum pharetra dui, nec bibendum ante dignissim vitae.'
|| chr(10)	
	as txt
		,'^('||'[['||chr(58)||'print'||chr(58)||']]+)$' as rx_paragraph
		,'([^.]+)' as rx_sentence
		,'(\w+)' as rx_word
		,'^\s*|\s*$' as rx_whitespace
	from dual
	)
	select case upper(substr(pi_type,1,1))
		when 'S' then nullif(regexp_replace(regexp_substr(txt,rx_sentence,1,pi_nr,'im',1),rx_whitespace)||'.','.')
		when 'P' then regexp_substr(txt,rx_paragraph,1,pi_nr,'im',1)
		else regexp_substr(txt,rx_word,1,pi_nr,'im',1)
		end as retval
		--,rx_paragraph
		--,rx_sentence
		--,rx_word
		--,rx_whitespace
		--,txt
	into l_rc
	from lipsum;
	
	return l_rc;

/* The text above in sentences:

01 Lorem ipsum dolor sit amet, consectetur adipiscing elit.
02 Proin maximus est ut arcu volutpat mollis.
03 Nulla nisl orci, semper convallis lacinia eu, malesuada sit amet justo.
04 Sed consequat, lectus nec mollis ornare, ante sem viverra justo, eget pellentesque dolor elit id ligula.
05 Etiam porttitor ex eget erat convallis finibus.
06 Aenean fermentum ipsum finibus varius pretium.
07 Maecenas vulputate, nibh vel posuere aliquam, ligula dui varius mauris, quis vestibulum orci tortor eget nunc.
08 Praesent quis sodales ipsum.
09 Nulla ac molestie urna, vestibulum venenatis eros.
10 Suspendisse ultrices condimentum maximus.
11 Pellentesque maximus, arcu vel tristique commodo, erat sem mattis quam, ut imperdiet dui tellus ac augue.
12 Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.
13 Praesent dictum in quam vel iaculis.
14 Fusce et porttitor felis, in laoreet tortor.
15 Donec viverra tellus vel ultricies gravida.
16 Sed dignissim maximus nisl, nec malesuada neque iaculis eget.


17 Curabitur convallis arcu sit amet sapien dictum, rutrum dictum nulla fringilla.
18 Etiam sit amet libero lorem.
19 Nunc sollicitudin elit eu lacus tincidunt semper.
20 Integer euismod in ipsum eu consectetur.
21 Donec id quam vestibulum, commodo elit eget, volutpat nunc.
22 Sed pharetra lorem ut consequat facilisis.
23 Donec lobortis semper nunc, ac congue ex sagittis non.


24 Nulla non ligula diam.
25 Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Vivamus placerat mauris ac dui tincidunt consectetur.
26 Sed in pretium nisl, in finibus magna.
27 Mauris placerat molestie ligula, nec consequat neque dapibus id.
28 Suspendisse potenti.
29 Interdum et malesuada fames ac ante ipsum primis in faucibus.
30 Quisque at lacus quis magna elementum consequat a vel sapien.
31 Praesent ante risus, dignissim ac dignissim sed, imperdiet id massa.
32 Ut imperdiet dolor quis fermentum imperdiet.
33 Ut tristique euismod sagittis.
34 Cras rhoncus erat vitae lacus scelerisque elementum.


35 Donec ut finibus odio, et gravida sem.
36 Nam non nibh libero.
37 Maecenas a justo ullamcorper felis semper eleifend.
38 Donec orci tellus, vehicula vel molestie ut, vestibulum nec leo.
39 Integer vitae bibendum leo, ut rhoncus magna.
40 Mauris magna mauris, lacinia vel lectus sit amet, accumsan elementum nunc.
41 Ut erat ipsum, consectetur vel porta in, lobortis eu risus.
42 Quisque scelerisque ex non eros sagittis pharetra.
43 Aenean at neque ac erat scelerisque iaculis id in nisl.
44 Suspendisse potenti.
45 Mauris orci urna, bibendum venenatis sodales a, sodales eget massa.
46 In hac habitasse platea dictumst.


47 Phasellus porttitor hendrerit porta.
48 Nam at ante eu justo pulvinar tincidunt.
49 Nullam arcu nisi, suscipit et felis at, egestas iaculis leo.
50 Nam volutpat lectus eget enim convallis, vitae molestie massa convallis.
51 Sed pellentesque, mauris non mollis tincidunt, sem diam pulvinar mi, id ullamcorper dolor felis ac leo.
52 Phasellus ex leo, tempor at placerat non, mattis nec ligula.
53 Nam vestibulum vehicula odio eu commodo.
54 Maecenas augue turpis, consectetur ac nunc sit amet, finibus hendrerit ante.
55 Nam eget quam interdum, porta nibh ac, vehicula justo.
56 Nulla facilisi.
57 Aliquam erat volutpat.
58 Morbi dui ligula, ullamcorper non nibh vel, consequat elementum urna.
59 Cras sed finibus augue.
60 Aenean dictum auctor congue.
61 Nam elementum pharetra dui, nec bibendum ante dignissim vitae.

*/
end get_lipsum_part;
/
grant execute on kcs.get_lipsum_part to public
/
-- testing
with testcases as
(
	select 'p' as sel_type, 1 as sel_nr from dual
	union all
	select 'p' as sel_type, 2 as sel_nr from dual
	union all
	select 'p' as sel_type, 3 as sel_nr from dual
	union all
	select 'p' as sel_type, 4 as sel_nr from dual
	union all
	select 'p' as sel_type, 5 as sel_nr from dual
	union all
	select 'p' as sel_type, 6 as sel_nr from dual
	union all
	select 's' as sel_type, 1 as sel_nr from dual
	union all
	select 's' as sel_type, 2 as sel_nr from dual
	union all
	select 's' as sel_type, 61 as sel_nr from dual
	union all
	select 's' as sel_type, 62 as sel_nr from dual
	union all
	select 'w' as sel_type, 1 as sel_nr from dual
	union all
	select 'w' as sel_type, 2 as sel_nr from dual
	union all
	select 'w' as sel_type, 490 as sel_nr from dual
	union all
	select 'w' as sel_type, 491 as sel_nr from dual
)
select sel_type
	,sel_nr
	,nullif('>' || kcs.get_lipsum_part(sel_type,sel_nr) || '<' ,'><') as lipsum_part
from testcases

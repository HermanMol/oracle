-- This script shows how to selectively rollback DML in a loop using the SAVEPOINT
-- (Required sample DDL at bottom of script)
-- HHMO, 20191106

-- For simplicity the actual functionality is here one single update. Such a simple DML can also
-- be captured with a proper begin-exception-end construction. But when more DML is executed you
-- may use this SAVEPOINT idea.

-- let us assume some initial situation with already some DML pending
update admhmo.table1
set val01 = chr(64 + pk)
	,val02 = 10 * pk
	;

<<savepoint_example>>
begin

	-- we want to preserve anything that happened before the next loop processing
	savepoint process_all_rows;

	<<loop_all_records>>
	for r_data in
		(
			select *
			from admhmo.table1
		)
	loop
		<<do_one_record>>
		begin
			-- Re-issuing a savepoint with the same name again just moves the existing
			-- savepoint. With this construction you can process each record and
			-- based upon some condition (or exception) you can either rollback the
			-- dml that was performed since the last savepoint statement, or continue
			-- with the next row.
			-- After the loop has ended, all succesful processed rows will be committed
			-- and the non-successful processed rows have been rolled-back.
			savepoint this_record;

			-- Perform the required action/functionality.
			update admhmo.table1
			set val02 = val02 / (r_data.pk * mod(r_data.pk,2))	-- every even PK a "ZERO_DIVIDE" will occur :-)
			where pk = r_data.pk;

		exception
			when ZERO_DIVIDE
			then
				-- roll back the updates for this row ...
				rollback to savepoint this_record;
				-- ... but still put some message in the failed record :-)
				update admhmo.table1
				set val01 = 'Oops, zero devide!'
				where pk = r_data.pk;
		end do_one_record;

	end loop loop_all_records;

	-- make it permanent
	commit;

exception
	when others
	then
		rollback to savepoint process_all_rows;
		-- ... perform whatever you want with the same data as before this SAVEPOINT_EXAMPLE PL/SQL block was started
end savepoint_example;
/
/*
  CREATE TABLE "ADMHMO"."TABLE1"
   (	"PK" NUMBER,
	"VAL01" VARCHAR2(100),
	"VAL02" NUMBER
   ) ;

REM INSERTING into ADMHMO.TABLE1
SET DEFINE OFF;
Insert into ADMHMO.TABLE1 (PK,VAL01,VAL02) values ('1','A','1');
Insert into ADMHMO.TABLE1 (PK,VAL01,VAL02) values ('2','B','3');
Insert into ADMHMO.TABLE1 (PK,VAL01,VAL02) values ('3','C','3');
Insert into ADMHMO.TABLE1 (PK,VAL01,VAL02) values ('4','D','5');
Insert into ADMHMO.TABLE1 (PK,VAL01,VAL02) values ('5','E','5');
Insert into ADMHMO.TABLE1 (PK,VAL01,VAL02) values ('6','F','7');
Insert into ADMHMO.TABLE1 (PK,VAL01,VAL02) values ('7','G','7');

commit;

	update admhmo.table1
	set val01 = chr(64 + pk)
		,val02 = 10 * pk
		;

*/
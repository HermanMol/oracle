      -- ---------------------------------------------------------------------------------------------
      -- Private function that returns the object name and line number where the function that called
      -- this invoked_from was invoked from. So this is ONLY for use in this package!!
      -- Output: object_name[object_linenr]
      -- Example of expected output of dbms_utility.format_call_stack():
      /*
      ----- PL/SQL Call Stack -----
  object      line  object
  handle    number  name
0x1fb752238       199  SRG.TR_LBS_PFC_DATA_CPD
0x20b3c8408       205  function SRG.GET_PROJECT
0x20b3c9808       430  package body SRG.F_INTEGRATION
0x20b2bc5f0        39  SRG.P_MACNAC_BI
0x21e35e6f8       444  package body SRG.LBS_PFC_IMPORT
0x1fb752238       199  SRG.TR_LBS_PFC_DATA_CPD
0x21e35e6f8      1202  package body SRG.LBS_PFC_IMPORT
0x21e35e6f8      1365  package body SRG.LBS_PFC_IMPORT
0x21e35e6f8      1869  package body SRG.LBS_PFC_IMPORT
0x1fbfe6708        29  anonymous block
      */
      function invoked_from
      return varchar2
      as
            l_call_stack_line3      varchar2(200);
            l_object_name           varchar2(100);
            l_object_line           varchar2(100);
            l_invoked_from          varchar2(200);
      begin
            -- If you have to debug uncomment this line: some_logging(dbms_utility.format_call_stack(),'D','*INVOKED_FROM*');
            -- The first line will be the location of the call of this invoked_from function.
            -- The second line will be the location of the call of the log method in this package that calls this invoked_from function.
            -- So we must get the third line: hence the "3" in the next regexp_substr :-)
            l_call_stack_line3 := regexp_substr(dbms_utility.format_call_stack(),'^0x[0-9a-f]{1,}([[:print:]]+)',1,3,'im',1);
            l_object_name := regexp_substr(l_call_stack_line3,'(\S+)$',1,1,null,1);
            l_object_line := regexp_substr(l_call_stack_line3,'([0-9]+)',1,1,null,1);
            if lower(l_object_name) = 'block'
            then
                  l_object_name := 'anonymous block';
            end if;
            l_invoked_from := l_object_name || '[' || l_object_line || ']';
            return l_invoked_from;
      end invoked_from;
/

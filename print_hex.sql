      -- ---------------------------------------------------------------------------------------------
      -- Public function that returns the received string in hex format, like
      --    srg.z_util.printhex(dbms_utility.dbms_utility.format_call_stack());
      -- giving...:
      --    0001: 2d 2d 2d 2d 2d 20 50 4c 2f 53 51 4c 20 43 61 6c = ----- PL/SQL Cal
      --    0017: 6c 20 53 74 61 63 6b 20 2d 2d 2d 2d 2d 0a 20 20 = l Stack -----·  
      --    0033: 6f 62 6a 65 63 74 20 20 20 20 20 20 6c 69 6e 65 = object      line
      --    ... etc
      -- The input may be maximum 8000 character long.
      -- The output uses LF chr(10) as line separator.
      function printhex(pi_text in varchar2)
      return varchar2
      deterministic
      as
            l_output    varchar2(32767);
            idx               number;
      begin
            if pi_text is null
            then
                  return to_char(null);
            end if;
            if length(pi_text) > 8000 / 4
            then
                  raise_application_error(-20001, 'Error in function PRINTHEX: input too long. Maximum is 8000, actual is ' || length(pi_text), true);
            end if;
            for i in 1..length(pi_text)
            loop
                  idx := i;
                  if mod(i,16) = 1
                  then
                        -- insert the offset of the first character printed
                        l_output := l_output || trim(to_char(i,'0000')) || ':';
                  end if;
                  -- add the hex value of the character
                  l_output := l_output || ' ' || trim(to_char(ascii(substr(pi_text,i,1)),'0x'));
                  if mod(i,16) = 0
                  then
                        -- add the text of the past 16 characters, but remove control characters
                        l_output := l_output || ' = ' || regexp_replace(substr(pi_text,( ( ( trunc(i / 16) - 1 ) * 16 ) + 1 ),16),'[^[:print:]]',chr(183),1,0) || chr(10);
                  end if;
            end loop;
            l_output := l_output || rpad('<', ( ( ( 16 * ceil ( idx / 16 ) ) - idx ) * 3),' ');
            l_output := l_output || ' = ' || regexp_replace(substr(pi_text,( 16 * floor(idx / 16) + 1 ) ) ,'[^[:print:]]',chr(183),1,0) || chr(10);
            return l_output;
      end printhex;

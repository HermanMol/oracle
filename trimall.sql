-- ================================================================================================
-- This TRIMALL removes ALL leading and trailing whitespace
  function trimall (p_string varchar2) 
  return varchar2
  deterministic;

  
-- ================================================================================================
-- This TRIMALL removes ALL leading and trailing whitespace
  function trimall (p_string varchar2) 
  return varchar2
  deterministic
  as
  begin
                return regexp_replace(p_string,'^\s*|\s*$');
  end;

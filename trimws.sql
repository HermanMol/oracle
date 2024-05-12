/* [HM7A9_20240512_120400] */
-- -------------------------------------------------------------------------------------------------
-- This trimws removes ALL leading and trailing whitespace: space, tab, cr, lf
    function trimws (p_string varchar2) 
    return varchar2
    deterministic;

-- -------------------------------------------------------------------------------------------------
-- This trimws removes ALL leading and trailing whitespace: space, tab, cr, lf
    function trimws (p_string varchar2) 
    return varchar2
    deterministic
    as
    begin
        return regexp_replace(p_string,'^\s*|\s*$');
    end trimws;

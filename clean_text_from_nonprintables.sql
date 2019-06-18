select f_seq
      ,f_text 
      -- remove all characters not in ASCII range space-tilde
      ,regexp_replace(f_text, '[^\x20-\x7e]*','',1,1,'i') as clean
from x_file where f_seq > 393665 order by f_seq
/

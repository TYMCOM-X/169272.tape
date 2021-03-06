
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)


(*       This program attempts to read from a file of 'rec' which
        has been 'rewrite'-ed. It should fail.
*)
program sui332;
const str_val : array[io_status] of string := ('io_ok',',io_novf',
        'io_povf', 'io_dgit', 'io_govf', 'io_intr', 'io_rewr',
        'io_eof', 'io_outf', 'io_inpf', 'io_seek', 'io_illc',
        'io_nepf', 'io_opnf');

type rec = record
        int : integer;
        rea : real;
        boo : boolean
     end;       
var f : file of rec;
    i : rec;
        
begin
        rewrite(output,'suite.txt',[preserve]);

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

        rewrite(f,'tmpfil:',[retry]);
        read(f,i);
        if iostatus(f) = io_eof then
                writeln('sui332 conforms')
        else
                writeln('sui332 deviates (read after rewrite)',
                        ' iostatus = ',str_val[iostatus(f)])
end.    

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

 
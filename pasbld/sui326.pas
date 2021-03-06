
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(*       This program attempts to rewrite a text without a filename.
        It should succeed. If it succeeds it prints the default
        filename via the 'filename' function.
*)
program sui326;

const str_val : array[io_status] of string := ('io_ok',',io_novf',
        'io_povf', 'io_dgit', 'io_govf', 'io_intr', 'io_rewr',
        'io_eof', 'io_outf', 'io_inpf', 'io_seek', 'io_illc',
        'io_nepf', 'io_opnf');
var f : text;

begin
        rewrite(output,'suite.txt',[preserve]);
        rewrite(f);
        if iostatus(f) <> io_ok then
                        writeln('deviates: sui326 iostatus = ',
                                str_val[iostatus(f)])
        else
                writeln('conforms: sui326 (default filename for ''f'' = ',

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

                        filename(f),')')
end.
 
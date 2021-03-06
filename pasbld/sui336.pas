
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(*       This program attemts to write to a text file which has been
        'reset'.  It should fail.
*)
program sui336;

var f : text;
    i : integer := 0;
        
begin
        rewrite(output,'suite.txt',[preserve]);
        rewrite(f,'tmpfil:');   (*generate a file to reset*)
        reset(f,'tmpfil:',[retry]);
        write(f,i);
        if iostatus(f) <> io_ok then
                writeln('sui336 conforms')
        else
                writeln('sui336 deviates (write after reset)')
end.    

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

 
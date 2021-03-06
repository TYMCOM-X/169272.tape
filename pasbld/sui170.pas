
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 170*)
(*TEST 6.6.5.2-3, CLASS=CONFORMANCE*)
(* This program tests if true is assigned to eof if the file f
  is empty when reset. *)
program t6p6p5p2d3;
var
   fyle : text;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #170');
   reset(fyle);
   if eof(fyle) then
      writeln(' PASS...6.6.5.2-3')
   else
      writeln(' FAIL...6.6.5.2-3')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

 

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 114*)
(*TEST 6.4.5-10, CLASS=DEVIANCE*)
(* Some implementations may have an implicit ordering
  between different types, and allow these to be compared etc.,
  thus not conforming to the compatibility rules of the Pascal
  Standard.
  The compiler conforms if the program does not compile, or
  fails to run. *)
program t6p4p5d10;
var
   colour : (red,green,blue);
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #114');
   if red < 0 then writeln(' DEVIATES...6.4.5-10')
              else writeln(' DEVIATES...6.4.5-10')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

 
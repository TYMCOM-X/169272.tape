
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 245*)
(*TEST 6.8.3.5-5, CLASS=ERRORHANDLING*)
(* This test checks the type of error produced when the case
  statement does not contain a constant of the selected value.
  An execution error should be produced. *)
program t6p8p3p5d5;
var
   i:integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #245');
   i:=0;
   case i of
   -3,3: writeln(' FAIL...6.8.3.5-5, CASE');
   end;
   writeln(' ERROR NOT DETECTED...6.8.3.5-5, CASE CONSTANT');
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

    
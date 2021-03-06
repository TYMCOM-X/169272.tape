
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 244*)
(*TEST 6.8.3.5-4, CLASS=CONFORMANCE*)
(* This test checks that a compiler handles a sparse case adequately
  Most compilers issue a jump table for a case, regardless
  of its structure. It is easy to optimise case statements
  to generate conditional statements if this is more compact.
  The compiler fails if the program does not compile
  or the program fails in execution. *)
program t6p8p3p5d4;
var
   i,j:integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #244');
   i:=-1000;
   for j:=1 to 2 do
      case i of
      -1000: i:=-i;
      1000: writeln(' PASS...6.8.3.5-4, SPARSE CASE');
      end;
end.
    
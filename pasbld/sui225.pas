
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 225*)
(*TEST 6.7.2.3-4, CLASS=DEVIANCE*)
(* Are logical operators allowed  to be performed on integers?
  The compiler deviates if the program compiles and prints
  DEVIATES. *)
program t6p7p2p3d4;
var
  i,j:integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #225');
   i:=1; j:=2;
   i:=i and j;
   i:=i and 1;
   i:= i or j;
   i:=i or j;
   i:= not j;
   writeln(' DEVIATES...6.7.2.3-4, LOGICAL OPS.')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

 
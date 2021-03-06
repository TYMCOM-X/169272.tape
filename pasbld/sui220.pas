
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 220*)
(*TEST 6.7.2.2-8, CLASS=ERRORHANDLING*)
(* This program causes an error to occur as the second operand
  of the MOD operator is 0.
  The error should be detected at run-time. *)
program t6p7p2p2d8;
var
   i, j, k : integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #220');
   i:=6;
   j:=0;
   k:=i mod j;       (* an error as j=0 *)
   writeln(' ERROR NOT DETECTED...6.7.2.2-8: MOD ZERO')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

  

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 206*)
(*TEST 6.6.6.4-6, CLASS=DEVIANCE*)
(* This test checks that succ and pred cannot be applied to
  real values. The compiler deviates if the program compiler
  and prints DEVIATES. *)
program t6p6p6p4d6;
var
   x:real;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #206');
   x:=0.3;
   if (succ(x)>x) and (pred(x)<x) then
      writeln(' DEVIATES...6.6.6.4-6, REAL SUCC/PRED')
   else
      writeln(' DEVIATES...6.6.6.4-6, MESS')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

  
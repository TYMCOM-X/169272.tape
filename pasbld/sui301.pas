
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 301*)
(*TEST 6.9.4-8, CLASS=DEVIANCE*)
(* This program attempts to output an integer number using a real
  format. The compiler deviates if the program prints DEVIATES. *)
program t6p9p4d8;
var
   i:integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #301');
   i:=123;
   writeln(i:6:1);
   writeln(' DEVIATES...6.9.4-8, WRITE');
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

 

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  19*)
(*TEST 6.1.7-4, CLASS=DEVIANCE*)
(* This program tests that strings of different lengths are
  not compatible (i.e. 1..m and 1..n).
  The compiler fails if the program compiles. *)
program t6p1p7d4;
const
   string1 = 'STRING1';
var
   string2 : packed array[1..5] of char;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #019');
   string2:=string1;
   writeln(' DEVIATES...6.1.7-4')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

    

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 271*)
(*TEST 6.8.3.9-12, CLASS=DEVIATES*)
(* This test checks whether a for statement control variable
  can be a pointer variable.
  The compiler deviates if the program compiles and prints
  DEVIATES. *)
program t6p8p3p9d12;
type
   int = ^integer;
var
   ptr:int;
   j:integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #271');
   j:=0;
   new(ptr);
   for ptr^ := 0 to 10 do
      j:=j+1;
   writeln(' DEVIATES...6.8.3.9-12, FOR');
end.
    
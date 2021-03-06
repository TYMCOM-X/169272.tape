
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 270*)
(*TEST 6.8.3.9-11, CLASS=DEVIANCE*)
(* This test checks whether a for statement control variable
  can be a component variable.
  The compiler deviates if the program compiles and prints
  DEVIATES. *)
program t6p8p3p9d11;
var
   rec:record
         i,j:integer;
       end;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #270');
   for rec.i:=0 to 10 do
      rec.j := rec.i;
   with rec do
      for i := 0 to 10 do
         j:=i;
   writeln(' DEVIATES...6.8.3.9-11, FOR');
end.
   
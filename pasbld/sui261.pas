
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 261*)
(*TEST 6.8.3.9-2, CLASS=DEVIANCE*)
(* This program checks that an assignment cannot be made to a
  for statement control variable.
  The compiler deviates if the program compiles and prints
  DEVIATES. *)
program t6p8p3p9d2;
var
  i,j:integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #261');
   j:=0;
   for i:=1 to 10 do
   begin
      j:=j+1;
      i:=i+1;
      writeln(j,i);
   end;
   writeln(' DEVIATES...6.8.3.9-2, FOR');
end.
   

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 237*)
(*TEST 6.8.2.4-2, CLASS=DEVIANCE*)
(* This test checks whether jumps between branches of an if
  statement are allowed.
  The compiler deviates if the program compiles and the
  program prints DEVIATES. *)
program t6p8p2p4d2;
label
   1,2;
var
   i:integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #237');
   i:=5;
   if (i<10) then
      goto 1
   else
      1:writeln(' DEVIATES...6.8.2.4-2');
   if (i>10) then
      2: writeln(' DEVIATES...6.8.2.4-2')

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   else
     goto 2;
end.
 
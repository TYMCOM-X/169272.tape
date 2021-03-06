
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 250*)
(*TEST 6.8.3.5-10, CLASS=DEVIANCE*)
(* This test checks that the compiler detects real case constants
  and a real case index, even when the values are integers.
  The compiler fails if the program compiles and the program
  prints FAILS. *)
program t6p8p3p5d10;
var
   i,counter:integer;
   r:real;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #250');
   counter:= 0;
   for i:= 1 to 4 do
   begin
      r:=i;
      case r of
      1.0: counter:=counter+1;
      2.0: counter:=counter+1;
      3.0: counter:=counter+1;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

      4e0: counter:=counter+1;
      end;
   end;
   if counter=4 then
      writeln(' DEVIANCE...6.8.3.5-10, CASE CONSTANTS')
   else
      writeln(' FAILS...6.8.3.5-10, CASE CONSTANTS');
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   
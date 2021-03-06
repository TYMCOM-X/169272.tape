
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 254*)
(*TEST 6.8.3.5-14, CLASS=EXTENSION, SUBCLASS=CONFORMANCE*)
(* This test checks whether an otherwise clause in a case statement
  is accepted. The convention is that adopted at the UCSD Pascal
  workshop in July 1978. The extension is accepted if the program
  compiles and prints EXTENSION - PASS *)
program t6p8p3p5d14;
var
   i,j,k,counter:integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #254');
   counter:=0;
   for i:=0 to 10 do
      case i of
      1,3,5,7,9:
         counter:=counter+1;
      otherwise
         j:=counter;
         k:=j;
      end;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   if (counter = 5) then
      writeln(' EXTENSION - PASS...6.8.3.5-14, OTHERWISE')
   else
      writeln(' EXTENSION - FAIL...6.8.3.5-14, OTHERWISE');
end.
    
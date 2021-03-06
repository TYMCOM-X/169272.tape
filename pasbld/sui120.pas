
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 120*)
(*TEST 6.4.6-3, CLASS=CONFORMANCE*)
(* This program tests a part of 6.5.2.1, that states that an index
  expression is assignment compatible with the index type
  specified in the definition of the array type.
  The compiler fails if the program does not compile. *)
program t6p4p6d3;
type
   colour = (red,pink,orange,yellow,green);
   intensity = (bright,dull);
var
   array1 : array[yellow..green] of boolean;
   array2 : array[colour] of intensity;
   array3 : array[1..99] of integer;
   colour1 : red..yellow;
   i      : integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #120');
   array1[yellow]:=true;
   colour1:=yellow;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   array1[colour1]:=false;
   array2[colour1]:=bright;
   array3[1]:=0;
   i:=2;
   array3[i*3+2]:=1;
   writeln(' PASS...6.4.6-3')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

 

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 113*)
(*TEST 6.4.5-9, CLASS=CONFORMANCE*)
(* The Pascal Standard states that set types of compatible base-types
  are compatible. This program tests that this is so for this
  compiler.
  The compiler fails if the program does not compile. *)
program t6p4p5d9;
type
   colour = (red,pink,orange,yellow,green,blue,brown);
var
   set1 : set of red..orange;
   set2 : set of orange..brown;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #113');
   set1:=[orange];
   set2:=[orange];
   if set1=set2 then writeln(' PASS...6.4.5-9')
                else writeln(' FAIL...6.4.5-9')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

    
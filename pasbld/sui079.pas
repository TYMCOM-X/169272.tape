
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  79*)
(*TEST 6.4.3.2-5, CLASS=DEVIANCE*)
(* Strings must have a subrange of integers as an index type.
  The compiler deviates if this program compiles and
  prints DEVIATES. *)
program t6p4p3p2d5;
type
   colour = (red,blue,yellow,green);
   cl1 = blue..green;
var
   s:packed array[cl1] of char;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #079');
   s:='ABC';
   writeln(' DEVIATES...6.4.3.2-5, INDEX TYPE')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

    
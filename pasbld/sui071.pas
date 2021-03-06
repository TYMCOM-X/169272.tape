
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  71*)
(*TEST 6.4.2.4-3, CLASS=DEVIANCE*)
(* The Pascal Standard states that the first constant in a definition
  specifies the lower bound, which is less than or equal to the
  upper bound.
  This program tests the compilers' conformance to this point.
  The compiler conforms if both the cases are rejected. *)
program t6p4p2p4d3;
type
   mixedup = 100..0;
   reverse = 'Z'..'A';
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #071');
   writeln(' DEVIATES...6.4.2.4-3 : EMPTY SUBRANGES ALLOWED')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

 
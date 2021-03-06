
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  76*)
(*TEST 6.4.3.2-2, CLASS=DEVIANCE*)
(* The Pascal Standard states that an index-type must be an
  ordinal-type. This does not include REAL.
  This program tests if the compiler will allow real bounds. *)
program t6p4p3p2d2;
type
   reeltest = array[1.5..10.1] of real;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #076');
   writeln(' DEVIATES...6.4.3.2-2')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

  
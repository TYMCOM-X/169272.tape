
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  95*)
(*TEST 6.4.3.4-3, CLASS=DEVIANCE*)
(* The Pascal Standard states that the base-type of the range
  of a set must be an ordinal-type. This should eliminate sets with
  real and structured ranges. Some compilers may allow these and
  hence will deviate for those cases not flagged as errors. *)
program t6p4p3p4d3;
type
   legalset = set of 1..3;
   urray    = array[1..4] of integer;
   setone   = set of real;                  (* case 1 *)
   settwo   = set of record a : 0..3 end;   (* case 2 *)
   setthree = set of array[1..5] of real;   (* case 3 *)
   setfour  = set of urray;                 (* case 4 *)
   setfive  = set of legalset;              (* case 5 *)
   setsix   = set of set of 1..4;           (* case 6 *)
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #095');
   writeln(' DEVIATES...6.4.3.4-3')
end.
   
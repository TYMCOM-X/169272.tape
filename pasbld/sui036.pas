
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  36*)
(*TEST 6.2.1-5, CLASS=DEVIANCE*)
(* This program declares a label, but it is not sited
  nor referenced.  This is illegal, as each declared
  label must appear once (and only once) in the executable
  part of the program. *)
program t6p2p1d5;
label
   9;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #036');
   writeln(' DEVIATES...6.2.1-5')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

 
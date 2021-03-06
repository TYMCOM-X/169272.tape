
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  61*)
(*TEST 6.4.2.2-2, CLASS=CONFORMANCE*)
(* The Pascal Standard specifies that the values an integer may
  take are within the range -maxint..+maxint.
  This program checks this. *)
program t6p4p2p2d2;
type
   natural = 0..maximum(integer);
   whole = -maximum(integer)..+maximum(integer);
var
   i : natural;
   j : whole;
   k : integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #061');
   i:=maximum(integer);
   j:=-maximum(integer);
   k:=maximum(integer);
   writeln(' PASS...6.4.2.2-2')
end.
  
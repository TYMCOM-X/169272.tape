
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  42*)
(*TEST 6.2.2-2, CLASS=CONFORMANCE*)
(* The Pascal Standard allows a user to redefine a predefined name.
  This program tests whether this is allowed by this compiler. *)
program t6p2p2d2;
var
   true : boolean;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #042');
   true:=false;
   if true = false then
      writeln(' PASS...6.2.2-2')
   else
      writeln(' FAIL...6.2.2-2')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  35*)
(*TEST 6.2.1-4, CLASS=DEVIANCE*)
(* Checks to see that labels may not be given two sites
  in the executable part.  Since the label is not used
  in a goto this program is a stringent test. *)
program t6p2p1d4;
label
   9;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #035');
   9: write(' DEVIATES');
      if true <> false then
         9: writeln('...6.2.1-4')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   
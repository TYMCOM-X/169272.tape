
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  74*)
(*TEST 6.4.3.1-3, CLASS=CONFORMANCE*)
(* The Pascal Standard allows array, set, file and
  record types to be declared as PACKED.
  The program simply tests that all these are
  permitted.
  The compiler fails if the program will not compile. *)
program t6p4p3p1d3;
type
   urray    = packed array[1..10] of char;
   rekord   = packed record
                  bookcode : integer;
                  authorcode : integer;
              end;
   fyle     = packed file of urray;
   card     = (heart,diamond,spade,club);
   sett     = packed set of card;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #074');
   writeln(' PASS...6.4.3.1-3')

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

end.
    

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  17*)
(*TEST 6.1.7-2, CLASS=CONFORMANCE*)
(* The Pascal standard does not place an upper limit
  on the length of strings. This program tests if strings
  are permitted up to a length of 68 characters. The
  compiler fails if the program will not compile. *)
program t6p1p7d2;
type
   string1 = packed array[1..68] of char;
   string2 = packed array[1..33] of char;
var
   alpha : string1;
   i     : string2;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #017');
   alpha:=
'ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOP';
   i:='IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII';
   writeln(' PASS...6.1.7-2')
end.
    

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 112*)
(*TEST 6.4.5-8, CLASS=CONFORMANCE*)
(* The Pascal Standard states that string types with the same
  number of components are compatible.
  The compiler fails if the program does not compile. *)
program t6p4p5d8;
var
   string1 : packed array[1..4] of char;
   string2 : packed array[1..4] of char;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #112');
   string1:='ABCD';
   string2:='EFGH';
   if 'ABC' = 'ABC' then
      if string1 <> string2 then
         writeln(' PASS...6.4.5-8')
      else
         writeln(' FAIL...6.4.5-8')
   else
      writeln(' FAIL...6.4.5-8')

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

end.
  
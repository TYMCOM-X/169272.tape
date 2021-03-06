
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  18*)
(*TEST 6.1.7-3, CLASS=CONFORMANCE*)
(* The Pascal standard allows quotes to appear as char
  constants and permits them to appear in strings.
  If this is desired, they must be written twice.
  This program tests that the compiler will allow this.
  The compiler fails if the program will not compile. *)
program t6p1p7d3;
const
   quote = '''';
   strquote = 'CAN''T';
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #018');
   writeln(' PASS...6.1.7-3')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   
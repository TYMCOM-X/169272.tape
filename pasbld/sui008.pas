
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number   8*)
(*TEST 6.1.5-1, CLASS=CONFORMANCE*)
(* This program tests the conformance of the compiler to
  the syntax productions for numbers specified by the
  Pascal Standard.
  If all productions are permitted the program will
  print 'PASS'. The compiler fails if the program will
  not compile. *)
program t6p1p5d1;
const
   (* all cases are legal productions *)
   a = 1;
   b = 12;
   c = 0123;
   d = 123.0123;
   e = 123.0123E+2;
   f = 123.0123E-2;
   g = 123.0123E2;
   h = 123E+2;
   i = 0123E-2;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   j = 0123E2;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #008');
   writeln(' PASS...6.1.5-1')
end.
 

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 134*)
(*TEST 6.5.3.4-1, CLASS=CONFORMANCE*)
(* The Pascal Standard states that the existance of a file
  variable f with components of type T implies the existence
  of a buffer variable of type T.
  Only the one component of a file variable determined by the
  current file position is directly accessible.
  The program tests that file buffers may be referenced in this
  implementation.
  The compiler fails if the program does not compile. *)
program t6p5p3p4d1;
type
   rekord = record
               urray : array[1..2] of char;
               a : integer;
               b : real
            end;
var
   fyle : file of rekord;
begin

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #134');
   rewrite(fyle);
   fyle^.urray[1]:='O';
   fyle^.urray[2]:='K';
   fyle^.a:=10;
   fyle^.b:=2.345;
   put(fyle);
   with fyle^ do
   begin
      urray[1]:='O';
      urray[2]:='K';
      a:=4;
      b:=3.456
   end;
   put(fyle);
   writeln(' PASS...6.5.3.4-1')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   
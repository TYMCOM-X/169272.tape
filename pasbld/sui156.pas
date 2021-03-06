
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 156*)
(*TEST 6.6.3.3-2, CLASS=CONFORMANCE*)
(* The Pascal Standard states that any operation involving the
  formal parameter is performed immediately on the actual
  parameter. Depending on how variable parameter passing is
  implemented, this test may cause some compilers to fail.
  The compiler fails if the program does not compile, or the
  program states that this is so. *)
program t6p6p3p3d2;
var
   direct : integer;
   pass  : boolean;
procedure indirection(var indirect : integer; var result : boolean);
   begin
      indirect:=2;
      if indirect<>direct then
         result:=false
      else
         result:=true
   end;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #156');
   direct:=1;
   pass:=false;
   indirection(direct,pass);
   if pass then
      writeln(' PASS...6.6.3.3-2')
   else
      writeln(' FAIL...6.6.3.3-2')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

 
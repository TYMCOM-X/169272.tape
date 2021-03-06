
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 178*)
(*TEST 6.6.5.3-4, CLASS=ERRORHANDLING*)
(* Similarly to 6.6.5.3-3, an error is caused by the
  pointer variable of dispose being undefined.
  The error should be detected by the compiler
  or at run-time. *)
program t6p6p5p3d4;
type
   rekord = record
             a : integer;
             b : boolean
            end;
var
   ptr : ^rekord;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #178');
   dispose(ptr);
   writeln(' ERROR NOT DETECTED...6.6.5.3-4')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

    
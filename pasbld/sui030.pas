
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  30*)
(*TEST 6.1.8-4, CLASS=QUALITY*)
(* In the case of an unclosed comment, does the compiler help
  the programmer to detect that this is so ? Hard to trace run-time
  errors may occur  if a comment accidentally encloses 1 or more
  statements. *)
program t6p1p8d4;
var
   i : integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #030');
   i:=10;
   (* Now write out the value of i.
   writeln(' THE VALUE OF I IS:', i);
   (* The value of i will not be printed because of the unclosed
     previous comment. *)*)
   i:=0
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   
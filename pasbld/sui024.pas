
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  24*)
(*TEST 6.1.7-9, CLASS=DEVIANCE*)
(* Some compilers may allow compatibility between strings and char
  constants. The two types for which they are constants are not
  compatible.
  This program tests what the compiler will allow.
  If all cases are accepted the program will print DEVIATES.
  However, if one or more of the cases are accepted, then the
  compiler deviates for those cases. *)
program t6p1p7d9;
const
   a = 'A';
var
   string1 : packed array[1..4] of char;
   string2 : packed array[1..1] of char;
   achar   : char;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #024');
   string1:=a;          (* CASE 1 *)
   string1:='A';        (* CASE 2 *)

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   string2:=a;          (* CASE 3 *)
   string2:='A';        (* CASE 4 *)
   achar:=string2;      (* CASE 5 *)
   string1:='A   ';
   achar:=string1;      (* CASE 6 *)
   string1:='   A';
   achar:=string1;      (* CASE 7 *)
   writeln(' DEVIATES...6.1.7-9')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

  
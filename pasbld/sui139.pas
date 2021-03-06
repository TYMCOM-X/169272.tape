
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 139*)
(*TEST 6.6.1-4, CLASS=DEVIANCE*)
(* This program tests if the compiler allows the formal parameter
  list to be included in the subsequent procedure declaration of
  a forward procedure.
  The compile conforms to the Standard if the program does not
  compile. *)
program t6p6p1d4;
var
   c : integer;
procedure one(var a : integer);
   forward;
procedure two(var b : integer);
begin
   b:=b+1;
   one(b)
end;
procedure one(var a : integer);
begin
   a:=a+1;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   if a = 1 then two(a)
end;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #139');
   c:=0;
   one(c);
   writeln(' DEVIATES...6.6.1-4')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

  
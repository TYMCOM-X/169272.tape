
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 152*)
(*TEST 6.6.3.1-4, CLASS=DEVIANCE*)
(* The occurrence of an identifier within an identifier list of
  a parameter group is its defining occurence as a parameter
  identifier for the formal parameter list in which it occurs
  and any corresponding procedure block or function block.
  This precludes the declaration of a local variable with the same
  name as an identifier in the formal parameter list.
  Does the compiler detect this as an error, or allow it
  to occur with some form of side effect?
  The compiler conforms if the program does not compile. *)
program t6p6p3p1d4;
var
   i : integer;
procedure deviates(var x : integer);
   var x : integer;
begin
   x:=2*x;
   writeln(' DEVIATES...6.6.3.1-4 : x=',x)
end;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

procedure deviates1(x : integer);
   var x : integer;
begin
   x:=0;
   x:=2*x;
   writeln(' DEVIATES...6.6.3.1-4 : x=',x)
end;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #152');
   i:=5;
   deviates(i);
   i:=5;
   deviates1(i)
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

  
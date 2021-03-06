
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 227*)
(*TEST 6.7.2.4-2, CLASS=CONFORMANCE*)
(* This test checks the operation of set operators.
   The compiler fails if the program does not compile, or the
  program states that this is so. *)
program t6p7p2p4d2;
var
   a,b,c,d:set of 0..10;
   counter:integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #227');
   counter :=0;
   a:=[0,2,4,6,8,10];
   b:=[1,3,5,7,9];
   c:=[];
   d:=[0,1,2,3,4,5,6,7,8,9,10];
   if (a+b=d) then
      counter:=counter+1;
   if (d-b=a) then
      counter := counter+1;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   if (d*b=b) then
      counter:=counter+1;
   if(d*b-b=c) then
      counter:=counter+1;
   if (a+b+c=d) then
      counter:=counter+1;
   if(counter=5) then
      writeln(' PASS...6.7.2.4-2, SET OPERATORS')
   else
      writeln(' FAIL...6.7.2.4-2, SET OPERATORS');
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   
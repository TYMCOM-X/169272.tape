
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 201*)
(*TEST 6.6.6.4-1, CLASS=CONFORMANCE*)
(* This program checks that the implementation of the ord
  function is as described by the Standard.
  The compiler fails if the program does not compile and run. *)
program t6p6p6p4d1;
type
   colourtype = (red,orange,yellow,green,blue);
var
   colour   : colourtype;
   some     : orange..green;
   i        : integer;
   counter  : integer;
   ok       : boolean;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #201');
   counter:=0;
   if (ord(false)=0) and (ord(true)=1) then
      counter:=counter+1
   else

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

      writeln(' FAIL...6.6.6.4-1 : FALSE/TRUE');
   if (ord(red)=0) and (ord(orange)=1) and
      (ord(yellow)=2) and (ord(green)=3) and
      (ord(blue)=4) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.4-1 : COLOURTYPE');
   i:=-11;
   ok:=true;
   while ok do
   begin
      i:=i+1;
      if i>10 then
         ok:=false
      else
         if ord(i)=i then
            counter:=counter+1
         else
         begin
            ok:=false;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

            writeln(' FAIL...6.6.6.4-1 : I')
         end
   end;
   colour:=blue;
   some:=orange;
   if ord(colour)=4 then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.4-1 : COLOUR');
   if ord(some)=1 then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.4-1 : SOME');
   if counter=25 then
      writeln(' PASS...6.6.6.4-1')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

    
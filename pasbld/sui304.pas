
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 304*)
(*TEST 6.9.4-11, CLASS=IMPLEMENTATIONDEFINED*)
(* This program determines the implementation defined default
  field width for writing integer, boolean and real types. *)
program t6p9p4d11;
var
   f:text;
   c:char;
   i,j:integer;
   function readfield:integer;
   var
      i:integer;
   begin
   i:=0;
   repeat
      read(f,c);
      i:=i+1;
   until (c='Z');
   readfield:=i-1;
end;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #304');
   rewrite(f);
   writeln(f,1,'Z',100,'Z');
   writeln(f,false,'Z',true,'Z');
   writeln(f,1.0,'Z',1000.0,'Z');
   reset(f);
   writeln(' IMPLEMENTATION DEFINED DEFAULT FIELD WIDTH VALUES');
   i:=readfield;
   j:=readfield;
   if (i=j) then
      writeln(' INTEGERS:',i:5,' CHARACTERS')
   else
   writeln(' THE VALUE VARIES ACCORDING TO THE SIZE OF THE INTEGER');
   readln(f);
   i:=readfield;
   j:=readfield;
   if (i=j) then
      writeln(' BOOLEAN:',i:5,' CHARACTERS')
   else

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

      writeln(' THE VALUE VARIES ACCORDING TO THE BOOLEAN VALUE');
   readln(f);
   i:=readfield;
   j:=readfield;
   if (i=j) then
      writeln(' REAL:',i:5,' CHARACTERS')
   else
      writeln(' THE VALUE VARIES ACCORDING TO THE SIZE OF THE REAL');
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  97*)
(*TEST 6.4.3.4-5, CLASS=QUALITY*)
(* This test is an implementation of Warshall's algorithm
  in Pascal. It serves to give a program which can be used both
  to time a simple procedure using sets, and which can measure
  the space requirements. In both cases the measurements of the
  procedure Warshall are to be compared.
  By way of comparison, the Tasmanian compiler on the Burroughs
  B6700 yielded
      space = 143 bytes ( 6864 bits)
      time = 0.816461 seconds
   *)
program t6p4p3p4d5;
const
   size = 79;   (*array is (size+1) by (size+1) square*)
   words = 4;   (*size div 16*)
   bitsperword = 16;   (*assume everyone allows this*)
   bitsminus1 = 15;   (*bitsperword-1*)
type
   btype = array [0..size] of array [0..words]

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

         of set of 0..bitsminus1;
var
   seed:integer;
   t1,t2:real;
   original,closure:btype;
function generate:integer;
begin
   seed:=57*seed+1;
   generate := (seed mod (size+1));
   seed:=seed mod 571
end;   (*of generate*)
procedure fill(var a:btype; p:integer);
var
   i:0..size;
   j:0..bitsminus1;
   k,l:0..maximum(integer);
begin
   for j:=0 to words do a[0][j]:=[];
   for i:=1 to size do a[i]:=a[0];
   for k:=1 to p do begin

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

      i:=generate;
      l:=generate;
      j:=l div bitsperword;
      a[i][j] := a[i][j]+[(l mod bitsperword)]
   end
end;   (*of fill*)
procedure print(var b:btype);
var
   i,j:0..size;
begin
   for i:=0 to size do begin
      write(' ');
      for j:=0 to size do begin
         if (j mod bitsperword) in b[i][j div bitsperword] then
            write('+')
         else
            write('-')
      end;
      writeln
   end

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

end;   (*of print*)
procedure warshallsalgorithm(var a,b:btype);
   (*examine the code to see how many bytes of 8-bits are required*)
var
   i,j:0..size;
   k:0..words;
begin
   b:=a;
   for i:=0 to size do
      for j:=0 to size do
         if (i mod bitsperword) in b[j][i div bitsperword] then
            for k:=0 to words do
               b[j][k] := b[j][k]+b[i][k];
end;   (*of warshallsalgorithm*)
begin
        rewrite(output,'suite.txt',[preserve]);    (*of main program*)       writeln('suite program #097');
   seed:=1;
   fill(original,125);
   t1:=runtime;   (*ie begin timing however you do it*)
   warshallsalgorithm(original,closure);

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   t2:=runtime;   (*ie stop timing*)
   writeln(' TIME=',t2-t1);
   writeln(' ORIGINAL MATRIX');
   print(original);
   writeln(' TRANSITIVE CLOSURE');
   print(closure)
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

 
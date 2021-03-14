
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 223*)
(*TEST 6.7.2.3-2, CLASS=IMPLEMENTATIONDEFINED*)
(* This program determines if a boolean expression is partially
  evaluated if the value of the expression is determined before
  the expression is fully evaluated *)
program t6p7p2p3d2;
var
   a:boolean;
   k,l:integer;
function sideeffect(var i:integer; b:boolean):boolean;
begin
   i:=i+1;
   sideeffect:=b;
end;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #223');
   writeln(' TEST OF SHORT CIRCUIT EVALUATION OF (A AND B)');
   k:=0;
   l:=0;
   a:=sideeffect(k,false) and sideeffect(l,false);

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   if (k=0) and (l=1) then
      writeln(' SECOND EXPRESSION EVALUATED...6.7.2.3-2')
   else
      if (k=1) and (l=0) then
         writeln(' FIRST EXPRESSION EVALUATED...6.7.2.3-2')
      else
         if(k=1) and (l=1) then
            writeln(' BOTH EXPRESSIONS EVALUATED...6.7.2.3-2')
         else
            writeln(' FAIL...6.7.2.3-2');
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

 
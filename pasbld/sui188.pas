
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 188*)
(*TEST 6.6.6.2-3, CLASS=CONFORMANCE*)
(* This program tests the implementation of the arithmetic
  functions sin, cos, exp, ln, sqrt, and arctan.
  A rough accuracy test is done, but is not the purpose
  of this program.
  The compiler fails if the program does not compile and run. *)
program t6p6p6p2d3;
const
   pi = 3.1415926;
var
   counter : integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #188');
   counter:=0;
   if (sin(pi)<0.000001) and
      ((0.70710<sin(pi/4)) and (sin(pi/4)<0.70711)) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.2-3 : SIN');

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   if (cos(pi)<-0.99999) and
      ((0.70710<cos(pi/4)) and (cos(pi/4)<0.70711)) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.2-3 : COS');
   if ((2.71828<exp(1)) and (exp(1)<2.71829)) and
      ((0.36787<exp(-1)) and (exp(-1)<0.36788)) and
      ((8103.08392<exp(9)) and (exp(9)<8103.08393)) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.2-3 : EXP');
   if (ln(exp(1))>0.99999) and
      ((0.69314<ln(2)) and (ln(2)<0.69315)) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.2-3 : LN');
   if (sqrt(25)=5) and
      ((5.09901<sqrt(26)) and (sqrt(26)<5.09902)) then
      counter:=counter+1
   else

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

      writeln(' FAIL...6.6.6.2-3 : SQRT');
   if ((0.09966<arctan(0.1)) and (arctan(0.1)<0.09967)) and
      (arctan(0)=0) then
      counter:=counter+1
   else
      writeln(' FAIL...6.6.6.2-3 : ARCTAN');
   if counter=6 then
      writeln(' PASS...6.6.6.2-3')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

  

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 123*)
(*TEST 6.4.6-6, CLASS=ERRORHANDLING*)
(* This program is similar to 6.4.6-4, except that array
  subscript assignment compatibility is tested.
  The program causes an error, which should be detected. *)
program t6p4p6d6;
type
   colour = (red,pink,orange,yellow,green);
var
   v     : colour;
   urray : array[red..orange] of boolean;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #123');
   v:=orange;
   urray[succ(v)]:=true;      (* error *)
   writeln(' ERROR NOT DETECTED...6.4.6-6')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

 
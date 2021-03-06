
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  91*)
(*TEST 6.4.3.3-12, CLASS=ERRORHANDLING*)
(* This program is similar to 6.4.3.3-3, except here
  an error is caused by assigning the undefined value
  of the variable empty to the field e.
  This error should be detected. *)
program t6p4p3p3d12;
type
   statuskind  = (defined,undefined);
   emptykind   = record end;
var
   empty : emptykind;
   number: record
            case status:statuskind of
               defined  : (i : integer);
               undefined: (e : emptykind)
            end;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #091');
   with number do

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   begin
      status:=undefined;
      e:=empty       (* undefined despite being empty *)
   end;
   writeln(' PASS...6.4.3.3-12')
end.
   
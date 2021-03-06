
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  83*)
(*TEST 6.4.3.3-4, CLASS=CONFORMANCE*)
(* Similarly to 6.4.3.3-2, a tag-field may be redefined
  elsewhere in the declaration part.
  The compiler fails if the program will not compile. *)
program t6p4p3p3d4;
type
   which = (white,black,warlock,sand);
var
   polex : record
             case which:boolean of
               true: (realpart:real;
                      imagpart:real);
               false:(theta:real;
                      magnit:real)
            end;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #083');
   polex.which:=true;
   polex.realpart:=0.5;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   polex.imagpart:=0.8;
   writeln(' PASS...6.4.3.3-4')
end.
   
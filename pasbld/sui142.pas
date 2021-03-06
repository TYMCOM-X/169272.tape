
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 142*)
(*TEST 6.6.1-7, CLASS=QUALITY*)
(* This test checks that procedures may be nested to 15 levels.
  The test may detect a small compiler limit.  The limit may
  arise due to failure of a register allocation scheme, a limited
  reserved size for a display, or a field set aside for lexical
  level information, or some combination of these. *)
program t6p6p1d7;
var
   i:integer;
procedure p1;
   procedure p2;
      procedure p3;
         procedure p4;
            procedure p5;
               procedure p6;
                  procedure p7;
                     procedure p8;
                        procedure p9;
                           procedure p10;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

                              procedure p11;
                                 procedure p12;
                                    procedure p13;
                                       procedure p14;
                                          procedure p15;
                                          begin
                                             i:=i+1;
                                          end;
                                       begin
                                          p15
                                       end;
                                    begin
                                       p14
                                    end;
                                 begin
                                    p13
                                 end;
                              begin
                                 p12
                              end;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

                           begin
                              p11
                           end;
                        begin
                           p10
                        end;
                     begin
                        p9
                     end;
                  begin
                     p8
                  end;
               begin
                  p7
               end;
            begin
               p6
            end;
         begin
            p5

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

         end;
      begin
         p4
      end;
   begin
      p3
   end;
begin
   p2
end;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #142');
    i:=0;
    p1;
    writeln(' NESTED PROCEDURES TO 15 LEVELS IMPLEMENTED...6.6.1-7');
 end.
(*TEST 6.6.2-1, CLASS=CONFORMANCE*)
(* This program simply tests the syntax for functions as defined
  by the Pascal Standard.
  The compiler fails if the program does not compile. *)

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

program t6p6p2d1(output);
var
   a ,
   twopisquared : real;
   b : integer;
function power(x : real; y : integer):real;  (* y>=0 *)
var
   w,z : real;
   i : 0..maximum(integer);
begin
   w:=x;
   z:=1;
   i:=y;
   while i > 0 do
   begin
      (* z*(w tothepower i)=x tothepower y *)
      if odd(i) then z:=z*w;
      i:=i div 2;
      w:=sqr(w)
   end;

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   (* z=x tothepower y *)
   power:=z
end;
function twopi : real;
begin
   twopi:=6.283185
end;
begin
   a:=twopi;
   b:=2;
   twopisquared:=power(a,b);
   writeln(' PASS...6.6.2-1')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

   
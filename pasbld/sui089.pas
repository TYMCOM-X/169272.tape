
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  89*)
(*TEST 6.4.3.3-10, CLASS=CONFORMANCE*)
(* The Pascal Standard states that case constants must be distinct,
  and are of an ordinal type which is compatible with the
  tag-field.
  This program tests to see if the compiler will permit case
  constants outside the tag-field subrange - it should .
  The compiler passes if the program runs.
  A warning might be appropriate, however, as fields outside the
  tagfield subrange are not accessible. *)
program t6p4p3p3d10;
type
   a = 0..3;
   b = record
         case c:a of
            0: (d:array[1..2] of boolean);
            1: (e:array[1..3] of boolean);
            2: (f:array[1..4] of boolean);
            3: (g:array[1..5] of boolean);
            4: (h:array[1..6] of boolean)

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

       end;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #089');
   writeln(' PASS...6.4.3.3-10')
end.
   
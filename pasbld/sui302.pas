
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 302*)
(*TEST 6.9.4-9, CLASS=DEVIANCE*)
(* This test attempts to output integers whose field width parameter
  are zero or negative. The compiles deviates if the program prints
  DEVIATES. *)
program t6p9p4d9;
var
   i:integer;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #302');
   for i:=10 downto -1 do
      writeln(' ','.':i, 'REP=',i);
   writeln(' DEVIATES...6.9.4-9, WRITE');
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

    

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number 108*)
(*TEST 6.4.5-4, CLASS=DEVIANCE*)
(* This program is similar to 6.4.5-3, except that deviance in the
  case of records is tested.
  The program should fail to compile/execute if the compiler
  conforms. *)
program t6p4p5d4;
type
   recone = record
               a : integer;
               b : boolean
            end;
   rectwo = record
               c : integer;
               d : boolean
            end;
var
   recordone : recone;
   recordtwo : rectwo;
procedure test(var rec : recone);

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

begin
   writeln(' DEVIATES...6.4.5-4')
end;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #108');
   (* Although the two record types are compatible, they
     are not identical, and hence the call to TEST
     should fail. *)
   recordtwo.c:=0;
   recordtwo.d:=true;
   test(recordtwo)
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

  
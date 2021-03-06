
(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

(* program number  75*)
(*TEST 6.4.3.2-1, CLASS=CONFORMANCE*)
(* This program tests all the valid productions for an
  array declaration from the syntax specified by the
  Pascal Standard.
  The compiler fails if one or more cases are rejected. *)
program t6p4p3p2d1;
type
   cards       = (two,three,four,five,six,seven,eight,nine,ten,jack,
                  queen,king,ace);
   suit        = (heart,diamond,spade,club);
   hand        = array[cards] of suit;
   picturecards= array[jack..king] of suit;
   played      = array[cards] of array[heart..diamond] of boolean;
   playedtoo   = array[cards,heart..diamond] of boolean;
begin
        rewrite(output,'suite.txt',[preserve]);       writeln('suite program #075');
   writeln(' PASS...6.4.3.2-1')
end.

(****           (c) 1981 Strategic Information                  ****)
(****           division of Ziff Davis Publishing Co.           ****)

  
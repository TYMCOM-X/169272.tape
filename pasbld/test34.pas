PROGRAM TEST34 OPTIONS DUMP;

TYPE
    IAR4 = ARRAY [1..4] OF 0 .. 1000;
    CAR6 = ARRAY [1..6] OF CHAR;
    BAR3 = ARRAY [1..3] OF BOOLEAN;

VAR
    IA: IAR4;
    CA: CAR6;
    BA: BAR3;

BEGIN
  IA := ( 10, 20, 30, 40 );
  CA := ( 'A', 'B', ' ', 'D', ' ', 'H' );
  BA := ( TRUE, FALSE, TRUE );
  IA := ( 1, 3, 5, 7, 9 );
  CA := ( 'A', 'E', 'I', 'O', 'U' );
  BA := ( 1, FALSE, 'A' );
  IA := ( ORD(CA[1]), ORD(BA[2]), IA[3], 0 );
  CA := ( '*', CHR(IA[1]), '/', CA[IA[1]], '+', SUBSTR('ABCDEF',IA[1],IA[2]) );
  BA := ( (IA[1]=IA[3]), (CA[2]<CA[3]), (BA[1] AND BA[2] ) );
END.
 
PROGRAM TEST42 OPTIONS DUMP;

(*  CONSTANT RECORDS AND FIELD REFERENCES  *)

TYPE
    R = RECORD
	F1, F2: CHAR;
	CASE F3: INTEGER OF
	    1,3,7..10,20:
		( F4A,F5A: STRING [5] );
	    2,4,5,11..15:
		( F4B,F5B: INTEGER );
	    0:
		( F4C: CHAR;
		  CASE CHAR OF
		    '0'..'9': (F6A:INTEGER);
		    'A'..'Z': (F6B: CHAR);
		    OTHERS: (F6C:BOOLEAN))
    END;

CONST

    (*  SOME LEGAL RECORD CONSTANTS  *)

    C1: R = ('A','B',6);
    C2: R = ('0','1',1,'MINIMAX','ALPHA');
    C3: R = ('','LEN',8,'FOR','FIL');
    C4: R = (' ',' ',2,3,7);
    C5: R = ('+','-',0,'&','0',20);
    C6: R = ('*','/',0,'','Z','X');
    C7: R = ('$','$',0,'$','$',TRUE);

    (*  NOW FOR SOME ERRORS  *)

    E1: R = ('A','B');
    E2: R = ('A','B',1,2,3);
    E3: R = ('A','B',-1,+1);
    E4: R = ('A','B',0,'X','Y',TRUE);

    (*  LEGAL FIELD REFERENCES  *)

    A1 = C1.F2;
    A2 = C2.F4A;
    A3 = C3.F5A;
    A4 = C4.F5B;
    A5 = C5.F6A;
    A6 = C6.F6B;
    A7 = C7.F6C;

    (*  THESE FIELD REFERENCES ARE ERRONEOUS  *)

    B1 = C1.F4A;
    B2 = C2.F4B;
    B3 = C6.F4A;
    B4 = C6.F6A;

BEGIN  END.
    
PROGRAM TEST48 OPTIONS DUMP;

(*  TEST OF SELECTED STANDARD FUNCTIONS.  OPERATOR GENERATION, FOLDING,
    AND ERROR CHECKING ARE TESTED FOR THE FOLLOWING FUNCTIONS:

	INDEX
	SUBSTR
	VERIFY
	SEARCH
	UPPERCASE
	LOWERCASE
	LENGTH								*)

TYPE COLOR = ( RED, GREEN, BLUE );

PROCEDURE P;
VAR I: INTEGER;
    P: BOOLEAN;
    C: CHAR;
    D: SET OF CHAR;
    E: SET OF ' ' .. '_';
    S: COLOR;
    T: STRING [10];
    U: PACKED ARRAY [1..20] OF CHAR;
BEGIN

    (*  THE FOLLOWING CALLS ARE ALL LEGAL  *)

    I := INDEX (U,T);
    I := INDEX (U,T,0);
    I := INDEX (U,C);
    I := INDEX (C,'A');

    T := SUBSTR (U,I);
    T := SUBSTR (T,I,3);
    C := SUBSTR (T,I,1);
    U := SUBSTR (C,I);

    I := VERIFY (T,D);
    I := VERIFY (U,E,I);
    I := VERIFY (C,['A'..'Z']);

    I := SEARCH (U,D);
    I := SEARCH (T,[],I);
    I := SEARCH (C,E);

    C := UPPERCASE (C);
    C := UPPERCASE (T);
    C := UPPERCASE (U);
    T := UPPERCASE (C);
    T := UPPERCASE (T);
    T := UPPERCASE (U);
    U := UPPERCASE (C);
    U := UPPERCASE (T);
    U := UPPERCASE (U);

    C := LOWERCASE ('A');
    T := LOWERCASE ('MIX-MASTER');
    U := LOWERCASE (' ');

    I := LENGTH (C);
    I := LENGTH (T);
    I := LENGTH (U);
    I := LENGTH ('');
    I := LENGTH ('A');
    I := LENGTH ('FOUR');

END (* P *);

BEGIN END .
  
MODULE ask;
(*ask a question*)

$SYSTEM setup

$INCLUDE ask.typ

PUBLIC PROCEDURE ask_tty(q: STRING[*]; l: ask_lst; VAR i: INTEGER); FORWARD;
(*ask TTY a question, return index of response word in list*)

PUBLIC PROCEDURE ask(q: STRING[*]; l: ask_lst; VAR i: INTEGER); FORWARD;
(*ask question, return index of response word in list*)

PUBLIC FUNCTION abbrev(s1, s2: STRING[*]): BOOLEAN; FORWARD;
(*return TRUE if s1 is equal to or an abbreviation of s2*)

FUNCTION abbrev(s1, s2: STRING[*]): BOOLEAN;
VAR i, p1, l1: INTEGER;
BEGIN (*return TRUE if s1 is equal to or an abbreviation of s2*)
  p1 := VERIFY(s1, [' '], 1);
  l1 := SEARCH(SUBSTR(s1 || ' ', p1), [' ']) - 1;
  IF l1 <= LENGTH(s2) THEN BEGIN
    abbrev := UPPERCASE(SUBSTR(s1, p1, l1)) = UPPERCASE(SUBSTR(s2, 1, l1))
  END
  ELSE abbrev := FALSE
END;

PROCEDURE ask(q: STRING[*]; l: ask_lst; VAR i: INTEGER);
VAR w: ask_wrd; j: INTEGER;
BEGIN (*ask question, return index of response word in list*)
  i := 0;
  REPEAT
    WRITELN; rd_cmd(q, w);
    IF (w = '') OR end_input THEN j := 0
    ELSE FOR j := 1 TO UPPERBOUND(l) DO IF abbrev(w, l[j]) THEN i := j;
    IF i = 0 THEN BEGIN
      WRITELN('Please respond with one of the following:');
      FOR j := 1 TO UPPERBOUND(l) DO WRITELN(l[j])
    END
  UNTIL (i <> 0) OR (j = 0)
END;

PROCEDURE ask_tty(q: STRING[*]; l: ask_lst; VAR i: INTEGER);
BEGIN (*ask TTY a question, return index of response word in list*)
  tty_on; ask(q, l, i); tty_off
END.
  
PROGRAM echo;

$SYSTEM pasutl

VAR
lin: STRING[132];
arg: STRING[10];
i: INTEGER;

BEGIN
  WHILE start('ECHO', '') DO BEGIN
    ttyon;
    IF askyn('Show args?') THEN BEGIN
      i := 1;
      WHILE getarg(i, arg) DO BEGIN
        wrlin('"' || arg || '"'); i := i + 1
      END;
      IF i = 1 THEN wrlin('No args.')
    END;
    IF askyn('Show file names?') THEN BEGIN
      wrlin('Input: ' || FILENAME(INPUT));
      wrlin('Output: ' || FILENAME(OUTPUT))
    END;
    IF askyn('Do copy?') THEN BEGIN
      ttyoff; lin := '';
      WHILE rdlin(lin) DO wrlin(lin)
    END
  END
END.
   
PROGRAM glarch;

VAR
  num_itms: INTEGER;
  idx: INTEGER;
  num: REAL;

BEGIN

  RESET(INPUT, 'GLARCH.DAT'); (*VAR INPUT: TEXT*)
  REWRITE(OUTPUT, 'TTY:'); (*VAR OUTPUT: TEXT*)

  WHILE NOT EOF(INPUT) DO BEGIN

    READLN(num_itms);
    WRITELN;
    WRITELN(num_itms: 0, ' items are to follow.');

    FOR idx := 1 TO num_itms DO BEGIN
      EXIT IF EOF(INPUT) DO WRITELN('? End of file.');
      READLN(num);
      WRITELN('Item #', idx: 0, ' is ', num: 0)
      END

    END

  END.
   
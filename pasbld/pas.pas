PROGRAM pascal;

$INCLUDE RUNUTL

BEGIN
  IF NOT runprg('[3,177775]PASCAL',0) THEN BEGIN
    REWRITE(TTYOUTPUT);
    WRITELN(TTYOUTPUT, 'Can not run: [3,177775]PASCAL')
  END
END.

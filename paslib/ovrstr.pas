PROGRAM ovrstr;
  (*remove backspaces from input*)

$SYSTEM TOOLS

BEGIN
  setup('OVERSTRIKE');
  WHILE getio DO BEGIN
    WHILE getl(lin, linlen) DO REPEAT
      csr := 1
      UNTIL lin[1] = eos
      REPEAT
    END
  END.
 
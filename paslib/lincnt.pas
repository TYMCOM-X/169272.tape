PROGRAM lincnt;
  (*count lines in standard input*)

$SYSTEM TOOLS

VAR c: CHAR;
VAR nl: INTEGER;

BEGIN
  setup('LINE COUNT');
  WHILE getio DO BEGIN
    nl := 0;
    WHILE getc(c) DO IF c = newline THEN nl := nl + 1;
    putdec(nl, 1);
    putc(newline)
    END
  END.
  
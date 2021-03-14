MODULE CHARS2;

$HEADER CHARS2.HDR


PUBLIC FUNCTION CHARS2 ( INT_VAL: -99..99 ): PACKED ARRAY [1..2] OF CHAR;

BEGIN
  PUTSTRING (CHARS2, ABS (INT_VAL):2);
  IF IOSTATUS <> IO_OK THEN
    CHARS2 := '**'
  ELSE IF CHARS2[1] = ' ' THEN
    CHARS2[1] := '0';
END.
    
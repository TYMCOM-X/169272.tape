$WIDTH=100
$LENGTH=55
$TITLE WID132.PAS, last modified 10/14/83, zw

PROGRAM wid132;
(*set VT102/LA50 for 132 character lines*)

$SYSTEM pasutl

PROCEDURE out_chrs(chrs: ARRAY[1 .. *] OF INTEGER);

VAR
    idx: INTEGER;

BEGIN (*output the list of characters, given their numbers*)
  FOR idx := 1 TO UPPERBOUND(chrs) DO
    wrstr(CHR(chrs[idx]))
END;

BEGIN
  IF start('WID132', ';') THEN BEGIN
    out_chrs((27, 91, 63, 51, 104)); (*set VT100 to 132 chars per line*)
    lpton;
    out_chrs((27, 91, 52, 119)); (*set LA50 to 132 chars per line*)
    lptoff
  END
END.
    
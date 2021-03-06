$WIDTH=100
$LENGTH=55
$TITLE DBGUTL.PAS, last modified 10/26/83, zw

MODULE dbgutl;
(*Debugging Utility*)

$HEADER DBGUTL.DOC

$PAGE modules and declarations

$SYSTEM USRUTL.MOD
$SYSTEM CMDUTL.MOD

$INCLUDE DBGUTL.DEC

VAR dbgindent: INTEGER := 0;

PUBLIC VAR dbg: BOOLEAN := FALSE;

$PAGE d, b, e

PUBLIC PROCEDURE d(msg: STRING[*]);
VAR i: INTEGER;
BEGIN
  IF dbg THEN BEGIN
    FOR i := 1 TO dbgindent * 2 DO ttystr(' ');
    ttylin(msg)
  END
END;

PUBLIC PROCEDURE b(msg: STRING[*]);
BEGIN
  d(msg);
  dbgindent := dbgindent + 1
END;

PUBLIC PROCEDURE e(msg: STRING[*]);
BEGIN
  IF dbgindent > 0 THEN
    dbgindent := dbgindent - 1
  ELSE
    dbgindent := 0;
  d(msg)
END;

$PAGE debug

PUBLIC PROCEDURE debug;
VAR
newdbg: BOOLEAN;
BEGIN
  newdbg := askyn('Debug?');
  IF newdbg THEN
    d('Debug flag is ON.')
  ELSE
    d('Debug flag is OFF.');
  dbg := newdbg;
  IF dbg THEN
    dbgindent := 0;
END.
 
$TITLE ED.PAS, last modified 2/16/84, zw
PROGRAM qed OPTIONS STORAGE(3072);
(*driver program for line editor*)

VAR buffer: buftyp; (*working buffer*)

BEGIN
  OPEN(TTY, [ASCII]); REWRITE(TTYOUTPUT);
  TTY^ := cr; (*initialize fake line end*)
  qinitexec(buffer); (*init buffer and editor parameters*)
  WRITELN(TTY, 'ED, Version 1.0');
  REPEAT
    edcl(buffer, [MINIMUM(edcmds) .. MAXIMUM(edcmds)])
  UNTIL (NOT buffer.changes) ORIF query('Unwritten changes, OK')
END.
    
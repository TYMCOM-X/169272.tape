$TITLE TYPTST.PAS, last modified 4/9/84, zw
PROGRAM typtst;
(*TYM-Pascal test for TYPUTL*)

$INCLUDE TYPUTL.TYP

BEGIN
  REWRITE(TTYOUTPUT);
  WRITELN(TTYOUTPUT, 'TEST OF TYPUTL');
  WRITELN(TTYOUTPUT, 'TEST SUCCEEDS')
END.

$TITLE TIMTST.PAS, last modified 4/9/84, zw
PROGRAM timtst;
(*TYM-Pascal test for TIMUTL*)

$HEADER TIMUTL.HDR

$INCLUDE TIMUTL.INC

BEGIN
  REWRITE(TTYOUTPUT);
  WRITELN(TTYOUTPUT, 'TEST OF TIMUTL');
  WRITELN(TTYOUTPUT, 'GREENWICH MEAN TIME: ', dc_ext(gmdtime));
  WRITELN(TTYOUTPUT, 'LOCAL TIME: ', dc_ext(daytime));
  WRITELN(TTYOUTPUT, 'DATE #1: ', ns_d1(extr_date(daytime)));
  WRITELN(TTYOUTPUT, 'DATE #2: ', ns_d2(extr_date(daytime)));
  WRITELN(TTYOUTPUT, 'TIME #1: ', ns_t1(extr_time(daytime)));
  WRITELN(TTYOUTPUT, 'TEST SUCCEEDS')
END.
   
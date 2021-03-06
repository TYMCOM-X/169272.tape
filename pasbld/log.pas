$TITLE LOG.PAS, last modified 4/30/84, zw
PROGRAM LOG OPTIONS special(word);
(*TYM-Pascal compiler -- reader of the log file*)
$SYSTEM TIMUTL.INC
$INCLUDE PASLOG.TYP
$SYSTEM VERSIO.INC

VAR
logfil: FILE OF log_file_record;
logrcd: log_file_record;
num_programs, num_modules, num_seconds, num_lines, num_errors, num_noerror,
  num_debug, num_check, num_special: INTEGER;
start_date: dtime_int;

BEGIN
  REWRITE(OUTPUT, 'TTY:');
  WRITELN('TYM-Pascal Log File Analyzer, Version ', version());
  WRITELN;
  RESET(logfil, 'PASCAL.LOG');
  IF EOF(logfil) THEN BEGIN
    WRITELN('--no data yet--');
    CLOSE(logfil);
    REWRITE(logfil, 'PASCAL.LOG');
    CLOSE(logfil);
    STOP
  END;
  num_programs := 0;
  num_modules := 0;
  num_seconds := 0;
  num_lines := 0;
  num_errors := 0;
  num_noerror := 0;
  num_debug := 0;
  num_check := 0;
  num_special := 0;
  WHILE NOT EOF(logfil) DO BEGIN
    READ(logfil, logrcd);
    WITH logrcd DO BEGIN
      IF (num_programs + num_modules) = 0 THEN start_date := date_and_time;
      IF opt_main THEN num_programs := num_programs + 1
      ELSE num_modules := num_modules + 1;
      num_seconds := num_seconds + run_time DIV 1000;
      num_lines := num_lines + no_lines;
      IF no_errors = 0 THEN num_noerror := num_noerror + 1
      ELSE num_errors := num_errors + no_errors;
      IF opt_debug THEN num_debug := num_debug + 1;
      IF opt_check THEN num_check := num_check + 1;
      IF opt_special THEN num_special := num_special + 1
    END
  END;
  WRITELN;
  WRITELN('Starting: ', dc_ext(start_date));
  WRITELN('Until: ', dc_ext(logrcd.date_and_time));
  WRITE('Total compilations =');
  WRITELN(num_programs + num_modules);
  WRITE('Total runtime (hours) =');
  WRITELN(num_seconds DIV 3600);
  WRITE('Average runtime (minutes) =');
  WRITELN((num_seconds DIV 60) DIV (num_programs + num_modules));
  WRITE('Average number of lines =');
  WRITELN(num_lines DIV (num_programs + num_modules));
  WRITE('Percent which were modules =');
  WRITELN((100 * num_modules) DIV (num_programs + num_modules));
  WRITE('Percent with debug option =');
  WRITELN((100 * num_debug) DIV (num_programs + num_modules));
  WRITE('Percent with check option =');
  WRITELN((100 * num_check) DIV (num_programs + num_modules));
  WRITE('Percent with special option =');
  WRITELN((100 * num_special) DIV (num_programs + num_modules));
  WRITE('Percent with errors =');
  WRITELN(100 - (100 * num_noerror) DIV (num_programs + num_modules));
  WRITE('Average number of errors =');
  WRITELN(num_errors DIV(num_programs + num_modules - num_noerror))
END.
   
$WIDTH=100
$LENGTH=50
$TITLE RDLOG.PAS, last modified 1/17/84, zw
PROGRAM rdlog OPTIONS SPECIAL(WORD);
(*TYM-Pascal compiler -- reader of the log file*)

$SYSTEM DTIME.TYP
$SYSTEM DTIME.INC

(* $INCLUDE PASLOG.TYP *)

type
    filblock = array [1..4] of machine_word; (* internal file name block *)

    log_file_record = packed record
	file_name: filblock; (* encoded file block *)
	version: integer; (* from .JBVER *)
	run_time: integer; (* in milliseconds *)
	no_lines: integer; (* source lines read *)
	no_incl_lines: integer; (* lines from include files *)
	no_errors: integer; (* errors detected *)
	users_ppn: machine_word; (* from GETPPN uuo *)
	date_and_time: dtime_int;
	lowseg_size: 0..777777b; (* generated code low segment *)
	highseg_size: 0..777777b; (* generated code high segment *)
	alloc_strategy: 0 .. 99; (* ALLOC=n *)
	ki10: boolean; (* no/yes *)
	kl10: boolean; (* yes *)
	opt_debug: boolean; (* DEBUG *)
	opt_double: boolean; (* no - no such thing *)
	opt_check: boolean; (* anything in CHECK mode? *)
	opt_main: boolean; (* program vs. module *)
	opt_overlay: boolean; (* OVERLAY *)
	opt_progress: boolean; (* no *)
	opt_source: boolean; (* SOURCE ever specified? *)
	opt_special: boolean; (* anything in SPECIAL mode *)
	opt_terse: boolean; (* TERSE vs. VERBOSE *)
	opt_trace: boolean; (* TRACE ever specified? *)
	opt_xref: boolean; (* GLOBAL *)
	opt_virtual: boolean; (* no *)
	opt_auto_run: boolean; (* run at offset 1 *)
	opt_tmpcor: boolean; (* run from tmpcor file *)
	opt_hash: boolean; (* run from ###PAS.TMP *)
	fill1, fill2, fill3: integer (* record size = 16 (decimal) words *)
    end;

VAR
logfil: FILE OF log_file_record;
logrcd: log_file_record;
num_programs, num_modules, num_seconds, num_lines, num_errors,
num_noerror, num_debug, num_check, num_special: INTEGER;
start_date: dtime_int;
BEGIN
  REWRITE(OUTPUT, 'TTY:');
  RESET(logfil, 'PASCAL.LOG');
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
  
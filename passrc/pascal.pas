$TITLE PASCAL.PAS, last modified 4/3/84, zw
MODULE pascal;
(*TYM-Pascal compiler -- global compiler utilities*)

$PAGE system modules
$SYSTEM UTLTYP.TYP
$SYSTEM UTLSW.INC
$SYSTEM UTLRUN.INC
$SYSTEM UTLSRC.TYP
$SYSTEM UTLLST.TYP
$SYSTEM UTLKEY.TYP
$SYSTEM UTLIO.INC
$SYSTEM PASENV.INC
$SYSTEM PASADR.TYP

$INCLUDE PASCAL.TYP

$PAGE definitions
EXTERNAL VAR (*declared public in PASENV.PAS*)
version: string_argument; (*current version/banner*)
cursrc: source_position; (*current file/page/line*)
srcfil: file_name; (*name of main source file*)
lstfil: file_name; (*name of listing file, if any*)
relfil: file_name; (*name of rel file, if any*)
dmpfil: file_name; (*name of dump file, if any*)
dmpfcb: list_file; (*control blocks for dump file*)
lstfcb: list_file; (*control block for list file*)
maxerr: error_severity; (*highest severity error detected*)
errcnt: ARRAY[error_severity] OF positive_integer; (*count of errors*)
defopts: command_options; (*default global options*)
glbopts: command_options; (*changed by program/module statement options*)
blkopts: option_set; (*all options specified for any block*)
lstopts: yes_no; (*any listing options specified?*)
lstexp: yes_no; (*list file explicitly specified?*)
reqallc: yes_no; (*ALLCONDITIONS ever specified?*)
dogen: yes_no; (*go on and generate code?*)
qcgen: yes_no; (*use quick code generator?*)
slncnt: positive_integer; (*total source lines read*)
ilncnt: positive_integer; (*total source lines read from include files*)
target: target_code; (*current target machine*)

$PAGE unchain, chain
PUBLIC PROCEDURE unchain;
(*Restore current environment when chained to.*)
BEGIN
  assume(rdpas(current_environment_file, yes),
    '?Unable to read current environment: ' || current_environment_file)
END;

PUBLIC PROCEDURE chain(next_progam: file_name);
(*Save current environment, chain to next program.*)
BEGIN
  assume(wrpas(curent_environment_file),
    '?unable to write environment to file: ' || current_environment_file);
  assume(NOT sw(glbopts.dump_switches, 'MANUAL'),
    'Manual operation, ready to run: ' || next_program);
  assume(runprg(next_program, yes), '?Unable to run: ' || next_program)
END;

PUBLIC PROCEDURE dpystat(name: file_name; start_time: INTEGER);
VAR segstuff: segrecd;
BEGIN
  REWRITE(TTY); seginfo(segstuff);
  WRITE(TTY, '[PASANL: ', (RUNTIME - start_time) / 1000.0: 8: 3,
  WRITELN(TTYOUTPUT, ' seconds, ', (segstuff.lowlen + 511) DIV 512: 3, '+',
    (segstuff.highlen + 511) DIV 512: 3, 'P]')
END.
  
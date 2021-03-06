$TITLE PASLOG.PAS, last modified 5/11/84, zw
MODULE paslog OPTIONS special(word);
(*TYM-Pascal Compiler Usage Log*)
$INCLUDE TIMUTL.typ
$INCLUDE paslog.typ
$INCLUDE prgdir.inc
EXTERNAL VAR
log_record: log_file_record;
PUBLIC
PROCEDURE log_write;
VAR
log_file: FILE OF log_file_record;
BEGIN
  log_record.run_time := RUNTIME - log_record.run_time;
  RESET (log_file, 'DSK:PASCAL.LOG' || prgm_dir ());
  IF iostatus = IO_OK THEN BEGIN
    CLOSE (log_file);
    REWRITE (log_file, 'DSK:PASCAL.LOG' || prgm_dir (), [PRESERVE]);
    IF iostatus = IO_OK THEN WRITE (log_file, log_record);
  END;
  CLOSE (log_file);
END.
   
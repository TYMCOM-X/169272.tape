$WIDTH=100
$LENGTH=55
$TITLE paslog.pas, last modified 5/10//83, zw
MODULE paslog
  OPTIONS SPECIAL(WORD, COERCIONS);
  (*log compiler usage statistics*)

$SYSTEM UTLWRT
$SYSTEM UTLTIM
$SYSTEM PRGDIR
$SYSTEM AUTORU
EXTERNAL FUNCTION user_ppn : machine_word;


$PAGE paslog declarations
$INCLUDE PASLOG.TYP

PUBLIC VAR log_record: log_file_record; (*global log record*)

$PAGE log_start and log_write
PUBLIC PROCEDURE log_start;
  (*prepare the standard log record skeleton*)
  VAR jbver : ^INTEGER;
  BEGIN
    jbver := ptr(137B);
    WITH log_record DO BEGIN
      run_time := RUNTIME;
      version := jbver^;
      users_ppn := user_ppn();
      opt_tmpcor := false;
      opt_hash := false
      END
    END;

PUBLIC PROCEDURE log_write;
  (*append completed log record to log file*)
  VAR log_file: FILE OF log_file_record;
  BEGIN
    log_record.run_time := RUNTIME - log_record.run_time;
    RESET(log_file, 'DSK:PASCAL.LOG' || prgm_dir());
    IF IOSTATUS = IO_OK THEN BEGIN (*log file exists*)
      CLOSE(log_file);
      REWRITE(log_file, 'DSK:PASCAL.LOG' || prgm_dir(), [PRESERVE]);
      IF IOSTATUS = IO_OK THEN BEGIN
        WRITE(log_file, log_record);
        CLOSE(log_file);
        END
      ELSE barf('Can not write log record.')
      END
    ELSE (*no log file -- don't write log record*)
    END.
   
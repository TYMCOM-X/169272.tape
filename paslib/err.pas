MODULE err;
(*error handler*)

$SYSTEM setup

$INCLUDE err.typ

PUBLIC PROCEDURE open_err; FORWARD;
(*open error log file*)

PUBLIC PROCEDURE barf(msg: STRING[*]); FORWARD;
(*display message and STOP*)

PUBLIC PROCEDURE sgnl_err(msg: STRING[*]); FORWARD;
(*display message to OUTPUT file and TTY, set error flag*)

PUBLIC VAR err: BOOLEAN := FALSE;
(*error flag set TRUE when error signaled*)

CONST err_fil_nam = 'ERR.LOG';

VAR err_fil: TEXT := NILF;

PROCEDURE open_err;
BEGIN (*open error log file*)
  RESET(err_fil, err_fil_nam, [RETRY]);
  IF IOSTATUS = IO_OK THEN BEGIN
    CLOSE(err_fil); REWRITE(err_fil, err_fil_nam, [PRESERVE])
  END
  ELSE err_fil := NILF
END;

PROCEDURE barf(msg: STRING[*]);
BEGIN (*display message and STOP*)
  tty_on; WRITELN('barf: ', msg); BREAK; tty_off;
  IF err_fil <> NILF THEN WRITELN(err_fil, 'barf: ', msg);
  CLOSE; STOP
END;

PROCEDURE sgnl_err(msg: STRING[*]);
BEGIN (*display message to OUTPUT file and TTY, set error flag*)
  tty_on; WRITELN('error: ', msg); BREAK; err := TRUE; tty_off;
  IF err_fil <> NILF THEN WRITELN(err_fil, 'error: ', msg)
END.
  
$WIDTH=100
$LENGTH=55
$TITLE PASAST.PAS, last modified 1/16/84, zw
MODULE pasast OPTIONS SPECIAL(WORD);
(*TYM-Pascal compiler -- assertion testing*)

$PAGE system modules

$SYSTEM PASCAL.INC
$SYSTEM PASFIL.INC
$SYSTEM PASIST.INC

$PAGE definitions

(*where are these defined??*)
EXTERNAL function cv_source_id(source_id): STRING;
EXTERNAL procedure err_failure;

$PAGE assert

PUBLIC PROCEDURE assert(condition: BOOLEAN);
(*defined here in lieu of the compiler's assertion checking*)
  PROCEDURE assert_failure;
  VAR n: nam;
  BEGIN
    IF cur_block^.kind = subr_blk THEN n := cur_block^.subr_sym^.name
    ELSE n := cur_block^.id;
    REWRITE(TTY);
$IFNOT PRODUCTION
    WRITE(TTY, 'Continuing after assertion failure in block ');
    WRITELN(TTY, n^.text || ' at ' || cv_source_id (cur_source));
    BREAK(TTYOUTPUT);
$ENDIF
$IF PRODUCTION
    WRITE(TTY, 'Assertion failure in block ');
    WRITELN(TTY, n^.text || ' at ' || cv_source_id (cur_source));
    WRITELN(TTY, 'Please report with stack trace and line number information');
    WRITELN(TTY, 'that is, type REENTER now and report what you see.');
    BREAK(TTYOUTPUT);
    err_failure;
$ENDIF
  END;
BEGIN
  IF NOT condition THEN BEGIN
    TRACE;
    assert_failure
  END;
END.
   
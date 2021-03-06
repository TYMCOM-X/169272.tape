$WIDTH=100
$LENGTH=55
$TITLE PASGLB.PAS, last modified 1/3/84, zw
MODULE pasglb OPTIONS SPECIAL(WORD);
(*TYM-Pascal compiler -- global cross reference file*)

$PAGE system modules

$SYSTEM PASCAL.INC
$SYSTEM PASFIL.INC

$PAGE definitions

PUBLIC VAR
glob_file: TEXT;
in_body: BOOLEAN;

$PAGE glob_init, glob_term

PUBLIC PROCEDURE glob_init;
BEGIN
  REWRITE(glob_file, list_file || '.SYM');
  IF NOT EOF(glob_file) THEN BEGIN
    ttymsg('?unable to open global symbol file: ' || list_file || '.SYM');
    prog_options.global_opt := FALSE
  END;
  in_body := FALSE
END;

PUBLIC PROCEDURE glob_term;
BEGIN
  CLOSE(glob_file)
END.
    
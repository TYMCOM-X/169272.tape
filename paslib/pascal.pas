$WIDTH=100
$LENGTH=55
$TITLE PASCAL.PAS, last modified 10/26/83, zw

PROGRAM PASCAL;
(*TYM-Pascal Compiler Entry Point*)

$HEADER PASCAL.DOC

$PAGE modules, main block

$SYSTEM USRUTL.MOD
$SYSTEM ERRUTL.MOD
$SYSTEM CMDUTL.MOD
$SYSTEM DBGUTL.MOD
$SYSTEM PASENV.MOD

BEGIN
  dbg := TRUE;
  resume(banner);
  rdenv(initial_environment);
  start(banner, version);
  IF err THEN error('could not read initial environment')
  ELSE BEGIN
    bgncmd(command_file, auto_start);
    chain('PASCMD');
  END;
  fatal('could not start compiler')
END.
   
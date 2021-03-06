$WIDTH=100
$LENGTH=55
$TITLE PASENV.PAS, last modified 10/26/83, zw

MODULE pasenv;
(*Global TYM-Pascal Compiler Environment*)

$HEADER PASENV.DOC

$PAGE modules and declarations

$SYSTEM RUNUTL.MOD
$SYSTEM CMDUTL.MOD
$SYSTEM DBGUTL.MOD

$INCLUDE PASENV.DEC

PUBLIC VAR env: envtyp;

$PAGE rdenv, wrenv

PUBLIC PROCEDURE rdenv(envnam: FILE_NAME);
BEGIN
  d('rdenv: ' || envnam)
END;

PUBLIC PROCEDURE wrenv(envnam: FILE_NAME);
BEGIN
  d('wrenv: ' || envnam)
END;

$PAGE getenv, zapenv, chain

PUBLIC PROCEDURE getenv;
BEGIN
  d('getenv');
  rdenv(environment_file);
END;

PUBLIC PROCEDURE zapenv;
VAR envfil: envfiltyp;
BEGIN
  d('zapenv');
  RESET(envfil, environment_file);
  SCRATCH(envfil);
  endcmd
END;

PUBLIC PROCEDURE chain(prognam: FILE_NAME);
BEGIN
  d('chain');
  wrenv(environment_file);
  run(source_account || prognam)
END.    
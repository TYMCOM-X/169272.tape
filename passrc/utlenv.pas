$WIDTH=100
$LENGTH=55
$TITLE UTLENV.PAS, last modified 1/31/84, zw
MODULE utlenv OPTIONS SPECIAL(COERCIONS, WORD);
(*TYM-Pascal heap environment manipulation utilities*)

$INCLUDE UTLENV.TYP

$PAGE definitions

TYPE
frog_pointer = ^ARRAY[1 .. 64000] OF MACHINE_WORD;
(*the frog pointer is needed because PTR() does not take a
  size argument like NEW(), thus PTR() can not be used with 
  flexable array types
  also note the 64000, this is because the compiler does an internal
  calculation of the number of *bits* used by a structure and using
  something like MAXIMUM(INTEGER) would cause an overflow*)

(*where are these defined??*)
EXTERNAL FUNCTION hpwrite(FILE_NAME; env): BOOLEAN;
EXTERNAL FUNCTION hpread(FILE_NAME; BOOLEAN): env;

$PAGE getenv, putenv

PUBLIC PROCEDURE getenv(start_addr, end_addr: INTEGER; block_ptr: env);
(*copy a block of static variables from the heap*)
VAR i: INTEGER; e: frog_pointer;
BEGIN
  IF block_ptr <> NIL THEN BEGIN
    e := PTR(start_addr);
    FOR i := 1 TO end_addr - start_addr
    DO e^[i] := block_ptr^[i]
  END
END;

PUBLIC PROCEDURE putenv(start_addr, end_addr: INTEGER; VAR block_ptr: env);
(*put blocks of static variables onto the heap, allocate heap area used*)
VAR i: INTEGER; e: frog_pointer;
BEGIN
  NEW(block_ptr, end_addr - start_addr);
  e := PTR(start_addr);
  FOR i := 1 TO end_addr - start_addr
  DO block_ptr^[i] := e^[i]
END;

$PAGE wrenv, rdenv

PUBLIC FUNCTION wrenv(n: FILE_NAME; e: env): BOOLEAN;
(*write environment into binary file*)
VAR nam: FILE_NAME; fil: FILE OF *;
BEGIN
  IF e <> NIL THEN BEGIN
    RESET(fil, n);
    IF FILENAME(fil) = '' THEN REWRITE(fil, n);
    nam := FILENAME(fil);
    CLOSE(fil);
    wrenv := hpwrite(nam, e)
  END
END;

PUBLIC FUNCTION rdenv(n: FILE_NAME; del: BOOLEAN; VAR e: env): BOOLEAN;
(*read environment from binary file, may delete file*)
VAR nam: FILE_NAME; fil: FILE OF *;
BEGIN
  RESET(fil, n);
  nam := FILENAME(fil);
  rdenv := NOT EOF(fil) AND (nam <> '');
  CLOSE(fil);
  IF rdenv THEN BEGIN
    e := hpread(nam, del);
    rdenv := e <> NIL
  END
END.
 
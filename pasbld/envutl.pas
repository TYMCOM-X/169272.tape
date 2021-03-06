$TITLE ENVUTL.PAS, last modified 1/31/84, zw
MODULE envutl OPTIONS SPECIAL(COERCIONS, WORD);
(*TYM-Pascal heap environment manipulation utilities*)

(*HEADER ENVUTL.HDR*)

$SYSTEM TYPUTL.TYP
$INCLUDE ENVUTL.TYP

TYPE
environment_record = ARRAY[1 .. *] OF MACHINE_WORD;
frog_pointer = ^ARRAY[1 .. 64000] OF MACHINE_WORD;
(*The frog_pointer is needed because PTR() does not take a size argument 
  like NEW(), thus PTR() can not be used with flexable array types.  Also
  note the 64000. this is because the compiler does an internal calculation
  of the number of *bits* used by a structure and using something like
  MAXIMUM(INTEGER) would cause an overflow.*)

(*these are defined in the MODFIT module of the runtime library*)
EXTERNAL FUNCTION hpwrite(file_name; environment): yes_no;
EXTERNAL FUNCTION hpread(file_name; yes_no): environment;

PUBLIC PROCEDURE getenv(start_addr, end_addr: INTEGER; block_ptr: environment);
(*Copy a block of static variables from the heap.*)
VAR i: INTEGER; e: frog_pointer;
BEGIN
  IF block_ptr <> NIL THEN BEGIN
    e := PTR(start_addr);
    FOR i := 1 TO end_addr - start_addr DO e^[i] := block_ptr^[i]
  END
END;

PUBLIC PROCEDURE putenv
  (start_addr, end_addr: INTEGER; VAR block_ptr: environment);
(*Put blocks of static variables onto the heap, allocate heap area used.*)
VAR i: INTEGER; e: frog_pointer;
BEGIN
  NEW(block_ptr, end_addr - start_addr);
  e := PTR(start_addr);
  FOR i := 1 TO end_addr - start_addr DO block_ptr^[i] := e^[i]
END;

PUBLIC FUNCTION wrenv(n: file_name; e: environment): yes_no;
(*Try to write an environment to a binary file*)
VAR nam: file_name; fil: binary_file;
BEGIN
  IF e <> NIL THEN BEGIN
    RESET(fil, n);
    IF FILENAME(fil) = '' THEN REWRITE(fil, n);
    nam := FILENAME(fil);
    CLOSE(fil);
    wrenv := hpwrite(nam, e)
  END
END;

PUBLIC FUNCTION rdenv(n: file_name; del: yes_no; VAR e: environment): yes_no;
(*Try to read an environment from a binary file, may delete the file.*)
VAR nam: file_name; fil: binary_file;
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
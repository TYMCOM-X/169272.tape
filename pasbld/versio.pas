$TITLE VERSION.PAS, last modified 5/11/84, zw
MODULE version OPTIONS special (coercions, word);
(*TYM-Pascal version utility*)
$HEADER VERSIO.HDR
$PAGE version

(*  Version returns a string containing the program version identifier.
    The version is taken from .JBVER, which is at absolute location 137B,
    and contains the fields:

	bits 0-2:    "last modified by"
	bits 3-11:   major version number
	bits 12-17:  minor version number
	bits 18-35:  edit number                                        *)

TYPE
version_string = STRING [15];
PUBLIC
FUNCTION version: version_string;
TYPE
version_word = PACKED RECORD
  mod_code: 0..7;
  major_version: 0..777b;
  minor_version: 0..77b;
  edit_number: 0..777777b
END;
VAR
version_ptr: ^ version_word;
TYPE
oct = 0 .. 100000b;
VAR
step: oct;

  FUNCTION digit ( od: oct ): CHAR;
  BEGIN
    digit := CHR (ORD ('0') + (od MOD 10b));
  END;
BEGIN
  version_ptr := PTR (137b);
  WITH version_ptr^ DO BEGIN
    version := '';
    IF major_version >= 100b THEN version := version || digit (major_version
      DIV 100b);
    IF major_version >= 10b THEN version := version || digit (major_version
      DIV 10b);
    version := version || digit (major_version);
    IF minor_version > 26 THEN version := version || CHR (ORD (PRED ('A'))
      + (minor_version DIV 26));
    IF minor_version <> 0 THEN version := version || CHR (ORD (PRED ('A'))
      + (minor_version MOD 26));
    IF edit_number <> 0 THEN BEGIN
      version := version || '(';
      step := 100000b;
      WHILE step <> 0 DO BEGIN
	IF edit_number >= step THEN version := version || digit (edit_number
	  DIV step);
	step := step DIV 10b;
      END;
      version := version || ')';
    END;
    IF mod_code <> 0 THEN version := version || '-' || digit (mod_code);
  END;
END.
  
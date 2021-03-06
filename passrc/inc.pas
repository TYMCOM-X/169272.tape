$WIDTH=100
$LENGTH=55
$TITLE INC.PAS, last modified 2/6/84, zw
PROGRAM inc;
(*TYM-Pascal program to evaluate $INCLUDE and $SYSTEM source directives*)
(*this is a test of the source file reader utility*)

$SYSTEM UTLIO.INC
$SYSTEM UTLRDR.INC

VAR
line: STRING[132] := '';
end_of_file: BOOLEAN := FALSE;

$PAGE interface to reader utility -- rd, err1, err2, new_file

FUNCTION rd(VAR l: STRING[*]): BOOLEAN;
(*read function used by reader utility*)
BEGIN
  LOOP
    EXIT IF rdlin(line) DO l := UPPERCASE(line);
    EXIT IF NOT popin DO end_of_file := TRUE
  END;
  rd := NOT end_of_file
END;

PROCEDURE err1(csr: INTEGER);
(*"not a key" error function used by reader utility*)
BEGIN
  ttymsg('? not a key: "' || SUBSTR(line, csr) || '"');
END;

PROCEDURE err2(csr: INTEGER);
(*"not a directive" error function used by reader utility*)
BEGIN
  (*ignore it*)
END;

PROCEDURE new_file(csr: INTEGER);
(*new file function for $INCLUDE or $SYSTEM directives*)
VAR fil: FILE_NAME; pos, len: INTEGER;
BEGIN
  pos := MAX(1, MIN(csr, LENGTH(line) + 1));
  len := MIN(UPPERBOUND(FILE_NAME), LENGTH(line) - pos + 1);
  fil := SUBSTR(line || ' ', pos, len);
  IF INDEX(fil, '.') = 0 THEN fil := fil || '.INC';
  IF (NOT EOF ANDIF NOT pushin(fil)) ORIF NOT opnin(fil, TRUE)
  THEN ttymsg('? can not read file: "' || fil || '"');
  srcrdr
END;

$PAGE read_line, write_line, main block

PROCEDURE read_line;
(*read next source line, uses reader utility*)
BEGIN
  srcrdr
END;

PROCEDURE write_line;
(*write current source line*)
BEGIN
  wrlin(line)
END;

VAR
lst: ARRAY[1 .. 2] OF rdr_rcd;
inam, onam: FILE_NAME;

BEGIN
  lst[1] := ('INCLUDE', 7, new_file); lst[2] := ('SYSTEM', 6, new_file);
  rdyio;
  bgnrdr(rd, err1, err2, lst);
  ttymsg('This program evaluates $INCLUDE and $SOURCE source directives.');
  asktty('Enter input file name: ', inam);
  IF opnin(inam, TRUE) THEN BEGIN
    asktty('Enter output file name: ', onam);
    IF opnout(onam, TRUE) THEN BEGIN
      WHILE NOT end_of_file DO BEGIN read_line; write_line END;
      clsout
    END
    ELSE ttymsg('? can not open output');
    clsin
  END
  ELSE ttymsg('? can not open input');
  endrdr
END.
  
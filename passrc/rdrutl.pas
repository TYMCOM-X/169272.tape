$WIDTH=100
$LENGTH=55
$TITLE UTLRDR.PAS, last modified 2/3/84, zw
MODULE utlrdr;
(*TYM-Pascal reader utility*)

$HEADER UTLRDR.HDR

$PAGE system modules

$SYSTEM UTLKEY.INC

$INCLUDE UTLRDR.TYP

$PAGE definitions

VAR
directive_function: ^ARRAY [1 .. *] OF PROCEDURE(INTEGER) := NIL;
directive_list: ^ARRAY [1 .. *] OF key_rcd := NIL;
key_error: reader_error_procedure;
directive_error: reader_action_procedure;
read_next_line: read_line_procedure;
reader_status: (ready, not_ready) := not_ready;
line, key: STRING; (*used in srcrdr*)
line_cursor, error_index, key_code: INTEGER; (*used in srcrdr*)

$PAGE endrdr, bgnrdr

PUBLIC PROCEDURE endrdr;
(*finished with reader utility*)
BEGIN
  IF reader_status = ready THEN BEGIN
    DISPOSE(directive_function);
    DISPOSE(directive_list)
  END;
  reader_status := not_ready
END;

PUBLIC PROCEDURE bgnrdr
  (r: FUNCTION(VAR STRING[*]): BOOLEAN; e1: PROCEDURE(INTEGER);
  e2: PROCEDURE(INTEGER); arg: ARRAY [1 .. *] OF rdr_rcd);
(*set up reader utility*)
VAR i: INTEGER;
BEGIN
  IF reader_status <> not_ready THEN endrdr;
  ASSERT(reader_status = not_ready);
  read_next_line := r;
  key_error := e1;
  directive_error := e2;
  NEW(directive_function, UPPERBOUND(arg));
  FOR i := 1 TO UPPERBOUND(arg) DO directive_function^[i] := arg[i].action;
  NEW(directive_list, UPPERBOUND(arg));
  FOR i := 1 TO UPPERBOUND(arg) DO WITH directive_list^[i] DO BEGIN
    key := arg[i].key;
    abbrev := arg[i].abbrev;
    code := i
  END;
  reader_status := ready
END;

$PAGE srcrdr

PUBLIC VAR dirflg: CHAR := '$'; (*flags directive*)

PUBLIC PROCEDURE srcrdr;
(*read next line, process any directive*)
BEGIN
  ASSERT(reader_status = ready);
  IF read_next_line(line) ANDIF (line <> '') ANDIF (line[1] = dirflg)
  THEN BEGIN
    line_cursor := 2;
    error_index := line_cursor;
    IF scnkey(line, line_cursor, ['A' .. 'Z'], key) THEN BEGIN
      IF lkpkey(key, directive_list^, key_code)
      THEN directive_function^[key_code](line_cursor) (*may not return*)
      ELSE directive_error(error_index)
    END
    ELSE key_error(error_index)
  END
END.
  
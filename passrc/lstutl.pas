$TITLE LSTUTL.PAS, last modified 3/9/84, zw
MODULE lstutl;
(*TYM-Pascal listing utility*)

(*HEADER LSTUTL.HDR*)

$SYSTEM TYPUTL.TYP
$SYSTEM FIOUTL.INC
$INCLUDE LSTUTL.TYP

PUBLIC PROCEDURE lstrdy(VAR fcb: list_file);
(*ready the list file control block -- make sure the file is open*)
BEGIN
  WITH fcb DO
    IF output_file = NILF THEN assume
      (opnfil(output_file, name, append_mode), '?Can not list to: ' || name)
END;

PUBLIC PROCEDURE lstnop(VAR fcb: list_file);
(*no action, used for default pag_hdr procedure*)
BEGIN
  lstrdy(fcb)
END;

PUBLIC PROCEDURE lstff(VAR fcb: list_file);
(*emit form feed, default new_pag procedure*)
BEGIN
  lstrdy(fcb);
  WITH fcb DO BEGIN
    IF CURSOR(output_file) > 1 THEN WRITELN(output_file);
    PAGE(output_file)
  END
END;

PUBLIC PROCEDURE lstatt(VAR fcb: list_file; output_file: text_file);
(*set up file control block for open file*)
BEGIN
  fcb.output_file := output_file;
  lstrdy(fcb);
  WITH fcb DO BEGIN
    name := FILENAME(output_file);
    page_number := 1;
    line_number := 1;
    column := 1;
    continue_column := 0;
    page_width := maximum_page_width;
    page_length := 0;
    footing := lstnop;
    heading := lstnop;
    eject := lstff
  END
END;

PUBLIC FUNCTION lstopn(VAR fcb: list_file; name: file_name): yes_no;
(*try to set up list file control block for specified file*)
BEGIN
  lstopn := opnfil(fcb.output_file, name, write_mode);
  IF lstopn THEN lstatt(fcb, fcb.output_file)
END;

PUBLIC PROCEDURE lstcls(VAR fcb: list_file);
(*temporarily close list file*)
BEGIN
  lstrdy(fcb);
  clsfil(fcb.output_file)
END;

PUBLIC PROCEDURE lstpag(VAR fcb: list_file);
(*force new page*)
BEGIN
  WITH fcb DO BEGIN
    IF column <> 1 THEN WRITELN(output_file); (*finish current line*)
    IF NOT ((line_number = 1)  AND (column = 1)) THEN BEGIN (*if inside page*)
      footing(fcb);
      eject(fcb);
      page_number := page_number + 1;
      line_number := 1;
      column := 1
    END;
    heading(fcb)
  END
END;

PUBLIC PROCEDURE lstskp(VAR fcb: list_file);
(*move output to beginning of new line, maybe prepare for new page*)
BEGIN
  lstrdy(fcb);
  WITH fcb DO BEGIN
    IF (column = 1) AND (page_length <> 0) AND (line_number > page_length)
    THEN lstpag(fcb)
    ELSE BEGIN
      line_number := line_number + 1;
      column := 1;
      IF NOT ((page_length <> 0) AND (line_number > page_length))
      THEN WRITELN(output_file)
    END
  END
END;

PUBLIC PROCEDURE lstnskp(VAR fcb: list_file; nskip, nleft: list_length_range);
(*skip n times, new page in not speficied number of lines left*)
VAR i: list_length_range;
BEGIN
  lstrdy(fcb);
  WITH fcb DO BEGIN
    IF (column = 1) AND (page_length <> 0) AND (line_number > page_length)
    THEN lstpag(fcb)
    ELSE BEGIN
      column := 1;
      IF (page_length = 0) ORIF (line_number + nskip + nleft <= page_length)
      THEN FOR i := 1 TO nskip DO lstskp(fcb)
      ELSE line_number := page_length + 1 (*prepare FOR new page*)
    END
  END
END;

PUBLIC PROCEDURE lsttab(VAR fcb: list_file; columnpos: list_width_range);
(*move to specified columnumn position, maybe start new line*)
VAR i, pos: list_width_range;
CONST tab = CHR(#o011);
BEGIN
  lstrdy(fcb);
  WITH fcb DO BEGIN
    pos := MIN(columnpos, page_width);
    IF column > pos THEN lstskp(fcb);
    IF column = pos THEN RETURN;
    IF (column = 1) AND (page_length <> 0) AND (line_number > page_length)
    THEN lstpag(fcb);
    FOR i := 1 TO (((pos - 1) DIV 8) - ((column - 1) DIV 8))
    DO WRITE(output_file, tab);
    WRITE(output_file, ' ': MIN((pos - 1) MOD 8, pos - column));
    column := pos
  END
END;

PUBLIC PROCEDURE lststr(VAR fcb: list_file; str: generic_string);
(*write string to list file within line and page bounds*)
VAR idx, len: positive_integer;
BEGIN
  lstrdy(fcb);
  WITH fcb DO BEGIN
    IF (column = 1) AND (page_length <> 0) AND (line_number > page_length)
    THEN lstpag(fcb);
    IF (LENGTH(str) > page_width - column + 1) AND
      (LENGTH(str) <= page_width - continue_column + 1) AND
      (continue_column <> 0)
    THEN lsttab(fcb, continue_column);
    idx := 1;
    LOOP
      len := MIN(LENGTH(str) - idx + 1, page_width - column + 1);
      WRITE(output_file, SUBSTR(str, idx, len));
      idx := idx + len;
      column := column + len;
      EXIT IF (idx > LENGTH(str)) OR (continue_column = 0);
      lsttab(fcb, continue_column);
    END
  END
END;

PUBLIC PROCEDURE lstlin(VAR fcb: list_file; str: generic_string);
(*write string to list file and skip to new line*)
BEGIN
  lstrdy(fcb);
  lststr(fcb, str);
  lstskp(fcb)
END;

PUBLIC PROCEDURE lstspc(VAR fcb: list_file; spaces: positive_integer);
(*write number of spaces to list file*)
BEGIN
  lsttab(fcb, fcb.column + spaces)
END.
  
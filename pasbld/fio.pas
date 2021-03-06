$TITLE FIO.PAS, lst modified 5/11/84, zw
MODULE fio;
(*TYM-Pascal formated output package*)
$INCLUDE fio.typ
$PAGE fio_nop
(* FIO NOP performs no action.  It is used as the page_header procedure when no
   header is required, e.g. the default case. *)
PUBLIC
PROCEDURE fio_nop (VAR fb: file_block);
BEGIN
END;
$PAGE fio_eject
(* FIO EJECT emits a form feed to the output file.  It is used as the new_page
   procedure in the default case, when the output file is intended for the
   line printer. *)
PUBLIC
PROCEDURE fio_eject ( VAR fb: file_block );
BEGIN
  WITH fb DO page (file_var);
END;
$PAGE fio_open
(* FIO OPEN opens a specified text file for output and initializes the control
   block to default values. *)
PUBLIC
PROCEDURE fio_open (VAR fb: file_block;
  FILE_NAME: PACKED ARRAY [1..*] OF CHAR);
BEGIN
  WITH fb DO BEGIN
    REWRITE (file_var, FILE_NAME);
    file_title := FILENAME (file_var);
    pageno := 1;
    lineno := 1;
    column := 1;
    width := max_width;
    c_column := 0;
    plength := 0;
    new_page := fio_eject;
    page_header := fio_nop;
  END (* with *);
END;
$PAGE fio_reopen
(* FIO REOPEN opens a specified text file for continued output.  The file is
   opened in append mode, and the control block is *not* reinitialized.  It is
   assumed that it has been previously opened with fio_open. *)
PUBLIC
PROCEDURE fio_reopen (VAR fb: file_block);
BEGIN
  REWRITE (fb.file_var, fb.file_title, [PRESERVE]);
END;
$PAGE fio_attach
(* FIO ATTACH takes a file which has already been opened for output, and
   initializes a control block for it. *)
PUBLIC
PROCEDURE fio_attach (VAR fb: file_block; fil: TEXT);
BEGIN
  WITH fb DO BEGIN
    file_var := fil;
    file_title := FILENAME (fil);
    pageno := 1;
    lineno := 1;
    column := 1;
    width := max_width;
    c_column := 0;
    plength := 0;
    new_page := fio_eject;
    page_header := fio_nop;
  END (* with *);
END;
$PAGE fio_close
(* FIO CLOSE closes a file opened by fio_open or fio_reopen.  The control block
   is not modified in order that a subsequent reopen call may be made. *)
PUBLIC
PROCEDURE fio_close (VAR fb: file_block);
BEGIN
  CLOSE (fb.file_var);
END;
$PAGE fio_page
(* FIO PAGE forces the output file to the top of a page (invoking the new_page
   routine if necessary), and then invokes the page_header routine. *)
PUBLIC
PROCEDURE fio_page (VAR fb: file_block);
BEGIN
  WITH fb DO BEGIN
    IF column <> 1 THEN WRITELN (file_var);
    IF (lineno <> 1) OR (column <> 1) THEN BEGIN (* don't page if already at top of page *)
      new_page (fb);
      pageno := pageno + 1;
      lineno := 1;
      column := 1;
    END;
    page_header (fb); (* emit header, if any *)
  END;
END;
$PAGE fio_skip
(* FIO SKIP moves the output to the beginning of a new line.  The state of the
   file block is altered so that if a page is overflowed, the next output operation
   will cause a skip to the top of a new page. *)
PUBLIC
PROCEDURE fio_skip (VAR fb: file_block);
BEGIN
  WITH fb DO BEGIN
    IF (column = 1) ANDIF (plength <> 0) ANDIF (lineno > plength)
      THEN fio_page (fb)
    ELSE BEGIN
      lineno := lineno + 1;
      column := 1;
      IF (plength = 0) ORIF (lineno <= plength) THEN WRITELN (file_var); (* No eoln if new page coming. *)
    END;
  END;
END;
$PAGE fio_nskip
(* FIO NSKIP is equivalent to N calls to fio_skip, except that it will never
   write beyond the top of a new page.  Fio_nskip will also test whether there
   are M lines remaining on the current page, and will force a page skip if
   there are not. *)
PUBLIC
PROCEDURE fio_nskip ( VAR fb: file_block; nskip, nleft: INTEGER );
VAR
i: INTEGER;
BEGIN
  WITH fb DO BEGIN
    IF (column = 1) ANDIF (plength <> 0) ANDIF (lineno > plength)
      THEN fio_page (fb)
    ELSE BEGIN
      column := 1;
      IF (plength = 0) ORIF (lineno + nskip + nleft <= plength) THEN BEGIN
	FOR i := 1 TO nskip DO WRITELN (file_var);
	lineno := lineno + nskip;
      END
      ELSE lineno := plength + 1;
    END;
  END;
END;
$PAGE fio_tab
(* FIO TAB moves the output to a specified column position.  If the target column
   lies before the current column position, a new line is started before tabbing. *)
PUBLIC
PROCEDURE fio_tab (VAR fb: file_block; tabcol: fio_width);
VAR
i, tcol: fio_width;
CONST
ht = CHR (011b);
BEGIN
  WITH fb DO BEGIN
    tcol := MIN (tabcol, width);
    IF column > tcol THEN fio_skip (fb);
    IF column = tcol THEN RETURN;
    IF (column = 1) ANDIF (plength <> 0) ANDIF (lineno > plength)
      THEN fio_page (fb);
    FOR i := 1 TO (((tcol - 1) DIV 8) - ((column - 1) DIV 8))
      DO WRITE (file_var, ht);
    WRITE (file_var, ' ': MIN ((tcol - 1) MOD 8, tcol - column));
    column := tcol;
  END;
END;
$PAGE fio_write
(* FIO WRITE outputs a string to the file.  Page width and length limitations are
   checked for and enforced. *)
PUBLIC
PROCEDURE fio_write (VAR fb: file_block; str: PACKED ARRAY [1..*] OF CHAR);
VAR
idx, l: INTEGER;
BEGIN
  WITH fb DO BEGIN
    IF (column = 1) ANDIF (plength <> 0) ANDIF (lineno > plength)
      THEN fio_page (fb);
    IF (LENGTH (str) > width - column + 1) AND (LENGTH (str)
      <= width - c_column + 1) AND (c_column <> 0) THEN fio_tab (fb, c_column)
      ;
    idx := 1;
    LOOP
      l := MIN (LENGTH (str) - idx + 1, width - column + 1);
      WRITE (file_var, SUBSTR (str, idx, l));
      idx := idx + l;
      column := column + l;
      EXIT IF (idx > LENGTH(str)) OR (c_column = 0);
      fio_tab (fb, c_column);
    END;
  END (* with fb *);
END;
$PAGE fio_line
(* FIO LINE writes a string to a file and skips to a new line.  Page width and
   length limitations are applied. *)
PUBLIC
PROCEDURE fio_line (VAR fb: file_block; str: PACKED ARRAY [1..*] OF CHAR);
BEGIN
  fio_write (fb, str);
  fio_skip (fb);
END;
$PAGE fio_space
(* FIO SPACE emits a specified number of spaces to the output file. *)
PUBLIC
PROCEDURE fio_space ( VAR fb: file_block; spaces: fio_width);
BEGIN
  fio_tab (fb, fb.column+spaces);
END.
  
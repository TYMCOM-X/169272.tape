PROGRAM entab;
  (*replace blanks by tabs and blanks*)

$SYSTEM TOOLS

TYPE tabs_typ = ARRAY [1 .. maxline] OF BOOLEAN;

PROCEDURE settab(VAR tabs: tabs_typ);
  (*set initial tab stops*)
  VAR i: INTEGER;
  BEGIN
    FOR i := 1 TO maxline DO tabs[i] := ((i MOD 8) = 1)
    END;

FUNCTION tabpos(col: INTEGER; tabs: tabs_typ): BOOLEAN;
  (*return TRUE if col is a tab stop*)
  BEGIN
    tabpos := (col < 1) ORIF (col > maxline) ORIF tabs[col]
    END;

VAR c: CHAR;
VAR col, newcol: INTEGER;
VAR tabs: tabs_typ;

BEGIN
  setup('EN-TAB');
  WHILE getio DO BEGIN
    settab(tabs);
    col := 1;
    newcol := 1;
    WHILE getc(c) DO
      IF c = blank THEN BEGIN
        newcol := newcol + 1;
        IF tabpos(newcol, tabs) THEN BEGIN
          putc(tab);
          col := newcol
          END
        END
      ELSE BEGIN
        FOR col := col TO newcol - 1 DO putc(blank);
        putc(c);
        IF c = newline THEN col := 1 ELSE col := col + 1;
        newcol := col
        END;
    FOR col := col TO newcol - 1 DO putc(blank)
    END
  END.
 
PROGRAM trans;
  (*transliterate input to output*)

$SYSTEM TOOLS

FUNCTION idxset(c: CHAR; chrs: PACKED ARRAY [*] OF CHAR): INTEGER;
  (*return the position of character c within the set, or zero*)
  BEGIN
    idxset := 1;
    WHILE (idxset <= UPPERBOUND(chrs)) ANDIF (chrs[idxset] <> eos) DO BEGIN
      EXIT IF chrs[idxset] = c;
      idxset := idxset + 1
      END;
    IF (idxset > UPPERBOUND(chrs)) ORIF (chrs[idxset] = eos) THEN idxset := 0
    END;

PROCEDURE insertc(c: CHAR;
  VAR chrs: PACKED ARRAY [*] OF CHAR; maxlen: INTEGER);
  (*insert char c into set*)
  VAR i: INTEGER;
  BEGIN
    IF idxset(c, chrs) = 0 THEN BEGIN
      FOR i := 1 TO maxlen DO EXIT IF chrs[i] = eos;
      chrs[i] := c;
      IF i < maxlen THEN i := i + 1;
      chrs[i] := eos
      END
    END;

PROCEDURE deletec(c: CHAR;
  VAR chrs: PACKED ARRAY [*] OF CHAR; maxlen: INTEGER);
  (*delete char c from set*)
  VAR i: INTEGER;
  BEGIN
    i := idxset(c, chrs);
    IF i > 0 THEN BEGIN
      FOR i := i TO maxlen - 1 DO chrs[i] := chrs[i + 1];
      chrs[maxlen] := eos
      END
    END;

$PAGE get character set argument
FUNCTION getset(n: INTEGER;
  VAR chrs: PACKED ARRAY [*] OF CHAR; maxlen: INTEGER): INTEGER;
  (*get the nth set argument, return its length*)
  VAR arg: PACKED ARRAY [1 .. 30] OF CHAR;
  VAR arglen: 0 .. 30;
  VAR i: INTEGER;
  VAR c: CHAR;
  VAR inverse: BOOLEAN;
  PROCEDURE scan;
    BEGIN (*handle quotes, newlines, blanks and tabs*)
      IF (arg[i] = quote) ANDIF (i < arglen) THEN i := i + 1
      ELSE IF (arg[i] IN ['N', 'n']) ANDIF (i < arglen)
        ANDIF (arg[i + 1] IN ['L', 'l']) THEN BEGIN
          i := i + 1; arg[i] := newline
          END
      ELSE IF (arg[i] IN ['B', 'b']) ANDIF (i < arglen)
        ANDIF (arg[i + 1] IN ['L', 'l']) THEN BEGIN
          i := i + 1; arg[i] := blank
          END
      ELSE IF (arg[i] IN ['T', 't']) ANDIF (i < arglen)
        ANDIF (arg[i + 1] IN ['B', 'b']) THEN BEGIN
          i := i + 1; arg[i] := tab
          END
      END;
  BEGIN
    FOR i := 1 TO maxlen DO chrs[i] := eos;
    arglen := getarg(n, arg, 30);
    IF arglen = 0 THEN getset := 0
    ELSE BEGIN
      inverse := (arglen > 1) ANDIF (arg[1] = '#');
      IF inverse THEN i := 2 ELSE i := 1;
      IF inverse THEN FOR c := MINIMUM(CHAR) TO MAXIMUM(CHAR) DO
        insertc(c, chrs, maxlen);
      WHILE i <= arglen DO BEGIN
        IF (arg[i] = '-') ANDIF (i > 1) ANDIF (i < arglen) THEN BEGIN
          c := arg[i - 1]; i := i + 1; scan;
          FOR c := c TO arg[i] DO
          IF inverse THEN deletec(arg[i], chrs, maxlen)
          ELSE insertc(arg[i], chrs, maxlen)
          END
        ELSE BEGIN
          scan;
          IF inverse THEN deletec(arg[i], chrs, maxlen)
          ELSE insertc(arg[i], chrs, maxlen)
          END;
        i := i + 1
        END;
      getset := 0;
      WHILE (getset + 1) <= maxlen DO BEGIN
        EXIT IF chrs[getset + 1] = eos;
        getset := getset + 1
        END
      END
    END;

$PAGE straight and collapsing transliteration
PROCEDURE straighttrans(fromset, toset: PACKED ARRAY [*] OF CHAR);
  (*straight transliteration*)
  VAR c: CHAR;
  VAR position: INTEGER;
  BEGIN
    WHILE getc(c) DO BEGIN
      position := idxset(c, fromset);
      IF position > 0 THEN putc(toset[position]) ELSE putc(c)
      END
    END;

PROCEDURE collapsetrans(fromset, toset: PACKED ARRAY [*] OF CHAR);
  (*collapsing transliteration*)
  VAR inrun: BOOLEAN;
  VAR c: CHAR;
  BEGIN
    inrun := FALSE;
    WHILE getc(c) DO BEGIN
      IF idxset(c, fromset) > 0 THEN BEGIN
        IF NOT inrun THEN BEGIN
          putc(toset[1]); inrun := TRUE
          END
        END
      ELSE BEGIN
        putc(c); inrun := FALSE
        END
      END
    END;

CONST maxsetlen = ORD(MAXIMUM(CHAR));
VAR fromset, toset: PACKED ARRAY [0 .. maxsetlen] OF CHAR;

BEGIN
  setup('TRANSLITERATE');
  WHILE getio DO
    IF getset(1, fromset, maxsetlen) > getset(2, toset, maxsetlen) THEN
      collapsetrans(fromset, toset)
    ELSE
      straighttrans(fromset, toset)
  END.
   
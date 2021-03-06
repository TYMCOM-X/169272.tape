$WIDTH=100
$LENGTH=55
$TITLE RDYRNO.PAS, last modified 10/14/83, zw

PROGRAM rdyrno;
(*ready text before RUNOFF*)

$SYSTEM pasutl

VAR
    lin: STRING[132];

PROCEDURE mark_caps(VAR s: STRING[*]);

VAR
    i: INTEGER;

BEGIN (*mark capital letters with '^'*)
  i := 1;
  WHILE i <= LENGTH(s) DO BEGIN
    IF s[i] IN ['A' .. 'Z'] THEN BEGIN
      s := SUBSTR(s, 1, i - 1) || '^' || SUBSTR(s, i);
      i := i + 1
    END;
    i := i + 1
  END
END;

BEGIN
  WHILE start('RDYRNO', '') DO BEGIN
    wrlin('.RIGHT MARGIN 60');
    wrlin('.LEFT MARGIN 0');
    wrlin('.PARAGRAPH');
    lin := '';
    WHILE rdlin(lin) DO BEGIN
      ;
      mark_caps(lin);
      IF lin = '' THEN
	wrlin('.PARAGRAPH')
      ELSE
	wrlin(UPPERCASE(lin))
    END
  END
END.
   
(*tools.typ, last modified 5/16/83, zw*)
$IFNOT toolstyp

CONST eos = CHR(0); newline = CHR(10); newpage = CHR(12);
CONST backspace = CHR(8); noskip = CHR(13); bell = CHR(7);
CONST blank = ' '; tab = CHR(9); comma = ','; quote = '''';

CONST maxline = 79; (*maximum line length*)

$ENABLE toolstyp
$ENDIF
(*end of tools.typ*)
  
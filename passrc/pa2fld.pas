$WIDTH=100
$LENGTH=55
$TITLE PA2FLD.PAS, last modified 1/16/84, zw
MODULE pa2fld OPTIONS SPECIAL(WORD);
(*TYM-Pascal compiler -- constant expression folding, pass 2*)

$ENABLE pass2

$PAGE system modules

$SYSTEM pascal.inc
$SYSTEM pasist.inc
$SYSTEM paspt.typ
$SYSTEM pasif.typ
$SYSTEM pasifu.inc
$SYSTEM pasval.inc
$SYSTEM pasesu.inc
$SYSTEM paserr.inc

$INCLUDE pasfld.pas
    
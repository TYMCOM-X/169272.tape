$PAGE UTLENV.TYP, last modified 1/13/84, zw
$IFNOT utlenvtyp

TYPE
env = ^env_rcd;
env_rcd = ARRAY[1 .. *] OF MACHINE_WORD;

$ENABLE utlenvtyp
$ENDIF

    
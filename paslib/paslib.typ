(*PASLIB.TYP, last modified 11/7/83, zw*)
$IFNOT paslibtyp

TYPE
heap_area = ^ARRAY [1 .. *] OF MACHINE_WORD;
maximum_area = ^ARRAY [1 .. MAXIMUM(INTEGER)] OF MACHINE_WORD;

$ENABLE paslibtyp
$ENDIF
  
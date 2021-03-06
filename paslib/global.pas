$WIDTH=100
$LENGTH=55
$TITLE PASDAT.PAS, last modified 11/7/83, zw

MODULE pasdat OPTIONS SPECIAL(COERCIONS, WORD);
(*TYM-Pascal Compiler Global Data*)
(*all global, public variable declarations are located in PASDAT.VAR*)

$SYSTEM USRLIB.INC
$SYSTEM PASLIB.INC

VAR
mark_start: BOOLEAN;
mark_version: INTEGER;

$SYSTEM PASDAT.VAR

VAR mark_end: BOOLEAN;

$INCLUDE PASDAT.TYP

PROCEDURE hpput(a, b: INTEGER; VAR h: heap_area);
(*copy data from address a to b into new heap area*)
VAR i: INTEGER; d: maximum_area;
BEGIN
  NEW(h, b - a); d := PTR(a);
  FOR i := 1 TO b - a DO h^[i] := d^[i]
END;

PROCEDURE hpget(a, b: INTEGER; h: heap_area);
(*copy data from heap area into address a to b, dispose heap area*)
VAR i: INTEGER; d: maximum_area;
BEGIN
  assume((h <> NIL), 'lost root pointer to heap');
  d := PTR(a);
  FOR i := 1 TO b - a DO d^[i] := h^[i]; DISPOSE(h)
END;

PUBLIC PROCEDURE datsav(f: FILE_NAME);
(*save global variables on heap, save heap in file*)
VAR h: heap_area;
BEGIN
  CLOSE;
  mark_version := heap_version;
  hpput(ORD(ADDRESS(mark_start)), ORD(ADDRESS(mark_end)), h);
  assume(hpwrite(f, h), 'unable to save heap to ' || f);
  DISPOSE(h)
END;

PUBLIC PROCEDURE datget(f: FILE_NAME; d: BOOLEAN);
(*restore heap from file, maybe delete file, load global variables from heap*)
VAR h: heap_area;
BEGIN
  CLOSE;
  h := hpread(f, d);
  assume((h <> NIL), 'lost root pointer to heap read from ' || f);
  hpget(ORD(ADDRESS(mark_start)), ORD(ADDRESS(mark_end)), h);
  assume((mark_version = heap_version), 'obsolete heap read from ' || f)
END.
   
$WIDTH=100
$LENGTH=55
$TITLE UTLSW.PAS, last modified 1/9/84, zw
MODULE utlsw OPTIONS SPECIAL(WORD);
(*TYM-Pascal switch manipulation utility*)

$INCLUDE UTLSW.TYP

$PAGE find_sw, sw, enasw, popsw

FUNCTION find_sw(head: sw_ptr; nam: sw_str): sw_ptr;
(*search for specified switch, return NIL if not found*)
BEGIN
  find_sw := head;
  WHILE find_sw <> NIL DO BEGIN
    EXIT IF find_sw^.nam = nam;
    find_sw := find_sw^.nxt
  END
END;

PUBLIC FUNCTION sw(head: sw_ptr; nam: sw_str): BOOLEAN;
(*search switch list, return value of switch or FALSE*)
VAR tmp: sw_ptr;
BEGIN
  tmp := find_sw(head, nam);
  IF tmp = NIL THEN sw := FALSE ELSE sw := tmp^.ena
END;

PUBLIC FUNCTION enasw(head: sw_ptr; nam: sw_str; ena: BOOLEAN): sw_ptr;
(*enable new switch at start of list*)
VAR tmp: sw_ptr;
BEGIN
  NEW(tmp, LENGTH(nam));
  tmp^.nam[1:LENGTH(nam)] := nam; tmp^.ena := ena; tmp^.nxt := head;
  enasw := tmp
END;

PUBLIC PROCEDURE popsw(VAR head: sw_ptr; final: sw_ptr);
(*delete switches up specified switch*)
VAR sw, next_sw: sw_ptr;
BEGIN
  sw := head;
  WHILE sw <> final DO BEGIN
    next_sw := sw^.nxt; DISPOSE(sw); sw := next_sw
  END;
  head := final
END;

$PAGE rdsw, wrsw

PUBLIC FUNCTION rdsw(VAR f: FILE OF * ): sw_ptr;
(*read switch list from binary file*)
VAR sw, last_sw: sw_ptr; len: INTEGER;
BEGIN
  rdsw := NIL;
  LOOP
    READ(f, len);
    EXIT IF len = 0;
    NEW(sw, len);
    READ(f, sw^: SIZE(sw^, len));
    sw^.nxt := NIL;
    IF rdsw = NIL THEN rdsw := sw
    ELSE last_sw^.nxt := sw;
    last_sw := sw
  END
END;

PUBLIC PROCEDURE wrsw(head: sw_ptr; VAR f: FILE OF * );
(*write switch list to binary file*)
VAR sw: sw_ptr; len: INTEGER;
BEGIN
  sw := head;
  WHILE sw <> NIL DO BEGIN
    len := LENGTH(sw^.nam); WRITE(f, len, sw^: SIZE(sw^, len));
    sw := sw^.nxt
  END;
  len := 0; WRITE(f, len)
END.
  
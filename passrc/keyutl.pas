$TITLE KEYUTL.PAS, last modified 4/9/84, zw
MODULE keyutl;
(*TYM-Pascal key word utility*)

(*HEADER KEYUTL.HDR*)

$SYSTEM TYPUTL.TYP
$INCLUDE KEYUTL.TYP

PUBLIC FUNCTION scnkey
  (lin: STRING[*]; VAR csr: INTEGER; chr_set: SET OF CHAR;
  VAR key: STRING[*]): BOOLEAN;
(*try to scan a key of the given char set from the line, update cursor*)
VAR len: INTEGER;
BEGIN
  IF (csr > 0) AND (csr <= LENGTH(lin))
  THEN len := VERIFY(SUBSTR(lin, csr), chr_set) - csr + 1
  ELSE len := 0;
  scnkey := len > 0;
  IF scnkey THEN BEGIN
    key := SUBSTR(lin, csr, len);
    csr := csr + len
  END
END;

PUBLIC FUNCTION lkpkey
  (key: STRING[*]; lst: key_list; VAR code: INTEGER): BOOLEAN;
(*try to lookup key in list, set code from matched record*)
VAR low, crnt, hgh: INTEGER;
BEGIN
  low := 1;
  hgh := UPPERBOUND(lst);
  lkpkey := FALSE;
  WHILE hgh >= low DO BEGIN (*binary search*)
    crnt := low + (hgh - low) DIV 2;
    EXIT IF key = SUBSTR(lst[crnt].key, 1,
      MAX(lst[crnt].abbreviate, MIN(LENGTH(lst[crnt].key), LENGTH(key))))
      DO BEGIN lkpkey := TRUE; code := lst[crnt].code END;
    IF key < lst[crnt].key THEN hgh := crnt - 1 ELSE low := crnt + 1
  END
END;

PUBLIC FUNCTION keystr(list: key_list; code: integer): string_argument;
VAR index: INTEGER;
BEGIN
  FOR index := 1 TO UPPERBOUND(list) DO
  IF list[index].code = code THEN keystr := list[code].key
END;

PUBLIC PROCEDURE srtkey(VAR lst: key_list);
(*sort list of keys*)
BEGIN
END.
  
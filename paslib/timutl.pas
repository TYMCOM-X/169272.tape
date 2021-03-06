$TITLE TIMUTL.PAS, last modified 2/28/84, zw
MODULE timutl;

$HEADER TIMUTL.HDR
TIMUTL.HDR, lst modified 2/28/84, zw

Day times are represented in three formats:
  1) packed format, "dt_pak": number of days since day zero (17-Nov-1858)
     number of seconds since midnight
  2) record format, "dt_rcd": year, month, day, hour, minute, second
  3) string format, "dt_str": DD-Mmm-YY HH:MM:SS

Use the packed format for storing, the record format for manipulation and
the string format for input/output.  Note that the packed format is an
undiscriminated union which is mapped to an integer for ease of manipulation.

TYM-Pascal time functions are:
DATE() returns current date string: DD-Mmm-YY
TIME() returns number of milliseconds since midnight
RUNTIME() returns cpu milliseconds value

The "daytim" function returns the current date/time in record format.

Conversion functions are:
unpack day time to record: "pakdt"
pack day time from record: "unpakdt"
make up date string from record: "daystr"
make up time string from record: "timstr"
make up day time string from record: "dtstr"
parse date string to record: "parday"
parse time string to record: "partim"
parse day time string to record: "pardt"
convert date string to record: "strday"
convert time string to record; "strtim"
convert day time string to record; "strdt"

Note: Check "timerr" boolean after any parse or convert!

Manipulation functions are:
increment year: "incyy"
increment month: "addmm"
increment day: "addday"
increment hour: "addhr"
increment minute: "addmin"
increment second: "addsec"
$INCLUDE TIMUTL.TYP
$PAGE TIMUTL.TYP, last modified 2/28/84, zw
$IFNOT timutltyp

(*day zero is Nov 17, 1858*)

TYPE
time_pak = RECORD
  CASE BOOLEAN OF
    TRUE: (number: INTEGER);
    FALSE: (date: (1900 - 1858) * 365 .. (2000 - 1858) * 365;
      time: 0 .. (60 * 60 * 24))
END;
time_rcd = RECORD
  year: 1900 .. 2000;
  month: 1 .. 12;
  day: 1 .. 31;
  hour: 0 .. 23;
  minute: 0 .. 59;
  second: 0 .. 59
END;
time_str = PACKED ARRAY [1 .. 17]; (*DD-Mmm-YY HH:MM:SS*)
months = (january, february, march, april, may, june, july, august,
  september, october, november, december);
days = (sunday, monday, tuesday, wednesday, thursday, friday, saturday);

CONST
month_str: ARRAY [months] OF STRING[9] =
  ('JANUARY', 'FEBRUARY', 'MARCH', 'APRIL',
   'MAY', 'JUNE', 'JULY', 'AUGUST',
   'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER');
day_str: ARRAY [DAYS] OF STRING[9] =
  ('SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY',
   'FRIDAY', 'SATURDAY');

$ENABLE timutltyp
$ENDIF

$SYSTEM TIMMAC.INC

FUNCTION intstr(i: INTEGER ): STRING[11];
BEGIN
  PUTSTRING(intstr, ABS(i):0);
END;

FUNCTION digits2(n: -99 .. 99 ): PACKED ARRAY [1 .. 2] OF CHAR;
BEGIN
  PUTSTRING(digits2, ABS(n):2);
  IF IOSTATUS <> IO_OK THEN digits2 := '**'
  ELSE IF digits2[1] = ' ' THEN digits2[1] := '0';
END;

PUBLIC FUNCTION timsecs(t: time_int ): seconds OPTIONS SPECIAL(WORD);
CONST secs_per_day: seconds = 86400;
VAR temp: MACHINE_WORD;
BEGIN
  temp := t.t * secs_per_day;
  temp := temp + #o400000;
  temp := temp DIV (2**18);
  timsecs := temp;
END;

PUBLIC FUNCTION timrcd(t: time_int): time_rcd;
VAR time_secs, time_left: seconds;
BEGIN
  WITH timrcd DO BEGIN
    time_secs := timsecs(t); hours := time_secs DIV 3600;
    time_left := time_secs MOD 3600;
    mins := time_left DIV 60; secs := time_left MOD 60
  END
END;

PUBLIC FUNCTION datdays(d: date_int): days;
BEGIN
  datdays := d.d
END;

PUBLIC FUNCTION datrcd(d: date_int): date_rcd;
CONST days_before: ARRAY [1 .. 13] OF -1..367 =
  (-1, 30, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 367);
VAR
days_left: 0 .. MAXIMUM(INTEGER);
quad_centurys: 0 .. 10;
centurys: 0 .. 3;
quarter_days: 0 .. MAXIMUM(INTEGER);
time_temp: 0 .. MAXIMUM(INTEGER);
temp_yr: 0 .. 100;
mo_found: BOOLEAN;
yr: min_year .. max_year;
mo: 1 .. 12;
da: 1 .. 31;
leap_year: BOOLEAN;
BEGIN
  days_left := datdays(d);
  (*convert day zero from 11/17/1858 to 1/1/1501*)
  days_left := days_left + ((1857 - 1500) * 365) + ((1857 - 1500) DIV 4)
    - ((1857 - 1500) DIV 100) + ((1857 -1500) DIV 400) 
    + 31 +28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + 17;
  (*find the number of quadrcenturies since then*)
  quad_centurys := days_left DIV ((400 * 365) + (400 DIV 4) - (400 DIV 100) 
    + (400 DIV 400));
  days_left := days_left MOD ((400 * 365) + (400 DIV 4) - (400 DIV 100)
    + (400 DIV 400));
  (*find quarter days left*)
  quarter_days := days_left * 4;
  (*divide that by the average number of quarter days per century*)
  centurys := quarter_days DIV (((100 * 365) + (100 DIV 4) - (100 DIV 100))
    * 4 + (400 DIV 400));
  quarter_days := quarter_days MOD (((100 * 365) + (100 DIV 4) - (100 DIV 100))
    * 4 + (400 DIV 400));
  (*discard any fractions of a day and add in 3/4 of a day to force
    a leap day into the forth year of each 4 year cycle*)
  quarter_days := (quarter_days DIV 4) * 4 + 3;
  temp_yr := quarter_days DIV (365 * 4 + 1);
  quarter_days := quarter_days MOD (365 * 4 + 1);
  yr := temp_yr + 1501 + (quad_centurys * 400) + (centurys * 100);
  days_left := quarter_days DIV 4;
  (*fake a febuary 29th if its not a leap year and past feb*)
  leap_year := (yr MOD 4) = 0)
    AND (((yr MOD 100) <> 0) OR ((yr MOD 400) = 0);
  IF (NOT leap_year) AND (days_left > (30 + 28))
  THEN days_left := days_left + 1;
  (*which month is it*)
  mo := 1; mo_found := FALSE;
  WHILE NOT mo_found DO BEGIN
    IF days_left <= days_before[mo + 1] THEN mo_found := TRUE
    ELSE mo := mo + 1
  END;
  da := days_left - days_before[mo];
  (*all done, load date record*)
  datrcd.year := yr; datrcd.month := mo; datrcd.day := da
END;

PUBLIC FUNCTION dtrcd(dt: day_time_int): day_time_rcd;
VAR time_bin: time_rcd; date_bin: date_rcd;
BEGIN
  time_bin := timrcd(dttim(dt)); date_bin := datrcd(dtdat(dt));
  WITH dtrcd DO BEGIN
    year := date_bin.year; month := date_bin.month; day := date_bin.day;
    hours := time_bin.hours; mins := time_bin.mins; secs := time_bin.secs
  END
END;

PUBLIC FUNCTION timext(t: day_time_int): day_time_ext;
BEGIN
  WITH dtrcd(t) DO timext :=
    digits2(day)||'-'||month_name(month)||'-'||SUBSTR(intstr(YEAR),3,2)
    ||' '||digits2(HOURS)||':'||digits2(MINS)||':'||digits2(SECS);
END;

PUBLIC PROCEDURE EC_EXT(VAR ERR_CODE: day_time_ERR;
   DT_EXT: NS_EXT; VAR day_time: day_time_INT);
TYPE
   MONTH_RANGE = 1..12;
   CURSOR_RANGE = 1..160;
   POS_INT = 0..MAXIMUM(INTEGER);
CONST
   CENTURY := 1900;	(* CENTURY USED FOR 2 DIGIT YEARS *)
VAR
   day_time_BIN: day_timeREC;	(*WE FIRST CONVERT TO BINARY *)
   CURSOR: CURSOR_RANGE;	(* CURSOR FOR SCANNING EXTERNAL STRING *)
   EOS: BOOLEAN;		(* END OF STRING FLAG *)
   CH: CHAR;
   CASE_IDX: 0..MAXIMUM(INTEGER);  (* INDEX FOR MAINLINE CASE *)
   LA_IDX: CURSOR_RANGE;	(* LOOK AHEAD STRING SCAN CURSOR *)
   TIME_SCANNED: BOOLEAN;	(* TRUE IF EXTERNAL TIME SCANNED ALREADY *)
$PAGE
(*
 *  SCAN_BLANKS - MOVES CURSOR PAST ANY BLANKS; 'EOS' IS
 *  SET TO TRUE IF THE END OF THE STRING IS REACHED BEFORE
 *  A NON-BLANK IS ENCOUNTERED.
 *)
PROCEDURE SCAN_BLANKS(VAR CURSOR: CURSOR_RANGE; VAR EOS: BOOLEAN);
BEGIN
   LOOP
      EOS := CURSOR > LENGTH(DT_EXT);
      EXIT IF EOS;
      EXIT IF DT_EXT[CURSOR] <> ' ';
      CURSOR := CURSOR + 1
   END
END;
$PAGE
(*
 *  SCAN_MONTH - CURSOR SHOULD BE POINTING AT FIRST CHARACTER
 *  OF MONTH.  RETURNS INDEX OF MONTH IF ASSUMPTION
 *  HOLDS, OTHERWISE ERROR CODE IS RETURNED.
 *)
PROCEDURE SCAN_MONTH(VAR ERR_CODE: day_time_ERR; 
   VAR CURSOR: CURSOR_RANGE; VAR MONTH_IDX: MONTH_RANGE);
TYPE
   MONTH_TEXT = PACKED ARRAY [1..3] OF CHAR;
   MTH_NAME_TAB = ARRAY [MONTH_RANGE] OF MONTH_TEXT;
CONST
   MONTH_NAME: MTH_NAME_TAB = ( 'JAN' , 'FEB' , 'MAR' , 'APR' ,
      'MAY' , 'JUN' , 'JUL' , 'AUG' , 'SEP' , 'OCT' , 'NOV' , 'DEC');
VAR
   THIS_MONTH: MONTH_TEXT;
   I: 1..13;
BEGIN
   ERR_CODE := DT_NOERR;
   IF CURSOR + 2 > LENGTH(DT_EXT) THEN
      ERR_CODE := DT_ERR
   ELSE
   BEGIN
      THIS_MONTH := UPPERCASE(SUBSTR(DT_EXT,CURSOR,3));
      CURSOR := CURSOR + 3;
      I := 1;
      WHILE (I <= 12) ANDIF (THIS_MONTH <> MONTH_NAME[I]) DO
         I := I + 1;
      IF I = 13 THEN ERR_CODE := DT_ERR
      ELSE MONTH_IDX := I
   END
END;
$PAGE
(*
 *  SCAN_INTEGER - CURSOR SHOULD BE POINTING AT FIRST DIGIT
 *  OF AN INTEGER.  CONVERTS INTEGER TO BINARY AND RETURNS ITS
 *  VALUE IF ASSUMPTION HOLDS, OTHERWISE ERROR CODE IS RETURNED.
 *)
PROCEDURE SCAN_INTEGER(VAR ERR_CODE: day_time_ERR;
   VAR CURSOR: CURSOR_RANGE;  VAR INT_VAL: POS_INT);
TYPE
   DIGIT_TAB = PACKED ARRAY ['0'..'9'] OF 0..9;
   SET_OF_CHAR = SET OF CHAR;
CONST
   DIGIT_VAL: DIGIT_TAB := (0,1,2,3,4,5,6,7,8,9);
   DIGITS_SET: SET_OF_CHAR := ['0'..'9'];
BEGIN
   ERR_CODE := DT_NOERR;
   INT_VAL := 0;
   IF (CURSOR > LENGTH(DT_EXT)) ORIF NOT (DT_EXT[CURSOR] IN DIGITS_SET) THEN
      ERR_CODE := DT_ERR
   ELSE
   LOOP
      EXIT IF CURSOR > LENGTH(DT_EXT);
      CH := DT_EXT[CURSOR];
      EXIT IF NOT (CH IN DIGITS_SET);
      CURSOR := CURSOR + 1;
      INT_VAINT_VAL * 10 + DIGIT_VAL[CH]
   END
END;
$PAGE
(*
 *  SCAN_DATE - PARSES DATE STRING WITH FORMAT: 'DD-MM-YY'.
 *  SETS FIELDS 'YEAR', 'MONTH' AND 'DAY' OF RECORD
 *  'day_time_BIN'.
 *)
PROCEDURE SCAN_DATE(VAR ERR_CODE: day_time_ERR; VAR CURSOR: CURSOR_RANGE);
BEGIN
   SCAN_INTEGER(ERR_CODE, CURSOR, day_time_BIN.DAY);
   IF ERR_CODE = DT_NOERR THEN
   BEGIN
      CURSOR := CURSOR + 1; (* SKIP FIRST '-' *)
      SCAN_MONTH(ERR_CODE,CURSOR,day_time_BIN.MONTH);
      IF ERR_CODE = DT_NOERR THEN
      BEGIN
         CURSOR := CURSOR + 1; (* SKIP SECOND '-'  *)
         SCAN_INTEGER(ERR_CODE, CURSOR, day_time_BIN.YEAR );
         IF ERR_CODE = DT_NOERR THEN
            day_time_BIN.YEAR := day_time_BIN.YEAR + CENTURY
      END
   END
END;
$PAGE
(*
 *  SCAN_NS_D1 - PARSES DATE STRING WITH FORMAT: 'MM/DD/YY'.
 *  SETS FIELDS 'YEAR', 'MONTH' AND 'DAY' OF RECORD 'day_time_BIN'.
 *)
PROCEDURE SCAN_NS_D1(VAR ERR_CODE: day_time_ERR; VAR CURSOR: CURSOR_RANGE);
VAR
   YR: 1858..MAX_YEAR;
BEGIN
   SCAN_INTEGER(ERR_CODE, CURSOR, day_time_BIN.MONTH);
   IF ERR_CODE = DT_NOERR THEN
   BEGIN
      CURSOR := CURSOR + 1;  (* SKIP FIRST '/'  *)
      
      SCAN_INTEGER(ERR_CODE, CURSOR, day_time_BIN.DAY);
      IF ERR_CODE = DT_NOERR THEN
      BEGIN
         CURSOR := CURSOR + 1;  (* SKIP SECOND '/'   *)
         SCAN_INTEGER(ERR_CODE, CURSOR, YR );
         IF ERR_CODE = DT_NOERR THEN
            day_time_BIN.YEAR := YR + CENTURY
      END
   END
END;
$PAGE
(*
 *  SCAN_NS_D2 - PARSES A DATE STRING WITH FORMAT 'MMM DD,YYYY'.
 *  SETS FIELDS 'YEAR', 'MONTH' AND 'DAY' OF RECORD 'day_time_BIN'.
 *)
PROCEDURE SCAN_NS_D2(VAR ERR_CODE: day_time_ERR; VAR CURSOR: CURSOR_RANGE);
BEGIN
   SCAN_MONTH(ERR_CODE, CURSOR, day_time_BIN.MONTH);
   IF ERR_CODE = DT_NOERR THEN
   BEGIN
      SCAN_BLANKS(CURSOR,EOS);
      SCAN_INTEGER(ERR_CODE, CURSOR, day_time_BIN.DAY);
      IF ERR_CODE = DT_NOERR THEN
      BEGIN
         CURSOR := CURSOR + 1;  (* SKIP ','  *)
         SCAN_BLANKS(CURSOR,EOS);
         SCAN_INTEGER(ERR_CODE,CURSOR,day_time_BIN.YEAR)
      END
   END
END;
$PAGE
(*
 *  SCAN_TIME - PARSES TIME STRING WITH FORMAT: 'HH:MM:SS [A/P]M',
 *  WHERE FINAL 'AM' OR 'PM' IS OPTIONAL.  SETS FIELDS 'HOURS',
 *  'MINS' AND 'SECS' OF RECORD day_time_BIN.
 *)
PROCEDURE SCAN_TIME(VAR ERR_CODE: day_time_ERR; VAR CURSOR: CURSOR_RANGE);
VAR
   HRS: 0..59;
   am: packed array [1..2] of char;
BEGIN
   TIME_SCANNED := TRUE;
   SCAN_INTEGER(ERR_CODE, CURSOR, HRS);
   IF ERR_CODE = DT_NOERR THEN
   BEGIN
      CURSOR := CURSOR + 1; (* SKIP FIRST ':'  *)
      SCAN_INTEGER(ERR_CODE, CURSOR, day_time_BIN.MINS);
      IF ERR_CODE = DT_NOERR THEN
      BEGIN
         CURSOR := CURSOR + 1;  (* SKIP SECOND ':'  *)
         SCAN_INTEGER(ERR_CODE, CURSOR, day_time_BIN.SECS);
         IF ERR_CODE = DT_NOERR THEN
         BEGIN
            SCAN_BLANKS(CURSOR, EOS);
            IF CURSOR + 1 <= LENGTH(DT_EXT) THEN
	       am := uppercase ( substr ( dt_ext, cursor, 2 ) );
	       if ( am = 'PM' ) and ( hrs < 12 )
		  then hrs := hrs + 12
	       else if ( am = 'AM' ) and (hrs = 12)
	          then hrs := hrs - 12;
            day_time_BIN.HOURS := HRS
         END
      END
   END
END;
(*
 *  EC_EXT MAIN ROUTINE.
 *)
BEGIN
   day_time := BASE_day_time_INTERNAL;
   ERR_CODE := DT_NOERR;
   CURSOR := 1;
   TIME_SCANNED := FALSE;
   WITH day_time_BIN DO
   BEGIN
      YEAR := 1858;
      MONTH := 11;
      DAY := 17;
      HOURS := 0;
      MINS := 0;
      SECS := 0
   END;
   SCAN_BLANKS(CURSOR,EOS);  (* SCAN PAST ANY INITIAL BLANKS *)
   IF NOT EOS THEN
   BEGIN
      CASE_IDX := 0;
      LA_IDX := CURSOR;
      LOOP
         EXIT IF LENGTH(DT_EXT) <= LA_IDX DO EOS := TRUE;
         CH := DT_EXT[LA_IDX];
         IF CH = '-' THEN CASE_IDX := 1
         ELSE IF CH = '/' THEN CASE_IDX := 2
         ELSE IF CH = ' ' THEN CASE_IDX := 3
         ELSE IF CH = ':' THEN CASE_IDX := 4
         ELSE LA_IDX := LA_IDX + 1;
         EXIT IF CASE_IDX <> 0
      END;
      CASE CASE_IDX OF
         0: ERR_CODE := DT_ERR;
         1: SCAN_DATE(ERR_CODE, CURSOR);
         2: SCAN_NS_D1(ERR_CODE, CURSOR);
         3: SCAN_NS_D2(ERR_CODE, CURSOR);
         4: SCAN_TIME(ERR_CODE, CURSOR)
      END;
      IF NOT TIME_SCANNED THEN
      BEGIN
         SCAN_BLANKS(CURSOR, EOS);
         IF NOT EOS THEN SCAN_TIME(ERR_CODE, CURSOR)
      END;
      (* CONVERT BINARY TO INTERNAL FORMAT *)
      IF ERR_CODE = DT_NOERR THEN 
         EC_day_time(ERR_CODE, day_time_BIN, day_time)
   END
END;
$SYSTEM Iday_time.TYP
$SYSTEM day_timeI.INC
PUBLIC FUNCTION NS_T1(TIME: TIME_INT): NS_TIME1;
VAR
    H: 0..23;
   AM: PACKED ARRAY [1..2] OF CHAR;
BEGIN
   WITH timrcd(TIME) DO
   BEGIN
      H := HOURS;
      if hours < 12 then begin
	 am := 'AM';
	 if H = 0 then H := 12;
      end
      else begin
	 am := 'PM';
	 if H > 12 then H := H - 12;
      end;
      NS_T1 := digits2(H) || ':'
         || digits2(MINS) || ':'
         || digits2(SECS) || ' '
         || AM
   END
END;
$SYSTEM Iday_time.TYP
$SYSTEM Iday_time.TYP
   VAR DATE_INT);
   VAR TIME_INT);
PUBLIC PROCEDURE EC_day_time(VAR ERR_CODE: day_time_ERR;
   day_timeBIN: day_timeREC; VAR day_time: day_time_INT);
VAR
   DATE_BIN: DATEREC;
   TIME_BIN: TIMEREC;
   DATE: DATE_INT;
   TIME: TIME_INT;
BEGIN
   WITH day_timeBIN DO
   BEGIN
      DATE_BIN.YEAR := YEAR;
      DATE_BIN.MONTH := MONTH;
      DATE_BIN.DAY := DAY;
      EC_DATE(ERR_CODE, DATE_BIN, DATE);
  
      IF ERR_CODE = DT_NOERR THEN
      BEGIN
         TIME_BIN.HOURS := HOURS;
         TIME_BIN.MINS := MINS;
         TIME_BIN.SECS := SECS;
         EC_TIME(ERR_CODE,TIME_BIN, TIME);
         IF ERR_CODE = DT_NOERR THEN
            day_time := DT_COMBINE(DATE,TIME)
      END
   END (* WITH *)
END;
$SYSTEM Iday_time.TYP
   TIMEREC; VAR TIME_INT);
PUBLIC FUNCTION EC_DCTIME(D_TIME: DEC_TIME): TIME_INT;
VAR
   SECS_SINCE: DEC_TIME;	(* SECONDS SINCE MIDNIGHT *)
   SECS_LEFT: DEC_TIME;
   TIME_BIN: TIMEREC;
   ERR_CODE: day_time_ERR;
   TIME: TIME_INT;
BEGIN
   WITH TIME_BIN DO
   BEGIN
      SECS_SINCE := D_TIME DIV 1000;
      HOURS := SECS_SINCE DIV 3600;
      SECS_LEFT := SECS_SINCE MOD 3600;
      MINS := SECS_LEFT DIV 60;
      SECS := SECS_LEFT MOD 60;
   END;
   EC_TIME(ERR_CODE, TIME_BIN, TIME );
   IF ERR_CODE = DT_NOERR THEN
      EC_DCTIME := TIME
   ELSE EC_DCTIME := ( 0, 0 )
END;
$SYSTEM Iday_time.TYP
   DATEREC; VAR DATE_INT);
PUBLIC FUNCTION EC_DCDATE(D_DATE: DEC_DATE): DATE_INT;
VAR
   DATE_BIN: DATEREC;
   DAYS_LEFT: DEC_DATE;
   ERR_CODE: day_time_ERR;
   DATE: DATE_INT;
BEGIN
   WITH DATE_BIN DO
   BEGIN
      YEAR := D_DATE DIV (12 * 31) + 1964;
      DAYS_LEFT := D_DATE MOD (12 * 31);
      MONTH := DAYS_LEFT DIV 31 + 1;
      DAY := DAYS_LEFT MOD 31 + 1;
   END;
   EC_DATE(ERR_CODE, DATE_BIN, DATE);
   IF ERR_CODE = DT_NOERR THEN
      EC_DCDATE := DATE
   ELSE EC_DCDATE := ( 0, 0 )
END;
(* EC_TSDATE - converts a standard TYMSHARE date to an internal date.
   The standard TYMSHARE date is the *exact* number of days since
   January 1, 1964.  *)
$SYSTEM iday_time.typ
public function ec_tsdate ( ts_date: tym_date ): date_int;
begin
  ec_tsdate.d := ts_date + 112773b;
END;
$SYSTEM Iday_time.TYP
$SYSTEM day_timeI.INC
$SYSTEM Iday_time.TYP
$SYSTEM day_timeI.INC
PUBLIC PROCEDURE EC_TIME(VAR ERR_CODE: day_time_ERR;
   TIME_BIN: TIMEREC;  VAR TIME: TIME_INT);
CONST
   SECS_PER_DAY = 86400;
VAR
   TIME_SECS: INTEGER;
BEGIN
   WITH TIME_BIN DO
   BEGIN
      IF (HOURS < 0) ORIF
         (HOURS > 23) ORIF
         (MINS < 0) ORIF
         (MINS > 59) ORIF
         (SECS < 0) ORIF
         (SECS > 59)
      THEN ERR_CODE := DT_ERR
      ELSE
      BEGIN
         ERR_CODE := DT_NOERR;
         TIME_SECS := HOURS * 3600 + MINS * 60 + SECS;
	 TIME := EC_SECS ( TIME_SECS );
      END
   END (* WITH *)
END;
$SYSTEM Iday_time.TYP
$SYSTEM day_timeI.INC
PUBLIC FUNCTION NS_D1(DATE: DATE_INT): NS_DATE1;
BEGIN
   WITH datrcd(DATE) DO
      NS_D1 := digits2(MONTH) || '/' ||
	       digits2(DAY)   || '/' ||
	       SUBSTR(intstr(YEAR),3,2);
END;
$SYSTEM Iday_time.TYP
$SYSTEM day_timeI.INC
PUBLIC FUNCTION NS_D2(DATE: DATE_INT): NS_DATE2;
BEGIN
   WITH datrcd(DATE) DO
      PUTSTRING (NS_D2, month_name(MONTH), ' ', DAY:0, ', ', YEAR:4);
END;
$SYSTEM Iday_time.TYP
$SYSTEM day_timeI.INC
$SYSTEM Iday_time.TYP
$SYSTEM day_timeI.INC
PUBLIC PROCEDURE EC_DATE(VAR ERR_CODE: day_time_ERR;
   DATE_BIN: DATEREC; VAR DATE: DATE_INT);
TYPE
   MONTH_TAB = ARRAY [1..12] OF 0..365;
CONST
   DAYS_IN_MONTH: MONTH_TAB = (31, 29 , 31, 30, 31, 30,
      31, 31, 30, 31, 30, 31 );
   DAYS_BEFORE: MONTH_TAB = (0 , 31, 59, 90, 120,
      151,181, 212, 243, 273, 304, 334 );
VAR
   DAYS_SINCE: 0..MAXIMUM(INTEGER);
   QUAD_CENT, CENTS, QUAD_YEARS: 0..MAXIMUM(INTEGER);
   LEAP_YEAR: BOOLEAN;
BEGIN
   WITH DATE_BIN DO
   BEGIN
      
      (* ERROR CHECK DATE PASSED IN *)
      IF (YEAR < 1858) ORIF
         (MONTH < 1) ORIF
         (MONTH > 12) ORIF
         (DAY < 1) ORIF
         (DAY > DAYS_IN_MONTH[MONTH])
      THEN ERR_CODE := DT_ERR
      ELSE
      BEGIN
         ERR_CODE := DT_NOERR;
         IF YEAR <> 1858 THEN
         BEGIN
            DAYS_SINCE := 44; (*DAYS FROM YEAR 1858 *)
            DAYS_SINCE := DAYS_SINCE + (YEAR-1859) * 365;
            (* ADD IN 1 FOR EACH LEAP YEAR.  A LEAP YEAR IS
            ASSUMED TO BE ANY YEAR DIVISIBLE BY 4 BUT NOT DIVISIBLE
            BY 100, UNLESS DIVISIBLE BY 400 ALSO.  THUS 1900 WAS 
            NOT A LEAP YEAR, THE YEAR 2000 WILL BE *)
            QUAD_CENT := (YEAR-1) DIV 400 - (1858 DIV 400);
            CENTS := (YEAR-1) DIV 100 - (1858 DIV 100);
            QUAD_YEARS := (YEAR-1) DIV 4 - (1858 DIV 4);
            DAYS_SINCE := DAYS_SINCE + QUAD_CENT
               - CENTS + QUAD_YEARS;
            (* ADD IN DAYS FOR THE COMPLETED MONTHS OF THIS YEAR *)
            DAYS_SINCE := DAYS_SINCE + DAYS_BEFORE[MONTH];
            IF MONTH > 2 THEN
            BEGIN
               LEAP_YEAR := ((YEAR MOD 4) = 0) AND
                  (((YEAR MOD 100) <> 0) OR
                  ((YEAR MOD 400) = 0));
               IF LEAP_YEAR THEN DAYS_SINCE := DAYS_SINCE + 1;
            END;
            (* NOW ADD IN THE DAYS OF THIS MONTH *)
            DAYS_SINCE := DAYS_SINCE + DAY;
         END
         ELSE
         (* SPECIAL CASE - DATE IN 1858 *)
         BEGIN
            IF MONTH = 12 THEN DAYS_SINCE := DAY + 13
            ELSE IF MONTH = 11 THEN 
               DAYS_SINCE := DAY - 17
            ELSE ERR_CODE := DT_ERR
         END;
         IF ERR_CODE <> DT_ERR THEN
	    DATE := EC_DAYS ( DAYS_SINCE );
      END (* FIRST IF STATEMENT *)
   END (* WITH *)
END;
$SYSTEM Iday_time.TYP
$SYSTEM day_timeI.INC
PUBLIC FUNCTION DAY_OF_WEEK(DATE: DATE_INT): WEEK_DAY;
VAR
   NORM_DATE: 0..777777B;
   DAY_INDEX,I: 0..6;
BEGIN
   NORM_DATE := datdays< ( DATE );
   DAY_INDEX := (NORM_DATE + 3) MOD 7;  (* DAY ZERO WAS A WED *)
   DAY_OF_WEEK := SUNDAY;
   FOR I := 1 TO DAY_INDEX DO
      DAY_OF_WEEK := SUCC(DAY_OF_WEEK)
END;
$SYSTEM iday_time.typ
$SYSTEM iday_time.typ
public function ec_days ( days_since_base: days ): date_int;
begin
  ec_days.d := days_since_base;
  ec_days.t := 0;
END;
$SYSTEM iday_time.typ
$SYSTEM iday_time.typ
public function ec_secs ( secs: seconds ): time_int
  options special (word);
const
  secs_per_day: seconds = 86400;
var
  temp: machine_word;
begin
  ec_secs.d := 0;
  temp := secs * (2**18);
  temp := temp + secs_per_day div 2;	(* so following DIV will round *)
  ec_secs.t := temp div secs_per_day;
END.
aj<?
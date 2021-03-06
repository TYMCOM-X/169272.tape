MODULE ECDCTIME;

$HEADER ECDCTI.HDR

$SYSTEM IDTIME.TYP

EXTERNAL PROCEDURE EC_TIME(VAR DTIME_ERR;
   TIMEREC; VAR TIME_INT);


PUBLIC FUNCTION EC_DCTIME(D_TIME: DEC_TIME): TIME_INT;

VAR
   SECS_SINCE: DEC_TIME;	(* SECONDS SINCE MIDNIGHT *)
   SECS_LEFT: DEC_TIME;
   TIME_BIN: TIMEREC;
   ERR_CODE: DTIME_ERR;
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

END.
   
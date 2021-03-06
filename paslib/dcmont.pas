MODULE DCMONTH;

$HEADER DCMONT.HDR


PUBLIC FUNCTION DC_MONTH ( MTH: 1..12 ): PACKED ARRAY [1..3] OF CHAR;

CONST
   MONTH_TAB: ARRAY [1..12] OF PACKED ARRAY [1..3] OF CHAR :=
     (  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
	'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'  );

BEGIN
   IF (MTH < 1) OR (MTH > 12) THEN
      DC_MONTH := '***'
   ELSE DC_MONTH := MONTH_TAB[MTH]
END.
    
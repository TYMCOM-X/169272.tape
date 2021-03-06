external string procedure logDate( string OPTS("W, D-M-Y T Z") );
comment
    Date:
	Return current local date and time in form
	    ddmmmyy hh:mm:ss
	or form specified by argument where:
	    D - day of month
	    M - month (3 chars)
	    m - month (2 digits)
	    Y - year (2 digits)
	    T - time (hh:mm:ss)
	    W - day of week (3 chars)
	    w - day of week (1 digit, 0=Sunday)
	    Z - time zone (3 chars)
	    z - time zone (2 digits, monitor code with daylight bit)
;
external boolean logging;	comment this is a flag saying log is open;
external integer logChan;	comment this is the log channel;
external integer procedure logOpen( string Name(null) );
external procedure logClose( integer SizeLimit(0) );
 

external integer procedure SQUISH( integer code; 
		integer  input!AOBJN; integer procedure more!input;
		integer output!AOBJN; integer procedure more!output );

external integer procedure MANGLE( integer code );

COMMENT code= 6, 7, 9, -6, -7, or -9
	MANGLE sets up node,freq from DWS-format FREQ
	SQUISH used a mangled table to produce an output bit stream 
		eof on input or output are done by returning 0, else
		wants XWD -len,firstloc returned
		(can either start with those ptrs, or 0 to get by pcall)
;

  
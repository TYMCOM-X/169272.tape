File 1)	DSK:PCOM54.SAI	created: 1926 07-MAR-83
File 2)	DSK:PCOM55.SAI	created: 1927 07-MAR-83

1)1	require (Ifcr PRELIMINARY thenc '101 elsec '1 endc lsh 18) lor '54 version;
1)	require "
****
2)1	require (Ifcr PRELIMINARY thenc '101 elsec '1 endc lsh 18) lor '55 version;
2)	require "
**************
1)22		Logout!Child;	! Print exit messages;
1)		EXIT( Error!RFM lsh 18 )
****
2)22		Logout!Child;			! Print exit messages;
2)		EXIT( Error!RFM lsh 18 )
**************
1)26	procedure REASSIGN (string CMD);
****
2)25	Simple Procedure LOGOUT!Frame;
2)	begin
2)	    Status _ Status!LOGOUT;			! Just mention LOGOUT;
2)	    O utPtr(Port,"LOGOUT"&#cr);
2)	    IntCause( Int!CHR );			! cause character interrupt;
2)	    Status _ Status!ZAP;			! now...;
2)	    SetTimeLimit( 5 );				! set 5 minute limit for zap;
2)	    while not (ZAP! or NTQ! or TIM!)		! wait for zapper;
2)		do Calli ( Sleep!Time, Calli!Hiber );	! for however long it takes;
2)	end;
2)26	procedure REASSIGN (string CMD);
**************
1)27	    if ZAP! then begin				! start a new frame;
1)		SPROUT;
1)		IntIni (Intvar_INTPRO, PORT, OChan, FilePage, FileSize,
1)				If detach! then 0 else !Xwd(-1,!AXOCI)   );
1)	    end;
1)	    ESCAPE;					! force command level;
1)	    
1)	!	send mail if indicated - inform user of disposition;
1)	    If MakeLog then IntLog( DoLog_ True );	! Force into logfile if there;
1)	    if DoMail then begin			! send mail ?;
1)		Status _ Status!MAIL;			! let parent know;
****
2)27	    if ( DoMail ) and
2)	       ( ( (frame!block[ FrmPRV ] land JP!MOD) lsh -7 ) = !JPMXJ )
2)	     then begin
2)		Logout!Frame;				! logout and set xexec mode;
2)		frame!block[ FrmPRV ] _ ( !JPMXE lsh 7 ) lor
2)			    ( frame!block[ FrmPrv ] land lnot JP!MOD );
2)	     end;
2)	    
2)	!	send mail if indicated - inform user of disposition;
2)	    if DoMail then begin			! send mail ?;
2)		if ZAP! then begin			! start a new frame;
2)		    SPROUT;				!  and attach it to a PTY;
2)		    IntIni (Intvar_INTPRO, PORT, OChan, FilePage, FileSize,
2)				If detach! then 0 else !Xwd(-1,!AXOCI)   );
2)		 end;
2)		If MakeLog then IntLog( DoLog_ True );	! Force logging;
File 1)	DSK:PCOM54.SAI	created: 1926 07-MAR-83
File 2)	DSK:PCOM55.SAI	created: 1927 07-MAR-83

2)		ESCAPE;					! force command level;
2)		Status _ Status!MAIL;			! let parent know;
**************
1)27	    Status _ Status!LOGOUT;			! Just mention LOGOUT;
1)	    OutPtr(Port,"LOGOUT"&#cr);
1)	    IntCause( Int!CHR );			! cause character interrupt;
1)	    Status _ Status!ZAP;			! now...;
1)	    SetTimeLimit( 5 );				! set 5 minute limit for zap;
1)	    while not (ZAP! or NTQ! or TIM!)		! wait for zapper;
1)		do Calli ( Sleep!Time, Calli!Hiber );	! for however long it takes;
1)	    IntZap;					! clear interrupts;
1)	    IntFin;					! dump character buffers;
1)	    
1)	    If MakeLog and (
****
2)27	    Logout!Frame;			! terminate the process;
2)	    IntZap;				! clear interrupts;
2)	    IntFin;				! dump character buffers;
2)	    If MakeLog and (
**************
   
File 1)	DSK:AUXSPL.16	created: 1233 16-DEC-86
File 2)	DSK:AUXSPL.SAI	created: 1846 28-JAN-87

1)1	require '1 lsh 24 lor '16 version;
1)	require "(SAILIB)SAIL.DEF" source!file;
****
2)1	require '1 lsh 24 lor '20 version;
2)	require "(SAILIB)SAIL.DEF" source!file;
**************
1)1	Own String Filename, HeadMessage, TailMessage, Author, Login!name;
1)	Own String AuxDev;
****
2)1	Own String Filename, HeadMessage, TailMessage, Author, Login!name, Host;
2)	Own String AuxDev;
**************
1)6	    if myjob_PrinterJob
****
2)6	    Host _ cvs(Calli('33000011,calli!GETTAB));
2)	    if myjob_PrinterJob
**************
1)7 	begin "draw box"
****
2)7	Comment
2)	The LN03 uses 720 decipoints per inch when reset (as poopsed to 300 pixels
2)	per inch).  The standard print area is 8.0 by 10.65 out of 8.5 by 11.0 inches.
2)	The top margin varies between 0.11 and 0.20 inches depending on how well the
2)	paper feeds.  The left and right margins are 0.25 inches each if the paper
2)	feeds in straight.  Offsets of plus or minus 0.08 inches have been observed.
2)	One batch of 3-hole drilled paper has the holes extending to 0.52 inches from
2)	the left edge.  Therefore the box is indented 0.60 inches from the sides.
2)	Since the built-in offset is 0.25, a software offset of 0.35 is needed.
2)	1/30 inch = 24 decipoints = width of the lines.
2)	(0.35,00.00) = 0252,0000 = top left corner.
2)	(0.35,10.65) = 0252,7668 = bottom left corner.  7668-24=7644 (minus line width)
2)	(7.65,00.00) = 5508,0000 = top right corner.  5508-0252=5256 (length of line)
2)	(7.65,10.65) = 5508,7668 = bottom right corner.
2)	(10.24,8.00) = 7372,5760 = bottom right in landscape, symmetric left/right.
2)	    5760-24=5736 (minus line width), 5760-252=5508 (sides in landscape).
2)	;
2)	begin "draw box"
**************
1)7		AuxOut( CSI &"0;0;0;7560;24!|" );	! Top line 10.5 inches ;
1)		AuxOut( CSI &"0;0;5736;7560;24!|" );	! Bottom line 10.5 inches ;
1)		AuxOut( CSI &"1;0;0;5760;24!|" );	! Left line 8.0 inches ;
1)		AuxOut( CSI &"1;7536;0;5760;24!|" );	! Right line 8.0 inches ;
1)	     end "landscape"
1)	     else begin "tall"
1)		AuxOut( CSI &"0;0;0;5760;24!|" );	! Top line 8.0 inches ;
1)		AuxOut( CSI &"0;0;7536;5760;24!|" );	! Bottom line 8.0 inches ;
1)		AuxOut( CSI &"1;0;0;7560;24!|" );	! Left line 10.5 inches ;
1)		AuxOut( CSI &"1;5736;0;7560;24!|" );	! Right line 10.5 inches ;
1)	     end "tall";
****
2)7			!   dir, X, Y, length, width ;
2)		AuxOut( CSI &"0;0000;0252;7372;24!|" );	! Top left to right (by holes) ;
2)		AuxOut( CSI &"0;0000;5736;7372;24!|" );	! Bottom left to right ;
2)		AuxOut( CSI &"1;0000;0252;5508;24!|" );	! Left is 0.39 from "bottom" ;
File 1)	DSK:AUXSPL.16	created: 1233 16-DEC-86
File 2)	DSK:AUXSPL.SAI	created: 1846 28-JAN-87

2)		AuxOut( CSI &"1;7655;0252;5508;24!|" );	! Right is 0.39 from "top" ;
2)	     end "landscape"
2)	     else begin "tall"			! normal "portrait" printing ;
2)		AuxOut( CSI &"0;0252;0000;5256;24!|" );	! Top left to right ;
2)		AuxOut( CSI &"0;0252;7644;5256;24!|" );	! Bottom left to right ;
2)		AuxOut( CSI &"1;0252;0000;7668;24!|" );	! Left top to bottom ;
2)		AuxOut( CSI &"1;5508;0000;7668;24!|" );	! Right top to bottom ;
2)	     end "tall";
**************
1)7		AuxOut( CSI &"?21 J"& CSI &"15m" );	! yes, set landscape ;
1)		AuxOut( CSI &" G" );			! Use normal font settings ;
1)		AuxOut( CSI &"4;64r" );			! only set top/bot margins ;
1)	     end "landscape"
1)	     else if ( kequ( Extension, "LS8" ) )
1)	      then begin "use 8.5"
1)		AuxOut( CSI &"?20 J"& CSI &"15m" );	! 8.5 lpi x 13.6 cpi ;
1)		AuxOut( CSI &" G" );			! Use normal font settings ;
1)		AuxOut( CSI &"9;0s" );			! set margins ;
1)		Auxout( CSI &"4;0r" );
1)	      end "use 8.5"
1)	     else begin "tall"
1)		AuxOut( CSI &"?20 J"& CSI &"14m" );	! no, set tall ;
1)		AuxOut( CSI &" G" );			! Use normal font settings ;
1)		AuxOut( CSI &"9;0s" );			! set margins ;
1)		AuxOut( CSI &"4;64r" );			! only set top/bot margins ;
1)	     end "tall";
****
2)8		AuxOut( CSI &"?21 J"& CSI &"15m" );	! at least 132 columns wide ;
2)		AuxOut( CSI &" G" );			! Use normal font settings ;
2)		AuxOut( CSI &"4;64r" );			! force 60 lines per page ;
2)	     end "landscape"
2)	     else if ( kequ( Extension, "LS8" ) )	! 8 lines per inch ;
2)	      then begin "8 LPI"
2)		AuxOut( CSI &"?20 J"& CSI &"15m" );	! 8.5 lpi x 13.6 cpi ;
2)		AuxOut( CSI &" G" );			! Use normal font settings ;
2)		AuxOut( CSI &"9;0s" );			! 100 columns wide ;
2)		Auxout( CSI &"4;0r" );			! allow 85 lines per page ;
2)	      end "8 LPI"
2)	     else begin "tall"				! normal "portrait" mode ;
2)		AuxOut( CSI &"?20 J"& CSI &"14m" );	! 12 characters per inch ;
2)		AuxOut( CSI &" G" );			! Use normal font settings ;
2)		AuxOut( CSI &"9;0s" );			! 88 columns (80 centered) ;
2)		AuxOut( CSI &"4;64r" );			! force 60 lines per page ;
2)	     end "tall";
**************
1)8	    AuxFlg_ 0;				! only send balls on pages ;
****
2)9	    if Aux > 0 then begin
2)	      AuxFlg_ 0;			! only send balls on pages ;
**************
1)8	end "start circuit";
****
2)9	    end;
2)	end "start circuit";
File 1)	DSK:AUXSPL.16	created: 1233 16-DEC-86
File 2)	DSK:AUXSPL.SAI	created: 1846 28-JAN-87

**************
1)8	    AuxOut( CSI &"?7h" );		! re-enable auto wrap ;
1)	    IntZap;				! clear interrupts ;
1)	    AuxZap;				! zap the circuit ;
1)	end "stop circuit";
1)9	Boolean Procedure WantFile( Reference integer File, Ext );
1)	Return( True );
1)	Simple Procedure HeaderPage;
****
2)9	    if Aux > 0 then AuxOut(CSI&"?7h");	! re-enable auto wrap ;
2)	    AuxZap;				! zap the circuit ;
2)	    calli( 1, calli!SLEEP);		! wait for zap interrupt ;
2)	    IntZap;				! clear interrupts ;
2)	end "stop circuit";
2)10	Boolean Procedure WantFile( Reference integer File, Ext );
2)	Return( not NTQ! );			! any file is OK ;
2)	Simple Procedure HeaderPage;
**************
1)10	    begin
1)		If not MoreText				! if buffer empty;
****
2)11	    begin	! warning: does not handle overprinted lines correctly ;
2)		If not MoreText				! if buffer empty;
**************
1)10	    If NTQ! then Return;		! No work if this happens ;
1)	    Eot_ data!output_ false;		! Clear file flags ;
1)	    Author_ CvUser( LKB[!RBAUT] );
****
2)11	    If NTQ! then Return;			! Don't start when evicted ;
2)	    Eot_ data!output_ MoreText_ false;		! Clear file flags ;
2)	    Author_ CvUser( LKB[!RBAUT] );
**************
1)10	    HeadMessage := "** " & "(" & Author & ")" &
1)			    Filename & ", printed " & WeekDay & ", " &
1)			    LongDate & " " & TimeOfDay & " **" & Crlf;
1)	    StartCircuit;			! setup device ;
1)	    If NTQ! then Return;		! No work if this happens ;
1)	    LogInfo( " Started ("& Author &")"& Filename );
****
2)11	    HeadMessage := "** " & "(" & Author & ":" & Host & ")" &
2)			    Filename & ", printed " & WeekDay & ", " &
2)			    LongDate & " at " & TimeOfDay & " **" & Crlf;
2)	    StartCircuit;			! setup device, wait if port is busy ;
2)	    If NTQ! then Return;		! evicted while waiting for printer ;
2)	    LogInfo( " Started ("& Author &")"& Filename );
**************
1)10	    CZAP!_ false;			! somehow this seems bad ;
1)	    SetTypeSize( Extension );
****
2)11	    SetTypeSize( Extension );
**************
1)10			   length(TextLine)	!  or text on line;
1)			 then begin
****
File 1)	DSK:AUXSPL.16	created: 1233 16-DEC-86
File 2)	DSK:AUXSPL.SAI	created: 1846 28-JAN-87

2)11			   (length(TextLine) and (Textline neq #CR))
2)			 then begin
**************
1)10	    If break neq #FF then AuxOut( #FF );
1)	    DateTimeStuff;
1)	    TailMessage _ "** (" & Author & ")" &
1)			    Filename & " printed " & WeekDay & ", " &
1)			    LongDate & " at " & TimeOfDay & " **" & Crlf;
1)	    SetTypeSize( Null );		! reset for trailer ;
1)	!   TrailerPage;			! remove this for now... ;
1)	    LogInfo( " Finished ("& Author & ")" & Filename &
1)		     " Printed: "& cvs(LogPages) &" pages." );
1)	    if not( CZAP! or NTQ! )
1)	     then data!output_ work!done_ true;	! set flags for data sent ;
1)	    if data!output
1)	     then begin
1)		if decext_ abs( cvd(extension) )
1)		 then LKB[!RBEXT]_ Cvsix(cvs(decext-1)[1 for 3]) lor !rh(LKB[!RBEXT])
1)		 else LKB[!RBNAM]_ 0;
1)		Chnior( dskchn, LKB[!RBCNT], !chREN );
****
2)11	    DateTimeStuff;
2)	    TailMessage _ "** (" & Author & ":" & Host & ")" &
2)			    Filename & " printed " & WeekDay & ", " &
2)			    LongDate & " at " & TimeOfDay & " **" & Crlf;
2)	    If not CZAP! then
2)	     begin "printer still there"
2)	      if NTQ! then AuxOut(CRLF&CRLF&"**** Print job aborted ****"&CRLF);
2)	      if not NTQ! then data!output_ work!done_ true;
2)	      if break neq #FF then AuxOut( #FF );
2)	      SetTypeSize( extension );		! reset for trailer ;
2)	  !   TrailerPage;			! TrailerPage disabled for now ;
2)	    end "printer still there";
2)	    if NTQ! then LogInfo( " Notice to quit " & LongDate);
2)	    LogInfo( " Finished ("& Author & ")" & Filename &
2)		     " Printed: "& cvs(LogPages) &" pages." );
2)	    if data!output
2)	     then begin
2)		if decext_ cvd(extension) > 001
2)		 then LKB[!RBEXT]_ Cvsix(ecext-1)[1 for 3]) lor !rh(LKB[!RBEXT])
2)		 else LKB[!RBNAM]_ 0;
2)		LKB[!RBNAM]_ 0;		! Always delete file (for now) ;
2)		Chnior( dskchn, LKB[!RBCNT], !chREN );
**************
1)12	if ( myppn neq '3000003 )		! If (LPQ) PPN = [ 3,3 ]  ;
1)	 then Create!printer!fork;
1)	SetLog( "(CARL)AUXSPL.LOG" );
1)	setbreak(inbrk_getbreak,#LF&#FF,null,"FINS");
****
2)13	! Start of main program ;
2)	if ( myppn neq '3000003 )		! If not logged in as LPQ[3,3] ;
2)	 then Create!printer!fork;
2)	SetLog( "(CARL)AUXSPL.LOG" );
2)	LogInfo( " Spooler started " & Weekday & "," & LongDate);
File 1)	DSK:AUXSPL.16	created: 1233 16-DEC-86
File 2)	DSK:AUXSPL.SAI	created: 1846 28-JAN-87

2)	setbreak(inbrk_getbreak,#LF&#FF,null,"FINS");
**************
1)12	while true				!  then loop till done.   ;
1)	 do begin
****
2)13	while not NTQ!				!  then loop till done.   ;
2)	 do begin
**************
1)12	    If NTQ! then Done;			! We have been told to leave ;
1)	    If not work!done
1)	     then Calli('201000030, calli!HIBER);	! then sleep for a bit ;
1)	end;
****
2)13	    If NTQ! then Done;			! Stop when evicted ;
2)	    If not work!done
2)	     then Calli(!XWD('201,30),calli!HIBER);	! sleep when UFD is empty ;
2)	end;
**************
1)12	Go!Away;
1)	end "Auxspl";
****
2)13	LogInfo( " Spooler stopped " & Weekday & "," & LongDate);
2)	Go!Away;
2)	end "Auxspl";
**************
  ^?
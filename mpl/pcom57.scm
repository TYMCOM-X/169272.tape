File 1)	DSK:PCOM56.SAI	created: 0508 30-MAR-83
File 2)	DSK:PCOM57.SAI	created: 0514 30-MAR-83

1)1	require (Ifcr PRELIMINARY thenc '101 elsec '1 endc lsh 18) lor '56 version;
1)	require "
****
2)1	require (Ifcr PRELIMINARY thenc '101 elsec '1 endc lsh 18) lor '57 version;
2)	require "
**************
1)22	    own integer array PC[0:5];	! run block for PEECOM (normal);
****
2)22	    own integer TmpSiz;		! size of file for PEECOM;
2)	    own integer array PC[0:5];	! run block for PEECOM (normal);
**************
1)22		if length( LogFileName ) and not Ext!Found
1)		 then LogFileName_ LogFileName & Default!Log
1)		 else L ogFileName_ Cvs(1000+JX)[2 to 4]&"PCO.LOG"
1)	     end "Setup PEECOM info";
****
2)22		if length( LogFileName )
2)		 then begin
2)		    if not Ext!Found
2)		     then LogFileName_ LogFileName & Default!Log
2)		 end
2)		 else LogFileName_ Cvs(1000+JX)[2 to 4]&"PCO.LOG";
2)		TmpSiz_ 1;			! default is the beginning;
2)		If ( swAPPEND )
2)		 then begin
2)		    Open( TmpChn_getchan, "DSK", 0, 0,0, 0,0, EoTmp_-1 );
2)		    Lookup( TmpChn, LogFileName, EoTmp_-1 );
2)		    If not ( EoTmp )		! if we have a file ;
2)		     then begin
2)			FileInfo( PC );		!   ask SAIL for info ;
2)			TmpSiz_ PC[5];		!   copy the size ;
2)			ArrClr( PC )		!   reset the array ;
2)		     end;
2)		    Release( TmpChn )		! done with the channel ;
2)		 end
2)	     end "Setup PEECOM info";
**************
1)22		TMPOUT( "PEC", LogFilename, EoTmp );
1)		If EoTmp
****
2)22		TMPOUT( "PEC", LogFilename & "/" & Cvs(TmpSiz), EoTmp );
2)		If EoTmp
**************
1)22		    Cprint( TmpChn, LogFileName );
1)		    Close( TmpChn ); Release( TmpChn )
****
2)22		    Cprint( TmpChn, LogFileName & "/", TmpSiz );
2)		    Close( TmpChn ); Release( TmpChn )
**************
   
File 1)	DSK:PCOM63.SAI	created: 1923 01-JUL-83
File 2)	DSK:PCOM.SAI	created: 1831 24-MAY-85

1)7	    Status _ Status!BEGIN;		! tell parent we've started;
1)	    Parent _ calli(0,calli!PJOB);	! remember who we are;
1)	    frame!block[ FrmCNT ]_ (CF!LIC lor 5);
1)	    frame!block[ FrmPPN ]_ calli( !Xwd( -1,!GTPPN ), calli!GETTAB );
****
2)7	    Redefine CF!LOG = !bit(17);
2)	    Status _ Status!BEGIN;		! tell parent we've started;
2)	    Parent _ calli(0,calli!PJOB);	! remember who we are;
2)	    frame!block[ FrmCNT ]_ (CF!LIC lor CF!LOG lor 5);
2)	    frame!block[ FrmPPN ]_ calli( !Xwd( -1,!GTPPN ), calli!GETTAB );
**** **********
1)8		[7] Cvs(101+R[1])[2 for 2]),
1)		[else] Null
****
2)8		[7] Cvs(101+R[1])[2 for 2],
2)		[else] Null
**************
1)9	    Assign( $Second      Second$);	! Current seconds of minute;
1)	    Assign( $SS,         SS$);		! Current seconds of minute SS;
****
2)9	    Assign( $Second,     Second$);	! Current seconds of minute;
2)	    Assign( $SS,         SS$);		! Current seconds of minute SS;
**************
  
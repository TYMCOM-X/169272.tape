File 1)	DSK:SMTPX.OLD	created: 0451 23-MAY-87
File 2)	DSK:SMTPX.SAI	created: 2040 02-SEP-88

1)1	require '21 version;
1)	! v21	23-May-87 WRS	added message-id to log;
****
2)1	require '22 version;
2)	! v22	 9-Sep-88 JMS	Add /GATEWAY for TRW;
2)	! v21	23-May-87 WRS	added message-id to log;
**************
1)1	string item HOST;
****
2)1	item GATEWAY;
2)	string item HOST;
**************
1)5	    if props(AUGMENT) and Status = 1 then auxOut( AugmentLogin );
****
2)5	    if props(GATEWAY) then Status := 0;    ! Zero if not in right network yet;
2)	    if props(AUGMENT) and Status = 1 then auxOut( AugmentLogin );
**************
1)5			    auxOut( datum(HOST) );
1)			    if IsLeft(datum(HOST),"MAIL:") then
****
2)5				! When HOST is a gateway host number, then user;
2)				! name MAIL must be homed to the destination. ;
2)			    if props(GATEWAY) then auxOut("MAIL")
2)			                      else auxOut( datum(HOST) );
2)			    if IsLeft(datum(HOST),"MAIL:") then
**************
1)9		{AUGMENT,BUBBNET,DELETE,HOST,RETRIES,TIMEOUT,TRACE,TYMCOMX,UNIX},
1)		ARGS );
****
2)9		{AUGMENT,BUBBNET,DELETE,GATEWAY,HOST,RETRIES,TIMEOUT,TRACE,TYMCOMX,UNIX},
2)		ARGS );
**************
    
File 1)	DSK:GFD.145	created: 0732 19-OCT-82
File 2)	DSK:GFD.MAC	created: 1843 19-SEP-89

1)1	tymrel==5	;bugfix nu.
1)	define titl(ts,tr)<
****
2)1	tymrel==7	;bugfix nu.
2)	define titl(ts,tr)<
**************
1)1	   	added code to look for access.msg in the
1)		directory just gfd'd into.  if found, the
****
2)1		added code to look for access.msg in the
2)		directory just gfd'd into.  if found, the
**************
1)1	>	; end repeat 0 for modhis
****
2)1	v 14.6;	Joe Smith 11/20/86; Ignore parenthesis when scanning for user name.
2)		Do CHGPPN a second time so monitor can set .GTNM1 and .GTNM2.
2)	v 14.7;	Joe Smith 5/ 25/89; Ignore LH when checking for overflow blocks.
2)	>	; end repeat 0 for modhis
**************
1)5		cail c,140
****
2)5		caie c,"("
2)		cain c,")"
2)		 jrst usrlp
2)		cail c,140
**************
1)6		 cain t1,")"
1)		  jrst tmpin1
1)		jumpe t1,tmpend		; end with null
****
2)6		cain t1,")"
2)		 jrst tmpin1
2)		jumpe t1,tmpend		; end with null
**************
1)7		camg t3,usrblk
****
2)7		HRRZS T3	;[JMS] Make sure sign bit is off for the compare
2)		camg t3,usrblk
**************
1)8	fndusr:	move t1,buf+lppn(ptr)	;yes, get ppn of destination user
****
2)8	;Now have user's entry in BUF
2)	fndusr:	move t1,buf+lppn(ptr)	;yes, get ppn of destination user
**************
1)11		useto ufd,2
1)		close ufd,
****
2)11		useto ufd,^D<7*4>	;Make it 7 pages long
2)		close ufd,
**************
1)12		dmovem t1,ufdnam+exlun1
1)		rename ufd,ufdnam
****
2)12		dmovem t1,ufdnam+exlun1	;Store correct username in UFD
File 1)	DSK:GFD.145	created: 0732 19-OCT-82
File 2)	DSK:GFD.MAC	created: 1843 19-SEP-89

2)		rename ufd,ufdnam
**************
1)12	ufdok:	
1)	adddon:	release ufd,0
****
2)12	ufdok:
2)	adddon:	release ufd,0
**************
1)21	msgdon:	releas msg,
1)		popj p,
1)22	end	stpt
****
2)20	msgdon:	getppn t1,		;Tell monitor to update JBTNM1 and JBTNM2
2)		  jfcl			; by doing CHGPPN again this time with a
2)		chgppn t1,		; file open (or a failed lookup) on channel
2)		  jfcl			; (Monitor uses name in DRB)
2)		releas msg,
2)		popj p,
2)21	end	stpt
**************
   
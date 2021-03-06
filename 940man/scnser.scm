File 1)	DSK:SCNSER.D04	created: 1802 17-MAR-88
File 2)	DSK:SCNSER.MAC	created: 1400 28-APR-88

1)23		ADDI	P4,1
****
2)23		PUSHJ	P,ORPLOG	;Put message into ORING log
2)		ADDI	P4,1
**************
1)23		ADDI	P4,1
****
2)23		PUSHJ	P,ORPLOG	;Put message into ORING log
2)		ADDI	P4,1
**************
1)24	;;;;;;;;BEGIN KMC DEBUG CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
****
2)24		PUSHJ	P,IRPLOG	;No, LOG current IRING data, P4=INDEX
2)	;;;;;;;;BEGIN KMC DEBUG CODE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
**************
1)24		MOVE	U,LINTAB(U)	;U/ PORT LDB
1)	BADPR1:	HLL	U,LDBDCH(U)
1)		TRZE	P1,200		;IF 200 BIT SET , IT'S DATA
****
2)24	BADPR1:	MOVE	U,LINTAB(U)	;U/ PORT LDB
2)		HLL	U,LDBDCH(U)
2)		TRZE	P1,200		;IF 200 BIT SET, IT'S DATA
**************
1)24	TTYBMT:: STOPCD (SCNIN1,INFO,TTYBMT,PRTIRG,<Bad Message Type from Base>);;CNTPRT-1
1)	CNTPRT:	XCT	TYPTRN(P1)	;DISPATCH TO IT
****
2)24	TTYBMT:: STOPCD (SCNIN2,INFO,TTYBMT,PRTIRG,<Bad Message Type from Base>);;CNTPRT-1
2)	CNTPRT:	XCT	TYPTRN(P1)	;DISPATCH TO IT
**************
1)24	BADPRT:	CAIE	P1,TYPANS	;(1) Answered, port = 0
****
2)24	;Check for legal messages that do not have port number in 2nd byte
2)	BADPRT:	CAIE	P1,TYPANS	;(1) Answered, port = 0
**************
1)27		 STOPCD (.+1,INFO,TTYZNE,PRTIRG,<Zapper not echoed for port>)
1)		PJRST	SIMRZP		; Simulate/force a zap (increment P4)
****
2)27		PUSHJ	P,ZAPBG0	;Save info, but use different stopcode
2)		 STOPCD (.+1,DEBUG,TTYZNE,PRTIRG,<Zapper not echoed for port>)
2)		PJRST	SIMRZP		; Simulate/force a zap (increment P4)
**************
1)75		SUBI	T1,200-5	;COMPUT NUMBER OF WORDS USED
****
2)75		PUSH	P,P3		; SAVE P3, THEN SETUP AS USUAL
2)		MOVE	P3,ORING(P4)	;  ORING(P4) contains data
2)		PUSHJ	P,ORPLOG	; Log the transmission
2)		POP	P,P3		; Restore saved P3 (someone want it)
2)		SUBI	T1,200-5	;COMPUT NUMBER OF WORDS USED
**************
1)76		SETOM	FSCN
****
2)76		PUSHJ	P,ORPLOG	;Put message into ORING log
2)		SETOM	FSCN
**************
File 1)	DSK:SCNSER.D04	created: 1802 17-MAR-88
File 2)	DSK:SCNSER.MAC	created: 1400 28-APR-88

1)76		SETOM	FSCN		;FLAG THAT THERE'S SOMETHING TO DO.
****
2)76	;** No LOG HERE **;
2)	;**;	PUSHJ	P,ORPLOG	;Put message into ORING log
2)		SETOM	FSCN		;FLAG THAT THERE'S SOMETHING TO DO.
**************
1)81	ZBGLIN:	0	;LDBLIN OF THE OFFENDING PORT
****
2)81	ZBGPC:	0	;Where problem was detected
2)	ZBGLIN:	0	;LDBLIN OF THE OFFENDING PORT
**************
1)81		PUSH	P,T2
1)		HRRZI	T2,ZBGBUG-1	;(PDL POINTER)
****
2)81	ZAPBG0:	PUSH	P,T2
2)		HRRZI	T2,ZBGBUG-1	;(PDL POINTER)
**************
1)81		PUSH	T2,LDBLIN(U)
****
2)81		PUSH	T2,-1(P)	;RETURN PC
2)		PUSH	T2,LDBLIN(U)
**************
1)83		ADDI	P4, 1
****
2)83		PUSHJ	P,ORPLOG	;Put message into ORING log
2)		ADDI	P4,1
**************
1)83	IFNCPU (KI),<MAP	T1,(T1)	;GET PHYSICAL ADDRESS
1)		DPB	T1,[POINT 18,P3,23] ;PUT IT IN
****
2)83	IFNCPU (KI),<
2)		MAP	T1,(T1)	;GET PHYSICAL ADDRESS
2)		DPB	T1,[POINT 18,P3,23] ;PUT IT IN
**************
1)83	IFCPU (KI),<DPB	T1,[POINT 9,P3,23] ;PUT IN LOW 9 BITS, MAP SMASHES THEM
1)		MAP	T1,(T1)		;GET PAGE NUMBER
****
2)83	IFCPU (KI),<
2)		DPB	T1,[POINT 9,P3,23] ;PUT IN LOW 9 BITS, MAP SMASHES THEM
2)		MAP	T1,(T1)		;GET PAGE NUMBER
**************
1)128		MOVE	T3,TTUUOT(W)	;GET DIPACTH ADRS AND BITS
****
2)128		AOS	TTCCNT(W)	;Count each TTCALL by function
2)		MOVE	T3,TTUUOT(W)	;GET DIPACTH ADRS AND BITS
**************
1)148		CAILE	T1,MAXAXC	;IF IT'S OUT OF RANGE,
1)		 POPJ	P,		;  JUST RETURN
1)		MOVE	T3,AXCTAB(T1)
****
2)148		CAIL	T1,AXCLEN	;IF IT'S OUT OF RANGE,
2)		 POPJ	P,		;  JUST RETURN
2)		AOS	AXCCNT(T1)	;Count AUXCALs by function
2)		MOVE	T3,AXCTAB(T1)
File 1)	DSK:SCNSER.D04	created: 1802 17-MAR-88
File 2)	DSK:SCNSER.MAC	created: 1400 28-APR-88

**************
1)149	MAXAXC==.-AXCTAB-1
1)150	SUBTTL	READ/SET TERMINAL CHARACTERISTICS BY NUMBER
****
2)149	AXCLEN==.-AXCTAB
2)	TTCCNT::BLOCK	20	;Count of TTCALLs by function
2)	AXCCNT::BLOCK	AXCLEN	;Count of AUXCALs by function
2)		SYDVF	(<<TTCCNT,20>,<AXCCNT,AXCLEN>>)	;2 items for SYSDVF
2)150	SUBTTL	READ/SET TERMINAL CHARACTERISTICS BY NUMBER
**************
1)154		DPB	T2,LDBTYP	;Valid type, set it
1)	PRINTF (<[Need to set WIDTH, ERASE, etc at ACTTYP]>)
****
2)154		DPB	T2,LDPTYP	;Valid type, set it
2)	PRINTF (<[Need to set WIDTH, ERASE, etc at ACTTYP]>)
**************
1)170		SOJLE	T2,AXCLP2	;RAN OUT OF ROOM
****
2)170		PUSHJ	P,ORPLOG	;Put message into ORING log
2)		SOJLE	T2,AXCLP2	;RAN OUT OF ROOM
**************
1)190		MOVE	T2,LDBMOD(U)
****
2)190	IFCPU (KL),<;P035/D05 - make sure page containing buffer is uncached.
2)		PUSH	P,T1		;Save pointer
2)		HRLI	T1,BIOCOR	;Size of buffer in LH
2)		PUSHJ	P,CSHCLR##	;Clear cache bit in EPT
2)		POP	P,T1
2)	>
2)		MOVE	T2,LDBMOD(U)
**************
1)191	IFNKMC<	AOJA	P4,SCNIN1>	;IGNORE ANS MESSAGE ON KI/KL/F3
1)	IFKMC<	MOVE	T1,DRMTIM ;;;;;;;TEMP PUT TIME IN IRING 1 MSG
****
2)191	IFNKMC<	MOVE	T1,IRING(P4)	;Get the message
2)		EXCH	T1,BASVER##	;Store BYTE(8)CODE,DEBUG,VERSION,RELEASE
2)		CAME	T1,BASVER##	;Don't mumble about 2 in a row
2)		 STOPCD	(,XCT,BASEOK)	;Print "base is up" message
2)		AOJA	P4,SCNIN1>	;IGNORE ANS MESSAGE ON KI/KL/F3
2)	IFKMC<	MOVE	T1,DRMTIM ;;;;;;;TEMP PUT TIME IN IRING 1 MSG
**************
1)226		ADDI	P4,1
****
2)226		PUSHJ	P,ORPLOG	;Put message into ORING log
2)		ADDI	P4,1
**************
1)230	TTYZAP:	MOVEI	T2,1
1)		MOVSI	T1,LLLNLN	;NLN set if base sent zap to us
1)		TDNN	T1,LDBLOG(U)	;IF IT'S A HANGUP NOT AN INCOMING ZAP,
1)		 DPB	T2,LOPSYL	;  SET SEND-YELLOW-BALL
1)		DPB	T2,LOPZAP	;SET SEND-ZAPPER
1)		DPB	T2,LDBOPB(U)	;SET NEED-OUTPUT
1)		MOVSI	T1,LDLNOP
1)		ANDCAM	T1,LDBDCH(U)	;IGNORE BACKPRESSURE
File 1)	DSK:SCNSER.D04	created: 1802 17-MAR-88
File 2)	DSK:SCNSER.MAC	created: 1400 28-APR-88

1)		MOVSI	T1,LMLBIO
1)		TDNE	T1,LDBMOD(U)	;IF IT'S IN BLOCK I/O MODE,
1)		 PUSHJ	P,BIOREL	;  GET IT OUT
1)		POPJ	P,
1)231	SUBTTL	TTYATT - ATTACH LDB TO JOB
1)	;	   U/ LDB  J/ JOB#
****
2)230	;Whenever a zapper originates from the PDP-10, then a yellow ball is
2)	;sent out first to make sure that the zapper does not gobble any of the
2)	;logout messages.  In this case, a 20-second timer is started and the
2)	;zapper is not sent until an orange ball is reflected by the TYMSAT.
2)	;
2)	;Whenever a zapper originates from TYMNET, the base has already given up
2)	;on the port and marks is as being "in clean up" until we return the zapper.
2)	;
2)	;In either case, the line is marked as "not in use" when we send a zapper.
2)	;We must respond to incoming zappers, but the base sends no response to
2)	;an outgoing zapper.
2)	;Change in P035/D05 - don't send yellow ball if line is not marked in use,
2)	;because base will ignore it and we will be waiting 20 seconds for an orange
2)	;ball that will never come in.  However, if a login just happens to come in
**************
1)231	TTYATT::PUSH	P,U
****
2)230	;for 128 ports and its base for 127, the base would crash when a zapper
2)	;was sent out on TTY177.
2)	TTYZAP:	MOVEI	T2,1
2)		MOVE	T1,LDBLOG(U)	;Get TYMNET status of line
2)		JUMPGE	T1,TTYZP1	;No yellow/orange if port not in use
2)		TLNN	T1,LLLNLN	;Send yellow ball and wait for orange to be
2)		 DPB	T2,LOPSYL	; reflected (unless zap came from base)
2)	TTYZP1:	DPB	T2,LOPZAP	;Set flag to send zapper
2)		DPB	T2,LDBOPB(U)	;Mark line as needing output
2)		MOVSI	T1,LDLNOP
2)		ANDCAM	T1,LDBDCH(U)	;Ignore backpressure
2)		MOVSI	T1,LMLBIO
2)		TDNE	T1,LDBMOD(U)	;If it's in block I/O mode,
2)		 PUSHJ	P,BIOREL	; get it out
2)		POPJ	P,
2)231	SUBTTL	TTYATT - ATTACH LDB TO JOB
2)	;	   U/ LDB  J/ JOB#
2)	;	   SKIP-RETURNS ON SUCCESS WITH F/ CMND PORT DDB
2)	;	   NONSKIP-RETURNS ON FAILURE WITH F/ 0
2)	TTYATT::PUSH	P,U
**************
1)254	SUBTTL	 VARIABLES
****
2)254	SUBTTL	ROUTINES TO LOG IRING AND ORING ACTIVITY
2)	;IRPLOG - routine to keep a log of iring messages
2)	;
2)	;  Assumes P1 and U may be clobbered since they will be
2)	;  reused immediately upon return.  If this changes, the
2)	;  appropriate registers should be saved.
2)	IRPLOG:	MOVE	U,IRING(P4)		; Get IRING message
File 1)	DSK:SCNSER.D04	created: 1802 17-MAR-88
File 2)	DSK:SCNSER.MAC	created: 1400 28-APR-88

2)		AOS	P1,SCNPTR		; Increment to next position
2)		ANDI	P1,777			; Keep offset
2)		JUMPN	P1,IRPLO1		; Not first - just log it
2)		MOVE	P1,DATE##		; Get current daytime
2)		MOVEM	P1,SCNUDT		; And remember...
2)		SETZ	P1,			; Clear counter
2)	IRPLO1:	MOVEM	U,SCNBUF(P1)		; Store
2)		POPJ	P,			; Return
2)	;ORPLOG - routine to keep a log of oring messages
2)	;
2)	;  Assumes P3 already setup containing data to store
2)	;  (If not, ORING(P4) does contain the correct data)
2)	ORPLOG:	PUSH	P,P1			; Save P1
2)		AOS	P1,SCNPTR		; Increment to next position
2)		ANDI	P1,777			; Keep offset
2)		JUMPN	P1,ORPLO1		; Not first - just log it
2)		MOVE	P1,DATE##		; Get current daytime
2)		MOVEM	P1,SCNUDT		; And remember...
2)		SETZ	P1,			; Clear counter
2)	ORPLO1:	MOVEM	P3,SCNBUF(P1)		; Log it
2)		POP	P,P1			; Restore P1
2)		POPJ	P,
2)255	SUBTTL	 VARIABLES
**************
1)255	SCNBUF:: BLOCK	2		;Buffer for trackRING/ORING bugs
1)	SCNBLN==:.-SCNPTR		;Length for SYSDVF (includes SCNPTR)
1)		SYDVF (<<SCNBUF,SCNBLN>,<SCNPTR,1>>)	;2 things for SYSDVF
1)		$END	(SCN)		;End of SCNSER (SCNLIT: SCNEND:)
****
2)256	SCNUDT:: EXP	-1		;Time buffer last wrapped
2)	SCNBUF:: BLOCK	1000		;Buffer for tracking IRING/ORING bugs
2)	SCNBLN==:.-SCNPTR		;Length for SYSDVF (includes SCNPTR)
2)		SYDVF (<<SCNUDT,1>,<SCNPTR,1>,<SCNBUF,SCNBLN>>)	;3 things for SYSDVF
2)		$END	(SCN)		;End of SCNSER (SCNLIT: SCNEND:)
**************
 e;{
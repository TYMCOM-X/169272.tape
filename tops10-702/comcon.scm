File 1)	DSKU:COMCON.MAC[702,10]	created: 1148 04-Jan-84
File 2)	DSKU:COMCON.CSM[702,10]	created: 0033 17-Dec-84

1)1	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
****
2)1		CSMEDT	10	;Initialize CSM edit 10 - Check for ambiguous commands
2)		CSMEDT	11	;Initialize CSM edit 11 - PJOB and DAYTIME improvements
2)		CSMEDT	12	;Initialize CSM edit 12 - Include PPN & time in SEND
2)		CSMEDT	14	;Initialize CSM edit 14 - ESC for PF keys and "/", "@"
2)		CSMEDT	15	;Initialize CSM edit 15 - KJOB and BYE
2)		CSMEDT	17	;Initialize CSM edit 17 - SET COMMAND SYS
2)	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
**************
1)6	;HERE WITH T2=COMMAND, P3=DISPATCH TABLE, P4=AOBJN TABLE
1)	COM1A:	SETZ	T1,		;NO FLAGS, INDICATE NORMAL TABLE SEARCH
1)		PUSHJ	P,FNDABV	;LOOK IT UP
1)		  SETOM	T1		;ERROR--SET FLAG
1)		JUMPGE	T1,COM1B	;GO IF NO ERROR
1)		HRRZ	P2,LINTAB##+FRCLIN## ;GET LDB ADDRESS OF FRCLIN
1)		CAIE	P2,(U)		;UNKNOWN COMMAND TYPED ON FRCLIN?
1)		JRST	COM1B		;NO, CONTINUE
1)		MOVEI	T1,.RNTXT##-COMTAB##(P4) ;GET OFFSET OF .RUN COMMAND
1)		MOVE	P2,T2		;GET NAME TO RUN
1)		MOVE	M,.RNTXT##-COMTAB##+DISP##
1)		JRST	COM1C		;JOIN COMMON CODE
1)	COM1B:	CAIL	T1,COMPIL##-COMTAB##
1)		CAILE	T1,LASCCL##-COMTAB##
1)		TRNA
****
2)6		CSMEDT	14,1		;Special command chars, part 1 at COM1:+3
2)	IFN CSM14$,<		;Check for "@", "/", and ESC
2)		JUMPN	T2,COM1A	;Skip these checks if already have a command
2)		CAIE	T3,"/"		;Check for slash
2)		CAIN	T3,"@"		; or an AT sign
2)		 MOVSI	T2,'DO '	; since MIC understands both
2)		CAIN	T3,33		;ESCape?
2)		 MOVSI	T2,'ESC'	;Yes, set up to interpret Program Function Key
2)	>  ;End of IFN CSM14$
2)7	;HERE WITH T2=COMMAND, P3=DISPATCH TABLE, P4=AOBJN TABLE
2)		CSMEDT	10,2		;Ambiguous commands, part 2 at COM1A:+2
2)	COM1A:	SETZ	T1,		;NO FLAGS, INDICATE NORMAL TABLE SEARCH
2)		PUSHJ	P,FNDABV	;LOOK IT UP
2)	IFE CSM10$,< SETOM T1 >		;ERROR--SET FLAG
2)	IFN CSM10$,< JFCL >		;T1=-1 for unknown, T1=-2 for ambiguous
2)		JUMPGE	T1,COM1B	;GO IF NO ERROR
2)		HRRZ	P2,LINTAB##+FRCLIN## ;GET LDB ADDRESS OF FRCLIN
2)		CAIE	P2,(U)		;UNKNOWN COMMAND TYPED ON FRCLIN?
2)		JRST	COM1B		;NO, CONTINUE
2)		MOVEI	T1,.RNTXT##-COMTAB##(P4) ;GET OFFSET OF .RUN COMMAND
2)		MOVE	P2,T2		;GET NAME TO RUN
2)		MOVE	M,.RNTXT##-COMTAB##+DISP##	;Set flags for .RUN command
2)		JRST	COM1C		;JOIN COMMON CODE
2)	;[CSM] Positive T1 for good match, -1 for unknown, -2 for ambiguous
2)	COM1B:	CAIL	T1,COMPIL##-COMTAB##	;In range of commands that
2)		CAILE	T1,LASCCL## -COMTAB##	; run COMPIL
2)		TRNA
**************
1)6		MOVSI	T1,1		;FLAG INDICATING THIS IS USER-COMMAND SEARCH
****
File 1)	DSKU:COMCON.MAC[702,10]	created: 1148 04-Jan-84
File 2)	DSKU:COMCON.CSM[702,10]	created: 0033 17-Dec-84

2)7	;1B17 tells FNDABV to search COMTAB again if no exact match in user commands
2)		MOVSI	T1,1		;FLAG INDICATING THIS IS USER-COMMAND SEARCH
**************
1)6	COMNLG:
1)		ADDI	T1,(P4)		;COMPUTE MATCH LOCATION
1)7		MOVE	P2,(T1)		;SAVE NAME OF COMMAND
1)	COM1C:	TLZ	T1,-1		;CLEAR JUNK
1)		CAILE	T1,COMPIL##	;SEE IF COMPIL##
1)		CAIL	T1,LASCCL##	;  ..
1)		JRST	COM1D		;NO
1)		MOVEI	T1,COMPIL##	;YES
1)		MOVE	M,COMPIL##-COMTAB##+DISP##
1)	COM1D:	SUBI	T1,(P4)		;INDEX OF TABLE
1)		ADDI	P3,(T1)		;POINT P3 TO DISPATCH ENTRY
1)		SKIPGE	T1		;SEE IF ERROR
1)		MOVEI	P3,COMERD##	;YES--SET DISPATCH
1)		HRR	M,(P3)		;GET DISPATCH TABLE ENTRY
****
2)7	COMNLG:	CSMEDT	17,6	;SET COMMAND SYS, part 6 at COMNLG
2)	IFN CSM17$,<	;Run programs from SYS if unknown command
2)		HRRZ	T4,P4		;Get the command table pointer
2)		CAIN	T4,COMTAB##	;Still in main table?
2)		CAME	T1,[-1]		; and unknown command?
2)		 JRST	CSM17Z		;No, skip all this
2)		MOVE	T4,JBTSTS##(J)	;Get the job status bits
2)		TLNN	T4,JLOG		;Logged in?
2)		 JRST	CSM17Z		;No, give up, type "?Unknown command"
2)		TLNE	T4,SWP		;Is job on disk or on its way?
2)		 JRST	[HRRI	M,DLYCM	  ;Yes, set to swap job in
2)			 JRST	COMDIS]	  ;Wait for it to come in
2)		SKIPN	.PDCMD##(W)	;Is SET COMMAND device nonzero?
2)		 JRST	CSM17Z		;No, give up, type "?Unknown command"
2)	;Call-by-name for devices other than just SYS:, T2 has program name
2)		MOVEM	T2,.PDCMD##+1(W);Set name of program
2)		HRLI	P3,.PDCMD##-1(W);Point to start of 3-word block
2)		HRRI	P3,DISP##	;For later use (P4 still points to COMTAB)
2)		MOVEI	T1,PLNTXT##-COMTAB## ;Index to SIXBIT/.PLRUN/
2)		MOVE	M,DISP##(T1)	;Set flags for .PLRUN command
2)	CSM17Z:	>  ;End of CSM17$
2)		ADDI	T1,(P4)		;COMPUTE MATCH LOCATION
2)8		MOVE	P2,(T1)		;SAVE NAME OF COMMAND
2)	COM1C:
2)	;[CSM] The following was tested for at COM1B:           CSM
2)		TLZ	T1,-1		;CLEAR JUNK             CSM
2)		CAILE	T1,COMPIL##	;SEE IF COMPIL##        CSM
2)		CAIL	T1,LASCCL##	;  ..                   CSM
2)		JRST	COM1D		;NO                     CSM
2)		MOVEI	T1,COMPIL##	;YES                    CSM
2)		MOVE	M,COMPIL##-COMTAB##+DISP##             ;CSM
2)	COM1D:	SUBI	T1,(P4)		;INDEX OF TABLE
2)	;At this point, P4 has original AOBJN pointer, T1 has index into table,
2)	;M has flags in LH, and P2 has command name in SIXBIT, P3 has dispatch table
2)		ADDI	P3,(T1)		;POINT P3 TO DISPATCH ENTRY
2)		SKIPGE	T1		;SEE IF ERROR
2)		MOVEI	P3,COMERD##	;YES--SET DISPATCH
2)		CSMEDT	10,3	;Ambiguous commands, part 3 at COM1D:+4
File 1)	DSKU:COMCON.MAC[702,10]	created: 1148 04-Jan-84
File 2)	DSKU:COMCON.CSM[702,10]	created: 0033 17-Dec-84

2)	IFN CSM10$,<
2)		CAMN	T1,[-2]		;Ambiguous command?
2)		 MOVEI	P3,AMBCMD##	;Yes, set ambiguous command dispatch
2)	>  ;End of IFN CSM10$
2)		HRR	M,(P3)		;GET DISPATCH TABLE ENTRY
**************
1)11	CHKAC0:	TLNN	P4,SWP
1)		JRST	CHKAC1
1)		JUMPN	R,CHKDLY
1)		PUSHJ	P,PUSHCT
1)		  JRST	CHKDLY
1)		MOVSI	T1,(JS.SAC)
1)		SKIPL	.PDSAC##(W)
1)		IORM	T1,JBTST2##(J)
****
2)12	CHKAC0:	TLNN	P4,SWP			;[CSM] Uncommented code!
2)		JRST	CHKAC1
2)		JUMPN	R,CHKDLY
2)		PUSHJ	P,PUSHCT                ;CSM  Uncommented code
2)		  JRST	CHKDLY
2)		MOVSI	T1,(JS.SAC)
2)		SKIPL	.PDSAC##(W)             ;CSM  Uncommented code
2)		IORM	T1,JBTST2##(J)
**************
1)17	;THIS PRINTS OUT:
1)	;
1)	; JOB N USER NAME [P,PN] TTY#
1)	;
1)	PJOBX:: PUSHJ	P,SAVJW##	;SAVE J(W GETS A RIDE)
1)		PUSHJ	P,GETJOB	;GET JOB NUMBER TO DO PJOB ON
1)		  SKIPA			;NO JOB NUMBER SO USE CURRENT JOB
1)		MOVE	J,T2		;PUT REQUESTED JOB NUMBER IN AC(J)
1)		JUMPE	J,ATT4		;ERROR IF NO JOB ASSIGNED
****
2)18		CSMEDT	11,5		;PJOB and DAYTIM, part 5 at DECLF::+2
2)	IFN CSM11$,<	;Routine to change the user's name
2)	USRNAM::PUSHJ	P,FNDPDB##	;Find the PDB
2)		  POPJ	P,		;Should not happen
2)		PUSHJ	P,SKIPS1	;Skip leading spaces
2)		  JRST	PJOBX0		;Nothing there, show current user name
2)		PUSHJ	P,GETSX1	;Get an arbitrary string of SIXBIT chars
2)		PUSH	P,T2		;Save for a bit
2)		MOVEI	T2,0		;In case end of line already (short name)
2)		CAIL	T3,40		;Take any control char as end of line
2)		 PUSHJ	P,GETSIX	;Get the second part
2)		POP	P,T1		;Get first half
2)		MOVE	T3,JBTPPN(J)	;Get job's PPN
2)		TRNN	T3,700000	;Student PPN? (100000 to 377777)
2)		 DMOVEM	T1,.PDNM1##(W)	;No, store as new user name
2)		JRST	PJOBX0		;Show what the new name is
2)	;Routine to get arbitrary SIXBIT name into T2, uses T3
2)	GETSIX:	PUSHJ	P,COMTYS	;Get a new char in T3
2)	GETSX1:	PUSHJ	P,SAVE1##	;Save P1
2)		SETZ	T2,		;Clear the word
2)		SKIPA	P1,[POINT 6,T2]	;Set up byte pointer
2)	GETSX2:	PUSHJ	P,COMTYS	;Get char, uppercase, no comments
File 1)	DSKU:COMCON.MAC[702,10]	created: 1148 04-Jan-84
File 2)	DSKU:COMCON.CSM[702,10]	created: 0033 17-Dec-84

2)		CAIGE	T3,40		;A control char?
2)		 POPJ	P,		;Yes, done
2)		MOVEI	T1,-40(T3)	;Convert to SIXBIT
2)		IDPB	T1,P1		;Store in T2
2)		TLNE	P1,770000	;Any more room?
2)		 JRST	GETSX2		;Yes, go for more
2)		POPJ	P,		;No, return with a full word
2)	;Routine to get a job number.  If number starts with a "#", it will be
2)	;taken as a line number, and translated to a job number, like SYSTAT does.
2)	GETJBL::PUSHJ	P,SKIPS1	;Skip leading spaces
2)		  POPJ	P,		;Nothing there
2)		CAIN	T3,"#"		;See if pound sign
2)		 JRST	GETJL1		;Yes, get job corresponding to TTY
2)		PUSHJ	P,DECIN1	;Get decimal number
2)		  POPJ	P,		;Nothing typed
2)		  JRST	COMERP		;Invalid character
2)		AOS	(P)		;Make for skip return
2)		JRST	GETJB1		;Do validity checking in GETJOB routine
2)	;Here for ".PJOB #122", show status of job using TTY122.
2)	;Very handy if you get a SEND message while in TECO and want to find
2)	;the name of the SENDer without blowing your core image (ala SYSTAT).
2)	GETJL1:	PUSHJ	P,OCTIN1	;Get octal number from terminal
2)		  JRST	COMERP		;Nothing after the #
2)		  JRST	COMERP		;Invalid character
2)		CAIL	T2,TTPLEN##	;Within range?
2)		 JRST	COMERP		;No, number too big to be a TTY line
2)		PUSH	P,F		;Save F
2)		MOVE	F,LINTAB##(T2)	;Get pointer to specified TTY
2)		HRRZ	F,LDBDDB##(F)	;Point to the DDB
2)		SKIPE	T2,F		;If none return zero
2)		 LDB	T2,PJOBN##	;Else get owner's job number
2)		POP	P,F		;Restore F
2)		AOS	(P)		;Make for skip return
2)		JRST	GETJB1		;Do validity checking in GETJOB routine
2)	>  ;End of IFN CSM11$
2)19	;THIS PRINTS OUT:
2)	;
2)	; JOB N USER NAME [P,PN] TTY	;
2)	PJOBX:: PUSHJ	P,SAVJW##	;SAVE J(W GETS A RIDE)
2)	IFE CSM11$,<
2)		PUSHJ	P,GETJOB	;GET JOB NUMBER TO DO PJOB ON
2)	>  ;End of IFE CSM11$
2)	IFN CSM11$,<	;Allow for # in job number
2)		PUSHJ	P,GETJBL	;GET JoB or Line number
2)	>  ;End of IFN CSM11$
2)		  SKIPA			;NO JOB NUMBER SO USE CURRENT JOB
2)		MOVE	J,T2		;PUT REQUESTED JOB NUMBER IN AC(J)
2)	IFN CSM11$,<PJOBX0:>		;Here to do 2nd half of USRNAM command
2)		JUMPE	J,ATT4		;ERROR IF NO JOB ASSIGNED
**************
1)18	KJOB::	JUMPE	J,ATT4		;WAS JOB INITIALIZED?
1)		TLNN	P4,JLOG		;TEST JLOG ALSO IN CASE JOB NOT LOGGED IN
****
2)20		CSMEDT	15,4		;BYE and KJOB, part 4 at KJOB::
2)	IFE CSM15$,<
File 1)	DSKU:COMCON.MAC[702,10]	created: 1148 04-Jan-84
File 2)	DSKU:COMCON.CSM[702,10]	created: 0033 17-Dec-84

2)	KJOB::	JUMPE	J,ATT4		;WAS JOB INITIALIZED?
2)	>  ;End of CSM15$
2)	IFN CSM15$,<
2)	KJOB::	JUMPE	J,[PUSHJ P,HANGUP##	;Disconnect dataset if no job number
2)			     PJRST ATT4		;Not a job and not a dataset
2)			   TLO   M,NOMESS!NOCRLF!NOPER!NOJOBN!NOINCK
2)			   POPJ  P,	]	;Don't type anything at all
2)		PUSHJ	P,CTIGLC##	;Re-get last character scanned
2)		CAIE	T3,"/"		;Was it "K/F"?
2)		TLNE	T2,007777	;More than just one letter typed?
2)		 JRST	KJOB1		;Yes, I'll allow that
2)		JSP	T1,ERRMES	;The single letter "K" is no longer legal
2)		ASCIZ	/Please type KJOB
2)	/
2)	KJOB1:	>  ;End of IFN CSM15$
2)		TLNN	P4,JLOG		;TEST JLOG ALSO IN CASE JOB NOT LOGGED IN
**************
1)18		MOVE	P2,LGONAM##	;GET 'LOGOUT'
****
2)20	IFN CSM15$,<	;BYE runs BYE.EXE, KJOB runs LOGOUT.EXE
2)		PUSHJ	P,CTIGLC##	;Re-get last character scanned
2)		CAIE	T3,12		;If LF, skip BYE and go directly to LOGOUT
2)	BYE::	 CAME	P2,['BYE   ']	;Run SYS:BYE.EXE in BYE/I (old KJOB program)
2)	>  ;End of IFN CSM15$
2)		MOVE	P2,LGONAM##	;GET 'LOGOUT'
**************
1)33	IFN	FTPATT,<
1)		EXP	CPOPJ##		;ROOM FOR PATCHING
1)	>
1)	SETTBL:	XWD	NEDPRV,SETMX1	;(0) - SET CORMAX
****
2)35	IFN FTPATT,<EXP	CPOPJ##	>	;ROOM FOR PATCHING
2)		CSMEDT	17,7	;SET COMMAND SYS, part 7 at SETTBC+2
2)	IFN CSM17$,<EXP	SETCMU	>	;(-1) SET COMMAND (run programs from SYS)
2)	SETTBL:	XWD	NEDPRV,SETMX1	;(0) - SET CORMAX
**************
1)33	;STILL IN FTSET CONDITIONAL
****
2)36		CSMEDT	17,8		;SET COMMAND SYS, part 8 after end of SETTBL
2)	IFN CSM17$,<	;".SET COMMAND PUB" will run PUB:FOOBAR.EXE when "FOOBAR" is
2)			;typed and FOOBAR has not been DECLARed to be a known command.
2)	;Here from -1 function of the SETUUO
2)	SETCMU::HRR	M,T2		;COPY ADDRESS
2)		PUSH	P,J
2)		PUSHJ	P,GETWDU##	;GET THE WORD
2)		POP	P,J
2)		PUSHJ	P,FNPDBS##
2)		EXCH	T1,.PDCMD##(W)	;Change command device
2)		JRST	STOTC1##	;Return previous value to user
2)	;Here from COMCON on "SET COMMAND"
2)	SETCMS::PUSHJ	P,CTEXT1	;Get the next word, set T2=0 if nothing there
2)		JUMPE	T2,STCMS1	;Output current setting if blank
2)		CAME	T2,[SIXBIT/NONE/];Want to disable this feature?
2)		CAMN	T2,[SIXBIT/NUL/]
2)		 MOVEI	T2,0		;Yes, don't run commands from SYS: or wherever
2)		MOVEM	T2,.PDCMD##(W)	;Store device for commands
File 1)	DSKU:COMCON.MAC[702,10]	created: 1148 04-Jan-84
File 2)	DSKU:COMCON.CSM[702,10]	created: 0033 17-Dec-84

2)		MOVEI	T1,3
2)		MOVEM	T1,.PDCMD##-1(W);Set size of pathological command block
2)		SETZM	.PDCMD##+1(W)	;This gets filled in at COMNLG + a few
2)		JRST	CPOPJ1##	;OK return
2)	STCMS1:	MOVEI	T1,[ASCIZ /[Commands default to /]
2)		PUSHJ	P,CONMES
2)		SKIPN	T2,.PDCMD##(W)	;Get device
2)		 MOVE	T2,['(NONE)']
2)		PUSHJ	P,PRNAME##
2)		MOVEI	T3,"]"
2)		PJRST	COMTYO##
2)	>  ;End of IFN CSM17$
2)	;STILL IN FTSET CONDITIONAL
**************
1)83		TLNE	T2,TTYOUW##	;OUTPUT DIRECTION?
1)		MOVEI	T1,[ASCIZ "
1)	Output"]
1)		JRST	USECMB		;TYPE THE MESSAGE
1)	USECMA:	TLNE	T2,IO		;OUTPUT DIRECTION?
1)		MOVEI	T1,[ASCIZ "
1)	Output"]
1)	USECMB:	PUSHJ	P,CONMES	;PRINT THE TEXT
1)		MOVEI	T1,[ASCIZ " wait for "]
****
2)85	;[CSM] The MOVEI and JRST can be eliminated by changing the TTY test
2)		TLNN	T2,TTYOUW##	;Terminal output wait?
2)	USECMA:	TLNE	T2,IO		;OUTPUT DIRECTION?
2)		MOVEI	T1,[ASCIZ "
2)	Output"]
2)		PUSHJ	P,CONMES	;PRINT THE TEXT
2)		MOVEI	T1,[ASCIZ " wait for "]
**************
1)90	;RUNAME--COMMAND WHICH RUNS CUSP OF SAME NAME
1)	RUNAME::TLNE	P4,JLOG		;SEE IF LOGGED IN
****
2)92	;RUNAME--COMMAND WHICH RUNS CUSP OF SAME NAME (name is in P2)
2)	RUNAME::TLNE	P4,JLOG		;SEE IF LOGGED IN
**************
1)117	;DATIME - PRINT DATE, TIME (NO CRLF)
1)	DATIME::MOVE	T1,LOCDAY##	;PRINT DAY
1)		PUSHJ	P,RADX10##
****
2)119		CSMEDT	11,6	;PJOB and DAYTIM, part 6 at DAYTIM::+2
2)	IFN CSM11$,<	;This will print midnight as "00:00:00" instead of "0.00"
2)	PRDTIM::PUSHJ	P,PRNOW		;Output the time in the right format
2)		PJRST	CRLF		;Finish the line
2)	PRNOW::	MOVE	T1,LOCHOR##	;Get current hour
2)		PUSHJ	P,PR2DIG	;Print 2 decimal digits
2)		MOVE	T1,LOCMIN##	;Get current minute
2)		PUSHJ	P,PCOL2D	;Print a colon and 2 digits
2)		MOVE	T1,LOCSEC##	;Get current seconds
2)		PJRST	PCOL2D		;Colon and 2 digits (no CRLF)
2)	PCOL2D::MOVEI	T3,":"		;Get a colon
2)		PUSHJ	P,PRCHR		;Print it preserving T1
2)	PR2DIG::IDIVI	T1,^D10		;Separate the two digits
2)		PUSH	P,T2		;Save the second one
File 1)	DSKU:COMCON.MAC[702,10]	created: 1148 04-Jan-84
File 2)	DSKU:COMCON.CSM[702,10]	created: 0033 17-Dec-84

2)		MOVEI	T3,"0"(T1)	;Convert to ASCII
2)		PUSHJ	P,COMTYO##	;Output it
2)		POP	P,T3		;Get back the second digit
2)		ADDI	T3,"0"		;Also ASCII
2)		PJRST	COMTYO##	;Output it
2)	WEKDAY::[ASCIZ	/Wednesday /]	;Table of days of the week
2)		[ASCIZ	/Thursday /]	;Day 1 = 18-Nov-1858 = Thursday
2)		[ASCIZ	/Friday /]
2)		[ASCIZ	/Saturday /]
2)		[ASCIZ	/Sunday /]
2)		[ASCIZ	/Monday /]
2)		[ASCIZ	/Tuesday /]
2)	;DATIME - PRINT DATE, TIME (NO CRLF)
2)	DATIME::MOVE	T1,DATE##	;Get GMT universal date/time
2)		ADD	T1,GMTDIF##	;Convert to local time
2)		HLRZS	T1		;Keep only the day portion
2)		IDIVI	T1,7		;Find day modulo 7
2)		MOVE	T1,WEKDAY(T2)	;Get pointer to name of day
2)		PUSHJ	P,CONMES	;Type the day
2)	>  ;End of IFN CSM14$
2)	IFE CSM11$,<DATIME::>
2)		MOVE	T1,LOCDAY##	;PRINT DAY
2)		PUSHJ	P,RADX10##
**************
1)117	PRDTIM::MOVE	T1,TIME##	;PRINT TIME OF DAY
1)	PRTIME::PUSHJ	P,PRTIM		;PRINT TIME AS HH:MM:SS(NO CRLF)
1)		PJRST	CRLF		;AND ADD CRLF
****
2)119	IFE CSM11$,<	;This routine types midnight wrong, it types "0.00"
2)	PRDTIM::MOVE	T1,TIME##	;PRINT TIME OF DAY
2)	>  ;End of IFE CSM11$
2)	PRTIME::PUSHJ	P,PRTIM		;PRINT TIME AS HH:MM:SS or S.HH (no CRLF)
2)		PJRST	CRLF		;AND ADD CRLF
**************
1)126		PUSHJ	P,PRNAME##	;OUTPUT THE NAME TO SENDEE
1)		PUSHJ	P,INLMES	;AND SPACER
1)		ASCIZ	/: - /		; ..
1)		POPJ	P,0		;RETURN FROM SENDHD
****
2)128		CSMEDT	12,1		;SEND changes, part 1
2)	IFE CSM12$,<
2)		PUSHJ	P,PRNAME##	;OUTPUT THE NAME TO SENDEE
2)		PUSHJ	P,INLMES	;AND SPACER
2)		ASCIZ	/: - /		; ..
2)	>  ;End of IFE CSM12$
2)	IFN CSM12$,<
2)		MOVE	T4,T2		;Save name of sender
2)		PUSHJ	P,PRNAME##	;Output the name to sendee
2)		CAME	T4,[SIXBIT/OPR/] ;If OPR
2)		CAMN	T4,[SIXBIT/SYSTEM/]	; or FRCLIN
2)		 JRST	CSM12Y		; use old format
2)		PUSHJ	P,INLMES	;Print separator
2)		ASCIZ	/: /		;Colon and space
2)		SKIPN	T2,JBTPPN##(J)	;Get sender's PPN
2)		 MOVE	T2,HLPPPN##	; use [2,5] instead of [0,0]
2)		PUSHJ	P,PRTPPN	;Type it
File 1)	DSKU:COMCON.MAC[702,10]	created: 1148 04-Jan-84
File 2)	DSKU:COMCON.CSM[702,10]	created: 0033 17-Dec-84

2)		PUSHJ	P,PR3SPC	;Print 3 spaces
2)		PUSHJ	P,PRDTIM	;Print time of day and CRLF
2)		MOVEI	T1,[BYTE (7) ";", 7, ";", " ", 0] ;Semi, bell, semi, space
2)		SKIPA			;Skip over alternate point
2)	CSM12Y:	MOVEI	T1,[ASCIZ /: - /]	;OPR separator
2)		PUSHJ	P,CONMES	;Type it
2)	>  ;End of IFN CSM12$
2)		POPJ	P,0		;RETURN FROM SENDHD
**************
1)127		PUSHJ	P,XTCTTY##	;CHECK ON DA-28 LINE
****
2)129	;Return through TPOPJ1 to NOT send to this line
2)	;[CSM] Do not send to CARD-PUNCH or PLOTTER-CONTROLLER
2)		CAIL	T1,124		;TTY124,125,126,127,130?
2)		CAILE	T1,130		;[CSM] *HACK*   CSMEDT
2)		 SKIPA			;OK
2)		  JRST	TPOPJ1##	;Do not send to them
2)		PUSHJ	P,XTCTTY##	;CHECK ON DA-28 LINE
**************
1)128	VERCOM::
1)	VERBTH::MOVE	T2,JBTNAM##(J)	;GET LOW NAME
1)		PUSHJ	P,PRNAME##	;PRINT IT
1)		PUSHJ	P,PRSPC		;AND SPACE
1)		MOVE	T1,.JDAT+.JBVER##	;GET LOW VERSION
1)		PUSHJ	P,PRVERS	;PRINT IT
1)	VERHGH::PUSHJ	P,SAVE2##
****
2)130	VERCOM:: CSMEDT	18,1	;VERSIO command, part 1 at VERCOM::
2)	IFN CSM18$,<	;Check for arguments, act per usual if none
2)		PUSHJ	P,SKIPS1	;Anything other than tabs, spaces, comments?
2)		  JRST	VERBTH		;No, type version number of current core image
2)		POP	P,(P)		;Yes, cancel PUSHJ P,(M)
2)		MOVE	T2,VERTXT##	;Set to SIXBIT/VERSIO/
2)	;Call-by-name for SYS:, T2 has program name
2)	CBNAME:	MOVE	P2,T2		;Name of program to run
2)		MOVEI	P3,DISP##	;Make sure P3 and
2)		MOVEI	P4,COMTAB##	; P4 are set up
2)		MOVEI	T1,.RNTXT##	;Prepare for SUBI T1,(P4) at COM1D
2)		MOVE	M,DISP##-COMTAB##(T1)	;Set flags for .RUN command
2)		JRST	COM1D		;P2 is already set up
2)	>  ;End of CSM18$
2)	VERBTH::MOVE	T2,JBTNAM##(J)	;GET LOW NAME
2)		PUSHJ	P,PRNAME##	;PRINT IT
2)		PUSHJ	P,PRSPC		;AND SPACE
2)		MOVE	T1,.JDAT+.JBVER##	;GET LOW VERSION
2)		PUSHJ	P,PRVERS	;PRINT IT
2)	IFN CSM18$,<	;.JBCST=136 has the customer version
2)		SKIPE	T1,.JDAT+.JBCST## ;See if customer version is non-zero
2)		 JRST	VERHGH
2)		PUSHJ	P,INLMES	;Type the separator
2)		ASCIZ	/;/
2)		MOVE	T1,.JDAT+.JBCST##  ;Get the customer version
2)		PUSHJ	P,PRVERS	;Print it
2)	>  ;End of IFN CSM18$
2)	VERHGH::PUSHJ	P,SAVE2##
**************
File 1)	DSKU:COMCON.MAC[702,10]	created: 1148 04-Jan-84
File 2)	DSKU:COMCON.CSM[702,10]	created: 0033 17-Dec-84

1)153	NOCOM::
1)	COMERR::PUSH	P,T2
1)		PUSHJ	P,CTIGBP##	;GET THE INPUT BYTE POINTER
1)		PUSH	P,T1		;SAVE ERROR POSITION ON THE STACK
1)		PUSHJ	P,TRESCN##	;BACK UP TO START OF COMMAND
1)		PUSHJ	P,PRQM		;TYPE ? FOR BATCH
1)	COMERL:	PUSHJ	P,COMTYI##	;GET A CHAR FROM COMMAND
****
2)155		CSMEDT	10,4		;Ambiguous commands, part 4 before COMERR
2)	IFN CSM10$,<
2)		JRST	COMERR		;COMERA and COMERP skip this
2)	;Here to type more informative messages, such as:
2)	;  ?Unknown command "SET FOOBAR"
2)	;  ?Ambiguous command "A"
2)	;  ?Improper command "SET TIME X"
2)	NOCOM::	SKIPA	P1,[[ASCIZ /Unknown command "/]]
2)	AMBCOM::MOVEI	P1,[ASCIZ /Ambiguous command "/]
2)		SKIPA
2)	COMERR::MOVEI	P1,[ASCIZ /Improper command "/]
2)		PUSH	P,T2
2)		PUSHJ	P,CTIGBP##	;Get the input byte pointer
2)		PUSH	P,T1		;Save error position on the stack
2)		PUSHJ	P,TRESCN##	;Back up to start of command
2)		PUSHJ	P,PRQM		;Type ? for BATCH
2)		MOVE	T1,P1		;Get pointer to ILLEGAL or AMBIGUOUS
2)		PUSHJ	P,CONMES	;Type it
2)	>  ;End of IFN CSM10$
2)	IFE CSM10$,<
2)	NOCOM::
2)	AMBCOM::
2)	COMERR::PUSH	P,T2
2)		PUSHJ	P,CTIGBP##	;GET THE INPUT BYTE POINTER
2)		PUSH	P,T1		;SAVE ERROR POSITION ON THE STACK
2)		PUSHJ	P,TRESCN##	;BACK UP TO START OF COMMAND
2)		PUSHJ	P,PRQM		;TYPE ? FOR BATCH
2)	>  ;End of IFE CSM10$
2)	COMERL:	PUSHJ	P,COMTYI##	;GET A CHAR FROM COMMAND
**************
1)153		PUSHJ	P,PRQM		;APPEND ? TO ERRONEOUS WORD
1)		TLO	M,ERRFLG##	;SET ERROR FLAG
1)		PJRST	CRLF		;ADD CRLF
1)	;ROUTINE TO PRINT ?DEVICE NAME
****
2)155	IFE CSM10$,<
2)		PUSHJ	P,PRQM		;APPEND ? TO ERRONEOUS WORD
2)		TLO	M,ERRFLG##	;SET ERROR FLAG
2)		PJRST	CRLF		;ADD CRLF
2)	>  ;End of IFE CSM10$
2)	IFN CSM10$,<
2)		TLO	M,ERRFLG##	;Set error flag
2)		PUSHJ	P,INLMES	;Type the closing quote
2)		ASCIZ	/"/
2)		PJRST	CRLF		;And finish it off
2)	>  ;End of IFN CSM10$
2)	;ROUTINE TO PRINT ?DEVICE NAME
**************
File 1)	DSKU:COMCON.MAC[702,10]	created: 1148 04-Jan-84
File 2)	DSKU:COMCON.CSM[702,10]	created: 0033 17-Dec-84

1)160		POPJ	P,CPOPJ1##	;NO GOOD. GIVE "BAD CHARACTER RETURN"
1)161	; ROUTINE TO INPUT TIME SINCE MIDNIGHT
****
2)162		POPJ	P,		;NO GOOD. GIVE "BAD CHARACTER RETURN"
2)163	; ROUTINE TO INPUT TIME SINCE MIDNIGHT
**************
1)164	PRNOW:	MOVE	T1,TIME##	;GET CURRENT TIME OF DAY
1)	PRTIM::	CAMGE	T1,TICMIN##	;IF LESS THAN A MINUTE
****
2)166	IFE CSM11$,<	;This routine types midnight as "0.00", instead of "00:00:00"
2)	PRNOW:	MOVE	T1,TIME##	;GET CURRENT TIME OF DAY
2)	>  ;End of IFE CSM11$
2)	PRTIM::	CAMGE	T1,TICMIN##	;IF LESS THAN A MINUTE
**************
1)168	;T2 AND P ACS ARE PRESERVED
1)	;NON-SKIP IF UNKNOWN (T1=0) OR DUPLICATE (T1.NE.0)
1)	;
****
2)170	;T2 AND P1-P4 are preserved
2)	;For non-skip return, T1=-1 for unknown, T1=-2 for ambiguous    [CSMEDT 10,5]
2)	;
**************
1)168	FNDAB6:	SOJN	P1,CPOPJ##	;MAKE SURE WE ONLY GOT A SINGLE COMMAND.
1)		TLNN	P3,1		;WAS THIS FROM A PREVIOUS TABLE SEARCH?
1)		 SUBI	P3,(R)		;NO, CONVERT IT TO AN OFFSET NOW.
1)		MOVE	T1,P3		;LEAVE WHERE CALLERS CAN FIND IT
1)		JRST	CPOPJ1##	;AND RETURN SUCCESS
1)	;WIN BY VIRTUE OF UNIQNESS BITS. SEARCH NO MORE.
1)	FNDAWN:	SUBI	P4,(R)		;COMPUTE INDEX TO RETURN
****
2)170	FNDAB6:	CSMEDT	10,5	;Ambiguous commands, part 5 at FNDAB6:
2)	;At this point, P1=0 for unknown, P1=1 for single, P1=2 for ambiguous
2)	IFN CSM10$,<	;Make a distinction between unknown and ambiguous
2)		MOVNI	T1,1		;Set T1 to -1, assume unknown
2)		CAILE	P1,1		;If more than one possible match,
2)		 MOVNI	T1,2		; set T1 to -2 for ambiguous
2)	>  ;End of IFN CSM10$
2)		SOJN	P1,CPOPJ##	;MAKE SURE WE ONLY GOT A SINGLE COMMAND.
2)		TLNN	P3,1		;WAS THIS FROM A PREVIOUS TABLE SEARCH?
2)		 SUBI	P3,(R)		;NO, CONVERT IT TO AN OFFSET NOW.
2)		MOVE	T1,P3		;LEAVE WHERE CALLERS CAN FIND IT
2)		JRST	CPOPJ1##	;AND RETURN SUCCESS
2)	;WIN BY VIRTUE OF UNIQNESS BITS. SEARCH NO MORE.
2)	;Skip return with index (from 0 to n) in RH of T1, LH of T1 has a flag bit
2)	FNDAWN:	SUBI	P4,(R)		;COMPUTE INDEX TO RETURN
**************
1)182	SAVEXE:	SKIPN	T1,.JDAT+SGALOW	;GET USER EXTENSION, IF ANY
1)		MOVSI	T1,'EXE'	;SET UP EXTENSION OF "EXE"
****
2)184		CSMEDT	18,2		;VERSIO command, part 2 at SAVEXE:
2)	IFE CSM18$,<	;Allow arbitrary extensions for .EXE files
2)	SAVEXE:	SKIPN	T1,.JDAT+SGALOW	;GET USER EXTENSION, IF ANY
2)	>  ;End of IFE CSM18$
2)	IFN CSM18$,<SAVEXE:>	;Allow only .EXE for .EXE files
2)		MOVSI	T1,'EXE'	;SET UP EXTENSION OF "EXE"
**************
File 1)	DSKU:COMCON.MAC[702,10]	created: 1148 04-Jan-84
File 2)	DSKU:COMCON.CSM[702,10]	created: 0033 17-Dec-84

1)238		PUSHJ	P,PRNAME##
1)		JSP	T1,PHOLD##	;START TTY AND STOP JOB
1)		ASCIZ	/ not found/
1)	LOOKFL:	PJSP	T1,LKENFL	;LOOKUP ERROR - PRINT MESSAGE
1)		ASCIZ	/Lookup error /
****
2)240		CSMEDT	18,3		;VERSIO command, part 3 at NOFILE:+7
2)	IFN CSM18$,<	;Type "?XXXXXX.EXE not found"
2)		CAMN	T2,[SIXBIT/SAV/];The LOOKUP was done on SAV as a last resort
2)		 MOVSI	T2,'EXE'	;Tell user we were expecting an EXE file
2)	>  ;End of IFN CSM18$
2)		PUSHJ	P,PRNAME##
2)		JSP	T1,PHOLD##	;START TTY AND STOP JOB
2)		ASCIZ	/ not found/
2)	LOOKFL:	CAIE	T1,2		;[CSM] Protection failure?
2)		 JRST	LOKFL1		;[CSM] No
2)		MOVE	T2,.JDAT+SGANAM	;[CSM] Yes, get file name
2)		PUSHJ	P,PRNAME##	;[CSM] Output it
2)		JSP	T1,PHOLD##	;[CSM] Output message and stop job
2)		ASCIZ	/.EXE is protected and cannot be accessed/
2)	LOKFL1:				;[CSM]
2)		PJSP	T1,LKENFL	;LOOKUP ERROR - PRINT MESSAGE
2)		ASCIZ	/Lookup error /
**************
    w K?
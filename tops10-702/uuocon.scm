File 1)	DSKU:UUOCON.MAC[702,10]	created: 1035 04-Jan-84
File 2)	DSKU:UUOCON.CSM[702,10]	created: 2037 16-Dec-84

1)1	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
****
2)1		CSMEDT	04	;Initialize CSM edit 04 - Imatation network
2)		CSMEDT	17	;Initialize CSM edit 17 - SET COMMAND SYS
2)		CSMEDT	30	;Initialize CSM edit 30 - Define CALLI -2, -3, and -4
2)	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
**************
1)12	X	LIGHTS,LIGHTS,UU.CP1            ;(-1) SET LIGHTS (EXAMPLE
****
2)12		CSMEDT	30,1			;UUO changes, parts 1 thru 5
2)	IFN CSM30$,<
2)	X	STSPL.,STSPL.,UU.CP1		;(-4) Get the status of the plotter
2)	X	USRLG.,USRLG.,UU.CP1		;(-3) Skip if specified PPN is logged in
2)	X	USRNM.,USRNM.,UU.CP1		;(-2) Change the user's name
2)	>  ;End of IFN CSM30$
2)	X	LIGHTS,LIGHTS,UU.CP1            ;(-1) SET LIGHTS (EXAMPLE
**************
1)78		SUBTTL	GETPPN AND DEVPPN UUO'S (ALSO RTZER)
****
2)78		SUBTTL	CSM UUOs, USRNM., USRLG., STSPL.
2)		CSMEDT	30,6			;CSM UUOs, part 6
2)	IFN CSM30$,<
2)	; STSPL. - Return the status of the plotter PLT0: (for on-line testing)
2)	; Call:
2)	;	STSPL.	AC,			;or CALLI AC,-4
2)	;	always return			;Does a CONI PLT,AC
2)	;
2)	; USRLG. - Skip if the specified PPN is logged in
2)	; Call:
2)	;	MOVE	AC,[PPN-to-look-for]
2)	;	USRLG.	AC,			;or CALLI AC,-3
2)	;	  error return			;PPN in AC is not logged in
2)	;	normal return			;PPN in AC is logged in
2)	;
2)	; USRNM. - Change the user's name, for PRINT, SYSTAT, PJOB, etc
2)	; Call:
2)	;	MOVEI	AC,[SIXBIT /New name, 12 chars/]
2)	;	USRNM.	AC,			;or CALLI AC,-2
2)	;	  error return			;Not implemented
2)	;	normal return			;PDB has been changed
2)	STSPL.::SKIPE	T1,[M0PLT##]		;Return 0 if on the 2020
2)		 CONI	PLT,T1			;Return status of plotter on 1091
2)		JRST	STOTAC##		;New UUO needed if we get 2nd plotter
2)	; USRLG. is at GETPPL+1
2)	USRNM.::MOVE	T2,JBTPPN(J)		;Get job's PPN
2)		TRNE	T2,700000		;Student PPN? (100000 to 377777)
2)		 POPJ	P,			;Yes, cannot change name
2)		MOVEI	M,(T1)			;Get addr of args
2)		PUSHJ	P,GETWDU##		;Get first half of new name
2)		MOVEM	T1,.PDNM1##(W)		;Store in the PDB
2)		PUSHJ	P,GETWD1##		;Get next word
2)		MOVEM	T1,.PDNM2##(W)		;Store for .GTNM1 and .GTNM2 GETTABs
2)		JRST	CPOPJ1			;OK return
2)	>  ;End of IFN CSM30$
2)79		SUBTTL	GETPPN AND DEVPPN UUO'S (ALSO RTZER)
**************
File 1)	DSKU:UUOCON.MAC[702,10]	created: 1035 04-Jan-84
File 2)	DSKU:UUOCON.CSM[702,10]	created: 2037 16-Dec-84

1)83		MOVEI	T1,LDRREM##	;GET THE REMOT E BIT
****
2)84		CSMEDT	04,3	;Imitation network, part 3 (near GTNTN:)
2)	IFE CSM04$&FTKL10,<	;Normal DEC stuff
2)		MOVEI	T1,LDRREM##	;GET THE REMOTE BIT
**************
1)83		HRLI	T1,(T2)		;INSERT THE NODE NUMBER
****
2)84	>  ;End of IFE CSM04$&FTKL10
2)	IFN CSM04$&FTKL10,<	;DCA "network"
2)		MOVEI	T1,LSRMS8##	;Check if the PDP-8
2)		TDNN	T1,LDBSMT##(U)	; can assign this line
2)		 JRST	GTNTN1		;No, line is hardwired to the 1091
2)		LDB	T2,LSPDEV##	;Get the device number (Which remote)
2)		ADDI	T2,100		;Make greater than 77
2)		LDB	T1,LSPUNI##	;Get unit (line on the remote)
2)	>  ;End of IFN CSM04$&FTKL10
2)		HRLI	T1,(T2)		;INSERT THE NODE NUMBER
**************
1)89	GETPPL:	MOVE	T1,JBTPPN##(J)	; AND GET OLD NUMBERS.
1)		MOVE	T2,HIGHJB##	;CHECK FOR OTHER USERS UNDER SAME PP NUMBER.
****
2)90		CSMEDT	30,7	;CSM UUOs, part 7 at GETPPL:
2)	GETPPL:	MOVE	T1,JBTPPN##(J)	; AND GET OLD NUMBERS.
2)	IFN CSM30$,< USRLG.:: >		;Skip if specified PPN is logged in
2)		MOVE	T2,HIGHJB##	;CHECK FOR OTHER USERS UNDER SAME PP NUMBER.
**************
1)94		MOVSI	T2,JACCT	;RESET THIS BIT TO INDICATE LOG-IN IS
****
2)95		CSMEDT	17,5		;SET COMMAND SYS, part 5 at LOGIN1:+12
2)	IFN CSM17$,<	;Make the LOGIN UUO set this always (instead of LOGIN.EXE)
2)		MOVEI	T1,3		;Size of pathological run block
2)		MOVEM	T1,.PDCMD##-1(W); (for PLNTXT)
2)		MOVSI	T1,'SYS'	;Device to run program from
2)		MOVEM	T1,.PDCMD##(W)
2)		SETZM	.PDCMD##+1(W)	;Gets filled in at COMNLG + a few
2)	>  ;End of IFN CSM17$
2)		MOVSI	T2,JACCT	;RESET THIS BIT TO INDICATE LOG-IN IS
**************
1)103	RNGTBL==.-RNGTAB
****
2)104		  CSMEDT	04,4	;Imitation network, part 4 (in RNGTAB:)
2)		RANGE	CSM04$,SMTMIN##,SMTMAX##,SMT	;Table of DCA names in SMTLIN
2)	RNGTBL==.-RNGTAB
**************
1)104	NUMTAB::GT	1,S,JBTSTS##		;(000) JOB STATUS TABLE
****
2)105		GT	CSM04$,R,SMTTBL##,,SMTOFS ;(-01) DCA node names and data
2)	NUMTAB::GT	1,S,JBTSTS##		;(000) JOB STATUS TABLE
**************
    
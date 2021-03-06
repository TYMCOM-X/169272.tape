File 1)	DSK:DDT.DEC	created: 1515 03-JAN-84
File 2)	DSK:DDT.MAC	created: 1831 25-APR-85

1)1	CSTVER==0	;CUSTOMER VERSION (WHO LAST . . .)
1)	EDTVER==362	;EDIT LEVEL
****
2)1	if2 <printx [Assembling DDT version 42A(362)-2]>
2)	CSTVER==2	;CUSTOMER VERSION (WHO LAST . . .) ;[JMS]
2)	EDTVER==362	;EDIT LEVEL
**************
1)13	SUBTTL	DDT ASSEMBLY SWITCHES
****
2)12	;42A(362)-2	Mar-85, patch by [JMS]
2)	;Symptom: FILOP. failure (6,14260) for input file.
2)	;Cure:  Use LOOKUP/USETI if FILOP. fails (ancient TOPS-10).
2)	;
2)	;		25-Apr-85 patch by [JMS]
2)	;Symptom: Cannot access JOBDAT in two segment program on KA-10.
2) 	;Cure:  Test for end-of-HISEG at CHKADR+37 is backwards.
2)	;	Change CAIL TT,(R) to CAMLE R,TT.
2)	;Note:	Removed possible recursion when CHKADR calls GETHSO which
2)	;	calls FETCH, which calls CHKADR again.  There is no need to call
2)	;	FETCH to access .JBHRL or any other TOPS-10 JOBDAT location.
2)	;
2)	;[End of Revision History]
2)13	SUBTTL	DDT ASSEMBLY SWITCHES
**************
1)13	IFNDEF	FTDEC20,<FTDEC20==0>
****
2)13	IFNDEF	FTTYM,<FTTYM==FTDEC10>	;[JMS] Code to read TYMCOM-X HOME blocks
2)	IFNDEF	FTDEC20,<FTDEC20==0>
**************
1)32		MOVEI	T,FIL		;INPUT FILE CHANNEL
****
2)32	FDIDF7:					;[JMS] Added label
2)		MOVEI	T,FIL		;INPUT FILE CHANNEL
**************
1)32	;HERE ON FILOP. ERROR
1)	FDIDF9:	SKIPE	PHYSIO		;/U?
1)		 PUSHJ	P,[CAIE	T,ERILU%	;"ILLEGAL UUO" ?
****
2)32	;[JMS] FILOP. not implemented on old TOPS-10 or current PA1050
2)	;HERE ON FILOP. ERROR
2)	FDIDF9:	CAMN	T,[FLPLEN,,FLPBLK]	;[JMS] Is the AC unchanged?
2)		 JRST	FDIDFZ			;[JMS] Yes, UUO not implemented
2)		SKIPE	PHYSIO			;/U?
2)		 PUSHJ	P,[CAIE	T,ERILU%	;"ILLEGAL UUO" ?
**************
1)32		MOVEI	ODF,10		;[315] SETUP TO TYPE OCTAL FILOP. ERROR CODE
1)		JRST	FDEFFF		;REAL FILOP. ERROR
1)33	;STILL FTFILE & FTDEC10
****
2)32	FDIDF8:	MOVEI	ODF,10		;[315] SETUP TO TYPE OCTAL FILOP. ERROR CODE
2)		JRST	FDEFFF		;REAL FILOP. ERROR
2)	;[JMS] Here when the FILOP. uuo is not implemented.
2)	FDIDFZ:	MOVEI	T,ERDNA%		;[JMS] Assume Device Not Available
2)		OPEN	FIL,FLPBLK+.FOIOS	;[JMS] INIT DSK:
File 1)	DSK:DDT.DEC	created: 1515 03-JAN-84
File 2)	DSK:DDT.MAC	created: 1831 25-APR-85

2)		  JRST	FDIDF8			;[JMS] Output error message
2)		SKIPE	PHYSIO			;[JMS] Done if super I/O
2)		 JRST	FDIOPN			;[JMS]
2)		MOVE	T,LKPBLK+.RBPPN		;[JMS] Save path pointer
2)		SKIPN	PTHBLK+.PTPPN+1		;[JMS] Any SFDs specified?
2)		 MOVE	T,PTHBLK+.PTPPN		;[JMS] No, use PPN directly
2)		MOVEM	T,LKPBLK+.RBPPN		;[JMS]  instead of pointer to PPN
2)		LOOKUP	FIL,LKPBLK		;[JMS] Find file for reading
2)		  JRST	[HRRZ	T,LKPBLK+.RBEXT	  ;[JMS] Get error code
2)			JRST	FDIDF8	]	  ;[JMS] Output error message
2)		SKIPN	PATCHS			;[JMS] Patching?
2)		 JRST	FDIDF7			;[JMS] No, done
2)		MOVEM	T,LKPBLK+.RBPPN		;[JMS] Restore PPN/path pointer
2)		ENTER	FIL,LKPBLK		;[JMS] Single-access update
2)		  JRST	[HRRZ	T,LKPBLK+.RBEXT	  ;[JMS] Get error code
2)			 JRST	FDIDF8	]	  ;[JMS] Output error message
2)		JRST	FDIDF7			;[JMS] Get file size
2)33	;STILL FTFILE & FTDEC10
**************
1)52	FDIPH6:	LSH	TT2,BL2WRD	;MAKE WORD COUNT
1)		MOVEM	TT2,MAXSIZ	;SET MAX SIZE ADDRESSABLE
****
2)52	;[JMS] The disks for TYMCOM-X are addressed in pages, not blocks
2)	FDIPH6:	LSH	TT2,BL2WRD	;MAKE WORD COUNT
2)	IFN FTTYM,< LSH	TT2,PG2WRD-BL2WRD ;[JMS] Convert pages to words  >
2)		MOVEM	TT2,MAXSIZ	;SET MAX SIZE ADDRESSABLE
**************
1)159		 JRST	[EXCH	R,.JBFF	;RESET .JBFF
1)			 JRST	FSEFFF]	;TYPE FILOP. ERROR
1)		EXCH	R,.JBFF		;RESTORE .JBFF
****
2)159		 JRST	[CAMN	T,[YFLLEN,,YFLBLK]	;[JMS] Unimplemented?
2)			  JSP	T,[OPEN	CM,YFLBLK+.FOIOS ;[JMS] Yes
2)				     JRST (T)		;[JMS] OPEN error
2)				   LOOKUP CM,YBFBUF	;[JMS] 
2)				     JRST (T)		;[JMS] LOOKUP error
2)				   JRST	TAPINZ]		;[JMS] Success
2)			 EXCH	R,.JBFF	;RESET .JBFF
2)			 JRST	FSEFFF]	;TYPE FILOP. ERROR
2)	TAPINZ:						;[JMS]
2)		EXCH	R,.JBFF		;RESTORE .JBFF
**************
1)160	;HERE TO HANDLE SYMBOL FILES
1)	TAPSY:	JRST	ERR		;CODE NOT YET WRITTEN . . .
****
2)159	;[JMS] Don't waste a page - deleted formfeed here
2)	  ;HERE TO HANDLE SYMBOL FILES
2)	TAPSY:	JRST	ERR		;CODE NOT YET WRITTEN . . .
**************
1)260		 JRST	FILIOE		;FAILED
1)		JRST	FILIO6		;GO DO I/O
****
2)259		 JRST	FILIOZ		;[JMS] FILOP.USETI failed
2)		JRST	FILIO6		;GO DO I/O
File 1)	DSK:DDT.DEC	created: 1515 03-JAN-84
File 2)	DSK:DDT.MAC	created: 1831 25-APR-85

**************
1)260		 JRST	FILIOE		;FAILED
1)		JRST	FILIO6		;GO DO I/O
1)261	;STILL IN FTFILE & FTDEC10
****
2)259		 JRST	FILIOY		;[JMS] FILOP.USETO failed
2)		JRST	FILIO6		;GO DO I/O
2)	;[JMS] Try old style USETI when FILOP. fails
2)	FILIOZ:	CAME	TT,[2,,TT1]	;[JMS] AC unchanged?
2)		 JRST	FILIOE		;[JMS] No, real error
2)		USETI	FIL,(TT2)	;[JMS] USETI instead of FILOP.
2)		JRST	FILIO6		;[JMS] Go do I/O
2)	;[JMS] Try old style USETO when FILOP. fails
2)	FILIOY:	CAME	TT,[2,,TT1]	;[JMS] AC unchanged?
2)		 JRST	FILIOE		;[JMS] No, real error
2)		USETO	FIL,(TT2)	;[JMS] USETO instead of FILOP.
2)		JRST	FILIO6		;[JMS]
2)	;[JMS] Here when SUSET. fails
2)	FILIOW:	MOVE	TT2,TT1			;[JMS] Page number again
2)		LSH	TT2,PG2BLK		;[JMS] Block number
2)		CAIL	TT2,777770		;[JMS] Within range for USETI/USETO?
2)		 JRST	FILIOX			;[JMS] No, give up
2)		JUMPN	T,[USETO FIL,(TT2)  	;[JMS] Super-USETO if writing
2)			   JRST  FILIO6]    	;[JMS]
2)		USETI	FIL,(TT2)		;[JMS] Super-USETI if reading
2)		JRST	FILIO6
2)	;[JMS] Here when both SUSET. and USETI/USETO don't work
2)	IFE FTTYM,<
2)	FILIOX:	TMSG	< Address is out of range for USETI/USETO >
2)		JRST	FILIOS			;[JMS] Output error message
2)	>
2)	IFN FTTYM,<
2)		OPDEF	CHANIO	[043B8]		;[JMS] TYMSHARE's monitor
2)		IFNDEF	.CHFSI,<.CHFSI==27>	;[JMS] TYMCOM-X full-word USETI
2)		IFNDEF	.CHFSO,<.CHFSO==30>	;[JMS] TYMCOM-X full-word USETO
2)	FILIOX:	MOVE	TT1,[.CHFSI,,FIL]	;[JMS] Assume reading
2)		SKIPE	T			;[JMS] Writing?
2)		 MOVE	TT1,[.CHFSO,,FIL]	;[JMS] Yes
2)		CHANIO	TT1,TT2			;[JMS] Go there
2)		JRST	FILIO6			;[JMS] Continue
2)	>
2)260	;STILL IN FTFILE & FTDEC10
**************
1)261		 JRST	FILIOE		;FAILED
1)		TXZ	TT2,<<Z FIL,>!SU.SOT>  ;FALL INTO I/O
****
2)260		 JRST	FILIOW		;[JMS] SUSET. failed, at FILIO4+3
2)		TXZ	TT2,<<Z FIL,>!SU.SOT>  ;FALL INTO I/O
**************
1)277		HRRZ	TT,.JBHRL	;TOP OF HISEG
1)		CAIL	TT,(R)		;ADDRESS IN R .LE. TOP OF HISEG?
1)		JRST	CHKAD4		;NO, ADDRESS NOT IN HISEG
****
2)276	;[JMS] 25-Apr-85 - Comparison with end-of-hiseg was backwards
File 1)	DSK:DDT.DEC	created: 1515 03-JAN-84
File 2)	DSK:DDT.MAC	created: 1831 25-APR-85

2)		HRRZ	TT,.JBHRL	;TOP OF HISEG
2)	;[JMS]	CAIL	TT,(R)		;ADDRESS IN R .LE. TOP OF HISEG?
2)		CAMLE	R,TT		;[JMS] Is address in R .LE. end of hiseg?
2)		JRST	CHKAD4		;NO, ADDRESS NOT IN HISEG
**************
1)285	GETHSO:	SETZ	T,		;ASSUME NO HISEG
****
2)284	;[JMS] Avoid unnecessary recursion CHKADR-GETHSO-FETCH-CHKADR
2)	GETHSO:	SETZ	T,		;ASSUME NO HISEG
**************
1)285		PUSHJ	P,SAVR		;SAVE R TO POINT TO .JBHRL
1)		MOVEI	R,.JBHRL	;HIGH SEG ORIGIN WORD
1)		PUSHJ	P,FETCH		;GET IT
1)		  SETZ	T,		;ASSUME NO HIGH SEG
1)		TRNN	T,-1		;HIGH SEG EXIST?
****
2)284	;[JMS]	PUSHJ	P,SAVR		;SAVE R TO POINT TO .JBHRL
2)	;[JMS]	MOVEI	R,.JBHRL	;HIGH SEG ORIGIN WORD
2)	;[JMS]	PUSHJ	P,FETCH		;GET IT
2)	;[JMS]	  SETZ	T,		;ASSUME NO HIGH SEG
2)		MOVE	T,.JBHRL ;[JMS]	;Get directly from JOBDAT
2)		TRNN	T,-1		;HIGH SEG EXIST?
**************
   
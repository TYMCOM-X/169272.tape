File 1)	DSK:FORINI.DEC	created: 2046 01-May-85
File 2)	DSK:FORINI.MAC	created: 1657 20-May-85

1)1	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
****
2)1	;[JMS] Includes check for F40 chain files
2)	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
**************
1)1	.JBOPS=135
1)		SEARCH	FORPRM	;LOAD GLOBAL SYMBOL FROM FORPRM SYMBOL TABLE
****
2)1	.JBOPS=135	;LH nonzero if need to GETSEG SYS:FOROTS, zero when
2)			; FOROTS is loaded.  RH is pointer for use by FOROTS.
2)		SEARCH	FORPRM	;LOAD GLOBAL SYMBOL FROM FORPRM SYMBOL TABLE
**************
1)1		BYTE	(6)1(12)VFOROT(18)0
1)	;      FORINI checks for a current FOROTS system in  the  high
1)	;     segment  and  jumps to the FOROTS initilization code if
1)	;     it is present.  If the high segment is non-existant  or
1)	;     other  than  FOROTS,  FORINI  sets  the  left  half  of
1)	;     (.JBOPS) to the FOROTS system code and calls SELOTS  to
1)	;     load the correct verson of FOROTS.
1)	;     FORINI contains  the  (RESET.)  entry  point  which  is
****
2)1		BYTE	(6)1(12)VFOROT(18)0	;010005,,0 for FOROTS version 5
2)	;     FORINI checks for a current FOROTS system in  the  high
2)	;     segment  and  jumps to the FOROTS initilization code if
2)	;     it is present.  If the high segment is non-existant  or
2)	;     other  than  FOROTS,  FORINI  sets  the  left  half  of
2)	;     (.JBOPS) to the FOROTS system code and does a GETSEG on
2)	;     SYS:FOROTS.EXT[1,4].
2)	;     FORINI contains  the  (RESET.)  entry  point  which  is
**************
1)1		SUBTTL FORINI REDEFINE FOROTS ENTRIES FORM INTERNAL TO EXTERNAL
1)		INTERNAL	FORER.,OPEN.,CLOSE.,RELEA.,IN.,OUT.,RTB.,WTB.
1)		INTERNAL	ENC.,DEC.,NLI.,NLO.,IOLST.,MTOP.,FIN.
1)		INTERNAL	FIND.,EXIT.,ALCOR.,ALCHN.,DECOR.,DECHN.
1)		INTERNAL	TRACE.,FUNCT.,DBMS.	;[475]
1)	OPEN.=OPEN%
****
2)1	SUBTTL FORINI - Redefine FOROTS entries from internal to external
2)		INTERNAL	FORER.,OPEN.,CLOSE.,RELEA.,IN.,OUT.,RTB.,WTB.
2)		INTERNAL	ENC.,DEC.,NLI.,NLO.,IOLST.,MTOP.,FIN.
2)		INTERNAL	FIND.,EXIT.,ALCOR.,ALCHN.,DECOR.,DECHN.
2)		INTERNAL	TRACE.,FUNCT.,DBMS.
2)	OPEN.=OPEN%
**************
1)1	DBMS.=DBMS%		;[475]
1)		SALL
1)		SUBTTL FORINI - ROUTINE TO GET SELOTS
1)		RELOC	0
1)		ENTRY	RESET.
1)	RESET.:				;MAIN ENTRY FROM FORTRAN TO INITILIZE FOROTS
1)		RESET			;RESET ALL SOWTWARE CHANNELS
1)		HRRZ	AC17,.JBFF	;GET THE FIRST FREE LOC IN THE LOW SEG
1)		HRRM	AC17,.JBOPS	;SAVE AS A BASE REG FOR FOROTS
1)		MOVEI	AC17,LOW.SZ	;[311] MUST HAVE ROOM FOR LOW SEG DATA BASE
1)		ADDB	AC17,.JBFF	;UPDATE .JBFF FOR THE STATIC LOW SEG
****
File 1)	DSK:FORINI.DEC	created: 2046 01-May-85
File 2)	DSK:FORINI.MAC	created: 1657 20-May-85

2)1	DBMS.=DBMS%
2)		SALL
2)	SUBTTL FORINI - ROUTINE TO GET FOROTS
2)		RELOC	0
2)		ENTRY	RESET.
2)	  ;[JMS] Watch out for F40 chained files, at RESET.:+1
2)	RESET.:				;MAIN ENTRY FROM FORTRAN TO INITILIZE FOROTS
2)		RESET			;RESET ALL SOFTWARE CHANNELS
2)	IFN FT$TYM,<IF2,<PRINTX [Including check for nonzero JOBCHN]>
2)		HLLZ	AC17,.JBCHN##	;[JMS] Check highest LOADER/F40 CHAIN address
2)		JUMPE	AC17,RESET1	;[JMS] No CHAIN if zero
2)		HLLM	AC17,.JBSA##	;[JMS] Fix so next RESET uses right value
2)		HLRM	AC17,.JBFF	;[JMS] Set FF to after LOADER's buffers
2)	RESET1:	>  ;End of IFN FT$TYM
2)	;For edit 721, LOW.SZ=261 octal.  If FOROTS.SHR needs more, it will get more
2)		HRRZ	AC17,.JBFF	;GET THE FIRST FREE LOC IN THE LOW SEG
2)		HRRM	AC17,.JBOPS	;SAVE AS A BASE REG FOR FOROTS
2)		MOVEI	AC17,LOW.SZ	;MUST HAVE ROOM FOR LOW SEG DATA BASE
2)		ADDB	AC17,.JBFF	;UPDATE .JBFF FOR THE STATIC LOW SEG
**************
1)1		MOVEM	L,L(AC17)	;[401] SAVE AC 16
1)		MOVEI	L,(AC17)	;[401] USE IT FOR BLT
1)		BLT	L,15(AC17)	;[401] SAVE THE AC'S 0 TO 15
1)		MOVE	P4,.JBOPS	;GET THE BASE REG AND LEFT FLAGS
****
2)1		MOVEM	L,L(AC17)	;SAVE AC 16
2)		MOVEI	L,(AC17)	;USE IT FOR BLT
2)		BLT	L,15(AC17)	;SAVE THE AC'S 0 TO 15
2)		MOVE	P4,.JBOPS	;GET THE BASE REG AND LEFT FLAGS
**************
1)1		GETSEG	T1,		;GET SELOTS
1)		  HALT			;HELP, SELOTS NO AROUND
1)	;**; [662] INSERT @ RESET2-1	SWG	11-JUL-77
1)		HRRZS	.JBOPS		;[662] RESET SO NEXT TIME WON'T GETSEG
****
2)1		GETSEG	T1,		;Bypass SELOTS, get FOROTS directly
2)		  HALT	.		;HELP, SELOTS NO AROUND
2)		HRRZS	.JBOPS		;[662] RESET SO NEXT TIME WON'T GETSEG
**************
   
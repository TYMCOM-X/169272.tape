File 1)	DSK:FORDDT.DEC	created: 2029 01-May-85
File 2)	DSK:FORDDT.MAC	created: 1714 20-May-85

1)1	;COPYRIGHT (C) 1973,1977 BY
****
2)1		FT$TYM==-1	;[JMS] Don't crump on .JBREN if it is in use
2)	;COPYRIGHT (C) 1973,1977 BY
**************
1)1	;**;[100] add universal search  ma 26-aug-77
1)		search monsym
1)	EDITNO==101	;EDIT NO
****
2)1		;[JMS] Move SEARCH MONSYM to be inside TOPS20 conditional
2)	EDITNO==101	;EDIT NO
**************
1)1	LOC	.JBREN
1)	RE.ENT		;SETS THE RE - ENTER ADDRESS
1)	LOC	.JBDDT
1)	FORDDT		;MAKES DEBUG PROG,FORDDT WORK
1)	RELOC
1)		PAGE
****
2)1	IFE FT$TYM,<	;Don't overwrite JOBREN
2)	LO C	.JBREN
2)	RE.ENT		;SETS THE RE - ENTER ADDRESS
2)	>  ;End of IFE FT$TYM
2)	LOC	.JBDDT
2)	FORDDT		;MAKES DEBUG PROG,FORDDT WORK
2)	RELOC
2)	DDTBEG:!	;[JMS] DDT beginning
2)		PAGE
**************
1)1	;**;[100] add conditional  ma 25-aug-77
1)	ifndef tops20,<tops20==0>	;[100]set tops20==1 to run in native mode
1)		PAGE
****
2)1	;[JMS] Put SEARCH MONSYM under IFN TOPS20
2)	;**;[100] add conditional  ma 25-aug-77
2)	ifndef tops20,<tops20==0>	;[100]set tops20==1 to run in native mode
2)	IFN TOPS20,<printx [Building TOPS-20 version of FORDDT]
2)		search monsym>		;[100]
2)		PAGE
**************
1)1	RE.NTR:	MOVEI	T,RE.ENT	;AND SET UP THE RE-ENTER ADDRESS
1)		MOVEM	T,.JBREN	;SO THAT FUTURE RE ENTERS WILL WORK
****
2)1	RE.NTR:
2)	IFN FT$TYM,<IF2,<PRINTX [Preserving REENTER address]>
2)		HRRZ	T,.JBREN	;[JMS] Pick up current setting
2)		JUMPE	T,RE.NT1	;[JMS] Proceed if currently zero
2)		CAIL	T,DDTBEG	;[JMS] Within FORDDT?
2)		CAILE	T,DDTEND	;[JMS]
2)		 SKIPA	T,.JBREN	;[JMS] No, keep both halves the same
2)	RE.NT1:	>  ;End of IFN FT$TYM
2)		MOVEI	T,RE.ENT	;AND SET UP THE RE-ENTER ADDRESS
2)		MOVEM	T,.JBREN	;SO THAT FUTURE RE ENTERS WILL WORK
**************
    
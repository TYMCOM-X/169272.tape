File 1)	DSK:FRMSER.D03	created: 1402 26-FEB-88
File 2)	DSK:FRMSER.MAC	created: 2113 15-APR-88

1)2		AOS	CNTFRM(T1)	;Count FRMOPs by function
1)		JUMPE	T1,FRMJMP	;IF ZERO, BYPASS DISPATCH FOR SPEED.
1)		CAIL	T1,FRMOTL*2	;IN BOUNDS?
1)		JRST	FOEBFN		;BAD FUNCTION CODE
1)		ROT	T1,-1		;<EVEN/ODD>,,FN/2
****
2)2	;*;	JUMPE	T1,FRMJMP	;IF ZERO, BYPASS DISPATCH FOR SPEED.
2)		CAIL	T1,FRMOTL	;IN BOUNDS?
2)		 JRST	FOEBFN		;BAD FUNCTION CODE
2)		AOS	FRMCNT(T1)	;Count FRMOPs by function
2)		ROT	T1,-1		;<EVEN/ODD>,,FN/2
**************
1)3	X (VRM,FRMVRM)			;;(10) VREMOV FOR ANOTHER FRAME
1)	X (VCL,FRMVCL)			;;(11) VCLEAR FOR ANOTH ER FRAME
1)	X (CFH,FRMCFH)			;;(12) CREATE HANDLE
****
2)3	X (VRM,FOOVRM)			;;(10) VREMOV FOR ANOTHER FRAME
2)	X (VCL,FOOVCL)			;;(11) VCLEAR FOR ANOTHER FRAME
2)	X (CFH,FRMCFH)			;;(12) CREATE HANDLE
**************
1)3	FRMOTL==.-FRMOTB
1)	CNTFRM:	BLOCK	FRMOTL*2	; Block for counters, one per .FO???
1)	SUBTTL	SETSTV - Set start vector address (CALLI -137)
****
2)3	FRMOTL==ZZ
2)	FRMCNT::BLOCK	FRMOTL	; Block for counters, one per .FO???
2)		SYDVF (<<FRMCNT,FRMOTL>>)	;For SYSDVF
2)	SUBTTL	SETSTV - Set start vector address (CALLI -137)
**************
1)4	EXTERN	FRMREP,FRMVXX		;These are in IOCSS
1)	FRMVCL::MOVEI	P1,KCLEAR##	;Use kernel CLEAR routine
1)		JRST	FRMVXX
1)	FRMVRM::MOVEI	P1,KREMOV##	;Use kernel REMOVE routine
1)		JRST	FRMVXX
1)5	SUBTTL	.FOCSI=44 Cause software interrupt
****
2)4		EXTERN	FRMREP		;This is in IOCSS
2)	FOOVCL:	JRST	FRMVCL##	;*HACK* These 2 lines are so that LINK doesn't
2)	FOOVRM:	JRST	FRMVRM##	;*HACK* mess up with 2 externals in 1 word.
2)5	SUBTTL	.FOCSI=44 Cause software interrupt
**************
1)16	JDSVCL:	STARCL,,.JBSA		;(-2) CCL START ADDRESS
1)		.JBREN##		;(-3) REENTER ADDRESS
1)		.JBDDT##		;(-4) DDT START ADDRESS
1)	JDSVCO:	0			;(-5) CONTINUE POINT.
1)	JDSVLN:				;table length
1)		dephase
****
2)16	JDSVCL:!STARCL,,.JBSA		;(-2) CCL START ADDRESS
2)		.JBREN##		;(-3) REENTER ADDRESS
2)		.JBDDT##		;(-4) DDT START ADDRESS
2)	JDSVCO:!0			;(-5) CONTINUE POINT.
2)	JDSVLN:!			;table length
2)		dephase
File 1)	DSK:FRMSER.D03	created: 1402 26-FEB-88
File 2)	DSK:FRMSER.MAC	created: 2113 15-APR-88

**************
 
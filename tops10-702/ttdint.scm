File 1)	DSKU:TTDINT.MAC[702,10]	created: 1903 26-Sep-83
File 2)	DSKU:TTDINT.CSM[702,10]	created: 1236 09-Jul-84

1)1	;NOTE:
****
2)1		$RELOC
2)		CSMEDT	06	;Initialize CSM edit 06 - Raise/lower DTR
2)	;NOTE:
**************
1)1		$RELOC
1)		$HIGH
****
2)1		$HIGH
**************
1)10	TTDDSC:	CAIN	T3,DSTON##	;WANT TO TURN DATASET ON?
1)		POPJ	P,		;YES, ALREADY DONE BY RSX-20F
1)		CAIN	T3,DSTOFF##	;WANT TO TURN IT OFF?
****
2)10		CSMEDT	06,3	;Raise/lower DTR, part 3 before TTDDSC:
2)	IFN CSM06$,<	;Routine to raise DTR
2)		.EMDSC==15		;DataSet Connected code
2)	TTDUHU:	PUSHJ	P,SAVE4##	;Save P1-P4
2)		HRRZ	P3,DSCTAB##(U)	;Get Monitor line number
2)		PUSHJ	P,STDT1		;Set up DTEQUE arguments
2)		HRRI	P2,.EMDSC	;DataSet Connect (raise DTR)
2)		PUSHJ	P,DTEQUE##	;Queue the request
2)		  JFCL			;Failed, just ignore
2)		POPJ	P,		;Return
2)	>  ;End of IFN CSM06$
2)	TTDDSC:	CAIN	T3,DSTON##	;WANT TO TURN DATASET ON?
2)	IFE CSM06$,<POPJ  P,	  >	;YES, ALREADY DONE BY RSX-20F
2)	IFN CSM06$,<PJRST TTDUHU  >	;Yes, un-hang-up dataset
2)		CAIN	T3,DSTOFF##	;WANT TO TURN IT OFF?
**************
    
File 1)	DSKU:ONCE.MAC[702,10]	created: 0930 27-Sep-83
File 2)	DSKU:ONCE.CSM[702,10]	created: 2259 24-May-84

1)1	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
****
2)1		CSMEDT	11	;Initialize CSM edit 11 - DAYTIM & PJOB changes
2)	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
**************
1)18		MOVE	T1,DEFSP	;GET DEFAULT STRING POINTER
****
2)18		CSMEDT	11,3	;DAYTIM changes, part 3 at DATLP2:+2
2)	IFN CSM11$,<
2)		PUSHJ	P,SUDATE##	;Recompute DATE (UDT format)
2)		SETTYO			;Set up output routine
2)		PUSHJ	P,DAYTIM##	;Type the default date/time before asking
2)		PUSHJ	P,OPOUT		;Output string to CTY
2)	>  ;End of IFN CSM11$
2)		MOVE	T1,DEFSP	;GET DEFAULT STRING POINTER
**************
  
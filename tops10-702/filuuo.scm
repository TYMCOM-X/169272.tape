File 1)	DSKU:FILUUO.MAC[702,10]	created: 1015 11-Oct-83
File 2)	DSKU:FILUUO.CSM[702,10]	created: 1521 28-Jun-84

1)1	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
****
2)1	;Includes MCO [11097] - Disk quotas messed up
2)		CSMEDT	31	;Initialize CSM edit 31 - Spooled PLT changes
2)				;Put plotter file in user's directory
2)	;[CSM] Insert after SPTST6 + 5 lines (page 4-12, 1-Dec-83 Dispatch)
2)	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
**************
1)42		JRST	SPTSO3
****
2)42		CSMEDT	31,1	;Plotter UUO changes, part 1 just before SPTSO2:
2)	IFN CSM31$,<	;Allow users to preview PLT files on the TEK or GIGI terminals
2)		HLRZ	T1,DEVNAM(F)	;Get device name
2)		CAIE	T1,'PLT'	;Going to spooled plotter?
2)		 JRST	SPTSO3		;No
2)		HRLZM	T1,.JDAT+141	;Yes, change extension to .PLT
2)		SETZM	.JDAT+143	;Create it in the user's default directory
2)	>  ;End of IFN CSM31$
2)		JRST	SPTSO3
**************
1)44		CAIN	T1,AEFERR	;CAN'T - SUPERSEDE ERROR?
****
2)44	;[CSM] Insert after SPTST6 + 5 lines (page 4-12, 1-Dec-83 Dispatch)
2)		TLZ	T1,-1		;[CSM] Clear all but error code
2)		CAIN	T1,AEFERR	;CAN'T - SUPERSEDE ERROR?
**************
1)111		ADDI	T2,RIBVER##+1	;SET TO LOC OF RIBVER
****
2)111		PUSHJ	P,FIXUSD	;[11097] Fix RIBUSD
2)		ADDI	T2,RIBVER##+1	;SET TO LOC OF RIBVER
**************
1)201	IFN FTDUFC,<
****
2)200	;From the Jun-84 CMCO list [11097]
2)	;Routine to fix the value of RIBUSD in the RIB.
2)	;(Only the value in UFBTAL is known to be right)
2)	;Respects all ACs except T1
2)	FIXUSD:	HLRZ	T1,DEVEXT(F)	;RIBUSD is only meaningful for UFD
2)		CAIE	T1,'UFD'
2)		 POPJ	P,
2)		PUSHJ	P,SAVT##
2)		PUSHJ	P,FNDUFB	;Find the UFB
2)		  POPJ	P,		;Not there
2)		MOVE	T1,.USMBF	;%Get quota from RIB
2)		MOVE	T3,RIBQTF##+1(T1)
2)		SUB	T3,UFBTAL##(T2)	;%Minus amount left
2)		MOVEM	T3,RIBUSD##+1(T1);%Gives amount used
2)		PJRST	GVCBJ##		;%Give up CB
2)	;End of MCO [11097]
2)201	IFN FTDUFC,<
**************
  
File 1)	DSKU:IPCSER.MAC[702,10]	created: 1039 04-Jan-84
File 2)	DSKU:IPCSER.CSM[702,10]	created: 1530 28-Jun-84

1)1	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
****
2)1	;Includes MCO [11113] to prevent stopcodes DOM and CMU
2)		CSMEDT	31	;Initialize CSM edit 31 - Spooled PLT changes
2)	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
**************
1)17		TRNE	T2,400000	;PAGE ON DSK?
1)		JRST	IPCS12		;YES
1)		MOVE	T1,.IPCFR(P3)	;RECEIVER
****
2)17	;MCO [11113] from Jun-84 CMCO list, change at IPCS9A:+13 lines
2)		MOVE	T1,.IPCFR(P3)	;RECEIVER
**************
1)17		  JRST	IPCS11		;SHOULD NEVER HAPPEN
1)		SKIPGE	T1,JBTSTS##(J)	;JOB RUNNING?
****
2)17		  JRST	IPS11A		;[11113] SHOULD NEVER HAPPEN
2)		TRNE	T2,400000	;[11113] PAGE ON DSK?
2)		JRST	IPCS12		;[11113] YES
2)		SKIPGE	T1,JBTSTS##(J)	;JOB RUNNING?
**************
1)18	IFN FTMP,<
****
2)18	IPS11A:				;[11113]
2)	IFN FTMP,<
**************
1)38		PUSH	P,J		;SAVE J
****
2)38		CSMEDT	31,2	;Plotter UUO changes, part 2 at QSRSPL::+1
2)	IFN CSM31$,<	;Do not notify QUASAR when spooled PLT file is closed.
2)		MOVE	T1,DEVPPN(F)	;Get directory
2)		CAME	T1,SPLPPN##	;Is it in SPL:[3,3]
2)		 POPJ	P,		;No, in user's directory, punt
2)	>  ;End of IFN CSM31$
2)		PUSH	P,J		;SAVE J
**************
  
File 1)	DSKU:FILIO.DEC[702,10]	created: 1103 04-Jan-84
File 2)	DSKU:FILIO.MAC[702,10]	created: 1511 28-Jun-84

1)1	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
****
2)1	;Includes MCO [11096] to prevent IME during FILOP. function .FORRC
2)	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
**************
1)81		MOVE	U,DEVUNI##(F)	; NOT SET IF FILOP
1)		PUSHJ	P,WAIT1##
****
2)81	;[11096]MOVE	U,DEVUNI##(F)	; NOT SET IF FILOP
2)		PUSHJ	P,SETU		;[11096] Not set if FILOP
2)		  POPJ	P,		;[11096]
2)		PUSHJ	P,WAIT1##
**************
  
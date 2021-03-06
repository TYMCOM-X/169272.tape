File 1)	DSKU:NETSER.MAC[702,10]	created: 0941 17-Jan-84
File 2)	DSKU:NETSER.CSM[702,10]	created: 2259 24-May-84

1)1	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
****
2)1		CSMEDT	04	;Initialize CSM edit 04 - Imitation newtork
2)	;THIS SOFTWARE IS FURNISHED UNDER A LICENSE AND MAY ONLY BE USED
**************
1)9	NODE.2:				;ENTRY
****
2)9		CSMEDT	04,5	;Imatation network, part 5 (at NODE.2:)
2)	NODE.2:				;ENTRY
**************
1)9		  PJRST	ND%INN		;ILLEGAL NODE
1)		MOVE	T2,T1		;COPY ARGUMENT
****
2)9	IFE CSM04$,< PJRST ND%INN >	;ILLEGAL NODE
2)	IFN CSM04$,< PJRST CHKDCA >	;Check the DCA "nodes"
2)		MOVE	T2,T1		;COPY ARGUMENT
**************
1)9	;SUBROUTINE TO FIND NDB FOR NODE.UUO FUNCTIONS
****
2)9	IFN CSM04$,<	;Here to try checking the DCA "nodes", 100 through 115
2)	CHKDCA:	TLNE	T1,-1		;Is it really a number?
2)		 JRST	CHKDCN		;No, try for name
2)		HRRZ	T3,SMTTBL##	;Get number of DCA nodes
2)		CAMLE	T1,T3		;Greater than max?
2)		 JRST	ND%INN		;Yes, illegal node number
2)		MOVE	T1,SMTTBL##(T1)	;Ok, get name of remote
2)		PJRST	STOTC1##	;Return data
2)	;Check if SIXBIT name in T1 matches anything on the table
2)	CHKDCN:	HRRZ	T2,SMTTBL##	;Get the max number of DCA remotes
2)	CHKDC1:	CAMN	T1,SMTTBL##(T2)	;Match?
2)		 JRST	[MOVE	T1,T2	   ;Yes, get the number (which is .GE. 100)
2)			 JRST	STOTC1## ] ;Return node number
2)		CAIN	T2,100		;No match, down to node 100?
2)		 MOVEI	T2,6+1		;Yes, skip down to test node 6 next
2)		SOJGE	T2,CHKDC1	;Keep trying
2)		PUSHJ	P,CVTOCT##	;No match, try converting SIXBIT number to octal
2)		  PJRST	ND%INN		;Illegal node number
2)		JRST	CHKDCA		;Try matching number
2)	>  ;End of IFN CSM04$
2)	;SUBROUTINE TO FIND NDB FOR NODE.UUO FUNCTIONS
**************
  
::	The following patch fixes a problem with PVC startup.
::	If a reset occurs in the low numbered DCE immediately
::	after the PVC confirmation IIX message has been sent,
::	the gobbler sent to the high numbered DCE will cause
::	an RR to be queued up.  This may occur before the PVC 
::	setup has finished, and causes a F5 crash at RMXPVC.

PATCH(860203,1800,DRE,ICBKG-8,,6)
	J	PA1PTR,,
CONPATCH(PA1PTR,,10)
	RBT	R1,DFLUSH
	LHL	R4,IPORT
	LB	R0,PCKSTE,R4,
	CLHI	R0,PSRESC		:IS THIS IN A GOOD STATE FOR A RR
	JG	MMFRA,,			:NO, SKIP CALL TO CWROT
	J	CWROT,,
ENDPATCH(Fix F5 crash at RMXPVC due to gobbler in wrong state)
    
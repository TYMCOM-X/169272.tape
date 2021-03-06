PATCH(850924,1600,DRE,GENRPT,,6)
	J	PA1PTR,,
CONPATCH(PA1PTR,,12)
	LHL	R1,DPORT
	TBT	R1,DPLOGN	:Has the dispatcher port gotten out of login?
	JNR	R9		:return if not
	LIS	R0,ADA.L
	J	GENRPT+6,,
ENDPATCH(disable accounting reports if still logging in)

  IF	PVC
PATCH(850924,1600,DRE,SNDR20+1C,,6)
	J	PA1PTR,,
CONPATCH(PA1PTR,,14)
	TBT	R2,DPLOGN	:Has the dispatcher port gotten out of login?
	JNR	R8		:return if not
	SBT	R2,DFLUSH
	LHL	R1,DPORT
	J	SNDR20+24,,
  ELSE
PATCH(850924,1600,DRE,SNDR20+12,,6)
	J	PA1PTR,,
CONPATCH(PA1PTR,,14)
	TBT	R2,DPLOGN	:Has the dispatcher port gotten out of login?
	JNR	R8		:return if not
	SBT	R2,DFLUSH
	LHL	R1,DPORT
	J	SNDR20+1A,,
  EI
ENDPATCH(don't send gobbler if still logging in)

PATCH(850924,1600,DRE,SNDC10,,6)
	J	PA1PTR,,
CONPATCH(PA1PTR,,1A)
	TBT	R1,DPLOGN	:Has the dispatcher port gotten out of login?
	JN	SNDC30,,	:No, then don't send garbage to the sup
	TBT	R1,TURKEY	:Do this test which may not be right
	JE	SNDC20,,	:Send text message
	J	SNDC10+08,,	:Send X.25 clear message
ENDPATCH(don't send turkey messages if still logging in)

  IF	X.75
PATCH(850924,1600,DRE,TRI020+2E,,0A)
	LHI	R0,CNETCG^8!DIA115
	STH	R0,PSDIAG,RL,RL		:STORE FOR HANGAL
  ELSE  X.25
PATCH(850924,1600,DRE,TRI020+2E,,6)
	J	PA1PTR,,
CONPATCH(PA0PTR,,4)
PCAU.F	WC	0			:SET NO PERMISSION FOR NON-ZERO CAUSE CODES
CONPATCH(PA1PTR,,28)
	LB	R0,PCTL2		:GET SAVED CAUSE CODE
	STB	R0,PSDIAG,RL,RL		:PUT IN PROPER PLACE
	JEFS	TRI025			:ZERO IS ALWAYS OK
	THI	R0,80			:IS BIT 8 ON?
	JNFS	TRI025			:ANYTHING WITH THE BIT ON IS OK
	TBT	RL,PCAU.F		:DO WE ALLOW NETWORK CAUSE CODES THROUGH?
	JNFS	TRI025			:YES, LET IT GO THROUGH
	LHI	R0,CLOCPE^8!$A081	:SET ERROR TO INPROPER CAUSE CODE
	STH	R0,PSDIAG,RL,RL		:STORE FOR HANGAL
TRI025	J	TRI020+38,,
  EI	X.25
ENDPATCH(Send proper cause code and diag in clears after a restart)
 
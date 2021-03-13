::	The following patch fixes a problem with private networks.
::	The called address gets converted to DNIC + NTN if it only
::	contains the NTN.  This does not seem compatable with the
::	requirements of a private which contains no DNIC.
PATCH(850520,1000,DRE,PCR460+2C,,6)
	J	PA1PTR,,
CONPATCH(PA1PTR,,2E)
	NHI	R0,0F0		:EXTRACT FIRST DIGIT
	JE	PCR466,,	:0 STARTS ADDRESS
	CLHI	R0,090		:DOES IT START WITH A 9?
	JN	PCR460+34,,	:DNIC STARTS ADDRESS
	TBT	RL,NNTN.F,,	:IS THIS A NTN INTERFACE?
	JN	PCR500,,	:YES, SKIP NUN STUFF
	LCS	R9,1		:SET FLAG
	SBT	R2,NTNCAL,,	:SET PROCESSING FLAG
	SIS	R7,2		:MAKE ADJUSTMENT FOR PROCESSING AT PCR492
	J	PCR460+5C,,	:CONTINUE NUN PROCESSING
CONPATCH(PCR484,,0A)
	ST	R0,DTESAX,R7,
	J	PCR488
ENDPATCH(Don't add DNIC to intra-network calls)

PATCH(850523,1045,DRE,CKAD30,,6)
	J	PA1PTR,,
CONPAT(PA1PTR,,1C)
	LR	R2,R0		:COPY REG WITH FIRST DIGIT
	SRLS	R2,4		:SHIFT FIRST DIGIT INTO POSITION
	CLHI	R2,9		:IS IT A 9
	JE	CKAD90,,	:YES, RESET GATEWAY FALG AND NO ERROR
	SLLS	R0,8		:POISTION FIRST 2 DIGITS OF DNIC
	LB	R2,DTESAX+2,R4,	:GET NEXT 2 DIGITS OF DNIC
	J	CKAD30+8,,	:CONTINUE WITH DNIC PROCESSING
ENDPATCH(Make sure leading 9 is not treated as a dnic)
    
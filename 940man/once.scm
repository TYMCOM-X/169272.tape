File 1)	DSK:ONCE.D05	created: 1709 08-MAR-88
File 2)	DSK:ONCE.MAC	created: 1950 29-APR-88

1)28	IFNCPU(KI),<WRAPR CLRNXM+APRCHN ;Clear NXM flags, keep PI channel assigned
1)		MOVEI	T3,PGCHK1	;Jump to PGCHK1 on AR/ARX parity page fault
1)		EXCH	T3,UPT+UPTNPP>	;(KL and KS get page failures from NXM)
1)		MOVE	T2,%ERR+774	;Verify interleaving by
****
2)28	IFNCPU(KI),<WRAPR CLRNXM+APRCHN>;Clear NXM flags, keep PI channel assigned
2)		MOVEI	T3,PGCHK1	;Jump to PGCHK1 on AR/ARX parity page fault
2)		EXCH	T3,UPT+UPTNPP	;(KL and KS get page failures from NXM)
2)		MOVE	T2,%ERR+774	;Verify interleaving by
**************
1)28	IFNCP U(KI),<			;Jump to here on page failure from NXM
1)	PGCHK1:	MOVEM	T3,UPT+UPTNPP>	;Restore page-fail new PC
1)		CONSZ	APR,APRNXM
1)		 JRST	[WRAPR	CLRNXM
1)			 POPJ	P,]	;Page is missing, give non-skip return
1)		PJRST	CPOPJ1		;Good page
1)	; Routine to type out message about dis-continuous core - highest
****
2)28					;Jump to here on page failure from NXM
2)	PGCHK1:	MOVEM	T3,UPT+UPTNPP	;Restore page-fail new PC
2)		CONSO	APR,APRNXM	;If not NXM
2)		 AOS	(P)		; then skip return
2)		WRAPR	CLRNXM
2)		SETZB	T2,UPT+UPTPFW	;Clear out page-fail locations
2)		SETZM	UPT+UPTOPP	; so as not to
2)		DPB	T2,[EPTPGP(%ERR.N)] ; confuse anyone
2)		POPJ	P,
2)	; Routine to type out message about dis-continuous core - highest
**************
  
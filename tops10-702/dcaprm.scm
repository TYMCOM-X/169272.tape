File 1)	DSKU:DCAPRM.DCA[702,10]	created: 0000 30-Jan-80
File 2)	DSKU:DCAPRM.CSM[702,10]	created: 2241 24-May-84

1)1	DEFINE	$SETMON<
1)	IFNDEF MONLVL,<	MONLVL==5070
1)	IFDEF FT2SEGMON,<MONLVL==6020>
1)	IFDEF DEVESE,<MONLVL==6030>
1)	>;;END OF IFNDEF MONLVL
1)		IFNDEF	FT2SEGMON,<
1)		DEFINE	$RELOC<
1)		SALL
1)	>
1)		DEFINE	$HIGH<>
1)		DEFINE	$LOW<>
1)		DEFINE	$LIT<
1)		LIT
1)	>
1)	>;;IFNDEF FT2SEGMON
1)		DINT==:-4
1)	IFGE MONLVL-6030,<
1)		DINT==:-6
1)	>;;6.03+
1)	>;;DEFINE $SETMON
1)		END			;OF DCAPRM.MAC
****
2)1	;[CSM] Removed needless definitions of $RELOC,$HIGH,$LOW,$LIT
2)	;[CSM] Removed definition of DINT until implemented in COMCON
2)		END			;OF DCAPRM.MAC
**************
    
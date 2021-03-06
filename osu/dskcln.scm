File 1)	DSK:DSKCLN.110	created: 1136 08-FEB-88
File 2)	DSK:DSKCLN.MAC	created: 2014 18-FEB-89

1)2	VEDT==110	; edits
1)	; %xxx - Add new rib bit RBHOLD for DKSCLN use only.  This bit means that
****
2)2	VEDT==111	; edits
2)	; %xxx - Add new rib bit RBHOLD for DKSCLN use only.  This bit means that
**************
1)2	;37(110)   5-Feb-88/JMS  Preserve PPN when deleting file due to NAM or SLF.
****
2)2	;37(111)  18-Feb-89/JMS  Make sure error message gets out if DSKB has
2)	;		more than 3 million pages (25 Memorex 3650 units).
2)	;37(110)   5-Feb-88/JMS  Preserve PPN when deleting file due to NAM or SLF.
**************
1 )11		HRRZ	T1,T		;SAVE FROM GETCOR.
****
2)11		TLNE	T,-1		;[111] EXCEED 256K?
2)		 JRST	NOCOR3		;[111] THIS LIMIT IS 3047424 PAGES ON DSKB
2)		HRRZ	T1,T		;SAVE FROM GETCOR.
**************
1)34		CAIL	T1,300000		;If more than this, ignore RIPALC
1)		 JRST	PRMRB0
****
2)34		CAIL	T1,774000		;If more than this, ignore RIPALC
2)		 JRST	PRMRB0
**************
1)44	PVYERR:	MOVEI	M,[ASCIZ/
****
2)44	;[111] This program takes 16K.  The remaining 240K can handle 3 SATs @ 80K
2)	NOCOR3:	MOVEI	M,[ASCIZ /
2)	SAT TOO BIG - Maximum size of DSKB is 3,000,000 pages/]
2)		JRST	FATERR	;[111] Limit is 80*1024*36 bits per SAT
2)	PVYERR:	MOVEI	M,[ASCIZ/
**************
   
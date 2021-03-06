File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

1)1		TITLE	BACKRS -- MODULE TO DO THE WORK FOR BACKUP -- %4(440)
1)		SUBTTL	FRANK NATOLI/FJN/PFC/KCM/JEF/MEB/CLRH/VLR/CGN/WMG/DC/BPK/MS/BAH	18-Jun-82
1)	DECVER==4		;MAJOR VERSION
1)	DECMVR==0		;MINOR VERSION
1)	DECEVR==440		;EDIT NUMBER
1)	CUSTVR==0		;CUSTOMER VERSION
1)	;+
1)	;.AUTOPARAGRAPH.FLAG INDEX.FLAG CAPITAL.LOWER CASE
1)	;.TITLE ^PROGRAM ^LOGIC ^MANUAL FOR ^^BACKRS\\
1)	;.SKIP 10.CENTER;^^BACKRS\\
1)	;.SKIP 1.CENTER;^PROGRAM ^LOGIC ^MANUAL
1)	;.SKIP 1.CENTER;^VERSION 4
1)	;.SKIP -20.CENTER;<ABSTRACT
****
2)1		TITLE	BACKRS -- MODULE TO DO THE WORK FOR BACKUP -- %4A(514)
2)		SUBTTL	FRANK NATOLI/FJN/PFC/KCM/JEF/MEB/CLRH/VLR/CGN/WMG/DC/BPK/MS/BAH/EDS	13-Apr-83
2)	DECVER==4		;MAJOR VERSION
2)	DECMVR==1		;MINOR VERSION
2)	DECEVR==514		;EDIT NUMBER
2)	CUSTVR==2		;Who edited, Joe Smith @ CSM
2)	;Also includes the following edits from the Software Dispatch
2)	;501  10-31514 15-Jun	Set /NOSCAN in LOOKUP block
2)	;506  10-32867 15-Nov	/ERRMAX
2)	;512  10-31851  1-Jan	List version numbers
2)	;515  10-33914 22-Jun	Remove edit 426.
2)	;[DPM]			Enable PSI notification of volume switch
2)		CSM01$==-1	;Change listing to fit within 64 columns
2)		CSM02$==-1	;Watch for reel changes after every OUT/IN uuo
2)		CSM03$==0	;Don't put SSNAME into the ANSI tape label
2)		CSM04$==777777	;Put REELID/FILE at top and bottom of listing
2)		CSM05$==-1	;Put list of REELIDs in TMP:TAP for cataloging
2)	;+
2)	;.AUTOPARAGRAPH.FLAG INDEX.FLAG CAPITAL.LOWER CASE
2)	;.TITLE ^PROGRAM ^LOGIC ^MANUAL FOR ^^BACKRS\\
2)	;.SKIP 10.CENTER;^^BACKRS\\
2)	;.SKIP 1.CENTER;^PROGRAM ^LOGIC ^MANUAL
2)	;.SKIP 1.CENTER;^VERSION 4A
2)	;.SKIP -20.CENTER;<ABSTRACT
**************
1)3		SEARCH	MACTEN,UUOSYM,SCNMAC		;[174]
1)	;%%C==%%C	;SHOW VERSION OF C
1)	%%MACT==%%MACT	;SHOW VERSION OF MACTEN		[174]
1)	%%SCNM==%%SCNM	;SHOW VERSION OF SCNMAC
1)	COPYRIGHT (C) DIGITAL EQUIPMENT CORPORATION 1974,1984.
1)		SALL		;CLEAN LISTING
1)	%%%BKP==:DECVER		;ENSURE CONSISTENT VERSION OF BACKUP
1)4		SUBTTL	DEFAULT PARAMETERS
****
2)3		SEARCH	MACTEN,UUOSYM,SCNMAC
2)	%%MACT==%%MACT	;SHOW VERSION OF MACTEN
2)	%%SCNM==%%SCNM	;SHOW VERSION OF SCNMAC
2)	COPYRIGHT (C) DIGITAL EQUIPMENT CORPORATION 1974,1984.
2)		SALL		;CLEAN LISTING
2)	%%%BKP==:DECVER		;ENSURE CONSISTENT VERSION OF BACKUP
2)	SUBTTL	CSM Revision History
2)		SEARCH	CSMEDT		;CSM edit macro definition
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	create d: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)	; Edit	   Date   Who	Description
2)	;======	========= ===	================================================
2)	;CSM 00	 1-Jun-81 JMS	Make /NLIST produce lines that are 64 characters
2)	;			max so that DBLDOC can print 2 columns per page.
2)	  ;
2)		CSMEDT	01	;Show value of CSM01$
2)	  ;
2)	;CSM 02	 1-Jun-81 JMS	Notice when a volume-switch occurs for labelled
2)	;			tapes by checking the REELID after every OUTPUT.
2)	  ;
2)		CSMEDT	02	;Show value of CSM02$
2)	  ;
2)	;CSM 03	 8-Jun-81 JMS	Use TAPOP. to set labelled file parameters.
2)	;			FILE=SSNAME, LRECL and BLKSIZE=544*5.
2)	  ;
2)		CSMEDT	03	;Turned off until bug in PULSAR is fixed.
2)	  ;
2)	;CSM 04	 8-Jun-81 JMS	CSM04$&1 will put FF and header in list file
2)	;			every 60 lines.  CSM04$&2 will put REELID/FILE at
2)	;			top of page, CSM04$&4 will put it at the bottom.
2)	  ;
2)		CSMEDT	04	;Show value of CSM04$
2)	  ;
2)	;CSM 05	10-Jun-81 JMS	Put list of REELIDs in TMPCOR file TAP.  Format:
2)	;				SSNAME:DSKS FULL SAVE
2)	;				DATE:  14-Feb-83 Monday
2)	;				VOLUME:MT0600 FILE:04
2)	;				EOV:   DSKB:[1234,5670,SFD1]FOOBAR.LST
2)	;				VOLUME:MT0601 FILE:01
2)	;			The above example used 2 tapes, starting with
2)	;			saveset #4 on MT0600 and continuing to MT0601.
2)	  ;
2)		CSMEDT	05	;Show value of CSM05$
2)	  ;
2)	IFN CSM05$,<IFE CSM02$,<PRINTX ?CSMEDT 05 depends on CSMEDT 02>>
2)	  ;
2)	;End of CSM Revision History.
2)4		SUBTTL	DEFAULT PARAMETERS
**************
1)4	ND EMAX,^D100		;MAX NUMBER OF TAPE ERRORS BEFORE GIVING UP
1)	ND EOTEMX,1		;MAX NUMBER OF TAPE ERRORS AFTER EOT
****
2)4	;[506] ND EMAX,^D100	;MAX NUMBER OF TAPE ERRORS BEFORE GIVING UP
2)	ND EOTEMX,1		;MAX NUMBER OF TAPE ERRORS AFTER EOT
**************
1)9			;&#FLAG CONTROL . 
1)10		SUBTTL	IMPURE STORAGE
****
2)9			;&#FLAG CONTROL .
2)10		SUBTTL	IMPURE STORAGE
**************
1)10	PSIVCT:: BLOCK	4	;PSI VECTOR
1)	IFN FT$IND,<
****
2)10		CSMEDT	02,1	;Watch reel changes, part 1
2)	IFN CSM02$!CSM03$,<
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)	LBTYP:	BLOCK	1		;Non-zero if MDA controlled tape
2)	MTCBLK:	BLOCK	4		;Block for MTCHR.
2)	REELID=MTCBLK+.MTRID		;Label for reel-ID
2)	  ND .MTFIL,2			;Should be in UUOSYM in place of .MTWRD==2
2)	MTFILE=MTCBLK+.MTFIL		;Count of files from BOT
2)	MTREC= MTCBLK+.MTREC		;Count of records from start of file
2)	>  ;End of IFN CSM02$!CSM03$
2)	IFE CSM02$!CSM03$,<
2)	REELID:	BLOCK	1	;[DPM] Current reel ID
2)	>  ;End of IFE CSM02$!CSM03$
2)	PSIVCT:!		;[DPM] Base address of PSI vector
2)	PSITTY::BLOCK	4	;[DPM] PSI vector for TTY
2)	PSIMTA::BLOCK	4	;[DPM] PSI vector for MTA
2)	IFN FT$IND,<
**************
1)10	PRNAME:	BLOCK	1	;[227] RENAME PROTECTION STORAGE
****
2)10	DCHARG:	BLOCK	5	;[503] FOR DSKCHR UUO
2)	PRNAME:	BLOCK	1	;[227] RENAME PROTECTION STORAGE
**************
1)10	STOEND==.-1	;END OF STORAGE
1)					;&
1)11		SUBTTL	TAPE FORMAT
1)	;+.AUTOPA.FLAGS.TS8,16,24,32,,,,,,,,,.P0,-1.FILL.LOWER CASE
1)	;.CHAPTER BACKUP TAPE FORMAT
1)	; <NOTE:  ^BACKUP IS DESIGNED FOR TWO PRIMARY FUNCTIONS; PERFORMING SYSTEM
1)	;BACKUP AND INTERCHANGING FILES BETWEEN SYSTEMS.  ^FOR THE LATTER FUNCTION,
1)	;^BACKUP PROVIDES AN "INTERCHANGE" SWITCH WHICH CAUSES SYSTEM DEPENDENT 
1)	;DATA TO BE IGNORED AND ONLY CRITICAL FILE INFORMATION TO BE WRITTEN ON
1)	;TAPE. ^A RESTORE OPERATION IN INTERCHANGE MODE ALSO IGNORES SYSTEM 
1)	;DEPENDENT DATA, ALLOWING THE OPERATING SYSTEM TO SUPPLY DEFAULTS WHERE
****
2)10		CSMEDT	05,1	;Put REELIDs in TMP:TAP, part 1
2)	IFN CSM05$,<
2)		TMPSIZ==^D500		;Size of our TMPCOR file in chars
2)	TMPBUF:	BLOCK	TMPSIZ/5	;TMPFIL
2)	TMPCNT:	BLOCK	1		;Count of bytes remaining
2)	TMPPTR:	BLOCK	1		;Byte pointer
2)	LSTFLG:	BLOCK	1		;Address of routine used by LSTOUT
2)	>  ;End of IFN CSM05$
2)	STOEND==.-1	;END OF STORAGE
2)		CSMEDT	03,1	;Labelled tape info, part 1
2)	IFN CSM03$,<	;Non-zero storage
2)	TAPBLK:	.TFLPR+.TOSET		;TAPOP. block for label parameters
2)		F.MTAP			; Channel
2)		.TFCAM,,.TRFFX		; Imbedded CRLFs, fixed length records
2)		MTBBKP*5		; Record size, in bytes
2)		MTBBKP*5		; Block size
2)		0			; Creation ,, expiration date
2)		0			; Protection
2)		0			;+.TPSEQ  File sequence number
2)		BLOCK	<^D17+4>/5	;+.TPFNM  File name, 17 chars of ASCII
2)		BLOCK	.TPLEN-<.-TAPBLK> ; Fill out the rest of the block
2)	>  ;End of IFN CSM03$
2)		CSMEDT	04,1	;List 60 lines per page, part 1
2)	IFN CSM04$,<
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)	LINUMB:	^D60			;Number of lines left on page
2)	PAGNUM:	0			;Listing file page number (never reset)
2)	NEWPAG:	-1			;-1 if first file on the page
2)	>  ;End of IFN CSM04$
2)					;&
2)11		SUBTTL	TAPE FORMAT
2)	;+.AUTOPA.FLAGS.TS8,16,24,32,,,,,,,,,.P0,-1.FILL.LOWER CASE
2)	;.CHAPTER BACKUP TAPE FORMAT
2)	; <NOTE:  ^BACKUP IS DESIGNED FOR TWO PRIMARY FUNCTIONS; PERFORMING SYSTEM
2)	;BACKUP AND INTERCHANGING FILES BETWEEN SYSTEMS.  ^FOR THE LATTER FUNCTION,
2)	;^BACKUP PROVIDES AN "INTERCHANGE" SWITCH WHICH CAUSES SYSTEM DEPENDENT
2)	;DATA TO BE IGNORED AND ONLY CRITICAL FILE INFORMATION TO BE WRITTEN ON
2)	;TAPE. ^A RESTORE OPERATION IN INTERCHANGE MODE ALSO IGNORES SYSTEM
2)	;DEPENDENT DATA, ALLOWING THE OPERATING SYSTEM TO SUPPLY DEFAULTS WHERE
**************
1)13	;HEADER IS RESERVED FOR CUSTOMER USE. ^THE REMAINING 20 WORDS IN THE 
1)	;RECORD HEADER VARY FOR EACH RECORD TYPE, WITH THE LAST WORD OF EACH
****
2)13	;HEADER IS RESERVED FOR CUSTOMER USE. ^THE REMAINING 20 WORDS IN THE
2)	;RECORD HEADER VARY FOR EACH RECORD TYPE, WITH THE LAST WORD OF EACH
**************
1)14	;PUNCTUATION. ^THE PATH COMPONENTS ARE TREATED AS IF THE USER GAVE A 
1)	;QUOTED REPRESENTATION IN "<DEC ^INTEGRATED ^COMMAND ^LANGUAGE".
****
2)14	;PUNCTUATION. ^THE PATH COMPONENTS ARE TREATED AS IF THE USER GAVE A
2)	;QUOTED REPRESENTATION IN "<DEC ^INTEGRATED ^COMMAND ^LANGUAGE".
**************
1)14	;ONE NULL. ^FOR THE <UFD DIRECTORY FIELD, THE PROJECT AND 
1)	;PROGRAMMER HALVES ARE CONVERTED TO OCTAL NUMBERS AND SEPARATED
****
2)14	;ONE NULL. ^FOR THE <UFD DIRECTORY FIELD, THE PROJECT AND
2)	;PROGRAMMER HALVES ARE CONVERTED TO OCTAL NUMBERS AND SEPARATED
**************
1)17	;.LE;<A$CRET -- CREATION DATE AND TIME OF THIS GENERATION 
1)	;.LE;<A$REDT -- LAST READ DATE AND TIME OF THIS GENERATION [<RB.ACD]
****
2)17	;.LE;<A$CRET -- CREATION DATE AND TIME OF THIS GENERATION
2)	;.LE;<A$REDT -- LAST READ DATE AND TIME OF TENERATION [<RB.ACD]
**************
1)18	;.LE;<D$PROT -- DIRECTORY PROTECTION [<RB.PRV]. 
1)	;^THE DIRCTORY PROTECTION WORD IS DIVIDED INTO THE SAME ACCESS FIELDS
****
2)18	;.LE;<D$PROT -- DIRECTORY PROTECTION [<RB.PRV].
2)	;^THE DIRCTORY PROTECTION WORD IS DIVIDED INTO THE SAME ACCESS FIELDS
**************
1)23		MOVEI	T1,TTYSER	;SERVICE ROUTINE ADDRESS
1)		MOVEM	T1,PSIVCT+.PSVNP;STORE NEW PC IN PSI VECTOR
1)		MOVX	T1,PS.VTO	;DISABLE WITH DEBRK. UUO
1)		MOVEM	T1,PSIVCT+.PSVFL;STORE
1)		MOVEI	T1,PSIVCT	;BASE ADDRESS
1)		PIINI.	T1,		;INITIALIZE PSI
1)		  TXZ	F,FL$PSI	;ERROR--CLEAR PSI FLAG
1)		MOVSI	T2,'TTY'	;SET DEVICE
1)		MOVX	T3,PS.RID	;REASON=INPUT DONE
1)		SETZ	T4,		;ZILCH
1)		MOVX	T1,PS.FON!PS.FAC;TURN PSI ON
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

1)		HRRI	T1,T2		;ADDRESS OF ARG BLOCK
1)		PISYS.	T1,		;EXEC
1)		  TXZ	F,FL$PSI	;ERROR--ZILCH PSI FLAG
1)	SETSRT:	MOVE	T1,S.SRTD##	;GET SORT INDEX
****
2)23	;[DPM] Add PSI interrupt to report volume switches in listing
2)	  ND PS.RSW,1B31	;[DPM] PSI reason = Reel Switch
2)		MOVEI	T1,TTYSER	;SERVICE ROUTINE ADDRESS
2)		MOVEM	T1,PSITTY+.PSVNP;[DPM] Store new PC in PSI vector
2)		MOVEI	T1,MTASER	;[DPM] MTA service routine
2)		MOVEM	T1,PSIMTA+.PSVNP;[DPM] Store new PC in PSI vector
2)		MOVX	T1,PS.VTO	;DISABLE WITH DEBRK. UUO
2)		MOVEM	T1,PSITTY+.PSVFL;[DPM]
2)		MOVEM	T1,PSIMTA+.PSVFL;[DPM]
2)		MOVEI	T1,PSIVCT	;BASE ADDRESS
2)		PIINI.	T1,		;INITIALIZE PSI
2)		  JRST	SETERR		;[DPM] Error - clear PSI allowed flag
2)		MOVE	T1,[PS.FON!PS.FAC+[EXP <'TTY   '>,<<PSITTY-PSIVCT>,,PS.RID>,0]];[DPM]
2)		PISYS.	T1,		;[DPM] Turn PSI on for TTY
2)		  JRST	SETERR		;[DPM] Should never happen
2)		MOVE	T1,[PS.FON!PS.FAC+[EXP F.MTAP,<<PSIMTA-PSIVCT>,,PS.RSW>,0]];[DPM]
2)		PISYS.	T1,		;[DPM] Turn PSI on for MTA
2)	SETERR:	  TXZ	F,FL$PSI	;ERROR--ZILCH PSI FLAG
2)	SETSRT:	MOVE	T1,S.SRTD##	;GET SORT INDEX
**************
1)23		SKIPGE	S.OPER##	;IF WRITE OPERATION,
****
2)23		CSMEDT	02,2	;Watch for reel changes, part 2, before CMDTBL:
2)	IFN CSM02$!CSM03$,<	;The variable LBTYP is set as follows:
2)			;-1 for unlabelled tapes, but MDA is involved at EOT
2)			; 0 for BYPASS or user-EOT, BACKRS does reel switching
2)			;+1 for ANSI labels, MDA will switch reels automatically
2)		SETOM	LBTYP		;Assume MDA is involved
2)		MOVE	T1,TAPLBL##	;Get label type
2)		CAXE	T1,.TFLAL	;ANSI labels?
2)		CAXN	T1,.TFLAU	; with or without user labels?
2)		 MOVEM	T1,LBTYP	;Yes, make flag positive (+1 or +2)
2)		CAXE	T1,.TFLBP	;Bypass?
2)		CAXN	T1,.TFLNV	;User-EOT?
2)		 SETZM	LBTYP		;Yes, MDA won't change reels on us
2)		PUSHJ	P,MTARID	;Get REELID and file number
2)	>  ;End if IFN CSM02$!CSM03$
2)		CSMEDT	04,2	;List 60 lines per page, part 2
2)	IFN CSM04$,<	;Set up LINUMB
2)		SKIPN	S.LIST##	;Listing?
2)		 JRST	CSM04Z		;No
2)	IFE CSM04$&4,<MOVEI T2,^D60	;Set line counter to 60 per page>
2)	IFN CSM04$&4,<MOVEI T2,^D59	;Leave room for line at bottom>
2)		MOVEI	T1,F.LIST	;Get list device channel
2)		DEVCHR	T1,		;Get its characteristics
2)		TXNE	T1,DV.TTY	;TTY or NUL?
2)		 SETO	T2,		;Yes, no headers
2)		MOVEM	T2,LINUMB	;Number of lines left on page
2)		PUSHJ	P,LSTHDR	;Send header to list file
2)		PUSHJ	P,LSCRLF	;Put blank line before T$BEG output
2)	CSM04Z:	>  ;End of IFN CSM04$
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)	;[DPM] Add PSI interrupt to report volume switches in listing
2)		PUSHJ	P,MTARID	;[DPM] Read current REELID before testing S.OPER
2)		SKIPGE	S.OPER##	;IF WRITE OPERATION,
**************
1)25		MOVE	T2,UPHYN	;PHYSICAL TAPE NAME
1)		MOVE	T1,[.MTRID,,T2]	;ARG FOR MTCHR.
1)		MTCHR.	T1,		;GET REELID
1)		  SETZ	T3,		;LOSE
1)		MOVEM	T3,S$RLNM(MH)	;STORE
****
2)25		MOVE	T3,REELID	;[DPM] Read REELID
2)		MOVEM	T3,S$RLNM(MH)	;STORE
**************
1)25		SKIPE	S.NLDV		;[375] NULL TAPE DEVICE?
1)		JRST	LSTXXX		;[375] YES, LIST AND RETURN
1)		PUSHJ	P,LSTXXX	;LIST START/END OF SAVE
1)		JRST	MTAOUT		;SEND BUFFER & RETURN
1)26	;+
1)	;<SAVSTR IS CALLED ONCE FOR EACH STRUCTURE INDICATED BY THE USER'S SPEC
1)	;LIST. <IO CHANNELS ARE INITIALIZED AND THE FILE STRUCTURE'S <MFD READ
1)	;INTO CORE, AND SORTED IF NEEDED. ^THEN THE ^^UFD\\S SPECIFIED FOR THE 
1)	;CURRENT STRUCTURE ARE CHOSEN OUT OF THE <MFD FOR FURTHER PROCESSING.
****
2)25		CSMEDT	05,2	;Put REELID list in TMP:TAP, part 2 at LSTSAV:+6
2)	IFN CSM05$,<	;Initialize TMPBUF before doing SAVE
2)		SKIPN	S.LIST##	;List file active?
2)		 JRST	CSM05Z		;No, do not write TMP
2)		MOVE	T1,G$TYPE(MH)	;Get type of save file
2)		CAIN	T1,T$END	;End of save set?
2)		 JRST	CSM05Y		;Yes, finish writing TMP
2)		CAIE	T1,T$BEG	;Beginning?
2)		 JRST	CSM05Z		;No, skip continuation records
2)		MOVSI	T2,'TAP'	;Get TMPCOR name
2)		MOVE	T3,[IOWD <TMPSIZ/5>,TMPBUF]
2)		MOVE	T1,[.TCRRF,,T2]	;Point to args
2)		TMPCOR	T1,		;Read old file, T1 gets size in words
2)		  MOVEI	T1,0		;No old file
2)		MOVE	T2,[POINT 7,TMPBUF]
2)		ADD	T2,T1		;Make byte pointer to append to file
2)		MOVEM	T2,TMPPTR	;Save pointer
2)		IMULI	T1,5		;Number of bytes used
2)		SUBI	T1,TMPSIZ	;Negative bytes remaining
2)		MOVNM	T1,TMPCNT	;Set byte count
2)	;Format of TMP:TAP (example starts with 4th saveset on BACK01, uses 2)
2)	;	SSNAME:PARTIAL SAVE OF DSKB
2)	;	DATE:  10-Jun-81 Wednesday
2)	;	REELID:BACK01 FILE:04
2)	;	EOV:   DSKB:[1234,5670,SFDA]FOOBAR.LST
2)	;	REELID:BACK02 FILE:01
2)	;There can be more than one save in the TMP file.
2)		PUSH	P,LSTFLG	;Save old routine
2)		PUSH	P,LINUMB	;Save current line number
2)		SETOM	LINUMB		;Disable funny stuff at line 60
2)		MOVEI	T1,LSTTMP	;Addr of new routine
2)		MOVEM	T1,LSTFLG	;Set to write into TMPBUF
2)	;Put SSNAME, DATE, and first VOLUME in TMPCOR file
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)		MOVEI	T1,[ASCIZ /SSNAME:/]
2)		PUSHJ	P,LSTMSG
2)		MOVEI	T1,S.SSNM##	;Point to saveset name
2)		PUSHJ	P,LSTMSG	;Put in TMPBUF
2)		MOVEI	T1,[ASCIZ /
2)	DATE:  /]
2)		PUSHJ	P,LSTMSG
2)		MOVX	T1,%CNDTM	;Get the universal date/time
2)		GETTAB	T1,
2)		  JFCL			;Can never fail
2)		PUSHJ	P,LSTWEK	;List date and day of week
2)		PUSHJ	P,LSCRLF	;Finish line
2)		POP	P,LINUMB	;Restore line counter
2)		POP	P,LSTFLG	;Restore old output routine
2)		PUSHJ	P,TMPVOL	;Put current REELID in TMPBUF
2)		JRST	CSM05Z		;Done
2)	;Here at end of saveset, write data back to TMPCOR file
2)	CSM05Y:	MOVE	T1,TMPCNT	;Get number of bytes remaining
2)		SUBI	T1,TMPSIZ+4	;Negative bytes used (with rounding)
2)		IDIVI	T1,5		;Number of words to write
2)		HRL	T3,T1		;Negative word count
2)		HRRI	T3,TMPBUF-1	;Build IOWD
2)		MOVSI	T2,'TAP'	;TMPCOR file name
2)		MOVE	T1,[.TCRWF,,T2]	;Point to args
2)		TMPCOR	T1,		;Write TMP:TAP
2)	          JRST	[OUTSTR [ASCIZ /%BKPERT Error writing TMP:TAP
2)	/]				  ;7.01 always has room in TMPCOR
2)			 OUTSTR	TMPBUF	  ;Output the message
2)			 JRST	.+1]	;Continue anyway
2)	CSM05Z:	>  ;End of IFN CSM05$
2)		SKIPE	S.NLDV		;[375] NULL TAPE DEVICE?
2)		JRST	LSTXXX		;[375] YES, LIST AND RETURN
2)		PUSHJ	P,LSTXXX	;LIST START/END OF SAVE
2)		JRST	MTAOUT		;SEND BUFFER & RETURN
2)26	;+
2)	;<SAVSTR IS CALLED ONCE FOR EACH STRUCTURE INDICATED BY THE USER'S SPEC
2)	;LIST. <IO CHANNELS ARE INITIALIZED AND THE FILE STRUCTURE'S <MFD READ
2)	;INTO CORE, AND SORTED IF NEEDED. ^THEN THE ^^UFD\\S SPECIFIED FOR THE
2)	;CURRENT STRUCTURE ARE CHOSEN OUT OF THE <MFD FOR FURTHER PROCESSING.
**************
1)29		SETOM	T1,CNAMSW	;[416] STORE 
1)		SETZM	THSRDB		;[421] SET BLOCK SIZE TO ZERO
****
2)29		SETOM	CNAMSW		;[416] STORE
2)		SETZM	THSRDB		;[421] SET BLOCK SIZE TO ZERO
**************
1)31		SKIPN	S.INTR##	;SEE IF /INTERCHANGE 
1)		PUSHJ	P,WRTUFD	;NO--WRITE T$UFD RECORDS ON TAPE
****
2)31		SKIPN	S.INTR##	;SEE IF /INTERCHANGE
2)		PUSHJ	P,WRTUFD	;NO--WRITE T$UFD RECORDS ON TAPE
**************
1)33	;<WRTUFD IS A ROUTINE TO WRITE A <T$UFD RECORD ON TAPE FOR EACH DIRECTORY IN 
1)	;THE FILE PATH.
****
2)33	;<WRTUFD IS A ROUTINE TO WRITE A <T$UFD RECORD ON TAPE FOR EACH DIRECTORY IN
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)	;THE FILE PATH.
**************
1)34		MOVEI	T1,NRIB-1	;SET FOR EXTENDED LOOKUP
****
2)34		CSMEDT	02,4	;Watch reel changes, part 4, at SAVFIL:+8
2)	IFG CSM02$,< PUSHJ  P,NVOLCK >	;Do new volume check before each file
2)		MOVEI	T1,NRIB-1	;SET FOR EXTENDED LOOKUP
**************
1)48		JRST	RSTRE2		;[426]
1)		JUMPLE	T1,NOSUCH	;UNRECOGNIZABLE RECORD TYPE
1)		CAIG	T1,T$MAX	;KNOW OF IT?
1)		JRST	RSTREC		;YES--CONTINUE READING
1)	NOSUCH:	WARN$N	(URT,Unknown record type)
1)		PUSHJ	P,OCTOUT	; ..
1)		OUTSTR	CRLF		;<CR><LF>
1)		JRST	RSTREC		;GET NEXT
1)	RSTRE2:	PUSHJ	P,LSTXXX	;[426] LIST IT
1)		PUSHJ	P,LABSTS	;[426] CHECK LABEL TYPE
1)		JRST	RSTREC		;[426]
1)49	;Make sure that the tape is being read using the same label
1)	;type that it was written with.  If it is not, give an error
1)	;message and wait for the user to type GO.
1)	;
1)	LABSTS:	MOVE	T1,TAPLBL##	;[426] GET THE LABEL TYPE 
1)		CAMN	T1,S$LBLT(MH)	;[426] IS CURRENT LABEL TYPE = SAVE LABEL TYPE?
1)		POPJ	P,		;[426] YES, RETURN 
1)		HRL	T1,S$LBLT(MH)	;[433] MOVE THE SAVE LABEL TYPE IN LH
1)		HRLZI	T2,LABCTE	;[433] SET UP AOBJN FOR TABLE SEARCH
1)	LABST1:	CAMN	T1,LABCTB(T2)	;[433] DO WE HAVE A MATCH?
1)		POPJ	P,		;[433] YES. DON'T COMPLAIN ABOUT THE MISMATCH
1)		AOBJN	T2,LABST1	;[433] LOOP THRU THE TABLE, REPORT IF NO MATCH
1)		OUTSTR	[ASCIZ/
1)	%BKPDLT Tape being read /]	;[426]
1)		MOVE	T1,LABTBL(T1)	;[426] GET THE POINTER FOR THE TABLE
1)		OUTSTR	@T1		;[426] 
1)		OUTSTR	[ASCIZ /was written /]	;[426]
1)		MOVE	T1,S$LBLT(MH)	;[426] SAVED LABEL
1)		MOVE	T1,LABTBL(T1)	;[426] GET THE POINTER FOR THE TABLE
1)		OUTSTR	@T1		;[426] 
1)		OUTSTR	CRLF		;[426]
1)		OPER$	(TGC,errors may occur type "GO" to continue..)
1)		PUSHJ	P,TYI		;[426] WAIT FOR GO
1)		POPJ	P,		;[426] 
1)	;The following table contains all label types as defined by
1)	;the .TFLBL function of the TAPOP. UUO.
1)	;
1)	LABTBL:	EXP	[ASCIZ /BYPASS /]				;[426]
1)		EXP	[ASCIZ /using ANSI labels /  ]			;[426]
1)		EXP	[ASCIZ /using ANSI labels and user labels /  ]	;[426]
1)		EXP	[ASCIZ /using IBM labels /  ]			;[426]
1)		EXP	[ASCIZ /using IBM labels and user labels /  ]	;[426]
1)		EXP	[ASCIZ /using leading tape mark /  ]		;[426]
1)		EXP	[ASCIZ /using NONSTANDARD labels /  ]		;[426]
1)		EXP	[ASCIZ /unlabeled /  ]				;[426]
1)		EXP	[ASCIZ /using DEC COBOL ASCII labels /  ]	;[426]
1)		EXP	[ASCIZ /using DEC COBOL SIXBIT labels /  ]	;[426]
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

1)		EXP	[ASCIZ /USER-EOT /  ]				;[426]
1)	;The following table contains all combinations of label types which are legal.
1)	;T1 contains the save label type in its LH and the current label type in its RH.
1)	;The routine LABSTS then does a table search for an equivalence.  Tapes written
1)	;by BACKUP before GALAXY 4.1 are written in BYPASS (label type 0) by definition.
1)	LABCTB:	.TFLBP,,.TFLNL		;[433] BYPASS,,UNLABELLED
1)		.TFLBP,,.TFLNV		;[433] BYPASS,,USER-EOT
1)		.TFLNL,,.TFLBP		;[433] UNLABELLED,,BYPASS
1)		.TFLNL,,.TFLNV		;[433] UNLABELLED,,USER-EOT
1)		.TFLNV,,.TFLBP		;[433] USER-EOT,,BYPASS
1)		.TFLNV,,.TFLNL		;[433] USER-EOT,,UNLABELLED
1)	LABCTE==LABCTB-.		;[433] Negative length of table
1)50	;HERE IF HAVE T$END TYPE RECORD IN BUFFER
****
2)48		JRST	[PUSHJ	P,LSTXXX  ;[515] Yes, list it and
2)			 JRST	RSTREC]	  ;[515]  continue
2)		JUMPLE	T1,NOSUCH	;UNRECOGNIZABLE RECORD TYPE
2)		CAIG	T1,T$MAX	;KNOW OF IT?
2)		JRST	RSTREC		;YES--CONTINUE READING
2)	NOSUCH:	WARN$N	(URT,Unknown record type)
2)		PUSHJ	P,OCTOUT	; ..
2)		OUTSTR	CRLF		;<CR><LF>
2)		JRST	RSTREC		;GET NEXT
2)	;**;[515] Delete routines RSTRE2 and LABSTS, BAH, 20-Jun-84
2)49	;HERE IF HAVE T$END TYPE RECORD IN BUFFER
**************
1)52		SETOM	T1,CNAMSW	;[416] STORE
1)		MOVEI	T1,.FCEXT	;INDICATE EXTENSION
****
2)51		SETOM	CNAMSW		;[416] STORE
2)		MOVEI	T1,.FCEXT	;INDICATE EXTENSION
**************
1)52	RSTVER:	SKIPE	S.INTR##	;SEE IF /INTERCHANGE
1)		JRST	RSTVR2		;YES--ONLY FILE NAME AND EXT MUST MATCH
****
2)51	RSTVER:	PUSHJ	P,SETSTR	;[503][262] SET UP STRUCTURE MASK
2)		SKIPE	S.INTR##	;SEE IF /INTERCHANGE
2)		JRST	RSTVR2		;YES--ONLY FILE NAME AND EXT MUST MATCH
**************
1)52		PUSHJ	P,SETSTR	;[262] SET UP STRUCTURE MASK
1)		CAMGE	SP,S.LAST##	;SKIP IF DONE
****
2)51		CAMGE	SP,S.LAST##	;SKIP IF DONE
**************
1)55		MOVE	T1,EXLFIL+.RBNAM;GET FILE NAME
1)		HLLZ	T2,EXLFIL+.RBEXT;GET EXT
1)		MOVEI	T3,0		;ZERO PRIV WORD
1)		MOVE	T4,EXLFIL+.RBPPN ;GET DIRECTORY
1)		LOOKUP	FILE,T1		;FILE THERE?
1)		JRST	NOFILE		;NOPE--GOODIE
1)		TXNN	F,FL$HUF	;[342] IF NOT ALREADY HELD,
1)		PUSHJ	P,HOLDIT	;[342] HOLD THIS PPN
1)		TXNE	F,FL$CHK	;IF /CHECK
****
2)54		MOVX	T1,.PTSCN	;[501] No SCAN
2)		MOVEM	T1,APATH+.PTSWT	;[501] Set path switch
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)		MOVE	T1,EXLFIL+.RBNAM;GET FILE NAME
2)		HLLZ	T2,EXLFIL+.RBEXT;GET EXT
2)		MOVEI	T3,0		;ZERO PRIV WORD
2)		MOVE	T4,EXLFIL+.RBPPN ;GET DIRECTORY
2)		LOOKUP	FILE,T1		;FILE THERE?
2)		JRST	NOFILE		;NOPE--GOODIE
2)		TXNN	F,FL$HUF	;[436][342] IF NOT ALREADY HELD,
2)		PUSHJ	P,HOLDIT	;[436][342] HOLD THIS PPN
2)		TXNE	F,FL$CHK	;IF /CHECK
**************
1)57		SETSTS	FILE,(T1)	;FAKE OUT FILSER
1)		PUSHJ	P,SETFIL	;SET UP FILE ENTER BLOCK
****
2)56	;**;[510] @ NEWFIL + 14L, Replace 1L, BAH, 5-Oct-82
2)		MOVEI	T2,FILE		;[510] CHANNEL
2)		DEVCHR	T2,		;[510] GET LEGAL DATA MODES FOR THIS DEVICE
2)		MOVEI	T3,1		;[510] ADJUST TO THE BIT POSITION OF THE GIVEN
2)		LSH	T3,(T1)		;[510]  DATA MODE TO COMPARE WITH BITS RETURNED
2)		TDNE	T2,T3		;[510]  BY THE DEVCHR.  IS THE DATA MODE KNOWN?
2)		JRST	NEWFL1		;[510] YES
2)		WARN$N	(IDM,Illegal data mode)	;[510] NO. REPORT IT
2)		PUSHJ	P,OCTOUT	;[510] DISPLAY ILLEGAL DATA MODE
2)		OUTSTR	[ASCIZ / for file /]	;[510]
2)		PUSHJ	P,TYSPEC	;[510] DISPLAY FILE SPEC
2)		OUTSTR	[ASCIZ/, assuming image mode.
2)	/]
2)		MOVEI	T1,.IOIMG	;[510] USE BINARY MODE INSTEAD
2)	NEWFL1:	SETSTS	FILE,(T1)	;FAKE OUT FILSER
2)		PUSHJ	P,SETFIL	;SET UP FILE ENTER BLOCK
**************
1)61		MOVEM	T2,EXLFIL		;[232] SET IN BLOCK 
1)		RENAME	FILE,EXLFIL		;[232] RENAME THE FILE
****
2)60		MOVEM	T2,EXLFIL		;[232] SET IN BLOCK
2)		RENAME	FILE,EXLFIL		;[232] RENAME THE FILE
**************
1)62		HLRZ	T3,(P1)		;GET SUB-BLOCK TYPE 
1)		CAMN	T2,T3		;COMPARE
****
2)61		HLRZ	T3,(P1)		;GET SUB-BLOCK TYPE
2)		CAMN	T2,T3		;COMPARE
**************
1)63		MOVEM	T1,.RBEST(P2)	;SET AS ESTIMATE 
1)		SKIPE	S.INTR##	;SEE  IF /INTERCHANGE
****
2)62		MOVEM	T1,.RBEST(P2)	;SET AS ESTIMATE
2)		SKIPE	S.INTR##	;SEE  IF /INTERCHANGE
**************
1)66		MOVEM	T1,UPTBLK+1	;[425] STORE
1)		MOVEI	T1,UPTBLK	;WHERE TO FIND PATH
1)		MOVEM	T1,EXLUFD+.RBPPN;STORE
1)		MOVSI	T1,'SFD'	;LOAD EXTENSION 
1)	LEVEL0:	HLLM	T1,EXLUFD+.RBEXT;STORE EXTENSION
****
2)65		MOVEM	T1,UPTBLK+.PTSWT;[501] STORE
2)		MOVEI	T1,UPTBLK	;WHERE TO FIND PATH
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)		MOVEM	T1,EXLUFD+.RBPPN;STORE
2)		MOVSI	T1,'SFD'	;LOAD EXTENSION
2)	LEVEL0:	HLLM	T1,EXLUFD+.RBEXT;STORE EXTENSION
**************
1)69		ADD	7,1		;DON'T ENCRYPT NON-DATA 
1)		MOVE	6,F$RDW(MH)	;GET RELATIVE WORD
****
2)68		ADD	7,1		;DON'T ENCRYPT NON-DATA
2)		MOVE	6,F$RDW(MH)	;GET RELATIVE WORD
**************
1)69		MTBLK.	F.MTAP,		;[310] YES, WRITE BLANK TAPE FIRST
****
2)68		CSMEDT	03,2	;Labelled file info, part 2, at DUMOUT:+3
2)	IFN CSM03$,<	;Inform PULSAR of the file parameters
2)		SKIPG	LBTYP			;ANSI labels?
2)		  JRST	DUMOU0			;No, don't try to set data
2)		MOVE	T1,MTFILE		;Yes, get current file number
2)		MOVEM	T1,TAPBLK+.TPSEQ	;Use it as file sequence number
2)		MOVE	T1,[S.SSNM##,,TAPBLK+.TPFNM] ;Use SSNAME
2)		BLT	T1,TAPBLK+.TPGEN-1	; as labelled file name
2)		MOVE	T1,[.TPLEN,,TAPBLK]	;Point to block
2)		TAPOP.	T1,			;Tell PULSAR
2)		  OUTSTR [ASCIZ	/
2)	%BKPCST	Cannot set tape label parameters
2)	/]					;Bug in PULSAR if this happens
2)	DUMOU0:	>  ;End of IFN CSM03$
2)		MTBLK.	F.MTAP,		;[310] YES, WRITE BLANK TAPE FIRST
**************
1)70	NOTEOT:	SKIPN	P3		;SEE IF FIRST TIME THRU
1)		HRRZ	P3,S.MBPT##	;YES--SAVE CURRENT POSITION IN RING
****
2)69	NOTEOT:	DMOVEM	P1,SAVEP1	;[CSM] Save GETSTS data in P1
2)		SKIPN	P3		;SEE IF FIRST TIME THRU
2)		HRRZ	P3,S.MBPT##	;YES--SAVE CURRENT POSITION IN RING
**************
1)70		CAIGE	T1,EMAX		;SEE IF MAXIMUM REACHED
1)		JRST	CNTOUT		;NO--CONTINUE OUTPUTTING
****
2)69		CAMGE	T1,S.EMAX##	;[506] See if maximum reached
2)		JRST	CNTOUT		;NO--CONTINUE OUTPUTTING
**************
1)70	NOFIND:	SETSTS	F.MTAP,.IOBIN	;[220] CLEAR STATUS & REPORT STRANGE ERROR
1)		WARN$	(UOE,Untraceable output error)
****
2)69	NOFIND:			;Here when no error bits were found in any buffer
2)		OPER$	(XXX,Untraceable Output Error, respond PROCEED or ABORT)
2)		PUSHJ	P,TYI		;[CSM] Get answer
2)		 SKIPA			;[CSM] ABORT
2)		  JRST	NOFND1		;[CSM] Proceed
2)		OUTSTR	[ASCIZ /*ABORT*
2)	"BKPCI7 Stopcode CI7 caused by 'BKPUOE Untraceable Output Error' in BACKUP
2)	?BKPCI7 Aborting job
2)	/]				;[CSM] Double quote to notify OPR if BATCH job
2)		MOVE	T1,[.RCCI7,,0]	;[CSM] *HACK* Cause a crash-dump
2)		DMOVE	P1,@NOTEOT	;[CSM] Get previous status from SAVEP1
2)	S..CI7::RECON.	T1,		;[CSM] New way of causing a CI7 debug STOPCD
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)		  CALLI	0,7		;[CSM] Old way
2)		EXIT			;[CSM] Close the listing file
2)	SAVEP1:	BLOCK	2		;[CSM] Storage for GETSTS data in P1 and P2
2)	NOFND1:	OUTSTR	[ASCIZ /*PROCEED*
2)	/]				;[CSM]
2)		SETSTS	F.MTAP,.IOBIN	;[220] CLEAR STATUS & REPORT STRANGE ERROR
2)		WARN$	(UOE,Untraceable output error)
**************
1)70		POPJ	P,		;RETURN
1)	;+
****
2)69		CSMEDT	02,5	;Watch reel changes, part 5, at MTARST:+6
2)	IFGE CSM02$,< POPJ  P, >	;Don't check for REELID switch here
2)	IFL CSM02$,< PJRST  NVOLCK >	;Check for reel change after each OUT
2)70	SUBTTL	[CSM] Check if MDA switched volumes, and put data into TMP:TAP
2)	IFN CSM02$,<	;Routine to check if new volume is mounted
2)	NVOLCK:	SKIPE	S.LIST##	;Do nothing if not listing
2)		SKIPG	LBTYP		;Is MDA involved?
2)		 POPJ	P,		;No, USER-EOT or BYPASS, we handle volume switch
2)		MOVE	T4,REELID	;Get old REELID
2)		PUSHJ	P,MTARID	;Get current REELID and file number
2)		CAMN	T4,REELID	;Same?
2)		 POPJ	P,		;Yes
2)		MOVEI	T2,F.MTAP	;Channel for tape
2)		DEVNAM	T2,		;MDA may have switched tape drives
2)		  MOVE	T2,UPHYN	;Should not fail
2)		MOVEM	T2,UPHYN	;Get the device name right
2)		AOS	S.NTPE##	;Count this new tape
2)		CSMEDT	04,3	;List 60 lines per page, part 3
2)	IFN CSM04$,<	;Make sure enough room on the page
2)		SKIPL	T1,LINUMB	;Get number of lines left on page
2)		CAIL	T1,6		;At least 6 lines left?
2)		 SKIPA			;OK
2)		  SETZM	LINUMB		;No, cause a formfeed to occur at next LF
2)	>  ;End of IFN CSM04$
2)		MOVEI	T1,[ASCIZ /
2)	Tape switched to volume /]
2)		PUSHJ	P,LSTMSG	;Put in listing
2)		MOVE	T1,REELID	;Get REELID
2)		PUSHJ	P,LST6		;List 6 BIT
2)		MOVEI	T1,[ASCIZ / on /]
2)		PUSHJ	P,LSTMSG	;Put in listing
2)		MOVE	T1,UPHYN	;Get device name
2)		PUSHJ	P,LST6		;List 6 bit
2)		MOVEI	T1,[ASCIZ /   ********************
2)	/]
2)		PUSHJ	P,LSTMSG
2)		MOVEI	T1,[ASCIZ /File /]
2)		PUSHJ	P,LSTMSG
2)		MOVE	T1,CNAM		;Current name
2)		PUSHJ	P,LST6
2)		MOVEI	CH,"."		;Period
2)		PUSHJ	P,LSTOUT
2)		MOVE	T1,CEXT		;Extension
2)		PUSHJ	P,LST6
2)	IFL CSM02$,<	;-1 to check after each block read or written
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)		MOVEI	T1,[ASCIZ / (block=/]
2)		PUSHJ	P,LSTMSG
2)		SKIPLE	T1,THSRDB	;Get relative block number
2)		 PUSHJ	P,LSTDEC	;List if positive
2)		MOVEI	T1,[ASCIZ /)  /]
2)	>  ;End of IFL CSM02$
2)	IFG CSM02$,<	;+1 to check only when starting a new file
2)		MOVEI	T1,[ASCIZ /   /];Three blanks before the path
2)	>  ;End of IFG CSM02$
2)		PUSHJ	P,LSTMSG
2)		PUSHJ	P,LSTFX1	;List the full path and CRLF
2)		PUSHJ	P,LSCRLF	;Blank line
2)		CSMEDT	05,2	;Put REELIDs in TMP:TAP, part 2
2)	IFN CSM05$,<	;Append an "EOV" line to TMPCOR, then a new "VOLUME"
2)		PUSH	P,LSTFLG	;Save old routine
2)		PUSH	P,LINUMB	;Save line counter
2)		MOVEI	T1,LSTTMP	;New address
2)		MOVEM	T1,LSTFLG	;Change list routine
2)		MOVEI	T1,[ASCIZ /EOV:   /]
2)		PUSHJ	P,LSTMSG	;Put in the line identifier
2)		MOVE	T1,LSTSTR	;Get device name
2)		PUSHJ	P,LST6
2)		MOVEI	CH,":"		;Punctuation
2)		PUSHJ	P,LSTOUT
2)		PUSHJ	P,LSTFXP	;List directory (no CRLF)
2)		MOVE	T1,CNAM		;Current name
2)		PUSHJ	P,LST6
2)		MOVEI	CH,"."		;Period
2)		PUSHJ	P,LSTOUT
2)		MOVE	T1,CEXT		;Extension
2)		PUSHJ	P,LST6
2)		PUSHJ	P,LSTFLX	;CRLF
2)		POP	P,LINUMB	;Restore line counter
2)		POP	P,LSTFLG	;Restore old typeout
2)		PUSHJ	P,TMPVOL	;Put this new REELID in TMPBUF
2)	>  ;End of IFN CSM05$
2)	IFN CSM04$,<	;Make sure enough room on the page
2)		SKIPL	T1,LINUMB	;Get number of lines left on page
2)		CAIL	T1,6		;At least 6 lines left?
2)		 SKIPA			;OK
2)		  SETZM	LINUMB		;No, cause a formfeed to occur at next LF
2)		SETOM	NEWPAG		;Force LSTFIL to output full path info
2)	>  ;End of IFN CSM04$
2)		POPJ	P,		;End of NVOLCK
2)	;TMPCOR buffered output routine
2)	IFN CSM05$,<	;Routine to put characters in TMPBUF
2)	LSTTMP:	SOSL	TMPCNT		;If room,
2)		 IDPB	CH,TMPPTR	;Put char in TMPCOR file buffer
2)		POPJ	P,
2)	;Routine to put new REELID in TMPBUF
2)	TMPVOL:	SKIPN	S.LIST##	;Listing?
2)		 POPJ	P,		;No, don't write TMPCOR
2)		PUSH	P,LSTFLG	;Save old routine
2)		PUSH	P,LINUMB	;Save line counter
2)		MOVEI	T1,LSTTMP	;New address
2)		MOVEM	T1,LSTFLG	;Change list routine
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)		MOVEI	T1,[ASCIZ /REELID:/]
2)		PUSHJ	P,LSTMSG	;Put in the line identifier
2)		MOVE	T1,REELID	;Get new REELID
2)		PUSHJ	P,LST6.6	;List all 6 chars
2)		MOVEI	T1,[ASCIZ / FILE:/]
2)		PUSHJ	P,LSTMSG	;Make self-identifying
2)		MOVE	T1,MTFILE	;File number
2)		PUSHJ	P,LSTBTH	;Put in leading zero
2)		PUSHJ	P,LSCRLF	;Finish line
2)		POP	P,LINUMB	;Restore line counter
2)		POP	P,LSTFLG	;Restore old typeout
2)		POPJ	P,		;Return from TMPVOL
2)	>  ;End of IFN CSM05$
2)	>  ;End of IFN CSM02$
2)71	SUBTTL	TAPE INPUT/OUTPUT SUBROUTINES
2)	;+
**************
1)71		CAIGE	T1,EMAX		;SEE IF MAXIMUM REACHED
1)		JRST	CNTINP		;NO, CONTINUE INPUT
****
2)72		CAMGE	T1,S.EMAX##	;[506] See if maximum reached
2)		JRST	CNTINP		;NO, CONTINUE INPUT
**************
1)71	BUFSTS:	MOVE	T1,S.MBPT##	;[257] CURRENT BUFFER ADDRESS
1)		HRLZI	T1,2(T1)	;[257] PLUS TWO
****
2)72	BUFSTS:	CSMEDT	02,6	;Watch reel changes, part 6
2)	IFL CSM02$,< PUSHJ  P,NVOLCK >	;Check for new vol after each IN if neg
2)		MOVE	T1,S.MBPT##	;[257] CURRENT BUFFER ADDRESS
2)		HRLZI	T1,2(T1)	;[257] PLUS TWO
**************
1)74	 
1)		;***TEMP*** CREATE ASCIZ NAME
****
2)75		;***TEMP*** CREATE ASCIZ NAME
**************
1)79		SUBTTL	DISK INPUT/OUTPUT ROUTINES
****
2)80		SUBTTL	TAPE PSI INTERRUPT HANDLING
2)	;[DPM]	Add PSI interrupt to report volume switches in listing
2)	;+
2)	;.CHAPTER TAPE PSI INTERUPT HANDLING
2)	;-
2)	;+
2)	;<MTASER IS THE ROUTINE THAT TAKES REEL SWITCH INTERRUPTS.
2)	;-
2)	MTASER:	PUSH	P,T1		;[DPM] Save temps
2)		PUSH	P,T2
2)		PUSH	P,T3
2)		PUSH	P,T4
2)		CSMEDT	02,X	;Reel changes, part X
2)	IFE CSM02$,<
2)		PUSHJ	P,MTARID	;[DPM] Reed REELID
2)		MOVE	T1,TAPLBL##	;[DPM] Get label type
2)		CAIE	T1,.TFLBP	;[DPM] Bypass?
2)		CAIN	T1,.TFLNV	;[DPM] User-eot?
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)		 JRST	MTASE1		;[DPM] Yes to either -- do things the old way
2)		AOS	S.NTPE##	;[DPM] Increment tape number
2)		PUSHJ	P,LSTRSW	;[DPM] Do listing stuff
2)	>  ;End of IFE CSM02$
2)	IFN CSM02$,<
2)		PUSHJ	P,NVOLCK	;Check for new volume, update TMP:TAP, listing
2)	>  ;End of IFN CSM02$
2)	MTASE1:	POP	P,T4
2)		POP	P,T3		;[DPM] Restore temps
2)		POP	P,T2
2)		POP	P,T1
2)		DEBRK.			;[DPM] Return
2)		  JFCL			;[DPM] Can never happen
2)		  POPJ	P,		;[DPM] Hope we got here via PUSHJ
2)	;+
2)	;<MTARID IS THE ROUTINE THAT READS REELIDS
2)	;-
2)	IFE CSM02$!CSM03$,<	;Get only the REELID
2)	MTARID:	MOVE	T1,[2,,T2]	;[DPM] Set up UUO ac
2)		MOVEI	T2,.TFRID	;[DPM] Function code to read reelid
2)		MOVEI	T3,F.MTAP	;[DPM] Channel number
2)		TAPOP.	T1,		;[DPM] Read reelid
2)		  SKIPA			;[DPM] Can never happen
2)		MOVEM	T1,REELID	;[DPM] Save
2)		POPJ	P,		;[DPM] Return
2)	>  ;End of IFE CSM02$!CSM03$
2)	IFN CSM02$!CSM03$,<	;Get REELID, file number, record number
2)	MTARID:	MOVE	T1,['(NULL)']	;Incase of "/TAPE NUL:"
2)		MOVEM	T1,REELID
2)		MOVEI	T1,^D99		; ...
2)		MOVEM	T1,MTFILE
2)		SKIPE	S.NLDV##	;If using NUL: instead of MTA:,
2)		 POPJ	P,		; return REELID=(NULL)
2)		MOVEI	T1,F.MTAP	;Channel number
2)		MOVEM	T1,MTCBLK+.MTCHN;Store in MTCHR. block
2)		MOVE	T1,[4,,MTCBLK]	;Point to args
2)		MTCHR.	T1,		;Get REELID, file number, record number
2)		  SETOM	REELID		;Should not fail, use SIXBIT/______/ if it does
2)		MOVE	T1,MTFILE	;Get file number
2)		SKIPLE	LBTYP		;If ANSI labels,
2)		 IDIVI	T1,3		; 3 tape marks per user file
2)		ADDI	T1,1		;Return file=1 at BOT
2)		MOVEM	T1,MTFILE	;Save
2)		POPJ	P,              ;Return
2)	>  ;End of IFN CSM02$!CSM03$
2)81		SUBTTL	DISK INPUT/OUTPUT ROUTINES
**************
1)79		PUSHJ	P,OCTOUT	;TYPE STATUS 
1)		OUTSTR	[ASCIZ / during/] ;TELL WHEN
****
2)81		PUSHJ	P,OCTOUT	;TYPE STATUS
2)		OUTSTR	[ASCIZ / during/] ;TELL WHEN
**************
1)80		DEVNAM	T1,		;[263] GET PHYSICAL NAME OF STRUCTURE
1)		 MOVE	T1,[SIXBIT/ALL/]	;[263] NONE--PRETEND IT WAS "ALL"
1)		SETOM	CSTRFL		;[262] SET FLAG FOR "ALL"
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

1)		CAMN	T1,[SIXBIT/ALL/]	;[262] SKIP IF NOT "ALL"
****
2)82		CAMN	T1,[SIXBIT/ALL/];[503] SPECIAL CHECK FOR "ALL"
2)		JRST	SETST2		;[503] NO TRANSLATION NEEDED
2)		MOVEM	T1,DCHARG	;[503] STORE IT
2)		MOVE	T1,[5,,DCHARG]	;[503] SETUP FOR DSKCHR UUO
2)		DSKCHR	T1,		;[503] GET DISK CHARACTERISTICS
2)		 SKIPA	T1,[SIXBIT/ALL/];[503] NONE--PRETEND IT WAS "ALL"
2)		MOVE	T1,DCHARG+.DCSNM;[503] GET PHYSICAL STRUCTURE NAME
2)	SETST2:	SETOM	CSTRFL		;[503][262] SET FLAG FOR "ALL"
2)		CAMN	T1,[SIXBIT/ALL/]	;[262] SKIP IF NOT "ALL"
**************
1)82	LSTOUT:	SOSG	S.LBPT##+.BFCTR	;SEE IF ANY ROOM LEFT
1)		OUTPUT	F.LIST,		;NONE. ADVANCE BUFFERS
1)		IDPB	CH,S.LBPT##+.BFPTR;STORE CHARACTER
1)		POPJ	P,		;RETURN
1)	;+
****
2)84	LSTOUT:	CSMEDT	05,3	;Put REELIDs in TMP:TAP, part 3
2)	IFN CSM05$,<	;Output to list file if not told to do otherwise
2)		SKIPE	LSTFLG		;Is there an output routine specified?
2)		 PJRST	@LSTFLG		;Yes, go to it
2)	>  ;End of IFN CSM05$
2)		SOSG	S.LBPT##+.BFCTR	;SEE IF ANY ROOM LEFT
2)		OUTPUT	F.LIST,		;NONE. ADVANCE BUFFERS
2)		IDPB	CH,S.LBPT##+.BFPTR;STORE CHARACTER
2)		CSMEDT	04,4	;List 60 lines per page, part 4
2)	IFN CSM04$,<	;Output header when LINUMB is zero or +1
2)			;Do not output header on TTY: when LINUMB is -1
2)		CAIE	CH,.CHLFD	;Linefeed?
2)		 POPJ	P,		;Just continue
2)		SOSLE	CH,LINUMB	;Yes, decrement line number
2)		 JRST	CSM04Y		;Not time for a formfeed, restore CH
2)		AOJL	CH,[SETOM  LINUMB	;Reset to -1 for no headers
2)			    OUTPUT F.LIST,	;Dump buffers after each LF when
2)			    JRST   CSM04Y ]	; output is to TTY
2)		MOVEI	CH,^D60		;Reset counter
2)		MOVEM	CH,LINUMB	; for 60 lines per page
2)		SETOM	NEWPAG		;Force LSTFIL to output full path info
2)	IFE CSM04$&<2!4>,<	;If only putting in FF every 60 lines
2)		MOVEI	CH,.CHFFD	;Replace 60th LF with FF
2)		DPB	CH,S.LBPT##+.BFPTR
2)	CSM04Y:	MOVEI	CH,.CHLFD	;Restore CH
2)		POPJ	P,		;Return
2)	>  ;End of IFE 2!4
2)	IFN CSM04$&<2!4>,<	;If putting on headers
2)		SAVE$	<T1,T2,T3,T4>	;Save temp regs
2)	IFN CSM04$&4,< PUSHJ  P,VOLFIL > ;Output REELID and date at bottom
2)		MOVEI	CH,.CHFFD	;Replace 60th LF with FF
2)		DPB	CH,S.LBPT##+.BFPTR
2)		PUSHJ	P,LSTHDR	;Do the header (LINUMB gets set to 58)
2)		RSTR$	<T4,T3,T2,T1>	;Restore temps
2)	CSM04Y:	MOVEI	CH,.CHLFD	;Restore CH
2)		POPJ	P,		;Return
2)	;Routine to output SSNAME and page number at top of page,
2)	;with REELID, tape number, file number, and date on 2nd line.
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)	LSTHDR:	MOVEI	T1,[ASCIZ /Save-set-name "/]
2)		PUSHJ	P,LSTMSG
2)		MOVEI	T1,S.SSNM##	;Output saveset name
2)		PUSHJ	P,LSTMSG
2)		MOVEI	T1,[ASCIZ /"		Page /]
2)		PUSHJ	P,LSTMSG
2)		AOS	T1,PAGNUM	;Get current page number
2)		PUSHJ	P,LSTDEC
2)		PUSHJ	P,LSCRLF	;Finish line
2)	IFN CSM04$&2,< PUSHJ  P,VOLFIL >;Put REELID on 2nd line of page
2)		POPJ	P,
2)	;--- BACK01 --- Tape 1, File 2 --- 10-Jun-81 Wednesday ---
2)	VOLFIL:	MOVE	T4,REELID	;Save in case it changes
2)		PUSHJ	P,MTARID	;Get REELID and file number
2)		MOVEI	T1,[ASCIZ /--- /]
2)		PUSHJ	P,LSTMSG	;Output separator
2)		MOVE	T1,REELID	;Current volume-ID
2)		MOVEM	T4,REELID	;Restore old one for NVOLCK to find
2)		PUSHJ	P,LST6
2)		MOVEI	T1,[ASCIZ / --- Tape /]
2)		PUSHJ	P,LSTMSG
2)		MOVE	T1,S.NTPE##	;Tape number
2)		PUSHJ	P,LSTDEC
2)		MOVEI	T1,[ASCIZ /, File /]
2)		PUSHJ	P,LSTMSG
2)		MOVE	T1,MTFILE	;Get file nubmer
2)		PUSHJ	P,LSTDEC
2)		MOVEI	T1,[ASCIZ / --- /]
2)		PUSHJ	P,LSTMSG
2)		MOVX	T1,%CNDTM	;Get the universal date/time
2)		GETTAB	T1,
2)		  JFCL			;Can never fail
2)		PUSHJ	P,LSTWEK	;List date and day of week
2)		MOVEI	T1,[ASCIZ / ---
2)	/]				;Entire message fits within 64 columns
2)		PJRST	LSTMSG		;Finish line and return
2)	>  ;End of IFN 2!4
2)	>  ;End of IFN CSM04$
2)		CSMEDT	01,1	;Narrow listing, part 1
2)	IFN CSM01$,<
2)	;Output 3 SIXBIT chars, even if all blanks
2)	LST6.6:	SKIPA	T3,[6]		;Do 6 chars
2)	LST6.3:	MOVEI	T3,3		;Do 3 chars
2)		MOVE	T2,T1		;Copy arg
2)	LST6.0:	MOVEI	T1,0		;Clear junk
2)		LSHC	T1,6		;Get a char
2)		MOVEI	CH," "-' '(T1)	;Convert to ASCII in CH
2)		PUSHJ	P,LSTOUT	;Send to file
2)		SOJG	T3,LST6.0	;Loop for all
2)		POPJ	P,		;Return
2)	;Output decimal number with leading spaces
2)	LST6DG:	CAIGE	T1,^D100000	;6 digit number?
2)		 PUSHJ	P,LSTSPC	;No, list a space
2)	LST5DG:	CAIGE	T1,^D10000	;5 digits
2)		 PUSHJ	P,LSTSPC
2)	LST4DG:	CAIGE	T1,^D1000	;4 digits
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)		 PUSHJ	P,LSTSPC
2)	LST3DG:	CAIGE	T1,^D100	;3 digits
2)		 PUSHJ	P,LSTSPC
2)	LST2DG:	CAIGE	T1,^D10		;2 digits
2)		 PUSHJ	P,LSTSPC
2)		JRST	LSTDEC		;List decimal number
2)	;Routine to output date in T1 as "dd-Mmm-yy Weekday "
2)	LSTWEK:	PUSH	P,T1		;Save UDT
2)		PUSHJ	P,CONTDT	;Convert to DEC format
2)		MOVE	T1,T2		;Get 15 bit date
2)		PUSHJ	P,LSTDAT	;Output date in 10-Jun-81 format
2)		PUSHJ	P,LSTSPC	;Output a space
2)		POP	P,T1		;Get back UDT
2)		HLRZS	T1		;Keep only the date portion
2)		IDIVI	T1,7		;Get day of week
2)		MOVE	T1,WEEKDA(T2)	;Point to string
2)		PJRST	LSTMSG		;Output it and return
2)	WEEKDA:	[ASCIZ	/Wednesday/]
2)		[ASCIZ	/Thursday/]
2)		[ASCIZ	/Friday/]
2)		[ASCIZ	/Saturday/]
2)		[ASCIZ	/Sunday/]
2)		[ASCIZ	/Monday/]
2)		[ASCIZ	/Tuesday/]
2)	;Output a space to listing file
2)	LSTSPC:	MOVEI	CH," "		;Get a space
2)		JRST	LSTOUT
2)	;Output CRLF to listing file
2)	LSCRLF:	MOVEI	T1,CRLF		;Point to string and fall into LSTMSG
2)	>  ;End of IFN CSM01$
2)	;+
**************
1)83	;<LSTBTH LISTS TWO DIGITS OF THE DECIMAL NUMBER IN ^T1, WITH A 
1)	;LEADING ZERO IF LESS THAN TEN.
****
2)85	;<LSTBTH LISTS TWO DIGITS OF THE DECIMAL NUMBER IN ^T1, WITH A
2)	;LEADING ZERO IF LESS THAN TEN.
**************
1)85	;<LSTXXX IS A SUBROUTINE TO LIST THE START/END OF SAVE SET INFORMATION.
****
2)87	;<LSTRSW IS A SUBROUTINE TO LIST DATA AFTER REEL SWITCHES ON LABELLED TAPES
2)	;-
2)	;[DPM]	Add PSI interrupt to report volume switches in listing
2)	LSTRSW:	SKIPN	S.LIST##	;[DPM] Want listing?
2)		 POPJ	P,		;[DPM] No
2)		MOVEI	CH,14		;[DPM] Get a form-feed
2)		MOVEI	T1,F.LIST	;[DPM] Listing channel
2)		DEVCHR	T1,		;[DPM] Get characteristics
2)		TXNN	T1,DV.TTY	;[DPM] Is dev a TTY?
2)		 PUSHJ	P,LSTOUT	;[DPM] No, start a new page
2)		MOVEI	T1,[ASCIZ /
2)	**********************************************************************
2)	Continuation on /]
2)		PUSHJ	P,LSTMSG	;[DPM] Send to file
2)		MOVEI	T1,F.MTAP	;[DPM] Get channel
2)		DEVNAM	T1,		;[DPM]  and name
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)		  MOVSI	T1,'???'	;[DPM]
2)		PUSHJ	P,LST6		;[DPM]
2)		MOVEI	T1,[ASCIZ /, reelid /] ;[CSM] Use word instead of space
2)		PUSHJ	P,LSTMSG	;[CSM]
2)		MOVE	T1,REELID	;[DPM]
2)		PUSHJ	P,LST6		;[DPM]
2)		MOVEI	T1,[ASCIZ /, tape number /]
2)		PUSHJ	P,LSTMSG	;[DPM]
2)		MOVE	T1,S.NTPE##	;[DPM]
2)		PUSHJ	P,LSTDEC	;[DPM]
2)		MOVEI	T1,[ASCIZ /
2)	**********************************************************************
2)	/]				;[DPM]
2)		PJRST	LSTMSG		;[DPM] List and return
2)	;+
2)	;<LSTXXX IS A SUBROUTINE TO LIST THE START/END OF SAVE SET INFORMATION.
**************
1)85		MOVEI	CH," "		;SPACE
1)		PUSHJ	P,LSTOUT	;SEND
1)		MOVE	T1,S$RLNM(MH)	;GET REELID
1)		PUSHJ	P,LST6		;SEND
1)86	;HERE TO LIST THE SECOND LINE OF THE SAVE SET HEADER
1)		MOVEI	T1,[ASCIZ /
1)	System /]
1)		PUSHJ	P,LSTMSG	; ..
****
2)87		MOVEI	T1,[ASCIZ / reelid /] ;[CSM] Use this after tape device
2)		PUSHJ	P,LSTMSG	     ;[CSM]  instead of space
2)		MOVE	T1,S$RLNM(MH)	;GET REELID
2)		PUSHJ	P,LST6		;SEND
2)88	;HERE TO LIST THE SECOND LINE OF THE SAVE SET HEADER
2)		MOVEI	T1,[ASCIZ /
2)	System /]
2)		CSMEDT	01,2	;Narrow listing, part 2, before LSTSYS:
2)	IFN CSM01$,<
2)		SKIPE	S.NARL##	;Narrow listing?
2)		 MOVEI	T1,CRLF		;Yes, must keep within 64 columns
2)	>  ;End of IFN CSM01$
2)		PUSHJ	P,LSTMSG	; ..
**************
1)87		MOVEI	T1,[ASCIZ / tape format /] ; ..
1)		PUSHJ	P,LSTMSG	; ..
****
2)89		MOVEI	T1,[ASCIZ / tape format /]
2)	IFN CSM01$,<
2)		SKIPE	S.NARL##	;If narrow listing,
2)		MOVEI	T1,[ASCIZ / format /] ;fit within 64 cols
2)	>  ;End of IFN CSM01$
2)		PUSHJ	P,LSTMSG	; ..
**************
1)88		MOVEI	CH,"A"-1(T1)	;GET UPDATE LETTER
1)		PUSHJ	P,LSTOUT	;SEND TO FILE
1)	NMINOR:	LDB	T1,[POINTR (P1,VR.EDT)] ;GET EDIT VERSION
****
2)90		SOS	T1		;[505] PRINT IN MODIFIED
2)		IDIVI	T1,^D26		;[505] RADIX 26 ALPHA
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)		JUMPE	T1,LSTVE1	;[505] JUMP IF ONE CHARACTER
2)		MOVEI	CH,"A"-1(T1)	;GET UPDATE LETTER
2)		PUSHJ	P,LSTOUT	;SEND TO FILE
2)	LSTVE1:	MOVEI	CH,"A"(T2)	;[505] ISSUE "UNITS"
2)		PUSHJ	P,LSTOUT	;[505] CHARACTER
2)	NMINOR:	LDB	T1,[POINTR (P1,VR.EDT)] ;GET EDIT VERSION
**************
1)89		HRLZI	T2,-.FXLND	;[366] START AT UFD LEVEL AT LSTPTH
****
2)91		CSMEDT	04,5	;List 60 lines per page, part 5
2)	IFN CSM04$,<	;Output full str path at top of each page
2)		AOSG	NEWPAG		;Was flag set to -1?
2)		 JRST	DIFF		;Yes
2)	>  ;End of IFN CSM04$
2)		HRLZI	T2,-.FXLND	;[366] START AT UFD LEVEL AT LSTPTH
**************
1)90	;HERE TO LIST INDIVIDUAL FILE IDENTIFIERS
****
2)91	        CSMEDT	01,3	;Narrow listing, part 3, at DIFF:+12
2)	IFN CSM01$,<    ;Listing is not wide enough for path on same line
2)		SKIPN	S.NARL##	;If not narrow listing,
2)		 JRST	LSTFID		; put path after file name
2)		MOVNI	T1,5		;Check all 5 SFDs
2)		SKIPE	LSTPTH+6(T1)	;Find end of path
2)		 AOJL	T1,.-1		;Not blank, try next
2)		CAMN	T1,[-5]		;UFD only?
2)		 MOVNI	T1,4		;Yes, do 4 tabs instead of 5
2)		PUSHJ	P,LSTTAB	;Output at least 1 tab
2)		 AOJL	T1,.-1		;Max line length here is 64 characters
2)		PUSHJ	P,LSTFX1	;Output the path on a separate line
2)	>  ;End of IFN CSM01$
2)92	;HERE TO LIST INDIVIDUAL FILE IDENTIFIERS
**************
1)90		PUSHJ	P,LST6		;SEND TO FILE
1)		PUSHJ	P,LSTTAB	;TAB OVER
1)		MOVE	T1,A$LENG(P1)	;GET SIZE IN BYTES
1)		MOVE	T2,A$MODE(P1)	;GET FILE MODE
1)		CAIG	T2,.IOASL	;SEE IF ASCII
1)		IDIVI	T1,5		;GET SIZE IN WORDS
1)		ADDI	T1,177		;FORCE OVERFLOW
1)		ASH	T1,-7		;COMPUTE SIZE IN BLOCKS
1)		PUSHJ	P,LSTDEC	;SEND TO FILE
1)		PUSHJ	P,LSTTAB	;TAB OVER
1)		SKIPE	A$PROT(P1)	;SEE IF NO PROTECTION ON TAPE,
****
2)92		CSMEDT	01,4	;Narrow listing, part 4, at LSTFID:+11
2)	IFE CSM01$,<
2)		PUSHJ	P,LST6		;SEND TO FILE
2)		PUSHJ	P,LSTTAB	;TAB OVER
2)	>  ;End of IFE CSM01$
2)	IFN CSM01$,< PUSHJ  P,LST6.3 >	;Send 3 blanks if necessary
2)	;**;[513] @LSTFID+14L, Replace 4L, BAH, 4-Mar-83
2)		MOVEI	T2,^D36		;[513] WIDTH OF WORD IN BITS
2)		IDIV	T2,A$BSIZ(P1)	;[513] GET BYTES PER WORD
2)		SKIPGE	T1,A$LENG(P1)	;[513] LENGTH OF FILE IN BYTES
2)		MOVEI	T2,1		;[513] IF OVERFLOW, KILL DIVISOR
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)		IDIV	T1,T2		;[513] FILE LENGTH IN WORDS
2)		SKIPE	T2		;[513] EXTRA BYTES?
2)		AOS	T1		;[513] YES. ONE MORE WORD
2)		ADDI	T1,177		;FORCE OVERFLOW
2)		ASH	T1,-7		;COMPUTE SIZE IN BLOCKS
2)	IFE CSM01$,<	;Numbers are not justified in standard BACKUP
2)		PUSHJ	P,LSTDEC	;SEND TO FILE
2)		PUSHJ	P,LSTTAB	;TAB OVER
2)	>  ;End of IFE CSM01$
2)	IFN CSM01$,<	;Make narrower columns line up
2)		PUSHJ	P,LST6DG	;List 6 digits with leading spaces
2)		PUSHJ	P,LSTSPC	;And 1 space between size and prot
2)	>  ;End of IFN CSM01$
2)		SKIPE	A$PROT(P1)	;SEE IF NO PROTECTION ON TAPE,
**************
1)90		JUMPE	P2,LSTFLX	;BRANCH IF NO STR-PATH CHANGE
1)		SKIPE	S.INTR##	;SEE IF /INTERCHANGE
1)		JRST	LSTFLX		;SKIP PATH INFO IF SO
1)	;HERE TO LIST THE FULL FILE PATH
1)		PUSHJ	P,LSTTAB	;TAB OVER
1)		MOVE	T1,LSTSTR	;GET STR NAME
1)		PUSHJ	P,LST6		;SEND TO FILE
1)		MOVEI	CH,":"		;END OF STR
1)		PUSHJ	P,LSTOUT	;SEND TO FILE
1)		PUSHJ	P,LSTTAB	;TAB OVER
1)		MOVEI	CH,"["		;START OF PATH
****
2)92		PUSHJ	P,LSTTAB	;[512] Adjust listing
2)		PUSH	P,P1		;[512] Save P1
2)		SKIPE	P1,A$VERS(P1)	;[512] Is there a version number?
2)		 PUSHJ	P,LSTVER	;[512] Yes, go list it
2)		POP	P,P1		;[512] Restore P1
2)		JUMPE	P2,LSTFLX	;BRANCH IF NO STR-PATH CHANGE
2)	IFN CSM01$,< SKIPN  S.NARL## >	;Path already output for narrow listing
2)		SKIPE	S.INTR##	;SEE IF /INTERCHANGE
2)		JRST	LSTFLX		;SKIP PATH INFO IF SO
2)	;HERE TO LIST THE FULL FILE PATH
2)		PUSHJ	P,LSTTAB	;TAB OVER
2)	LSTFX1:	MOVE	T1,LSTSTR	;GET STR NAME
2)		PUSHJ	P,LST6		;SEND TO FILE
2)		MOVEI	CH,":"		;END OF STR
2)		PUSHJ	P,LSTOUT	;SEND TO FILE
2)	IFE CSM01$,< PUSHJ  P,LSTTAB >	;TAB OVER
2)	IFN CSM01$,< PUSHJ  P,LSTSPC >	;One space
2)	LSTFX2:
2)	IFN CSM05$,<
2)		PUSHJ	P,LSTFXP	;List path with no CRLF
2)		PJRST	LSTFLX		;Finish line
2)	LSTFXP:	>  ;End of IFN CSM05$
2)		MOVEI	CH,"["		;START OF PATH
**************
1)90		PUSHJ	P,LSTOUT	;SEND TO FILE
1)	LSTFLX:	MOVEI	T1,CRLF		;<CR><LF>
****
2)92	IFE CSM05$,<PUSHJ  P,LSTOUT>	;SEND TO FILE
2)	IFN CSM05$,<PJRST  LSTOUT>	;No CRLF
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)	LSTFLX:	MOVEI	T1,CRLF		;<CR><LF>
**************
1)92					;T1=DAYS SINCE JAN 1, 1501	 
1)		IDIVI	T1,400*365+400/4-400/100+400/400
1)					;SPLIT INTO QUADRACENTURY	 
1)		LSH	T2,2		;CONVERT TO NUMBER OF QUARTER DAYS   
1)		IDIVI	T2,<100*365+100/4-100/100>*4+400/400
1)					;SPLIT INTO CENTURY		 
1)		IORI	T3,3		;DISCARD FRACTIONS OF DAY	 
1)		IDIVI	T3,4*365+1	;SEPARATE INTO YEARS		 
1)		LSH	T4,-2		;T4=NO DAYS THIS YEAR		 
1)		LSH	T1,2		;T1=4*NO QUADRACENTURIES	 
1)		ADD	T1,T2		;T1=NO CENTURIES		 
1)		IMULI	T1,100		;T1=100*NO CENTURIES		 
1)		ADDI	T1,1501(T3)	;T1 HAS YEAR, T4 HAS DAY IN YEAR	 
1)		MOVE	T2,T1		;COPY YEAR TO SEE IF LEAP YEAR
1)		TRNE	T2,3		;IS THE YEAR A MULT OF 4?	 
1)		JRST	CNTDT0		;NO--JUST INDICATE NOT A LEAP YEAR   
1)		IDIVI	T2,100		;SEE IF YEAR IS MULT OF 100	 
1)		SKIPN	T3		;IF NOT, THEN LEAP		 
1)		TRNN	T2,3		;IS YEAR MULT OF 400?		 
1)		TDZA	T3,T3		;YES--LEAP YEAR AFTER ALL	 
1)	CNTDT0:	MOVEI	T3,1		;SET LEAP YEAR FLAG		 
1)					;T3 IS 0 IF LEAP YEAR
****
2)94					;T1=DAYS SINCE JAN 1, 1501	
2)		IDIVI	T1,400*365+400/4-400/100+400/400
2)					;SPLIT INTO QUADRACENTURY	
2)		LSH	T2,2		;CONVERT TO NUMBER OF QUARTER DAYS
2)		IDIVI	T2,<100*365+100/4-100/100>*4+400/400
2)					;SPLIT INTO CENTURY		
2)		IORI	T3,3		;DISCARD FRACTIONS OF DAY	
2)		IDIVI	T3,4*365+1	;SEPARATE INTO YEARS		
2)		LSH	T4,-2		;T4=NO DAYS THIS YEAR		
2)		LSH	T1,2		;T1=4*NO QUADRACENTURIES	
2)		ADD	T1,T2		;T1=NO CENTURIES		
2)		IMULI	T1,100		;T1=100*NO CENTURIES		
2)		ADDI	T1,1501(T3)	;T1 HAS YEAR, T4 HAS DAY IN YEAR	
2)		MOVE	T2,T1		;COPY YEAR TO SEE IF LEAP YEAR
2)		TRNE	T2,3		;IS THE YEAR A MULT OF 4?	
2)		JRST	CNTDT0		;NO--JUST INDICATE NOT A LEAP YEAR
2)		IDIVI	T2,100		;SEE IF YEAR IS MULT OF 100	
2)		SKIPN	T3		;IF NOT, THEN LEAP		
2)		TRNN	T2,3		;IS YEAR MULT OF 400?		
2)		TDZA	T3,T3		;YES--LEAP YEAR AFTER ALL	
2)	CNTDT0:	MOVEI	T3,1		;SET LEAP YEAR FLAG		
2)					;T3 IS 0 IF LEAP YEAR
**************
1)102		MONRT.			;[402] DONE FOR
****
2)104		  OUTSTR [ASCIZ /"Error in BACKUP, please check the tape drives
2)	/]				;[CSM]
2)		  MOVEI	T1,^D60		;[CSM] Sleep for 1 minute
2)		  SLEEP	T1,		;[CSM]
2)		  OUTSTR [ASCIZ /"Make a note as to whether the drive is off-line
2)	/]				;[CSM]
File 1)	DSK:BACKRS.MAC[10,7,BACKUP] 	created: 0856 27-Sep-83
File 2)	DSK:BACKRS.MAC[10,10,BACKUP]	created: 1606 08-Jan-85

2)		  SLEEP	T1,		;[CSM]
2)		MONRT.			;[402] DONE FOR
**************
1)104		END		;&.SKIP2;[^END OF <BACKRS.PLM]
****
2)106	LITS:	END		;&.SKIP2;[^END OF <BACKRS.PLM]
**************
  T@ bI
File 1)	DSK:SSPRAM.OLD	created: 1628 18-Sep-85
File 2)	DSK:SSPRAM.MAC	created: 1627 18-Sep-85

1)1	%NODSIZE==3*^D128	;LENGTH OF NODE BUFFER
****
2)1	%NODMAX==7777	;Number of nodes in TYMNET
2)	%NODSIZE==3*^D128	;LENGTH OF NODE BUFFER
**************
   File 1)	DSK:SYSCOM.OLD	created: 1628 18-Sep-85
File 2)	DSK:SYSCOM.MAC	created: 1627 18-Sep-85

1)1	        EXTERN  NODIOWD ;IOWD FOR READING NODES.MAP (SSLOW)
1)	;  EXTERNAL LOCATIONS
1)		EXTERN	DBLOCK,DET,DIO,FONE	;(SSLOW)
****
2)1		EXTERN	TYPNOD	;Routine to output node name (SSIO)
2)	;  EXTERNAL LOCATIONS
2)		EXTERN	NODIOWD ;IOWD FOR READING NODES.MAP (SSLOW)
2)		EXTERN	DBLOCK,DET,DIO,FONE	;(SSLOW)
**************
1)1		LDB	NODE,[POINT 6,INFO,27]
1)		LDB	NODE1,[POINT 6,INFO,19]
1)		DPB	NODE1,[POINT 6,NODE,29]
1)	        JRST    WRNODE          ;FIND NODE NAME
1)	; SEARCH FOR VALID NODE IN %NODBUFF
1)	; THREE WORD E NTRIES ARE:
1)	;    1: NUMBER OF NODE
1)	;  2,3: NODE NAME IN 7-BIT WITH A NULL
1)	WFNODE: USETI   NOD,1           ;START AT BEGINNING OF FILE
1)	WNNODE: IN      NOD,NODIOWD     ;READ 3 BLOCKS OF FILE
1)	        SKIPA                   ;NO ERRORS
1)	        JRST    WHR3Z           ;IF ERROR, GIVE UP
1)	WRNODE: CAMGE   NODE,%NODBUFF   ;HAVE CORRECT BLOCKS?
1)	        JRST    WFNODE          ;IF NOT, RETURN TO BEGINNING
1)	        CAMLE   NODE,%NODBUFF+^D381 ;CHECK END OF BLOCK
1)	        JRST    WNNODE          ;MUST GET NEXT 3 BLOCKS
1)		SETZ	N1,		;INDEX
1)	        MOVEI   M,3000          ;SEARCH THROUGH NODBUFF
1)	W1NODE:	CAMN	NODE,%NODBUFF(N1) ;COMPARE?
1)		JRST	W2NODE		;YES, OKAY.
1)	        CAMG    M,%NODBUFF(N1)  ;END OF SEARCH?
1)		JRST	WHR3Z		;YES, GIVE UP.
1)		ADDI	N1,3		;TO NEXT 3-WORD ENTRY
1)		JRST	W1NODE		;LOOP
1)	; HERE WHEN NODE FOUND
1)	W2NODE:	MOVEI	M,%NODBUFF+1(N1) ; ADR OF NODE NAME
1)	WHR3G:	PUSHJ	P,MSG
1)		MOVEI	M,[ASCIZ / #/]
****
2)1		PUSHJ	P,TYPNOD	;Output node name
2)		MOVEI	M,[ASCIZ / #/]
**************
1)1	;HERE WHEN NODE NOT FOUND IN THE TABLE
1)	WHR3Z:	MOVEI	M,[ASCIZ /*/]	;PRINT **NODE#**
1)		PUSHJ	P,MSG		;PRINT IT.
1)		MOVEI	R,^O10		;OCTAL RADIX
1)		PUSHJ	P,RDXN	;PRINT NODE #
1)		MOVEI	M,[ASCIZ /*/]	;SECOND SET OF **
1)		JRST	WHR3G		;AND FINISH PRINT-OUT
1)	;HERE TO SEE IF THE LUSER IS FROM A GFD
****
2)1	;HERE TO SEE IF THE LUSER IS FROM A GFD
**************
 File 1)	DSK:SSIO.OLD	created: 1628 18-Sep-85
File 2)	DSK:SSIO.MAC	created: 1810 18-Sep-85

1)1		EXTERN 	DSKUSE	;SWAPPING SPACE USED (SSLOW)
1)		EXTERN	DULOPN	;ONES IF DUL OPEN ON DUL CHANNEDL (SSLOW)
****
2)1		EXTERN	DSKUSE	;SWAPPING SPACE USED (SSLOW)
2)		EXTERN	DULOPN	;ONES IF DUL OPEN ON DUL CHANNEDL (SSLOW)
**************
1)1		EXTERN 	LQTAB	;LENGTH OF QTAB (SSLOW)
1)		EXTERN	LUDOPN	;ONES IF LUD OPEN ON LUD CHANNEL (SSLOW)
1)		EXTERN	MEMNSP	;CORE SPEED (SSLOW)
1)		EXTERN 	MESPC	;USERNAME PRINTING SWITCH (SSLOW)
1)		EXTERN	NOW	;CURRENT TIME (SSLOW)
****
2)1		EXTERN	LQTAB	;LENGTH OF QTAB (SSLOW)
2)		EXTERN	LUDOPN	; ONES IF LUD OPEN ON LUD CHANNEL (SSLOW)
2)		EXTERN	MEMNSP	;CORE SPEED (SSLOW)
2)		EXTERN	MESPC	;USERNAME PRINTING SWITCH (SSLOW)
2)		EXTERN	NOW	;CURRENT TIME (SSLOW)
**************
1)1	;  THE FOLLOWING ARE ALL IN SSLOW
****
2)1		EXTERN	%NODBUFF,NODIOWD ;Buffer for reading (TYMNET)NODES.MAP in SSLOW
2)	;  THE FOLLOWING ARE ALL IN SSLOW
**************
1)4		POPJ	P,		;RETURN 
1)	;FIELD2 - HERE WHEN EXACTLY AT POSITION
****
2)4		POPJ	P,		;RETURN
2)	;FIELD2 - HERE WHEN EXACTLY AT POSITION
**************
1)20	;  CONSTANTS
1)	COM:	IOWD	LN.BUF,BUF	;FOR READING DUL.
****
2)21	SUBTTL	TYPNOD - Output node info
2)		ENTRY	TYPNOD		;Call with word in INFO
2)	TYPNOD:	LDB	NODE,[POINT 6,INFO,27]	;6 low-order bits
2)		LDB	NODE1,[POINT 6,INFO,19]	;6 high-order bits
2)		DPB	NODE1,[POINT 6,NODE,29]	;Combine 12 bits
2)		PUSHJ	P,FNDNOD	;Find node name
2)		  JRST	TYPND1		;Not there
2)	TYPND2:	PUSHJ	P,MSG		;M points to ASCIZ name
2)		POPJ	P,		;End of TYPNOD
2)	;Here when node not found in the table - print "**7777**" for node 7777
2)	TYPND1:	MOVEI	M,[ASCIZ /**/]	;Output first 2 asterisks
2)		PUSHJ	P,MSG
2)		MOVEI	R,^O10		;Octal radix
2)		PUSHJ	P,RDXN		;Print node #
2)		MOVEI	M,[ASCIZ /**/]	;Second set of **
2)		JRST	TYPND2
2)	; Search for valid node in %NODBUFF - (TYMNET)NODES.MAP
2)	; Assumes nonzero node numbers are monotonically increasing (can have gaps).
2)	; Does not assume that node N is at word 3*N in file (which is possible).
2)	;  Three words per entry:
2)	;    1: Number of node
2)	;  2,3: Up to 10 ASCII characters of node name
2)	FNDNOD:	HRRZS	(P)		;Clear pass-2 flag
2)	FNODE:	MOVEI	N1,0		;Start at beginning of buffer
File 1)	DSK:SSIO.OLD	created: 1628 18-Sep-85
File 2)	DSK:SSIO.MAC	created: 1810 18-Sep-85

2)	FNODE2:	CAMN	NODE,%NODBUF(N1);BUFFER .EQ. NODE ?
2)		 JRST	FNODOK		;Yes, found it
2)		CAMG	NODE,%NODBUF(N1);Gotten to the right spot in the buffer yet?
2)		 JRST	FNODE0		;Oops, missed it.  Try again from the beginning
2)		ADDI	N1,3		;Point to next entry
2)		CAIL	N1,%NODSIZE	;End of table?
2)		 JRST	FNODE1		;Yes, try next 3 blocks
2)		JRST	FNODE2
2)	;Go back to beginning if too far into the file
2)	FNODE0:	SKIPGE	(P)		;If been here already,
2)		 POPJ	P,		; give up.  Node is not mentioned in file
2)		USETI	NOD,1		;Go back to the beginning of the file
2)		HRROS	(P)		;Set flag saying file has been rewound
2)	;Get next record of 3 blocks
2)	FNODE1:	IN	NOD,NODIOWD	;Read 3 blocks of file
2)		  JRST	FNODE		;No errors
2)		SKIPGE	(P)		;If EOF and already tried USETI once,
2)		 POPJ	P,		; give up.  Node is not at end of file
2)		JRST	FNODE0		;Otherwise rewind and try one more pass
2)	;Here when node found
2)	FNODOK:	MOVEI	M,%NODBUFF+1(N1);Get address of 9 character node name
2)		SKIPE	(M)		;If name is nonzero,
2)		 AOS	(P)		; success return
2)		POPJ	P,		;End of FNDNOD
2)22	SUBTTL	CONSTANTS
2)	COM:	IOWD	LN.BUF,BUF	;FOR READING DUL.
**************
    File 1)	DSK:JOBSTT.OLD	created: 1628 18-Sep-85
File 2)	DSK:JOBSTT.MAC	created: 1627 18-Sep-85

1)1	;  EXTERNAL LOCATIONS
****
2)1		EXTERN	TYPNOD	;Output name of node (SSIO)
2)	;  EXTERNAL LOCATIONS
**************
1)1	        LDB     NODE,[POINT 6,INFO,27]  ;GET 1ST PART OF NODE #
1)	        LDB     NODE1,[POINT 6,INFO,19] ;GET 2ND PART OF NODE #
1)	        DPB     NODE1,[POINT 6,NODE,29] ;PUT 2ND PART WITH 1ST
1)	        JRST    SRNODE          ;GO SEARCH FOR NODE NAME.
1)	; SEARCH FOR A NODE
1)	; THREE WORD ENTRIES IN %NODBUFF
1)	;   1:NUMBER OF NODE
1)	; 2,3:7-BIT ASCII
1)	;  PRESENTLY, 3000 IS HIGHEST LEGAL NODE  #.
1)	;  NODES.MAP FILE TO BE CHANGED TO FLAG LAST ENTRY.
1)	;
1)	RFNODE: USETI   NOD,1           ;RESET TO BEGINNING OF FILE.
1)	RNNODE: IN      NOD,NODIOWD     ;READ NEXT 3 BLOCKS OF NODE FILE.
1)	        SKIPA                   ;THIS IS NORMAL RETURN.
1)	        JRST    ILNODE          ;IF FAILED, TREAT AS NOT FOUND.
1)	SRNODE: CAMGE   NODE,%NODBUFF   ;HAVE WE THE CORRECT BLOCKS OF NODE FILE?
1)	        JRST    RFNODE          ;NO -- BACK TO BEGINNING.
1)	        CAMLE   NODE,%NODBUFF+^D381     ;CHECK END OF BLOCK.
1)	        JRST    RNNODE          ;MUST GET NEXT 3 BLOCKS.
1)	        SETZ    N1,             ;SET UP INDEX ON %NODBUFF.
1)	        MOVEI   M,3000          ;SEARCH THROUGH %NODBUFF FOR NODE #.
1)	SNODE:  CAMN    NODE,%NODBUFF(N1)       ;COMPARE WITH CURRENT ENTRY.
1)	        JRST    FNODE           ;FOUND IT.
1)	        CAMG    M,%NODBUFF(N1)  ;ARE WE AT THE END OF NODE MAP?
1)	        JRST    ILNODE          ;YES -- GIVE UP SEARCH.
1)	        ADDI    N1,3            ;TO NEXT ENTRY
1)	        JRST    SNODE           ;KEEP ON SEARCHING
1)	;HERE ON ILLEGAL NODE
1)	ILNODE: MOVEI   M,[ASCIZ /*/]   ;TYPE **NODE#**
1)	        PUSHJ   P,MSG           ;TYPE THE FIRST PART, **
1)	        MOVEI   R,^O10          ;RADIX OCTAL
1)	        PUSHJ   P,RDXN  ;PRINT NODE NUMBER
1)	        MOVEI   M,[ASCIZ /*/]   ;TYPE THE LAST **
1)	        JRST    PNODE           ;AND PRINT **
1)	;HERE WHEN FOUND NODE
1)	FNODE:  MOVEI   M,%NODBUFF+1(N1) ;ADR OF MESSAGE
1)	;HERE ON MESSAGE TO PRINT (DETACHED OR OTHERWISE)
1)	PNODE:  PUSHJ   P,MSG           ;PRINT NODE NAME
1)	        MOVEI   M,[ASCIZ/ #/]
****
2)1		PUSHJ	P,TYPNOD	;Type node name
2)	        MOVEI   M,[ASCIZ/ #/]
**************
   File 1)	DSK:HEADER.OLD	created: 1628 18-Sep-85
File 2)	DSK:HEADER.MAC	created: 1627 18-Sep-85

1)1		TYMREL==06      	;TYMSHARE RELEASE NUMBER
1)		DECSPC==470		;DEC SPECIFICATION  [WHAT'S A]
****
2)1		TYMREL==07      	;TYMSHARE RELEASE NUMBER
2)		DECSPC==470		;DEC SPECIFICATION  [WHAT'S A]
**************
1)1	TITLE SYSTAT -- VERSION TS'.'TR'-'DS'.'DR -- FOR P027 -- REAL PAGING/NEW IO
1)	SUBTTL	GNSITS - RCC/CHW/TNH/PFC/RPG/NH/GMG/AMG - SEP 15, 1976
1)	IF1,<PRINTX VERSION TS'.'TR'-'DS'.'DR>
1)	VSYSTAT==BYTE(9)DS,TS,DR,TR>
****
2)1	TITLE SYSTAT -- VERSION TS'.'TR'-'DS'.'DR -- FOR P034 -- REAL PAGING/NEW IO
2)	SUBTTL	GNSIT S - RCC/CHW/TNH/PFC/RPG/NH/GMG/AMG - SEP 15, 1976
2)	SUBTTL	JMS - 18-SEP-85
2)	IF2,<PRINTX VERSION TS'.'TR'-'DS'.'DR>
2)	VSYSTAT==BYTE(9)DS,TS,DR,TR>
**************
2)1	;61.6	13-Aug-85 ???	Remove output of "swapping space used", obsolete
2)1	;61.7	18-Sep-85 JMS	Move routine to rTYMNET)NODES.MAP to SSIO, and
2)1	;			fix it to handle 7777 nodes.
 Q5j3%
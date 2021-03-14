;REQUIRED SOURCE FILES:
;	BACKRS.MAC
;	BACKUP.MAC
;REQUIRED UNV FILES (ON DEC:):
;	C.UNV
;	SCNMAC.UNV
;REQUIRED REL FILES (ON DEC:):
;	SCAN.REL
;	HELPER.REL
;	ENDECR.REL
;REQUIRED PROGRAMS (ON DEC:):
;	COMPIL
;	MACRO
;	CREF
;	LINK
;OUTPUT LISTING FILES:
;	BACKUP
;	BACKRS
;	BACKUP.MAP
;OUTPUT SAV FILES:
;	BACKUP.SHR
;	BACKUP.LOW
.ASSIGN DEC UNV ;GET FIELD IMAGE UNV FILES
.ASSIGN DEC REL ;GET FIELD IMAGE REL FILES
.ASSIGN DEC SYS ;GET FIELD IMAGE SOFTWARE
X::	;DO A /TAG:X FOR EXPERIMENTAL SOFTWARE, ETC.
	; INSTEAD OF FIELD IMAGE DEC SOFTWARE
.SET WATCH VERSION
.DIRECT/CHECKSUM BACKUP.MAC,BACKRS.MAC
.LOAD/CREF/COMPILE/MAP:LPT:BACKUP BACKUP.MAC,BACKRS.MAC
.SSAVE
.DIRECT/CHECKSUM BACKUP.SHR,BACKUP.LOW
.CREF
.RUN BACKUP
*HELP
*EXIT
.NOERROR	;SUPPRESS ERROR HANDLING OF DELETES
.DELETE BACKUP.REL,BACKRS.REL
DIRECT/CHECKSUM BACKUP.RND,BACKUP.RNH,BACKUP.HLP,BACKUP.CTL

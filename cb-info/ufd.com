BROAD .    %PICTUR 
E     .    %PICTUR 
EXP   .    %PICTUR 
EXPL  .    %PICTUR 
FILE  .    %COOKIE 
GIRL  .    %PICTUR 
LINUS .    %PICTUR 
LOIS  .    %VUE    
QUOTES.    %COOKIE 
ROOMS .    %AMAZON 
MAIL  .BOX         ;SYS, MAIL BOX file
DMS   .CAB %DMS    ;DMS, Backup source in case...
DMS   .COM %DMS    ;DMS, Comment file for DMS software
MAZE  .COM %MAZE   ;MAZE, Common definitions -- Include file
UFD   .COM         ;SYS, DMS comment file for this UFD
DMS   .COR %DMS    ;DMS, Soup correction file
DMS   .DEC %DMS    ;DMS, TOPS-10 Source
SIX12 .DEC %BLISS  
UUOSYM.DEC %DEC    
BENCH .DOC %BENCH  ;Benchmark memo
DMS   .DOC %DMS    ;DMS, DOCument file
DRT5  .DOC         ;Directory documentation updates
RUNOFF.DOC         ;Runoff documentation
TRMOP .DOC         ;DEC TRMOP.'s vs. Tymcom's AUXCALs
UUOSYM.DOC         ;UUOSYM documentation
WLD7A .DOC         ;WILD documentation
BIGCAL.F4  %BIGCAL 
GGPROG.F4  %PICTUR 
MAZE  .F4  %MAZE   ;MAZE source
MAZES .F4  %MAZE   ;MAZE source
MOVEMO.F4  %BIGCAL 
POWER .F4  %MISC   
PRTYUP.FAS %SNOBOL ;FASBOL pretty-up program
WHERE .FIN %VUE    
COMAND.FOR %AMAZON ;Command scanner routine
LIST  .FOR %BENCH  ;Program to LIST stats for 1000
M     .FOR %MAZE   ;MAZE generating program
PM    .FOR %MAZE   ;Plotter Version of MAZE
REFORM.FOR %REFORM ;Data REFORMmatter
TEST  .FOR %AMAZON ;TEST program
LIST  .HGH %BENCH  
DMS   .HLP %DMS    ;DMS, HELP file
DMSCOM.HLP %DMS    ;DMS, Commands HELP file
DMSI  .HLP %DMS    ;DMS, Individual mode HELP file
DMSIE .HLP %DMS    ;DMS, Iextension HELP file
DMSS  .HLP %DMS    ;DMS, Sort Switch HELP file
DMSSW .HLP %DMS    ;DMS, Switches HELP file
LOGON .HLP %LOGON  ;LOGON, HELP file.
RPG   .INI         ;RPG, Initialization file
SWITCH.INI         ;SYS, User Profile file
LIST  .INP %BENCH  
CRSHID.LOG %CRASH  
DMS   .LOW %DMS    ;DMS, Tymshare version
LIST  .LOW %BENCH  
H8YRZI.MA0 %MAGNUM 
1000  .MAC %1000   ;PERF, Performance for I/O
CARL  .MAC %UNV    ;Personal MACRO definitions
CKSUM .MAC %CKSUM  ;Tymshare Checksum Program
COOKIE.MAC %COOKIE ;Cookie Monster Program
D     .MAC %REVDIR ;Original Cogliano "D" directory program
DATE  .MAC %SUB    ;Get day of Week
DIRECT.MAC %DEC    ;DEC's DIRECTory program
DMS   .MAC %DMS    ;DMS, Tymshare version source file
DSKCHR.MAC %DISK   ;Program to print DSKCHR data
ECM12 .MAC %UNV    ;Version 12 of MULREA.MAC
FD    .MAC %REVDIR ;Directory program
HANG  .MAC %PENDU  ;Hangman game
HDTE75.MAC %DMS    ;DMS, Date conversion routines
KOSTER.MAC %UNV    ;Koster Universal
LEXE  .MAC %EXE    ;LOAD an EXE file on TYMCOM-X
LINKUP.MAC %LINKUP ;LINKUP, Multi-system i/o package
LOGON .MAC %LOGON  ;INIT Program
LOOKTT.MAC %MISC   ;Look at TTy for input
MJK   .MAC %UNV    ;Koster Universal
ND    .MAC %REVDIR ;Directory Program
RUNEXE.MAC %EXE    ;Load and RUN and EXE file on TYMCOM-X
TTYO  .MAC %DMS    ;DMS, Teletype output routine
TYMCAB.MAC %SUB    ;Subroutine package [CAB]
TYMSCN.MAC %SUB    ;Scanner package [CAB]
WLD7A .MAC %WILD   ;Source for version %7A
LIST  .MCH %BENCH  
H8YRZI.MD0 %MAGNUM 
U31EXB.ME0 %MAGNUM 
UB0W38.ME0 %MAGNUM 
Z3CIV9.ME0 %MAGNUM 
UB0W38.MP0 %MAGNUM 
O76M8D.MR0 %MAGNUM 
YRZUS6.MR0 %MAGNUM 
H8YRZI.MS0 %MAGNUM 
H8YRZI.MX0 %MAGNUM 
AMAZON.OFF %AMAZON ;Offsets for Amazon Structure
LOGON .OLD %LOGON  ;LOGON, Tops-10 version, ancient.
MAZE  .ONE %MAZE   ;MAZE, Normal version #1
PMAZE .ONE %MAZE   ;MAZE, Plotter version #1
BARON .PIC %PICTUR 
BROAD .PIC %PICTUR 
EXP   .PIC %PICTUR 
LINUS .PIC %PICTUR 
PEACE .PIC %PICTUR 
PUPPY .PIC %PICTUR 
SNOOPY.PIC %PICTUR 
BLOCK .REL %SUB    ;Block letter subroutine
DDT   .REL %DDT    
HDTE75.REL %DMS    ;DMS, Date conversion routines
HELPER.REL %LIB    ;System help file
LEXCMP.REL %SUB    
SCAN  .REL %SCAN   
SCN7B .REL %SCAN   ;Version %7B
TTYO  .REL %DMS    ;DMS, Teletype output routine
TYMCAB.REL %SUB    
TYMSCN.REL %SUB    
WLD7A .REL %WILD   
AUXLIB.REQ         ;WRS's Sail require file
DMS   .RND %DMS    ;DMS, Document source file
DMS   .RNH %DMS    ;DMS, HELP source file
DMSCOM.RNH %DMS    ;DMS, Command HELP source
DMSI  .RNH %DMS    ;DMS, Individual mode HELP source
DMSIE .RNH %DMS    ;DMS, Iextension HELP source
DMSS  .RNH %DMS    ;DMS, Sort Switch HELP source
DMSSW .RNH %DMS    ;DMS, Switches HELP source
LOGON .RNH %LOGON  ;LOGON, HELP FILE source
RPG   .RV1         ;RPG, Initialization file, Version 1
AMAZON.SAI %AMAZON ;Test Sail program
DUMP2 .SAI         ;MISC, Print a file in many modes
1000  .SAV %1000   ;Performance, Running program
CRA001.SAV %CRASH  
CRA002.SAV %CRASH  
CRA003.SAV %CRASH  
CRA004.SAV %CRASH  
CRA005.SAV %CRASH  
CRA006.SAV %CRASH  
FILDDT.SAV         ;FILDDT, TOPS-10 version of FILE DDT
PFD   .SAV         ;PFD, Phanthom File Directory Manipulator
DMS   .SHR %DMS    ;DMS, Tymshare version
LOGON .SHR %LOGON  ;LOGON, Universal Init program
MTADIR.SHR         ;DIRECT, DEC's version with SCAN/WILD
ADDRES.SNO %PHONE  ;Snobol program to generate an address file
DUMP  .SNO %DUMP   
LNKTYP.SNO %LINK   
P     .SNO %PHONE  
PH    .SNO %PHONE  
PHONE .SNO %PHONE  
PRTYUP.SNO %SNOBOL ;Snobol 4 pretty-up for FASBOL
RECORD.SNO %MISC   
SNOSYM.SNO %SNOBOL ;Snobol 4 list and cross-reference-er
MAZE  .TWO %MAZE   
AMAZON.TXT %AMAZON ;Dungeon definitions
COOKIE.TXT %COOKIE ;Fortune cookies!
FOOF3 .TXT %BENCH  ;Foonly F3 stats
KI10  .TXT %BENCH  ;KI-10 stats
KL10  .TXT %BENCH  ;KL-10 stats
KS10  .TXT %BENCH  ;DEC 2020 stats
MAZE  .TXT %MAZE   ;DMS file describing various MAZE programs
MOVIES.TXT %TEXT   
SOUNDE.TXT %TEXT   
SUMARY.TXT %BENCH  ;Summary of Performance stats
TRIP  .TXT %LETTER 
CARL  .UNV %UNV    
ECM12 .UNV %UNV    
JOBDAT.UNV %UNV    ;MACRO, Job data Universal file
KOSTER.UNV %UNV    
MACTEN.UNV %UNV    ;MACRO, System Macros file
MJK   .UNV %UNV    
UUOSYM.UNV %UNV    ;MACRO, UUO symbols Universal file
DMS   .UTH %DMS    ;DMS, Edit history at Univ of Tex @ Austin
DMSSW .UTH %DMS    ;DMS, UTH Switches, long.
    ABBREV.BLH ;Archive: Kazar's Abbreviation Module
ABBREV.BLI ;Source: Abbreviation Module
ABBREV.REL ;Binary: Abbreviation Module
ACCESS.MSG ;My "Access" Message
AUX   .LST ;Listing
AUX   .MAB ;Archive:  An Ancient version of AUX.MAC
AUX   .MAC ;Source: Auxilliary Routines
AUX   .REL ;Binary
BLILIB.DOC ;Document: About BLISS Library routines
BLILIB.REL ;BLISS Library, Use this instead of SYS:BLILIB
BLISS .DOC ;Document: About DEC/CMU Bliss
BLISS .EXE ;Archive:  DEC/CMU BLISS compiler
BLISS .LOW ;Compiler: DEC/CMU version
BLISS .SHR ;Compiler: DEC/CMU version
BUFFER.BLH ;Archive: Kazar's Buffer manipulation Module
BUFFER.BLI ;Source: Buffer Manipulation Module
BUFFER.LST ;Listing
BUFFER.REL ;Binary
CALIAD.BLH ;Archive:  Redisplay Logic
CALIAD.BLI ;Source: Redisplay Logic
CALIAD.LST ;Listing
CALIAD.OLD ;Archive: Redisplay Logic
CALIAD.REL ;Binary
CCL   .BLH ;Archive: CCL entry handler
CCL   .BLI ;Source: CCL entry/exit handler
CCL   .LST ;Listing
CCL   .REL ;Binary
CURSOR.BLH ;Archive: Cursor Manipulation Routines
CURSOR.BLI ;Source: Cursor Manipulation Routines
CURSOR.LST ;Listing
CURSOR.REL ;Binary
DDT   .REL ;TOPS-10 Version of DDT.REL
DIRED .BLH ;Archive: DIRED MODE
DISPAT.BLH ;Archive: Dispatch table and Status line
DISPAT.BLI ;Source: Dispatch Table routines
DISPAT.LST ;Listing
DISPAT.REL ;Binary
DVUE  .CMD ;Command: Directory command list
EMACS .1   ;Archive: 1st half of EMACS.TXT
EMACS .2   ;Archive: 2nd half of EMACS.TXT
EMACS .CHT ;Archive: EMACS command Chart
EMACS .CRD ;Archive: EMACS command card
EMACS .OUT ;Archive: EMACS.TXT in some incarnation
FILECO.BLH ;Archive: File Routines
FILECO.BLI ;Source: File reading routines
FILECO.LST ;Listing
FILECO.REL ;Binary
FILESC.BLH ;Archive: File Scanner Module
FILESC.BLI ;Source: File Scanner Module
FILESC.LST ;Listing
FILESC.REL ;Binary
FINDOC.DOC ;Archive: FINE Documentation
FINE  .BLH ;Archive: Ancient Main Module for "FINE"
FINE  .CAB ;Archive: Very Ancient Main Module for "FINE"
FINE  .DOC ;Archive: Old Document for "FINE"
FINE  .MEM ;Archive: Old Document for "FINE"
FINE  .MSS ;Archive: Scribe Document for "FINE"
FINE  .ODC ;Archive: Older Document for "FINE"
FINE  .OLD ;Archive: Older Main Module for "FINE"
FINE  .PRT ;Archive: Original LPT Document for "FINE"
FINE  .RND ;Archive: Reworked RUNOFF Document for "FINE"
FINI  .BLH ;Archive: FINI Mode
GETSTR.BLH ;Archive: "Get String" routines
GETSTR.BLI ;Source: "Get String" Routines
GETSTR.LST ;Listing
GETSTR.REL ;Binary
HELP  .BLI ;Source: Rudimentary "HELP" Text Module
HELP  .CRD ;Document: VUE Command Summary by KEY
HELP  .LST ;Listing
HELP  .REL ;Binary
IDC   .BLH ;Archive: Insert and Delete (Line/Character) Logic
IDC   .BLI ;Source: Insert and Delete (Line/Character) Logic
IDC   .LST ;Listing
IDC   .REL ;Binary
ISERCH.BLH ;Archive: Incremental Search Mode
ISERCH.BLI ;Source: Incremental Search Mode
ISERCH.LST ;Listing
ISERCH.REL ;Binary
JOBDAT.UNV ;Source: Macro Universal File
JUST  .BLH ;Archive: Justification Routines
JUST  .BLI ;Source: Justification Routines
JUST  .LST ;Listing
JUST  .OLD ;Archive: Old version of Justification RoutineST  .REL ;Binary
KILL  .RNX ;Document: Text about C-U C-K command
LDVUE .COM ;Command: Debugging Load File
LF    .BLH ;Archive: ROutine to perform <LF> function
LVUE  .COM ;Command: Commands to Link VUE together
MACTEN.UNV ;Source: Macro Universal File
MLOAD .BLH ;Archive: Load Macro Command
MLOAD .BLI ;Source: Load Macro Command
MLOAD .LST ;Listing
MLOAD .REL ;Binary
MODES .BLH ;Archive: Mode Package Routines
MODES .BLI ;Source: Mode Package Routines
MODES .LST ;Listing
MODES .OLD ;Archive: Original Mode Package Routines
MODES .REL ;Binary
NEWFIN.MSS ;Archive: Instructions to Install a "FINE"
PASCAL.BLH ;Archive: PASCAL Mode
PASCAL.BLI ;Source: Pascal Mode
PASCAL.LST ;Listing
PASCAL.REL ;Binary
QREPL .BLH ;Archive: String Replace Module
QREPL .BLI ;Source: String Replace Module
QREPL .LST ;Listing
QREPL .REL ;Binary
REBIND.BLH ;Archive: Rebinding Commands
REBIND.BLI ;Source: Rebinding Commands
REBIND.LST ;Listing
REBIND.REL ;Binary
REDISP.BLH ;Archive: Redisplay Screen Logic
REDISP.BLI ;Source: Redisplay Screen Logic
REDISP.LST ;Listing
REDISP.REL ;Binary
RPG   .INI ;RPG Init File
SHERMA.TUT ;Document: Sherman's suggested changes
SIX12 .DOC ;Document about BLISS debugger
SIX12 .REL ;Source: Bliss Debugger Rel File
SPEED .LST ;Listing
SPEED .MAB ;Archive: Routines written for "Speed"
SPEED .MAC ;Source: Routines written for "SPEED"
SPEED .REL ;Binary
STATUS.BLI ;Source: Statusline Code
STATUS.LST ;Listing
STATUS.REL ;Binary
SWITCH.INI ;User Profile "Init" File
SYMS  .BLH ;Archive: Mode Parameter Setting Module
SYMS  .BLI ;Source: Mode Parameter Setting Module
SYMS  .LST ;Listing
SYMS  .REL ;Binary
TEACHE.TXT ;Archive: Tutorial for EMACS
TEXT  .BLH ;Archive: TEXT Mode
TMP   .BLH ;Archive: TMPCOR Routines
TMP   .BLI ;Source: TMPCOR Routines
TMP   .LST ;Listing
TMP   .REL ;Binary
TTYCOR.BAC ;Source: Backup Copy of TTYCOR
TTYCOR.LST ;Listing
TTYCOR.M04 ;Archive: Old Copy of TTYCOR.MAC
TTYCOR.MAB ;Archive: Kazar's version of TTYCOR.MAC
TTYCOR.MAC ;Source: Most recent version of TTYCOR
TTYCOR.REL ;Binary
UUOSYM.UNV ;Source: Macro Universal File
VMACS .IDX ;Archive: Documentation Supplement, EMACS/VUE
VUE   .BLI ;Source: Main Module
VUE   .CMD ;Command: List of files to be compiled
VUE   .CNF ;Command: Brief settings list for Installation
VUE   .DOC ;Document: Major Reference Manual
VUE   .INF ;Document: Internal Change Documentation
VUE   .INI ;Init File for VUE
VUE   .INX ;Old INIT file for VUE
VUE   .LOW ;Source: Impure Segment
VUE   .LST ;Listing
VUE   .MAP ;Listing
VUE   .REL ;Binary
VUE   .RND ;Document: Source for VUE Documentation
VUE   .SHR ;Source: Pure Shareable Segment
VUE   .SLG ;Document: Tutorial with comments by Sherman
VUE   .STS ;Document: Configuration List of FINE/VUE on X Systems
VUE   .TUT ;Document: Tutorial Text
VUE   .WSH ;Document: Wish List
VUECRD.TXT ;Document: Reference Card
VUEHLP.TXT ;Document: Reference Card
VUEKRD.TXT ;Document: Reference Card
VUELST.DAT ;Document: Detailed List of Routines by Module name
VUEMAC.CRF ;Source: Future Replacement for *.MAC
VUEMAC.LST ;Listing
VUEMAC.MAC ;Source: Future Replacement for *.MAC
VUEMAC.REL ;Binary
WINDOW.BLH ;Archive: Window Manipulation Routines
WINDOW.BLI ;Source: Window Manipulation Routines
WINDOW.LST ;Listing
WINDOW.OLD ;Archive: Window Manipulation Routines
WINDOW.REL ;Binary
XLIAD .BLH ;Archive: More Redisplay Logic
XLIAD .BLI ;Source: More Redisplay Logic
XLIAD .CB0 ;Archive: Old version of Redisplay Logic
XLIAD .LST ;Listing
XLIAD .REL ;Binary
    ABBREV.BLH ;Archive: Kazar's Abbreviation Module
ABBREV.BLI ;Source: Abbreviation Module
ABBREV.REL ;Binary: Abbreviation Module
ACCESS.MSG ;My "Access" Message
AUX   .LST ;Listing
AUX   .MAB ;Archive:  An Ancient version of AUX.MAC
AUX   .MAC ;Source: Auxilliary Routines
AUX   .REL ;Binary
BLILIB.DOC ;Document: About BLISS Library routines
BLILIB.REL ;BLISS Library, Use this instead of SYS:BLILIB
BLISS .DOC ;Document: About DEC/CMU Bliss
BLISS .EXE ;Archive:  DEC/CMU BLISS compiler
BLISS .LOW ;Compiler: DEC/CMU version
BLISS .SHR ;Compiler: DEC/CMU version
BUFFER.BLH ;Archive: Kazar's Buffer manipulation Module
BUFFER.BLI ;Source: Buffer Manipulation Module
BUFFER.LST ;Listing
BUFFER.REL ;Binary
CALIAD.BLH ;Archive:  Redisplay Logic
CALIAD.BLI ;Source: Redisplay Logic
CALIAD.LST ;Listing
CALIAD.OLD ;Archive: Redisplay Logic
CALIAD.REL ;Binary
CCL   .BLH ;Archive: CCL entry handler
CCL   .BLI ;Source: CCL entry/exit handler
CCL   .LST ;Listing
CCL   .REL ;Binary
CURSOR.BLH ;Archive: Cursor Manipulation Routines
CURSOR.BLI ;Source: Cursor Manipulation Routines
CURSOR.LST ;Listing
CURSOR.REL ;Binary
DDT   .REL ;TOPS-10 Version of DDT.REL
DIRED .BLH ;Archive: DIRED MODE
DISPAT.BLH ;Archive: Dispatch table and Status line
DISPAT.BLI ;Source: Dispatch Table routines
DISPAT.LST ;Listing
DISPAT.REL ;Binary
DVUE  .CMD ;Command: Directory command list
EMACS .1   ;Archive: 1st half of EMACS.TXT
EMACS .2   ;Archive: 2nd half of EMACS.TXT
EMACS .CHT ;Archive: EMACS command Chart
EMACS .CRD ;Archive: EMACS command card
EMACS .OUT ;Archive: EMACS.TXT in some incarnation
FILECO.BLH ;Archive: File Routines
FILECO.BLI ;Source: File reading routines
FILECO.LST ;Listing
FILECO.REL ;Binary
FILESC.BLH ;Archive: File Scanner Module
FILESC.BLI ;Source: File Scanner Module
FILESC.LST ;Listing
FILESC.REL ;Binary
FINDOC.DOC ;Archive: FINE Documentation
FINE  .BLH ;Archive: Ancient Main Module for "FINE"
FINE  .CAB ;Archive: Very Ancient Main Module for "FINE"
FINE  .DOC ;Archive: Old Document for "FINE"
FINE  .MEM ;Archive: Old Document for "FINE"
FINE  .MSS ;Archive: Scribe Document for "FINE"
FINE  .ODC ;Archive: Older Document for "FINE"
FINE  .OLD ;Archive: Older Main Module for "FINE"
FINE  .PRT ;Archive: Original LPT Document for "FINE"
FINE  .RND ;Archive: Reworked RUNOFF Document for "FINE"
FINI  .BLH ;Archive: FINI Mode
GETSTR.BLH ;Archive: "Get String" routines
GETSTR.BLI ;Source: "Get String" Routines
GETSTR.LST ;Listing
GETSTR.REL ;Binary
HELP  .BLI ;Source: Rudimentary "HELP" Text Module
HELP  .CRD ;Document: VUE Command Summary by KEY
HELP  .LST ;Listing
HELP  .REL ;Binary
IDC   .BLH ;Archive: Insert and Delete (Line/Character) Logic
IDC   .BLI ;Source: Insert and Delete (Line/Character) Logic
IDC   .LST ;Listing
IDC   .REL ;Binary
ISERCH.BLH ;Archive: Incremental Search Mode
ISERCH.BLI ;Source: Incremental Search Mode
ISERCH.LST ;Listing
ISERCH.REL ;Binary
JOBDAT.UNV ;Source: Macro Universal File
JUST  .BLH ;Archive: Justification Routines
JUST  .BLI ;Source: Justification Routines
JUST  .LST ;Listing
JUST  .OLD ;Archive: Old version of Justification Routines
JUST  .REL ;Binary
KILL  .RNX ;Document: Text about C-U C-K command
LDVUE .COM ;Command: Debugging Load File
LF    .BLH ;Archive: ROutine to perform <LF> function
LVUE  .COM ;Command: Commands to Link VUE together
MACTEN.UNV ;Source: Macro Universal File
MLOAD .BLH ;Archive: Load Macro Command
MLOAD .BLI ;Source: Load Macro Command
MLOAD .LST ;Listing
MLOAD .REL ;Binary
MODES .BLH ;Archive: Mode Package Routines
MODES .BLI ;Source: Mode Package Routines
MODES .LST ;Listing
MODES .OLD ;Archive: Original Mode Package Routines
MODES .REL ;Binary
NEWFIN.MSS ;Archive: Instructions to Install a "FINE"
PASCAL.BLH ;Archive: PASCAL Mode
PASCAL.BLI ;Source: Pascal Mode
PASCAL.LST ;Listing
PASCAL.REL ;Binary
QREPL .BLH ;Archive: String Replace Module
QREPL .BLI ;Source: String Replace Module
QREPL .LST ;Listing
QREPL .REL ;Binary
REBIND.BLH ;Archive: Rebinding Commands
REBIND.BLI ;Source: Rebinding Commands
REBIND.LST ;Listing
REBIND.REL ;Binary
REDISP.BLH ;Archive: Redisplay Screen Logic
REDISP.BLI ;Source: Redisplay Screen Logic
REDISP.LST ;Listing
REDISP.REL ;Binary
RPG   .INI ;RPG Init File
SHERMA.TUT ;Document: Sherman's suggested changes
SIX12 .DOC ;Document about BLISS debugger
SIX12 .REL ;Source: Bliss Debugger Rel File
SPEED .LST ;Listing
SPEED .MAB ;Archive: Routines written for "Speed"
SPEED .MAC ;Source: Routines written for "SPEED"
SPEED .REL ;Binary
STATUS.BLI ;Source: Statusline Code
STATUS.LST ;Listing
STATUS.REL ;Binary
SWITCH.INI ;User Profile "Init" File
SYMS  .BLH ;Archive: Mode Parameter Setting Module
SYMS  .BLI ;Source: Mode Parameter Setting Module
SYMS  .LST ;Listing
SYMS  .REL ;Binary
TEACHE.TXT ;Archive: Tutorial for EMACS
TEXT  .BLH ;Archive: TEXT Mode
TMP   .BLH ;Archive: TMPCOR Routines
TMP   .BLI ;Source: TMPCOR Routines
TMP   .LST ;Listing
TMP   .REL ;Binary
TTYCOR.BAC ;Source: Backup Copy of TTYCOR
TTYCOR.LST ;Listing
TTYCOR.M04 ;Archive: Old Copy of TTYCOR.MAC
TTYCOR.MAB ;Archive: Kazar's version of TTYCOR.MAC
TTYCOR.MAC ;Source: Most recent version of TTYCOR
TTYCOR.REL ;Binary
UUOSYM.UNV ;Source: Macro Universal File
VMACS .IDX ;Archive: Documentation Supplement, EMACS/VUE
VUE   .BLI ;Source: Main Module
VUE   .CMD ;Command: List of files to be compiled
VUE   .CNF ;Command: Brief settings list for Installation
VUE   .DOC ;Document: Major Reference Manual
VUE   .INF ;Document: Internal Change Documentation
VUE   .INI ;Init File for VUE
VUE   .INX ;Old INIT file for VUE
VUE   .LOW ;Source: Impure Segment
VUE   .LST ;Listing
VUE   .MAP ;Listing
VUE   .REL ;Binary
VUE   .RND ;Document: Source for VUE Documentation
VUE   .SHR ;Source: Pure Shareable Segment
VUE   .SLG ;Document: Tutorial with comments by Sherman
VUE   .STS ;Document: Configuration List of FINE/VUE on X Systems
VUE   .TUT ;Document: Tutorial Text
VUE   .WSH ;Document: Wish List
VUECRD.TXT ;Document: Reference Card
VUEHLP.TXT ;Document: Reference Card
VUEKRD.TXT ;Document: Reference Card
VUELST.DAT ;Document: Detailed List of Routines by Module name
VUEMAC.CRF ;Source: Future Replacement for *.MAC
VUEMAC.LST ;Listing
VUEMAC.MAC ;Source: Future Replacement for *.MAC
VUEMAC.REL ;Binary
WINDOW.BLH ;Archive: Window Manipulation Routines
WINDOW.BLI ;Source: Window Manipulation Routines
WINDOW.LST ;Listing
WINDOW.OLD ;Archive: Window Manipulation Routines
WINDOW.REL ;Binary
XLIAD .BLH ;Archive: More Redisplay Logic
XLIAD .BLI ;Source: More Redisplay Logic
XLIAD .CB0 ;Archive: Old version of Redisplay Logic
XLIAD .LST ;Listing
XLIAD .REL ;Binary
    ABBREV.BLH ;Archive: Kazar's Abbreviation Module
ABBREV.BLI ;Source: Abbreviation Module
ABBREV.REL ;Binary: Abbreviation Module
ACCESS.MSG ;My "Access" Message
AUX   .LST ;Listing
AUX   .MAB ;Archive:  An Ancient version of AUX.MAC
AUX   .MAC ;Source: Auxilliary Routines
AUX   .REL ;Binary
BLILIB.DOC ;Document: About BLISS Library routines
BLILIB.REL ;BLISS Library, Use this instead of SYS:BLILIB
BLISS .DOC ;Document: About DEC/CMU Bliss
BLISS .EXE ;Archive:  DEC/CMU BLISS compiler
BLISS .LOW ;Compiler: DEC/CMU version
BLISS .SHR ;Compiler: DEC/CMU version
BUFFER.BLH ;Archive: Kazar's Buffer manipulation Module
BUFFER.BLI ;Source: Buffer Manipulation Module
BUFFER.LST ;Listing
BUFFER.REL ;Binary
CALIAD.BLH ;Archive:  Redisplay Logic
CALIAD.BLI ;Source: Redisplay Logic
CALIAD.LST ;Listing
CALIAD.OLD ;Archive: Redisplay Logic
CALIAD.REL ;Binary
CCL   .BLH ;Archive: CCL entry handler
CCL   .BLI ;Source: CCL entry/exit handler
CCL   .LST ;Listing
CCL   .REL ;Binary
CURSOR.BLH ;Archive: Cursor Manipulation Routines
CURSOR.BLI ;Source: Cursor Manipulation Routines
CURSOR.LST ;Listing
CURSOR.REL ;Binary
DDT   .REL ;TOPS-10 Version of DDT.REL
DIRED .BLH ;Archive: DIRED MODE
DISPAT.BLH ;Archive: Dispatch table and Status line
DISPAT.BLI ;Source: Dispatch Table routines
DISPAT.LST ;Listing
DISPAT.REL ;Binary
DVUE  .CMD ;Command: Directory command list
EMACS .1   ;Archive: 1st half of EMACS.TXT
EMACS .2   ;Archive: 2nd half of EMACS.TXT
EMACS .CHT ;Archive: EMACS command Chart
EMACS .CRD ;Archive: EMACS command card
EMACS .OUT ;Archive: EMACS.TXT in some incarnation
FILECO.BLH ;Archive: File Routines
FILECO.BLI ;Source: File reading routines
FILECO.LST ;Listing
FILECO.REL ;Binary
FILESC.BLH ;Archive: File Scanner Module
FILESC.BLI ;Source: File Scanner Module
FILESC.LST ;Listing
FILESC.REL ;Binary
FINDOC.DOC ;Archive: FINE Documentation
FINE  .BLH ;Archive: Ancient Main Module for "FINE"
FINE  .CAB ;Archive: Very Ancient Main Module for "FINE"
FINE  .DOC ;Archive: Old Document for "FINE"
FINE  .MEM ;Archive: Old Document for "FINE"
FINE  .MSS ;Archive: Scribe Document for "FINE"
FINE  .ODC ;Archive: Older Document for "FINE"
FINE  .OLD ;Archive: Older Main Module for "FINE"
FINE  .PRT ;Archive: Original LPT Document for "FINE"
FINE  .RND ;Archive: Reworked RUNOFF Document for "FINE"
FINI  .BLH ;Archive: FINI Mode
GETSTR.BLH ;Archive: "Get String" routines
GETSTR.BLI ;Source: "Get String" Routines
GETSTR.LST ;Listing
GETSTR.REL ;Binary
HELP  .BLI ;Source: Rudimentary "HELP" Text Module
HELP  .CRD ;Document: VUE Command Summary by KEY
HELP  .LST ;Listing
HELP  .REL ;Binary
IDC   .BLH ;Archive: Insert and Delete (Line/Character) Logic
IDC   .BLI ;Source: Insert and Delete (Line/Character) Logic
IDC   .LST ;Listing
IDC   .REL ;Binary
ISERCH.BLH ;Archive: Incremental Search Mode
ISERCH.BLI ;Source: Incremental Search Mode
ISERCH.LST ;Listing
ISERCH.REL ;Binary
JOBDAT.UNV ;Source: Macro Universal File
JUST  .BLH ;Archive: Justification Routines
JUST  .BLI ;Source: Justification Routines
JUST  .LST ;Listing
JUST  .OLD ;Archive: Old version of Justification Routines
JUST  .REL ;Binary
KILL  .RNX ;Document: Text about C-U C-K command
LDVUE .COM ;Command: Debugging Load File
LF    .BLH ;Archive: ROutine to perform <LF> function
LVUE  .COM ;Command: Commands to Link VUE together
MACTEN.UNV ;Source: Macro Universal File
MLOAD .BLH ;Archive: Load Macro Command
MLOAD .BLI ;Source: Load Macro Command
MLOAD .LST ;Listing
MLOAD .REL ;Binary
MODES .BLH ;Archive: Mode Package Routines
MODES .BLI ;Source: Mode Package Routines
MODES .LST ;Listing
MODES .OLD ;Archive: Original Mode Package Routines
MODES .REL ;Binary
NEWFIN.MSS ;Archive: Instructions to Install a "FINE"
PASCAL.BLH ;Archive: PASCAL Mode
PASCAL.BLI ;Source: Pascal Mode
PASCAL.LST ;Listing
PASCAL.REL ;Binary
QREPL .BLH ;Archive: String Replace Module
QREPL .BLI ;Source: String Replace Module
QREPL .LST ;Listing
QREPL .REL ;Binary
REBIND.BLH ;Archive: Rebinding Commands
REBIND.BLI ;Source: Rebinding Commands
REBIND.LST ;Listing
REBIND.REL ;Binary
REDISP.BLH ;Archive: Redisplay Screen Logic
REDISP.BLI ;Source: Redisplay Screen Logic
REDISP.LST ;Listing
REDISP.REL ;Binary
RPG   .INI ;RPG Init File
SHERMA.TUT ;Document: Sherman's suggested changes
SIX12 .DOC ;Document about BLISS debugger
SIX12 .REL ;Source: Bliss Debugger Rel File
SPEED .LST ;Listing
SPEED .MAB ;Archive: Routines written for "Speed"
SPEED .MAC ;Source: Routines written for "SPEED"
SPEED .REL ;Binary
STATUS.BLI ;Source: Statusline Code
STATUS.LST ;Listing
STATUS.REL ;Binary
SWITCH.INI ;User Profile "Init" File
SYMS  .BLH ;Archive: Mode Parameter Setting Module
SYMS  .BLI ;Source: Mode Parameter Setting Module
SYMS  .LST ;Listing
SYMS  .REL ;Binary
TEACHE.TXT ;Archive: Tutorial for EMACS
TEXT  .BLH ;Archive: TEXT Mode
TMP   .BLH ;Archive: TMPCOR Routines
TMP   .BLI ;Source: TMPCOR Routines
TMP   .LST ;Listing
TMP   .REL ;Binary
TTYCOR.BAC ;Source: Backup Copy of TTYCOR
TTYCOR.LST ;Listing
TTYCOR.M04 ;Archive: Old Copy of TTYCOR.MAC
TTYCOR.MAB ;Archive: Kazar's version of TTYCOR.MAC
TTYCOR.MAC ;Source: Most recent version of TTYCOR
TTYCOR.REL ;Binary
UUOSYM.UNV ;Source: Macro Universal File
VMACS .IDX ;Archive: Documentation Supplement, EMACS/VUE
VUE   .BLI ;Source: Main Module
VUE   .CMD ;Command: List of files to be compiled
VUE   .CNF ;Command: Brief settings list for Installation
VUE   .DOC ;Document: Major Reference Manual
VUE   .INF ;Document: Internal Change Documentation
VUE   .INI ;Init File for VUE
VUE   .INX ;Old INIT file for VUE
VUE   .LOW ;Source: Impure Segment
VUE   .LST ;Listing
VUE   .MAP ;Listing
VUE   .REL ;Binary
VUE   .RND ;Document: Source for VUE Documentation
VUE   .SHR ;Source: Pure Shareable Segment
VUE   .SLG ;Document: Tutorial with comments by Sherman
VUE   .STS ;Document: Configuration List of FINE/VUE on X Systems
VUE   .TUT ;Document: Tutorial Text
VUE   .WSH ;Document: Wish List
VUECRD.TXT ;Document: Reference Card
VUEHLP.TXT ;Document: Reference Card
VUEKRD.TXT ;Document: Reference Card
VUELST.DAT ;Document: Detailed List of Routines by Module name
VUEMAC.CRF ;Source: Future Replacement for *.MAC
VUEMAC.LST ;Listing
VUEMAC.MAC ;Source: Future Replacement for *.MAC
VUEMAC.REL ;Binary
WINDOW.BLH ;Archive: Window Manipulation Routines
WINDOW.BLI ;Source: Window Manipulation Routines
WINDOW.LST ;Listing
WINDOW.OLD ;Archive: Window Manipulation Routines
WINDOW.REL ;Binary
XLIAD .BLH ;Archive: More Redisplay Logic
XLIAD .BLI ;Source: More Redisplay Logic
XLIAD .CB0 ;Archive: Old version of Redisplay Logic
XLIAD .LST ;Listing
XLIAD .REL ;Binary
    <h+?
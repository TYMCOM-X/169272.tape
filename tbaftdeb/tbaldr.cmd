; Load production-version of TBALDR, switch descriptions:
;  file%-4Y       specifies /HOTSTART:file
;  %-5Y           specifies deletion of "EXECUTION" message when loading done
;  %W             load without local symbols
TBALDR/FORWARD/REL%-4Y,%-5Y,(SYS)JOBDAT,%W,RUNDAT,DATAR,TBARUN,%L,TBALIB,%-L, /RUN(SPUNKDEV)LOADER
  
:LOGFILE SZRPTX.LOG
:PARAMETERS $SUBSTITUTION=$TRUE
;Update the access date for these files for next system startup
GFD ZZZ-LAST-DIR
COPY ACCESS.MSG,ACCESS.MSG
GFD
DAYTIME		;\$WEEKDAY\
SYS G
ASSIGN DSK TTY	;Put listing in DSK:SZRPT.LST
R SZRPT		;## NOTE: Sort by USER on X32, X17, X14 only ##
Y
USER
DEASSIGN	;Listing back to TTY
R SZRPT
6
SIZE
;SZRPT.LST=GAN:3, SZRPTX.LOG=ALL
DIRECT SZRPT?.*
COPY SZRPTX.LOG,SZRPT.\$WEEKDAY\
COPY SZRPTX.LOG,SZRPT.LOG
  
:LOG ASMC.LOG
;This file assembles TELECO with cref
CTEST SETPROC MACRO=(SYS)MACRO
COMPILE/COMPILE @ASMC
R CROSS
_TELECO/O/Q
_MASTER/O/Q
_SLAVE/O/Q
_TF/O/Q
_RF/O/Q
_BIO/O/Q
_DSKIO/O/Q
_TRANS/O/Q
_VAR/O/Q
:ESCAPE
dir *.swt,*.mac,*.lst
del *.crf
    
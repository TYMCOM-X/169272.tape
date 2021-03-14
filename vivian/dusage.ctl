:logfile dusage.log
; File to build DUSAGE version 2.0

ctest setp sail=(ftsys)sail
com/com lic.sai
load/com dusage.sai
save dusage.sav
declare run run run dusage.sav
dir dusage.sav/prot
r cksum
@dusage.fil

DEL DUSAGE.020
R (QASYS)FDM
OPEN DUSAGE.020
Y
READ @DUSAGE.FIL
DIRECTORY
Q


 "\3650A.PAT - Patch "A" for systems with 3650 disks.  JMS 13-Nov-86\
 "\Make GIVPG1 be an INFO stopcode\
SWAMP:
GIVPG1/	.+2[S$INFO,,0
 "\Change number of SAT PCBs to max\
COMMON:
NMRBPC[16
NMSTPC[60
PATMAP[100000000000
CONFIG+1T/
 
 "\ This file contains patches applicable to P035/B thru P035/B03.\

 "\ Patch #1 for P035/B - TDERR.PAT 9-Feb-86 JMS \
 "\ Fix 'serious restart error while writing to HOM pages' on blocks disks.\
MONBTS:
PMDST1+0/MOVEI T2,200
PMDST1+2/LDB T2,UNYBPT
PMDST1+4/LDB T2,UNYBPY
COMMON:
PATMAP[Q+200000000000

 "\ DAYLIT.PAT - Change to make daylight savings time start on 5-Apr-87.\
 "\ Patch #2 for P035/B, patch #16 for P034/P.\
UUOCON:
DLTTAB+2*1987.-2*1964.[ 616151
COMMON:
PATMAP[Q+100000000000

 "\ Patch #3 for P035/B and P035/B04 - INTKIL.PAT 17-May-87 JMS \
 "\ Preserve J in the inactivity-timeout killer \
CLOCK1:
PAT/PUSH P,J
PAT+1/PUSHJ P,HNGMON
PAT+2/JFCL
PAT+3/POP P,J
PAT+4/JRST INACT1
INTKIL+2/JRST PAT
PAT+5/PAT:
PATSIZ/PAT
COMMON:
PATMAP[Q+040000000000

CONFIG+2T/"/-3/
   
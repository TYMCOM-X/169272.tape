 "\PATCH #0 NOHALT.PAT 1-Oct-85 JMS\
 "\Replace the 2 HALT instructions in the crash code to JSR's\
 "\Pick up correct PC on a "147 RESTART"\
ERRCON:
DIE+1/JSR CRS147
COMMON:
CRASHX+1/JSR GOBOOT
CRASHX+11/MOVE 1,CRS147
PATMAP[Q+400000000000

 "\PATCH #1 WRTSAT.PAT 24-Oct-85 JMS\
 "\Change STOPCD(WRTSAT) to output meaningful data\
FILIO:
WRTSAT-4/MOVEM PG,WRTST1+7
WRTSAT+1/MOVE PG,WRTST1+7
WRTST1+4["/ page/
WRTST1+5["/ /
WRTST1+6[SKIPA PG,.+1
WRTST1+7[0
WRTST1+10/
COMMON:
PATMAP[Q+200000000000

 "\PATCH #2 EVICT.PAT 24-Oct-85 JMS\
 "\ILLINS when LOGOUT fails to kill another job due to T1 on stack\
FRMSER:
EVICT+5/JRST TPOPJ
COMMON:
PATMAP[Q+100000000000

 "\PATCH #3 BADCH7.PAT 4-Nov-85 CARL ** REMOVED BY #4 **\
 "\Skip CONO PI,REQCLK at KEYSET+6 while in STOPCD processor\
PATMAP[Q+040000000000=

 "\Patch #4 NOINTE.PAT 27-Nov-85 JMS ** REPLACES #3\
 "\Disable the CONO PI,PI.TNP+PI.CO1 for JOB and INFO stopcodes\
ERRCON:
DIE1A+7/JFCL
COMMON:
PATMAP[Q+020000000000

 "\Patch #5 SETOUT.PAT 5-Dec-85 WRS\
 "\Fix character lossage @ SETOUT+1\
SCNSER:
SETOUT/
PAT/SETOM MXMCNT
PAT+1/SETOM MULCNT
PAT+2/JRST SETOUT+1
SETOUT/JRST PAT
PAT+3/PAT:
PATSIZ/PAT
COMMON:
PATMAP[Q+010000000000

 "\Patch #6 DEBUGF.PAT 31-Jan-86 JMS\
 "\Go to BOOTS on DEBUG or JOB stopcodes to get a crash dump\
 "\Output "?HALT stopcode" instead of "?STOP stopcode" message\
ERRCON:
DEBUGF[DF.RJE+DF.RDC
STPTYP+16T/"/HALT/
COMMON:
PATMAP[Q+004000000000

 "\Patch #7 SYSUFD.PAT 1-Feb-86 JMS *** REMOVED\
 "\Patch to make SYS: be [1,4] always, even if GFD'd to UFD\
 "\Patch was retracted because some accounting programs depend on this bug\
FILUUO:
"\*** DO NOT ADD THIS PATCH *** CHKPP1+2/JFCL ***\
PATMAP[Q+002000000000=

 "\Patch #8 TTYZNE.PAT 7-Feb-86 JMS *** REMOVED BY #10\
 "\Make TTYZNE be a DEBUG stopcode until INFO stopcodes work right\
SCNSER:
 "\Removed by patch 10 *** TTYZNE/	.+2[400003,,0  ***\
COMMON:
PATMAP[Q+001000000000=

 "\Patch #9 BIOZAP.PAT 18-Feb-86 CARL\
 "\Check for prior circuit zap on BIO port before output\
SCNSER:
PAT+0/0
PAT+1/AOS PAT+0
PAT+2/HLRZ T3,LDBBIO(U)
PAT+3/SKIPE T3
PAT+4/JRST GOBOT+3
PAT+5/MOVSI T3,LNLZIN
PAT+6/TDNE T3,LDBLIN(U)
PAT+7/JRST FINLIN
PAT+10/XCT PAT+11
PAT+11/PUSHJ P,DIE
PAT+12/"+BIOZAP+
PAT+13/S$DEBUG,,CPOPJ
GOBOT+2/JRST PAT+1
PAT+14/PAT:

PAT+0/0
PAT+1/AOS PAT+0
PAT+2/MOVSI T1,LNLZIN
PAT+3/TDNE T1,LDBLIN(U)
PAT+4/POPJ P,
PAT+5/MOVSI T1,LDLPTY
PAT+6/JRST GETBIO+1
GETBIO/JRST PAT+1
PAT+7/PAT:
PATSIZ/PAT
COMMON:
PATMAP[Q+000400000000

 "\Patch #10 DIETYO.PAT 9-May-86 JMS \
 "\Make INFO stopcodes like BADSAT and WRTSAT not cause recursion in DIE\
ERRCON:
PAT+0/MOVEI U,SCNLDB
PAT+1/PUSHJ P,CCTYO
PAT+2/JRST UPOPJ
DIETYO+1/JRST PAT
PAT+3/PAT:
SCNSER:
CCTYO+3/CAIL T1,480.
 "\Update the KEY in JOB and DEBUG stopcodes so base won't get unhappy\
PAT+0/PUSH P,T1
PAT+1/MOVE T1,@KEYSET-1
PAT+2/XCT KEYSET
PAT+3/POP P,T1
PAT+4/JRST CTYTYO
CTYWAT/JRST PAT
PAT+5/PAT:
PATSIZ/PAT
COMMON:
PATMAP[Q+000200000000

 "\Change configuration name to XxxP034/P-10\
CONFIG+0T/
CONFIG+1T/
CONFIG+2T/"\-10\
 "\Must do systems with 3-digit host numbers by hand\
   
0010�	
 0020�	%%PAT!MOVEI P,%%PAT+145
   0030�	OUTCHI 15
  0040�	OUTCHI 12
  0050�	MOVSI T3,CONFIG-SYSDAT
    0060�	SETZ T2,
   0070�	%%FET T1,CONFIG(T3)
  0080�	%%END
 0090�	OUTSTR T1
  0100�	AOBJN T3,.-3
    0110�	OUTCHI 40
  0120�	SKIPA T1,.+1
    0130�	"/APR#/
    0140�	SETZ T2,
   0150�	OUTSTR T1
  0160�	%%FET T1,SERIAL
 0170�	%%END
 0180�	PUSHJ P,%%PAT+100
    0190�	OUTCHI 40
  0200�	%%FET T1,THSDAT
 0210�	%%END
 0220�	MOVEM T1,%%PAT+140
   0230�	%%FET T1,TIME
   0240�	%%END
 0250�	MOVEM T1,%%PAT+141
   0260�	MOVSI T1,400020
 0270�	MOVEM T1,%%PAT+142
                       0280�	MOVEI T1,%%PAT+140
   0290�	DATUUO T1,
 0300�	JFCL
  0310�	MOVE T1,%%PAT+140
    0320�	IDIVI T1,31.
    0330�	PUSH P,T2
  0340�	IDIVI T1,12.
    0350�	EXCH T1,(P)
0360�	PUSH P,T1
  0370�	MOVEI T1,1(T2)
  0380�	PUSHJ P,%%PAT+100
    0390�	OUTCHI "/
 0400�	POP P,T1
   0410�	ADDI T1,1
  0420�	PUSHJ P,%%PAT+100
    0430�	POP P,T1
   0440�	ADDI T1,1964.
   0450�	OUTCHI "/
 0460�	PUSHJ P,%%PAT+100
    0470�	OUTCHI 40
  0480�	MOVE T1,%%PAT+141
    0490�	IDIVI T1,3600.
  0500�	IDIVI T1,60.
    0510�	IMULI T1,100.
   0520�	ADD T1,T2
  0530�	PUSHJ P,%%PAT+100
                        0540�	OUTCHI 15
  0550�	OUTCHI 12
  0560�	%%END
  0570�	%%PAT+100!IDIVI T1,10.
    0580�	HRLM T2,(P)
0590�	SKIPE T1
   0600�	PUSHJ P,%%PAT+100
    0610�	HLRZ T1,(P)
0620�	OUTCHI 60(T1)
   0630�	POPJ P,
0640�	0
    
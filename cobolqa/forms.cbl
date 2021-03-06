0010?	 IDENTIFICATION DIVISION.
  0020?	   PROGRAM-ID.  FORMS.
0030?	 
 0040?	 
 0050?	 ENVIRONMENT DIVISION.
0060?	  CONFIGURATION SECTION.
   0070?	   SOURCE-COMPUTER.  ANY.
  0080?	   OBJECT-COMPUTER.  DECSYSTEM-10.
   0090?	 
 0100?	 
 0110?	 DATA DIVISION.
  0120?	 WORKING-STORAGE SECTION.
  0130?	   01  SI                       PIC 9(2) USAGE IS COMPUTATIONAL.
   0140?	   01  SENT.
0150?	     02  S-PART OCCURS 12 TIMES.
0160?	       03  S-TYPE               PIC X.
    0170?	       03  S-VALUE              PIC 9(4) USAGE IS COMPUTATIONAL.
                                                                         0180?	       03  S-LINKC              PIC 9(2) USAGE IS COMPUTATIONAL.
   0190?	       03  S-LINKD              PIC 9(2) USAGE IS COMPUTATIONAL.
   0200?	   01  N                        PIC 9(4) USAGE IS COMPUTATIONAL.
   0210?	   01  NODES.
    0220?	     02  NODE OCCURS 100 TIMES.
 0230?	       03  NODE-S               PIC 9(4) USAGE IS COMPUTATIONAL.
   0240?	       03  NODE-TARGETTYPE      PIC X.
    0250?	       03  NODE-TARGET          PIC 9(4) USAGE IS COMPUTATIONAL.
   0260?	       03  NODE-LINKC           PIC 9(3) USAGE IS COMPUTATIONAL.
                                                                              0270?	       03  NODE-LINKN           PIC 9(3) USAGE IS COMPUTATIONAL.
   0280?	   01  WI                       PIC 9(2) USAGE IS COMPUTATIONAL.
   0290?	   01  WRDS.
0300?	     02  N-WORDS                PIC 9(2) USAGE IS COMPUTATIONAL.
   0310?	     02  WORD OCCURS 40 TIMES.
  0320?	       03  WORD-TYPE            PIC X.
    0330?	       03  WORD-VALUE           PIC 9(4) USAGE IS COMPUTATIONAL.
   0340?	   01  S                        PIC 9    USAGE IS COMPUTATIONAL.
   0350?	   01  STACK.
    0360?	     02  STK OCCURS 9 TIMES.
    0370?	       03  STK-SI               PIC 9(2) USAGE IS COMPUTATIONAL.
                  0380?	       03  STK-WI               PIC 9(2) USAGE IS COMPUTATIONAL.
   0390?	       03  STK-N                PIC 9(4) USAGE IS COMPUTATIONAL.
   0400?	       03  STK-CURRN            PIC 9(4) USAGE IS COMPUTATIONAL.
   0410?	   01  I                        PIC 9(4) USAGE IS COMPUTATIONAL.
   0420?	   01  FAIL-FLAG                PIC X.
    0430?	   01  ABORT-MSG                PIC X(30).
0440?	 
 0450?	 
 0460?	 PROCEDURE DIVISION.
  0470?	 EXECUTIVE SECTION.
   0480?	 EXEC-10.
   0490?	*  <SENTENCE> ::= <LOOK>/PAUSE
  0500?	*  <LOOK>     ::= LOOK+AROUND/LOOK
   0505?	     DISPLAY "EXEC-10".
                        0510?	     MOVE 1 TO NODE-S (1).
 0520?	     MOVE "S" TO NODE-TARGETTYPE (1).
0530?	     MOVE 3 TO NODE-TARGET (1).
 0540?	     MOVE 0 TO NODE-LINKC (1)
   0550?	     MOVE 2 TO NODE-LINKN (1).
  0560?	     MOVE "W" TO NODE-TARGETTYPE (2).
0570?	     MOVE 1 TO NODE-TARGET (2).
 0580?	     MOVE 0 TO NODE-LINKC (2).
  0590?	     MOVE 0 TO NODE-LINKN (2).
  0600?	     MOVE 2 TO NODE-S (3)
  0610?	     MOVE "W" TO NODE-TARGETTYPE (3)
 0620?	     MOVE 2 TO NODE-TARGET (3).
 0630?	     MOVE 4 TO NODE-LINKC (3).
  0640?	     MOVE 5 TO NODE-LINKN (3).
  0650?	     MOVE "W" TO NODE-TARGETTYPE (4).
                              0660?	     MOVE 3 TO NODE-TARGET (4).
 0670?	     MOVE 0 TO NODE-LINKC (4).
  0680?	     MOVE 5 TO NODE-LINKN (4).
  0690?	     MOVE "W" TO NODE-TARGETTYPE (5).
0700?	     MOVE 2 TO NODE-TARGET (5).
 0710?	     MOVE 0 TO NODE-LINKC (5).
  0720?	     MOVE 0 TO NODE-LINKN (5).
  0730?	 
 0740?	     MOVE 1 TO N-WORDS.
    0750?	     MOVE "W" TO WORD-TYPE (1).
 0760?	     MOVE 1 TO WORD-VALUE (1).
  0770?	 
 0780?	     MOVE 1 TO WI.
    0790?	     MOVE 1 TO SI.
    0800?	     MOVE 0 TO S.
0810?	     MOVE 1 TO N.
0820?	 NEW-NODE.
  0830?	     ADD 1 TO S.
 0840?	     MOVE SI TO STK-SI (S).
                              0850?	     MOVE WI TO STK-WI (S).
0860?	     MOVE N TO STK-N (S).
  0870?	     MOVE N TO STK-CURRN (S).
   0880?	 LOOP.
 0890?	     IF NODE-TARGETTYPE (N) EQUALS "S"
    0900?	         MOVE "S" TO S-TYPE (SI)
0910?	         MOVE NODE-S (N) TO S-VALUE (SI)
  0920?	         PERFORM LINK-S
    0930?	         MOVE SI TO I
 0940?	         ADD 1 TO SI
  0950?	         MOVE SI TO S-LINKD (I)
 0960?	         MOVE NODE-TARGET (N) TO N
   0970?	         MOVE N TO STK-CURRN (S)
0980?	         GO TO NEW-NODE
    0990?	     ELSE
   1000?	     IF NODE-TARGETTYPE (N) EQUALS "W"
    1010?	         IF WORD-TYPE (WI) EQUALS "W"
     1020?	          AND NODE-TARGET (N) EQUALS WORD-VALUE (WI)
1030?	             MOVE "W" TO S-TYPE (SI)
 1040?	             MOVE WORD-VALUE (WI) TO S-VALUE (SI)
   1050?	             ADD 1 TO WI
   1060?	             PERFORM LINK-S
1070?	             ADD 1 TO SI
   1080?	         ELSE
    1090?	             GO TO BAD-ATOM
1100?	     ELSE
   1110?	     IF NODE-TARGETTYPE (N) EQUALS "N"
    1120?	         IF WORD-TYPE (WI) EQUALS "N"
1130?	             MOVE "W" TO S-TYPE (SI)
 1140?	             MOVE WORD-VALUE (WI) TO S-VALUE (SI)
   1150?	             ADD 1 TO WI
   1160?	             PERFORM LINK-S
                    1170?	             ADD 1 TO SI
   1180?	         ELSE
    1190?	             GO TO BAD-ATOM
1200?	     ELSE
   1210?	         MOVE "FORMS-1" TO ABORT-MSG
 1220?	         CALL ABORT.
  1230?	 GOOD-COMPONENT.
 1240?	* THE NODE COMPONENT (I.E. NODE, WORD, OR NUMBER) MATCHES THE SENTENCE
  1250?	     MOVE NODE-LINKC (N) TO N.
  1260?	     MOVE N TO STK-CURRN (S).
   1270?	     IF N NOT EQUAL ZERO
   1280?	         GO TO LOOP.
  1290?	* ALL COMPONENTS OF THE NODE MATCH THE SENTENCE
1300?	     SUBTRACT 1 FROM S.
    1310?	     IF S NOT EQUAL ZERO
   1320?	         MOVE STK-CURRN (S) TO N
                                   1330?	         GO TO GOOD-COMPONENT.
  1340?	* A SENTENCE HAS BEEN RECOGNIZED
1350?	     IF WI NOT EQUALS N-WORDS
   1360?	         DISPLAY "EXTRA WORDS BEYOND RECOGNIZABLE SENTENCE"
   1370?	         MOVE "T" TO FAIL-FLAG
  1380?	     ELSE
   1390?	         MOVE "F" TO FAIL-FLAG.
 1400?	* EXIT WITH  SENT  AND  FAIL-FLAG
    1410?	     DISPLAY SENT.
    1420?	     STOP RUN.
   1430?	 
 1440?	 
 1450?	 BAD-NODE.
  1460?	     SUBTRACT 1 FROM S.
    1470?	     IF S EQUALS ZERO
 1480?	          MOVE "T" TO FAIL-FLAG
 1490?	          STOP RUN.
   1500?	 BAD-ATOM.
  1510?	     MOVE STK-SI (S) TO SI.
                    1520?	     MOVE STK-WI (S) TO WI.
1530?	     MOVE NODE-LINKN (N) TO N.
  1540?	     MOVE N TO STK-CURRN (S).
   1550?	     IF N NOT EQUAL ZERO
   1560?	         GO TO LOOP
   1570?	     ELSE
   1580?	         GO TO BAD-NODE.
   1590?	 
 1600?	 
 1610?	 LINK-S SECTION.
 1620?	 LINK-S-10.
 1630?	     MOVE ZERO TO S-LINKC (SI).
 1640?	     MOVE ZERO TO S-LINKD (SI).
 1650?	     MOVE STK-SI (S) TO I.
 1660?	     IF I EQUALS ZERO
 1670?	          GO TO LINK-S-30.
 1680?	 LINK-S-20.
 1690?	     MOVE S-LINKC (I) TO I.
1700?	     IF I NOT EQUAL ZERO
   1710?	         GO TO LINK-S-20.
  1720?	 LINK-S-30.
                1730?	     IF I NOT EQUALS SI
    1740?	         MOVE SI TO S-LINKC (I).

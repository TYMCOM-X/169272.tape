10      FOR X1=1 TO 20
15      FOR Y=1 TO 6000
16      X=X1
20      S=X1
30      IF X <= 1 THEN 70
40      X=X-1
45      S=S*X
46      GO TO 30
70      NEXT Y
75      PRINT X1,S
80      NEXT X1
100     END
  
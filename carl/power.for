C	PROGRAM TO READ IN A NUMBER AND PRINT OUT THE FACTORS
C	IN GROUPS OF 2 -- SO NO REPITION OF FACTORS OCCURS.
C
C	METHOD IS TO:
C		1.	READ THE NUMBER
C		2.	CALCULATE THE SQUARE ROOT OF THE NUMBER
C			TO USE AS THE MIDPOINT IN THE SEARCH
C			FOR UNIQUE FACTORS.
C		3.	TRUNCATE THIS TO AN INTEGER TO OBTAIN
C			THE NECESSARY UPPER INTEGER LIMIT.
C		4.	LOOP FROM 1 TO THIS NUMBER TESTING FOR
C			EVEN FACTORS & PRINT OUT EACH PAIR
C			WHEN FOUND.
C		5.	EXIT WHEN NUMBER TO FACTOR IS 0,
C			OR WHEN USER TYPES A <CARRIAGE-RETURN>.
C
C		6.	NOTE: THE FACTOR'S 1 & THE NUMBER ITSELF ARE NOT
C			CONSIDERED IN THIS CASE, SO PRIME NUMBERS
C			ARE DULY RECOGNIZED.
100	TYPE 1
1	FORMAT(//1X,'Please type in your number: '$)
	ACCEPT 2,NUM
2	FORMAT(I)
	IF (NUM.EQ.0) GO TO 20
	INC=0
	IF (NUM.LT.0)TYPE 30,NUM
30	FORMAT(1X,'The number:',I8,' is negative thus either of'/1X,
	1'the factors in each group should be multiplied by -1'/1X,
	2'to obtain the correct results'/)
	NUMBER=IABS(NUM)
	DO 10 I=2,IFIX(SQRT(FLOAT(NUMBER)))
	IF (NUMBER-((NUMBER/I)*I).NE.0) GO TO 10
	INT=NUMBER/I
	TYPE 3,I,INT
3	FORMAT(1X,'Factors: ',i,',',i)
	INC=INC+1
10	CONTINUE
	IF (INC.GT.0) GO TO 15
	TYPE 11,NUMBER
11	FORMAT(/1X,'The number: ',I,' is a prime number!')
	GO TO 100
15	TYPE 16,NUMBER
16	FORMAT(1X,'Divide evenly into the number: ',I)
	GO TO 100
20	END

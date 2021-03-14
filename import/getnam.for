	SUBROUTINE GETNAM(NUMBER,AREA,MAXCHR)
	IMPLICIT INTEGER (A-Z)
	DIMENSION FNUM(1), FORMS(5)
	DIMENSION NAME(15),AREA(3)
	DATA FORMS/'(I1)','(I2)','(I3)','(I4)','(I5)'/

5	READ (5,10,END=5,ERR=5)NAME
10	FORMAT(15A1)

	COMMAS=0
	ALPHAS=0
	NUMS  =0
	COMMA =0
	ALPHA =0
	NUM   =0
	AREA(1)  =' '
	IF (MAXCHR .GT. 5) AREA(2)  =' '
	IF (MAXCHR .GT. 10) AREA(3)  =' '
	NAREA =' '
	NUMBER=0

	DO 20 I=1,15
	IF(NAME(I).GE.'a'.AND.NAME(I).LE.'z')
	1NAME(I)=NAME(I).AND."577777777777
	IF(NAME(I).NE.',')GO TO 11
	COMMAS=COMMAS+1
	COMMA=I
11	IF(NAME(I).LT.'0'.OR.NAME(I).GT.'9')GO TO 12
	NUMS=NUMS + 1
	IF(NUMS.EQ.1)NUM=I
12	IF(NAME(I).LT.'A'.OR.NAME(I).GT.'Z')GO TO 14
13	ALPHAS=ALPHAS + 1
	IF(ALPHAS.EQ.1)ALPHA=I
	IF(ALPHA.NE.0.AND.NUM.NE.0.AND.NUM.GT.ALPHA)GO TO 60
	GO TO 20
14	IF (NAME(I).EQ.'-') GO TO 13
20	CONTINUE

	IF(NUMS.EQ.0.AND.ALPHAS.EQ.0.AND.COMMAS.EQ.0)RETURN
	IF(ALPHAS.GT.MAXCHR)ALPHAS=MAXCHR
	IF(ALPHAS.NE.0)
     *	ENCODE(ALPHAS,10,AREA) (NAME(I),I=ALPHA,(ALPHA+ALPHAS-1))
	IF (NUMS.GT.(ALPHA-NUM).AND.(ALPHA-NUM).GT.0)NUMS = ALPHA-NUM
	IF(NUMS.GT.5)NUMS=5
	IF(NUMS.EQ.0)GO TO 50
	ENCODE(NUMS,10,NAREA) (NAME(I),I=NUM,(NUM+NUMS-1))
	FNUM(1)=FORMS(NUMS)
	DECODE(NUMS,FNUM,NAREA) NUMBER
50	RETURN
60	TYPE 70,NAME(I)
70	FORMAT(1X,'ILLEGAL CHARACTER IN INPUT LINE "',A1,'"'
	1/1X,'PLEASE RETYPE LINE')
	GO TO 5
	END
 
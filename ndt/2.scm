File 1)	DSK:CFDEF.SLO	created: 1856 08-APR-82
File 2)	DSK:CFDEF.SLO[3,222635]	created: 2312 05-MAR-81

1)1		*old*no-carry	= 0 default
1)		*old*carry	= 1 $
1)	alu-d-range = field 1 25.
****
2)1		no-carry	= 0 default
2)		carry		= 1 $
2)	alu-d-range = field 1 25.
**************
1)1		0-D'ALU    = SOURCE D,0 carry-in[1] 1
1)		0-D-1'ALU  = SOURCE D,0 carry-in[0] 1
1)		0-AC'ALU   = SOURCE 0,B carry-in[1] 2
1)		0-AC-1'ALU = SOURCE 0,B carry-in[0] 2
1)		0-Q	= SOURCE 0,Q carry-in[1] 2
1)		0-Q-1	= SOURCE 0,Q carry-in[0] 2
1)		IX+D	= SOURCE D,A ACSEL 1 carry-in[0] 0
1)		D+1	= SOURCE D,0 carry-in[1] 0
1)		Q+1	= SOURCE 0,Q car ry-in[1] 0
1)		AC+1	= SOURCE 0,B carry-in[1] 0
1)		D-1	= SOURCE D,0 carry-in[0] 2
1)		AC-1	= SOURCE 0,B carry-in[0] 1
1)		Q-1	= SOURCE 0,Q carry-in[0] 1
1)		Q-D-1	= SOURCE D,Q carry-in[0] 1
1)		D-Q-1	= SOURCE D,Q carry-in[0] 2
1)		NOTAC	= SOURCE 0,B 7
****
2)1		0-D'ALU = SOURCE D,0 CARRY 1
2)		0-AC'ALU = SOURCE 0,B CARRY 2
2)		0-Q	= SOURCE 0,Q CARRY 2
2)		IX+D	= SOURCE D,A ACSEL 1 0
2)		D+1	= SOURCE D,0 CARRY 0
2)		Q+1	= SOURCE 0,Q CARRY 0
2)		AC+1	= SOURCE 0,B CARRY 0
2)		D-1	= SOURCE D,0 2
2)		AC-1	= SOURCE 0,B 1
2)		Q-1	= SOURCE 0,Q 1
2)		Q-D-1	= SOURCE D,Q 1
2)		D-Q-1	= SOURCE D,Q 2
2)		NOTAC	= SOURCE 0,B 7
**************
1)1		MULAC-D = COND-SOURCE D,A carry-in[1] 1
1)		MULAC+D	= COND-SOURCE 0,A-OR-D,A carry-in[0] 0
1)		DIVAC+D	= COND-SOURCE D,A carry-in[0] 0
1)		DIVAC-D = COND-SOURCE D,A carry-in[1] 1
1)		D+Q+1	= SOURCE D,Q carry-in[1] 0
1)		D-0'ALU	= SOURCE D,0 carry-in[1] 2
1)	.define sources [ R S SRC ]
1)	[	R`+`S`'alu`src	 = source src carry-in[0] 0
1)		S`+`R`'ALU`SRC	 = source src carry-in[0] 0
1)		S`-`R`'alu`src	 = source src carry-in[1] 1
1)		R`-`S`'alu`src	 = source src carry-in[1] 2
1)		R`+`S`+1'alu`src = source src carry-in[1] 0
1)		S`+`R`+1'alu`src = source src carry-in[1] 0
1)		S`-`R`-1'alu`src = source src carry-in[0] 1
1)		R`-`S`-1'alu`src = source src carry-in[0] 2
File 1)	DSK:CFDEF.SLO	created: 1856 08-APR-82
File 2)	DSK:CFDEF.SLO[3,222635]	created: 2312 05-MAR-81

1)		R`or`S`'alu`src	 = source src 3
1)		S`or`R`'alu`src	 = source src 3
1)		R`&`S`'alu`src	 = source src 4
****
2)1		MULAC-D = COND-SOURCE D,A CARRY 1
2)		MULAC+D	=	COND-SOURCE 0,A-OR-D,A 0
2)		DIVAC+D	=	COND-SOURCE D,A 0
2)		DIVAC-D = COND-SOURCE D,A CARRY 1
2)		D+Q+1	= SOURCE D,Q CARRY 0
2)		D-0'ALU	= SOURCE D,0 CARRY 2
2)	.define sources [ R S SRC ]
2)	[	R`+`S`'alu`src	= source src 0
2)		S`+`R`'ALU`SRC	= SOURCE SRC 0
2)		S`-`R`'alu`src	= source src CARRY 1
2)		R`-`S`'alu`src	= source src CARRY 2
2)		R`or`S`'alu`src	= source src 3
2)		S`OR`R`'ALU`SRC	= SOURCE SRC 3
2)		R`&`S`'alu`src	= source src 4
**************
1)1		R+S		= carry-in[0] 0
1)		S-R		= carry-in[1] 1
1)		R-S		= carry-in[1] 2
1)		S-R-1		= carry-in[0] 1
1)		R-S-1		= carry-in[0] 2
1)		R+S+1		= carry-in[1] 0
1)		R!S		= 3
1)		R&S		= 4
1)		-R&S		= 5
1)		R#S		= 6
1)		R/#S		= 7 $
1)	SPEC = FIELD 4 55.
****
2)1		R+S		= 0
2)		s-r		= CARRY 1
2)		r-s		= CARRY 2
2)		r!s		= 3
2)		r&S		= 4
2)		-r&s		= 5
2)		r#s		= 6
2)		r/#s		= 7 $
2)	SPEC = FIELD 4 55.
**************
   
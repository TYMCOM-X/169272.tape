      PROCEDURE EXPRESSION;

      VAR
	  LATTR: ATTR;
	  LOP: OPERATOR;
	  LSIZE: ADDRRANGE;
	  B,C,STACKD: BOOLEAN;
	  SUBRNAME: RUNTIMEROUTS;
	  SMIN,SMAX: INTEGER;
	  MULTSSIZE: INTEGER;


	PROCEDURE SMPLEEXPRESSION(FSYS: SETOFSYS);

	VAR
	    LATTR: ATTR;
	    LOP: OPERATOR;
	    SIGNED: BOOLEAN;


	  PROCEDURE TERM(FSYS: SETOFSYS);

	  VAR
	      LATTR: ATTR;
	      LOP: OPERATOR;


	    PROCEDURE LOADSTRINGCONSTANT;

	    VAR
		I: INTEGER;

	    BEGIN
	      WITH GATTR DO
		IF TYPTR <> NIL THEN
		  WITH CVAL.VALP^ DO BEGIN
		    GENBR(BR,(SLGTH + 2) DIV 2);
		    I := 0;
		    WHILE I < SLGTH DO BEGIN
		      GENCONST(ORD(SVAL[I]) + 256 * ORD(SVAL[I + 1]));
		      I := I + 2
		    END;
		    IF ODD(SLGTH+1) THEN
		      GENCONST(ORD(SVAL[I]));
		    GEN2(MOV,REG,PC,AUTDEC,SP);
		    GEN2(SUB,AUTINC,PC,REGDEF,SP);
		    GENCONST(TYPTR^.SIZE + 2)
		    (*HYP. STRINGADDRESS ON STACK*)
		  END
	    END;
	    (*LOADSTRINGCONSTANT*)



	    PROCEDURE FACTOR(FSYS: SETOFSYS);

	    VAR
		LCP: CTP;
		LVP: CSP;
		VARPART: BOOLEAN;
		CSTPART: SET OF 0..63;
		LSP,LSP1: STP;
		J,I,INTSET,K: INTEGER;
		FOURWORDSET: BOOLEAN;
		SCOUNT,LRMIN: INTEGER;
		RANGEPART: BOOLEAN;

	    BEGIN
	      IF NOT (SY IN FACBEGSYS) THEN BEGIN
		ERROR(58);
		SKIP(FSYS OR FACBEGSYS);
		GATTR.TYPTR := NIL
	      END;
	      WHILE SY IN FACBEGSYS DO BEGIN
		CASE SY OF
		(*ID*)
		  IDENT: BEGIN
		    SEARCHID([KONST,VARS,FIELD,FUNC],LCP);
		    INSYMBOL;
		    IF LCP^.KLASS = FUNC THEN BEGIN
		      CALL(FSYS,LCP);
		      GATTR.KIND := EXPR
		    END
		    ELSE IF LCP^.KLASS = KONST THEN
		      WITH GATTR, LCP^ DO BEGIN
			TYPTR := IDTYPE;
			KIND := CST;
			CVAL := VALUES;
			IF STRING(TYPTR) THEN BEGIN

			  (* IF THE STRING CONSTANT HAS NEVER BEEN EMITTED,
			     OR IF IT WAS EMITTED IN A PREVIOUS PSECT, THEN
			     RE-EMIT IT AND UPDATE SYMBOL TABLE RECORD *)
			  IF (KADDR=0) OR (BODYINDEX<>BODYCOUNT) THEN BEGIN
			    LOADSTRINGCONSTANT;
			    KADDR := 2 * CIX - 4 - IDTYPE^.SIZE;
			    BODYINDEX:= BODYCOUNT
			  END
			  ELSE BEGIN
			    GEN2(MOV,REG,PC,AUTDEC,SP);
			    GEN2(SUB,AUTINC,PC,REGDEF,SP);
			    GENCONST(2 * CIX - KADDR);
			    (*HYPOTHETICAL ADDRESS OF STRINGCONSTANT ON THE STACK*)
			  END;
			  IF SY = LBRACK THEN BEGIN
			    SELECTOR(FSYS,NIL);
			    LOAD
			  END
			END ;
		      END
		    ELSE
		      SELECTOR(FSYS,LCP);
		    IF GATTR.TYPTR <> NIL THEN (*ELIM. SUBR. TYPES TO*)
			WITH GATTR, TYPTR^ DO (*SIMPLIFY LATER TESTS*)
			IF FORM = SUBRANGE THEN
			  TYPTR := RANGETYPE
		  END;
		  (*CST*)
		  INTCONST: BEGIN
		    WITH GATTR DO BEGIN
		      TYPTR := INTPTR;
		      KIND := CST;
		      CVAL := VAL
		    END;
		    INSYMBOL
		  END;
		  REALCONST: BEGIN
		    WITH GATTR DO BEGIN
		      TYPTR := REALPTR;
		      KIND := CST;
		      CVAL := VAL
		    END;
		    INSYMBOL
		  END;
		  STRINGCONST: BEGIN
		    WITH GATTR DO BEGIN
		      KIND := CST;
		      IF LGTH = 1 THEN BEGIN
			TYPTR := CHARPTR;
			CVAL := VAL;
			INSYMBOL
		      END
		      ELSE BEGIN
			NEW(LSP,ARRAYS);
			NEW(LSP1,SUBRANGE);
			WITH LSP^ DO BEGIN
			  AELTYPE := CHARPTR;
			  INXTYPE := LSP1;
			  PACKOPT := FALSE;
			  ADDRCORR := 0;
			  SIZE := 2 * ((LGTH + 1) DIV 2);
			END;
			WITH LSP1^ DO BEGIN
			  SIZE := 2;
			  RANGETYPE := INTPTR;
			  MIN.IVAL := 0;
			  MAX.IVAL := LGTH-1
			END;
			TYPTR := LSP;
			CVAL := VAL;
			LOADSTRINGCONSTANT;
			INSYMBOL;
			IF SY = LBRACK THEN BEGIN
			  SELECTOR(FSYS,NIL);
			  LOAD
			END
		      END;
		    END;
		  END;
		  (* ( *)
		  LPARENT: BEGIN
		    INSYMBOL;
		    EXPRESSION(FSYS OR [RPARENT]);
		    IF SY = RPARENT THEN
		      INSYMBOL
		    ELSE
		      ERROR(4)
		  END;
		  (*NOT*)
		  NOTSY: BEGIN
		    INSYMBOL;
		    FACTOR(FSYS);
		    LOAD;
		    GEN1(COM,REGDEF,SP);
		    GEN2(BIC,AUTINC,PC,REGDEF,SP);
		    GENCONST(-2);
		    IF GATTR.TYPTR <> NIL THEN
		      IF GATTR.TYPTR <> BOOLPTR THEN BEGIN
			ERROR(135);
			GATTR.TYPTR := NIL
		      END;
		  END;
		  (*[*)
		  LBRACK: BEGIN
		    INSYMBOL;
		    CSTPART := [ ];
		    VARPART := FALSE;
		    FOURWORDSET := FALSE;
		    RANGEPART := FALSE;
		    NEW(LSP,POWER);
		    WITH LSP^ DO BEGIN
		      ELSET := NIL;
		      SIZE := 2
		    END;
		    IF SY = RBRACK THEN BEGIN
		      WITH GATTR DO BEGIN
			TYPTR := LSP;
			KIND := CST
		      END;
		      INSYMBOL
		    END
		    ELSE BEGIN
		      LOOP
			EXPRESSION(FSYS OR [COMMA,COLON,RBRACK]);
			IF GATTR.TYPTR <> NIL THEN
			  IF GATTR.TYPTR^.FORM <> SCALAR THEN BEGIN
			    ERROR(136);
			    GATTR.TYPTR := NIL
			  END
			  ELSE IF COMPTYPES(LSP^.ELSET,GATTR.TYPTR) THEN BEGIN
			    IF GATTR.KIND = CST THEN BEGIN
			      I := GATTR.CVAL.IVAL;
			      IF GATTR.TYPTR = CHARPTR THEN
				I := I - 40B;
			      IF I > 15 THEN
				FOURWORDSET := TRUE;
			      CSTPART := CSTPART OR [I];
			      IF (I > 63) OR (I < 0) THEN
				ERROR(604);
			      IF SY = COLON THEN BEGIN
				RANGEPART := TRUE;
				LRMIN := I
			      END
			      ELSE IF RANGEPART THEN BEGIN
				LRMIN := LRMIN + 1;
				WHILE LRMIN < I DO BEGIN
				  CSTPART := CSTPART OR [LRMIN];
				  LRMIN := LRMIN + 1;
				END;
				RANGEPART := FALSE
			      END
			    END
			    ELSE BEGIN
			      LOAD;
			      IF (SY = COLON) OR RANGEPART THEN BEGIN
				ERROR(21);
				RANGEPART := NOT RANGEPART
			      END;
			      IF GATTR.TYPTR = CHARPTR THEN BEGIN
				GEN2(SUB,AUTINC,PC,REGDEF,SP);
				GENCONST(40B);
			      END;
			      IF NOT VARPART THEN BEGIN
				VARPART := TRUE;
				GETBOUNDS(GATTR.TYPTR,SMIN,SMAX) ;
				IF (SMAX <> 0) AND (SMAX <= 15) AND
				  NOT FOURWORDSET THEN BEGIN
				    GEN2(MOV,REGDEF,SP,REG,AR);
				    GEN1(CLR,REGDEF,SP);
				    GEN2(MOV,REG,AR,AUTDEC,SP)
				  END
				  ELSE BEGIN
				    GENSUBRCALL(INITS);
				    FOURWORDSET := TRUE
				  END;
			      END;
			      GENSUBRCALL(SGSIN)
			    END;
			    LSP^.ELSET := GATTR.TYPTR;
			    GATTR.TYPTR := LSP
			  END
			  ELSE
			    ERROR(137);
		      EXIT IF NOT (SY IN [COMMA,COLON]);
			INSYMBOL
		      END;
		      IF SY = RBRACK THEN
			INSYMBOL
		      ELSE
			ERROR(12)
		    END;
		    GATTR.KIND := EXPR;
		    IF FOURWORDSET THEN
		      LSP^.SIZE := 8;
		    IF NOT (VARPART AND (CSTPART = [])) THEN BEGIN
		      IF FOURWORDSET THEN
			SCOUNT := 63
		      ELSE
			SCOUNT := 15;
		      FOR K := LSP^.SIZE DIV 2 DOWNTO 1 DO BEGIN
			J := 40000B;
			INTSET := 0;
			IF SCOUNT IN CSTPART THEN
			  INTSET := INTSET + 100000B;
			SCOUNT := SCOUNT - 1;
			FOR I := 0 TO 14 DO BEGIN
			  IF SCOUNT IN CSTPART THEN
			    INTSET := INTSET + J;
			  J := J DIV 2;
			  SCOUNT := SCOUNT - 1
			END;
			IF INTSET = 0 THEN
			  GEN1(CLR,AUTDEC,SP)
			ELSE BEGIN
			  GEN2(MOV,AUTINC,PC,AUTDEC,SP);
			  GENCONST(INTSET)
			END;
		      END;
		      IF VARPART THEN
			IF FOURWORDSET THEN
			  GENSUBRCALL(UNI4)
			ELSE
			  GEN2(BIS, AUTINC,SP,REGDEF,SP);
		    END
		  END
		END (*CASE*);
		IF NOT (SY IN FSYS) THEN BEGIN
		  ERROR(6);
		  SKIP(FSYS OR FACBEGSYS)
		END
	      END (*WHILE*)
	    END (*FACTOR*);

	  BEGIN (*TERM*)
	    FACTOR(FSYS OR [MULOP]);
	    WHILE SY = MULOP DO BEGIN
	      LOAD;
	      LATTR := GATTR;
	      LOP := OP;
	      INSYMBOL;
	      FACTOR(FSYS OR [MULOP]);
	      LOAD;
	      IF (LATTR.TYPTR <> NIL) AND (GATTR.TYPTR <> NIL) THEN
		CASE LOP OF
		(***)
		  MUL:
		    IF LATTR.TYPTR^.FORM = POWER THEN BEGIN
		     IF COMPTYPES(LATTR.TYPTR,GATTR.TYPTR) THEN BEGIN
		      IF LARGESET (LATTR) THEN GENSUBRCALL (INT4)
		      ELSE BEGIN
			GEN1 (COM,REGDEF,SP);
			GEN2 (BIC,AUTINC,SP,REGDEF,SP);
		      END
		     END
		     ELSE ERROR(134)
		    END
		    ELSE IF (LATTR.TYPTR = INTPTR) AND (GATTR.TYPTR = INTPTR) THEN
		      MULTIPLY
		    ELSE BEGIN
		      IF LATTR.TYPTR = INTPTR THEN BEGIN
			GENSUBRCALL(FLO);
			LATTR.TYPTR := REALPTR
		      END
		      ELSE IF GATTR.TYPTR = INTPTR THEN BEGIN
			GENSUBRCALL(FLT);
			GATTR.TYPTR := REALPTR
		      END;
		      IF (LATTR.TYPTR = REALPTR) AND (GATTR.TYPTR = REALPTR)
			THEN
			  GENSUBRCALL(MPR)
			ELSE BEGIN
			  ERROR(134);
			  GATTR.TYPTR := NIL
			END
		    END;
		    (* / *)
		  RDIV: BEGIN
		    IF GATTR.TYPTR = INTPTR THEN BEGIN
		      GENSUBRCALL(FLT);
		      GATTR.TYPTR := REALPTR
		    END;
		    IF LATTR.TYPTR = INTPTR THEN BEGIN
		      GENSUBRCALL(FLO);
		      LATTR.TYPTR := REALPTR
		    END;
		    IF (LATTR.TYPTR = REALPTR) AND (GATTR.TYPTR = REALPTR) THEN
		      GENSUBRCALL(DVR)
		    ELSE BEGIN
		      ERROR(134);
		      GATTR.TYPTR := NIL
		    END
		  END;
		  (*DIV*)
		  IDIV:
		    IF (LATTR.TYPTR = INTPTR) AND (GATTR.TYPTR = INTPTR) THEN
		      GENSUBRCALL(DVI)
		    ELSE BEGIN
		      ERROR(134);
		      GATTR.TYPTR := NIL
		    END;
		    (*MOD*)
		  IMOD:
		    IF (LATTR.TYPTR = INTPTR) AND (GATTR.TYPTR = INTPTR) THEN
		      GENSUBRCALL(MODI)
		    ELSE BEGIN
		      ERROR(134);
		      GATTR.TYPTR :=
		    END;
		    (*AND*)
		  ANDOP:
		    IF (LATTR.TYPTR = BOOLPTR) AND (GATTR.TYPTR = BOOLPTR)
		      THEN BEGIN
			GEN1(COM,REGDEF,SP);
			GEN2(BIC,AUTINC,SP,REGDEF,SP)
		      END
		    ELSE IF (LATTR.TYPTR^.FORM = POWER) THEN
		     IF COMPTYPES(LATTR.TYPTR,GATTR.TYPTR) THEN
		      IF LARGESET(LATTR) THEN
			GENSUBRCALL(INT4)
		      ELSE BEGIN
			GEN1(COM,REGDEF,SP); (*INT1*)
			GEN2(BIC,AUTINC,SP,REGDEF,SP)
		      END
		     ELSE ERROR(134)
		    ELSE BEGIN
		      ERROR(134);
		      GATTR.TYPTR := NIL
		    END
		END (*CASE*)
	      ELSE
		GATTR.TYPTR := NIL
	    END (*WHILE*)
	  END (*TERM*);

	BEGIN (*SIMPLEEXPRESSION*)
	  SIGNED := FALSE;
	  IF (SY = ADDOP) AND (OP IN [PLUS,MINUS]) THEN BEGIN
	    SIGNED := OP = MINUS;
	    INSYMBOL
	  END;
	  TERM(FSYS OR [ADDOP]);
	  IF SIGNED THEN BEGIN
	    LOAD;
	    IF GATTR.TYPTR = INTPTR THEN
	      GEN1(NEG,REGDEF,SP)
	    ELSE IF GATTR.TYPTR = REALPTR THEN BEGIN
	      GEN1(TST,REGDEF,SP);
	      GENBR(BEQ,2); (*TO PREVENT -0*)
	      GEN2(ADD,AUTINC,PC,REGDEF,SP);
	      GENCONST(100000B);
	    END
	    ELSE BEGIN
	      ERROR(134);
	      GATTR.TYPTR := NIL
	    END
	  END;
	  WHILE SY = ADDOP DO BEGIN
	    LOAD;
	    LATTR := GATTR;
	    LOP := OP;
	    INSYMBOL;
	    TERM(FSYS OR [ADDOP]);
	    LOAD;
	    IF (LATTR.TYPTR <> NIL) AND (GATTR.TYPTR <> NIL) THEN
	      CASE LOP OF
	      (*+*)
		PLUS:
		  IF LATTR.TYPTR^.FORM = POWER THEN BEGIN
		   IF COMPTYPES(LATTR.TYPTR,GATTR.TYPTR) THEN BEGIN
		    IF LARGESET (LATTR) THEN
		      GENSUBRCALL (UNI4)
		    ELSE GEN2 (BIS,AUTINC,SP,REGDEF,SP);
		   END
		   ELSE ERROR(134)
		  END
		  ELSE IF (LATTR.TYPTR = INTPTR) AND (GATTR.TYPTR = INTPTR) THEN
		    GEN2(ADD,AUTINC,SP,REGDEF,SP)
		  ELSE BEGIN
		    IF LATTR.TYPTR = INTPTR THEN BEGIN
		      GENSUBRCALL(FLO);
		      LATTR.TYPTR := REALPTR
		    END
		    ELSE IF GATTR.TYPTR = INTPTR THEN BEGIN
		      GENSUBRCALL(FLT);
		      GATTR.TYPTR := REALPTR
		    END;
		    IF (LATTR.TYPTR = REALPTR) AND (GATTR.TYPTR = REALPTR) THEN
		      GENSUBRCALL(ADR)
		    ELSE BEGIN
		      ERROR(134);
		      GATTR.TYPTR := NIL
		    END
		  END;
		  (*-*)
		MINUS:
		  IF (LATTR.TYPTR = INTPTR) AND (GATTR.TYPTR = INTPTR) THEN
		    GEN2(SUB,AUTINC,SP,REGDEF,SP)
		  ELSE BEGIN
		    IF LATTR.TYPTR = INTPTR THEN BEGIN
		      GENSUBRCALL(FLO);
		      LATTR.TYPTR := REALPTR
		    END
		    ELSE IF GATTR.TYPTR = INTPTR THEN BEGIN
		      GENSUBRCALL(FLT);
		      GATTR.TYPTR := REALPTR
		    END;
		    IF (LATTR.TYPTR = REALPTR) AND (GATTR.TYPTR = REALPTR) THEN
		      GENSUBRCALL(SBR)
		    ELSE IF LATTR.TYPTR^.FORM = POWER THEN
		      IF LARGESET(LATTR) THEN
			GENSUBRCALL(DIF4)
		      ELSE
			GEN2(BIC,AUTINC,SP,REGDEF,SP)
		    ELSE BEGIN
		      ERROR(134);
		      GATTR.TYPTR := NIL
		    END
		  END;
		  (*OR*)
		OROP:
		  IF (LATTR.TYPTR = BOOLPTR) AND (GATTR.TYPTR = BOOLPTR) THEN
		    GEN2(BIS,AUTINC,SP,REGDEF,SP)
		  ELSE IF LATTR.TYPTR^.FORM = POWER THEN
		   IF COMPTYPES(LATTR.TYPTR,GATTR.TYPTR) THEN
		    IF LARGESET(LATTR) THEN
		      GENSUBRCALL(UNI4)
		    ELSE
		      GEN2(BIS,AUTINC,SP,REGDEF,SP)
		   ELSE ERROR(134)
		  ELSE BEGIN
		    ERROR(134);
		    GATTR.TYPTR := NIL;
		  END
	      END (*CASE*)
	    ELSE
	      GATTR.TYPTR := NIL
	  END (*WHILE*)
	END (*SIMPLEEXPRESSION*);

	(*$Y+*)   (* NEW MODULE *)


      BEGIN (*EXPRESSION*)
	MULTSSIZE := 0;
	SMPLEEXPRESSION(FSYS OR [RELOP]);
	IF SY = RELOP THEN BEGIN
	  STACKD := FALSE;
	  IF GATTR.TYPTR <> NIL THEN
	    IF GATTR.TYPTR^.FORM <= POWER THEN
	      LOAD
	    ELSE IF GATTR.KIND = EXPR THEN
	      STACKD := TRUE
	    ELSE BEGIN
	      LOADADDRESS;
	      IF GATTR.TYPTR^.FORM = ARRAYS THEN (*HYP --> ACT*)
		IF GATTR.TYPTR^.ADDRCORR <> 0 THEN BEGIN
		  GEN2(ADD,AUTINC,PC,REGDEF,SP);
		  GENCONST(GATTR.TYPTR^.ADDRCORR)
		END
	    END;
	  LATTR := GATTR;
	  LOP := OP;
	  INSYMBOL;
	  SMPLEEXPRESSION(FSYS);
	  IF GATTR.TYPTR <> NIL THEN
	    IF GATTR.TYPTR^.FORM <= POWER THEN
	      LOAD
	    ELSE IF STACKD THEN (*MULTIPLE LEFTM ON STACK*)
	    BEGIN
	      IF GATTR.KIND = EXPR THEN BEGIN
		GEN2(MOV,REG,SP,REG,AR); (*LOAD RIGHT MEMBER ADDR*)
		MULTSSIZE := GATTR.TYPTR^.SIZE;
	      END
	      ELSE BEGIN
		LOADADDRESS;
		GEN2(MOV,AUTINC,SP,REG,AR); (*LOAD RIGHT MEMBER ADDRESS*)
		IF GATTR.TYPTR^.FORM = ARRAYS THEN
		  IF GATTR.TYPTR^.ADDRCORR <> 0 THEN BEGIN
		    GEN2(ADD,AUTINC,PC,REG,AR);
		    GENCONST(GATTR.TYPTR^.ADDRCORR)
		  END
	      END;
	      GEN2(MOV,REG,SP,REG,AD); (*LOAD DESTINATIONADDRESS*)
	      IF MULTSSIZE <> 0 THEN BEGIN
		GEN2(ADD,AUTINC,PC,REG,AD);
		GENCONST(MULTSSIZE)
	      END;
	      MULTSSIZE := MULTSSIZE + LATTR.TYPTR^.SIZE
	    END
	    ELSE IF GATTR.KIND = EXPR THEN BEGIN
	      STACKD := TRUE;
	      GEN2(MOV,REG,SP,REG,AR);
	      MULTSSIZE := GATTR.TYPTR^.SIZE;
	      GEN2(MOV,INDEX,SP,REG,AD);
	      GENCONST(MULTSSIZE);
	      MULTSSIZE := MULTSSIZE + 2;
	    END
	    ELSE BEGIN
	      LOADADDRESS;
	      STACKD := FALSE;
	      IF GATTR.TYPTR^.FORM = ARRAYS THEN
		IF GATTR.TYPTR^.ADDRCORR <> 0 THEN BEGIN
		  GEN2(ADD,AUTINC,PC,REGDEF,SP);
		  GENCONST(GATTR.TYPTR^.ADDRCORR)
		END
	    END;
	  IF (LATTR.TYPTR <> NIL) AND (GATTR.TYPTR <> NIL) THEN
	    IF LOP = INOP THEN
	      IF (GATTR.TYPTR^.FORM = POWER ) AND (LATTR.TYPTR^.FORM=SCALAR)
		THEN
		  IF COMPTYPES(LATTR.TYPTR,GATTR.TYPTR^.ELSET) THEN BEGIN
		    GETBOUNDS(LATTR.TYPTR,SMIN,SMAX); (*BOUNS OF SCAL.*)
		    IF (LATTR.TYPTR = CHARPTR) OR
		      ((LATTR.TYPTR^.FORM = SUBRANGE) AND
			(LATTR.TYPTR^.RANGETYPE = CHARPTR)) THEN BEGIN
			  C := TRUE (* CHAR IN SET MUST BE REL SPACE *);
			  SMIN := 0;
			  SMAX := SMAX - 40B;
			END
			ELSE
			  C := FALSE;
		    IF (SMAX = 0) OR (SMAX > 15) THEN
		      B := TRUE
		    ELSE
		      B := FALSE;
		      (*B=TRUE MEANS THAT A LARGE SET MUST BE USED*)
		    LSIZE := GATTR.TYPTR^.SIZE;
		    IF (GATTR.KIND<>VARBL) AND B AND (LSIZE = 2) THEN BEGIN
		      GENSUBRCALL(EXPST);
		      LSIZE := 8
		    END
		    ELSE
		      B := LSIZE = 8;
		    IF C THEN BEGIN
		      GEN2( SUB, AUTINC, PC, INDEX, SP );
		      GENCONST( 40B (* SPACE *));
		      GENCONST( LSIZE )
		    END;
		    GENSUBRCALL(INN);
		    IF B THEN
		      GENCONST(8)
		    ELSE
		      GENCONST(2);
		  END
		  ELSE BEGIN
		    ERROR(129);
		    GATTR.TYPTR := NIL
		  END
		ELSE BEGIN
		  ERROR(130);
		  GATTR.TYPTR := NIL
		END
	    ELSE BEGIN
	      IF LATTR.TYPTR <> GATTR.TYPTR THEN
		IF LATTR.TYPTR = INTPTR THEN BEGIN
		  GENSUBRCALL(FLO);
		  LATTR.TYPTR := REALPTR
		END
		ELSE IF GATTR.TYPTR = INTPTR THEN BEGIN
		  GENSUBRCALL(FLT);
		  GATTR.TYPTR := REALPTR
		END;
	      IF COMPTYPES(LATTR.TYPTR,GATTR.TYPTR) THEN BEGIN
		LSIZE := LATTR.TYPTR^.SIZE;
		CASE LATTR.TYPTR^.FORM OF
		  SCALAR : BEGIN
		    B := LATTR.TYPTR = REALPTR;
		    SUBRNAME := SCALRT[LOP,B]
		  END;
		  POINTER:
		    IF LOP = EQOP THEN
		      SUBRNAME := EQU
		    ELSE IF LOP = NEOP THEN
		      SUBRNAME := NEQ
		    ELSE
		      SUBRNAME := ERRN;
		  POWER : BEGIN
		    B := LARGESET(LATTR);
		    CASE LOP OF
		      LTOP,GTOP:
			SUBRNAME := ERRN;
		      LEOP:
			IF B THEN
			  SUBRNAME := LEQS4
			ELSE
			  SUBRNAME := LEQS1;
		      GEOP:
			IF B THEN
			  SUBRNAME := GEQS4
			ELSE
			  SUBRNAME := GEQS1;
		      NEOP:
			IF B THEN
			  SUBRNAME := NEQS4
			ELSE
			  SUBRNAME := NEQ;
		      EQOP:
			IF B THEN
			  SUBRNAME := EQUS4
			ELSE
			  SUBRNAME := EQU
		    END;
		  END;
		  ARRAYS, RECORDS: BEGIN
		    SUBRNAME := ARRT[LOP,STRING(LATTR.TYPTR),STACKD];
		    IF SUBRNAME IN [EQUM,EQUM2,NEQM,NEQM2] THEN
		      LSIZE := LSIZE DIV 2;
		  END;
		  FILES : BEGIN
		    ERROR(133);
		    SUBRNAME := ERRN
		  END
		END;
		IF SUBRNAME = ERRN THEN
		  ERROR(131)
		ELSE IF LATTR.TYPTR^.FORM IN [ARRAYS,RECORDS] THEN
		  IF SUBRNAME IN [EQUM2,NEQM2,LEQM2,LESM2,GEQM2,GRTM2] THEN
		    BEGIN
		      GEN2(MOV,AUTINC,PC,REG,R);
		      GENCONST(LSIZE);
		      GENSUBRCALL(SUBRNAME);
		    END
		  ELSE BEGIN
		    GENSUBRCALL(SUBRNAME);
		    GENCONST(LSIZE)
		  END
		ELSE
		  GENSUBRCALL(SUBRNAME)
	      END
	      ELSE
		ERROR(129)
	    END;
	  GATTR.TYPTR := BOOLPTR;
	  GATTR.KIND := EXPR;
	  IF MULTSSIZE <> 0 THEN BEGIN
	    GEN2(MOV,REGDEF,SP,INDEX,SP);
	    GENCONST(MULTSSIZE);
	    GEN2(ADD,AUTINC,PC,REG,SP);
	    GENCONST(MULTSSIZE);
	  END
	END (*SY = RELOP*)
      END (*EXPRESSION*);
    L7fm4
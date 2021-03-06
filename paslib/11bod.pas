

PROCEDURE ASSIGNMENT(FCP: CTP) (*$Y+*);

VAR
    LATTR: ATTR;
    SMIN,SMAX: INTEGER;
    LSP1: STP;
    STACKD: BOOLEAN;
    AL, I: INTEGER;

BEGIN
  SELECTOR(FSYS OR [BECOMES],FCP);
  IF FCP^.KLASS = FUNC THEN
    IF FCP^.PFLEV <> LEVEL - 1 THEN BEGIN (*assignments to current function only*)
      ERROR ( 184 );
      GATTR.TYPTR := NIL;
    END;
  IF SY = BECOMES THEN BEGIN
    IF GATTR.TYPTR <> NIL THEN
      IF (GATTR.ACCESS <> DRCT) OR (GATTR.TYPTR^.FORM > POWER) THEN BEGIN
	LOADADDRESS;
	IF GATTR.TYPTR^.FORM = ARRAYS THEN
	  IF GATTR.TYPTR^.ADDRCORR <> 0 THEN BEGIN
	    GEN2(ADD,AUTINC,PC,REGDEF,SP);
	    GENCONST(GATTR.TYPTR^.ADDRCORR)
	    (*HYPOTHETICAL ADDRESS BECOMES ACTUAL ADDRESS*)
	  END
      END;
    LATTR := GATTR;
    INSYMBOL;
    EXPRESSION(FSYS);
    IF GATTR.TYPTR <> NIL THEN
      IF GATTR.TYPTR^.FORM <= POWER THEN
	LOAD
      ELSE IF GATTR.KIND = EXPR THEN BEGIN
	STACKD := TRUE;
	GEN2(MOV,REG,SP,REG,AR);
	GEN2(ADD,AUTINC,PC,REG,SP);
	GENCONST(GATTR.TYPTR^.SIZE);
	GEN2(MOV,AUTINC,SP,REG,AD)
      END (*WHEN THE MULTIPLE IS A FUNCTIONRESULT ON THE STACK*)
      ELSE BEGIN
	LOADADDRESS;
	STACKD := FALSE;
	IF GATTR.TYPTR^.FORM = ARRAYS THEN
	  IF GATTR.TYPTR^.ADDRCORR <> 0 THEN BEGIN
	    GEN2(ADD,AUTINC,PC,REGDEF,SP);
	    GENCONST(GATTR.TYPTR^.ADDRCORR)
	  END
      END;
    IF (LATTR.TYPTR <> NIL) AND (GATTR.TYPTR <> NIL) THEN BEGIN
      IF COMPTYPES(REALPTR,LATTR.TYPTR) AND (GATTR.TYPTR = INTPTR) THEN BEGIN
	GENSUBRCALL(FLT);
	GATTR.TYPTR := REALPTR
      END;
      IF LATTR.TYPTR^.FORM = POWER THEN
	STACKD := LARGESET(LATTR); (*SETCONVERSIONS ONLY*)
      IF COMPTYPES(LATTR.TYPTR,GATTR.TYPTR) THEN
	CASE LATTR.TYPTR^.FORM OF
	  SCALAR, SUBRANGE: BEGIN
	    IF RUNTMCHECK AND ((LATTR.TYPTR<>INTPTR) AND
	      (LATTR.TYPTR <> REALPTR)) THEN BEGIN
		GETBOUNDS(LATTR.TYPTR,SMIN,SMAX);
		GENSUBRCALL(SUBRCHK);
		GENCONST(SMIN);
		GENCONST(SMAX);
	      END;
	    STORE(LATTR);
	  END;
	  POINTER, POWER :
	    STORE(LATTR);
	  ARRAYS, RECORDS: BEGIN
	    AL := GATTR.TYPTR^.SIZE DIV 2;
	    IF STACKD THEN
	      IF AL <= 3 THEN
		FOR I:= 1 TO AL DO
		  GEN2(MOV,AUTINC,AR,AUTINC,AD)
	      ELSE BEGIN
		GENSUBRCALL(MOVM2);
		GENCONST(AL);
	      END
	    ELSE BEGIN
	      GENSUBRCALL(MOVM);
	      GENCONST(AL)
	    END
	  END;
	  FILES:
	    ERROR(146)
	END
      ELSE
	ERROR(129)
    END
  END (*SY = BECOMES*)
  ELSE
    ERROR(51)
END (*ASSIGNMENT*);

PROCEDURE GOTOSTATEMENT (*$Y+*);

LABEL
    1;

VAR
    LLP: LBP;
    LRP: REFLINKP ;

BEGIN
  IF SY = INTCONST THEN BEGIN
    LLP := FSTLABP;
    WHILE LLP <> FLABP DO
      WITH LLP^ DO
	IF LABVAL = VAL.IVAL THEN BEGIN
	  IF DEFINED THEN
	    GENUJP(LABADDR)
	  ELSE BEGIN
	    GENUJP( 0 );
	    NEW ( LRP ) ;
	    LRP^.NEXTREF := LABCHAIN ;
	    LABCHAIN := LRP ;
	    LRP^.REFADDR := CIX ;
	  END;
	  GOTO 1
	END
	ELSE
	  LLP := NEXTLAB;
	  (* UNDECLARED AND UNDEFINED *)
    GENUJP( 0 );
    NEW(LRP);
    NEW(LLP);
    WITH LLP^ DO BEGIN
      LABVAL := VAL.IVAL;
      DEFINED := FALSE;
      LABCHAIN := LRP;
      NEXTLAB := FSTLABP;
      DECLARED := FALSE;
    END;
    FSTLABP := LLP;
    WITH LRP^ DO BEGIN
      NEXTREF := NIL;
      REFADDR := CIX
    END;
    1:
      INSYMBOL
  END
  ELSE
    ERROR(15)
END (*GOTOSTATEMENT*);

PROCEDURE COMPOUNDSTATEMENT (*$Y+*);

BEGIN
  LOOP
    REPEAT
      STATEMENT(FSYS OR [SEMICOLON,ENDSY])
    UNTIL NOT (SY IN STATBEGSYS);
  EXIT IF SY <> SEMICOLON;
    INSYMBOL
  END;
  IF SY = ENDSY THEN
    INSYMBOL
  ELSE
    ERROR(13)
END (*COMPOUNDSTATEMENET*);

PROCEDURE IFSTATEMENT (*$Y+*);

VAR
    LCIX1,LCIX2: CODERANGE;

BEGIN
  EXPRESSION(FSYS OR [THENSY]);
  GENFJP(0);
  LCIX1 := CIX;
  IF SY = THENSY THEN
    INSYMBOL
  ELSE
    ERROR(52);
  STATEMENT(FSYS OR [ELSESY]);
  IF SY = ELSESY THEN BEGIN
    GENUJP(0);
    LCIX2 := CIX;
    INSERT(LCIX1, 2 * (CIX - LCIX1));
    INSYMBOL;
    STATEMENT(FSYS);
    INSERT(LCIX2, 2 * (CIX - LCIX2));
  END
  ELSE
    INSERT(LCIX1,2 * (CIX - LCIX1));
END (*IFSTATEMENT*);

PROCEDURE CASESTATEMENT (*$Y+*);

LABEL
    1;

TYPE
    CIP = ^CASEINFO;
    CASEINFO = PACKED RECORD
      NEXT: CIP;
      CSSTART: CODERANGE;
      CSEND: CODERANGE;
      CSLAB: INTEGER
    END;

VAR
    LSP,LSP1: STP;
    FSTPTR,LPT1,LPT2,LPT3: CIP;
    LVAL: VALU;
    LADDR,OTHERADDR,OTHEREND: ADDRRANGE;
    LCIX: CODERANGE;
    LMIN,LMAX: INTEGER;
    OTHERCASE: BOOLEAN;
    HEAPM: INTP;

BEGIN
  EXPRESSION(FSYS OR [OFSY,COMMA,COLON]);
  HEAPMARK(HEAPM);
  LOAD; (*LOAD LABELVALUE*)
  GEN2(MOV,AUTINC,SP,REG,R);
  GEN2(CMP,REG,R,AUTINC,PC);
  GENCONST(0);
  GENBR(BLT,3);
  GEN2(CMP,REG,R,AUTINC,PC);
  GENCONST(0);
  GENBR(BLE,2);
  GEN1(JMP,INDEX,PC);
  GENCONST(0);
  GEN1(ASL,REG,R);
  GEN2(ADD,REG,PC,REG,R);
  LCIX := CIX;
  GEN2(ADD,INDEX,R,REG,R);
  GENCONST(0);
  GEN1(JMP,REGDEF,R);
  LSP := GATTR.TYPTR;
  IF LSP <> NIL THEN
    IF (LSP^.FORM <> SCALAR) OR (LSP = REALPTR) THEN BEGIN
      ERROR(144);
      LSP := NIL
    END;
  IF SY = OFSY THEN
    INSYMBOL
  ELSE
    ERROR(8);
  FSTPTR := NIL;
  LPT3 := NIL;
  OTHERADDR := 0;
  LOOP
    OTHERCASE := SY = DEFAULTSY;
    IF OTHERCASE THEN BEGIN
      IF OTHERADDR <> 0 THEN
	ERROR(156);
      OTHERADDR := CIX + 1;
      INSYMBOL
    END
    ELSE
      LOOP
	CONSTANT(FSYS OR [COMMA,COLON],LSP1,LVAL);
	IF LSP <> NIL THEN
	  IF COMPTYPES(LSP,LSP1) THEN BEGIN
	    LPT1 := FSTPTR;
	    LPT2 := NIL;
	    WHILE LPT1 <> NIL DO
	      WITH LPT1^ DO BEGIN
		IF CSLAB <= LVAL.IVAL THEN BEGIN
		  IF CSLAB = LVAL.IVAL THEN
		    ERROR(156);
		  GOTO 1
		END;
		LPT2 := LPT1;
		LPT1 := NEXT
	      END;
	    1:
	      NEW(LPT3);
	    WITH LPT3^ DO BEGIN
	      NEXT := LPT1;
	      CSLAB := LVAL.IVAL;
	      CSSTART := CIX + 1;
	      CSEND := 0; (*CSSTART IS CODEADDRESS*)
	    END;
	    IF LPT2 = NIL THEN
	      FSTPTR := LPT3
	    ELSE
	      LPT2^.NEXT := LPT3
	  END
	  ELSE
	    ERROR(147);
      EXIT IF SY <> COMMA;
	INSYMBOL;
      END;
    IF SY = COLON THEN
      INSYMBOL
    ELSE
      ERROR(5);
    REPEAT
      STATEMENT(FSYS OR [SEMICOLON])
    UNTIL NOT (SY IN STATBEGSYS);
    GENUJP(0);
    IF OTHERCASE THEN
      OTHEREND := CIX
    ELSE IF LPT3<>NIL THEN
      LPT3^.CSEND := CIX;
  EXIT IF SY <> SEMICOLON;
    INSYMBOL
  END;
  IF FSTPTR <> NIL THEN BEGIN
    LMAX := FSTPTR^.CSLAB;
    (*REVERSE POINTERS*)
    LPT1 := FSTPTR;
    FSTPTR := NIL;
    REPEAT
      LPT2 := LPT1^.NEXT;
      LPT1^.NEXT := FSTPTR;
      FSTPTR := LPT1;
      LPT1 := LPT2
    UNTIL LPT1 = NIL;
    LMIN := FSTPTR^.CSLAB;
    INSERT(LCIX + 2, 2 * (CIX - LCIX - LMIN));
    INSERT(LCIX - 8, LMIN);
    INSERT(LCIX - 5, LMAX);
    IF LMAX - LMIN < CIXMAX THEN BEGIN
      LADDR := CIX + 2 + LMAX - LMIN;
      IF OTHERADDR = 0 THEN
	OTHERADDR := LADDR
      ELSE
	INSERT( OTHEREND, 2*(LADDR-OTHEREND-1));
      INSERT(LCIX - 2,2 * (OTHERADDR - LCIX + 1));
      REPEAT
	WITH FSTPTR^ DO BEGIN
	  WHILE CSLAB > LMIN DO BEGIN
	    GENCONST(2 * (OTHERADDR - LCIX - 1 - LMIN));
	    LMIN := LMIN + 1
	  END;
	  GENCONST(2 * (CSSTART - LCIX - CSLAB - 1));
	  IF CSEND <> 0 THEN
	    INSERT(CSEND, 2 * (LADDR-CSEND-1));
	  FSTPTR := NEXT;
	  LMIN := LMIN + 1
	END
      UNTIL FSTPTR = NIL
    END
    ELSE
      ERROR(157)
  END;
  IF SY = ENDSY THEN
    INSYMBOL
  ELSE
    ERROR(13);
  HEAPRELEASE(HEAPM)
END (*CASESTATEMENT*);

PROCEDURE REPEATSTATEMENT (*$Y+*);

VAR
    LADDR: ADDRRANGE;

BEGIN
  LADDR := CIX + 1;
  LOOP
    REPEAT
      STATEMENT(FSYS OR [SEMICOLON,UNTILSY])
    UNTIL NOT (SY IN STATBEGSYS);
  EXIT IF SY <> SEMICOLON;
    INSYMBOL
  END;
  IF SY = UNTILSY THEN BEGIN
    INSYMBOL;
    EXPRESSION(FSYS);
    GENFJP(LADDR)
  END
  ELSE
    ERROR(53)
END (*REPEATSTATEMENT*);

PROCEDURE WHILESTATEMENT (*$Y+*);

VAR
    LADDR: ADDRRANGE;
    LCIX: CODERANGE;

BEGIN
  LADDR := CIX + 1;
  EXPRESSION(FSYS OR [DOSY]);
  GENFJP(0);
  LCIX := CIX;
  IF SY = DOSY THEN
    INSYMBOL
  ELSE
    ERROR(54);
  STATEMENT(FSYS);
  GENUJP(LADDR);
  INSERT(LCIX, 2 * (CIX - LCIX))
END (*WHILESTATEMENT*);

PROCEDURE FORSTATEMENT (*$Y+*);

VAR
    LATTR: ATTR;
    LSP: STP;
    LADDR: ADDRRANGE;
    LSY: SYMBOL;
    LCIX: CODERANGE;
    REGR, I: INTEGER;
    INSTR: INSTRRANGE;

BEGIN
  IF SY = IDENT THEN BEGIN
    SEARCHID([VARS],LCP);
    WITH LCP^, LATTR DO BEGIN
      TYPTR := IDTYPE;
      KIND := VARBL;
      IF VKIND = ACTUAL THEN BEGIN
	ACCESS := DRCT;
	VLEVEL := VLEV;
	VSCLASS := VCLASS;
	VID := LCP;
	DPLMT := VADDR
      END
      ELSE BEGIN
	ERROR(155);
	TYPTR := NIL
      END
    END;
    IF LATTR.TYPTR <> NIL THEN
      IF (LATTR.TYPTR^.FORM > SUBRANGE) OR COMPTYPES(REALPTR,LATTR.TYPTR)
	THEN BEGIN
	  ERROR(143);
	  LATTR.TYPTR := NIL
	END;
    INSYMBOL
  END
  ELSE BEGIN
    ERROR(2);
    SKIP(FSYS OR [BECOMES,TOSY,DOWNTOSY,DOSY])
  END;
  IF SY = BECOMES THEN BEGIN
    INSYMBOL;
    EXPRESSION(FSYS OR [TOSY,DOWNTOSY,DOS
    IF GATTR.TYPTR <> NIL THEN
      IF GATTR.TYPTR^.FORM <> SCALAR THEN
	ERROR(144)
      ELSE IF COMPTYPES(LATTR.TYPTR,GATTR.TYPTR) THEN BEGIN
	LOAD;
	STORE(LATTR)
      END
      ELSE
	ERROR(145)
  END
  ELSE BEGIN
    ERROR(51);
    SKIP(FSYS OR [TOSY,DOWNTOSY,DOSY])
  END;
  IF SY IN [TOSY,DOWNTOSY] THEN BEGIN
    LSY := SY;
    INSYMBOL;
    EXPRESSION(FSYS OR [DOSY]);
    IF GATTR.TYPTR <> NIL THEN
      IF GATTR.TYPTR^.FORM <> SCALAR THEN
	ERROR(144)
      ELSE IF COMPTYPES(LATTR.TYPTR,GATTR.TYPTR) THEN BEGIN
	LOAD;
	LC := LC - 2;
	GEN2(MOV,AUTINC,SP,INDEX,MP);
	GENCONST(LC);
	LADDR := CIX + 1; (*CODE-ADDR FOR JUMP*)
	IF LATTR.VLEVEL <= 1 THEN REGR:= GP (* FLAGS STATICPUBLIC LATER *)
	ELSE IF LATTR.VLEVEL = LEVEL THEN
	  REGR := MP
	ELSE BEGIN
	  GEN2(MOV,REGDEF,MP,REG,AD);
	  FOR I := 2 TO LEVEL - LATTR.VLEVEL DO
	    GEN2(MOV,REGDEF,AD,REG,AD);
	  REGR := AD
	END;
	IF LATTR.TYPTR = CHARPTR THEN
	  INSTR := CMPB
	ELSE
	  INSTR := CMP;
	IF REGR <> GP THEN BEGIN
	  GEN2(INSTR,INDEX,REGR,INDEX,MP);
	  GENCONST(LATTR.DPLMT);

	END
	ELSE BEGIN
	  GEN2 (INSTR,AUTINCDEF,PC,INDEX,MP);
	  STATICPUBLIC (LATTR.VID,LATTR.DPLMT);
	END;
	GENCONST(LC);
	IF LSY = TOSY THEN
	  INSTR := BLE
	ELSE
	  INSTR := BGE;
	GENBR(INSTR, 2);
	IF LC < LCMAX THEN
	  LCMAX := LC
      END
      ELSE
	ERROR(145)
  END
  ELSE BEGIN
    ERROR(55);
    SKIP(FSYS OR [DOSY])
  END;
  GEN1(JMP,INDEX,PC);
  GENCONST(0);
  LCIX := CIX;
  IF SY = DOSY THEN
    INSYMBOL
  ELSE
    ERROR(54);
  STATEMENT(FSYS);
  IF LSY = TOSY THEN
    INSTR := INC
  ELSE
    INSTR := DEC;
  IF REGR = AD THEN BEGIN
    GEN2(MOV,REGDEF,MP,REG,AD);
    FOR I := 2 TO LEVEL - LATTR.VLEVEL DO
      GEN2(MOV,REGDEF,AD,REG,AD)
  END;
  IF REGR <> GP THEN BEGIN
    GEN1(INSTR,INDEX,REGR);
    GENCONST(LATTR.DPLMT);
  END
  ELSE BEGIN
    GEN1 (INSTR,AUTINCDEF,PC);
    STATICPUBLIC (LATTR.VID,LATTR.DPLMT);
  END;
  GENUJP(LADDR);
  INSERT(LCIX, 2 * (CIX - LCIX));
  LC := LC + 2
END (*FORSTATEMENT*);

PROCEDURE LOOPSTATEMENT (*$Y+*);

VAR
    LADDR: ADDRRANGE;
    LCIX: CODERANGE;

BEGIN
  LADDR := CIX + 1;
  LOOP
    REPEAT
      STATEMENT(FSYS OR [SEMICOLON,EXITSY])
    UNTIL NOT (SY IN STATBEGSYS);
  EXIT IF SY <> SEMICOLON;
    INSYMBOL
  END;
  IF SY = EXITSY THEN BEGIN
    INSYMBOL;
    IF SY = IFSY THEN BEGIN
      INSYMBOL;
      EXPRESSION(FSYS OR [SEMICOLON,ENDSY]);
      LOAD
    END
    ELSE BEGIN
      ERROR(56);
      SKIP(FSYS OR [SEMICOLON,ENDSY])
    END;
    GEN1(TST,AUTINC,SP);
    GENBR(BEQ,2);
    GEN1(JMP,INDEX,PC);
    GENCONST(0);
    LCIX := CIX;
    LOOP
      REPEAT
	STATEMENT(FSYS OR [SEMICOLON,ENDSY])
      UNTIL NOT (SY IN STATBEGSYS);
    EXIT IF SY <> SEMICOLON;
      INSYMBOL
    END;
    GENUJP(LADDR);
    INSERT(LCIX,2 * (CIX - LCIX))
  END
  ELSE
    ERROR(57);
  IF SY = ENDSY THEN
    INSYMBOL
  ELSE
    ERROR(13)
END (*LOOPSTATEMENT*);

PROCEDURE WITHSTATEMENT (*$Y+*);

VAR
    LCP: CTP;
    LCNT1: DISPRANGE;
    LCNT2: ADDRRANGE;

BEGIN
  LCNT1 := 0;
  LCNT2 := 0;
  LOOP
    IF SY = IDENT THEN BEGIN
      SEARCHID([VARS,FIELD],LCP);
      INSYMBOL
    END
    ELSE BEGIN
      ERROR(2);
      LCP := UVARPTR
    END;
    SELECTOR(FSYS OR [COMMA,DOSY],LCP);
    IF GATTR.TYPTR <> NIL THEN
      IF GATTR.TYPTR^.FORM = RECORDS THEN
	IF TOP < DISPLIMIT THEN BEGIN
	  TOP := TOP + 1;
	  LCNT1 := LCNT1 + 1;
	  DISPLAY[TOP].FNAME := GATTR.TYPTR^.FSTFLD;
	  IF (GATTR.ACCESS = DRCT) AND (GATTR.VSCLASS = DEFAULTSY) THEN
	    WITH DISPLAY[TOP] DO BEGIN
	      OCCUR := CREC;
	      CLEV := GATTR.VLEVEL;
	      CDSPL := GATTR.DPLMT
	    END
	  ELSE BEGIN
	    LOADADDRESS;
	    LC := LC - 2;
	    LCNT2 := LCNT2 - 2;
	    WITH DISPLAY[TOP] DO BEGIN
	      OCCUR := VREC;
	      VDSPL := LC
	    END;
	    IF LC < LCMAX THEN
	      LCMAX := LC;
	    GEN2(MOV,AUTINC,SP,INDEX,MP);
	    GENCONST(LC)
	  END
	END
	ELSE
	  ERROR(250)
      ELSE
	ERROR(140);
  EXIT IF SY <> COMMA;
    INSYMBOL
  END;
  IF SY = DOSY THEN
    INSYMBOL
  ELSE
    ERROR(54);
  STATEMENT(FSYS);
  TOP := TOP - LCNT1;
  LC := LC - LCNT2;
END (*WITHSTATEMENT*);


(*$Y+*)   (* NEW MODULE *)



BEGIN (*STATEMENT*)
  IF RUNTMCHECK THEN
    LINENODEF;
  IF SY = INTCONST THEN (*LABEL*)
  BEGIN
    LLP := FSTLABP;
    WHILE LLP <> FLABP DO
      WITH LLP^ DO
	IF LABVAL = VAL.IVAL THEN BEGIN
	  IF NOT DECLARED THEN
	    ERROR(900);
	  IF DEFINED THEN
	    ERROR(165);
	  WHILE LABCHAIN <> NIL DO
	    WITH LABCHAIN^ DO BEGIN
	      INSERT ( REFADDR, 2*( CIX - REFADDR )) ;
	      LABCHAIN := NEXTREF
	    END ;
	  LABADDR := CIX + 1 ;
	  DEFINED := TRUE ;
	  GOTO 1
	END
	ELSE
	  LLP := NEXTLAB;
    ERROR(900);
    NEW(LLP);
    WITH LLP^ DO BEGIN
      DECLARED := FALSE;
      LABVAL := VAL.IVAL;
      DEFINED := TRUE;
      LABCHAIN := NIL;
      NEXTLAB := FSTLABP;
      LABADDR := CIX + 1;
    END;
    FSTLABP := LLP;
    1:
      INSYMBOL;
    IF SY = COLON THEN
      INSYMBOL
    ELSE
      ERROR(5)
  END;
  IF NOT (SY IN FSYS OR [IDENT]) THEN BEGIN
    ERROR(6);
    SKIP(FSYS)
  END;
  IF SY IN STATBEGSYS OR [IDENT] THEN BEGIN
    CASE SY OF
      IDENT: BEGIN
	SEARCHID([VARS,FIELD,FUNC,PROC],LCP);
	INSYMBOL;
	IF LCP^.KLASS = PROC THEN
	  CALL(FSYS,LCP)
	ELSE
	  ASSIGNMENT(LCP)
      END;
      BEGINSY: BEGIN
	INSYMBOL;
	COMPOUNDSTATEMENT
      END;
      GOTOSY: BEGIN
	INSYMBOL;
	GOTOSTATEMENT
      END;
      IFSY: BEGIN
	INSYMBOL;
	IFSTATEMENT
      END;
      CASESY: BEGIN
	INSYMBOL;
	CASESTATEMENT
      END;
      WHILESY: BEGIN
	INSYMBOL;
	WHILESTATEMENT
      END;
      REPEATSY: BEGIN
	INSYMBOL;
	REPEATSTATEMENT
      END;
      LOOPSY: BEGIN
	INSYMBOL;
	LOOPSTATEMENT
      END;
      FORSY: BEGIN
	INSYMBOL;
	FORSTATEMENT
      END;
      WITHSY: BEGIN
	INSYMBOL;
	WITHSTATEMENT
      END
    END;
    IF NOT (SY IN FSYS) THEN BEGIN
      ERROR(6);
      SKIP(FSYS)
    END
  END
END (*STATEMENT*);

PROCEDURE STARTOFMAIN (*$Y+*);

BEGIN
  EPMAIN := (CIX + 1);
  LLC1 := 0 ;
  IF NOIO THEN GENSUBRCALL( INITB ) 
  ELSE BEGIN
    GENSUBRCALL( INITA ) ;

    (* OPEN STANDARD FILES TTY AND TTYOUTPUT *)

    GENCONST( 0 (* OUTPUT *)) ;  (* STANDARD FILES INPUT AND OUTPUT *)
    GENCONST ( 0 (* INPUT *)) ;  (* MUST BE OPENED BY PROGRAM *)
    IF TTYOUTPTR <> NIL THEN
      ADDR := TTYOUTPTR^.VADDR
    ELSE
      ADDR := 0 ;
    GENCONST ( ADDR (* TTYOUT *)) ;
    IF TTYINPTR <> NIL THEN
      ADDR := TTYINPTR^.VADDR
    ELSE
      ADDR := 0 ;
    GENCONST ( ADDR (* TTYIN *)) 
  END;
  TESTPACKED := TRUE;
  IF ONSWITCH['H'] THEN BEGIN
    GEN2(MOV,AUTINC,PC,INDEX,GP);
    GENCONST(SELECTOR);
    GENCONST(4 (*SELECTOR WORD*));
  END;
  IF ONSWITCH['D'] THEN BEGIN
    GEN2(MOV,AUTINC,PC,INDEX,GP);
    GENCONST(0);
    PUTRLD('$DDTDF    ',RELOCFCN,2*CODE.LEN-2,2*DCIX+2);
    GENCONST(-6);
    COPYCTP( DISPLAY[0].FNAME );
    GEN2( MOV,AUTINC,PC,INDEX,GP);
    GENCONST(0);
    PUTRLD('$DDTDF    ',RELOCFCN,2*CODE.LEN-2,2*INTPTR^.SELFSTP);
    GENCONST(-8);
    GEN2 ( MOV,AUTINC,PC,INDEX,GP );
    GENCONST(0);
    PUTRLD('$DDTDF    ',RELOCFCN,2*CODE.LEN-2,2*REALPTR^.SELFSTP);
    GENCONST(-10);
    GEN2 ( MOV,AUTINC,PC,INDEX,GP );
    GENCONST(0);
    PUTRLD('$DDTDF    ',RELOCFCN,2*CODE.LEN-2,2*CHARPTR^.SELFSTP);
    GENCONST(-12);
  END;
END;

PROCEDURE RESETFLAGS (LCP: CTP);

BEGIN
  IF LCP <> NIL THEN BEGIN
    RESETFLAGS (LCP^.LLINK);
    WITH LCP^ DO
      IF KLASS = VARS THEN 
	VNOTUSED := TRUE
      ELSE IF KLASS IN [PROC,FUNC] THEN 
	IF PFKIND = ACTUAL THEN
	  PNOTUSED := TRUE;
    RESETFLAGS (LCP^.RLINK);
  END;
END;


PROCEDURE NEWMODULE (*$Y-*)   (*  CONTIGUOUS MODULE   *);

VAR D: DISPRANGE;

BEGIN
  IF FIRSTMODULE THEN
    FIRSTMODULE := FALSE
  ELSE BEGIN
    IF GSD.LEN > 1 THEN
      WRITOBJ( GSD );
    GSD.VALUE[1] := 2 (*  EGSD  *);
    WRITOBJ( GSD );
    GSD.VALUE[1] := 6 (*  EM    *);
    WRITOBJ( GSD );
    GSD.VALUE[1] := 1 (*  GSD   *);
    (*$Z+*)   (*  NEW MODULE  *)
    IF PRCODE THEN BEGIN
      WRITELN(CEX,'.END':30);
      PAGE(CEX);
    END;
    (*$Z-*)
  END;
  PUTGSD ( PSECT, 0 (* MODULE NAME *), 0 );
  PUTGSD ( OBJIDENT, 3000B (* MODULE IDENT *), 0 );
  WRITOBJ( GSD );
  FOR RTR := ERRN TO LASTRTR DO
    NOTCALLED[RTR] := TRUE;
  FOR D := TOP DOWNTO 1 DO
    RESETFLAGS (DISPLAY[D].FNAME);
    (*$Z+*)
  IF PRCODE THEN
    WRITELN( CEX, '                       .TITLE   ',PSECT);
    (*$Z-*)
END (* NEWMODULE *);

PROCEDURE ENTERBODY;

BEGIN
  IF PSECTGEN OR FIRSTMODULE THEN
    NEWMODULE ;
  PUTRLD ( PSECT, 7, 0, 2*CIX+2 ) ;
  WRITOBJ ( RLD ) ;
  (*$Z+*)
  IF PRCODE THEN BEGIN
    WRITELN(CEX);
    WRITELN(CEX);
    WRITELN(CEX);
    WRITELN(CEX,'.PSECT':30,PSECT:15)
  END;
  (*$Z-*)
  IF FPROCP <> NIL THEN
    WITH FPROCP^ DO BEGIN
      PFADDR := 2 * (CIX + 1);
      LLC1 := PARLISTSIZE;
      GLOBALDEF ( PSECT, PFADDR ) ;
    END (*WITH  FPROCP*)
  ELSE
    STARTOFMAIN;
  GEN2(MOV,REG,SP,REG,AD);
  GEN2(MOV, REG,MP,AUTDEC,SP);
  GEN2(MOV, REG,AD,REG,MP); (*ENTER  BODY INSTRUCTIONS*)
  IF TESTPACKED THEN
    GENSUBRCALL(CLRSTK)
  ELSE
    GEN2(SUB,AUTINC,PC,REG,SP);
  GENCONST(0);
  CIX1 := CIX;
  IF ONSWITCH['D'] THEN BEGIN
    GEN2 ( MOV,AUTINC,PC,INDEX,MP );
    GENCONST(0);
    IF DISPLAY[TOP].FNAME <> NIL THEN
      PUTRLD('$DDTDF    ',RELOCFCN,2*CODE.LEN-2,2*DCIX+2);
    GENCONST(-4);
    COPYCTP( DISPLAY[TOP].FNAME )
  END;
  IF HEAPCHECK THEN BEGIN
    LINENODEF;
    GENSUBRCALL(OVFLCHK);
  END;
  IF ONSWITCH['D'] AND (FPROCP = NIL) THEN
    GENSUBRCALL ( DDTINIT );
  LCMAX := LC;
END (* ENTERBODY *);

PROCEDURE LEAVEBODY;

VAR
    GLOBALSIZE: INTEGER;


  PROCEDURE DEFINEPUBLIC (P: CTP);

  VAR
      I: INTEGER;
      OFFSET: INTEGER;

  BEGIN
    IF P <> NIL THEN
      WITH P^ DO BEGIN
	DEFINEPUBLIC (LLINK);
	IF KLASS = VARS THEN
	  IF VCLASS = PUBLICSY THEN IF IDTYPE <> NIL THEN
	   IF FIRSTPASS THEN BEGIN
	    IF IDTYPE^.FORM = FILES THEN BEGIN
	      OFFSET := FILESIZECORR;
	      IF IDTYPE^.FILTYPE = CHARPTR THEN
		OFFSET := OFFSET + TEXTBUFFSIZE;
	    END
	    ELSE OFFSET := 0;
	    VADDR := 2*CIX+2+OFFSET;
	    IF IDTYPE^.FORM=FILES THEN
	      OFFSET := OFFSET + IDTYPE^.FILTYPE^.SIZE;
	    FOR I := 1 TO (OFFSET + IDTYPE^.SIZE) DIV 2 DO
	      GENCONST (0);
	  END
	  ELSE PUTGSD (NAME,GLOBALDEFFLAGS,VADDR);
        DEFINEPUBLIC (RLINK);
      END;
  END;

BEGIN
  IF SY = ENDSY THEN
    INSYMBOL
  ELSE
    ERROR(13);
  LLP := FSTLABP; (*TEST FOR UNDEFINED LABELS*)
  WHILE LLP <> FLABP DO
    WITH LLP^ DO BEGIN
      IF NOT DEFINED THEN BEGIN
	IF LABCHAIN = NIL THEN
	  ERROR(901)
	ELSE
	  ERROR(168);
	WRITELN;
	WRITELN(' LABEL ',LABVAL)
      END;
      LLP := NEXTLAB
    END;
  IF FPROCP = NIL THEN BEGIN
    IF ONSWITCH['Q'] THEN BEGIN
      GENSUBRCALL ( FREQV );
      GENCONST(ORD(FILENAME[8])+256*ORD(FILENAME[9]));
      GENCONST(ORD(FILENAME[6])+256*ORD(FILENAME[7]));
      GENCONST(ORD(FILENAME[4])+256*ORD(FILENAME[5]));
      GENCONST(ORD(FILENAME[2])+256*ORD(FILENAME[3]));
      GENCONST(ORD(FILENAME[0])+256*ORD(FILENAME[1]));
      GENCONST(0);
      PUTRLD ( LASTLINE.LLPSECT,15B (* PSECT ADD.REL. *), 2*CODE.LEN-2,2*
	LASTLINE.LLADDR);
    END;
    IF NOIO THEN GENSUBRCALL( EXITB )
    ELSE GENSUBRCALL( EXITP )
  END
  ELSE BEGIN
    GEN2(MOV,AUTDEC,MP,REG,MP);
    GEN2(ADD,AUTINC,PC,REG,SP);
    GENCONST(LLC1 - LCMAX); (*RETURN FROM BODY INSTRUCTIONS*)
    GEN1(RTS,REG,PC);
  END;
  I := -LCMAX - 2;
  DATASIZE := DATASIZE + I;
  IF TESTPACKED THEN
    INSERT(CIX1,I DIV 2) (*NUMBER OF WORDS*)
  ELSE
    INSERT(CIX1,I);
  FSTLABP := FLABP ;
  IF CODE.LEN > 1 THEN
    WRITOBJ ( CODE ) ;
  IF RLD.LEN > 1 THEN
    WRITOBJ ( RLD ) ;
  PSECTDEF ( PSECT, 2*CIX+2 ) ;
  CIXX := CIXX + CIX + 1 ;
  IF ( FPROCP = NIL ) OR ( SY = PERIOD ) THEN BEGIN
    IF FPROCP = NIL THEN BEGIN
      PUTGSD ( PSECT, 1400B (* TRANSFER ADDRESS *), 2*EPMAIN ) ;
      PSECT := '$STORE    ';
      IF PSECTGEN THEN
	NEWMODULE ;
      DATASIZE := DATASIZE + 200;
      PUTGSD('$$HEAP    ',GLOBALREFFLAGS,0);
    END;
    IF HAVEGLOBALS THEN BEGIN
    (* DEFINE PSECT ".GLOBL" WITH CONCATENATION ACROSS COMPILATIONS
       FOR PUBLIC VARS *)
      IF GSD.LEN > 1 THEN
	WRITOBJ (GSD);
      PSECT := GLOBALPSECT;
      CIX := -1;
      PUTRLD (PSECT,7,0,0);
      WRITOBJ (RLD);
      FIRSTPASS := TRUE;
      DEFINEPUBLIC (DISPLAY[1].FNAME);
      PUBLICBASE := 2*CIX+2;
      IF CODE.LEN > 1 THEN
	WRITOBJ (CODE);
      PUTGSD (PSECT,GLBLPSECTFLAGS,PUBLICBASE);
      FIRSTPASS := FALSE;
      DEFINEPUBLIC (DISPLAY[1].FNAME);
    END;
    WRITOBJ ( GSD ) ;
    IF STATBASE > 0 THEN BEGIN
      PSECT := STATICPSECT;
      CIX := -1;
      PUTRLD (PSECT,7,0,0);
      WRITOBJ (RLD);
      FOR I := 1 TO STATBASE DIV 2 DO
	GENCONST (0);
      IF CODE.LEN > 1 THEN
	WRITOBJ (CODE);
      PUTGSD (PSECT,GLBLPSECTFLAGS,STATBASE);
      WRITOBJ (GSD);
    END;
    GSD.VALUE [ 1 ] := 2 (* EGSD *);
    WRITOBJ ( GSD ) ;
    GSD.VALUE [ 1 ] := 6 (*  EM  *);
    WRITOBJ ( GSD ) ;
  END
  ELSE IF GSD.LEN > 1 THEN
    WRITOBJ ( GSD ) ;
  CIX := OLDCIX ;
  PSECT := OLDPSECT ;
  GLOBALINDEX := OLDGLOBALINDEX ;
END (* LEAVE BODY *);

(*$Y+*)    (* MODULE SPLITTING AGAIN *)



BEGIN (* BODY *)
  BODYCOUNT:= BODYCOUNT+1;  (* KEEP RUNNING COUNT OF BODIES EMITTED *)
  ENTERBODY;
  LOOP
    REPEAT
      STATEMENT(FSYS OR [SEMICOLON,ENDSY])
    UNTIL NOT (SY IN STATBEGSYS);
  EXIT IF SY <> SEMICOLON;
    INSYMBOL;
  END;
  LEAVEBODY;
END (* BODY *);
     d?
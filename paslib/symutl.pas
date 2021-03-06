$WIDTH=100
$LENGTH=55
$TITLE SYMUTL.PAS, last modified 10/14/83, zw

MODULE symutl;
(*symbolic manipulation utility*)
$SYSTEM PASUTL
$PAGE constants, types and variables
$INCLUDE SYMUTL.TYP

VAR
    namtab: namtabtyp := NIL;
    proid: int := 0;
$PAGE namtosym, symtonam

PUBLIC PROCEDURE namtosym(nam: namtyp; VAR sym: symtyp);

VAR
    tmp: ^namtabrec;
    lastsym: symtyp;

BEGIN
  tmp := namtab;
  sym := NIL;
  IF tmp = NIL THEN BEGIN
    NEW(tmp);
    namtab := tmp;
    sym := tmp;
    tmp^.nam := nam;
    tmp^.nxt := NIL
  END
  ELSE
    WHILE tmp <> NIL DO BEGIN
      IF tmp^.nam = nam THEN
	sym := tmp;
      IF (tmp^.nxt = NIL) AND (sym = NIL) THEN BEGIN
	NEW(tmp^.nxt);
	tmp := tmp^.nxt;
	sym := tmp;
	tmp^.nam := nam;
	tmp^.nxt := NIL
      END;
      tmp := tmp^.nxt
    END
END;

PUBLIC PROCEDURE symtonam(sym: symtyp; VAR nam: namtyp);

BEGIN
  nam := sym^.nam
END;
$PAGE wrsym, rdsym

PUBLIC PROCEDURE wrsym(sym: symtyp);

VAR
    nam: namtyp;

BEGIN
  symtonam(sym, nam);
  wrlin(nam)
END;

PUBLIC PROCEDURE rdsym(VAR sym: symtyp);

BEGIN
  namtosym(tkn, sym);
  scan(tkn)
END;
$PAGE wrset, rdset

PUBLIC PROCEDURE wrset(symset: settyp);

VAR
    tmp: ^setrec;

BEGIN
  tmp := symset;
  wrlin('(');
  WHILE tmp <> NIL DO
    WITH tmp^ DO BEGIN
      wrsym(sym);
      tmp := nxt
    END;
  wrlin(')')
END;

PUBLIC PROCEDURE rdset(VAR symset: settyp);

VAR
    tmp: ^setrec;

BEGIN
  tmp := NIL;
  symset := NIL;
  scan('(');
  WHILE (tkn <> ')') AND (tkn <> '') DO BEGIN
    IF tmp = NIL THEN BEGIN
      NEW(tmp);
      symset := tmp
    END
    ELSE
      WITH tmp^ DO BEGIN
	NEW(nxt);
	tmp := nxt
      END;
    WITH tmp^ DO BEGIN
      rdsym(sym);
      nxt := NIL
    END
  END;
  scan(')')
END;
$PAGE wrlst, rdlst

PUBLIC PROCEDURE wrlst(lst: lsttyp);

VAR
    tmp: ^lstrec;

BEGIN
  tmp := lst;
  wrlin('(');
  WHILE tmp <> NIL DO
    WITH tmp^ DO BEGIN
      wrsym(sym);
      tmp := nxt
    END;
  wrlin(')')
END;

PUBLIC PROCEDURE rdlst(VAR lst: lsttyp);

VAR
    tmp: ^lstrec;

BEGIN
  tmp := NIL;
  lst := NIL;
  scan('(');
  WHILE (tkn <> ')') AND (tkn <> '') DO BEGIN
    IF tmp = NIL THEN BEGIN
      NEW(tmp);
      lst := tmp
    END
    ELSE
      WITH tmp^ DO BEGIN
	NEW(nxt);
	tmp := nxt
      END;
    WITH tmp^ DO BEGIN
      rdsym(sym);
      nxt := NIL
    END
  END;
  scan(')')
END;
$PAGE wrprolst, rdprolst

PUBLIC PROCEDURE wrprolst(lst: prolsttyp);

VAR
    tmp: ^prolstrec;

BEGIN
  tmp := lst;
  wrlin('(');
  WHILE tmp <> NIL DO
    WITH tmp^ DO BEGIN
      wrsym(prosym.sym);
      tmp := nxt
    END;
  wrlin(')')
END;

PUBLIC PROCEDURE rdprolst(VAR lst: prolsttyp);

VAR
    tmp: ^prolstrec;

BEGIN
  tmp := NIL;
  lst := NIL;
  scan('(');
  WHILE (tkn <> ')') AND (tkn <> '') DO BEGIN
    IF tmp = NIL THEN BEGIN
      NEW(tmp);
      lst := tmp
    END
    ELSE
      WITH tmp^ DO BEGIN
	NEW(nxt);
	tmp := nxt
      END;
    WITH tmp^, tmp^.prosym DO BEGIN
      rdsym(sym);
      id := proid;
      nxt := NIL
    END;
    proid := SUCC(proid)
  END;
  scan(')')
END;
$PAGE wrpro, rdpro

PUBLIC PROCEDURE wrpro(pro: protyp);

BEGIN
  wrlin('(');
  WITH pro DO BEGIN
    wrsym(sym);
    wrprolst(lst)
  END;
  wrlin(')')
END;

PUBLIC PROCEDURE rdpro(VAR pro: protyp);

BEGIN
  scan('(');
  WITH pro DO BEGIN
    rdsym(sym);
    rdprolst(lst)
  END;
  scan(')')
END;
$PAGE wrproset, rdproset

PUBLIC PROCEDURE wrproset(proset: prosettyp);

VAR
    tmp: ^prosetrec;

BEGIN
  tmp := proset;
  wrlin('(');
  WHILE tmp <> NIL DO
    WITH tmp^ DO BEGIN
      wrpro(pro);
      tmp := nxt
    END;
  wrlin(')')
END;

PUBLIC PROCEDURE rdproset(VAR proset: prosettyp);

VAR
    tmp: ^prosetrec;

BEGIN
  tmp := NIL;
  proset := NIL;
  scan('(');
  WHILE (tkn <> ')') AND (tkn <> '') DO BEGIN
    IF tmp = NIL THEN BEGIN
      NEW(tmp);
      proset := tmp
    END
    ELSE
      WITH tmp^ DO BEGIN
	NEW(nxt);
	tmp := nxt
      END;
    WITH tmp^ DO BEGIN
      rdpro(pro);
      nxt := NIL
    END
  END;
  scan(')')
END;
$PAGE wrgrm, rdgmr

PUBLIC PROCEDURE wrgmr(gmr: gmrtyp);

BEGIN
  wrlin('(');
  WITH gmr DO BEGIN
    wrset(nonterset);
    wrset(terset);
    wrproset(proset);
    wrsym(startsym)
  END;
  wrlin(')')
END;

PUBLIC PROCEDURE rdgmr(VAR gmr: gmrtyp);

BEGIN
  scan('(');
  WITH gmr DO BEGIN
    rdset(nonterset);
    rdset(terset);
    rdproset(proset);
    rdsym(startsym)
  END;
  scan(')')
END;
$PAGE wrtre, rdtre

PUBLIC PROCEDURE wrtre(tre: tretyp);

VAR
    tmp: tretyp;

BEGIN
  IF tre <> NIL THEN
    WITH tre^ DO BEGIN
      wrsym(sym);
      IF NOT ister THEN BEGIN
	wrlin('(');
	tmp := lst;
	WHILE tmp <> NIL DO BEGIN
	  wrtre(tmp);
	  tmp := tmp^.nxt
	END;
	wrlin(')')
      END
    END
END;

PUBLIC PROCEDURE rdtre(VAR tre: tretyp);

VAR
    tmp: ^trerec;

BEGIN
  NEW(tre);
  WITH tre^ DO BEGIN
    nxt := NIL;
    lst := NIL;
    rdsym(sym);
    ister := tkn <> '(';
    IF NOT ister THEN BEGIN
      scan('(');
      WHILE (tkn <> ')') AND (tkn <> '') DO BEGIN
	IF tmp = NIL THEN BEGIN
	  rdtre(tmp);
	  lst := tmp
	END
	ELSE BEGIN
	  rdtre(tmp^.nxt);
	  tmp := tmp^.nxt
	END
      END;
      scan(')')
    END
  END
END;
$PAGE tresym

PUBLIC PROCEDURE tresym(tre: tretyp);


  PROCEDURE walktre(tre: tretyp);

  VAR
      tmp: ^trerec;

  BEGIN
    IF tre <> NIL THEN
      WITH tre^ DO BEGIN
	IF ister THEN
	  wrsym(sym)
	ELSE BEGIN
	  tmp := lst;
	  WHILE tmp <> NIL DO BEGIN
	    walktre(tmp);
	    tmp := tmp^.nxt
	  END
	END
      END
  END;

BEGIN
  wrlin('(');
  walktre(tre);
  wrlin(')')
END;
$PAGE fmtsym

PUBLIC PROCEDURE fmtsym;

VAR
    indentlevel: int;
    lasttkn: tkntyp;


  PROCEDURE indent;

  VAR
      i: int;

  BEGIN
    FOR i := 1 TO indentlevel DO
      wrstr('  ')
  END;

BEGIN
  indentlevel := 0;
  scan('');
  lasttkn := '';
  WHILE tkn <> '' DO BEGIN
    IF tkn = '(' THEN BEGIN
      wrlin('');
      indent;
      wrstr('(');
      indentlevel := indentlevel + 1
    END
    ELSE IF tkn = ')' THEN BEGIN
      indentlevel := indentlevel - 1;
      IF NOT wrchk(1) THEN BEGIN
	wrlin('');
	indent
      END;
      wrstr(')')
    END
    ELSE BEGIN
      IF lasttkn = ')' THEN BEGIN
	wrlin('');
	indent
      END
      ELSE IF lasttkn <> '(' THEN
	wrstr(' ');
      IF NOT wrchk(LENGTH(tkn)) THEN BEGIN
	wrlin('');
	indent
      END;
      wrstr(tkn)
    END;
    lasttkn := tkn;
    scan(tkn)
  END
END.
   
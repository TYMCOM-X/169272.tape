PROGRAM st;
  (*software tools*)

$SYSTEM utlerr

PROCEDURE opr;
  BEGIN
    WRITELN('that is all');
    sgnl_hlt
    END;

PROCEDURE set_up;
  BEGIN
    err_set_up
    END;

PROCEDURE cln_up;
  BEGIN
    err_cln_up
    END;

BEGIN
  err_trp('SOFTWARE TOOLS','1.0',set_up, opr, cln_up)
  END.
   
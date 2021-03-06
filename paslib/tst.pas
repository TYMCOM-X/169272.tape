$WIDTH=100
$LENGTH=50
$TITLE tst.pas, last modified 3/13/83, zw
PROGRAM Test;

CONST
  prog_nam = 'TEST'; prog_ver = '1.0';
  prog_pur = 'This is a program to exercise various utility functions.';

$SYSTEM WRTUTL
$SYSTEM FILUTL.TYP
$SYSTEM PIOUTL
$SYSTEM SCNUTL.TYP
$SYSTEM CMDUTL.TYP
$SYSTEM QRYUTL.TYP
$SYSTEM SLCUTL
$SYSTEM HLPUTL
$SYSTEM ERRUTL
$SYSTEM WRTTST
$SYSTEM FILTST
$SYSTEM PIOTST
$SYSTEM SCNTST
$SYSTEM CMDTST
$SYSTEM QRYTST
$SYSTEM SLCTST
$SYSTEM HLPTST
$SYSTEM ERRTST
$SYSTEM RUNTST

VAR cnt_set_cln : int := zero;

$PAGE set up and clean up
PUBLIC PROCEDURE Cln_up;
  BEGIN
    IF Cnt_cln(cnt_set_cln) THEN RETURN;
    Cln_run_tst;
    Cln_err_tst;
    Cln_hlp_tst;
    Cln_slc_tst;
    Cln_qry_tst;
    Cln_cmd_tst;
    Cln_scn_tst;
    Cln_pio_tst;
    Cln_fil_tst;
    Cln_wrt_tst;
    Err_cln_up;
    Hlp_cln_up;
    Slc_cln_up;
    Pio_cln_up;
    Wrt_cln_up
    END;

PUBLIC PROCEDURE Set_up;
  BEGIN
    IF Cnt_set(cnt_set_cln) THEN RETURN;
    Wrt_set_up;
    Pio_set_up;
    Slc_set_up;
    Hlp_set_up;
    Err_set_up;
    Set_wrt_tst;
    Set_fil_tst;
    Set_pio_tst;
    Set_scn_tst;
    Set_cmd_tst;
    Set_qry_tst;
    Set_slc_tst;
    Set_hlp_tst;
    Sup_err_tst;
    Set_run_tst;
    Set_err_msg('BAD_IFL_FIL', 'Bad indrect file.')
    END;

$PAGE command interpreter
PUBLIC FUNCTION Get_opr : int;
  BEGIN
    IF NOT Slc_cmd('Enter ' || prog_nam || ' command.',
      ((1, cmd_tkn, 'HELP', 1), (2, cmd_tkn, 'QUIT', 1),
      (3, cmd_tkn, 'WRTUTL', 1), (4, cmd_tkn, 'FILUTL', 1),
      (5, cmd_tkn, 'PIOUTL', 1), (6, cmd_tkn, 'SCNUTL', 2),
      (7, cmd_tkn, 'CMDUTL', 1), (8, cmd_tkn, 'QRYUTL', 2),
      (9, cmd_tkn, 'SLCUTL', 2), (10, cmd_tkn, 'HLPUTL', 2),
      (11, cmd_tkn, 'ERRUTL', 1), (12, cmd_tkn, 'RUNUTL', 2),
      (13, ifl_tkn)), Get_opr) THEN Get_opr := 2
    END;

PUBLIC FUNCTION Do_opr(opr : int) : succeed_or_fail;
  BEGIN
    Do_opr := succeed;
    CASE opr OF
      1 : Hlp_cmd('TST', 'TST_CMD');
      2 : Do_opr := fail;
      3 : Tst_wrtutl;
      4 : Tst_filutl;
      5 : Tst_pioutl;
      6 : Tst_scnutl;
      7 : Tst_cmdutl;
      8 : Tst_qryutl;
      9 : Tst_slcutl;
      10 : Tst_hlputl;
      11 : Tst_errutl;
      12 : Tst_runutl;
      13 : IF NOT Psh_get_fil(usr_cmd.ifl_val) THEN Sgnl_err('BAD_IFL_FIL')
      END
    END;

BEGIN
  Trp_errs(prog_nam, prog_ver, prog_pur)
  END.
   
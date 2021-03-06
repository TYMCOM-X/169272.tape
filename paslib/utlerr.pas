$WIDTH=100
$LENGTH=55
$TITLE utlerr.pas, last modified 5/5/83, zw
MODULE utlerr;
  (*error trapping utility*)

$SYSTEM UTLWRT
$SYSTEM UTLIO
$SYSTEM UTLCMD
$SYSTEM UTLRUN

$PAGE utlerr declarations
$INCLUDE UTLERR.TYP

VAR cnt_set_cln: int := zero;

PUBLIC EXCEPTION fatl_err;
PUBLIC EXCEPTION err;

VAR err_rtn: PROCEDURE;

PUBLIC VAR err_fil: txt_fil := NILF; (*error messages directed here*)

VAR num_fatl_errs: pos_int := zero; (*count fatl errs sgnld*)
VAR num_errs: pos_int := zero; (*count errs sgnld*)

VAR hlt_flg: on_or_off := off; (*exit err_trp if on*)

VAR err_lev: pos_int := zero; (*error level counter*)

$PAGE error check, signal errors, error report
PROCEDURE err_chk;
  (*check against error within an error*)
  CONST err_in_err = 'Error within an error.';
  BEGIN
    inc(err_lev);
    IF err_lev > three THEN barf(err_in_err)
    ELSE IF err_lev > one THEN WRITELN('[' || err_in_err || ']')
    END;

PUBLIC PROCEDURE sgnl_hlt;
  (*halt after current operation*)
  BEGIN
    hlt_flg := on
    END;

PUBLIC PROCEDURE sgnl_fatl_err(rtn: PROCEDURE);
  (*signal specified fatal error*)
  BEGIN
    err_chk; err_rtn := rtn; inc(num_fatl_errs); SIGNAL(fatl_err)
    END;

PUBLIC PROCEDURE sgnl_err(rtn: PROCEDURE);
  (*signal specified non-fatal error*)
  BEGIN
    err_chk; err_rtn := rtn; inc(num_errs); SIGNAL(err)
    END;

PROCEDURE err_rpt;
  (*report error status*)
  BEGIN
    WRITELN(err_fil);
    IF (num_errs=zero) AND (num_fatl_errs=zero) THEN
      WRITELN(err_fil, 'No errors.');
    IF num_errs > zero THEN
      WRITELN(err_fil, 'Warning errors: ' || int_str(num_errs));
    IF num_fatl_errs > zero THEN
      WRITELN(err_fil, 'Fatal errors: ' || int_str(num_fatl_errs))
    END;

$PAGE solicit standard I/O files
PUBLIC FUNCTION slct_io(VAR i_fil, o_fil: fil_nam): succeed_or_fail;
  (*solicit standard input and output files*)
  VAR tkn_num: 1 .. 8; p_fil: fil_nam;
  PROCEDURE do_hlp;
    BEGIN
      WRITELN;
      WRITELN('Enter: [<output file> = ] <input file>');
      WRITELN('Default values are "TTY:".');
      WRITELN('To run another program: /RUN <program>');
      WRITELN('To exit: /QUIT or a carriage return');
      WRITELN('To take commands from a file: @<command file>');
      WRITELN
      END;
  PROCEDURE do_run;
    BEGIN
      IF slc_fil('Enter program name.', p_fil) THEN BEGIN
        slc_cmd('Should program prompt?', ((1, eol_tkn),
          (1, cmd_tkn, 'YES', 1), (2, cmd_tkn, 'NO', 1)), tkn_num);
        IF NOT run(p_fil, (tkn_num = 1)) THEN WRITELN
        END
      END;
  BEGIN
    REPEAT
      slc_cmd(nul,
        ((1, swt_tkn, 'HELP', 1), (2, swt_tkn, 'QUIT', 1),
         (3, swt_tkn, 'RUN', 1), (4, fil_tkn), (5, key_tkn, '=', 1),
         (6, ifl_tkn), (7, cr_tkn)), tkn_num);
      slct_io := succeed;
      CASE tkn_num OF
        1: do_hlp;
        2: slct_io := fail;
        3: do_run;
        4: BEGIN
          i_fil := usr_cmd.fil_val;
          slc_cmd('"=" specifies input file.',
            ((5, key_tkn, '=', 1), (4, nul_tkn)), tkn_num);
          IF tkn_num = 5 THEN o_fil := i_fil
          END;
        5: o_fil := 'TTY:';
        6: ifl_cmd;
        7: slct_io := fail
        END
      UNTIL (NOT slct_io) OR (tkn_num IN [4, 5]);
    IF slct_io THEN BEGIN
      CASE tkn_num OF
        4: (*null*);
        5: slc_cmd('Input file?', ((5, fil_tkn), (8, nul_tkn)), tkn_num)
        END;
      CASE tkn_num OF
        4: o_fil := 'TTY:';
        5: i_fil := usr_cmd.fil_val;
        8: i_fil := 'TTY:'
        END
      END
    EXCEPTION
      ALLCONDITIONS: BEGIN WRITELN(err_fil); slct_io := fail END
    END;

$PAGE push and pop input and output files
FUNCTION push_io: succeed_or_fail;
  (*try to solicit file names, push INPUT and OUTPUT files*)
  VAR i_fil, o_fil: fil_nam;
  BEGIN
    REPEAT
      push_io := fail;
      EXIT IF NOT slct_io(i_fil, o_fil);
      IF psh_fil(INPUT, i_fil, 'READ') THEN BEGIN
        IF psh_fil(OUTPUT, o_fil, 'WRITE') THEN push_io := succeed
        ELSE BEGIN
          pop_fil(INPUT);
          WRITELN(err_fil, crlf || '% Bad output file "' || o_fil || '".')
          END
        END
      ELSE WRITELN(err_fil, crlf || '% Bad input file "' || i_fil || '".')
      UNTIL push_io
    END;

PROCEDURE pop_io;
  (*pop INPUT and OUTPUT, restore previous files*)
  BEGIN
    pop_fil(OUTPUT); pop_fil(INPUT)
    END;

$PAGE set up and clean up
PUBLIC PROCEDURE err_cln_up;
  (*clean up error utility*)
  BEGIN
    IF cnt_cln(cnt_set_cln) THEN RETURN;
    run_cln_up;
    cmd_cln_up;
    io_cln_up;
    wrt_cln_up
    END;

PUBLIC PROCEDURE err_set_up;
  (*set up error utility*)
  BEGIN
    IF cnt_set(cnt_set_cln) THEN RETURN;
    wrt_set_up;
    io_set_up;
    cmd_set_up;
    run_set_up;
    err_fil := TTYOUTPUT
    END;

$PAGE error trap
PUBLIC PROCEDURE err_trp(nam, ver: str; set_up, opr, cln_up: PROCEDURE);
  (*general purpose error trap*)
  FUNCTION rst: yes_or_no;
    BEGIN
      cmd_rst;
      IF NOT slc_yon('Restart ' || nam || '?', rst) THEN rst := no
      END;
  PROCEDURE trp_err;
    BEGIN
      WHILE MASKED(ATTENTION) DO UNMASK(ATTENTION);
      err_lev := zero; hlt_flg := off;
      REPEAT opr UNTIL hlt_flg
      EXCEPTION
        err: BEGIN dec(err_lev); WRITE(err_fil, '% '); err_rtn END;
        ATTENTION: BEGIN MASK(ATTENTION); WRITELN(err_fil, 'Nu?' || bel) END;
      END;
  PROCEDURE trp_fatl_err;
    BEGIN
      REPEAT trp_err; cmd_rst; UNTIL hlt_flg;
      EXCEPTION
        fatl_err: BEGIN dec(err_lev); WRITE(err_fil, '? '); err_rtn END;
        OTHERS: BEGIN
          WRITELN(err_fil, '? Fatal error.'); inc(num_fatl_errs);
          EXCEPTION_MESSAGE
          END
      END;
  BEGIN
    err_set_up;
    LOOP
      WRITELN(err_fil, crlf || nam || ', version ' || ver || crlf);
      REPEAT
        EXIT IF NOT push_io DO hlt_flg := on;
        set_up; trp_fatl_err; cln_up;
        pop_io
        UNTIL NOT hlt_flg;
      EXIT IF hlt_flg ORIF NOT rst DO err_rpt;
      WRITELN(err_fil, 'Restarting ' || nam || '.')
      END;
    err_cln_up
    EXCEPTION
      ALLCONDITIONS: BEGIN EXCEPTION_MESSAGE; barf('Check your data!') END
    END.
    
$WIDTH=100
$LENGTH=55
$TITLE PA2XRF.PAS, last modified 1/16/84, zw
MODULE pa2xrf OPTIONS SPECIAL(WORD);
(*TYM-Pascal compiler -- cross reference utilities, pass 2*)

$PAGE system modules

$SYSTEM PASCAL.INC
$SYSTEM PASIST.INC
$SYSTEM PASFIL.INC
$SYSTEM PASPT.TYP
$SYSTEM PASIF.TYP
$SYSTEM PASXRF.TYP
$SYSTEM UTLSET.INC

$PAGE declarations

VAR
xrf_file: file of xrf_record;
(*xst_file: file of xst_record;
  xnm_file: text;  *)
current_file, current_page, current_line: INTEGER;

$PAGE sum_flow, process_block in sum_flow

PUBLIC PROCEDURE sum_flow(mod0, use0: svector);
(*read the cross reference file to produce the direct versions
  of the summary data flow relations, MOD0 and USE0.*)

PROCEDURE process_block(n: INTEGER);
(*perform the processing on a <block> in the file*)
VAR nesting: INTEGER;
BEGIN
  GET(xrf_file); nesting := 0;
  LOOP
    WITH xrf_file^ DO
      CASE code OF
        value_ctxt: IF var_lab_parm THEN add_elem(use0, n, parameter);
        mod_ctxt: IF var_lab_parm THEN add_elem(mod0, n, parameter);
        var_parm_ctxt: IF var_lab_parm THEN BEGIN
            add_elem(use0, n, parameter); add_elem(mod0, n, parameter)
          END;
        block_xrf: process_block(parameter);
        index_xrf, call_xrf: nesting := nesting + 1;
        end_xrf: IF nesting = 0 THEN RETURN ELSE nesting := nesting - 1;
        OTHERS: (*do nothing*)
      END;
    GET(xrf_file)
  END
END;

$PAGE sum_flow - main routine

VAR v: vl_link;
BEGIN
  RESET(xrf_file, xrf_tmp);
  WHILE xrf_file^.code <> block_xrf DO GET(xrf_file);
  process_block(xrf_file^.parameter);
  (*If there is an external procedure, we assume that it can modify and
    use every public, external, file, and heap variable.*)
  IF ext_block <> NIL THEN BEGIN
    v := vl_list;
    WHILE v <> NIL DO WITH v^ DO BEGIN
      IF symbol^.public_dcl OR
        (symbol^.dcl_class IN [external_sc, dynamic_sc, fileblk_sc, opt_sc])
      THEN BEGIN
        add_elem(mod0, ext_block^.number, symbol^.id_number);
        add_elem(use0, ext_block^.number, symbol^.id_number)
      END;
      v := last
    END
  END;
  CLOSE(xrf_file);
END.
  
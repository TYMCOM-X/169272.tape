$TITLE pa2xrf -- Pascal Cross Reference Utilities, Pass 2
$LENGTH 43

(*   +--------------------------------------------------------------+
     |                                                              |
     |                P A S X R F   -   P a s s   2                 |
     |                - - - - - - - - - - - - - - -                 |
     |                                                              |
     +--------------------------------------------------------------+
     
     PURPOSE:  This  module  handles  the  generation  of  the  cross
        reference files.  The files it manipulates are:
     
             name.XRF -- the cross reference file
             name.XST -- the symbol table file
             name.XNM -- the name file
     
     ENTRY POINTS:
     
        sum_flow    will read the cross reference file to produce the
                    direct summary  data  flow  relations,  MOD0  and
                    USE0.
     
     ---------------------------------------------------------------- *)
$PAGE includes

$INCLUDE pascal.inc
$INCLUDE pasist.inc
$INCLUDE pasfil.inc
$INCLUDE paspt.typ
$INCLUDE pasif.typ
$INCLUDE pasxrf.typ
$INCLUDE passet.inc
$INCLUDE tmpnam.inc
$PAGE declarations

var
    xrf_file: file of xrf_record;
(*  xst_file: file of xst_record;
    xnm_file: text;  *)

    current_file,
    current_page,
    current_line: int_type;
$PAGE sum_flow

(*  SumFlow will read the cross reference file to produce the direct versions
    of the summary data flow relations, MOD0 and USE0.  *)


public procedure sum_flow ( mod0, use0: svector );
$PAGE process_block - in sum_flow

(*  ProcessBlock will perform the processing on a <block> in the file.  *)


procedure process_block ( n: int_type );
var nesting: int_type;
begin
  get (xrf_file);
  nesting := 0;
  loop
    with xrf_file^ do
      case code of
        value_ctxt:
          if var_lab_parm then
            add_elem (use0, n, parameter);
        mod_ctxt:
          if var_lab_parm then
            add_elem (mod0, n, parameter);
        var_parm_ctxt:
          if var_lab_parm then begin
            add_elem (use0, n, parameter);
            add_elem (mod0, n, parameter);
          end;
        block_xrf:
          process_block (parameter);
        index_xrf,
        call_xrf:
          nesting := nesting + 1;
        end_xrf:
          if nesting = 0
            then return
            else nesting := nesting - 1;
        others:
      end (* case code *);
    get (xrf_file);
  end (* loop *);
end (* process_block *);
$PAGE sum_flow - main routine

var v: vl_link;

begin
  reset (xrf_file, tempname ('XRF'));
  while xrf_file^.code <> block_xrf do
    get (xrf_file);
  process_block (xrf_file^.parameter);

  (*  If there is an external procedure, we assume that it can modify and
      use every public, external, file, and heap variable.  *)

  if ext_block <> nil then begin
    v := vl_list;
    while v <> nil do
      with v^ do begin
        if symbol^.public_dcl or
          (symbol^.dcl_class in [external_sc, dynamic_sc, fileblk_sc, opt_sc]) then begin
            add_elem (mod0, ext_block^.number, symbol^.id_number);
            add_elem (use0, ext_block^.number, symbol^.id_number);
          end;
        v := last;
      end;
  end;
  close (xrf_file);
end  (* sum_flow *).
  
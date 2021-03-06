$WIDTH=100
$LENGTH=55
$TITLE PASSMO.PAS, last modified 1/10/84, zw
MODULE passmo OPTIONS SPECIAL(WORD);
(*TYM-Pascal compiler -- semantic options*)

$PAGE system modules

$SYSTEM PASCAL.INC
$SYSTEM UTLSW.INC
$SYSTEM PASIST.INC
$SYSTEM PASPT.TYP
$SYSTEM PASERR.INC
$SYSTEM PASUTL.INC
$SYSTEM PASOPD.INC

$PAGE sem_check_options

PROCEDURE sem_check_options
  (nodes: parse_node; subr_block: blk; positive: BOOLEAN);
(*called with the sub-options list for a CHECK option, and the sign
  of the option.  It updates the current semantic options.*)
VAR sub_opt: parse_node; idx, opt_code: integer; opt_set: SET OF checklist;
BEGIN
  IF nodes = NIL THEN opt_set := [MINIMUM(checklist) .. MAXIMUM(checklist)]
  ELSE BEGIN
    opt_set := []; sub_opt := nodes;
    WHILE sub_opt <> NIL DO BEGIN
      idx := 1;
      IF cmd_lookup(sub_opt^.name^.text, idx, ['A' .. 'Z'],
        opdcot_chk_opt_table, opt_code)
      THEN opt_set := opt_set + [opdmtc_map_to_chk_opt[chk_opts(opt_code)]]
      ELSE err_node(err_chk_sub_option, sub_opt);
      sub_opt := sub_opt^.next
    END
  END;
  WITH subr_block^ DO IF positive
  THEN semantic_options :=
    semantic_options - [MINIMUM(checklist) .. MAXIMUM(checklist)] + opt_set
  ELSE semantic_options := semantic_options - opt_set
END;

$PAGE sem_special_options

PROCEDURE sem_special_options
  (nodes: parse_node; subr_block: blk; positive: BOOLEAN);
(*called with the sub-options list for a SPECIAL option, and the
  sign of the option.  It updates the current semantic options.*)
VAR
sub_opt: parse_node; idx, opt_code: INTEGER; opt_set: SET OF speciallist;
BEGIN
  IF nodes = NIL THEN opt_set := [MINIMUM(speciallist) .. MAXIMUM(speciallist)]
  ELSE BEGIN
    opt_set := []; sub_opt := nodes;
    WHILE sub_opt <> NIL DO BEGIN
      idx := 1;
      IF cmd_lookup(sub_opt^.name^.text, idx, ['A' .. 'Z'],
        opdsot_sp_opt_table, opt_code)
      THEN opt_set := opt_set + [opdmts_map_to_sp_opt[sp_opts(opt_code)]]
      ELSE err_node(err_sp_sub_option, sub_opt);
      sub_opt := sub_opt^.next
    END
  END;
  WITH subr_block^ DO IF positive
  THEN semantic_options := semantic_options + opt_set
  ELSE semantic_options := semantic_options - opt_set
END;

$PAGE set_sem_options

PUBLIC FUNCTION set_sem_options
  (opt_node: parse_node;   (*links to name of option word*)
   subr_type: typ; (*type node of subroutine *)
   subr_block: blk (*block node of same *)
   ): BOOLEAN;     (*if false, error code is set *)
(*sets a single semantic option for a subroutine as
  represented by its block and type nodes.  If the block node pointer
  is nil, the subroutine is assumed to be external, determining 
  whether or not certain options are applicable.*)
VAR
dump_id: parse_node; (*for chain of dump identifiers*)
positive: BOOLEAN;
opt_ix: INTEGER;
option_ix: option_scalar; (*for lookup*)
ix: INTEGER; (*dummy index for lookup_options*)
BEGIN
  set_sem_options := FALSE; (*assume false -- error return*)
  WITH opt_node^.name^ DO BEGIN
    positive := NOT ((LENGTH(text) >= 2) ANDIF (SUBSTR(text, 1, 2) = 'NO'));
    IF positive THEN ix := 1 ELSE ix := 3;
    IF NOT cmd_lookup(text, ix, ['A'..'Z'], opdotb_option_table, opt_ix)
    THEN BEGIN err_node(err_bad_option, opt_node); RETURN END
  END;
  option_ix := option_scalar(opt_ix);
  IF NOT positive AND NOT (option_ix IN opdnoo_no_options) THEN BEGIN
    err_node(err_sem_opt_bad, opt_node); return
  END;
  IF NOT (option_ix IN opdblo_block_options) THEN BEGIN
    err_node(err_sem_opt_bad, opt_node); RETURN
  END;
  IF option_ix = opt_fortran THEN BEGIN
    IF subr_block <> NIL THEN BEGIN
      err_node(err_int_opt_bad, opt_node); RETURN
    END
  END
  ELSE BEGIN
    IF subr_block = NIL THEN BEGIN
      err_node(err_ext_opt_bad, opt_node); RETURN
    END
  END;
  (*process option*)
  CASE option_ix OF
    opt_fortran: subr_type^.fortran_call := true;
    opt_storage: BEGIN
      IF subr_block^.kind <> program_blk THEN BEGIN
        err_node(err_prog_option, opt_node); RETURN
      END;
      IF (opt_node^.defn = NIL) ORIF (opt_node^.defn^.sym <> intconst)
      THEN BEGIN
        err_node(err_number_expected, opt_node); RETURN
      END;
      prog_options.storage := opt_node^.defn^.value.ival
    END;
    opt_alloc: BEGIN
      IF subr_block^.kind <> program_blk THEN BEGIN
        err_node(err_prog_option, opt_node); RETURN
      END;
      IF (opt_node^.defn = NIL) ORIF (opt_node^.defn^.sym <> intconst)
      THEN BEGIN
        err_node(err_number_expected, opt_node); RETURN
      END;
      IF opt_node^.defn^.value.ival > 99 THEN BEGIN
        err_node(err_alloc_mode, opt_node); RETURN
      END;
      prog_options.alloc_mode := opt_node^.defn^.value.ival
    END;
    opt_overlay: BEGIN
      IF subr_block^.kind <> module_blk THEN BEGIN
        err_node(err_ovl_module, opt_node); RETURN
      END;
      IF positive AND prog_options.mainseg_opt THEN BEGIN
        err_node(err_ovl_mainseg, opt_node); RETURN
      END;
      prog_options.overlay_opt := positive
    END;
    opt_mainseg: BEGIN
      IF positive AND prog_options.overlay_opt THEN BEGIN
        err_node(err_ovl_mainseg, opt_node);
        prog_options.overlay_opt := FALSE
      END;
      prog_options.mainseg_opt := TRUE
    END;
    opt_debug: BEGIN
      IF NOT (subr_block^.kind IN [program_blk, module_blk]) THEN BEGIN
        err_node(err_deb_module, opt_node); RETURN
      END;
      prog_options.debug_opt := positive;
      IF positive AND (optimize_opt IN subr_block^.semantic_options) THEN BEGIN
        err_node(err_deb_optimize, opt_node);
        subr_block^.semantic_options :=
	  subr_block^.semantic_options - [optimize_opt];
        RETURN
      END
    END;
    opt_masking: BEGIN
      IF subr_block^.kind <> program_blk THEN BEGIN
        err_node(err_prog_option, opt_node); RETURN
      END;
      prog_options.masking_opt := positive
    END;
    opt_underflow: BEGIN
      IF subr_block^.kind <> program_blk THEN BEGIN
	err_node(err_prog_option, opt_node); RETURN
      END;
      prog_options.underflow_opt := positive
    END;
    opt_global: BEGIN
      IF NOT (subr_block^.kind IN [program_blk, module_blk, data_blk])
      THEN BEGIN err_node(err_prog_option, opt_node); RETURN END;
      prog_options.global_opt := positive
    END;
    opt_standard: err_node(err_standard, opt_node);
    opt_check: sem_check_options(opt_node^.defn, subr_block, positive);
    opt_trace .. opt_optimize: BEGIN
      IF (option_ix = opt_optimize) AND positive AND prog_options.debug_opt
      THEN BEGIN err_node(err_deb_optimize, opt_node); RETURN END;
      WITH subr_block^ DO IF positive
      THEN semantic_options :=
        semantic_options + [opdmto_map_to_optionlist[option_ix]]
      ELSE semantic_options :=
        semantic_options - [opdmto_map_to_optionlist[option_ix]]
    END;
    opt_special: sem_special_options(opt_node^.defn, subr_block, positive);
    opt_dump: BEGIN
      dump_id := opt_node^.defn; (*pointer to first dump parameter*)
      WHILE dump_id <> NIL DO BEGIN
        subr_block^.dump_switches :=
          enasw(subr_block^.dump_switches, dump_id^.name^.text, positive);
        dump_id := dump_id^.next
      END
    END
  END;
  set_sem_options := TRUE (*no error*) 
END.
  
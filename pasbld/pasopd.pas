$TITLE PASOPD.PAS, lst modified 5/11/84, zw
MODULE pasopd OPTIONS special(word);
(*TYM-Pascal compiler Option Definitions Data Module*)
$INCLUDE pascal
$INCLUDE cmdutl
$INCLUDE pasopd.typ
$PAGE options
PUBLIC CONST
opdotb_option_table: op_list = ( ( 'TERSE     ', 1, ORD (opt_terse) )
  , ( 'VERBOSE   ', 1, ORD (opt_verbose) )
  , ( 'LENGTH    ', 3, ORD (opt_length) ), ( 'WIDTH     ', 3, ORD (opt_width)
  ), ( 'ENABLE    ', 2, ORD (opt_enable) )
  , ( 'DISABLE   ', 3, ORD (opt_disable) ), ( 'QUICK     ', 1, ORD (opt_quick)
  ), ( 'STATISTICS', 4, ORD (opt_statistics) )
  , ( 'NAMES     ', 4, ORD (opt_names) ), ( 'CODE      ', 3, ORD (opt_code) )
  , ( 'FINISH    ', 3, ORD (opt_finish) ), ( 'SOURCE    ', 1, ORD (opt_source)
  ), ( 'SEARCH    ', 3, ORD (opt_search) )
  , ( 'LSYSTEM   ', 4, ORD (opt_lsystem) )
  , ( 'ERRORS    ', 3, ORD (opt_errors) ), ( 'BANNER    ', 3, ORD (opt_banner)
  ), ( 'KICODE    ', 2, ORD (opt_kicode) ), ( 'CHECK     ', 2, ORD (opt_check)
  ), ( 'TRACE     ', 2, ORD (opt_trace) )
  , ( 'QBLOCKS   ', 3, ORD (opt_qblocks) ), ( 'MAP       ', 3, ORD (opt_map) )
  , ( 'SYMBOLS   ', 3, ORD (opt_symbols) ), ( 'CALLS     ', 2, ORD (opt_calls)
  ), ( 'ASSEMBLY  ', 1, ORD (opt_assembly) )
  , ( 'XREF      ', 1, ORD (opt_xref) ), ( 'OPTIMIZE  ', 3, ORD (opt_optimize)
  ), ( 'SPECIAL   ', 2, ORD (opt_special) )
  , ( 'OVERLAY   ', 2, ORD (opt_overlay) )
  , ( 'MAINSEG   ', 4, ORD (opt_mainseg) ), ( 'DEBUG     ', 3, ORD (opt_debug)
  ), ( 'UNDERFLOW ', 5, ORD (opt_underflow) )
  , ( 'MASKING   ', 4, ORD (opt_masking) )
  , ( 'GLOBAL    ', 4, ORD (opt_global) )
  , ( 'STANDARD  ', 4, ORD (opt_standard) ), ( 'DUMP      ', 4, ORD (opt_dump)
  ), ( 'ALLOC     ', 2, ORD (opt_alloc) )
  , ( 'STORAGE   ', 3, ORD (opt_storage) )
  , ( 'FORTRAN   ', 7, ORD (opt_fortran) ), ( 'RUN       ', 3, ORD (opt_run) )
  , ( 'RUNOFFSET ', 6, ORD (opt_runoffset) )
  , ( 'HELP      ', 1, ORD (opt_help) ), ( 'EXIT      ', 4, ORD (opt_exit) ) )
  ;
opdclo_cmdline_options: options_set = [opt_terse..opt_storage];
opdblo_block_options: options_set = [opt_check..opt_fortran];
opdnoo_no_options : options_set = [opt_quick..opt_dump];
opdauo_auto_options: options_set = [opt_source, opt_quick];
opdmto_map_to_optionlist: in_options_set = ( trace_opt, qblocks_opt, map_opt,
  symbols_opt, calls_opt, assembly_opt, xref_opt, optimize_opt ) ;
opdmfo_map_from_optionlist: to_options_set = ( opt_check, opt_check, opt_check
  , opt_check, opt_check, opt_check, opt_check, opt_check, opt_check,
  opt_check, opt_check, opt_special, opt_special, opt_special, opt_map,
  opt_symbols, opt_calls, opt_assembly, opt_xref, opt_trace, opt_qblocks,
  opt_optimize );
$PAGE CHECK suboptions
PUBLIC CONST
opdcot_chk_opt_table: chk_op_list = ( ( 'ASSERTIONS', 3, ORD (opt_chk_ass) )
  , ( 'CASES     ', 3, ORD (opt_chk_cas) )
  , ( 'COMPATIBIL', 3, ORD (opt_chk_com) )
  , ( 'FIELDS    ', 3, ORD (opt_chk_fld) )
  , ( 'FILES     ', 3, ORD (opt_chk_fil) )
  , ( 'INPUT     ', 3, ORD (opt_chk_inp) )
  , ( 'POINTERS  ', 3, ORD (opt_chk_poi) )
  , ( 'STRINGS   ', 3, ORD (opt_chk_str) )
  , ( 'SUBSCRIPTS', 3, ORD (opt_chk_sub) )
  , ( 'VALUES    ', 3, ORD (opt_chk_val) )
  , ( 'STACK     ', 3, ORD (opt_chk_stk) ) );
opdmtc_map_to_chk_opt: in_chk_opt_set = ( chk_ass_opt, chk_cas_opt,
  chk_com_opt, chk_fld_opt, chk_fil_opt, chk_inp_opt, chk_poi_opt, chk_str_opt
  , chk_sub_opt, chk_val_opt, chk_stk_opt );
opdmfc_map_from_chk_opt: to_chk_opt_set = ( opt_chk_ass, opt_chk_cas,
  opt_chk_com, opt_chk_fld, opt_chk_fil, opt_chk_inp, opt_chk_poi, opt_chk_str
  , opt_chk_sub, opt_chk_val, opt_chk_stk );
$PAGE SPECIAL suboptions
PUBLIC CONST
opdsot_sp_opt_table: sp_op_list = ( ( 'COERCIONS ', 3, ORD (opt_sp_coe) )
  , ( 'PTR       ', 3, ORD (opt_sp_ptr) ), ( 'WORD      ', 3, ORD (opt_sp_wor)
  ) );
opdmts_map_to_sp_opt: in_sp_opt_set = ( sp_coe_opt, sp_ptr_opt, sp_wor_opt );
opdmfs_map_from_sp_opt: to_sp_opt_set = ( opt_sp_coe, opt_sp_ptr, opt_sp_wor )
  ;
$PAGE immediate commands
PUBLIC CONST
opdict_imd_cmd_table: imd_list = ( ( 'ENVIRON   ', 3, ORD (imd_environment) )
  , ( 'TARGET    ', 3, ORD (imd_target) ) );
$PAGE opd_dummy
PUBLIC
PROCEDURE opd_dummy;
BEGIN
END.
    
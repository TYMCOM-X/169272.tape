$WIDTH=100
$LENGTH=55
$TITLE PASS1.PAS, alst modified 1/10/84, zw
PROGRAM pass1 OPTIONS STORAGE(6000), SPECIAL(WORD);
(*TYM-Pascal compiler pass 1 -- syntax analysis*)

$PAGE system modules

$SYSTEM PASCAL.INC
$SYSTEM PASENV.INC
$SYSTEM PASFIL.INC
$SYSTEM PASIST.INC
$SYSTEM PTMCON.INC
$SYSTEM PASPT.TYP
$SYSTEM PASIF.TYP
$SYSTEM PASLEX.INC
$SYSTEM PASERR.INC
$SYSTEM PASCFM.INC
$SYSTEM UTLSW.INC
$SYSTEM PASOPD.INC
$SYSTEM COROUT.INC
$SYSTEM UTLOPN.INC
$SYSTEM PASRDR.INC
$SYSTEM PASCGR.INC
$SYSTEM PA1XRF.INC
$SYSTEM PASGLB.INC
$SYSTEM PASANL.INC
$SYSTEM PASBLK.INC
$SYSTEM PASTAL.INC
$SYSTEM PASALC.INC
$SYSTEM PASIFU.INC
$SYSTEM PASCV.INC
$SYSTEM PA1DMP.INC
$SYSTEM PASDMP.INC
$SYSTEM DTIME.INC
$SYSTEM PASLOG.INC
$SYSTEM INFPAC.INC

$PAGE check_types

PROCEDURE check_types;
(*This is called at the end of an environment compilation to examine
  all the type identifiers defined in the root block, and print
  error messages if any of them are undefined.*)
VAR ts: sym;
BEGIN
  ts := root_block^.type_list.first;
  WHILE ts <> NIL DO BEGIN
    WITH ts^.type_desc^ DO BEGIN
      IF (kind = unknown_type) ANDIF (type_id <> NIL) ANDIF
        (type_id^.name <> nil) 
      THEN BEGIN
	err_print(err_type_warning, declaration, type_id^.name^.text, 0);
        declaration := null_source
      END
    END;
    ts := ts^.next
  END
END;

$PAGE do_pass_1

PROCEDURE do_pass_1;
(*TYM-Pascal compiler first pass*)
VAR dtime: dtime_ext;
CONST reader_stack_size = 2000;
LABEL 100; (* abort *)
PROCEDURE abt_pass1; (* record line where reading aborted *)
BEGIN detach; fin_source := cur_source; GOTO 100 END;
BEGIN
  dtime := dc_ext(DAYTIME());
  cdatesym^.init_value.valp^.str_val[1:9] := SUBSTR(dtime, 1, 9);
  ctimesym^.init_value.valp^.str_val[1:8] := SUBSTR(dtime, 11, 8);
  all_opts := [];
  cur_block := root_block;
  ext_block := NIL; lex_block := NIL;
  blk_number := 0; max_level := 0;
  heap_chain := NIL;
  sym_vl_number := vl_base; sym_nvl_number := nvl_base;
  vl_list := vll_base;
  err_count := 0; warnings := 0;
  linect := 0; inclct := 0;
  elf_status := unopened; elf_open;
  df_status := unopened; (* tell PASDMP to open on first reference *)
  xrf_init; lex_init; tal_init; alc_init;
  initparse;
  ch_init; ch_open(FALSE, TRUE);
  IF prog_options.global_opt THEN glob_init;
  abort := abt_pass1; (*procedure to do the actual abort*)
  reader := create(read_input_lines, reader_stack_size);
  semantics; (*do the actual first pass analysis*)
  IF sw(root_block^.dump_switches, 'NAMES') THEN dump_name_table;
  IF sw(root_block^.dump_switches, 'ROOTST') THEN BEGIN
    dmpblock(root_block); dmpstable(root_block)
  END;
  finish := (NOT env_compilation) AND ((max_severity = 0) OR
    ((max_severity = 1) AND prog_options.finish_opt));
  endparse;
  IF env_compilation THEN check_types;
  IF finish THEN BEGIN
    fin_graph; (* includes the quick block analysis *)
    allocate_storage; (* gives addresses to all var, value and const symbols *)
  END;
  100: (*abort*)
  DISPOSE(reader);
  xrf_close; elf_close; dmp_close; ch_close;
  IF prog_options.global_opt THEN glob_term;
END;

$PAGE next_pass

PROCEDURE next_pass;
(*initiate next pass*)
VAR next: STRING[6];
BEGIN
  opts_listing := (list_file <> '') ANDIF (src_selected ORIF
    ([symbols_opt, xref_opt, calls_opt] * all_opts <> []) ORIF
    (prog_options.code_opt ANDIF ([assembly_opt, map_opt] * all_opts <> [])
    ANDIF prog_options.banner_opt));
  IF (rel_file = '') AND ((list_file = '') OR NOT (assembly_opt IN all_opts))
  THEN prog_options.code_opt := FALSE;
  quick := NOT have_optimizer OR (have_checkout AND
    ((prog_options.quick_opt = opt_is_on) OR
    ((prog_options.quick_opt = opt_is_auto) AND
    NOT (optimize_opt IN all_opts))));
  IF finish AND (prog_options.code_opt OR (prog_options.dump_switches <> NIL))
  THEN BEGIN
    IF quick THEN BEGIN
      IF opts_listing OR (err_count <> 0) THEN next := 'PASLST'
      ELSE next := tmprefix || 'CCG'
    END
    ELSE next := tmprefix || 'SHP'
  END
  ELSE IF opts_listing OR (err_count <> 0) THEN next := 'PASLST'
  ELSE next := 'PASCAL';
  log_record.no_lines := linect;
  log_record.no_incl_lines := inclct;
  log_record.no_errors := err_count - warnings;
  log_record.date_and_time := root_block^.children^.comp_dtime;
  log_record.alloc_strategy := prog_options.alloc_mode;
  log_record.opt_debug := prog_options.debug_opt;
  log_record.opt_check :=
    ([MINIMUM(checklist) .. MAXIMUM(checklist)] * all_opts <> []);
  log_record.opt_main := (root_block^.children^.kind = program_blk);
  log_record.opt_overlay := prog_options.overlay_opt;
  log_record.opt_source := src_selected;
  log_record.opt_special :=
    ([MINIMUM(speciallist) .. MAXIMUM(speciallist)] * all_opts <> []);
  log_record.opt_terse := prog_options.terse_opt;
  log_record.opt_trace := (trace_opt in all_opts);
  log_record.opt_xref := prog_options.global_opt;
  log_record.lowseg_size := 0;
  log_record.highseg_size := 0;
  log_record.ki10:=prog_options.ki_code_opt;
  chain(next)
END;

$PAGE save_env, main block

PROCEDURE save_env(env_fil: FILE_NAME);
(*write the current environment to a specified file*)
VAR save_main_file_name: FILE_NAME;
BEGIN
  save_main_file_name := main_file; main_file := '';
  cmd_clear;
  popsw(default_options.switches, NIL);
  popsw(default_options.dump_switches, NIL);
  IF NOT wrpas('.ENV ' || env_fil)
  THEN byebye('?unable to write environment to file ' || env_fil);
  main_file := save_main_file_name
END;

VAR start_time: INTEGER; segstuff: segrecd;

EXTERNAL FUNCTION fileblock(VAR TEXT): filblock; (*where is this defined??*)

BEGIN
  unchain;
  start_time := RUNTIME;
  IF opnsrc(prog_options.search_list, INPUT, '.PAS ' || main_file) THEN;
  log_record.file_name := fileblock(INPUT);
  log_record.run_time := start_time;
  IF prog_options.names_opt
  THEN ttymsg('[compiling ' || FILENAME(INPUT) || ']');
  root_block^.semantic_options := prog_options.semantic_options;
  root_block^.dump_switches := prog_options.dump_switches;
  do_pass_1;
  IF env_compilation AND ((max_severity = 0) OR
    ((max_severity = 1) AND prog_options.finish_opt)) AND (rel_file <> '')
  THEN save_env(rel_file);
  IF prog_options.statistics_opt THEN BEGIN
    REWRITE(TTY); seginfo (segstuff);
    WRITELN(TTY, '[Pass 1: ', (RUNTIME - start_time) / 1000.0: 8: 3,
      ' seconds, ', (segstuff.lowlen + 511) DIV 512: 3, '+',
    (segstuff.highlen + 511) DIV 512: 3, 'P]')
  END;
  next_pass
END.
 
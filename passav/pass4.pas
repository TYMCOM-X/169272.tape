$TITLE PASS4 -- Pascal Compiler Code Generation Pass

program pass4
  options storage(8000);
$PAGE includes
$SYSTEM pascal
$SYSTEM ptmcon
$SYSTEM pasist
$SYSTEM pasfil
$SYSTEM paslog
$SYSTEM paspt.typ
$SYSTEM pasif.typ
$SYSTEM pasifu
$SYSTEM pasdat
$SYSTEM pastal
$SYSTEM ptmgen
$SYSTEM pascv
$SYSTEM passw
$SYSTEM prgdir
$SYSTEM infpac
$SYSTEM run
$SYSTEM tmpnam

external var
    auto_run: boolean;
$PAGE pass4 - main program
var start_time: integer;
    segstuff: segrecd;
    code_size, const_size, static_size: unit_range;

begin
  start_time := runtime;
  if not dat_get (tempname ('PAS'), true) then begin
    rewrite (tty);
    writeln (tty, '?Compiler temporary file PAS lost');
    stop;
  end;

  rewrite (tty);

  if finish and prog_options.code_opt then begin
    ch_open (true, false);
    tal_init;
    gen_code (code_size, const_size, static_size);
    ch_close;
  end;

  if prog_options.statistics_opt then begin
    seginfo (segstuff);
    writeln (tty, '[Pass 4: ', (runtime - start_time) / 1000.0:8:3, ' seconds, ',
                  (segstuff.lowlen+511) div 512:3, '+',
                  (segstuff.highlen+511) div 512:3, 'P]');
    if finish and prog_options.code_opt then begin
      writeln (tty, '[Code area:      ', cv_radix (code_size, adr_width), ' words (',
                    cv_int (code_size), ' decimal)]');
      writeln (tty, '[Constant area:  ', cv_radix (const_size, adr_width), ' words (',
                    cv_int (const_size), ' decimal)]');
      writeln (tty, '[Static area:    ', cv_radix (static_size, adr_width), ' words (',
                    cv_int (static_size), ' decimal)]');
      writeln (tty);
    end;
  end;

  close (ttyoutput);
  
  if auto_run then begin
    if prog_options.overlay_opt then begin
      log_record.lowseg_size := const_size + static_size;
      log_record.highseg_size := code_size;
    end
    else begin
      log_record.lowseg_size := static_size;
      log_record.highseg_size := code_size + const_size;
    end;
    log_write;
    run ('PASCMD' || prgm_dir (), true);
    rewrite (tty);
    writeln (tty, '?Unable to run PASCMD');
  end;
end.
 
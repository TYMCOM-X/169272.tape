program doctrim;

var document_list, pmf_temp, scribe_temp: text;
    document, line, uline: string [256];

begin
  rewrite (tty);
  reset (document_list, 'DOCMNT.LIS');
  if iostatus <> io_ok then begin
    writeln (tty, '?Cannot read DOCMNT.LIS');
    assert (false);
  end;
  rewrite (pmf_temp, 'DCMNT1.TMP');
  rewrite (scribe_temp, 'DOCMNT.TMP');
  while not eof (document_list) do begin
    readln (document_list, document);
    document := uppercase (document);
    reset (input, document || '.DOC');
    if iostatus <> io_ok then
      writeln (tty, '%Could not open ', document, '.DOC')
    else begin
      rewrite (output, document || '.TMP');
      while not eof do begin
	readln (line);
	uline := uppercase (line);
	if (index (uline, '#WIDTH') = 0) and
	   (index (uline, '#CHANGE') = 0) and
	   (index (uline, '#EXTERNAL') = 0) and
	   (index (uline, '#RESPONSIBLE') = 0) then
	  writeln (line);
      end;
      close (input);
      close (output);
      writeln (pmf_temp, document, '.TMP=',
			 document, '.TMP/LIB:DOCMNT[31024,320156]/NOPASCAL');
      writeln (scribe_temp, '$INCLUDE ', document, '.TMP');
      writeln (scribe_temp, '$PAGE');
    end;
  end;
end.
 
$PAGE prline
(* QPRINT.PAS - modified 9/24/81 by djm to change chr(11b) to tab *)

module qprint
  options special;
public procedure prline
(	var outfile: text;			(* file to write to *)
	line: qstring;				(* text to write out *)
        tab_print: boolean;                     (* flag for &I printing *)
        var err: qerrcode);			(* checks for write errors *)

var
  i: qlineno;

begin
  for i := 1 to length (line) do
  begin
    if (ord(line[i]) > #o37) orif (tab_print and (line[i] = tab))
      then write(outfile, line[i])
      else write(outfile, '&', chr(ord(line[i]) + #o100));
  exit if not eof(outfile) do err := qwrterr
  end;
  writeln (outfile);
  if not eof(outfile) then err := qwrterr
end;
$PAGE qlistlines
public procedure qlistlines
(	var buffer: qbuffer;			(* working buffer *)
	low,
	high: qlineno;				(* range of lines to print *)
	var outfile: text;			(* to this file *)
	ctl_char,
	number,        			(* flags to modify printing *)
        tab_print: boolean;                     (* flag for &I printing *)
        var err: qerrcode);			(* set if write errors occur *)

var
  i: qlineno;
  line: qstring;

begin
  i := low;
  err := qok;
  while (err = qok) and (i <= high) do
  begin
    line := qgetline (buffer, i, err);
    if err = qok then
    begin
      if number then begin
        write( outfile, i:5, tab);
        if not eof(outfile) then err := qwrterr
      end;
      if err = qok then begin
	if ctl_char then prline (outfile, line, tab_print, err)
        else begin
          writeln(outfile, line);
          if not eof(outfile) then err := qwrterr
        end;
	i := i + 1
      end
    end
  end
end.
    
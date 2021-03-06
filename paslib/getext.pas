$TITLE GETEXT - Program to get public declarations from a source file

program getext;

$SYSTEM (pasdev27)getiof
$SYSTEM (pasdev2)cmdutl
$PAGE global variables
var token : string;		(* the current token -- '' => EOF *)
    spacing : integer;		(* # of spaces preceding it *)
    new_line : boolean;		(* true => first token on line *)
    first : boolean;		(* nothing written yet *)

    (*  GET TOKEN private variables.  *)

    tline : string [256];
    tlidx : integer;

exception
    error;
$PAGE get_token
(*  GET TOKEN will read the next token from the source file.  A token is a
    special character, alphanumeric string, or quoted string.  The text of
    the token is stored into the global string TOKEN.  If the token was the
    first on a line, then the global counter SPACING will be set to the
    number of leading spaces plus two; otherwise, SPACING will be set to
    zero.  When EOF becomes true, TOKEN and SPACING will be undefined.  *)

procedure get_token;

var cmt_level : integer;
    oldidx : integer;

begin
  token := '';
  spacing := 0;
  new_line := false;
  cmt_level := 0;
  while (token = '') and (not eof) do begin
    oldidx := tlidx;
    if cmd_eol (tline, tlidx) then begin
      readln (tline);
      tline := uppercase (tline);
      if (length (tline) <> 0) andif (tline[1] = '$') then
	tline := '';
      tlidx := 1;
      spacing := 2;
      new_line := true;
    end
    else if cmt_level = 0 then begin
      spacing := spacing + tlidx - oldidx;
      if (tlidx < length (tline)) andif (substr (tline, tlidx, 2) = '(*') then begin
	cmt_level := 1;
	tlidx := tlidx + 1;
      end
      else if cmd_token (tline, tlidx, ['A'..'Z', '0'..'9', '_', '.', '$', '#'], token) then
	(* success *)
      else if cmd_check_punct (tline, tlidx, '''') then begin
	if cmd_dqstring (tline, tlidx, '''', token) then
	  token := '''' || token || ''''
	else begin
	  writeln (tty, 'Unterminated string:', tline);
	  signal (error);
	end;
      end
      else if cmd_check_punct (tline, tlidx, ':') then begin
	if (tlidx <= length (tline)) andif (tline[tlidx] = '=') then begin
	  token := ':=';
	  tlidx := tlidx + 1;
	end
	else
	  token := ':';
      end
      else begin
	token := tline[tlidx];
	tlidx := tlidx + 1;
      end;
    end
    else (* cmt_level <> 0 *) begin
      tlidx := tlidx + search (substr (tline, tlidx), ['(', '*'],
			       length (tline) - tlidx + 2) - 1;
      if (tlidx < length (tline)) then begin
	if substr (tline, tlidx, 2) = '(*' then begin
	  cmt_level := cmt_level + 1;
	  tlidx := tlidx + 2;
	end
	else if substr (tline, tlidx, 2) = '*)' then begin
	  cmt_level := cmt_level - 1;
	  tlidx := tlidx + 2;
	end
	else
	  tlidx := tlidx + 1;
      end
      else
	tlidx := tlidx + 1;
    end;
  end;
  if cmt_level <> 0 then begin
    writeln ('Unterminated comment');
    signal (error);
  end;
end;
$PAGE delimiter
(*  DELIMITER is the predicate which tests whether a token string would
    indicate the end of a preceding declaration.  *)

function delimiter : boolean;

begin
  delimiter := (token = 'PROCEDURE') or
	       (token = 'FUNCTION') or
	       (token = 'VAR') or
	       (token = 'TYPE') or
	       (token = 'CONST') or
	       (token = 'LABEL') or
	       (token = 'EXCEPTION') or
	       (token = 'BEGIN') or
	       (token = 'STATIC') or
	       (token = 'EXTERNAL') or
	       (token = 'FORWARD');
end;
$PAGE write_token
(*  WRITE TOKEN will write the token string to the output file, allowing
    preliminary spacing for a preceding end-of-line.  *)

procedure write_token;

begin
  if new_line and not first then
    writeln;
  first := false;
  if token = 'PUBLIC' then begin
    token := 'EXTERNAL';
    if new_line then
      spacing := spacing - 2;
  end;
  write ('':spacing, lowercase (token));
end;
$PAGE scan_source_file
(*  SCAN SOURCE FILE will copy all the public declarations from the INPUT
    file to the OUTPUT file, changing 'PUBLIC' to 'EXTERNAL'.  *)

procedure scan_source_file;

var copy : (yes, no, scan, skip_to_semi);
    paren_level : integer;

begin
  copy := no;
  paren_level := 0;
  first := true;
  tline := '';
  tlidx := 1;
  get_token;
  while token <> '' do begin
    case copy of

      no :
	if token = 'PUBLIC' then begin
	  write_token;
	  copy := yes;
	end;

      yes :
	begin
	  write_token;
	  copy := scan;
	end;

      scan :
	begin
	  if token = '(' then
	    paren_level := paren_level + 1;
	  if token = ')' then
	    paren_level := paren_level - 1;
	  if (paren_level = 0) and delimiter then
	    copy := no
	  else if token = 'PUBLIC' then begin
	    write_token;
	    copy := yes;
	  end
	  else if (token = '=') or (token = ':=') or (token = 'OPTIONS') then
	    copy := skip_to_semi
	  else
	    write_token;
	end;

      skip_to_semi:
	if token = ';' then begin
	  copy := scan;
	  write_token;
	end;

    end;
    get_token;
  end;
  if copy <> no then begin
    writeln (tty, 'Incomplete declaration');
    signal (error);
  end;
  writeln;
  close (input);
  close (output);

exception
  error: begin
    close (input);
    scratch (output);
  end;
end;
$PAGE getext - main program
begin
  rewrite (tty);
  open (tty);
  while getiofiles (input, 'PAS', output, 'INC') do
    scan_source_file;
end.
  
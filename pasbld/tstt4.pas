program test3 options special, noch;
var f: file of integer;
  ch: char;
  s: string;
begin
  rewrite (tty); open (tty);
  loop
    write (tty,'File: ');
    break (tty);
    readln (tty);
  exit if eoln (tty);
    s := '';
    while not eoln (tty) do begin
      read (tty,ch);
      s := s || ch;
    end;
    reset (f,s);
    if eof (f) then writeln (tty,'Can''t find file ',s)
    else writeln (tty,filename(f));
    close (f);
  end;
end.
    
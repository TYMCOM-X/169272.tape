program prog options sp, noch;
var s: string;
begin
  rewrite (tty); open (tty);
  loop
    write (tty,'File: '); break;
    readln (tty);
  exit if eoln (tty);
    read (tty,s);
    open (input,s);
    if not eof (input) then writeln (tty,filename(input))
    else writeln (tty,'Can''t open file ',s);
    close (input);
  end;
end.
 
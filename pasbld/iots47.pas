program iots47;

var
  f, g: file of *;
  buf: ^ array [1..*] of integer;
  bufsiz: integer;
  i: integer;
  target, source: string[100];

begin
  rewrite (ttyoutput); open (tty);
  loop
    write (tty, 'Target: '); break (tty); readln (tty);
    read (tty, target);
  exit if target = '';
    write (tty, 'Source: '); break (tty); readln (tty);
    read (tty, source);
  exit if source = '';
    write (tty, 'Buffer size: '); break (tty); readln (tty);
    read (tty, bufsiz);
    new (buf, bufsiz);
    reset (f, source);
    rewrite (g, target);
    for i := 1 to ( extent (f) div bufsiz ) do begin
      read (f, buf^: bufsiz);
      write (g, buf^: bufsiz)
      end;
    read (f, buf^: extent (f) mod bufsiz);
    write (g, buf^: extent (f) mod bufsiz);
    writeln (tty, filename (g));
    writeln (tty, ' got ', extent (f): 0, ' words from ');
    writeln (tty, filename (f));
    close (f); 
    close (g);
    dispose (buf);
  end
end.
  
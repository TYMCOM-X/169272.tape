program iots42;

begin
  open (tty, 'tty:', [ascii]);
  rewrite (tty);
  loop
    break (tty);
    get (tty);
    if eoln (tty) then write (tty, 'Eoln  ');
    if eof (tty) then write (tty, 'Eof ');
    if eopage (tty) then write (tty, 'Eopage ');
    writeln (tty, '[', ord (tty^):3:o, ']');
  end
end.
  
program iots48;

var
  i, j: integer;

begin
  open (tty); rewrite (ttyoutput);
  loop
    write (tty, '#'); break (tty); readln (tty);
    read (tty, i, j);
  exit if (i = 0) and (j = 0);
    writeln (tty, i:0, ' mod ', j:0, ' = ', (i mod j):0)
  end
end.
    
program iots26;

type
  doublereal = real;

var
  f, g: text;
  r: doublereal;
  i: -10000 .. 10000;

begin
  open (f, 'tty:');
  rewrite (g, 'tty:');
  loop
    write (g, 'Enter integer:'); break (g); readln (f); read (f, i);
  exit if i = 0;
    r := 0.0;
    while i > 0 do begin
      i := i - 1;
      r := r + 1.0
      end;
    r := 1.0 / r;
    for i := 1 to 20 do
      writeln (g, '[', r:22:i, '] [', r:25:i, ']' )
  end
end.
   
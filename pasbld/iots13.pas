program iots13;

var
  f, g: text;
  i: -10000..10000;
  ch: char;
  s: string[200];

begin
  open (f, 'TTY:');
  rewrite (g, 'TTY:');
  loop
    write (g, 'Enter chars: ');
    break (g);
    readln (f);
    while not eoln (f) do begin
      read (f, i);
      read (f, ch);
      if uppercase (ch) = 'B' then read (f, i:i:o)
      else if uppercase (ch) = 'H' then read (f, i:i:h)
      else read (f, i:i);
      writeln (g, i:4, '[', -i:5, '] ', i:4:o, ' ', i:4:h, ' [', i, ']' );
      putstring (s, i:4, '[', -i:5, '] ', i:4:o, ' ', i:4:h, ' [', i, ']' );
      writeln (g, s);
      writeln (g, i:20:o);
      end
    end
end.
    
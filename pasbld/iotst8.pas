program iotst8;

var
  f, g: text;
  i: 0..10000;
  q: packed record
    j,k,l: 0..7
    end;

begin
  open (f, 'FOO.INP');
  rewrite (g, 'FOO.OUT');
  get (f);
  read (f, i);
  writeln (f, 'I equals ', i);
  with q do begin
    j := 0;
    k := 0;
    l := 0
    end;
  read (f, q.k);
  writeln (g, 'q was ', q.j:10, q.k:10, q.l:10);
  close
end.
   
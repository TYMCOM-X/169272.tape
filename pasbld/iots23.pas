program iots23;

var
  f, g: text;
  r: -1.0e23 .. 1.0e23  prec 16;

procedure writeit (r: -1.0e23 .. 1.0e23 prec 16);
  var i: 1..20;

  begin
    for i := 1 to 20 do
      writeln (g, 'E[', r:24:i:e, ']  R[', r:22:i:f, ']  G[', r:22:i );
    break (g);
  end;

begin
  rewrite (g, 'tty:');
  r := 2.0;
  writeit (r);
  r := r / 13.0;
  writeit (r);
end.
  
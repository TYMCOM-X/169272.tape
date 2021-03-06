program iots30;

var
  r: -1.0e23 .. 1.0e23  prec 6;
  i: -10000 .. 10000;

procedure writeit (r: -1.0e23 .. 1.0e23 prec 6);
  var i: 1..20;

  begin
    for i := 1 to 5 do
      writeln (tty, '[', r:24:i*4:e, '] [', r:22:i*4:f, '] [', r:22:i*4, ']');
    break (tty);
  end;

begin
  rewrite (tty);
  open (tty);
  r := 2.0;
    loop
      if eoln (tty) then begin
	write (tty, 'Enter real number(s):'); break (tty); readln (tty)
	end;
      read (tty, r:10);
    exit if r = 0.0;
      writeit (r);
      writeit (1.0/r);
    end
end.
    
program test56 options dump;

 condition cn;

 condition cbb (var a: boolean; b: boolean);

 condition cnr: real;

begin

  writeln (tty) on cn do stop;

  on cnr do cnr := 2.0 :
    begin
      stop
    end;

  on cbb do begin  a := b end :
    stop;

  on anyother do writeln (tty, name) :
    stop;

end.
   
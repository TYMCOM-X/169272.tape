program rnf1 options nocheck;

var ub : packed 0 .. 255;
    uw : packed 0 .. 65535;
    sw : packed -32768..32767;
    sl : integer;

begin
  ub := ub div 2;
  ub := ub div 3;
  ub := ub div 8;
  ub := ub div 32;

  ub := uw div 2;
  ub := uw div 3;
  ub := uw div 8;
  ub := uw div 32;

  ub := sw div 2;
  ub := sw div 3;
  ub := sw div 8;
  ub := sw div 32;

  ub := sl div 2;
  ub := sl div 3;
  ub := sl div 8;
  ub := sl div 32;

  uw := ub div 2;
  uw := ub div 3;
  uw := ub div 8;
  uw := ub div 32;

  uw := uw div 2;
  uw := uw div 3;
  uw := uw div 8;
  uw := uw div 32;

  uw := sw div 2;
  uw := sw div 3;
  uw := sw div 8;
  uw := sw div 32;

  uw := sl div 2;
  uw := sl div 3;
  uw := sl div 8;
  uw := sl div 32;

  sw := ub div 2;
  sw := ub div 3;
  sw := ub div 8;
  sw := ub div 32;

  sw := uw div 2;
  sw := uw div 3;
  sw := uw div 8;
  sw := uw div 32;

  sw := sw div 2;
  sw := sw div 3;
  sw := sw div 8;
  sw := sw div 32;

  sw := sl div 2;
  sw := sl div 3;
  sw := sl div 8;
  sw := sl div 32;

  sl := ub div 2;
  sl := ub div 3;
  sl := ub div 8;
  sl := ub div 32;

  sl := uw div 2;
  sl := uw div 3;
  sl := uw div 8;
  sl := uw div 32;

  sl := sw div 2;
  sl := sw div 3;
  sl := sw div 8;
  sl := sw div 32;

  sl := sl div 2;
  sl := sl div 3;
  sl := sl div 8;
  sl := sl div 32;

end.
 
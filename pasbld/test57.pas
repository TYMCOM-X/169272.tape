program test57 options dump;

type
  s1 = packed [4] 0..3;
  s2 = packed [4] 0..8;
  s3 = packed [4] 0..15;
  s4 = packed [4] 0..16;	(* erroneous *)
  s5 = 0..3;
  s6 = 0..8;
  s7 = packed [2] 0..3;

external procedure p1 (var a: s1);
external procedure p2 (var 0..3);

var
  v1: s1; v2: s2; v3: s3; v5: s5; v6: s6; v7: s7;

begin
  p1 (v1);
  p1 (s2);
  p1 (v3);
  p1 (v5);
  p1 (v7);

  p2 (v5);
  p2 (v6);
  p2 (v7);
end.
  
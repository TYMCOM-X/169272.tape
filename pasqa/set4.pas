program djw4 options dump(noro);

var
  s1, t1: set of 0..15;
  s2, t2: set of 0..31;
  s3, t3: set of 0..47;
  s4, t4: set of 0..63;
  s5, t5: set of 0..79;
  s6, t6: set of 0..95;
  s7, t7: set of 0..111;
  s8, t8: set of 0..127;
  s9, t9: set of 0..9*16-1;
  s10, t10: set of 0..10*16-1;
  s11, t11: set of 0..11*16-1;
  s12, t12: set of 0..12*16-1;
  s13, t13: set of 0..13*16-1;
  s14, t14: set of 0..14*16-1;
  s15, t15: set of 0..15*16-1;
  s40, t40: set of 0..40*16-1;
  s41, t41: set of 0..41*16-1;
  s42, t42: set of 0..42*16-1;
  s75, t75: set of 0..75*16-1;
  s76, t76: set of 0..76*16-1;
  s77, t77: set of 0..77*16-1;
  s78, t78: set of 0..78*16-1;
  s1_b1: set of 16..31;
  s2_b1: set of 16..47;
  s3_b1: set of 16..63;
  s4_b1: set of 16..79;
  s5_b1: set of 16..6*16-1;
  s1_b2: set of 32..47;
  s2_b2: set of 32..63;
  s3_b2: set of 32..5*16-1;
  s4_b2: set of 32..6*16-1;
  s11_b13: set of 13*16..24*16-1;

  arr1: array [1..100] of set of 16..201*16-1;
  s10_b150: set of 150*16..160*16-1;
  i,j: 1..100;

  arr2: array [1..100] of record
			     f1: array [1..31] of integer;
			     f2: set of 0..159
			   end;

begin
  s1 := t1;
  s2 := t2;
  s3 := t3;
  s4 := t4;
  s5 := t5;
  s6 := t6;
  s7 := t7;
  s8 := t8;
  s9 := t9;
  s10 := t10;
  s11 := t11;
  s12 := t12;
  s13 := t13;
  s14 := t14;
  s15 := t15;
  s40 := t40;
  s41 := t41;
  s42 := t42;
  s75 := t75;
  s76 := t76;
  s77 := t77;
  s78 := t78;
  s1 := t2;
  s1 := t3;
  s1 := t4;
  s1 := t11;
  s2 := t1;
  s2 := t11;
  s3 := t1;
  s3 := t2;
  s4 := t1;
  s4 := t2;
  s4 := t3;
  s11 := t1;
  s11 := t2;
  s11 := t3;
  s11 := t8;
  s11 := t9;
  s11 := t10;
  s42 := t1;
  s42 := t3;
  s42 := t11;
  s42 := t41;
  s78 := t1;
  s78 := t2;
  s78 := t11;
  s78 := t41;
  s78 := t75;
  s78 := t77;
  s1_b1 := s2_b1;
  s2_b1 := s1_b1;
  s5 := s4_b1;
  s5 := s3_b1;
  s4_b2 := s5_b1;
  s5_b1 := s4_b2;
  s5_b1 := s3_b2;
  s1 := s5_b1;
  s2 := s5_b1;
  s6 := s5_b1;
  s7 := s5_b1;
  s78 := s5_b1;
  s77 := s4_b2;
  s77 := s11_b13;
  s78 := s11_b13;
  s11_b13 := s78;

  arr1 [i] := s10_b150;
  arr2 [i].f2 := s4_b2;
end.

program djw8 options dump(noro);

type
  one_word_base_0 = set of 0..15;
  one_word_base_1 = set of 16..31;
  one_word_base_2 = set of 32..47;
  two_word_base_0 = set of 0..31;
  two_word_base_1 = set of 16..47;
  three_word_base_0 = set of 0..47;
  three_word_base_1 = set of 16..63;
  four_word_base_0 = set of 0..4*16 - 1;
  five_word_base_0 = set of 0..5*16-1;
  six_word_base_0 = set of 0..6*16-1;
  seven_word_base_0 = set of 0..7*16-1;
  eight_word_base_0 = set of 0..8*16-1;
  nine_word_base_0 = set of 0..9*16-1;
  ten_word_base_0 = set of 0..10*16-1;
  eleven_word_base_0 = set of 0..11*16-1;
  eleven_word_base_4 = set of 4*16..15*16-1;
  twelve_word_base_0 = set of 0..12*16-1;
  fifteen_word_base_0 = set of 0..15*16-1;

var
  ipos, jpos: 0..maximum (integer);
  i, j: integer;
  s1, t1, u1: one_word_base_0;
  i1, j1: lowerbound (one_word_base_0)..upperbound (one_word_base_0);
  s2, t2, u2: two_word_base_0;
  s3, t3, u3: three_word_base_0;
  s3_b1: three_word_base_1;
  s4, t4, u4:four_word_base_0;
  s5, t5, u5: five_word_base_0;
  s6, t6, u6: six_word_base_0;
  s7, t7, u7: seven_word_base_0;
  s8, t8, u8: eight_word_base_0;
  s9, t9, u9: nine_word_base_0;
  s10, t10, u10: ten_word_base_0;
  s11, t11, u11: eleven_word_base_0;
  i11, j11: lowerbound (eleven_word_base_0)..upperbound (eleven_word_base_0);
  s11_b4, t11_b4: eleven_word_base_4;
  i11_b4, j11_b4: lowerbound (eleven_word_base_4)..upperbound (eleven_word_base_4);
  s12, t12, u12: twelve_word_base_0;
  i15, j15: lowerbound (fifteen_word_base_0)..upperbound (fifteen_word_base_0);

begin
  s1 := t1 - u1;
  s2 := t2 - u2;
  s3 := t3 - u3;
  s4 := t4 - u4;
  s5 := t5 - u5;
  s6 := t6 - u6;
  s7 := t7 - u7;
  s8 := t8 - u8;
  s9 := t9 - u9;
  s10 := t10 - u10;
  s11 := t11 - u11;
  s12 := t12 - u12;

  s1 := s1 - u1;
  s2 := s2 - u2;
  s3 := s3 - u3;
  s4 := s4 - u4;
  s5 := s5 - u5;
  s6 := s6 - u6;
  s7 := s7 - u7;
  s8 := s8 - u8;
  s9 := s9 - u9;
  s10 := s10 - u10;
  s11 := s11 - u11;
  s12 := s12 - u12;

  s1 := s1 - t1;
  s2 := s2 - t1;
  s3 := s3 - t1;
  s4 := s4 - t1;
  s5 := s5 - t1;
  s6 := s6 - t1;
  s7 := s7 - t1;
  s8 := s8 - t1;
  s9 := s9 - t1;
  s10 := s10 - t1;
  s11 := s11 - t1;
  s12 := s12 - t1;

  s1 := t1 - u1;
  s2 := t2 - u1;
  s3 := t3 - u1;
  s4 := t4 - u1;
  s5 := t5 - u1;
  s6 := t6 - u1;
  s7 := t7 - u1;
  s8 := t8 - u1;
  s9 := t9 - u1;
  s10 := t10 - u1;
  s11 := t11 - u1;
  s12 := t12 - u1;

  s1 := (s1 - t1) - u1;
  s2 := (s2 - t2) - u2;
  s3 := (s3 - t3) - u3;
  s4 := (s4 - t4) - u4;
  s5 := (s5 - t5) - u5;
  s6 := (s6 - t6) - u6;
  s7 := (s7 - t7) - u7;
  s8 := (s8 - t8) - u8;
  s9 := (s9 - t9) - u9;
  s10 := (s10 - t10) - u10;
  s11 := (s11 - t11) - u11;
  s12 := (s12 - t12) - u12;

  s1 := (s1 - t1) - u1;
  s2 := (s2 - t2) - u1;
  s3 := (s3 - t3) - u1;
  s4 := (s4 - t4) - u1;
  s5 := (s5 - t5) - u1;
  s6 := (s6 - t6) - u1;
  s7 := (s7 - t7) - u1;
  s8 := (s8 - t8) - u1;
  s9 := (s9 - t9) - u1;
  s10 := (s10 - t10) - u1;
  s11 := (s11 - t11) - u1;
  s12 := (s12 - t12) - u1;

  s1 := s1 - (t1 - u1);
  s2 := s2 - (t2 - u2);
  s3 := s3 - (t3 - u3);
  s4 := s4 - (t4 - u4);
  s5 := s5 - (t5 - u5);
  s6 := s6 - (t6 - u6);
  s7 := s7 - (t7 - u7);
  s8 := s8 - (t8 - u8);
  s9 := s9 - (t9 - u9);
  s10 := s10 - (t10 - u10);
  s11 := s11 - (t11 - u11);
  s12 := s12 - (t12 - u12);

  s1 := s1 - ((t1 - s1) - u1);
  s2 := s2 - ((t2 - s2) - u2);
  s3 := s3 - ((t3 - s3) - u3);
  s4 := s4 - ((t4 - s4) - u4);
  s5 := s5 - ((t5 - s5) - u5);
  s6 := s6 - ((t6 - s6) - u6);
  s7 := s7 - ((t7 - s7) - u7);
  s8 := s8 - ((t8 - s8) - u8);
  s9 := s9 - ((t9 - s9) - u9);
  s10 := s10 - ((t10 - s10) - u10);
  s11 := s11 - ((t11 - s11) - u11);
  s12 := s12 - ((t12 - s12) - u12);

  s1 := s1 - (t1 - (s1 - u1));
  s2 := s2 - (t2 - (s2 - u2));
  s3 := s3 - (t3 - (s3 - u3));
  s4 := s4 - (t4 - (s4 - u4));
  s5 := s5 - (t5 - (s5 - u5));
  s6 := s6 - (t6 - (s6 - u6));
  s7 := s7 - (t7 - (s7 - u7));
  s8 := s8 - (t8 - (s8 - u8));
  s9 := s9 - (t9 - (s9 - u9));
  s10 := s10 - (t10 - (s10 - u10));
  s11 := s11 - (t11 - (s11 - u11));
  s12 := s12 - (t12 - (s12 - u12));

  s1 := s3_b1 - s4; (* null *)
  s3_b1 := s3_b1 - s1; (* nop *)
  s3_b1 := s4 - s1; (* just assign *)
  s4 := s4 - s3_b1;

  s1 := [i1];
  s1 := s1 - [i1];
  s1 := t1 - [i1];
  s1 := [i1] - s1;
  s1 := s1 - [ipos];
  s1 := [ipos] - s1;

  s11 := [i11];
  s11 := s11 - [i11];
  s11 := t11 - [i11];
  s11 := [i11] - s11;
  s11 := s11 - [ipos];
  s11 := [ipos] - s11;

  s11_b4 := s11_b4 - [i11_b4];
  s11_b4 := [i11_b4] - s11_b4;
  s11_b4 := t11_b4 - [i11_b4];
  s11_b4 := t11_b4 - [ipos];
  s11_b4 := t11_b4 - [i15];
  s11_b4 := s11_b4 - [i15];
  s11_b4 := s11_b4 - (t12 - [i15]);
  s11_b4 := (s11_b4 - [ipos]) - [i15];
  s11_b4 := s11_b4 - ((t11_b4 - [ipos]) - [i15]);

  s1 := [15];
  s1 := s1 - [7];
  s1 := t1 - [16];
  s1 := [0] - s1;
  s1 := s1 - [3];
  s1 := [16] - s1;

  s11 := [175];
  s11 := s11 - [35];
  s11 := s11 - [160];
  s11_b4 := s11_b4 - [64];
  s11_b4 := [239] - s11_b4;
  s11_b4 := t11_b4 - [105];
  s11_b4 := s11_b4 - (t12 - [220]);
  s11_b4 := (s11_b4 - [220]) - [68];
  s11_b4 := s11_b4 - ((t11_b4 - [239]) - [i15]);

  s1 := [3..i1];
  s1 := s1 - [3..8];
  s1 := t1 - [i1..8];
  s1 := [2..14] - s1;
  s1 := s1 - [i1..j1];
  s1 := [i..j] - s1;

  s11 := [155..175];
  s11 := s11 - [155..175];
  s11 := t11 - [i..j];
  s11 := t11 - [i11..j11];

  s11_b4 := s11_b4 - [i11_b4..j11_b4];
  s11_b4 := [i11_b4..j] - s11_b4;
  s11_b4 := t11_b4 - [i11_b4..j];
  s11_b4 := s11_b4 - (t12 - [i15..239]);
  s11_b4 := (s11_b4 - [ipos..220]) - [i15];
  s11_b4 := s11_b4 - ((t11_b4 - [0..ipos]) - [i15..j15]);
end.
   
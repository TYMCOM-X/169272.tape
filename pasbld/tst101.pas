program tst101;

 const
   cstr := 'abcedf';
   cch := 'C';

 type
   fs = packed array[1..10] of char;
   fsl = packed array[1..100] of char;
   xs = packed array[1..*] of char;
   vs = string[5];
   vsl = string[120];
   xvs = string[*];

 var
   ch: char;
   ifs: fs;
   ifsl: fsl;
   ivs: vs;
   ivsl: vsl;

   i,j: 0..16000;

   p: ^ record
	  a: boolean;
	  rxs: xs
	end;

 procedure inner (valxs: xs; var varxs: xs);
  begin
   ch := valxs;
   ifs := valxs;
   ivs := valxs;
   varxs := ch;
   varxs := ifs;
   varxs := ivs;
   varxs := valxs;
  end;

begin
 ch := ch;
 ch := ifs;
 ch := ifsl;
 ch := ivs;
 ch := ivsl;
 ch := p^.rxs;

 ifs := ch;
 ifs := ifs;
 ifs := ifsl;
 ifs := ivs;
 ifs := ivsl;

 ifsl := ch;
 ifsl := ifs;
 ifsl := ifsl;
 ifsl := ivs;
 ifsl := ivsl;

 ivs := ch;
 ivs := ifs;
 ivs := ifsl;
 ivs := ivs;
 ivs := ivsl;

 ivsl := ch;
 ivsl := ifs;
 ivsl := ivs;
 ivsl := ivs;
 ivsl := ivsl;

 p^.rxs := ch;
 p^.rxs := ifs;
 p^.rxs := ivs;
 p^.rxs := ivs;
 p^.rxs := ivsl;

  substr (ifs, 1, 4) := ch;
  substr (ifsl, i, 10) := ifs;
  substr (ivs, 1, j) := ifsl;
  substr (ivsl, i, j) := ivs;
  ivs := substr (ivs || ivs, i, j);

  ivs := ch || ifs || ifsl || ivs || lowercase (ivsl) || substr (ifs, 2, 7);

  new (p, 12);

  inner (ifs, ifsl);
  inner (cstr, ifs);
  inner (ch, ifsl);
  inner (ifsl, ifsl);
  inner (ivs, ifsl);
  inner (ivsl, ifsl);
  inner (substr (ivs, 3), ifsl);

  i := length (ifs);
  i := length (ivs);
end.
    
program test28 options dump;

 type
   int = 0..25;
   r = record
	 f1, f2: 0..4;
	 case b3: boolean of
	   false:( c: char;
		   case int of
		     1, 12..20: ( xyz: string );
		     others: ( s: packed array[1..4] of char ) )
       end;

  var p: ^ r;
  var v: 0..4;


begin
  new (v);
  new (p);
  new (p, true);
  new (p, false);
  new (p, true, 1);
  new (p, false, 1);
  new (p, false, 2);
  new (p, false, 20);
end.
    
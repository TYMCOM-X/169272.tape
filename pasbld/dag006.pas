program dag006;

var r: record
    case tag: integer of
      1: ( case tag1: integer of
	     1: ( case integer of
		    1: ( case tag111: integer of
			   1: ( v1111: integer )
		       )
		 )
	 );
      2: ( case tag2: integer of
	     1: ( case integer of
		    1: ( case tag211: integer of
			   1: ( v2111: integer )
		       );
		    2: ( case tag212: integer of
			   1: ( v2121: integer )
		       )
		 )
	  )
    end;

var i: integer;

begin  with r do begin
  v1111 := 2;
  v2111 := 3;
  i := v1111;
  i := v2111;
  tag1 := 1;
  i := v1111;
  i := v2111;
  tag212 := 4;
  i := v2111;
  i := tag212;
end  end.
   
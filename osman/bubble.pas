Procedure BubbleSort(Var r  : Vect; 
                   lo : Integer ;
                   upIn : Integer);  
var
       i,j,up : Integer;
       TempR : Name;
begin
  up := upIn;
  while up > lo do
    begin
      j := lo;
      for i := lo to up - 1 do
        begin
	  if r[ i ] > r [ i + 1 ] then
	    begin
	      TempR := r[ i ];
	      r[ i ] := r[ i + 1 ];
	      r[ i + 1 ] := TempR;
	      j := i;
	    end;
	end;
      up := j;
    end;
end;

  

Program HEAP;

Const ArrayDim = 3000;
      StrLength = 10;
      FileNameLength = 10;
Type
    Name = string[StrLength];
    Vect = array[1..ArrayDim] of Name;

Var i,
    lowerbound,
    upperbound : integer;
    ArrayFull : boolean;
    ListH,ListB,ListR : Vect;
    SortFileName : Packed array[1..FileNameLength] of char ; 
    InFile,
    OutFile : text;

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

Procedure HeapSort(Var r  : Vect; (* This procedure takes an array *)
                   lo,	      (* passed in 'r', and returns the array sorted *)
                   up : Integer);  
var
       i : Integer;
       TempR : Name;

Procedure SiftUp(Var r  : Vect;
                     i,
                     n  : Integer);
var
       j,TempI : Integer;
       TempR : Name;
begin (* SiftUp *)
  TempI := i;
  while 2 * TempI <= n do
    begin
      j := 2 * TempI;
      if j < n then
        if r[j] < r[j+1] then
          j := j + 1;
      if r[TempI] < r[j] then
        begin
          TempR := r[j];
          r[j] := r[TempI];
          r[TempI] := TempR;
          TempI := j;
        end (* if *)
      else
        TempI := n + 1
    end (* while *)
end; (* SiftUp *)

begin (* HeapSort *)
  (* construct heap *)
  for i := (up DIV 2) downto 2 do
    SiftUp(r,i,up);
  (* repeatedly extract maximum *)
  for i := up downto 2 do
    begin
      SiftUp(r,1,i);
      TempR := r[1];  
      r[1] := r[i];
      r[i] := TempR;    
    end; (* for *)
end; (* HeapSort *)

begin
  open(tty); Rewrite(tty);

  Write(tty,'Enter Name of file to be sorted  = ');break(tty);
  i := 1;
  readln(tty);
  while not EOLN(tty) do
    begin
      Read(tty,SortFileName[i]);
      i := i + 1;
    end; (* while not EOLN *)
  for i := i to FileNameLength do
    SortFileName[i] := ' ';

  Reset( InFile,SortFileName );
  UpperBound := 0;
  ArrayFull := false;
  While not EOF( InFile ) and not ArrayFull do (* read in file to array *)
    begin
      UpperBound := UpperBound + 1;
      ReadLN( InFile,ListH[ UpperBound ] );
      ListB[ Upperbound ] := ListH[ Upperbound ];
      if UpperBound = ArrayDim then
      begin
        writeln( tty, 'Stopped reading due to array full at ',UpperBound:2 );
	break( tty );
	ArrayFull := true;
      end;
    end;

  if UpperBound = 0 then (* file must have been empty or not existing *)
    begin
      writeln( tty, 'I could not find ',SortFileName,'.' );break( tty );
    end
  else
    begin
      writeln( tty );
      write( tty,'Heap Sort.. ' );break( tty );
      HeapSort( ListH,1,UpperBound );
          writeln( tty,'Sorted ',UpperBound:5,' items.' );break( tty );
      writeln( tty,'Done! ' );break( tty );

      write( tty,'Bubble Sort.. ' );break( tty );
      BubbleSort( ListB,1,UpperBound );
          writeln( tty,'Sorted ',UpperBound:5,' items.' );break( tty );
      writeln( tty,'Done! ' );break( tty );

      writeln( tty );
      write( tty,'Now copy the sorted array in reverse..' );break( tty );
      for i := 1 to upperbound do
        begin
	  ListR[ i ] := ListH[ upperbound + 1 - i ];
	  ListB[ i ] := ListR[ i ];
	end;
      writeln( tty,'Reversed ' );break( tty );

      writeln( tty );
      write( tty,'Heap Sort.. ' );break( tty );
      HeapSort( ListR,1,UpperBound );
          writeln( tty,'Sorted ',UpperBound:5,' items.' );break( tty );
      writeln( tty,'Done! ' );break( tty );

      write( tty,'Bubble Sort.. ' );break( tty );
      BubbleSort( ListB,1,UpperBound );
          writeln( tty,'Sorted ',UpperBound:5,' items.' );break( tty );
      writeln( tty,'Done! ' );break( tty );

      writeln( tty );
      writeln( tty,'Now sort arrays which are already sorted.' );
      writeln( tty );
      write( tty,'Heap Sort.. ' );break( tty );
      HeapSort( ListR,1,UpperBound );
          writeln( tty,'Sorted ',UpperBound:5,' items.' );break( tty );
      writeln( tty,'Done! ' );break( tty );

      write( tty,'Bubble Sort.. ' );break( tty );
      BubbleSort( ListB,1,UpperBound );
          writeln( tty,'Sorted ',UpperBound:5,' items.' );break( tty );
      writeln( tty,'Done! ' );break( tty );

      Open( OutFile );
      ReWrite( OutFile,'Sorted' );
      for i := 1 to UpperBound do (* write sorted array back out to disk *)
        begin
          WriteLn( OutFile,ListH[ i ] );
        end;
    end;
  writeln( tty,'exit' );
end.
   
program iots36;

type
  littlearray = array [1..200] of integer;

var
  f, g: text;
  starfile: file of *;
  readerin: littlearray;
  filename: string[50];
  width, i: 0..10000;

begin
  open (f, 'tty:'); rewrite (g, 'tty:');
  write (g, 'Enter star file name to check: '); break (g); readln (f);
  read (f, filename);
  if filename = '' then stop;
  open (starfile, filename, [randio]);
  seek (starfile, 201); read (starfile, readerin:1);
  writeln (g, 'First was ', readerin[1]);
  seek (starfile, cursor(starfile) + readerin [1] - 1);
    while not eof (starfile) do begin
      read (starfile, readerin);
    exit if eof (starfile);
      for i := 1 to readerin[1] do
	if readerin [i] <> (readerin[1] - i + 1) then write (g, '"');
      writeln (g, 'One.');
      for i := readerin [1] + 1 to 200 do
	if readerin [i] <> 0 then write (g, '$');
      writeln (g, 'Two.');
      read (starfile, readerin: readerin[1]);
      writeln (g, 'Number is ', readerin [1] );
      for i := 1 to readerin[1] do
	if readerin[i] <> (readerin[1] - i + 1) then write (g, '#');
      writeln (g, ' Done.')
    end;
  close
end.
 
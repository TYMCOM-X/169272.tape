program ichinit;

const
  tab = chr (11b);

var
  found: array[0..63] of boolean;
  i, j, k: integer;
  str: string;

procedure abort (message: string[*]);
begin
  rewrite (tty);
  writeln (tty,'?',message);
  break;
  scratch (output);
  stop;
end;
begin
  reset (input,'iching.txt');
  rewrite (output,'iching.inc');
  repeat 
    read (str);
    if verify (str,['0'..'1']) <> 0 then
      abort ('Illegal identifier  "' || str || '".');
    if length (str) <> 6 then
      abort ('Identifier "' || str || '" not six digits.');
    i := 0;
    for j := 1 to length (str) do
      i := i * 2 + ord (str[j]) - ord ('0');
    if found[i] then
      abort ('Duplicate entry "' || str || '".');
    found[i] := true;
    writeln ('  msg',i:1+ord(i>9),': string :=');
    readln;
    loop
      write (tab,'''');
      read (str);
      for i := 1 to length (str) do
	if str[i] = ''''
	  then write ('''''')
	  else write (str[i]);
      readln;
    exit if eoln do writeln (''';');
      writeln (''' || crlf ||');
    end;
    if not eof then readln;
  until eof;
  for i := 0 to 63 do
    if not found[i] then
      abort ('Missing entries.');
  close (output);
  rewrite (output,'ichmac.mac');
  writeln (tab,'twoseg');
  writeln (tab,'reloc',tab,'400000');
  writeln (tab,'entry',tab,'table');
  writeln ('table:');
  for i := 0 to 63 do
    writeln (tab,'exp',tab,'msg',i:1+ord(i>9),'##');
  writeln (tab,'end');
  close;
end.
    
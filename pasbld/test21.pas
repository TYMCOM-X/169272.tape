program test21 options dump;

 label 3;
 var b: boolean;

begin
  if b then return;
  repeat
    b := b;
  until b;
  while not b do begin
    b := b;
  exit if b;
    b := b;
  end;
  if b
    then b := b
    else stop;
  goto 3;
  goto 2;
end.
   
program foo;
i,j:integer;
begin
rewrite(TTY);
i:=1; j:=2;
WRITELN(TTY,i,j);
i:=i+1; j:=j*2;
WRITELN(TTY,i,j);
end
.
    
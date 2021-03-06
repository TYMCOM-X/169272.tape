program erastosthenes;

$INCLUDE corout.inc

var n: integer;
    sieve: environment;

procedure sieve_proc;
var prime: integer;
    sieve: environment;
begin
  detach;
  prime := n;
  write (tty, prime:8);
  sieve := create (sieve_proc, 50);
  loop
    detach;
    if n mod prime <> 0 then call (sieve);
  end;
end;

begin
  rewrite (tty);
  sieve := create (sieve_proc, 50);
  n := 2;
  loop
    call (sieve);
    n := n + 1;
  end;
end.
 
program test;

var i, j, k: integer;

function f (a: integer): integer
	    options nodump (ifm,dags,shape,optshape);

begin
  f := a + i
end;

function g (a: integer): integer
	    options nodump (ifm,dags,shape,optshape);

begin
  k := a;
  g := f(a);
end;

begin
  i := 1;
  j := 2;
  k := 3;
  j := f(i+k);
  k := g(i+j);
  j := -1;
  k := -2;
  i := f(i+j) + g(j+k) + 2*f(i+j) - 2*f(j+k);
end.
  
program test17 options dump;

var r: packed record
	f1, f2: char;
	b: boolean;
	c: 0..4
       end;
var a: boolean;

begin
  with a, r do begin
    f1 := f2;
    c := 2;
  end;
end.
   
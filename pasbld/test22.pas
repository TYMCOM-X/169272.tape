program test22 options dump;

var f: text;
var b: boolean;
var i: 0..1000;
var c: char;
var s: string;

begin;
  writeln;
  writeln (tty);
  writeln (f);
  write (b, b:4, b:4:3);
  write (tty, i, i:4, i:4:0, i:4:o);
  write (f, c:12, s:12);
  write;
end.
   
program iotst1;

var
 f,g,h: text;
 i: 0..100;

begin
  i := 2;
  open (f, substr ( ' FOO.TMP', i ) );
  rewrite (g, substr ( ' FOO2.TMP', i));
  open (tty, substr (' TTY:', i) );
  rewrite (ttyoutput, substr (' TTY:', i) );
  open (h, substr (' TTY:', i) );
  close (h);
  scratch (g);
  rewrite (h, substr (' FOO2.TMP', i) );
  close
end.
 
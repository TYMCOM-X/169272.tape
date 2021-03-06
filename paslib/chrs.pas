PROGRAM chrs;
(*echo characters to terminal*)

VAR
chr_lst: ARRAY[1 .. 80] OF INTEGER;
num_chrs: INTEGER;

PROCEDURE get_chr_lst;
BEGIN (*read a list of characters -- by number*)
  WRITELN;
  WRITE('Enter a list of character numbers: ');
  BREAK;
  READLN;
  num_chrs := 0;
  WHILE NOT EOLN DO BEGIN
    num_chrs := num_chrs + 1;
    READ(chr_lst[num_chrs])
  END;
  WRITELN('List of ', num_chrs: 0, ' characters accepted.');
  BREAK
END;

PROCEDURE put_chr_lst;
VAR i: INTEGER;
BEGIN (*write a list of characters*)
  WRITE('{');
  BREAK;
  FOR i := 1 TO num_chrs DO WRITE(CHR(chr_lst[i] MOD ORD(MAXIMUM(CHAR))));
  WRITELN('}');
  BREAK
END;

BEGIN
  OPEN(TTY);
  INPUT := TTY;
  REWRITE(TTYOUTPUT);
  OUTPUT := TTYOUTPUT;
  WRITELN('CHRS -- a program to echo characters');
  BREAK;
  REPEAT
    get_chr_lst;
    put_chr_lst
  UNTIL num_chrs = 0
END.
    
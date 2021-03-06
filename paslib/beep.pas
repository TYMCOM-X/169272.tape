PROGRAM beep;
  (*this program beeps the terminal*)

PROCEDURE pause(pause_time: INTEGER);
(*pause for specified number of milliseconds*)
VAR start_time: INTEGER;
BEGIN
  start_time := TIME();
  REPEAT (*do nothing*) UNTIL (TIME() - start_time) >= pause_time
END;

PROCEDURE prepare_tty;
(*prepare tty for input and output*)
BEGIN
  OPEN(TTY); (*ready for input*)
  REWRITE(TTY) (*ready for output*)
END;

PROCEDURE beep_tty;
(*make the tty beep*)
BEGIN
  WRITE(TTY, CHR(7)); (*send beep character #7*)
  BREAK(TTY) (*wait until beep character sent*)
END;

BEGIN
  prepare_tty;
  WRITELN(TTY, 'BEEP, Version 1.0');
  WRITELN(TTY, 'Use control-C to make it stop beeping!');
  BREAK(TTY); pause(5000);
  LOOP
    beep_tty; pause(300);
    beep_tty; pause(300);
    beep_tty; pause(300);
    beep_tty; pause(1000);
    beep_tty; pause(500);
    beep_tty; pause(4000)
  END
END.
 
PROGRAM foo;

VAR
user: ARRAY[1 .. 500] OF RECORD
  name: STRING[40]; systems, programs: INTEGER
END;
system: ARRAY[1 .. 30] OF RECORD
  name: STRING[40]; users, programs: INTEGER
END;
line: STRING[80];
current_system: INTEGER;
current_user: INTEGER;
numusers: INTEGER := 0;
numsystems: INTEGER := 0;
numprograms: INTEGER := 0;

PROCEDURE system_users;
VAR top_ten: ARRAY[1 .. 10] OF INTEGER; i, j, x, y, q: INTEGER;
BEGIN
  FOR i := 1 TO 10 DO top_ten[i] := 1; q := 0;
  FOR i := 1 TO numsystems DO BEGIN
    x := i; q := q + system[i].users;
    FOR j := 1 TO 10 DO BEGIN
      IF system[x].users > system[top_ten[j]].users THEN BEGIN
        y := top_ten[j]; top_ten[j] := x; x := y
      END
    END
  END;
  WRITELN;
  WRITELN('Average Number of Users / System = ', q / numsystems: 0:0);
  WRITELN('Top Ten Systems (Number of Users):');
  FOR i := 1 TO 10 DO WITH system[top_ten[i]] DO
    WRITELN('  ', name, ': ', users: 0)
END;

PROCEDURE system_programs;
VAR top_ten: ARRAY[1 .. 10] OF INTEGER; i, j, x, y, q: INTEGER;
BEGIN
  FOR i := 1 TO 10 DO top_ten[i] := 1; q := 0;
  FOR i := 1 TO numsystems DO BEGIN
    x := i; q := q + system[i].programs;
    FOR j := 1 TO 10 DO BEGIN
      IF system[x].programs > system[top_ten[j]].programs THEN BEGIN
        y := top_ten[j]; top_ten[j] := x; x := y
      END
    END
  END;
  WRITELN;
  WRITELN('Average Number of Programs / System = ', q / numsystems: 0:0);
  WRITELN('Top Ten Systems (Number of Programs):');
  FOR i := 1 TO 10 DO WITH system[top_ten[i]] DO
    WRITELN('  ', name, ': ', programs: 0)
END;

PROCEDURE user_systems;
VAR top_ten: ARRAY[1 .. 10] OF INTEGER; i, j, x, y, q: INTEGER;
BEGIN
  FOR i := 1 TO 10 DO top_ten[i] := 1; q := 0;
  FOR i := 1 TO numusers DO BEGIN
    x := i; q := q + user[i].systems;
    FOR j := 1 TO 10 DO BEGIN
      IF user[x].systems > user[top_ten[j]].systems THEN BEGIN
        y := top_ten[j]; top_ten[j] := x; x := y
      END
    END
  END;
  WRITELN;
  WRITELN('Average Number of Systems / User = ', q / numusers: 0:0);
  WRITELN('Top Ten Users (Number of Systems):');
  FOR i := 1 TO 10 DO WITH user[top_ten[i]] DO
    WRITELN('  ', name, ': ', systems: 0)
END;

PROCEDURE user_programs;
VAR top_ten: ARRAY[1 .. 20] OF INTEGER; i, j, x, y, q: INTEGER;
BEGIN
  FOR i := 1 TO 20 DO top_ten[i] := 1; q := 0;
  FOR i := 1 TO numusers DO BEGIN
    x := i; q := q + user[i].programs;
    FOR j := 1 TO 20 DO BEGIN
      IF user[x].programs > user[top_ten[j]].programs THEN BEGIN
        y := top_ten[j]; top_ten[j] := x; x := y
      END
    END
  END;
  WRITELN;
  WRITELN('Average Number of Programs / User = ', q / numusers: 0:0);
  WRITELN('Top Ten Users (Number of Programs):');
  FOR i := 1 TO 20 DO WITH user[top_ten[i]] DO
    WRITELN('  ', name, ': ', programs: 0)
END;

PROCEDURE count_system(name: STRING[*]);
VAR i: INTEGER;
BEGIN
  current_system := 0;
  FOR i := 1 TO numsystems DO
    IF system[i].name = name THEN current_system := i;
  IF current_system = 0 THEN BEGIN
    numsystems := numsystems + 1; current_system := numsystems;
    WITH system[current_system] DO BEGIN users := 0; programs := 0 END;
    WRITELN(TTYOUTPUT, 'SYSTEM: ', name); BREAK(TTYOUTPUT)
  END;
  system[current_system].name := name
END;

PROCEDURE count_user(name: STRING[*]);
VAR i: INTEGER;
BEGIN
  current_user := 0;
  FOR i := 1 TO numusers DO IF user[i].name = name THEN current_user := i;
  IF current_user = 0 THEN BEGIN
    numusers := numusers + 1; current_user := numusers;
    WITH user[current_user] DO BEGIN systems := 0; programs := 0 END;
    WRITELN(TTYOUTPUT, 'USER: ', name); BREAK(TTYOUTPUT)
  END;
  user[current_user].name := name;
  WITH system[current_system] DO users := users + 1;
  WITH user[current_user] DO systems := systems + 1
END;

PROCEDURE count_program(name: STRING[*]);
BEGIN
  numprograms := numprograms + 1;
  WITH user[current_user] DO programs := programs + 1;
  WITH system[current_system] DO programs := programs + 1
END;

BEGIN
  REWRITE(TTYOUTPUT);
  RESET(INPUT, 'PASCAL.DIR');
  WHILE NOT EOF DO BEGIN
    READLN(line);
    IF line[1] = ':' THEN count_system(SUBSTR(line, 2))
    ELSE IF line[1] = '(' THEN count_user(SUBSTR(line, 2))
    ELSE count_program(line)
  END;
  CLOSE(INPUT);
  REWRITE(OUTPUT, 'PASUSE.TXT');
  WRITELN('Total Systems = ', numsystems: 0);
  WRITELN('Total Users = ', numusers: 0);
  WRITELN('Total Programs = ', numprograms: 0);
  system_users;
  system_programs;
  user_systems;
  user_programs;
  CLOSE(OUTPUT)
END.
 
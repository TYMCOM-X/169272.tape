  program dtmpfl;

$include infpac.inc

	var	jb_rcd: jobrec;
		jb_numb: integer;
		sng: packed array[1..10] of char;
		cmd_flnm,tmp_flnm: file_name;
		cmd_fl,tmp_fl: text;
		tmpnm: packed array[1..3] of char;
		ln_sng: string[256];

    begin
      jobinfo(jb_rcd);
      jb_numb:=jb_rcd.jobnum;
      putstring(sng,jb_numb:10);
      if sng[9]=' ' then sng[9]:='0';
      if sng[8]=' ' then sng[8]:='0';
        open(tty); 
	rewrite(tty); write(tty,' command file name : '); break(tty);
	readln(tty); read(tty,cmd_flnm);
	  write(tty,' temp file name (only 3 letters) : '); break(tty);
	  readln(tty); read(tty,tmpnm);
        tmp_flnm:=substr(sng,8,3)||tmpnm||'.tmp';
      open(cmd_fl,cmd_flnm); readln(cmd_fl);
	rewrite(tmp_fl,tmp_flnm);
      while not eof(cmd_fl) do
	begin
	  readln(cmd_fl,ln_sng);
	  writeln(tmp_fl,ln_sng)
	end;
      close
    end.
   
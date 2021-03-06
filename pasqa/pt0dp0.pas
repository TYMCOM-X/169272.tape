  program dprtst options special(word);

	type	mchwrdar_type=array[1..*] of machine_word;
		ptr_type= ^mchwrdar_type;

	var	data_len,res_len,i,stp: integer;
		ptr1,ptr2: ptr_type;
		inptxt,outtxt: text;
		inp_flnm,out_flnm: file_name;
		
	external procedure dp_int(datap,resp: ptr_type);

    begin open(tty); rewrite(tty); writeln(tty);
	write(tty,' give an input file name : '); break(tty);
	readln(tty); read(tty,inp_flnm);  writeln(tty);
	write(tty,' give an output file name : '); break(tty);
	readln(tty); read(tty,out_flnm);
      open(inptxt,inp_flnm); readln(inptxt);
	readln(inptxt,data_len,res_len);
      rewrite(outtxt,out_flnm); writeln(outtxt);
	writeln(outtxt,' data_len =',data_len:3,
		'     res_len =',res_len:3); writeln(outtxt);
	new(ptr1,data_len); new(ptr2,res_len); stp:=0; readln(inptxt);
      while not eof(inptxt) do
	begin stp:=stp+1;
	  for i:=1 to data_len do read(inptxt,ptr1^[i]:14:o);
	    writeln(outtxt); writeln(outtxt,' step =',stp:3);
	    write(outtxt,' data  :');
	    for i:=1 to data_len do write(outtxt,'  ',ptr1^[i]:12:o);
	    writeln(outtxt);
	  dp_int(ptr1,ptr2);
	    write(outtxt,' result:');
	    for i:=1 to res_len	do write(outtxt,'  ',ptr2^[i]:12:o);
	    writeln(outtxt); readln(inptxt) 
	end; writeln(outtxt); writeln(outtxt,' finish'); close
    end.
 
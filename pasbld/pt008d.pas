  module pt008d options special(word);

    public procedure bin_fl_ops(var bin_arp: mchwrd_ar_type;
				flnmp: file_name; var fl_txt: text);

	var	fl: file of *;
		i: integer;
		ar_vr: array[1..3] of machine_word;

      begin rewrite(fl,flnmp); i:=2;
	repeat write(fl,bin_arp[i]:2);
	       i:=i+4
	  until i>mchwrd_ar_len;  close(fl);
	writeln(fl_txt); writeln(fl_txt,' binary file contents');
	writeln(fl_txt);
	reset(fl,flnmp); read(fl,ar_vr);
	for i:=1 to 3 do write(fl_txt,'  ',ar_vr[i]:12:o);
	  writeln(fl_txt); writeln(fl_txt); close(fl);
	update(fl,flnmp); readrn(fl,11,ar_vr);
	for i:=1 to 3 do write(fl_txt,'  ',ar_vr[i]:12:o);
	  writeln(fl_txt); writeln(fl_txt); close(fl) 
      end.

 
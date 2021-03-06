  module pt001a options special(word);

  public procedure mem_bin_repr(wrd_num: integer; var memp: mem_ar_tp);

	type 	bin_wrd_tp = record case boolean of
				true: (wrd_vr: machine_word);
				false: (ar_vr: packed array
					[1..mch_wrd_len] of boolean)
			     end;

	var	bin_vr: bin_wrd_tp;
		i,j: integer;

    begin writeln(output); writeln(output); 
      	write(output,'               ');
      writeln(output,'Binary representation of the memory');
	writeln(output);
      for i:=1 to wrd_num do
	begin write(output,i:5,'.          '); bin_vr.wrd_vr:=memp[i];
	  for j:=1 to mch_wrd_len do
	    if bin_vr.ar_vr[j] then write(output,'1')
	      else write(output,'0');
	  writeln(output)
	end; break(output)
    end;

  public procedure mem_oct_repr(wrd_num: integer; var memp: mem_ar_tp);

	var	i,j: integer;

    begin writeln(output); writeln(output); 
	write(output,'               ');
      writeln(output,'Octal representation of the memory');
	writeln(output);  j:=0;
      for i:=1 to wrd_num do
	begin j:=j+1; write(output,i:6,'.   ',memp[i]:oct_dgt_num:o);
	  if j=oct_wrds_ln then
	    begin writeln(output); writeln(output); j:=0 end
	end; writeln(output); writeln(output)
    end;

  public procedure mem_chr_repr(wrd_num: integer; var memp: mem_ar_tp);

	type	chr_wrd_tp = record case boolean of
				true: (wrd_vr: machine_word);
				false: (ar_vr: packed array[1..chr_num]
							of char)
			     end;

	var	chr_wrd_vr: chr_wrd_tp;
		i,j,k: integer;

   begin writeln(output); writeln(output); 
	write(output,'               ');
      writeln(output,'ASCII representation of the memory');
	writeln(output); j:=0;
      with chr_wrd_vr do
	for i:=1 to wrd_num do
	  begin j:=j+1;
	    wrd_vr:=memp[i];
		for k:=1 to 5 do
	  if (ar_vr[k] < ' ') or (ar_vr[k] > 'z') then ar_vr[k]:='{';
	    write(output,ar_vr);
	    if j=chr_wrds_ln then
	      begin writeln(output); writeln(output); j:=0 end
	  end; writeln(output); writeln(output)
    end.
   
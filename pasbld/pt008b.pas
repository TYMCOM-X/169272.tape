  module pt008b options special(coercions);

	external var	rcd_vr: main_rcd;
			check_excps_vr: check_excps_tp;

    public procedure rd_typed(rcd_num,rcd_qnt: integer;
		       var fl_rcd: file of rcd_type; var fl_txt: text);

		var	ptr_mem: ptr_mchwrd_ar_type;
			bln_vr: boolean;

	procedure out_rcd(var rcdp: rcd_type);
		var	chrt: char;
			sng: sng_type;
			sng_vr: string[20];
			ind_vr: ind_type;
			sub_vr: subsclr_type;

	  begin writeln(fl_txt);
	    with rcdp do
	      begin case numb of
		      zero: write(fl_txt,'   zero        ');
		       one: write(fl_txt,'    one        ');
		       two: write(fl_txt,'    two        ');
		     three: write(fl_txt,'  three        ');
		      four: write(fl_txt,'   four        ');
		      five: write(fl_txt,'   five        ');
		    end; write(fl_txt,wrd,'     '); sng:='';
		for chrt:=minimum(char) to maximum(char) do
		  if chrt in lngst then sng:=sng||chrt;
		writeln(fl_txt,sng,'     ');
		writeln(fl_txt,srlnum:0:6:e,'     ',rlnum:0:13:e);
		with subrcd do
		  begin sng:='';
		    for ind_vr:=blue to brown do
		      for sub_vr:=one to four do
			if sub_vr in stindar[ind_vr] then
			  begin
                            putstring(sng_vr,intar[ind_vr,sub_vr]:5);
			    sng:=sng||sng_vr
			  end else sng:=sng||'.'
		  end
	      end; writeln(fl_txt,sng); writeln(fl_txt); break(fl_txt)
	  end;

      begin excmes_print(' RD_TYPED entered');
       if check_excps_vr=mmrs then
	begin close(fl_rcd);
	  ptr_mem:=ptr_mchwrd_ar_type(377770b);
	  pr_mem(ptr_mem,32,2,true,' called from RD_TYPED')
	end;
	if rcd_qnt=1 then begin seek(fl_rcd,rcd_num); bln_vr:=false end 
	    else begin readrn(fl_rcd,rcd_num,rcd_vr.elmt);
		       out_rcd(rcd_vr.elmt); bln_vr:=true  
		 end;
	    out_rcd(fl_rcd^);
	ptr_mem:=ptr_mchwrd_ar_type(address(fl_rcd^));
	pr_mem(ptr_mem,32,2+rcd_qnt,bln_vr,' called from RD_TYPED');
	  excmes_print(' RD_TYPED - exit')
      end.

    
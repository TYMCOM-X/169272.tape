  program pt0010;

	var	 i,j: integer;
		 out_flnm: file_name;

    begin

$include pt0out.inc
      rewrite(output,out_flnm);

      rewrite(rcd_file,rcd_fl_name);

      with rcd do
	begin mem_prnt:=mem_bin_repr; tag_fld:=record_1;
	  with rcd_1 do
	    begin sbrg_vr:=111; sclr_vr:=three; int_vr:=127;
	      with srcd1_vr do
	        begin sclr:=five; st:=[three..five]; sng:='abc';
	          for i:=1 to 3 do
		    for j:=1 to 4 do ar[i,j]:=100+4*(i-1)+j-1;
	        end
	    end;
	  write(rcd_file,rcd);

	      mem_prnt:=mem_oct_repr; tag_fld:=record_2;
	  with rcd_2 do
	    begin sbrg_vr:=100; sng_vr:='ijk';
              for i:=1 to 3 do
	        for j:=1 to 4 do ar_vr[i,j]:=103;
	      with srcd2_vr do
	        begin sclr:=two; sbrg:=115; sng:='xyz'; 
		  int:=63; st:=[two..six]
	        end
	    end;
	  write(rcd_file,rcd);

	      mem_prnt:=mem_chr_repr; tag_fld:=record_3;
	  with rcd_3 do begin
	    sng3:='def'; sng2:='abxy'; sng1:=sng3||sng2||sng3
			end;
	  write(rcd_file,rcd)

	end;   close(rcd_file);

      rd_rcd_file
    end.
   
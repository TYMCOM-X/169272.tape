  module pt007i;

	external var	outtxm: text;
			blar_pr_mem: blar_pr_mem_type;

    public procedure pr_mem(var ptrp: ptr_mchwrd_ar_type; 
                     wrdnum,blindp: integer; mesgp: string[35]);
	var	i,j,addr_vr: integer;
      begin
	if blar_pr_mem[blindp] then
	  begin rewrite(outtxm,out_txm_flnm_cst,[preserve]);
	    writeln(outtxm); 
	    write(outtxm,' this is PR_MEM procedure');
	    writeln(outtxm,mesgp);
	    if ptrp=nil then
	      begin print(' ill memory address in PR_MEM'); 
		jump_error
	      end; j:=1; writeln(outtxm);
	    for i:=1 to wrdnum do
	      begin write(outtxm,'  ',ptrp^[i]:12:o);
		if j=5 then begin writeln(outtxm); j:=1 end
		 else j:=j+1
	      end; writeln(outtxm); writeln(outtxm,' ***'); 
		close(outtxm); blar_pr_mem[blindp]:=false
          end
      end.

    
  module pt008i;

	external var	outtxm: text;
			blar_pr_mem: blar_pr_mem_type;

	external exception excp_user;

    public procedure pr_mem(var ptrp: ptr_mchwrd_ar_type; 
                     wrdnum,blindp: integer; blnp: boolean; 
			mesgp: string[35]);
	var	i,j,addr_vr: integer;
      begin excmes_print(' PR_MEM entered');
	if blar_pr_mem[blindp] then
	  begin rewrite(outtxm,out_txm_flnm_cst,[preserve]);
	    writeln(outtxm); 
	    write(outtxm,' this is PR_MEM procedure');
	    writeln(outtxm,mesgp);
	           j:=1; writeln(outtxm);
	    for i:=1 to wrdnum do
	      begin write(outtxm,'  ',ptrp^[i]:12:o);
		if j=5 then begin writeln(outtxm); j:=1 end
		 else j:=j+1
	      end; writeln(outtxm); writeln(outtxm,' ***'); 
		close(outtxm); blar_pr_mem[blindp]:=false;
	    if blnp then signal(excp_user)
          end;
	    excmes_print(' PR_MEM - exit');
	exception
	  others: 
	    begin excmes_print(' PR_MEM - OTHERS signalled');
	      signal()
	    end
      end.

    
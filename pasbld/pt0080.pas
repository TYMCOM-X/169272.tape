  program pt0080;

	label	1;

	public 	const	max_pr_mem: integer = mem_cst;
			mchwrd_ar_len: integer = len_cst;
			out_txm_flnm_cst: file_name = 'outtxm.tmp';

	        const	blar_pr_mem_ct: blar_pr_mem_type = 
						(true,true,true,true);

	public  var	blar_pr_mem: blar_pr_mem_type;
			ptr1,ptr2: ptr_main_rcd_type;
			rcd_vr: main_rcd;
			outtx,outtxm: text;
			check_excps_vr: check_excps_tp;
	
	public exception excp_user;

	var	mem_ptr: ptr_mchwrd_ar_type;
	tp_flnm,inptx_flnm,outtx_flnm,out_flnm,bn_flnm: file_name;
		sng_vr: sng_type;

    public procedure jump_error;
	      begin goto 1 end;

    begin open(tty); rewrite(tty); blar_pr_mem:=blar_pr_mem_ct;
	      tp_flnm:='typed.tmp'; bn_flnm:='binary.tmp';
	  check_excps_vr:=vals;
	writeln(tty); write(tty,' give input file name: '); break(tty);
	readln(tty); read(tty,inptx_flnm);    writeln(tty); 
	  write(tty,' give output file name for data: '); break(tty);
	readln(tty); read(tty,outtx_flnm);
      rewrite(outtx,outtx_flnm);    writeln(tty);
  write(tty,' give output file name for exc. messages: '); break(tty);
	readln(tty); read(tty,out_flnm);
      rewrite(output,out_flnm);    
      rd_inp(inptx_flnm); print(' *** input file is read');
	begin
      loop begin
          tp_fl_ops(tp_flnm); 
	exception
	  program_error:
	    case programstatus of
	      program_value: 
		excmes_print(' MAIN - PROGRAM_VALUE signalled');
	      program_pointer:
		begin 
		  excmes_print(' MAIN - PROGRAM_POINTERS signalled');
		  check_excps_vr:=ptrs
		end;
	      others: 
		begin 
		  excmes_print(' MAIN - Unexpected PROGRAM_ERROR');
		  exception_message; signal()
		end
	    end;
	  special_error:
	    case specialstatus of
	      special_disp_ptr:
		begin 
		  excmes_print(' MAIN - SPECIAL_DISP_PTR signalled');
		  check_excps_vr:=mmrs 
		end;
	      special_ill_mem_ref:
		begin 
		  excmes_print(' MAIN - SPECIAL_ILL_MEM_REF signalled');
		  check_excps_vr:=usrs; close(outtxm)
		end;
	      others: 
		begin excmes_print(' MAIN - Unexpected SPECIAL_ERROR');
		  exception_message; signal()
		end
	    end;
	  others: begin excmes_print(' MAIN - first OTHERS signalled');
		    signal()
		  end
      end end;
	  exception
	    excp_user: 
		excmes_print(' MAIN - first EXCP_USER signalled')
	end; close(outtx);
      begin
	new(mem_ptr); mem_ptr^:=rcd_vr.main_ar;
	  pr_mem(mem_ptr,32,1,true,' called to type memory for RCD_VR');
	exception
	  excp_user: excmes_print(' MAIN - second EXCP_USER signalled');
	  others: 
	    begin 
	     excmes_print(' MAIN - Unexpected second OTHERS signalled');
	      exception_message; signal()
	    end
      end;
      rewrite(outtx,outtx_flnm,[preserve]);
      bin_fl_ops(rcd_vr.main_ar,bn_flnm,outtx);
	print(' *** data from the OUTTXM file:'); writeln(outtx);
	  open(outtxm,out_txm_flnm_cst); readln(outtxm);
	while not eof(outtxm) do
	  begin readln(outtxm,sng_vr); writeln(outtx,sng_vr) end;
    1: print(' *** finish ***'); close;
      exception
	allconditions: 
	  begin excmes_print(' Unexpected ALLCONDITIONS signalled');
	    exception_message; close
	  end
    end.

    
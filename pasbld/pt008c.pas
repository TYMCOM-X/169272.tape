  module pt008c;

	external var	ptr1,ptr2: ptr_main_rcd_type;
			outtx: text;
			check_excps_vr: check_excps_tp;

    external procedure rd_typed( integer; integer;
		                var file of rcd_type; var text);

    public procedure tp_fl_ops(flnmp: file_name);

	var	fl: file of rcd_type;

      begin excmes_print(' TP_FL_OPS entered');
	case check_excps_vr of
	  vals:
	    begin rewrite(fl,flnmp,[preserve]); ptr2:=ptr1;
	      loop if (ptr1^.elmt.numb>two) and (ptr1^.elmt.numb<five)
		     then p_rcd_type('ptr1^.elmt',ptr1^.elmt);
		fl^:=ptr1^.elmt; put(fl);
	        ptr1:=ptr2^.ptr; dispose(ptr2); ptr2:=ptr1
	      end; close(fl) 
	    end;
	  ptrs: dispose(ptr1);
     mmrs,usrs: begin update(fl,flnmp);
		  rd_typed(2,1,fl,outtx);
		  rd_typed(4,2,fl,outtx);
		  close(fl)
	        end 
	end;
	  excmes_print(' TP_FL_OPS - exit');
	exception
	  program_error:
	    begin if programstatus=program_value then
	      begin 
		excmes_print(' TP_FL_OPS - PROGRAM_VALUE signalled');
		  fl^:=ptr1^.elmt; put(fl);
		ptr1:=ptr2^.ptr; dispose(ptr2); ptr2:=ptr1
	      end else 
		excmes_print(' TP_FL_OPS - PROGRAM_ERROR signalled');
	      close(fl); signal()
	    end;
	  others: begin excmes_print(' TP_FL_OPS - OTHERS signalled');
		    signal()
		  end
      end.
  
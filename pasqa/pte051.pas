  program pte020;

	const	int1_cst=8;
		int2_cst=12;
		int3_cst=9;
		rl1_cst=481.035;
		rl2_cst=893.12;

	var	subint: -20..20;
		int,int1,int2,int3: integer;
		rl,rl1,rl2: -1..2.0**120 prec 7;
		math_vr: math_status;

    procedure print(numb: integer; mesgp: string[50]);
	begin writeln(tty);
	  writeln(tty,' point =',numb:3,'     ',mesgp);
	  break(tty)
	end;

    begin open(tty); rewrite(tty); writeln(tty);
	math_vr:=math_flt_und;
	int1:=int1_cst; int2:=int2_cst; rl1:=rl1_cst; rl2:=rl2_cst;
	int3:=int3_cst;
      loop begin
	case math_vr of
	  math_flt_und: begin print(1,' MATH_FLT_UND');
			  break(tty); subint:=0; rl2:=rl2**9;
			  writeln(tty,' 1 - rl2 = ',rl2); break(tty);
			  rl:=rl1**(-int1); 
			  writeln(tty,' 1 - rl = ',rl); break(tty);
			  rl:=rl/rl2;
			  writeln(tty,' 1 - rl = ',rl); break(tty)
			end;
	  math_flt_ovf: begin print(2,' MATH_FLT_OVF');
			  rl1:=rl1**int1; 
			  writeln(tty,' 2 - rl1 = ',rl1); break(tty);
			  rl:=rl1*rl2;
			  writeln(tty,' 2 - rl = ',rl); break(tty)
			end;
	  math_int_ovf: begin print(3,' MATH_INT_OVF');
			  break(tty); int:=int1**int2;
			  writeln(tty,' 3 - int = ',int); break(tty)
			end;
	  math_zero_divide: begin print(4,' MATH_ZERO_DIVIDE');
				rl:=int1/subint 
			    end;
	  math_arg_arcsin: begin print(5,' MATH_ARG_ARCSIN');
				rl:=arcsin(int1) 
			   end;
	  math_arg_arccos: begin print(6,' MATH_ARG_ARCCOS');
				rl:=arccos(int1)
			   end
	end;
	exception
	  math_error:
	    case mathstatus of
	      math_flt_und: 
		begin print(12,' MATH_FLT_UND signalled');
		  math_vr:=math_flt_ovf
		end;
	      math_flt_ovf:
		begin print(13,' MATH_FLT_OVF signalled');
		  math_vr:=math_int_ovf
		end;
	      math_int_ovf:
		begin print(14,' MATH_INT_OVF signalled');
		  math_vr:=math_zero_divide
		end;
	      math_zero_divide:
		begin print(15,' MATH_ZERO_DIVIDE signalled');
		  math_vr:=math_arg_arcsin
		end;
	      math_arg_arcsin:
		begin print(16,' MATH_ARG_ARCSIN signalled');
		  math_vr:=math_arg_arccos
		end;
	      others: begin print(17,' MATH_ERROR signalled');
			exception_message;
			signal()
		      end
	    end;
	  others: begin print(18,' OTHERS signalled'); 
		    exception_message; signal()
		  end
      end end;
      exception
	math_error:
	  if mathstatus=math_arg_arccos then
	    print(20,' MATH_ARG_ARCCOS signalled') 
	  else begin print(21,' MATH_ERROR signalled');
		 exception_message; close
	       end;
	allconditions: begin print(22,' ALLCONDITIONS signalled');
			 exception_message; close
		       end
    end.
  
  program pt0130;

	label 1;

	const	ssrl_cst1=-2e3;
		ssrl_cst2=2e3;

	type	io_try=(try_subint,try_int,try_srl,try_ssrl,
			try_intfor,try_rlfor,try_sng,try_sngfor,
			try_getstr_int,try_getstr_rl1,try_getstr_rl2,
			try_putstr);
		ssrl_type=-2e3..2e3 prec 5;
		drl_type=-1e100..1e100 prec 13;

	var	subint: -20..20;
		int,int1,int2,cnt: integer;
		srl,srl1: real;
		ssrl: ssrl_type;
		sng: string[70];
		io_vr: io_try;
		io_er: io_status;
		bl_vr: boolean;
		inp_flnm,out_flnm: file_name;
	
	exception finish;

    procedure print(point: integer; mesg: string[256]);
      begin writeln(output);
	writeln(output,' ',point:2,'     ',mesg); break(output)
      end;

    procedure int_print(point,intp: integer);
      begin writeln(output);
	writeln(output,' ',point:2,'     int = ',intp); break(output)
      end;

    procedure ssrl_print(point: integer; ssrlp: ssrl_type);
      begin writeln(output);
	writeln(output,' ',point:2,'     ssrl = ',ssrlp:11:4:e); 
	break(output)
      end;

    procedure srl_print(point: integer; srlp: real);
      begin writeln(output);
	writeln(output,' ',point:2,'     srl = ',srlp:20:12:e); 
	break(output)
      end;

$include ptiost.inc

    begin open(tty); rewrite(tty); writeln(tty);
      write(tty,' give an input file name : '); break(tty);
	readln(tty); read(tty,inp_flnm); writeln(tty);
      write(tty,' give an output file name : '); break(tty);
	readln(tty); read(tty,out_flnm); 
	  rewrite(output,out_flnm);
      reset(input,inp_flnm); io_vr:=try_subint; cnt:=0;
	ssrl_print(91,minimum(ssrl_type));
	ssrl_print(91,maximum(ssrl_type));
	srl_print(92,minimum(real));
	srl_print(92,maximum(real));

      loop begin 
	case io_vr of
	  
	  try_subint:
	    begin read(input,subint);
	      io_er:=iostatus(input); iosts_print(1,io_er);
		int_print(1,subint);
	      if io_er=io_novf then
		if cnt=1 then begin io_vr:=try_int; cnt:=0 end
		  else cnt:=1
	    end;

	  try_int:
	    begin read(input,int);
	      io_er:=iostatus(input); iosts_print(2,io_er);
		int_print(2,int);
	      if io_er=io_novf then
		if cnt=1 then io_vr:=try_srl
		  else cnt:=1
	    end;

	  try_srl:
	    begin read(input,srl);
	      io_er:=iostatus(input); iosts_print(3,io_er);
		srl_print(3,srl);
	      if io_er=io_novf then io_vr:=try_ssrl
	    end;

	  try_ssrl:
	    begin read(input,ssrl);
	      io_er:=iostatus(input); iosts_print(4,io_er);
		ssrl_print(4,ssrl);
	      if io_er=io_novf then
		       begin close(input); open(input,inp_flnm);
			 io_vr:=try_intfor; cnt:=0; int1:=0; 
			 bl_vr:=true
		       end
	    end;

	  try_intfor:
	    begin
	     1: if bl_vr then begin read(input,int:4); bl_vr:=false end
		  else begin read(input,int:12); bl_vr:=true end;
		io_er:=iostatus(input); iosts_print(6,io_er);
		int_print(6,int); int_print(7,int1); int_print(8,cnt);
		  if (io_er=io_novf) and (int=0) then
		    begin io_vr:=try_rlfor; cnt:=0 end;
		  if int=int1 then
		    if cnt>=1 then
		      begin cnt:=0; int1:=0; readln(input); goto 1 end
		    else cnt:=cnt+1
		  else begin cnt:=0; int1:=int end
	    end;

	  try_rlfor:
	    begin read(input,srl:12);
	      io_er:=iostatus(input); iosts_print(9,io_er);
		srl_print(9,srl); cnt:=cnt+1;
		  if (cnt>=10) andif eoln(input) then
		    begin int:=0; int1:=0; int2:=0;
		      close(input); open(input,inp_flnm); io_vr:=try_sng
		    end
	    end;

	  try_sng:
	    begin sng:=''; read(input,sng);
	      io_er:=iostatus(input); iosts_print(10,io_er);
		if sng='' then
			begin print(10,'SNG is empty');
			  readln(input); read(input,sng)
			end;
		print(10,sng);
		writeln(output); 
		writeln(output,' string length = ',length(sng):2);
		break(output);
	      io_vr:=try_getstr_int
      	    end;

	  try_sngfor:
	    begin sng:=''; read(input,sng:60);
	      io_er:=iostatus(input); iosts_print(11,io_er);
		if sng='' then
			begin print(11,'SNG is empty');
			  readln(input); read(input,sng:60)
			end;
		print(11,sng);
		writeln(output); 
		writeln(output,' string length = ',length(sng):2);
		break(output);
	      io_vr:=try_getstr_rl2
      	    end;

	  try_getstr_int:
	    begin getstring(sng,int,int1,int2);
	      io_er:=iostatus(); iosts_print(12,io_er);
	     int_print(13,int); int_print(14,int1); int_print(15,int2); 
		if io_er=io_govf then io_vr:=try_sng
		  else sng:=substr(sng,17)
	    end;

	  try_getstr_rl1:
	    begin getstring(sng,srl:7,srl1);
	      io_er:=iostatus(); iosts_print(16,io_er);
		srl_print(17,srl); srl_print(18,srl1); 
	      if io_er=io_govf then io_vr:=try_sngfor
		else sng:=substr(sng,14)
	    end;

	  try_getstr_rl2:
	    begin getstring(sng,srl,srl1:7);
	      io_er:=iostatus(); iosts_print(19,io_er);
		srl_print(20,srl); srl_print(21,srl1); 
	      if io_er=io_govf then io_vr:=try_putstr
		else sng:=substr(sng,14) 
	    end;

	  try_putstr:
	    begin int_print(22,int); int_print(22,int1); 
	     int_print(22,int2); srl_print(22,srl); srl_print(22,srl1); 
		putstring(sng,int:20,int1:20,int2:20,srl,srl1);
	      io_er:=iostatus(); iosts_print(23,io_er);
		print(23,sng); signal(finish)
	    end;

	end;

	exception

	  program_error:
	    if programstatus=program_substring then
		if io_vr=try_getstr_int then
		  begin print(24,'PROGRAM_SUBSTRING for GETSTR_INT');
		       readln(input); readln(input); read(input,sng);
		       io_vr:=try_getstr_rl1
		  end 
		else if io_vr=try_getstr_rl2 then
		  begin print(25,'PROGRAM_SUBSTRING for GETSTR_RL2');
		    io_vr:=try_putstr
		  end
		else
		 begin print(26,'Unexpected PROGRAM_SUBSTR signalled');
		  signal()
		 end
	      else
		begin print(27,'Unexpected PROGRAM_ERROR signalled');
		  signal()
		end;

	  finish: signal();

	  others:
	    begin print(28,'Unexpected ERROR signalled');
	      signal()
	    end
	
      end end;

      exception

	finish: begin print(0,'--- THE END ---'); close end;

	allconditions:
		begin print(29,'Unexpected ALLCONDITIONS signalled');
		  exception_message;
		  close
		end
    end.
  
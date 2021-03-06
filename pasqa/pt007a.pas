  module pt007a;

	external var	ptr1,ptr2: ptr_main_rcd_type;

    public procedure rd_inp(flnmp: file_name);

	const	drl_const=111.111111111;
		rl_const=3.3;

	var	fl: text;
		bvr: boolean;
		sng: sng_type;
		sng_hdr: packed array[1..4] of char;
		sclr_vr: sclr_type;
		stsclr_vr: stsclr_type;
		bl_ar_vr: bl_ar_type;
		st_vr: st_char;
		chrt,chrt1: char;
		i,i1,i2,ps,strt_pos,len_vr,cnt_vr: integer;
		ind_vr: ind_type;
		sub_vr: subsclr_type;
		drl_vr1,drl_vr2: drl_type;
		rl_vr: rl_type;
		ptr3: ptr_main_rcd_type;

	function rl_convrt(ip: integer): drl_type;
		var	drl_vr: drl_type;
	  begin drl_vr:=ip;
		p_integer('ip',ip); p_drl_type('drl_vr',drl_vr);
	    while abs(drl_vr)>=1 do drl_vr:=drl_vr/10;
		p_drl_type('drl_vr',drl_vr);
	    rl_convrt:=drl_vr
	  end;

      begin open(fl,flnmp); readln(fl);
	for sclr_vr:=zero to five do bl_ar_vr[sclr_vr]:=false;
        sclr_vr:=zero; ptr1:=nil; ptr2:=nil; stsclr_vr:=[];
	while not eof(fl) do
	  begin read(fl,sng_hdr);
	    if sng_hdr='name' then
	      begin readln(fl); read(fl,sng); len_vr:=length(sng);
		  p_sng_type('sng',sng); p_integer('len_vr',len_vr);
		bvr:=true; cnt_vr:=1;
		while bvr do
		  begin chrt:=sng[cnt_vr]; st_vr:=[];
		      p_char('chrt',chrt);
		    while chrt=' ' do
		      begin cnt_vr:=cnt_vr+1;
			if cnt_vr>len_vr then bvr:=false
			  else chrt:=sng[cnt_vr]
		      end;  strt_pos:=cnt_vr;
			      p_integer('strt_pos',strt_pos);
		    while chrt<>' ' do
		      begin if not ([chrt]<=st_vr) then
			       st_vr:=st_vr+[chrt];
			 p_char('chrt',chrt); p_st_char('st_vr',st_vr);
                        cnt_vr:=cnt_vr+1;
			if cnt_vr>len_vr then bvr:=false
			  else chrt:=sng[cnt_vr];
		      end;
			p_integer('cnt_vr',cnt_vr);
		    if strt_pos<>cnt_vr then
		      begin new(ptr3);
			if ptr2<>nil then ptr2^.ptr:=ptr3;
			ptr2:=ptr3;
			if ptr1=nil then ptr1:=ptr3;
			with ptr3^ do
			  begin ptr:=nil;
				elmt.numb:=sclr_vr;
				elmt.lngst:=st_vr;
				elmt.wrd:=substr(sng,strt_pos,
						 cnt_vr-strt_pos)
			  end;
			    p_rcd_type('ptr3^.elmt',ptr3^.elmt);
			    p_boolean('bvr',bvr);
			if bvr then
			  if sclr_vr=five then bvr:=false
			    else sclr_vr:=succ(sclr_vr)
		      end
		  end;  ptr2:=ptr1;  sclr_vr:=zero; readln(fl)
	      end
	    else if sng_hdr='line' then
	      begin if ptr1=nil then
		      begin print(' no names'); jump_error end;
		if ptr2=nil then
		      begin print(' too many lines'); jump_error end
		else
		  begin readln(fl); chrt:=fl^;
		    while chrt<>':' do
		      begin get(fl); chrt:=fl^ end; get(fl); bvr:=true;
		    with ptr2^.elmt do
		      begin
			with subrcd do
			  for ind_vr:=blue to brown do
			    begin stindar[ind_vr]:=[];
			      for sub_vr:=one to four do
			       begin
				p_boolean('bvr',bvr);
				if bvr then
				  begin read(fl,i:5);
					p_integer('i',i);
				    if i<>0 then stindar[ind_vr]:=
                                              stindar[ind_vr]+[sub_vr];
				p_ind_type('ind_vr',ind_vr);
				p_sclr_type('sub_vr',sub_vr);
				    intar[ind_vr,sub_vr]:=i; chrt:=fl^;
				p_char('chrt',chrt);
				    while (chrt<>',')and(chrt<>';') do
				      begin get(fl);
					if eoln(fl) then get(fl);
					chrt:=fl^
				      end; 
				p_char('chrt',chrt);
				    if chrt=';' then bvr:=false
				      else get(fl)
				  end
				else intar[ind_vr,sub_vr]:=0
			       end	
			    end; readln(fl); read(fl,sng);
				p_sng_type('sng',sng);
			st_vr:=['+','-','*','/'];
			ps:=index(sng,'.'); cnt_vr:=search(sng,st_vr);
		p_integer('ps',ps); p_integer('cnt_vr',cnt_vr);
			getstring(substr(sng,1,cnt_vr-1),
				  i1:ps-1,chrt1,i2:cnt_vr-ps-1);
		p_integer('i1',i1); p_integer('i2',i2); 
		p_char('chrt1',chrt1);
			drl_vr1:=rl_convrt(i2); 
		p_drl_type('drl_vr1',drl_vr1);
			drl_vr1:=drl_vr1+i1;
		p_drl_type('drl_vr1',drl_vr1);
			drl_vr1:=drl_vr1+drl_const;
		p_drl_type('drl_vr1',drl_vr1);
			chrt:=sng[cnt_vr]; sng:=substr(sng,cnt_vr+1);
		p_char('chrt',chrt);
			ps:=index(sng,'.');
		p_integer('ps',ps);
			getstring(sng,i1:ps-1,chrt1,i2);
		p_integer('i1',i1); p_integer('i2',i2);
		p_char('chrt1',chrt1);
			drl_vr2:=rl_convrt(i2); 
		p_drl_type('drl_vr2',drl_vr2);
			rl_vr:=drl_vr2+i1;
		p_rl_type('rl_vr',rl_vr);
			rl_vr:=rl_vr/rl_const;
		p_rl_type('rl_vr',rl_vr);
			case chrt of
			  '+': drl_vr1:=drl_vr1+rl_vr;
			  '-': drl_vr1:=drl_vr1-rl_vr;
			  '*': drl_vr1:=drl_vr1*rl_vr;
			  '/': drl_vr1:=drl_vr1/rl_vr;
			end;   rlnum:=drl_vr1;  srlnum:=sin(rl_vr);
		p_drl_type('drl_vr1',drl_vr1);
			bl_ar_vr[sclr_vr]:=true; bl_ar:=bl_ar_vr;
		p_sclr_type('sclr_vr',sclr_vr);
		p_bl_ar_type('bl_ar_vr',bl_ar_vr);
			stsclr_vr:=stsclr_vr+[sclr_vr];
		p_stsclr_type('stsclr_vr',stsclr_vr);
			stsclr:=stsclr_vr;
			if sclr_vr<five then sclr_vr:=succ(sclr_vr);
		      end;  
		p_rcd_type('ptr2^.elmt',ptr2^.elmt);
		    ptr2:=ptr2^.ptr; readln(fl);
		  end	
	      end
	    else
	      begin readln(fl,sng);
		sng:=sng_hdr||sng; print(sng)
	      end
	  end;
	if ptr1=nil then
	  begin print(' no data at all'); jump_error end;
	if ptr2<>nil then
	  begin print(' too few lines'); jump_error end
      end.

    
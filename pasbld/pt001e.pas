  envmodule pt001e options special(word);

  type  mem_ar_tp = array[1..*] of machine_word;
	sclr_dgt_tp = (one,two,three,four,five,six,seven,eight);
	sbrg_100_tp = 100..115;
	st_dgt_tp = set of sclr_dgt_tp;
	short_sng_tp = packed array[1..3] of char;
	pck_ar_tp = packed array[1..3,1..4] of sbrg_100_tp;
	srcd_tp1 = packed record
			sclr: sclr_dgt_tp;
			ar: pck_ar_tp;
			st: st_dgt_tp;
			sng: short_sng_tp 
		   end;
	srcd_tp2 = packed record
			sclr: sclr_dgt_tp;
			sbrg: sbrg_100_tp;
			sng: short_sng_tp;
			int: integer;
			st: st_dgt_tp
		   end;
	rcd_tp1 = packed record
			sbrg_vr: sbrg_100_tp;
			srcd1_vr: srcd_tp1;
			sclr_vr: sclr_dgt_tp;
			int_vr: integer
		  end;
	rcd_tp2 = packed record
			sbrg_vr: sbrg_100_tp;
			ar_vr: pck_ar_tp;
			srcd2_vr: srcd_tp2;
			sng_vr: short_sng_tp
		  end;
	rcd_tp3 = packed record
			sng1: packed array[1..11] of char;
			sng2: string[7];
			sng3: packed array[1..5] of char
		  end;
	tag_fld_tp = (mch_wrd_ar,record_1,record_2,record_3);
	
	mem_prnt_tp = procedure ( integer; var mem_ar_tp );

	rcd_tp = record
		   case boolean of
		     true: (main_mem_ar: array[1..11] of machine_word);
		     false: (mem_prnt: mem_prnt_tp;
			     case tag_fld: tag_fld_tp of
				mch_wrd_ar: (mem_ar: array[1..9] of
						machine_word);
				record_1: (rcd_1: rcd_tp1);
				record_2: (rcd_2: rcd_tp2);
				record_3: (rcd_3: rcd_tp3))
		  end;

  const mch_wrd_len = 36;
	chr_num = 5;
	oct_dgt_num = mch_wrd_len div 3;
	oct_wrds_ln = 3;
	chr_wrds_ln = 14;

  external const rcd_fl_name: file_name;

  external var	rcd: rcd_tp;
		rcd_file: file of rcd_tp;

  external procedure mem_bin_repr( integer; var mem_ar_tp);

  external procedure mem_oct_repr( integer; var mem_ar_tp);

  external procedure mem_chr_repr( integer; var mem_ar_tp);

  external procedure rd_rcd_file;

  end.
    
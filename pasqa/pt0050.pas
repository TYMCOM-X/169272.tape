  program pt0110;

	var	sngsng: string[100];
		sngar1: packed array[1..10] of char;
		sngar2: packed array[1..25] of char;
		bln_vr: boolean;

$include (passrc)debio.inc

    begin
	sngar2:=' give a short string';
      writ$nl(sngar2);
      read$line(sngsng,bln_vr);
	sngar1:=sngsng;
      writ$str(sngar1);
      writ$eol 
    end.
   

simple boolean procedure dorescan;
begin!code
    seto 1,;
    ttcall 6,1;
    trz 1,'777777;
    tlz 1,'677777;
end;

Open(Chan_getchan,"DSK",'17,0,0,0,0,Eof_-1);
Do begin
    If RPGSW
     then begin "RPG"
	integer C,B,E; string F; integer array T[0:1];
	File _ TMPIN( "PEC", E );
	if E then begin
	    F _ cvs( 1000+Parent )[2 to 4]&"PEC.TMP";
	    open(C_getchan,"DSK",1,4,0,256,B,E);
	    lookup(C,F,E);
	    if E then print("?cant read ",F," error code '",E,
				EXIT( !Xwd(Error!RCF,!rh(E)) )  );
	    File _ null;		! make sure no ill side-effects;
	    Do File _ File & input(C,0) until E;
	    rename(C,null,0,E);
	    release(C);
	 end
	 else begin
	    T[0] _ Cvsix("PEC");
	    T[1] _ 0;
	    calli(!Xwd(!TCRDF,T[0]), calli!TMPCOR);	! Delete it;
	 end
     end "RPG"
     else If DoRescan
	   then begin "NOT RPG"
		Backup;
		Setbreak(Table_Getbreak,";",null,"KINS");
		File _ Inchsl(Command);
		Scan(File,Table,Break);
		Relbreak(Table)
	   end "NOT RPG";

    If Length(File)=0
     then begin
	Print("Logfile? ");
	File _ Inchwl
     end;
    Lookup(Chan,File,Eof_-1);
    If Eof
     then begin
	Print("File ",File," not found (",cvos(!rh(Eof)),")",crlf);
	File _ null
     end
end until not Eof;
  
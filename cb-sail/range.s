Define MaxRange = '44 * '2000;

Own Safe Integer Array Range[ 0:'1777 ];

Simple Integer Procedure RangeByte( Integer BitNumber );
! ----------------------------------------------------------------------;
!									;
!	RangeByte	Returns a bytepointer such that the IBP part	;
!			of I-LDB and I-DPB will point to the specified	;
!			bit position in the array.			;
!									;
! ----------------------------------------------------------------------;
start!code
    define T1=1, T2=T1+1;  Protect!acs T1,T2;

	Move	T1,BitNumber;		! Get bit/file number ;
	Soj	T1,;			! Subtract before operation ;
	Idivi	T1,36;			! Separate into parts ;
	Addi	T1,Range[0];		! Index into range array ;
	Subi	T2,36;			! Subtract to get offset ;
	Movn	T2,T2;			! Reverse sign to positive ;
	Lsh	T2,30;			! Slide into position ;
	Tlo	T2,'100;		! setup Point(1,0,offset) ;
	Iorm	T2,T1;			! make a pointer and return ;
end;


Simple Procedure AddRange( Integer Here, There );
! ----------------------------------------------------------------------;
!									;
!	AddRange	Routine to set the bit positions between	;
!			here and there in the range array.  Not the	;
!			"fastest" way, but the easiest.			;
!									;
! ----------------------------------------------------------------------;
begin
    Own Integer Delta, Where;

    Delta_ There - Here;
    Where_ RangeByte( Here );
    Quick!Code
	Define T1=1; Label Loop;

	Movei	T1,1;			! a bit to set ;
Loop:	Idpb	T1,Where;		! in the range array ;
	Sosl	Delta;			! for each file ;
	  Jrst	Loop;			! repeat the operation ;
    end;
end;


Simple Boolean Procedure LegalRange( String Place );
! ----------------------------------------------------------------------;
!									;
!	LegalRange	Returns true if the specified numeric string	;
!			is OCTAL and within the range of the bit-table	;
!			or is a left subset of the word "END".		;
!									;
! ----------------------------------------------------------------------
begin
    Integer Brk;
    String Str;

    If not ( Length( Place ) )			! must not be empty ;
     then begin
	Print( "Tape positions must be non-blank", Crlf );
	Return( False );
     end;

    Scan( Str_ Place, BrkOct, Brk );		! must match all octal ;
    If ( Length( Str ) = 0 )			! if so, return value ;
     then begin
	If Cvo( Place ) > MaxRange
	 then begin
	    Print( "Tape positions must not exceed ",
		    Cvos(MaxRange), ".", Crlf );
	    Return( False );
	 end
	 else Return( Cvo(Place) );
     end;

    If Equ( Place, "END"[1 for length(Place)] )	! must match "END" ;
     then Return( MaxRange );			!  which very positive ;

    Print( "Tape positions should be entered as OCTAL numbers", Crlf,
	   "between 1 and ",Cvos( MaxRange )," inclusive.", Crlf );

    Return( False );				! else return 0 ;
end;


Simple Boolean Procedure GetRange;
! ----------------------------------------------------------------------;
!									;
!	GetRange	Prompts the user for a range and returns	;
!			true if a valid set of ranges is specified.	;
!			As a "side-effect" the appropriate bits are	;
!			turned "ON" or "OFF" in the range table.	;
!									;
! ----------------------------------------------------------------------;
begin
    Own String Line, Part, Start, Stop;
    Own Integer B, E;

    Print( "Tape positions: " );		! prompt the user ;
    Line_ Inchwl;				! read the answer ;
    Scan( Line, BrkWht, Brk );

    If Length( Line )				! something typed ;
     then begin "specified entries"

	ArrClr( Range );			! clear the range ;

	While Length( Line )
	 do begin "each entry"

	    Part_ Scan( Line, BrkCom, Brk );	! get an entry ;
	    If ( Length( Part ) )		!  and break it apart ;
	     then begin "gobble morsel"

		Start_ Scan( Part, BrkDsh, Brk );
		Stop_ If ( Length( Part ) )	! fill with ending ;
		       then Part		!  or with a copy ;
		       else Start;		!  of the same ;
	     end "gobble morsel";

	    If not ( (B_ LegalRange( Start )) and
		     (E_ LegalRange( Stop  )) )	! both must be legal ;
	     then Return( False );

	    If ( B leq 0 ) or			! start must be positive ;
		( E < B )			! end must not be less ;
	     then Return( False )		!  else it's illegal ;
	     else AddRange( B,E );		! if so, then add it ;

	 end "each entry"
     end "specified entries"
     else begin "default entry"

	ArrClr( Range, -1 );			! a blank line means ;
						! position 1 to E-O-T ;
     end "default entry";

    Return( True );				! tell of success ;

end;

  
    2VMFILE.DEB   15-Oct-85 17:51:20  BABNED    entry

	VMFile, VMLine, VMFree, VMMove, VMSetC, VMGetC, VMFLic
	define FT!InternalPages = True;
	Ifcr not FT!InternalPages thenc , VMInit endc

;

begin "VM Package"

  require "(SAILIB)SAIL.DEF"   source!file;
  require "(SAILIB)UUOSYM.DEF" source!file;

  redefine !Block(Group, Name, Size) = {
    Ifcr Length(Cvps(Size)) = 0 thenc assignc Size = 1; Endc
    Define Group}&{Name = Group;
    Redefine Group = Group + Size;};

    Define S! = 0;
    !Block( S!,Dev )			! Device ;
    !Block( S!,Usr,2 )			! Username ;
    !Block( S!,Nam )			! Name ;
    !Block( S!,Ext )			! Extension ;

  Define
	MinChan = 16			! lowest channel to use ;
  ,	MaxChan = 47			! highest available ;
  ,	MaxSlot = MaxChan - MinChan + 1	! number of available slots ;
  ,	MemMax  = MaxSlot * 512		! pages in words ;
  ,	CharPerPage = 512 * 5		! characters per page ;
  ;

  Define MaxSlots = {
      ifcr FT!InternalPages		! if feature "on" (default) ;
       thenc MaxSlot			!  then use internal max ;
       elsec MaxCount			!  else use external value ;
      endc
  };


  Record!Class F (  Integer Page;	! memory page to use ;
		    Integer File;	! file page in use ;
		    Integer Chan;	! channel for file open ;
		    Integer Char;	! character pointer in file ;
		    Integer Line;	! line pointer in file +/-;
		    Integer PTxt;	! text page pointer in file +/- ;
		    Integer Size;	! character size of file ;
		    Integer LSiz;	! lines in file (if known) ;
		    Integer PSiz;	! pages in file (if known) ;
		    Integer FLic    );	! file license info ;

  R!P (F) S;
  Safe R!P (F) Array Files[ 1 : MaxSlot ];

  Integer VMBase, VMPage;

  Own Safe Integer Array FileSpec[ S!Dev : S!Ext ];

 Ifcr FT!InternalPages thenc			! selectable by feature sw ;
  Preset!with [ MemMax + 512 ] 0;		! expect to use 1 : MemMax ;
  Own Safe Integer Array VM[ 1 : MemMax+512 ];	!  entries minus page slop ;
 elsec
  Integer MaxCount;				! remember available slots ;
 endc


Ifcr FT!InternalPages thenc
  Simple Procedure InitStuff;
elsec
  Internal Simple Procedure VMInit( Integer Page, Count );
endc
! ----------------------------------------------------------------------;
!									;
!	InitStuff							;
!		Routine to initialize data structures and calculate	;
!		where to put the initial cache of pages to use for	;
!		this venture.						;
!									;
!	VMInit( FirstPage, Count )					;
!		Routine to setup a cache of pages for the user to use	;
!		instead of using the preset range designated by this	;
!		package.  This is setup via the assembly parameter:	;
!		(FT!InternalPages).					;
!									;
! ----------------------------------------------------------------------;
begin "VM Init"

  Ifcr FT!InternalPages thenc		! internal definition ;
    VMPage_ (location( VM[1] ) + '777) lsh -9;
  elsec
    VMPage_ Page;			! base page ;
    MaxCount_ Count max MaxSlot;	! count of pages ;
  endc
    VMBase_ VMPage lsh 9;		! base memory address ;


    ArrClr( Files );			! files not open ;

end "VM Init";
Ifcr FT!InternalPages thenc
  require InitStuff initialization;
endc



Simple Integer Procedure MapPage( r!p (F) Rec; Integer NewPage );
! ----------------------------------------------------------------------;
!									;
!	MapPage( Rec, NewPage )						;
!		Routine to map the specified new file-page into the	;
!		page designated by F:Page[Rec] and update F:File[Rec]	;
!		to NewPage.						;
!									;
! ----------------------------------------------------------------------;
begin "Map Page"
    Own safe integer array Arg[ 0:1 ];

    Calli( Arg[0]_ !Xwd('2001, F:Page[Rec]), calli!VCLEAR );
    Arg[1]_ NewPage;				! point at file page ;
    Chnior( F:Chan[Rec], Arg[0], !chMFP );	! map the page ;

    If ( !Skip! )				! remember file page ;
     then F:File[Rec]_ NewPage			!  NewPage (if map ok) ;
     else F:File[Rec]_ 0;			!  nothing (if map fails) ;

    return( F:File[Rec] );			! return current mapping ;

end "Map Page";


Simple Procedure Dbp( Reference Integer Ptr );
! ----------------------------------------------------------------------;
!									;
!	Dbp( AsciiBytePointer )						;
!		Routine to decrement a 7-bit byte pointer.  Its only	;
!		magic relies on the assumption that a negative pointer	;
!		is setup as '440700 from the point/bbpp operation that	;
!		creates a ildb pointer to the first byte of the word.	;
!		This routine fixes this to point to the last byte of	;
!		the previous word whenever this is seen.  In "this"	;
!		initial case, this works so that the pointer is never	;
!		decremented the WRONG way.				;
!									;
! ----------------------------------------------------------------------;
begin "Decrement Byte Pointer"

    If ( Ptr < 0 )				! initially '440700,,addr ;
     then Ptr_ !xwd( '010700, !rh(Ptr) - 1 )	! so set to prev-last byte ;
     else Ptr_ Ptr + '070000000000;		! else decrement a byte ;

    If ( Ptr < 0 )				! must now be '440700,,addr ;
     then Ptr_ !xwd( '010700, !rh(Ptr) - 1 );	! so set to prev-last byte ;

end "Decrement Byte Pointer";


Simple Boolean Procedure VMSpec( String Line );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMSpec( FileSpecification )					;
!		Routine to read a string file specification and build	;
!		the special file block used by the VMFile routine.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Spec"
    own integer bp,wp,ct;

    arrclr( filespec );			! clear out the array ;
    filespec[ S!Dev ]_ cvsix( "DSK" );	!  and fill in the device ;
    
    if ( "(" = Line )			! if it starts with "(" ;
     then begin "get user"		!  then pick up username ;
	bp_ point( 6,filespec[ S!Usr ],-1 );
	ct_ 12;				! maximum of 12 charcters ;
	lop( line );			! eat the leading "(" ;
	while ( length( Line ) and ")" neq wp_ lop( line ) )
	 do if ( 0 leq ct_ ct - 1 )	! if room in string ;
	     then if ( wp geq "a" )	!  then check case range ;
		   then idpb( wp-'100, bp )	! lowercase to sixbit ;
		   else idpb( wp-'40, bp );	! uppercase to sixbit ;
     end "get user"
     else begin "default user"		! set default if no user specified ;
	filespec[ S!Usr   ]_ calli( -'22, '41 );
	filespec[ S!Usr+1 ]_ calli( -'21, '41 );
     end "default user";

    if ( length( Line ) = 0 )		! must have a name ;
     then return( false );		!  so return false ;

    bp_ point( 6,filespec[ S!Nam ],-1 );
    ct_ 6;				! maximum of 6 characters ;
    while ( length( Line ) and "." neq wp_ lop( Line ) )
     do if ( 0 leq ct_ ct - 1 )		! if room left in string ;
	 then if ( wp geq "a" )		!  then check case ;
	       then idpb( wp-'100, bp )	!    lowercase to sixbit ;
	       else idpb( wp-'40, bp );	!    uppercase to sixbit ;

    bp_ point( 6,filespec[ S!Ext ],-1 );
    ct_ 3;				! maximum of 3 characters ;
    while ( length( Line ) and " " neq wp_ lop( Line ) )
     do if ( 0 leq ct_ ct - 1 )		! if room left in string ;
	 then if ( wp geq "a" )		!  then check case ;
	       then idpb( wp-'100, bp )	!    lowercase to sixbit ;
	       else idpb( wp-'40, bp );	!    uppercase to sixbit ;

    return( true );

end "VM Spec";


Simple Integer Procedure VMSlot;
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMSlot							;
!		Returns the next available file slot in the internal	;
!		file table.  If no slots or channels are available,	;
!		returns 0.  Array Files[slot] is setup with F:Chan,	;
!		F:Page and F:Char.					;
!									;
! ----------------------------------------------------------------------;
begin "VM Slot"
    Own Integer Slot;

    For Slot_ 1 upto MaxSlots		! check each legal slot ;
     do if not( Files[ Slot ] )		! if it's free ;
	 then begin "setup slot"	!  then make it available ;

	    S_ Files[ Slot ]_ new!record( F );	! initialize record ;
	    F:Chan[ S ]_ MaxChan - Slot + 1;	! file channel ;
	    F:Page[ S ]_ VMPage  + Slot - 1;	! memory page ;
	    F:File[ S ]_ F:Char[ S ]_ -1;	! file/char position ;

	    S_ null!record;		! free up working pointer ;

	    return( Slot );		! give caller a slot number ;

	 end "setup slot";

    return( 0 );

end "VM Slot";


Internal Simple Integer Procedure VMFLic( Integer Slot );
! ----------------------------------------------------------------------;
!									;
!	License_ VMFLic							;
!		Routine to return the license that was set on the 	;
!		file open on the specified slot.			;
!									;
! ----------------------------------------------------------------------;
begin  "VM File Lic"

    If not( 1 leq Slot leq MaxSlots )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    return( F:FLic[ S ] );		! return the license ;

end "VM File Lic";


Internal Simple Integer Procedure VMGetC( Integer Slot );
! ----------------------------------------------------------------------;
!				;
!	Position_ VMGetC( Slot )					;
!		Read the character position within the file and return	;
!		it to the caller.  If no file is open or an invalid	;
!		slot is specified return a value of -2.  ( -1 may be	;
!		returned if the file has been opened, but no reads	;
!		have been requested. )					;
!									;
! ----------------------------------------------------------------------;
begin "VM Get Character Pointer"

    If not( 1 leq Slot leq MaxSlots )	! only "my" Slots are ;
     then return( -2 );			!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( -2 );			!  not this time ;

    return( F:Char[ S ] );		! return character position ;

end "VM Get Character Pointer";


Internal Simple Integer Procedure VMSetC( Integer Slot, Position );
! ----------------------------------------------------------------------;
!									;
!	NewPosition_ VMSetC( Slot, TrialPosition )			;
!		Set the character position with the file open on the	;
!		specified slot.  All further references to the slot	;
!		will use the new file position.  If the specified	;
!		position is outside the file, the position is set to	;
!		-1.  The routine always returns the new position.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Set Character Pointer"

    If not( 1 leq Slot leq MaxSlots )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( 0 leq Position leq F:Size[S] )	! if position within range ;
     then F:Char[S]_ Position		!  then set it up ;
     else F:Char[S]_ Position_ -1;	!  else set to -1 ;

    return( Position );			! return the new position ;

end "VM Set Character Pointer";


Internal Simple Boolean Procedure VMFree( Integer Slot );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMFree( Slot )						;
!		Closes any open file for this slot and frees the	;
!		slot for future use.  Returns true if the slot was	;
!		in use.							;
!									;
! ----------------------------------------------------------------------;
begin "VM Free"

    If not( 1 leq Slot leq MaxSlots )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( F:Char[ S ] neq -1 )		! file positioned? ;
     then begin "unmap slot"

	Calli( !Xwd( '2001, F:Page[ S ] ), calli!VCLEAR );

     end "unmap slot";

    Chniov( F:Chan[ S ], 0, !chREL );	! release Slot ;
    Files[ Slot ]_ null!record;		! clear out tables ;

    return( true );			! everything is ok ;

end "VM Free";


Internal Simple Boolean Procedure VMFile( String Spec );
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMFile( StringSpec )					;
!		Opens a file for reading.  A slot number from 1-36	;
!		is returned if the file is available for reading.	;
!		0 means no slots or the file is not available.		;
!									;
! ----------------------------------------------------------------------;
begin "VM File"
    Own Safe Integer Array File[ 0 : !RBLIC ];
    Preset!with '17, cvsix("DSK   "), 0;
    Own Safe Integer Array Dev[ 0 : 2 ];
    Own Integer Slot;

    If not( Slot_ VMSlot )		! If no Slots available ;
     then return( false );		!  then no file opened ;

    If not( S_ Files[ Slot ] )		! slot assigned? *Debug check* ;
     then return( false );		!  not this time *huh why not* ;

    If not( VMSpec( Spec ) )		! trouble with the spec? ;
     then return( false );		!  then don't do anything ;

    Dev[ 1 ]_ FileSpec[ S!Dev ];	! Setup device block ;
    Chnior( F:Chan[S],Dev[0],!chOPN );	! OPEN [ '17, Dev, 0 ] ;
    If not( !Skip! )			! If open-failure ;
     then begin "open failure"		!  then no file opened ;
	VMFree( Slot );			! Free the slot ;
	return( !Xwd( -1,-1 ) );	!  and return ;
     end "open failure";

    File[ !RBCNT ]_ !RBLIC;		! Setup file lookup block ;
    File[ !RBPPN ]_ location( FileSpec[ S!Usr ] );
    File[ !RBNAM ]_ FileSpec[ S!Nam ];
    File[ !RBEXT ]_ FileSpec[ S!Ext ] land (-1 lsh 18);

    Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
    If not( !Skip! )			! If lookup-failure ;
     then begin "no file"		!  then Free the slot ;
	VMFree( Slot );			!  and return error code ;
	return( !Xwd( -1,!rh(File[!RBEXT]) ) );
     end "no file";

    F:Size[ S ]_ File[ !RBSIZ ] * 5;	! File size in characters ;
    F:FLic[ S ]_ !rh( File[ !RBLIC ] );	! File license ;

    return( Slot );			! Return the slot number ;

end "VM File";


Internal String Procedure VMLine( Integer Slot; Reference Integer More;
				  Integer Dir( 0 ) );
! ----------------------------------------------------------------------;
!									;
!	Line_ VMLine( Slot, More, Dir(0) )				;
!		Returns the next consecutive line from the file that	;
!		is connected to the specified slot.  More is set to	;
!		the line terminator ( LF, FF or VT) or to 0 when the	;
!		end of the file is reached or the slot is inactive.	;
!		Dir is the direction read the file (zero = forward,	;
!		-1 or non-zero = backward).				;
!									;
! ----------------------------------------------------------------------;
begin "VM Line"
    Integer Page, Byte, Ch, Copy, Count, Len, LastBrk;
    Boolean Eol;
    String Str;

    More_ 0;				! Initialize for bad exits ;

    If not( 1 leq Slot leq MaxSlots )	! only "my" Slots are ;
     then return( null );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( null );		!  not this time ;

    If ( Dir )				! verify proper usage of Dir ;
     then Dir_ -1			!  non-zero = backward = -1 ;
     else Dir_ +1;			!  was-zero = forward  = +1 ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then If ( Dir < 0 )		! Forward or Backward? ;
	   then F:Char[S]_ F:Size[S]	!   Set after last character ;
	   else F:Char[S]_ 0;		!   Set before first character ;

    If ( F:File[S] neq Page_ ( F:Char[S] div CharPerPage ) + 1 )
     then MapPage( S, Page );		! Verify using right page ;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Copy_Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);
    If ( Dir < 0 )			! If backward direction ;
     then Ibp( Copy );			!  then offset immediately by 1 ;

    Str_ Null;				! Initial return string ;

    If ( Dir geq 0 )			!   Fix count (# left) ;
     then If ( ( F:File[S] * CharPerPage ) > F:Size[S] )
	   then Count_ (F:Size[S] mod CharPerPage) - Count
	   else Count_ CharPerPage - Count;

    Len_ 0;				!   Initialize string length ;
    LastBrk_ 0;				!   Initialize break var ;
    Eol_ false;				!   Initialize line var ;
    While not( Eol )			!   Read one line ;
     do begin "one line"

	If ( Count > 0 )		! Must have chars left ;
	 then begin "more characters"	!  to even try to read ;

	    If ( Dir < 0 )		! Forward or Backward? ;
	     then Dbp( Copy )		!  position the character ;
	     else Ibp( Copy );		!  pointer in the page ;

	    F:Char[S]_ F:Char[S] + Dir;	! Increment count into file ;

	    Case More_ Ldb( Copy ) of begin	! check for end of line ;
		[#nul][#cr] begin "found eos break"
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    If ( Dir < 0 ) and		! Backing up? ;
		       not( LastBrk or More )	! First time through? (nulls);
		     then Dbp( Byte )		!  yes, keep it this way ;
		     else Byte_ Copy;		!  no, update pointer ;
		    Len_ 0;			! Reset string length ;
		 end "found eos break";

		[#lf][#vt][#ff] begin "found eol break"
		    Eol_ true;			! looks like one? ;
		    if ( Dir < 0 )		! were we going backward? ;
		     then if ( Copy = Byte )	!  and the first character ;
			   then begin "not eol"
			      Eol_ false;	!  yes, not really eol ;
			      Print( "<" );
!			      LastBrk_ More;	!  remember this for later ;
			   end "not eol"
			   else begin "got eol"
!			      F:Char[S]_ F:Char[S] + 1;
			      Print( ">" );
!			      More_ LastBrk;	! set count and eol-brk ;
			   end "got eol";
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		 end "found eol break";

		[else] Len_ Len + 1		!  increment string length ;
	    end;

	    If ( memory[ !rh( copy ) ] land 1 )	! bit 35 set ;
	     then begin "sequence numbers"	! in this word? ;

		Count_ (Count - 5) max 0;	!  update counts by 5 chars ;
		F:Char[S]_ (F:Char[S] + (5*Dir)) max 0;

		If ( Dir < 0  and  Len > 2 )	! reverse read normal case ;
		 then begin "normal reverse"	!  +1 for tab after seq # ;
		    Ibp( Copy );		! make string skipping tab ;
		    Str_ StMake( Copy, Len-2 ) & Str;
		 end "normal reverse"
		 else if ( Dir > 0  and  Len neq 1 )
		       then Print( "*** Bad SEQ # in text file. ***"& Crlf );

		Byte_ Copy_ Copy + Dir;		!  update 1 word ;
		Len_ 0;				! Reset length ;

	     end "sequence numbers";

	    If ( 0 = Count_ (Count-1) max 0 )	! If now out of characters ;
	     then begin "fake eos break"
		If ( Len )			! length to concatenate? ;
		 then if ( Dir < 0 )
		       then Str_ StMake( Copy, Len ) & Str
		       else Str_ Str & StMake( Byte, Len );
		Len_ 0;				! Reset string length ;
	     end "fake eos break";

	 end "more characters"
	 else begin "need next page"		! If no-more-characters ;

	    If ( F:Char[S] geq F:Size[S] )	! Forwards at end or ;
	       or ( F:Char[S] = 0 )		!  backwards at beginning ;
	     then begin "end of file"		! At end-of-file? ;

		Eol_ true;			! Set flags true ;
!		If ( Dir < 0 )			! If backing up ;
!		 then More_ LastBrk		!  use last break at end ;
!		 else; More_ 0;			!  else set flag var to 0 ;
		Done "one line";		! Finish loop ;

	     end "end of file";			! Guess, read next page ;

	    MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 );

	    ! ** assume: here at the beginning of the page ** ;
	    If ( Dir < 0 )			! Forward or Backward? ;
	     then Copy_ Byte_ point( 7, memory[(F:Page[S]+1) lsh 9], -1 )
	     else Copy_ Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );

	    If ( ( Page * CharPerPage ) > F:Size[S] )
	     then Count_ F:Size[S] mod CharPerPage
	     else Count_ CharPerPage;

	 end "need next page";

     end "one line";

    return( Str );			! give 'em what they came for ;

end "VM Line";


Internal Boolean Procedure VMMove( Integer Slot, HowMany(1) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMMove( Slot, HowMany(1) )					;
!		Moves the position pointer forward or backward up to	;
!		HowMany lines in the file.  Returns true if the slot is	;
!		active and HowMany lines exist, otherwise it returns	;
!		false and leaves the pointer positioned at logical end	;
!		of file (at the beginning if direction is backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Move"
    Integer Page, Byte, Copy, Count, Dir;
    Boolean Eol;

    If not( 1 leq Slot leq MaxSlots )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( HowMany )			! we can always move ;
     then return( true );		!  a distance of 0 ;

    If ( HowMany < 0 )			! verify proper direction ;
     then Dir_ -1			!  negative = backward = -1 ;
     else Dir_ +1;			!  positive = forward  = +1 ;

    HowMany_ Dir * HowMany;		! always sign correct the count ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then If ( Dir < 0 )		! Forward or Backward? ;
	   then F:Char[S]_ F:Size[S]	!   Set after last character ;
	   else F:Char[S]_ 0;		!   Set before first character ;

    If ( Dir < 0  and  F:Char[S] = 0 ) or
       ( Dir geq 0  and  F:Char[S] geq F:Size[S] )
     then return( false );		! can't move if already at end ;

    If ( F:File[S] neq Page_ ( F:Char[S] div CharPerPage ) + 1 )
     then MapPage( S, Page );		! Verify using right page ;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Copy_Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);
    If ( Dir < 0 )			! Going backward? ;
     then Ibp( Copy );			!  then offset by 1 ;

    If ( Dir geq 0 )			! [F] Fix count (# left) ;
     then If ( ( F:File[S] * CharPerPage ) > F:Size[S] )
	   then Count_ (F:Size[S] mod CharPerPage) - Count
	   else Count_ CharPerPage - Count;

    Eol_ false;				!   Initialize line var ;
    While ( 0 geq HowMany_ HowMany - 1 ) and not( Eol )
     do begin "each line"		! Read one line ;

	If ( Count > 0 )			! Must have chars left ;
	 then begin "more characters"		!  to even try to read ;

	    Count_ Count - 1;			! Decrement characters left ;
	    F:Char[S]_ F:Char[S] + Dir;		! Update count into file ;

	    If ( Dir < 0 )			! Which direction? ;
	     then Dbp( Copy )			!  to move the pointer ;
	     else Ibp( Copy );			!  forward or backward ;

	    Case Ldb( Copy ) of begin		! Check character type ;
		[#lf][#vt][#ff] begin "got eol"
		    Eol_ true;			! looks like one? ;
		    if ( Dir < 0 )		! were we going backward? ;
		     then if ( Copy = Byte )	!  and the first character ;
			   then Eol_ false	!  yes, not really eol ;
			   else F:Char[S]_ F:Char[S] + 1;
		 end "got eol";
		[else]				!    else go on to the next ;
	    end;

	    If ( memory[!rh(copy)] land 1 )	! bit 35 set ;
	     then begin "sequence numbers"	! in this word? ;

		Count_ Count - 5;		! decrement left by 5 ;
		Copy_ Copy + Dir;		! update word by 1 ;
		F:Char[S]_ F:Char[S] + (5*Dir);	! update char by 5 ;

	     end "sequence numbers";

	 end "more characters"
	 else begin "need next page"		! If no-more-characters ;

	    If ( F:Char[S] geq F:Size[S] )	! * Forward * ;
	       or ( F:Char[S] = 0 )		! * or backward * ;
	     then begin "end of file"		! At end of file? ;

		Eol_ true;			! Set flags true ;
		If ( HowMany )			! If any lines to go ;
		 then return( false )		!  this is bad ;
		 else Done "each line";		!  else Finish loop ;

	     end "end of file";			! Guess, read next page ;

	    MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 );

	    ! ** assume: here at the end/beginning of the page ** ;
	    If ( Dir < 0 )
	     then Copy_ point( 7, memory[(F:Page[S]+1) lsh 9], -1 )
	     else Copy_ point( 7, memory[F:Page[S] lsh 9], -1 );

	    If ( ( Page * CharPerPage ) > F:Size[S] )
	     then Count_ F:Size[S] mod CharPerPage
	     else Count_ CharPerPage;

	 end "need next page";

     end "each line";

    return( true );			! give 'em what they came for ;

end "VM Move";

end "VM Package";     2VMFILE.000   ?18-Oct-85 13:27:30  WEFPAT    entry
	VMFile, VMFree, VMLine, VMMove,
	VMGetC, VMSetC, VMFLic, VMSetM
	define FT!InternalPages = True;
	Ifcr not FT!InternalPages thenc , VMInit endc

;

begin "VM Package"

  require "(SAILIB)SAIL.DEF"   source!file;
  require "(SAILIB)UUOSYM.DEF" source!file;

  redefine !Block(Group, Name, Size) = {
    Ifcr Length(Cvps(Size)) = 0 thenc assignc Size = 1; Endc
    Define Group}&{Name = Group;
    Redefine Group = Group + Size;};

    Define S! = 0;
    !Block( S!,Dev )			! Device ;
    !Block( S!,Usr,2 )			! Username ;
    !Block( S!,Nam )			! Name ;
    !Block( S!,Ext )			! Extension ;

    Define VM$ = 0;
    !Block( VM$,Char )			! Character position ;
    !Block( VM$,Line )			! Line position ;
    !Block( VM$,Page )			! Page position ;
    !Block( VM$,Eol )			! End of Line terminator ;
    !Block( VM$,ECR )			! End of Line CR seen ;
    !Block( VM$,Size )			! Size of file in Characters ;
    !Block( VM$,LSize )			! Size of file in Lines ;
    !Block( VM$,PSize )			! Size of file in Pages ;
    !Block( VM$,Lic )			! File license ;


  Define
	MinChan = 16			! lowest channel to use ;
  ,	MaxChan = 47			! highest available ;
  ,	MaxSlot = MaxChan - MinChan + 1	! number of available slots ;
  ,	MemMax  = MaxSlot * 512		! pages in words ;
  ,	CharPerPage = 512 * 5		! characters per page ;
  ,	BackByte  = '430000000001	! offset to backup a byte ;
  ,	AddaByte  = '070000000000	! offset to increment byte ;
  ;



  Record!Class F (  Integer Page;	! memory page to use ;
		    Integer File;	! file page in use ;
		    Integer Chan;	! channel for file open ;
		    Integer Char;	! character pointer in file ;
		    Integer Line;	! line pointer in file +/-;
		    Integer PTxt;	! text page pointer in file +/- ;
		    Integer Last;	! last eol character ;
		    Integer CRet;	! carriage return on line ;
		    Integer Size;	! character size of file ;
		    Integer LSiz;	! lines in file (if known) ;
		    Integer PSiz;	! pages in file (if known) ;
		    Integer FLic    );	! file license info ;

  R!P (F) S;
  Safe R!P (F) Array Files[ 1 : MaxSlot ];

  Integer VMBase, VMPage;			! virtual memory pointers  ;
  Integer MaxSlots;				! remember available slots ;

  Own Safe Integer Array FileSpec[ S!Dev : S!Ext ];

 Ifcr FT!InternalPages thenc			! selectable by feature sw ;
  Preset!with [ MemMax + 512 ] 0;		! expect to use 1 : MemMax ;
  Own Safe Integer Array VM[ 1 : MemMax+512 ];	!  entries minus page slop ;
 endc


Ifcr FT!InternalPages thenc
  Simple Procedure InitStuff;
elsec
  Internal Simple Procedure VMInit( Integer Page, Count );
endc
! ----------------------------------------------------------------------;
!									;
!	InitStuff							;
!		Routine to initialize data structures and calculate	;
!		where to put the initial cache of pages to use for	;
!		this venture.						;
!									;
!	VMInit( FirstPage, Count )					;
!		Routine to setup a cache of pages for the user to use	;
!		instead of using the preset range designated by this	;
!		package.  This is setup via the assembly parameter:	;
!		(FT!InternalPages).					;
!									;
! ----------------------------------------------------------------------;
begin "VM Init"

  Ifcr FT!InternalPages thenc		! internal definition ;
    VMPage_ (location( VM[1] ) + '777) lsh -9;
    MaxSlots_ MaxSlot;			! count of pages ;
  elsec
    VMPage_ Page;			! base page ;
    MaxSlots_ Count max MaxSlot;	! count of pages ;
  endc
    VMBase_ VMPage lsh 9;		! base memory address ;

    ArrClr( Files );			! files not open ;

end "VM Init";
Ifcr FT!InternalPages thenc
  require InitStuff initialization;
endc


Internal Simple Integer Procedure VMMaxS( Integer Count );
! ----------------------------------------------------------------------;
!									;
!	NewCount_ VMMaxS( Count )					;
!		Routine to limit the maximum number of slots to use	;
!		in this package.  Useful to insure that specifically	;
!		allocated channels between the top of SAILs channel	;
!		range and those used by VMFILE are not used.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Max Slots"

    return( MaxSlots_ Count max MaxSlot );	! count of pages ;

end "VM Max Slots";


Simple Integer Procedure MapPage( r!p (F) Rec; Integer NewPage );
! ----------------------------------------------------------------------;
!									;
!	MapPage( Rec, NewPage )						;
!		Routine to map the specified new file-page into the	;
!		page designated by F:Page[Rec] and update F:File[Rec]	;
!		to NewPage.						;
!									;
! ----------------------------------------------------------------------;
begin "Map Page"
    Own safe integer array Arg[ 0:1 ];

    Calli( Arg[0]_ !Xwd('2001, F:Page[Rec]), calli!VCLEAR );
    Arg[1]_ NewPage;				! point at file page ;
    Chnior( F:Chan[Rec], Arg[0], !chMFP );	! map the page ;

    If ( !Skip! )				! remember file page ;
     then F:File[Rec]_ NewPage			!  NewPage (if map ok) ;
     else F:File[Rec]_ 0;			!  nothing (if map fails) ;

    return( F:File[Rec] );			! return current mapping ;

end "Map Page";


Simple Integer Procedure Dbp( Reference Integer Ptr );
! ----------------------------------------------------------------------;
!									;
!	Dbp( AsciiBytePointer )						;
!		Routine to decrement a 7-bit byte pointer.  Its only	;
!		magic relies on the assumption that a negative pointer	;
!		is setup as '440700 from the point/bbpp operation that	;
!		creates a ildb pointer to the first byte of the word.	;
!		This routine fixes this to point to the last byte of	;
!		the previous word whenever this is seen.  In "this"	;
!		initial case, this works so that the pointer is never	;
!		decremented the WRONG way.				;
!									;
! ----------------------------------------------------------------------;
begin "Decrement Byte Pointer"

    If ( Ptr < 0 )			! initially '440700,,addr ;
     then Ptr_ Ptr - BackByte		! so set to prev-last byte ;
     else Ptr_ Ptr + AddaByte;		! else decrement a byte ;

    If ( Ptr < 0 )			! must now be '440700,,addr ;
     then Ptr_ Ptr - BackByte;		! so set to prev-last byte ;

    return( Ptr );			! so it can be an expression ;

end "Decrement Byte Pointer";


Simple Boolean Procedure VMSpec( String Line );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMSpec( FileSpecification )					;
!		Routine to read a string file specification and build	;
!		the special file block used by the VMFile routine.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Spec"
    own integer bp,wp,ct;

    arrclr( filespec );			! clear out the array ;
    filespec[ S!Dev ]_ cvsix( "DSK" );	!  and fill in the device ;
    
    if ( "(" = Line )			! if it starts with "(" ;
     then begin "get user"		!  then pick up username ;
	bp_ point( 6,filespec[ S!Usr ],-1 );
	ct_ 12;				! maximum of 12 charcters ;
	lop( line );			! eat the leading "(" ;
	while ( length( Line ) and ")" neq wp_ lop( line ) )
	 do if ( 0 leq ct_ ct - 1 )	! if room in string ;
	     then if ( wp geq "a" )	!  then check case range ;
		   then idpb( wp-'100, bp )	! lowercase to sixbit ;
		   else idpb( wp-'40, bp );	! uppercase to sixbit ;
     end "get user"
     else begin "default user"		! set default if no user specified ;
	filespec[ S!Usr   ]_ calli( -'22, '41 );
	filespec[ S!Usr+1 ]_ calli( -'21, '41 );
     end "default user";

    if ( length( Line ) = 0 )		! must have a name ;
     then return( false );		!  so return false ;

    bp_ point( 6,filespec[ S!Nam ],-1 );
    ct_ 6;				! maximum of 6 characters ;
    while ( length( Line ) and "." neq wp_ lop( Line ) )
     do if ( 0 leq ct_ ct - 1 )		! if room left in string ;
	 then if ( wp geq "a" )		!  then check case ;
	       then idpb( wp-'100, bp )	!    lowercase to sixbit ;
	       else idpb( wp-'40, bp );	!    uppercase to sixbit ;

    bp_ point( 6,filespec[ S!Ext ],-1 );
    ct_ 3;				! maximum of 3 characters ;
    while ( length( Line ) and " " neq wp_ lop( Line ) )
     do if ( 0 leq ct_ ct - 1 )		! if room left in string ;
	 then if ( wp geq "a" )		!  then check case ;
	       then idpb( wp-'100, bp )	!    lowercase to sixbit ;
	       else idpb( wp-'40, bp );	!    uppercase to sixbit ;

    return( true );

end "VM Spec";


Simple Integer Procedure VMSlot;
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMSlot							;
!		Returns the next available file slot in the internal	;
!		file table.  If no slots or channels are available,	;
!		returns 0.  Array Files[slot] is setup with F:Chan,	;
!		F:Page and F:Char.					;
!									;
! ----------------------------------------------------------------------;
begin "VM Slot"
    Own Integer Slot;

    For Slot_ 1 upto MaxSlots		! check each legal slot ;
     do if not( Files[ Slot ] )		! if it's free ;
	 then begin "setup slot"	!  then make it available ;

	    S_ Files[ Slot ]_ new!record( F );	! initialize record ;
	    F:Chan[ S ]_ MaxChan - Slot + 1;	! file channel ;
	    F:Page[ S ]_ VMPage  + Slot - 1;	! memory page ;
	    F:File[ S ]_ F:Char[ S ]_ -1;	! file/char position ;

	    S_ null!record;		! free up working pointer ;

	    return( Slot );		! give caller a slot number ;

	 end "setup slot";

    return( 0 );

end "VM Slot";


Internal Simple Integer Procedure VMFLic( Integer Slot );
! ----------------------------------------------------------------------;
!									;
!	License_ VMFLic							;
!		Routine to return the license that was set on the 	;
!		file open on the specified slot.			;
!									;
! ----------------------------------------------------------------------;
begin  "VM File Lic"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    return( F:FLic[ S ] );		! return the license ;

end "VM File Lic";


Internal Simple Integer Procedure VMGetC( Integer Slot, Index(VM$Char) );
! ----------------------------------------------------------------------;
!									;
!	Position_ VMGetC( Slot, Index(VM$Char) )			;
!		Read the specified characteristic from the file table.	;
!		[0]character, [1]line or [2]page position in the file	;
!		[3]eol char, [4]eol-cr-seen, size in [5]characters,	;
!		[6]lines or [7]pages, [8]file license.  If no file is	;
!		open or an invalid slot, return -2.  If the index is	;
!		out of range, return -3.  If the file is open, but no	;
!		reads have been done, return -1.			;
!									;
! ----------------------------------------------------------------------;
begin "VM Get Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( -2 );			!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( -2 );			!  not this time ;

    Case Index of begin
	[VM$Char]  return( F:Char[ S ] );	! return character position ;
	[VM$Line]  return( F:Line[ S ] );	! return line position ;
	[VM$Page]  return( F:PTxt[ S ] );	! return page position ;
	[VM$Eol]   return( F:Last[ S ] );	! return last eol char ;
	[VM$ECR]   return( F:CRet[ S ] );	! return last cr on line ;
	[VM$Size]  return( F:Size[ S ] );	! return file size in chars ;
	[VM$LSize] return( F:LSiz[ S ] );	! return file size in lines ;
	[VM$PSize] return( F:PSiz[ S ] );	! return file size in pages ;
	[VM$Lic]   return( F:FLic[ S ] );	! return file license ;
	[else]     return( -3 )			! illegal index ;
    end;

end "VM Get Character Pointer";



Internal Simple Integer Procedure VMSetC( Integer Slot, Position );
! ----------------------------------------------------------------------;
!									;
!	NewPosition_ VMSetC( Slot, TrialPosition )			;
!		Set the character position with the file open on the	;
!		specified slot.  All further references to the slot	;
!		will use the new file position.  If the specified	;
!		position is outside the file, the position is set to	;
!		-1.  The routine always returns the new position.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Set Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( 0 leq Position leq F:Size[S] )	! if position within range ;
     then F:Char[S]_ Position		!  then set it up ;
     else F:Char[S]_ Position_ -1;	!  else set to -1 ;

    return( Position );			! return the new position ;

end "VM Set Character Pointer";


Internal Simple Boolean Procedure VMFree( Integer Slot );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMFree( Slot )						;
!		Closes any open file for this slot and frees the	;
!		slot for future use.  Returns true if the slot was	;
!		in use.							;
!									;
! ----------------------------------------------------------------------;
begin "VM Free"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( F:Char[ S ] neq -1 )		! file positioned? ;
     then begin "unmap slot"

	Calli( !Xwd( '2001, F:Page[ S ] ), calli!VCLEAR );

     end "unmap slot";

    Chniov( F:Chan[ S ], 0, !chREL );	! release Slot ;
    Files[ Slot ]_ null!record;		! clear out tables ;

    return( true );			! everything is ok ;

end "VM Free";


Internal Simple Boolean Procedure VMFile( String Spec );
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMFile( StringSpec )					;
!		Opens a file for reading.  A slot number from 1-36	;
!		is returned if the file is available for reading.	;
!		0 means no slots or the file is not available.		;
!									;
! ----------------------------------------------------------------------;
begin "VM File"
    Own Safe Integer Array File[ 0 : !RBLIC ];
    Preset!with '17, cvsix("DSK   "), 0;
    Own Safe Integer Array Dev[ 0 : 2 ];
    Own Integer Slot;

    If not( Slot_ VMSlot )		! If no Slots available ;
     then return( false );		!  then no file opened ;

    If not( S_ Files[ Slot ] )		! slot assigned? *Debug check* ;
     then return( false );		!  not this time *huh why not* ;

    If not( VMSpec( Spec ) )		! trouble with the spec? ;
     then return( false );		!  then don't do anything ;

    Dev[ 1 ]_ FileSpec[ S!Dev ];	! Setup device block ;
    Chnior( F:Chan[S],Dev[0],!chOPN );	! OPEN [ '17, Dev, 0 ] ;
    If not( !Skip! )			! If open-failure ;
     then begin "open failure"		!  then no file opened ;
	VMFree( Slot );			! Free the slot ;
	return( !Xwd( -1,-1 ) );	!  and return ;
     end "open failure";

    File[ !RBCNT ]_ !RBLIC;		! Setup file lookup block ;
    File[ !RBPPN ]_ location( FileSpec[ S!Usr ] );
    File[ !RBNAM ]_ FileSpec[ S!Nam ];
    File[ !RBEXT ]_ FileSpec[ S!Ext ] land (-1 lsh 18);

    Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
    If not( !Skip! )			! If lookup-failure ;
     then begin "no file"		!  then Free the slot ;
	VMFree( Slot );			!  and return error code ;
	return( !Xwd( -1,!rh(File[!RBEXT]) ) );
     end "no file";

    F:Size[ S ]_ File[ !RBSIZ ] * 5;	! File size in characters ;
    F:FLic[ S ]_ !rh( File[ !RBLIC ] );	! File license ;

    return( Slot );			! Return the slot number ;

end "VM File";


Internal String Procedure VMLine( Integer Slot; Reference Integer More;
				  Integer Dir( 0 ) );
! ----------------------------------------------------------------------;
!									;
!	Line_ VMLine( Slot, More, Dir(0) )				;
!		Returns the next consecutive line from the file that	;
!		is connected to the specified slot.  More is set to	;
!		the line terminator ( LF, FF or VT) or to 0 when the	;
!		end of the file is reached or the slot is inactive.	;
!		Dir is the direction read the file (zero = forward,	;
!		-1 or non-zero = backward).				;
!									;
! ----------------------------------------------------------------------;
begin "VM Line"
    Integer Page, Byte, Copy, Count, Len;
    Boolean Eol;
    String Str;

    More_ 0;				! Initialize for bad exits ;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( null );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( null );		!  not this time ;

    If ( Dir )				! verify proper usage of Dir ;
     then Dir_ -1			!  non-zero = backward = -1 ;
     else Dir_ +1;			!  was-zero = forward  = +1 ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then If ( Dir < 0 )		! Forward or Backward? ;
	   then F:Char[S]_ F:Size[S]	!   Set after last character ;
	   else F:Char[S]_ 0;		!   Set before first character ;

    If ( F:File[S] neq Page_ ( F:Char[S] div CharPerPage ) + 1 )
     then MapPage( S, Page );		! Verify using right page ;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Copy_Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);
    If ( Byte < 0 )			! Means we have '440700,,x ;
     then Copy_ Byte_ Byte - BackByte;	! Point at an actual byte ;
    If ( Dir < 0 )			! If backward direction ;
     then Ibp( Copy );			!  then setup for Dbp by 1 ;

    Str_ Null;				! Initial return string ;

    If ( Dir geq 0 )			!   Fix count (# left) ;
     then If ( ( F:File[S] * CharPerPage ) > F:Size[S] )
	   then Count_ (F:Size[S] mod CharPerPage) - Count
	   else Count_ CharPerPage - Count;

    Len_ 0;				!   Initialize string length ;
    F:Last[S]_ F:CRet[S]_ 0;		!   Initialize break vars ;
    Eol_ false;				!   Initialize line var ;
    While not( Eol )			!   Read one line ;
     do begin "one line"

	If ( Count > 0 )		! Must have chars left ;
	 then begin "more characters"	!  to even try to read ;

	    If ( Dir < 0 )		! Forward or Backward? ;
	     then Dbp( Copy )		!  position the character ;
	     else Ibp( Copy );		!  pointer in the page ;

	    F:Char[S]_ F:Char[S] + Dir;	! Update file character count ;

	    Case More_ Ldb( Copy ) of begin	! check for end of line ;
		[#nul] begin "found eos break"
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    If ( Dir < 0 ) and		! Backing up? ;
		       not( F:Last[S] )		! First time through? ;
		     then Dbp( Byte )		!  yes, keep it this way ;
		     else Byte_ Copy;		!  no, update pointer ;
		    Len_ 0;			! Reset string length ;
		 end "found eos break";

		[#cr] begin "found return"
		    F:CRet[S]_ #CR;		! remember we saw this ;
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    Byte_ Copy;			! synchronize pointers ;
		    Len_ 0;			! Reset string length ;
		 end "found return";

		[#lf][#vt][#ff] begin "found eol break"
		    Eol_ true;			! looks like one? ;
		    if ( Dir < 0 )		! were we going backward? ;
		     then if ( Copy = Byte )	!  and the first character ;
			   then begin "not eol"
			      Eol_ false;	!  yes, not really eol ;
			      F:Last[S]_ More;	!  remember this for later ;
			   end "not eol"
			   else begin "got eol"
			      F:Char[S]_ F:Char[S] + 1;
			      If ( More = #FF )
			       then F:PTxt[S]_ F:PTxt[S] + Dir;
			      F:Line[S]_ F:Line[S] + Dir;
			      More_ F:Last[S];	! set count and eol-brk ;
			   end "got eol"
		     else begin "forward eol"
			If ( More = #FF )
			 then F:PTxt[S]_ F:PTxt[S] + Dir;
			F:Line[S]_ F:Line[S] + Dir;
		     end "forward eol";
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		 end "found eol break";

		[else] begin "keeping track"
		    F:CRet[S]_ 0;		! forget we saw one ;
		    Len_ Len + 1		!  increment string length ;
		 end "keeping track"
	    end;

	    If ( memory[ !rh( copy ) ] land 1 )	! bit 35 set ;
	     then begin "sequence numbers"	! in this word? ;

		If ( Dir < 0 )
		 then begin "seq backward"
		    F:Char[S]_ F:Char[S] - 4;	! tab already seen backwards ;
		    Count_ Count - 4;		!  update counts by 4 chars ;
		    If ( Len > 2 )
		     then begin "add text"	!  +1 for tab after seq # ;
			Ibp( Copy );		! make string skipping tab ;
			Str_ StMake( Copy, Len-2 ) & Str;
		     end "add text"
		 end "seq backward"
		 else begin "seq forward"
		    F:Char[S]_ F:Char[S] + 5;	! include tab in count here ;
		    Count_ Count - 5;		!  update counts by 5 chars ;
		    if ( Len neq 1 )
		     then Print( "*** Bad SEQ # in text file. ***"& Crlf );
		 end "seq forward";

		Byte_ Copy_ Copy + Dir;		!  update 1 word ;
		Len_ 0;				! Reset length ;

	     end "sequence numbers";

	    If ( 0 = Count_ (Count-1) max 0 )	! If now out of characters ;
	     then begin "fake eos break"
		If ( Len )			! length to concatenate? ;
		 then if ( Dir < 0 )
		       then Str_ StMake( Dbp( Copy ), Len ) & Str
		       else Str_ Str & StMake( Byte, Len );
		Len_ 0;				! Reset string length ;
	     end "fake eos break";

	 end "more characters"
	 else begin "need next page"		! If no-more-characters ;

	    If ( F:Char[S] geq F:Size[S] )	! Forwards at end or ;
	       or ( F:Char[S] leq 0 )		!  backwards at beginning ;
	     then begin "end of file"		! At end-of-file? ;

		Eol_ true;			! Set flags true ;
		If ( Dir < 0 )			! If backing up ;
		 then More_ F:Last[S]		!  use last break at end ;
		 else begin "save info"
		    More_ 0;			!  set flag var to 0 ;
		    F:LSiz[S]_ F:Line[S] + 1;	!  save total size in lines ;
		    F:PSiz[S]_ F:PTxt[S] + 1;	!  save total size in pages ;
		 end "save info";
		Done "one line";		! Finish loop ;

	     end "end of file";			! Guess, read next page ;

	    MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 );

	    ! ** assume: here at the beginning of the page ** ;
	    If ( Dir < 0 )			! Forward or Backward? ;
	     then Copy_ Byte_ point( 7, memory[(F:Page[S]+1) lsh 9], -1 )
	     else Copy_ Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );

	    If ( ( Page * CharPerPage ) > F:Size[S] )
	     then Count_ F:Size[S] mod CharPerPage
	     else Count_ CharPerPage;

	 end "need next page";

     end "one line";

    return( Str );			! give 'em what they came for ;

end "VM Line";


Internal Boolean Procedure VMMove( Integer Slot, HowMany(1) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMMove( Slot, HowMany(1) )					;
!		Moves the position pointer forward or backward up to	;
!		HowMany lines in the file.  Returns true if the slot is	;
!		active and HowMany lines exist, otherwise it returns	;
!		false and leaves the pointer positioned at logical end	;
!		of file (at the beginning if direction is backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Move"
    Own Integer Brk;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( HowMany )			! we can always move ;
     then return( true );		!  a distance of 0 ;

    while ( HowMany )			! while lines to go read them ;
     do begin "moving lines"

	If not( length( VMLine( Slot, Brk, HowMany < 0 ) ) or Brk )
	 then return( false );		!  then take the cows to town ;

	If ( HowMany > 0 )		! decrement the right direction ;
	 then HowMany_ HowMany - 1	!  down to zero  ;
	 else HowMany_ HowMany + 1;	!  or up to zero ;

     end "moving lines";

    return( true );			! give 'em what they came for ;

end "VM Move";

end "VM Package";
     2VMFILE.001   ?25-Oct-85 13:26:43  WEFPAT    entry
	VMFile, VMFree, VMLine, VMMove,
	VMGetC, VMSetC, VMFLic, VMSetM
	define FT!InternalPages = True;
	Ifcr not FT!InternalPages thenc , VMInit endc

;

begin "VM Package"

  require "(SAILIB)SAIL.DEF"   source!file;
  require "(SAILIB)UUOSYM.DEF" source!file;

  redefine !Block(Group, Name, Size) = {
    Ifcr Length(Cvps(Size)) = 0 thenc assignc Size = 1; Endc
    Define Group}&{Name = Group;
    Redefine Group = Group + Size;};

    Define S! = 0;
    !Block( S!,Dev )			! Device ;
    !Block( S!,Usr,2 )			! Username ;
    !Block( S!,Nam )			! Name ;
    !Block( S!,Ext )			! Extension ;

    Define VM$ = 0;
    !Block( VM$,Char )			! Character position ;
    !Block( VM$,Line )			! Line position ;
    !Block( VM$,Page )			! Page position ;
    !Block( VM$,Eol )			! End of Line terminator ;
    !Block( VM$,ECR )			! End of Line CR seen ;
    !Block( VM$,Size )			! Size of file in Characters ;
    !Block( VM$,LSize )			! Size of file in Lines ;
    !Block( VM$,PSize )			! Size of file in Pages ;
    !Block( VM$,Lic )			! File license ;


  Define
	MinChan = 16			! lowest channel to use ;
  ,	MaxChan = 47			! highest available ;
  ,	MaxSlot = MaxChan - MinChan + 1	! number of available slots ;
  ,	MemMax  = MaxSlot * 512		! pages in words ;
  ,	CharPerPage = 512 * 5		! characters per page ;
  ,	BackByte  = '430000000001	! offset to backup a byte ;
  ,	AddaByte  = '070000000000	! offset to increment byte ;
  ;



  Record!Class F (  Integer Page;	! memory page to use ;
		    Integer File;	! file page in use ;
		    Integer Chan;	! channel for file open ;
		    Integer Char;	! character pointer in file ;
		    Integer Line;	! line pointer in file +/-;
		    Integer PTxt;	! text page pointer in file +/- ;
		    Integer Last;	! last eol character ;
		    Integer CRet;	! carriage return on line ;
		    Integer Size;	! character size of file ;
		    Integer LSiz;	! lines in file (if known) ;
		    Integer PSiz;	! pages in file (if known) ;
		    Integer FLic    );	! file license info ;

  R!P (F) S;
  Safe R!P (F) Array Files[ 1 : MaxSlot ];

  Integer VMBase, VMPage;			! virtual memory pointers  ;
  Integer MaxSlots;				! remember available slots ;

  Own Safe Integer Array FileSpec[ S!Dev : S!Ext ];

 Ifcr FT!InternalPages thenc			! selectable by feature sw ;
  Preset!with [ MemMax + 512 ] 0;		! expect to use 1 : MemMax ;
  Own Safe Integer Array VM[ 1 : MemMax+512 ];	!  entries minus page slop ;
 endc


Ifcr FT!InternalPages thenc
  Simple Procedure InitStuff;
elsec
  Internal Simple Procedure VMInit( Integer Page, Count );
endc
! ----------------------------------------------------------------------;
!									;
!	InitStuff							;
!		Routine to initialize data structures and calculate	;
!		where to put the initial cache of pages to use for	;
!		this venture.						;
!									;
!	VMInit( FirstPage, Count )					;
!		Routine to setup a cache of pages for the user to use	;
!		instead of using the preset range designated by this	;
!		package.  This is setup via the assembly parameter:	;
!		(FT!InternalPages).					;
!									;
! ----------------------------------------------------------------------;
begin "VM Init"

  Ifcr FT!InternalPages thenc		! internal definition ;
    VMPage_ (location( VM[1] ) + '777) lsh -9;
    MaxSlots_ MaxSlot;			! count of pages ;
  elsec
    VMPage_ Page;			! base page ;
    MaxSlots_ Count max MaxSlot;	! count of pages ;
  endc
    VMBase_ VMPage lsh 9;		! base memory address ;

    ArrClr( Files );			! files not open ;

end "VM Init";
Ifcr FT!InternalPages thenc
  require InitStuff initialization;
endc


Internal Simple Integer Procedure VMMaxS( Integer Count );
! ----------------------------------------------------------------------;
!									;
!	NewCount_ VMMaxS( Count )					;
!		Routine to limit the maximum number of slots to use	;
!		in this package.  Useful to insure that specifically	;
!		allocated channels between the top of SAILs channel	;
!		range and those used by VMFILE are not used.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Max Slots"

    return( MaxSlots_ Count max MaxSlot );	! count of pages ;

end "VM Max Slots";


Simple Integer Procedure MapPage( r!p (F) Rec; Integer NewPage );
! ----------------------------------------------------------------------;
!									;
!	MapPage( Rec, NewPage )						;
!		Routine to map the specified new file-page into the	;
!		page designated by F:Page[Rec] and update F:File[Rec]	;
!		to NewPage.						;
!									;
! ----------------------------------------------------------------------;
begin "Map Page"
    Own safe integer array Arg[ 0:1 ];

    Calli( Arg[0]_ !Xwd('2001, F:Page[Rec]), calli!VCLEAR );
    Arg[1]_ NewPage;				! point at file page ;
    Chnior( F:Chan[Rec], Arg[0], !chMFP );	! map the page ;

    If ( !Skip! )				! remember file page ;
     then F:File[Rec]_ NewPage			!  NewPage (if map ok) ;
     else F:File[Rec]_ 0;			!  nothing (if map fails) ;

    return( F:File[Rec] );			! return current mapping ;

end "Map Page";


Simple Integer Procedure Dbp( Reference Integer Ptr );
! ----------------------------------------------------------------------;
!									;
!	Dbp( AsciiBytePointer )						;
!		Routine to decrement a 7-bit byte pointer.  Its only	;
!		magic relies on the assumption that a negative pointer	;
!		is setup as '440700 from the point/bbpp operation that	;
!		creates a ildb pointer to the first byte of the word.	;
!		This routine fixes this to point to the last byte of	;
!		the previous word whenever this is seen.  In "this"	;
!		initial case, this works so that the pointer is never	;
!		decremented the WRONG way.				;
!									;
! ----------------------------------------------------------------------;
begin "Decrement Byte Pointer"

    If ( Ptr < 0 )			! initially '440700,,addr ;
     then Ptr_ Ptr - BackByte		! so set to prev-last byte ;
     else Ptr_ Ptr + AddaByte;		! else decrement a byte ;

    If ( Ptr < 0 )			! must now be '440700,,addr ;
     then Ptr_ Ptr - BackByte;		! so set to prev-last byte ;

    return( Ptr );			! so it can be an expression ;

end "Decrement Byte Pointer";


Simple Boolean Procedure VMSpec( String Line );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMSpec( FileSpecification )					;
!		Routine to read a string file specification and build	;
!		the special file block used by the VMFile routine.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Spec"
    own integer bp,wp,ct;

    arrclr( filespec );			! clear out the array ;
    filespec[ S!Dev ]_ cvsix( "DSK" );	!  and fill in the device ;
    
    if ( "(" = Line )			! if it starts with "(" ;
     then begin "get user"		!  then pick up username ;
	bp_ point( 6,filespec[ S!Usr ],-1 );
	ct_ 12;				! maximum of 12 charcters ;
	lop( line );			! eat the leading "(" ;
	while ( length( Line ) and ")" neq wp_ lop( line ) )
	 do if ( 0 leq ct_ ct - 1 )	! if room in string ;
	     then if ( wp geq "a" )	!  then check case range ;
		   then idpb( wp-'100, bp )	! lowercase to sixbit ;
		   else idpb( wp-'40, bp );	! uppercase to sixbit ;
     end "get user"
     else begin "default user"		! set default if no user specified ;
	filespec[ S!Usr   ]_ calli( -'22, '41 );
	filespec[ S!Usr+1 ]_ calli( -'21, '41 );
     end "default user";

    if ( length( Line ) = 0 )		! must have a name ;
     then return( false );		!  so return false ;

    bp_ point( 6,filespec[ S!Nam ],-1 );
    ct_ 6;				! maximum of 6 characters ;
    while ( length( Line ) and "." neq wp_ lop( Line ) )
     do if ( 0 leq ct_ ct - 1 )		! if room left in string ;
	 then if ( wp geq "a" )		!  then check case ;
	       then idpb( wp-'100, bp )	!    lowercase to sixbit ;
	       else idpb( wp-'40, bp );	!    uppercase to sixbit ;

    bp_ point( 6,filespec[ S!Ext ],-1 );
    ct_ 3;				! maximum of 3 characters ;
    while ( length( Line ) and " " neq wp_ lop( Line ) )
     do if ( 0 leq ct_ ct - 1 )		! if room left in string ;
	 then if ( wp geq "a" )		!  then check case ;
	       then idpb( wp-'100, bp )	!    lowercase to sixbit ;
	       else idpb( wp-'40, bp );	!    uppercase to sixbit ;

    return( true );

end "VM Spec";


Simple Integer Procedure VMSlot;
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMSlot							;
!		Returns the next available file slot in the internal	;
!		file table.  If no slots or channels are available,	;
!		returns 0.  Array Files[slot] is setup with F:Chan,	;
!		F:Page and F:Char.					;
!									;
! ----------------------------------------------------------------------;
begin "VM Slot"
    Own Integer Slot;

    For Slot_ 1 upto MaxSlots		! check each legal slot ;
     do if not( Files[ Slot ] )		! if it's free ;
	 then begin "setup slot"	!  then make it available ;

	    S_ Files[ Slot ]_ new!record( F );	! initialize record ;
	    F:Chan[ S ]_ MaxChan - Slot + 1;	! file channel ;
	    F:Page[ S ]_ VMPage  + Slot - 1;	! memory page ;
	    F:File[ S ]_ F:Char[ S ]_ -1;	! file/char position ;

	    S_ null!record;		! free up working pointer ;

	    return( Slot );		! give caller a slot number ;

	 end "setup slot";

    return( 0 );

end "VM Slot";


Internal Simple Integer Procedure VMFLic( Integer Slot );
! ----------------------------------------------------------------------;
!									;
!	License_ VMFLic							;
!		Routine to return the license that was set on the 	;
!		file open on the specified slot.			;
!									;
! ----------------------------------------------------------------------;
begin  "VM File Lic"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    return( F:FLic[ S ] );		! return the license ;

end "VM File Lic";


Internal Simple Integer Procedure VMGetC( Integer Slot, Index(VM$Char) );
! ----------------------------------------------------------------------;
!									;
!	Position_ VMGetC( Slot, Index(VM$Char) )			;
!		Read the specified characteristic from the file table.	;
!		[0]character, [1]line or [2]page position in the file	;
!		[3]eol char, [4]eol-cr-seen, size in [5]characters,	;
!		[6]lines or [7]pages, [8]file license.  If no file is	;
!		open or an invalid slot, return -2.  If the index is	;
!		out of range, return -3.  If the file is open, but no	;
!		reads have been done, return -1.			;
!									;
! ----------------------------------------------------------------------;
begin "VM Get Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( -2 );			!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( -2 );			!  not this time ;

    Case Index of begin
	[VM$Char]  return( F:Char[ S ] );	! return character position ;
	[VM$Line]  return( F:Line[ S ] );	! return line position ;
	[VM$Page]  return( F:PTxt[ S ] );	! return page position ;
	[VM$Eol]   return( F:Last[ S ] );	! return last eol char ;
	[VM$ECR]   return( F:CRet[ S ] );	! return last cr on line ;
	[VM$Size]  return( F:Size[ S ] );	! return file size in chars ;
	[VM$LSize] return( F:LSiz[ S ] );	! return file size in lines ;
	[VM$PSize] return( F:PSiz[ S ] );	! return file size in pages ;
	[VM$Lic]   return( F:FLic[ S ] );	! return file license ;
	[else]     return( -3 )			! illegal index ;
    end;

end "VM Get Character Pointer";



Internal Simple Integer Procedure VMSetC( Integer Slot, Position );
! ----------------------------------------------------------------------;
!									;
!	NewPosition_ VMSetC( Slot, TrialPosition )			;
!		Set the character position with the file open on the	;
!		specified slot.  All further references to the slot	;
!		will use the new file position.  If the specified	;
!		position is outside the file, the position is set to	;
!		-1.  The routine always returns the new position.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Set Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( 0 leq Position leq F:Size[S] )	! if position within range ;
     then F:Char[S]_ Position		!  then set it up ;
     else F:Char[S]_ Position_ -1;	!  else set to -1 ;

    return( Position );			! return the new position ;

end "VM Set Character Pointer";


Internal Simple Boolean Procedure VMFree( Integer Slot );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMFree( Slot )						;
!		Closes any open file for this slot and frees the	;
!		slot for future use.  Returns true if the slot was	;
!		in use.							;
!									;
! ----------------------------------------------------------------------;
begin "VM Free"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( F:Char[ S ] neq -1 )		! file positioned? ;
     then begin "unmap slot"

	Calli( !Xwd( '2001, F:Page[ S ] ), calli!VCLEAR );

     end "unmap slot";

    Chniov( F:Chan[ S ], 0, !chREL );	! release Slot ;
    Files[ Slot ]_ null!record;		! clear out tables ;

    return( true );			! everything is ok ;

end "VM Free";


Internal Simple Boolean Procedure VMFile( String Spec );
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMFile( StringSpec )					;
!		Opens a file for reading.  A slot number from 1-36	;
!		is returned if the file is available for reading.	;
!		0 means no slots or the file is not available.		;
!									;
! ----------------------------------------------------------------------;
begin "VM File"
    Own Safe Integer Array File[ 0 : !RBLIC ];
    Preset!with '17, cvsix("DSK   "), 0;
    Own Safe Integer Array Dev[ 0 : 2 ];
    Own Integer Slot;

    If not( Slot_ VMSlot )		! If no Slots available ;
     then return( false );		!  then no file opened ;

    If not( S_ Files[ Slot ] )		! slot assigned? *Debug check* ;
     then return( false );		!  not this time *huh why not* ;

    If not( VMSpec( Spec ) )		! trouble with the spec? ;
     then return( false );		!  then don't do anything ;

    Dev[ 1 ]_ FileSpec[ S!Dev ];	! Setup device block ;
    Chnior( F:Chan[S],Dev[0],!chOPN );	! OPEN [ '17, Dev, 0 ] ;
    If not( !Skip! )			! If open-failure ;
     then begin "open failure"		!  then no file opened ;
	VMFree( Slot );			! Free the slot ;
	return( !Xwd( -1,-1 ) );	!  and return ;
     end "open failure";

    File[ !RBCNT ]_ !RBLIC;		! Setup file lookup block ;
    File[ !RBPPN ]_ location( FileSpec[ S!Usr ] );
    File[ !RBNAM ]_ FileSpec[ S!Nam ];
    File[ !RBEXT ]_ FileSpec[ S!Ext ] land (-1 lsh 18);

    Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
    If not( !Skip! )			! If lookup-failure ;
     then begin "no file"		!  then Free the slot ;
	VMFree( Slot );			!  and return error code ;
	return( !Xwd( -1,!rh(File[!RBEXT]) ) );
     end "no file";

    F:Size[ S ]_ File[ !RBSIZ ] * 5;	! File size in characters ;
    F:FLic[ S ]_ !rh( File[ !RBLIC ] );	! File license ;

    return( Slot );			! Return the slot number ;

end "VM File";


Internal String Procedure VMLine( Integer Slot; Reference Integer More;
				  Integer Dir( 0 ) );
! ----------------------------------------------------------------------;
!									;
!	Line_ VMLine( Slot, More, Dir(0) )				;
!		Returns the next consecutive line from the file that	;
!		is connected to the specified slot.  More is set to	;
!		the line terminator ( LF, FF or VT) or to 0 when the	;
!		end of the file is reached or the slot is inactive.	;
!		Dir is the direction read the file (zero = forward,	;
!		-1 or non-zero = backward).				;
!									;
! ----------------------------------------------------------------------;
begin "VM Line"
    Integer Page, Byte, Copy, Count, Len;
    Boolean Eol;
    String Str;

    More_ 0;				! Initialize for bad exits ;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( null );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( null );		!  not this time ;

    If ( Dir )				! verify proper usage of Dir ;
     then Dir_ -1			!  non-zero = backward = -1 ;
     else Dir_ +1;			!  was-zero = forward  = +1 ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then If ( Dir < 0 )		! Forward or Backward? ;
	   then F:Char[S]_ F:Size[S]	!   Set after last character ;
	   else F:Char[S]_ 0;		!   Set before first character ;

    If ( F:File[S] neq Page_ ( F:Char[S] div CharPerPage ) + 1 )
     then MapPage( S, Page );		! Verify using right page ;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Copy_Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);
    If ( Byte < 0 )			! Means we have '440700,,x ;
     then Copy_ Byte_ Byte - BackByte;	! Point at an actual byte ;
    If ( Dir < 0 )			! If backward direction ;
     then Ibp( Copy );			!  then setup for Dbp by 1 ;

    Str_ Null;				! Initial return string ;

    If ( Dir geq 0 )			!   Fix count (# left) ;
     then If ( ( F:File[S] * CharPerPage ) > F:Size[S] )
	   then Count_ (F:Size[S] mod CharPerPage) - Count
	   else Count_ CharPerPage - Count;

    Len_ 0;				!   Initialize string length ;
    F:Last[S]_ F:CRet[S]_ 0;		!   Initialize break vars ;
    Eol_ false;				!   Initialize line var ;
    While not( Eol )			!   Read one line ;
     do begin "one line"

	If ( Count > 0 )		! Must have chars left ;
	 then begin "more characters"	!  to even try to read ;

	    If ( Dir < 0 )		! Forward or Backward? ;
	     then Dbp( Copy )		!  position the character ;
	     else Ibp( Copy );		!  pointer in the page ;

	    F:Char[S]_ F:Char[S] + Dir;	! Update file character count ;

	    Case More_ Ldb( Copy ) of begin	! check for end of line ;
		[#nul] begin "found eos break"
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    If ( Dir < 0 ) and		! Backing up? ;
		       not( F:Last[S] )		! First time through? ;
		     then Dbp( Byte )		!  yes, keep it this way ;
		     else Byte_ Copy;		!  no, update pointer ;
		    Len_ 0;			! Reset string length ;
		 end "found eos break";

		[#cr] begin "found return"
		    F:CRet[S]_ #CR;		! remember we saw this ;
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    Byte_ Copy;			! synchronize pointers ;
		    Len_ 0;			! Reset string length ;
		 end "found return";

		[#lf][#vt][#ff] begin "found eol break"
		    Eol_ true;			! looks like one? ;
		    if ( Dir < 0 )		! were we going backward? ;
		     then if ( Copy = Byte )	!  and the first character ;
			   then begin "not eol"
			      Eol_ false;	!  yes, not really eol ;
			      F:Last[S]_ More;	!  remember this for later ;
			   end "not eol"
			   else begin "got eol"
			      F:Char[S]_ F:Char[S] + 1;
			      If ( More = #FF )
			       then F:PTxt[S]_ F:PTxt[S] + Dir;
			      F:Line[S]_ F:Line[S] + Dir;
			      More_ F:Last[S];	! set count and eol-brk ;
			   end "got eol"
		     else begin "forward eol"
			If ( More = #FF )
			 then F:PTxt[S]_ F:PTxt[S] + Dir;
			F:Line[S]_ F:Line[S] + Dir;
		     end "forward eol";
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		 end "found eol break";

		[else] begin "keeping track"
		    F:CRet[S]_ 0;		! forget we saw one ;
		    Len_ Len + 1		!  increment string length ;
		 end "keeping track"
	    end;

	    If ( memory[ !rh( copy ) ] land 1 )	! bit 35 set ;
	     then begin "sequence numbers"	! in this word? ;

		If ( Dir < 0 )
		 then begin "seq backward"
		    F:Char[S]_ F:Char[S] - 4;	! tab already seen backwards ;
		    Count_ Count - 4;		!  update counts by 4 chars ;
		    If ( Len > 2 )
		     then begin "add text"	!  +1 for tab after seq # ;
			Ibp( Copy );		! make string skipping tab ;
			Str_ StMake( Copy, Len-2 ) & Str;
		     end "add text"
		 end "seq backward"
		 else begin "seq forward"
		    F:Char[S]_ F:Char[S] + 5;	! include tab in count here ;
		    Count_ Count - 5;		!  update counts by 5 chars ;
		    if ( Len neq 1 )
		     then Print( "*** Bad SEQ # in text file. ***"& Crlf );
		 end "seq forward";

		Byte_ Copy_ Copy + Dir;		!  update 1 word ;
		Len_ 0;				! Reset length ;

	     end "sequence numbers";

	    If ( 0 = Count_ (Count-1) max 0 )	! If now out of characters ;
	     then begin "fake eos break"
		If ( Len )			! length to concatenate? ;
		 then if ( Dir < 0 )
		       then Str_ StMake( Dbp( Copy ), Len ) & Str
		       else Str_ Str & StMake( Byte, Len );
		Len_ 0;				! Reset string length ;
	     end "fake eos break";

	 end "more characters"
	 else begin "need next page"		! If no-more-characters ;

	    If ( F:Char[S] geq F:Size[S] )	! Forwards at end or ;
	       or ( F:Char[S] leq 0 )		!  backwards at beginning ;
	     then begin "end of file"		! At end-of-file? ;

		Eol_ true;			! Set flags true ;
		If ( Dir < 0 )			! If backing up ;
		 then More_ F:Last[S]		!  use last break at end ;
		 else begin "save info"
		    More_ 0;			!  set flag var to 0 ;
		    F:LSiz[S]_ F:Line[S] + 1;	!  save total size in lines ;
		    F:PSiz[S]_ F:PTxt[S] + 1;	!  save total size in pages ;
		 end "save info";
		Done "one line";		! Finish loop ;

	     end "end of file";			! Guess, read next page ;

	    MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 );

	    ! ** assume: here at the beginning of the page ** ;
	    If ( Dir < 0 )			! Forward or Backward? ;
	     then Copy_ Byte_ point( 7, memory[(F:Page[S]+1) lsh 9], -1 )
	     else Copy_ Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );

	    If ( ( Page * CharPerPage ) > F:Size[S] )
	     then Count_ F:Size[S] mod CharPerPage
	     else Count_ CharPerPage;

	 end "need next page";

     end "one line";

    return( Str );			! give 'em what they came for ;

end "VM Line";


Internal Boolean Procedure VMMove( Integer Slot, HowMany(1) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMMove( Slot, HowMany(1) )					;
!		Moves the position pointer forward or backward up to	;
!		HowMany lines in the file.  Returns true if the slot is	;
!		active and HowMany lines exist, otherwise it returns	;
!		false and leaves the pointer positioned at logical end	;
!		of file (at the beginning if direction is backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Move"
    Own Integer Brk;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( HowMany )			! we can always move ;
     then return( true );		!  a distance of 0 ;

    while ( HowMany )			! while lines to go read them ;
     do begin "moving lines"

	If not( length( VMLine( Slot, Brk, HowMany < 0 ) ) or Brk )
	 then return( false );		!  then take the cows to town ;

	If ( HowMany > 0 )		! decrement the right direction ;
	 then HowMany_ HowMany - 1	!  down to zero  ;
	 else HowMany_ HowMany + 1;	!  or up to zero ;

     end "moving lines";

    return( true );			! give 'em what they came for ;

end "VM Move";

end "VM Package";
     2VMFILE.002   ?26-Oct-85 21:00:57  JEPXEW    entry
	VMFile, VMFree, VMLine, VMText, VMMove,
	VMGetC, VMSetC, VMFLic, VMSetM
	define FT!InternalPages = True;
	Ifcr not FT!InternalPages thenc , VMInit endc

;

begin "VM Package"

  require "(SAILIB)SAIL.DEF"   source!file;
  require "(SAILIB)UUOSYM.DEF" source!file;

  redefine !Block(Group, Name, Size) = {
    Ifcr Length(Cvps(Size)) = 0 thenc assignc Size = 1; Endc
    Define Group}&{Name = Group;
    Redefine Group = Group + Size;};

    Define S! = 0;
    !Block( S!,Dev )			! Device ;
    !Block( S!,Usr,2 )			! Username ;
    !Block( S!,Nam )			! Name ;
    !Block( S!,Ext )			! Extension ;

    Define  VM$ = 0;
    !Block( VM$,Char )			! Character position ;
    !Block( VM$,Line )			! Line position ;
    !Block( VM$,Page )			! Page position ;
    !Block( VM$,Msg )			! Message position ;
    !Block( VM$,Eol )			! End of Line terminator ;
    !Block( VM$,ECR )			! End of Line CR seen ;
    !Block( VM$,Size )			! Size of file in Characters ;
    !Block( VM$,LSize )			! Size of file in Lines-1 ;
    !Block( VM$,PSize )			! Size of file in Pages-1 ;
    !Block( VM$,MSize )			! Size of file in Messages-1 ;
    !Block( VM$,Lic )			! File license ;
    !Block( VM$,Access )		! File access mode ;


  Define
	MinChan = 1			! lowest channel to use ;
  ,	MaxChan = 47			! highest available ;
  ,	MaxSlot = MaxChan - MinChan + 1	! number of available slots ;
  ,	MemMax  = MaxSlot * 512		! pages in words ;
  ,	CharPerPage = 512 * 5		! characters per page ;
  ,	BackByte    = '430000000001	! offset to backup a byte ;
  ,	AddaByte    = '070000000000	! offset to increment byte ;
  ,	$Read       =  0			! read mode ;
  ,	$Write      =  $Read   + 1	! write (supersede) mode ;
  ,	$Update     =  $Write  + 1	! write update mode ;
  ,	$Multi      =  $Update + 1	! multi-update mode ;
  ;



  Record!Class F (  Integer Page;	! memory page to use ;
		    Integer File;	! file page in use ;
		    Integer Chan;	! channel for file open ;
		    Integer Mode;	! file access mode ;
		    Integer Char;	! character pointer in file ;
		    Integer Line;	! line pointer in file +/-;
		    Integer PTxt;	! text page pointer in file +/- ;
		    Integer MTxt;	! text message pointer in file +/- ;
		    Integer Last;	! last eol character ;
		    Integer CRet;	! carriage return on line ;
		    Integer Size;	! character size of file ;
		    Integer LSiz;	! lines in file (if known) ;
		    Integer PSiz;	! pages in file (if known) ;
		    Integer MSiz;	! messages in file (if known) ;
		    Integer FLic    );	! file license info ;

  R!P (F) S;
  Safe R!P (F) Array Files[ 1 : MaxSlot ];

  Integer VMBase, VMPage;			! virtual memory pointers  ;
  Integer MaxSlots;				! remember available slots ;

  Own Safe Integer Array FileSpec[ S!Dev : S!Ext ];

 Ifcr FT!InternalPages thenc			! selectable by feature sw ;
  Preset!with [ MemMax + 512 ] 0;		! expect to use 1 : MemMax ;
  Own Safe Integer Array VM[ 1 : MemMax+512 ];	!  entries minus page slop ;
 endc


Ifcr FT!InternalPages thenc
  Simple Procedure InitStuff;
elsec
  Internal Simple Procedure VMInit( Integer Page, Count );
endc
! ----------------------------------------------------------------------;
!									;
!	InitStuff							;
!		Routine to initialize data structures and calculate	;
!		where to put the initial cache of pages to use for	;
!		this venture.						;
!									;
!	VMInit( FirstPage, Count )					;
!		Routine to setup a cache of pages for the user to use	;
!		instead of using the preset range designated by this	;
!		package.  This is setup via the assembly parameter:	;
!		(FT!InternalPages).					;
!									;
! ----------------------------------------------------------------------;
begin "VM Init"

  Ifcr FT!InternalPages thenc		! internal definition ;
    VMPage_ (location( VM[1] ) + '777) lsh -9;
    MaxSlots_ MaxSlot;			! count of pages ;
  elsec
    VMPage_ Page;			! base page ;
    MaxSlots_ Count max MaxSlot;	! count of pages ;
  endc
    VMBase_ VMPage lsh 9;		! base memory address ;

    ArrClr( Files );			! files not open ;

end "VM Init";
Ifcr FT!InternalPages thenc
  require InitStuff initialization;
endc


Internal Simple Integer Procedure VMMaxS( Integer Count );
! ----------------------------------------------------------------------;
!									;
!	NewCount_ VMMaxS( Count )					;
!		Routine to limit the maximum number of slots to use	;
!		in this package.  Useful to insure that specifically	;
!		allocated channels between the top of SAILs channel	;
!		range and those used by VMFILE are not used.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Max Slots"

    return( MaxSlots_ Count max MaxSlot );	! count of pages ;

end "VM Max Slots";


Simple Integer Procedure MapPage( r!p (F) Rec; Integer NewPage );
! ----------------------------------------------------------------------;
!									;
!	MapPage( Rec, NewPage )						;
!		Routine to map the specified new file-page into the	;
!		page designated by F:Page[Rec] and update F:File[Rec]	;
!		to NewPage.						;
!									;
! ----------------------------------------------------------------------;
begin "Map Page"
    Own safe integer array Arg[ 0:1 ];
    Own integer Status, Err;

    If ( F:File[Rec] = NewPage )		! if the same page ;
     then begin "check protection"

	If not( F:Mode[Rec] )			! if no writing request ;
	 then return( NewPage );		! then nothing special ;
	Status_Calli(F:Page[Rec],calli!PAGSTS);	! read page protection ;
	If ( '3 = ( Status land '7 ) )		! if read/write? ;
	 then return( NewPage );		!  then nothing to do ;
	Err_ Calli( !Xwd( '6001,F:Page[Rec] ), calli!VPROT );
	If ( !skip! )				! if no problems, return! ;
	 then return( NewPage )			!  nothing else to do ;
	 else begin				! otherwise complain and ;
	    Print( "Map error: ",cvos(Err)," pagsts: ",cvos(Status),crlf );
	    return( F:File[Rec]_ 0 );		! make believe un-mapped ;
	 end;

     end "check protection";

    Calli( Arg[0]_ !Xwd('2001,F:Page[Rec]), calli!VCLEAR );
    If ( $Read neq F:Mode[Rec] )		! if we're writing then ;
     then Arg[0]_ !Xwd('6001,F:Page[Rec]);	!  make it .prrw not .prro ;
    Arg[1]_ NewPage;				! point at file page ;
    Chnior( F:Chan[Rec], Arg[0], !chMFP );	! map the page ;
    Start!code MOVEM '3,ERR; end;		! remember any errors ;

    If ( !Skip! )				! remember file page ;
     then F:File[Rec]_ NewPage			!  NewPage (if map ok) ;
     else begin "map failure"			! else check the fault ;
	F:File[Rec]_ 0;				! default (if map fails) ;

	If ( F:Mode[Rec] ) and ( !rh(ERR)='6 )	! if writing and FLPHP% ;
	 then begin "create page"		!  then try to create it ;

	    Chnior( F:Chan[Rec], NewPage, !chCFP );
	    If ( !Skip! )			! check success flag ;
	     then begin "try map again"		! if ok, then try map ;
		Chnior( F:Chan[Rec], Arg[0], !chMFP );
		if ( !Skip! )			! any errors? ;
		 then F:File[Rec]_ NewPage;	! no, it's ok ;
	     end "try map again";

	 end "create page";
     end "map failure";

    return( F:File[Rec] );			! return current mapping ;

end "Map Page";


Simple Integer Procedure Dbp( Reference Integer Ptr );
! ----------------------------------------------------------------------;
!									;
!	Dbp( AsciiBytePointer )						;
!		Routine to decrement a 7-bit byte pointer.  Its only	;
!		magic relies on the assumption that a negative pointer	;
!		is setup as '440700 from the point/bbpp operation that	;
!		creates a ildb pointer to the first byte of the word.	;
!		This routine fixes this to point to the last byte of	;
!		the previous word whenever this is seen.  In "this"	;
!		initial case, this works so that the pointer is never	;
!		decremented the WRONG way.				;
!									;
! ----------------------------------------------------------------------;
begin "Decrement Byte Pointer"

    If ( Ptr < 0 )			! initially '440700,,addr ;
     then Ptr_ Ptr - BackByte		! so set to prev-last byte ;
     else Ptr_ Ptr + AddaByte;		! else decrement a byte ;

    If ( Ptr < 0 )			! must now be '440700,,addr ;
     then Ptr_ Ptr - BackByte;		! so set to prev-last byte ;

    return( Ptr );			! so it can be an expression ;

end "Decrement Byte Pointer";


Simple Boolean Procedure VMSpec( String Line );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMSpec( FileSpecification )					;
!		Routine to read a string file specification and build	;
!		the special file block used by the VMFile routine.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Spec"
    own integer bp,wp,ct;

    arrclr( filespec );			! clear out the array ;
    filespec[ S!Dev ]_ cvsix( "DSK" );	!  and fill in the device ;
    
    if ( "(" = Line )			! if it starts with "(" ;
     then begin "get user"		!  then pick up username ;
	bp_ point( 6,filespec[ S!Usr ],-1 );
	ct_ 12;				! maximum of 12 charcters ;
	lop( line );			! eat the leading "(" ;
	while ( length( Line ) and ")" neq wp_ lop( line ) )
	 do if ( 0 leq ct_ ct - 1 )	! if room in string ;
	     then if ( wp geq "a" )	!  then check case range ;
		   then idpb( wp-'100, bp )	! lowercase to sixbit ;
		   else idpb( wp-'40, bp );	! uppercase to sixbit ;
     end "get user"
     else begin "default user"		! set default if no user specified ;
	filespec[ S!Usr   ]_ calli( -'22, '41 );
	filespec[ S!Usr+1 ]_ calli( -'21, '41 );
     end "default user";

    if ( length( Line ) = 0 )		! must have a name ;
     then return( false );		!  so return false ;

    bp_ point( 6,filespec[ S!Nam ],-1 );
    ct_ 6;				! maximum of 6 characters ;
    while ( length( Line ) and "." neq wp_ lop( Line ) )
     do if ( 0 leq ct_ ct - 1 )		! if room left in string ;
	 then if ( wp geq "a" )		!  then check case ;
	       then idpb( wp-'100, bp )	!    lowercase to sixbit ;
	       else idpb( wp-'40, bp );	!    uppercase to sixbit ;

    bp_ point( 6,filespec[ S!Ext ],-1 );
    ct_ 3;				! maximum of 3 characters ;
    while ( length( Line ) and " " neq wp_ lop( Line ) )
     do if ( 0 leq ct_ ct - 1 )		! if room left in string ;
	 then if ( wp geq "a" )		!  then check case ;
	       then idpb( wp-'100, bp )	!    lowercase to sixbit ;
	       else idpb( wp-'40, bp );	!    uppercase to sixbit ;

    return( true );

end "VM Spec";


Simple Integer Procedure VMSlot;
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMSlot							;
!		Returns the next available file slot in the internal	;
!		file table.  If no slots or channels are available,	;
!		returns 0.  Array Files[slot] is setup with F:Chan,	;
!		F:Page and F:Char.					;
!									;
! ----------------------------------------------------------------------;
begin "VM Slot"
    Own Integer Slot;

    For Slot_ 1 upto MaxSlots		! check each legal slot ;
     do if not( Files[ Slot ] )		! if it's free ;
	 then begin "setup slot"	!  then make it available ;

	    S_ Files[ Slot ]_ new!record( F );	! initialize record ;
	    F:Chan[ S ]_ MaxChan - Slot + 1;	! file channel ;
	    F:Page[ S ]_ VMPage  + Slot - 1;	! memory page ;
	    F:File[ S ]_ F:Char[ S ]_ -1;	! file/char position ;

	    S_ null!record;		! free up working pointer ;

	    return( Slot );		! give caller a slot number ;

	 end "setup slot";

    return( 0 );

end "VM Slot";


Internal Simple Integer Procedure VMFLic( Integer Slot );
! ----------------------------------------------------------------------;
!									;
!	License_ VMFLic							;
!		Routine to return the license that was set on the 	;
!		file open on the specified slot.			;
!									;
! ----------------------------------------------------------------------;
begin  "VM File Lic"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    return( F:FLic[ S ] );		! return the license ;

end "VM File Lic";


Internal Simple Integer Procedure VMGetC( Integer Slot, Index(VM$Char) );
! ----------------------------------------------------------------------;
!									;
!	Position_ VMGetC( Slot, Index(VM$Char) )			;
!		Read the specified characteristic from the file table.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Get Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( -2 );			!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( -2 );			!  not this time ;

    Case Index of begin
	[VM$Char]   return( F:Char[ S ] );	! return character position ;
	[VM$Line]   return( F:Line[ S ] );	! return line position ;
	[VM$Page]   return( F:PTxt[ S ] );	! return page position ;
	[VM$Msg]    return( F:MTxt[ S ] );	! return message position ;
	[VM$Eol]    return( F:Last[ S ] );	! return last eol char ;
	[VM$ECR]    return( F:CRet[ S ] );	! return last cr on line ;
	[VM$Size]   return( F:Size[ S ] );	! return file size in chars ;
	[VM$LSize]  return( F:LSiz[ S ] );	! return file size in lines ;
	[VM$PSize]  return( F:PSiz[ S ] );	! return file size in pages ;
	[VM$MSize]  return( F:MSiz[ S ] );	! return file size in msgs ;
	[VM$Lic]    return( F:FLic[ S ] );	! return file license ;
	[VM$Access] return( F:Mode[ S ] );	! return file access mode ;
	[else]      return( -3 )		! illegal index ;
    end;

end "VM Get Character Pointer";



Internal Simple Integer Procedure VMSetC( Integer Slot, Position );
! ----------------------------------------------------------------------;
!									;
!	NewPosition_ VMSetC( Slot, TrialPosition )			;
!		Set the character position with the file open on the	;
!		specified slot.  All further references to the slot	;
!		will use the new file position.  If the specified	;
!		position is outside the file, the position is set to	;
!		-1.  The routine always returns the new position.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Set Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( 0 leq Position leq F:Size[S] )	! if position within range ;
     then F:Char[S]_ Position		!  then set it up ;
     else F:Char[S]_ Position_ -1;	!  else set to -1 ;

    return( Position );			! return the new position ;

end "VM Set Character Pointer";


Internal Simple Boolean Procedure VMFree( Integer Slot );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMFree( Slot )						;
!		Closes any open file for this slot and frees the	;
!		slot for future use.  Returns true if the slot was	;
!		in use.							;
!									;
! ----------------------------------------------------------------------;
begin "VM Free"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( F:Char[ S ] neq -1 )		! if file mapped, clear page ;
     then Calli( !Xwd( '2001, F:Page[ S ] ), calli!VCLEAR );

    If ( F:Mode[ S ] )			! if any writes ;
     then begin "some changes"		!  reset size & close file ;

	Chniov( F:Chan[S], (F:Size[S]+4) div 5, !chFTR );
	Chnior( F:Chan[ S ], memory[0], !chCLS ) ;

     end "some changes";

    Chniov( F:Chan[ S ], 0, !chREL );	! release Slot ;
    Files[ Slot ]_ null!record;		! clear out tables ;

    return( true );			! everything is ok ;

end "VM Free";


Internal String Procedure VMLine( Integer Slot; Reference Integer More;
				  Integer Dir( 0 ) );
! ----------------------------------------------------------------------;
!									;
!	Line_ VMLine( Slot, More, Dir(0) )				;
!		Returns the next consecutive line from the file that	;
!		is connected to the specified slot.  More is set to	;
!		the line terminator (LF, FF, VT, CR or EOT) or to 0	;
!		when the end of the file is reached or the slot is 	;
!		inactive.  Dir is the direction to read the file ( 0	;
!	 	indicates forward, -1 or non-zero for backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Line"
    Integer Page, Byte, Copy, Count, Len, Last;
    Boolean Eol;
    String Str;

    More_ 0;				! Initialize for bad exits ;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( null );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( null );		!  not this time ;

    If ( Dir )				! verify proper usage of Dir ;
     then Dir_ -1			!  non-zero = backward = -1 ;
     else Dir_ +1;			!  was-zero = forward  = +1 ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then If ( Dir < 0 )		! Forward or Backward? ;
	   then F:Char[S]_ F:Size[S]	!   Set after last character ;
	   else F:Char[S]_ 0;		!   Set before first character ;

    If ( F:File[S] neq Page_ ( F:Char[S] div CharPerPage ) + 1 )
     then if not( MapPage( S, Page ) )	! Verify using right page ;
	   then return( null );		!  and page gets mapped ;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Copy_Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);
    If ( Byte < 0 )			! Means we have '440700,,x ;
     then Copy_ Byte_ Byte - BackByte;	! Point at an actual byte ;
    If ( Dir < 0 )			! If backward direction ;
     then Ibp( Copy );			!  then setup for Dbp by 1 ;

    Str_ Null;				! Initial return string ;

    If ( Dir geq 0 )			!   Fix count (# left) ;
     then If ( ( F:File[S] * CharPerPage ) > F:Size[S] )
	   then Count_ (F:Size[S] mod CharPerPage) - Count
	   else Count_ CharPerPage - Count;

    Len_ 0;				! Initialize string length ;
    F:Last[S]_ F:CRet[S]_ 0;		! Initialize break vars ;
    Last_ -1;				! Last character seen ;
    Eol_ false;				! Initialize line var ;
    While not( Eol )			! Read one line ;
     do begin "one line"

	If ( Count > 0 )		! Must have chars left ;
	 then begin "more characters"	!  to even try to read ;

	    If ( Dir < 0 )		! Forward or Backward? ;
	     then Dbp( Copy )		!  position the character ;
	     else Ibp( Copy );		!  pointer in the page ;

	    F:Char[S]_ F:Char[S] + Dir;	! Update file character count ;

	    Case More_ Ldb( Copy ) of begin	! check for end of line ;
		[#nul] begin "found eos break"
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    If ( Dir < 0 ) and		! Backing up? ;
		       not( F:Last[S] )		! First time through? ;
		     then Dbp( Byte )		!  yes, keep it this way ;
		     else Byte_ Copy;		!  no, update pointer ;
		    Len_ 0;			! Reset string length ;
		 end "found eos break";

		[#cr] begin "found return"
		    If ( Dir < 0 )
		     then if ( #LF leq Last leq #FF )
			   then F:CRet[S]_ #CR	! remember we saw this ;
			   else begin "lone cr"
			      If ( Copy = Byte )	! if first char ;
			       then F:Last[S]_ More	!  remember and go ;
			       else begin "eol cr"	! else do eol stuff ;
				 Eol_ true;		! set end of line ;
				 More_ F:Last[S];	! and get last one ;
				 F:Char[S]_ F:Char[S]+1	! bump pointer by 1 ;
			       end "eol cr";
			   end "lone cr";
		    If ( ( Dir > 0 ) and ( #CR = Last ) )
		     then Eol_ true;		! flag as end of line ;
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    Byte_ Copy;			! synchronize pointers ;
		    Len_ 0;			! Reset string length ;
		 end "found return";

		[#lf][#vt][#ff][#eot] begin "found eol break"
		    Eol_ true;			! looks like one? ;
		    if ( Dir < 0 )		! were we going backward? ;
		     then if ( Copy = Byte )	!  and the first character ;
			   then begin "not eol"
			      Eol_ false;	!  yes, not really eol ;
			      F:Last[S]_ More;	!  remember this for later ;
			      F:Line[S]_ F:Line[S] + Dir;	! each line ;
			      If ( More = #FF )			! each FF ;
			       then F:PTxt[S]_ F:PTxt[S] + Dir;	! text page ;
			      If ( More = #EOT )		! each EOT ;
			       then F:MTxt[S]_ F:MTxt[S] + Dir;	! message ;
			   end "not eol"
			   else begin "got eol"
			      F:Char[S]_ F:Char[S] + 1;		! each char ;
			      More_ F:Last[S];			! eol-brk ;
			   end "got eol"
		     else begin "forward eol"
			If ( Last = #CR ) and ( #LF leq More leq #FF )
			 then F:CRet[S]_ Last;		! mark CR before Brk ;
			If ( More = #FF )		! for each FF seen ;
			 then F:PTxt[S]_ F:PTxt[S]+Dir;	!  count a text page ;
			If ( More = #EOT )		! for each EOT seen ;
			 then F:MTxt[S]_ F:MTxt[S]+Dir;	!  count a text message ;
			F:Line[S]_ F:Line[S] + Dir;	! count each line ;
		     end "forward eol";
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		 end "found eol break";

		[else] begin "normal character"
		    If ( Last = #CR ) and ( Dir > 0 )
		     then begin "lonely cr"	! else do eol stuff ;
			Eol_ true;		! set end of line ;
			F:Char[S]_ F:Char[S]-1;	! bump pointer by 1 ;
			More_ #CR;		! set eol to CR ;
			If ( Len )		! length to concatenate? ;
			 then Str_ Str & StMake( Byte, Len );
		     end "lonely cr"
		     else Len_ Len + 1		!  increment string length ;
		 end "normal character"
	    end;

	    If ( memory[ !rh( copy ) ] land 1 )	! bit 35 set ;
	     then begin "sequence numbers"	! in this word? ;

		If ( Dir < 0 )
		 then begin "seq backward"
		    F:Char[S]_ F:Char[S] - 4;	! tab already seen backwards ;
		    Count_ Count - 4;		!  update counts by 4 chars ;
		    If ( Len > 2 )
		     then begin "add text"	!  +1 for tab after seq # ;
			Ibp( Copy );		! make string skipping tab ;
			Str_ StMake( Copy, Len-2 ) & Str;
		     end "add text"
		 end "seq backward"
		 else begin "seq forward"
		    F:Char[S]_ F:Char[S] + 5;	! include tab in count here ;
		    Count_ Count - 5;		!  update counts by 5 chars ;
		    if ( Len neq 1 )
		     then Print( "*** Bad SEQ # in text file. ***"& Crlf );
		 end "seq forward";

		Byte_ Copy_ Copy + Dir;		!  update 1 word ;
		Len_ 0;				! Reset length ;

	     end "sequence numbers";

	    If ( 0 = Count_ (Count-1) max 0 )	! If now out of characters ;
	     then begin "fake eos break"
		If ( Len )			! length to concatenate? ;
		 then if ( Dir < 0 )
		       then Str_ StMake( Dbp( Copy ), Len ) & Str
		       else Str_ Str & StMake( Byte, Len );
		Len_ 0;				! Reset string length ;
	     end "fake eos break";

	    If ( More )				! if this is not a null ;
	     then Last_ More;			! last char for next time ;

	 end "more characters"
	 else begin "need next page"		! If no-more-characters ;

	    If ( F:Char[S] geq F:Size[S] )	! Forwards at end or ;
	       or ( F:Char[S] leq 0 )		!  backwards at beginning ;
	     then begin "end of file"		! At end-of-file? ;

		Eol_ true;			! Set flags true ;
		If ( Dir < 0 )			! If backing up ;
		 then More_ F:Last[S]		!  use last break at end ;
		 else begin "save info"
		    More_ 0;			!  set flag var to 0 ;
		    F:LSiz[S]_ F:Line[S];	!  save total size in lines ;
		    F:PSiz[S]_ F:PTxt[S];	!  save total size in pages ;
		    F:MSiz[S]_ F:MTxt[S];	!  save total size in pages ;
		 end "save info";
		Done "one line";		! Finish loop ;

	     end "end of file";			! Guess, read next page ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then return( null );		! error mapping! ;

	    ! ** assume: here at the beginning of the page ** ;
	    If ( Dir < 0 )			! Forward or Backward? ;
	     then Copy_ Byte_ point( 7, memory[(F:Page[S]+1) lsh 9], -1 )
	     else Copy_ Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );

	    If ( ( Page * CharPerPage ) > F:Size[S] )
	     then Count_ F:Size[S] mod CharPerPage
	     else Count_ CharPerPage;

	 end "need next page";

     end "one line";

    return( Str );			! give 'em what they came for ;

end "VM Line";


Internal Boolean Procedure VMText( Integer Slot; String Text );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMText( Slot, Text, Dir(0) )				;
!		Writes the next consecutive line or lines to the file	;
!		that is connected to the specified slot.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Text"
    Integer Page, Byte, Char, Count;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( F:Mode[S] )			! were we writing? ;
     then return( false );		! no, don't bother! ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then F:Char[S]_ 0;			!   Set before first character ;

    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
     then begin
	Print( "Page map error: p",page,"  c",F:Char[S],"  f",F:Chan[S],crlf );
	return( false );		! if no page, error return ;
     end;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);

    Count_ CharPerPage - Count;		! Fix count (# left) ;

    while ( length( Text ) )		! Must have some text left ;
     do begin "writing line"

	If ( Count > 0 )		! Must have room left on page ;
	 then begin "more characters"	!  to even try to write ;

	    If not( Char_ Lop( Text ) )	! if char = null then try next ;
	     then continue "writing line";

	    IDpb( Char, Byte );		! deposit byte at position ;
	    F:Char[S]_ F:Char[S] + 1;	! Update file character count ;

	    Case ( Char ) of begin	! check for end of line ;
		[#cr] F:CRet[S]_ #CR;	! remember we saw this ;

		[#lf][#vt][#ff][#eot] begin "count lines"
		  F:Last[S]_ Char;		! remember eol character ;
		  F:Line[S]_ F:Line[S] + 1;	! count lines seen ;
		  If ( Char = #FF )		! for each FF seen ;
		   then F:PTxt[S]_ F:PTxt[S]+1;	!  count a text page ;
		  If ( Char = #EOT )		! for each EOT seen ;
		   then F:MTxt[S]_ F:MTxt[S]+1;	!  count a text message ;
		 end "count lines";

		[else] F:CRet[S]_ 0	! forget we saw a cr ;
	     end;

	    Count_ (Count-1) max 0;	! keep character count ;

	 end "more characters"
	 else begin "need next page"	! If no-more-characters ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then begin
		Print( "Page(2) map error: ",page," ",F:Char[S],crlf );
		return( false );	! if no page, error return ;
	     end;

	    Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );
	    Count_ CharPerPage;		! always a full page to write in ;

	 end "need next page";

     end "writing line";

    If ( F:Char[S] geq F:Size[S] )	! At or Past end of file? ;
     then begin "end of file"

	F:Size[S]_ F:Char[S];		!  save size in characters ;
	F:LSiz[S]_ F:Line[S];		!  save total size in lines ;
	F:PSiz[S]_ F:PTxt[S];		!  save total size in pages ;
	F:MSiz[S]_ F:MTxt[S];		!  save total size in pages ;

     end "end of file";			! Guess, read next page ;

    return( true );			! give 'em what they came for ;

end "VM Text";


Internal Boolean Procedure VMMove( Integer Slot, HowMany(1) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMMove( Slot, HowMany(1) )					;
!		Moves the position pointer forward or backward up to	;
!		HowMany lines in the file.  Returns true if the slot is	;
!		active and HowMany lines exist, otherwise it returns	;
!		false and leaves the pointer positioned at logical end	;
!		of file (at the beginning if direction is backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Move"
    Own Integer Brk;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( HowMany )			! we can always move ;
     then return( true );		!  a distance of 0 ;

    while ( HowMany )			! while lines to go read them ;
     do begin "moving lines"

	If not( length( VMLine( Slot, Brk, HowMany < 0 ) ) or Brk )
	 then return( false );		!  then take the cows to town ;

	If ( HowMany > 0 )		! decrement the right direction ;
	 then HowMany_ HowMany - 1	!  down to zero  ;
	 else HowMany_ HowMany + 1;	!  or up to zero ;

     end "moving lines";

    return( true );			! give 'em what they came for ;

end "VM Move";


Internal Simple Boolean Procedure VMFile( String Spec; Integer Mode($Read) );
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMFile( StringSpec, AccessMode )				;
!		Opens a file for the specified access.  A positive	;
!		slot number is returned if the file is available.  A 	;
!		0 means no slots and a negative value means there was	;
!		some file error or the file is not available.		;
!									;
! ----------------------------------------------------------------------;
begin "VM File"
    Own Safe Integer Array File[ 0 : !RBLIC ];
    Preset!with '17, cvsix("DSK   "), 0;
    Own Safe Integer Array Dev[ 0 : 2 ];
    Own Integer Slot;

    If not( Slot_ VMSlot )		! If no Slots available ;
     then return( false );		!  then no file opened ;

    If not( S_ Files[ Slot ] )		! slot assigned? *Debug check* ;
     then return( false );		!  not this time *huh why not* ;

    If not( VMSpec( Spec ) )		! trouble with the spec? ;
     then return( false );		!  then don't do anything ;

    If not($Read leq Mode leq $Multi)	! if an invalid mode ;
     then return( false );		! $Read,$Write,$Update,$Multi ;

    Dev[ 1 ]_ FileSpec[ S!Dev ];	! Setup device block ;
    Chnior( F:Chan[S],Dev[0],!chOPN );	! OPEN [ '17, Dev, 0 ] ;
    If not( !Skip! )			! If open-failure ;
     then begin "open failure"		!  then no file opened ;
	VMFree( Slot );			! Free the slot ;
	return( !Xwd( -1,-1 ) );	!  and return ;
     end "open failure";

    File[ !RBCNT ]_ !RBLIC;		! Setup file lookup block ;
    File[ !RBPPN ]_ location( FileSpec[ S!Usr ] );
    File[ !RBNAM ]_ FileSpec[ S!Nam ];
    File[ !RBEXT ]_ FileSpec[ S!Ext ] land (-1 lsh 18);

    If ( $Write neq F:Mode[ S ]_ Mode )	! if mode neq $Write, do lookup ;
     then begin "read update"

	Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
	If not( !Skip! ) and ( 0 = !rh(File[!RBEXT]) )
	 then begin "not found"		! no skip and file not found ;
	    If ( $Read neq Mode )	! if mode neq $Read, do create ;
	     then begin "update stuff"

		Chnior( F:Chan[ S ], File[ !RBCNT ], !chENT );
		if ( !Skip! )		! enter ok, so close & lookup ;
		 then begin "ok find it"
		    Chnior( F:Chan[ S ], memory[0], !chCLS );
		    Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
		 end "ok find it";

	     end "update stuff";	! if !skip! found or created file ;
	 end "not found";		!  else some other file error ;

	if not( !Skip! )		! lookups failed - not ERFNF% ;
	 then begin "huh what's up"	! unless happened 2nd time ;
	    VMFree( Slot );		! so, clear out and return ;
	    return( !Xwd( -1,!rh(File[!RBEXT]) ) );
	 end "huh what's up";

     end "read update";			! have old file, or new file ;

    If ( $Read neq Mode )		! for $Write, $Update, $Multi ;
     then Chnior( F:Chan[ S ], File[ !RBCNT ],
		   if (Mode = $Multi)	! if mode eql $Multi ;
		     then !chMEN	!  then use multiple enter ;
		     else !chENT );	!  else use normal enter ;

    If not( !Skip! )			! If lookup-enter failure ;
     then begin "no file or access"	!  then Free the slot ;
	VMFree( Slot );			!  and return error code ;
	return( !Xwd( -1,!rh(File[!RBEXT]) ) );
     end "no file or access";

    F:Size[ S ]_ File[ !RBSIZ ] * 5;	! File size in characters ;
    F:FLic[ S ]_ !rh( File[ !RBLIC ] );	! File license ;

    return( Slot );			! Return the slot number ;

end "VM File";

end "VM Package";
      2VMFILE.003   ?17-Jan-86 00:15:09  PUXMOZ    entry
	VMFile, VMFree, VMLine, VMText, VMMove,
	VMGetC, VMSetC, VMFLic, VMSetM
	define FT!InternalPages = True;
	Ifcr not FT!InternalPages thenc , VMInit endc

;

begin "VM Package"

  require "(SAILIB)SAIL.DEF"   source!file;
  require "(SAILIB)UUOSYM.DEF" source!file;

  redefine !Block(Group, Name, Size) = {
    Ifcr Length(Cvps(Size)) = 0 thenc assignc Size = 1; Endc
    Define Group}&{Name = Group;
    Redefine Group = Group + Size;};

    Define S! = 0;			! ** Filespec block offsets ** ;
    !Block( S!,Dev )			! Device ;
    !Block( S!,Usr,2 )			! Username ;
    !Block( S!,Nam )			! Name ;
    !Block( S!,Ext )			! Extension ;

    Define  VM$ = 0;			! ** Access Modes ** ;
    !Block( VM$,Read )			! Read Only ;
    !Block( VM$,Write )			! Write/Supersede ;
    !Block( VM$,Update )		! Write/Update (used for append) ;
    !Block( VM$,Multi )			! Multi-access Write/Update ;

    ReDefine  VM$ = 0;			! ** Characteristic Indicies ** ;
    !Block( VM$,Char )			! Character position ;
    !Block( VM$,Line )			! Line position ;
    !Block( VM$,Page )			! Page position ;
    !Block( VM$,Msg )			! Message position ;
    !Block( VM$,Eol )			! End of Line terminator ;
    !Block( VM$,ECR )			! End of Line CR seen ;
    !Block( VM$,Size )			! Size of file in Characters ;
    !Block( VM$,LSize )			! Size of file in Lines-1 ;
    !Block( VM$,PSize )			! Size of file in Pages-1 ;
    !Block( VM$,MSize )			! Size of file in Messages-1 ;
    !Block( VM$,Lic )			! File license ;
    !Block( VM$,Access )		! File access mode ;
    !Block( VM$,Time )			! File creation time in seconds ;
    !Block( VM$,Date )			! File creation date ;


  Define
	MinChan = 1			! lowest channel to use ;
  ,	MaxChan = 47			! highest available ;
  ,	MaxSlot = MaxChan - MinChan + 1	! number of available slots ;
  ,	MemMax  = MaxSlot * 512		! pages in words ;
  ,	CharPerPage = 512 * 5		! characters per page ;
  ,	BackByte    = '430000000001	! offset to backup a byte ;
  ,	AddaByte    = '070000000000	! offset to increment byte ;
  ;



  Record!Class F (  Integer Page;	! memory page to use ;
		    Integer File;	! file page in use ;
		    Integer Chan;	! channel for file open ;
		    Integer Mode;	! file access mode ;
		    Integer Char;	! character pointer in file ;
		    Integer Line;	! line pointer in file +/-;
		    Integer PTxt;	! text page pointer in file +/- ;
		    Integer MTxt;	! text message pointer in file +/- ;
		    Integer Last;	! last eol character ;
		    Integer CRet;	! carriage return on line ;
		    Integer Size;	! character size of file ;
		    Integer LSiz;	! lines in file (if known) ;
		    Integer PSiz;	! pages in file (if known) ;
		    Integer MSiz;	! messages in file (if known) ;
		    Integer FLic;	! file license info ;
		    Integer Time;	! file creation time in seconds ;
		    Integer Date    );	! file creation date ;

  R!P (F) S;
  Safe R!P (F) Array Files[ 1 : MaxSlot ];

  Integer VMBase, VMPage;			! virtual memory pointers  ;
  Integer MaxSlots;				! remember available slots ;

  Own Safe Integer Array FileSpec[ S!Dev : S!Ext ];

 Ifcr FT!InternalPages thenc			! selectable by feature sw ;
  Preset!with [ MemMax + 512 ] 0;		! expect to use 1 : MemMax ;
  Own Safe Integer Array VM[ 1 : MemMax+512 ];	!  entries minus page slop ;
 endc


Ifcr FT!InternalPages thenc
  Simple Procedure InitStuff;
elsec
  Internal Simple Procedure VMInit( Integer Page, Count );
endc
! ----------------------------------------------------------------------;
!									;
!	InitStuff							;
!		Routine to initialize data structures and calculate	;
!		where to put the initial cache of pages to use for	;
!		this venture.						;
!									;
!	VMInit( FirstPage, Count )					;
!		Routine to setup a cache of pages for the user to use	;
!		instead of using the preset range designated by this	;
!		package.  This is setup via the assembly parameter:	;
!		(FT!InternalPages).					;
!									;
! ----------------------------------------------------------------------;
begin "VM Init"

  Ifcr FT!InternalPages thenc		! internal definition ;
    VMPage_ (location( VM[1] ) + '777) lsh -9;
    MaxSlots_ MaxSlot;			! count of pages ;
  elsec
    VMPage_ Page;			! base page ;
    MaxSlots_ Count max MaxSlot;	! count of pages ;
  endc
    VMBase_ VMPage lsh 9;		! base memory address ;

    ArrClr( Files );			! files not open ;

end "VM Init";
Ifcr FT!InternalPages thenc
  require InitStuff initialization;
endc


Internal Simple Integer Procedure VMMaxS( Integer Count );
! ----------------------------------------------------------------------;
!									;
!	NewCount_ VMMaxS( Count )					;
!		Routine to limit the maximum number of slots to use	;
!		in this package.  Useful to insure that specifically	;
!		allocated channels between the top of SAILs channel	;
!		range and those used by VMFILE are not used.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Max Slots"

    return( MaxSlots_ Count max MaxSlot );	! count of pages ;

end "VM Max Slots";


Simple Integer Procedure MapPage( r!p (F) Rec; Integer NewPage );
! ----------------------------------------------------------------------;
!									;
!	MapPage( Rec, NewPage )						;
!		Routine to map the specified new file-page into the	;
!		page designated by F:Page[Rec] and update F:File[Rec]	;
!		to NewPage.						;
!									;
! ----------------------------------------------------------------------;
begin "Map Page"
    Own safe integer array Arg[ 0:1 ];
    Own integer Status, Err;

    If ( F:File[Rec] = NewPage )		! if the same page ;
     then begin "check protection"

	If not( F:Mode[Rec] )			! if no writing request ;
	 then return( NewPage );		! then nothing special ;
	Status_Calli(F:Page[Rec],calli!PAGSTS);	! read page protection ;
	If ( '3 = ( Status land '7 ) )		! if read/write? ;
	 then return( NewPage );		!  then nothing to do ;
	Err_ Calli( !Xwd( '6001,F:Page[Rec] ), calli!VPROT );
	If ( !skip! )				! if no problems, return! ;
	 then return( NewPage )			!  nothing else to do ;
	 else begin				! otherwise complain and ;
	    Print( "Map error: ",cvos(Err)," pagsts: ",cvos(Status),crlf );
	    return( F:File[Rec]_ 0 );		! make believe un-mapped ;
	 end;

     end "check protection";

    Calli( Arg[0]_ !Xwd('2001,F:Page[Rec]), calli!VCLEAR );
    If ( VM$Read neq F:Mode[Rec] )		! if we're writing then ;
     then Arg[0]_ !Xwd('6001,F:Page[Rec]);	!  make it .prrw not .prro ;
    Arg[1]_ NewPage;				! point at file page ;
    Chnior( F:Chan[Rec], Arg[0], !chMFP );	! map the page ;
    Start!code MOVEM '3,ERR; end;		! remember any errors ;

    If ( !Skip! )				! remember file page ;
     then F:File[Rec]_ NewPage			!  NewPage (if map ok) ;
     else begin "map failure"			! else check the fault ;
	F:File[Rec]_ 0;				! default (if map fails) ;

	If ( F:Mode[Rec] ) and ( !rh(ERR)='6 )	! if writing and FLPHP% ;
	 then begin "create page"		!  then try to create it ;

	    Chnior( F:Chan[Rec], NewPage, !chCFP );
	    If ( !Skip! )			! check success flag ;
	     then begin "try map again"		! if ok, then try map ;
		Chnior( F:Chan[Rec], Arg[0], !chMFP );
		if ( !Skip! )			! any errors? ;
		 then F:File[Rec]_ NewPage;	! no, it's ok ;
	     end "try map again";

	 end "create page";
     end "map failure";

    return( F:File[Rec] );			! return current mapping ;

end "Map Page";


Simple Integer Procedure Dbp( Reference Integer Ptr );
! ----------------------------------------------------------------------;
!									;
!	Dbp( AsciiBytePointer )						;
!		Routine to decrement a 7-bit byte pointer.  Its only	;
!		magic relies on the assumption that a negative pointer	;
!		is setup as '440700 from the point/bbpp operation that	;
!		creates a ildb pointer to the first byte of the word.	;
!		This routine fixes this to point to the last byte of	;
!		the previous word whenever this is seen.  In "this"	;
!		initial case, this works so that the pointer is never	;
!		decremented the WRONG way.				;
!									;
! ----------------------------------------------------------------------;
begin "Decrement Byte Pointer"

    If ( Ptr < 0 )			! initially '440700,,addr ;
     then Ptr_ Ptr - BackByte		! so set to prev-last byte ;
     else Ptr_ Ptr + AddaByte;		! else decrement a byte ;

    If ( Ptr < 0 )			! must now be '440700,,addr ;
     then Ptr_ Ptr - BackByte;		! so set to prev-last byte ;

    return( Ptr );			! so it can be an expression ;

end "Decrement Byte Pointer";


Simple Integer procedure GetText( Reference string Line;
				  Integer Byte, Count; String Chars );
begin "get text"
    Own integer wp;
    String Str;

    while ( length( Line ) )
     do begin "get data"

	Str_ Chars;				! copy break chars ;
	while ( length( Str ) )			! if any break chars ;
	 do if ( Line = Lop( Str ) )		!  and match a brk ;
	     then return( Line );		!  return that character ;

	if ( 0 leq count_ count - 1 )		! if room left in string ;
	 then if ( "a" leq wp_lop(Line) )	!  then check case ;
	       then idpb( wp-'100, byte )	!    lowercase to sixbit ;
	       else idpb( wp-'40, byte )	!    uppercase to sixbit ;
	 else wp_ lop( Line );			!  throw away extras ;

     end "get data";

    return( 0 );				! no line left? ;

end "get text";


Simple Boolean Procedure VMSpec( String Line );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMSpec( FileSpecification )					;
!		Routine to read a string file specification and build	;
!		the special file block used by the VMFile routine.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Spec"

    arrclr( filespec );				! clear out the array ;

    GetText( Line, point( 6,filespec[S!Nam],-1 ), 6, ":(." );

    if ( ":" = Line )				! it was a device, good! ;
     then begin
	lop( Line );				! throw away the colon and ;
	filespec[S!Dev] swap filespec[S!Nam];	! swap data to right places ;
     end
     else filespec[S!Dev]_cvsix("DSK");		!  and fill in the device ;

    if ( "(" = Line )				! if it starts with "(" ;
     then begin "get user"			!  then pick up username ;
	lop( Line );				!    eat the "(" ;
	GetText( Line, point( 6,filespec[ S!Usr ],-1 ), 12, ")" );
	lop( Line );				!    eat the ")" ;
     end "get user"
     else begin "default user"			! set default if no user ;
	filespec[ S!Usr   ]_ calli( '31, '41 );	! .GTNM1 (GFD user 1-6)  ;
	filespec[ S!Usr+1 ]_ calli( '32, '41 );	! .GTNM2 (GFD user 7-12) ;
	If not( !Skip! )			! set blank if GETTAB fails ;
	 then filespec[ S!Usr ]_ filespec[ S!Usr+1 ]_ 0;
     end "default user";

    if not( length( Line ) or filespec[S!Nam] )	! must have a name ;
     then return( false );			!  so return false ;

    if not( "." = Line or filespec[S!Nam] )
     then GetText( Line, point( 6,filespec[ S!Nam ],-1 ), 6, "." );

    if not( filespec[S!Nam] )			! seen anyone ;
     then return( false );			! no, go home ;

    if ( "." = Line )				! if dot seen ;
     then begin "get ext"
	lop( Line );				!  then chop it off ;
	GetText( Line, point( 6,filespec[ S!Ext ],-1 ), 3, " "&'11 );
     end "get ext";

    return( true );				! got here, return ok ;

end "VM Spec";


Simple Integer Procedure VMSlot;
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMSlot							;
!		Returns the next available file slot in the internal	;
!		file table.  If no slots or channels are available,	;
!		returns 0.  Array Files[slot] is setup with F:Chan,	;
!		F:Page and F:Char.					;
!									;
! ----------------------------------------------------------------------;
begin "VM Slot"
    Own Integer Slot;

    For Slot_ 1 upto MaxSlots		! check each legal slot ;
     do if not( Files[ Slot ] )		! if it's free ;
	 then begin "setup slot"	!  then make it available ;

	    S_ Files[ Slot ]_ new!record( F );	! initialize record ;
	    F:Chan[ S ]_ MaxChan - Slot + 1;	! file channel ;
	    F:Page[ S ]_ VMPage  + Slot - 1;	! memory page ;
	    F:File[ S ]_ F:Char[ S ]_ -1;	! file/char position ;

	    S_ null!record;		! free up working pointer ;

	    return( Slot );		! give caller a slot number ;

	 end "setup slot";

    return( 0 );

end "VM Slot";


Internal Simple Integer Procedure VMFLic( Integer Slot );
! ----------------------------------------------------------------------;
!									;
!	License_ VMFLic							;
!		Routine to return the license that was set on the 	;
!		file open on the specified slot.			;
!									;
! ----------------------------------------------------------------------;
begin  "VM File Lic"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    return( F:FLic[ S ] );		! return the license ;

end "VM File Lic";


Internal Simple Integer Procedure VMGetC( Integer Slot, Index(VM$Char) );
! ----------------------------------------------------------------------;
!									;
!	Position_ VMGetC( Slot, Index(VM$Char) )			;
!		Read the specified characteristic from the file table.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Get Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( -2 );			!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( -2 );			!  not this time ;

    Case Index of begin
	[VM$Char]   return( F:Char[ S ] );	! return character position ;
	[VM$Line]   return( F:Line[ S ] );	! return line position ;
	[VM$Page]   return( F:PTxt[ S ] );	! return page position ;
	[VM$Msg]    return( F:MTxt[ S ] );	! return message position ;
	[VM$Eol]    return( F:Last[ S ] );	! return last eol char ;
	[VM$ECR]    return( F:CRet[ S ] );	! return last cr on line ;
	[VM$Size]   return( F:Size[ S ] );	! return file size in chars ;
	[VM$LSize]  return( F:LSiz[ S ] );	! return file size in lines ;
	[VM$PSize]  return( F:PSiz[ S ] );	! return file size in pages ;
	[VM$MSize]  return( F:MSiz[ S ] );	! return file size in msgs ;
	[VM$Lic]    return( F:FLic[ S ] );	! return file license ;
	[VM$Access] return( F:Mode[ S ] );	! return file access mode ;
	[VM$Time]   return( F:Time[ S ] );	! return file creation time ;
	[VM$Date]   return( F:Date[ S ] );	! return file creation date ;
	[else]      return( -3 )		! illegal index ;
    end;

end "VM Get Character Pointer";



Internal Simple Integer Procedure VMSetC( Integer Slot, Position );
! ----------------------------------------------------------------------;
!									;
!	NewPosition_ VMSetC( Slot, TrialPosition )			;
!		Set the character position with the file open on the	;
!		specified slot.  All further references to the slot	;
!		will use the new file position.  If the specified	;
!		position is outside the file, the position is set to	;
!		-1.  The routine always returns the new position.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Set Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( 0 leq Position leq F:Size[S] )	! if position within range ;
     then F:Char[S]_ Position		!  then set it up ;
     else F:Char[S]_ Position_ -1;	!  else set to -1 ;

    return( Position );			! return the new position ;

end "VM Set Character Pointer";


Internal Simple Boolean Procedure VMFree( Integer Slot, Bits(0) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMFree( Slot )						;
!		Closes any open file for this slot and frees the	;
!		slot for future use.  Returns true if the slot was	;
!		in use.							;
!									;
! ----------------------------------------------------------------------;
begin "VM Free"
    preset!with 0,0,0,0;
    Own integer array delete[0:3];

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( F:Char[ S ] neq -1 )		! if file mapped, clear page ;
     then Calli( !Xwd( '2001, F:Page[ S ] ), calli!VCLEAR );

    If ( F:Mode[ S ] )			! if any writes ;
     then begin "some changes"		!  reset size & close file ;

	If ( F:Size[ S ] > 0 )		! if non-zero size ;
	 then Chniov( F:Chan[S], (F:Size[S]+4) div 5, !chFTR );
	if ( Bits = -1 )		! Special "RENAME" ;
	 then Chnior( F:Chan[S], Delete[0], !chREN );
	Chnior( F:Chan[ S ], memory[Bits], !chCLS );

     end "some changes";

    Chniov( F:Chan[ S ], 0, !chREL );	! release Slot ;
    Files[ Slot ]_ null!record;		! clear out tables ;

    return( true );			! everything is ok ;

end "VM Free";


Internal String Procedure VMLine( Integer Slot; Reference Integer More;
				  Integer Dir( 0 ) );
! ----------------------------------------------------------------------;
!									;
!	Line_ VMLine( Slot, More, Dir(0) )				;
!		Returns the next consecutive line from the file that	;
!		is connected to the specified slot.  More is set to	;
!		the line terminator (LF, FF, VT, CR or EOT) or to 0	;
!		when the end of the file is reached or the slot is 	;
!		inactive.  Dir is the direction to read the file ( 0	;
!	 	indicates forward, -1 or non-zero for backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Line"
    Integer Page, Byte, Copy, Count, Len, Last;
    Boolean Eol;
    String Str;

    More_ 0;				! Initialize for bad exits ;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( null );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( null );		!  not this time ;

    If ( Dir )				! verify proper usage of Dir ;
     then Dir_ -1			!  non-zero = backward = -1 ;
     else Dir_ +1;			!  was-zero = forward  = +1 ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then If ( Dir < 0 )		! Forward or Backward? ;
	   then F:Char[S]_ F:Size[S]	!   Set after last character ;
	   else F:Char[S]_ 0;		!   Set before first character ;

    If ( F:File[S] neq Page_ ( F:Char[S] div CharPerPage ) + 1 )
     then if not( MapPage( S, Page ) )	! Verify using right page ;
	   then return( null );		!  and page gets mapped ;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Copy_Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);
    If ( Byte < 0 )			! Means we have '440700,,x ;
     then Copy_ Byte_ Byte - BackByte;	! Point at an actual byte ;
    If ( Dir < 0 )			! If backward direction ;
     then Ibp( Copy );			!  then setup for Dbp by 1 ;

    Str_ Null;				! Initial return string ;

    If ( Dir geq 0 )			!   Fix count (# left) ;
     then If ( ( F:File[S] * CharPerPage ) > F:Size[S] )
	   then Count_ (F:Size[S] mod CharPerPage) - Count
	   else Count_ CharPerPage - Count;

    Len_ 0;				! Initialize string length ;
    F:Last[S]_ F:CRet[S]_ 0;		! Initialize break vars ;
    Last_ -1;				! Last character seen ;
    Eol_ false;				! Initialize line var ;
    While not( Eol )			! Read one line ;
     do begin "one line"

	If ( Count > 0 )		! Must have chars left ;
	 then begin "more characters"	!  to even try to read ;

	    If ( Dir < 0 )		! Forward or Backward? ;
	     then Dbp( Copy )		!  position the character ;
	     else Ibp( Copy );		!  pointer in the page ;

	    F:Char[S]_ F:Char[S] + Dir;	! Update file character count ;

	    Case More_ Ldb( Copy ) of begin	! check for end of line ;
		[#nul] begin "found eos break"
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    If ( Dir < 0 ) and		! Backing up? ;
		       not( F:Last[S] )		! First time through? ;
		     then Dbp( Byte )		!  yes, keep it this way ;
		     else Byte_ Copy;		!  no, update pointer ;
		    Len_ 0;			! Reset string length ;
		 end "found eos break";

		[#cr] begin "found return"
		    If ( Dir < 0 )
		     then if ( #LF leq Last leq #FF )
			   then F:CRet[S]_ #CR	! remember we saw this ;
			   else begin "lone cr"
			      If ( Copy = Byte )	! if first char ;
			       then F:Last[S]_ More	!  remember and go ;
			       else begin "eol cr"	! else do eol stuff ;
				 Eol_ true;		! set end of line ;
				 More_ F:Last[S];	! and get last one ;
				 F:Char[S]_ F:Char[S]+1	! bump pointer by 1 ;
			       end "eol cr";
			   end "lone cr";
		    If ( ( Dir > 0 ) and ( #CR = Last ) )
		     then Eol_ true;		! flag as end of line ;
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    Byte_ Copy;			! synchronize pointers ;
		    Len_ 0;			! Reset string length ;
		 end "found return";

		[#lf][#vt][#ff][#eot] begin "found eol break"
		    Eol_ true;			! looks like one? ;
		    if ( Dir < 0 )		! were we going backward? ;
		     then if ( Copy = Byte )	!  and the first character ;
			   then begin "not eol"
			      Eol_ false;	!  yes, not really eol ;
			      F:Last[S]_ More;	!  remember this for later ;
			      F:Line[S]_ F:Line[S] + Dir;	! each line ;
			      If ( More = #FF )			! each FF ;
			       then F:PTxt[S]_ F:PTxt[S] + Dir;	! text page ;
			      If ( More = #EOT )		! each EOT ;
			       then F:MTxt[S]_ F:MTxt[S] + Dir;	! message ;
			   end "not eol"
			   else begin "got eol"
			      F:Char[S]_ F:Char[S] + 1;		! each char ;
			      More_ F:Last[S];			! eol-brk ;
			   end "got eol"
		     else begin "forward eol"
			If ( Last = #CR ) and ( #LF leq More leq #FF )
			 then F:CRet[S]_ Last;		! mark CR before Brk ;
			If ( More = #FF )		! for each FF seen ;
			 then F:PTxt[S]_ F:PTxt[S]+Dir;	!  count a text page ;
			If ( More = #EOT )		! for each EOT seen ;
			 then F:MTxt[S]_ F:MTxt[S]+Dir;	!  count a text message ;
			F:Line[S]_ F:Line[S] + Dir;	! count each line ;
		     end "forward eol";
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		 end "found eol break";

		[else] begin "normal character"
		    If ( Last = #CR ) and ( Dir > 0 )
		     then begin "lonely cr"	! else do eol stuff ;
			Eol_ true;		! set end of line ;
			F:Char[S]_ F:Char[S]-1;	! bump pointer by 1 ;
			More_ #CR;		! set eol to CR ;
			If ( Len )		! length to concatenate? ;
			 then Str_ Str & StMake( Byte, Len );
		     end "lonely cr"
		     else Len_ Len + 1		!  increment string length ;
		 end "normal character"
	    end;

	    If ( memory[ !rh( copy ) ] land 1 )	! bit 35 set ;
	     then begin "sequence numbers"	! in this word? ;

		If ( Dir < 0 )
		 then begin "seq backward"
		    F:Char[S]_ F:Char[S] - 4;	! tab already seen backwards ;
		    Count_ Count - 4;		!  update counts by 4 chars ;
		    If ( Len > 2 )
		     then begin "add text"	!  +1 for tab after seq # ;
			Ibp( Copy );		! make string skipping tab ;
			Str_ StMake( Copy, Len-2 ) & Str;
		     end "add text"
		 end "seq backward"
		 else begin "seq forward"
		    F:Char[S]_ F:Char[S] + 5;	! include tab in count here ;
		    Count_ Count - 5;		!  update counts by 5 chars ;
		    if ( Len neq 1 )
		     then Print( "*** Bad SEQ # in text file. ***"& Crlf );
		 end "seq forward";

		Byte_ Copy_ Copy + Dir;		!  update 1 word ;
		Len_ 0;				! Reset length ;

	     end "sequence numbers";

	    If ( 0 = Count_ (Count-1) max 0 )	! If now out of characters ;
	     then begin "fake eos break"
		If ( Len )			! length to concatenate? ;
		 then if ( Dir < 0 )
		       then Str_ StMake( Dbp( Copy ), Len ) & Str
		       else Str_ Str & StMake( Byte, Len );
		Len_ 0;				! Reset string length ;
	     end "fake eos break";

	    If ( More )				! if this is not a null ;
	     then Last_ More;			! last char for next time ;

	 end "more characters"
	 else begin "need next page"		! If no-more-characters ;

	    If ( F:Char[S] geq F:Size[S] )	! Forwards at end or ;
	       or ( F:Char[S] leq 0 )		!  backwards at beginning ;
	     then begin "end of file"		! At end-of-file? ;

		Eol_ true;			! Set flags true ;
		If ( Dir < 0 )			! If backing up ;
		 then More_ F:Last[S]		!  use last break at end ;
		 else begin "save info"
		    More_ 0;			!  set flag var to 0 ;
		    F:LSiz[S]_ F:Line[S];	!  save total size in lines ;
		    F:PSiz[S]_ F:PTxt[S];	!  save total size in pages ;
		    F:MSiz[S]_ F:MTxt[S];	!  save total size in pages ;
		 end "save info";
		Done "one line";		! Finish loop ;

	     end "end of file";			! Guess, read next page ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then return( null );		! error mapping! ;

	    ! ** assume: here at the beginning of the page ** ;
	    If ( Dir < 0 )			! Forward or Backward? ;
	     then Copy_ Byte_ point( 7, memory[(F:Page[S]+1) lsh 9], -1 )
	     else Copy_ Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );

	    If ( ( Page * CharPerPage ) > F:Size[S] )
	     then Count_ F:Size[S] mod CharPerPage
	     else Count_ CharPerPage;

	 end "need next page";

     end "one line";

    return( Str );			! give 'em what they came for ;

end "VM Line";


Internal Boolean Procedure VMText( Integer Slot; String Text );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMText( Slot, Text, Dir(0) )				;
!		Writes the next consecutive line or lines to the file	;
!		that is connected to the specified slot.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Text"
    Integer Page, Byte, Char, Count;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( F:Mode[S] )			! were we writing? ;
     then return( false );		! no, don't bother! ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then F:Char[S]_ 0;			!   Set before first character ;

    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
     then begin
	Print( "Page map error: p",page,"  c",F:Char[S],"  f",F:Chan[S],crlf );
	return( false );		! if no page, error return ;
     end;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);

    Count_ CharPerPage - Count;		! Fix count (# left) ;

    while ( length( Text ) )		! Must have some text left ;
     do begin "writing line"

	If ( Count > 0 )		! Must have room left on page ;
	 then begin "more characters"	!  to even try to write ;

	    If not( Char_ Lop( Text ) )	! if char = null then try next ;
	     then continue "writing line";

	    IDpb( Char, Byte );		! deposit byte at position ;
	    F:Char[S]_ F:Char[S] + 1;	! Update file character count ;

	    Case ( Char ) of begin	! check for end of line ;
		[#cr] F:CRet[S]_ #CR;	! remember we saw this ;

		[#lf][#vt][#ff][#eot] begin "count lines"
		  F:Last[S]_ Char;		! remember eol character ;
		  F:Line[S]_ F:Line[S] + 1;	! count lines seen ;
		  If ( Char = #FF )		! for each FF seen ;
		   then F:PTxt[S]_ F:PTxt[S]+1;	!  count a text page ;
		  If ( Char = #EOT )		! for each EOT seen ;
		   then F:MTxt[S]_ F:MTxt[S]+1;	!  count a text message ;
		 end "count lines";

		[else] F:CRet[S]_ 0	! forget we saw a cr ;
	     end;

	    Count_ (Count-1) max 0;	! keep character count ;

	 end "more characters"
	 else begin "need next page"	! If no-more-characters ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then begin
		Print( "Page(2) map error: ",page," ",F:Char[S],crlf );
		return( false );	! if no page, error return ;
	     end;

	    Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );
	    Count_ CharPerPage;		! always a full page to write in ;

	 end "need next page";

     end "writing line";

    If ( F:Char[S] geq F:Size[S] )	! At or Past end of file? ;
     then begin "end of file"

	F:Size[S]_ F:Char[S];		!  save size in characters ;
	F:LSiz[S]_ F:Line[S];		!  save total size in lines ;
	F:PSiz[S]_ F:PTxt[S];		!  save total size in pages ;
	F:MSiz[S]_ F:MTxt[S];		!  save total size in pages ;

     end "end of file";			! Guess, read next page ;

    return( true );			! give 'em what they came for ;

end "VM Text";


Internal Boolean Procedure VMMove( Integer Slot, HowMany(1) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMMove( Slot, HowMany(1) )					;
!		Moves the position pointer forward or backward up to	;
!		HowMany lines in the file.  Returns true if the slot is	;
!		active and HowMany lines exist, otherwise it returns	;
!		false and leaves the pointer positioned at logical end	;
!		of file (at the beginning if direction is backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Move"
    Own Integer Brk;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( HowMany )			! we can always move ;
     then return( true );		!  a distance of 0 ;

    while ( HowMany )			! while lines to go read them ;
     do begin "moving lines"

	If not( length( VMLine( Slot, Brk, HowMany < 0 ) ) or Brk )
	 then return( false );		!  then take the cows to town ;

	If ( HowMany > 0 )		! decrement the right direction ;
	 then HowMany_ HowMany - 1	!  down to zero  ;
	 else HowMany_ HowMany + 1;	!  or up to zero ;

     end "moving lines";

    return( true );			! give 'em what they came for ;

end "VM Move";


Internal Simple Boolean Procedure VMFile( String Spec; Integer Mode(VM$Read) );
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMFile( StringSpec, AccessMode )				;
!		Opens a file for the specified access.  A positive	;
!		slot number is returned if the file is available.  A 	;
!		0 means no slots and a negative value means there was	;
!		some file error or the file is not available.		;
!									;
! ----------------------------------------------------------------------;
begin "VM File"
    Own Safe Integer Array File[ 0 : !RBLIC ];
    Preset!with '17, cvsix("DSK   "), 0;
    Own Safe Integer Array Dev[ 0 : 2 ];
    Own Integer Slot;

    If not( Slot_ VMSlot )		! If no Slots available ;
     then return( false );		!  then no file opened ;

    If not( S_ Files[ Slot ] )		! slot assigned? *Debug check* ;
     then return( false );		!  not this time *huh why not* ;

    If not( VMSpec( Spec ) )		! trouble with the spec? ;
     then return( false );		!  then don't do anything ;

    If not(VM$Read leq Mode leq VM$Multi)	! if an invalid mode ;
     then return( false );		! Read, Write, Update, Multi ;

    Dev[ 1 ]_ FileSpec[ S!Dev ];	! Setup device block ;
    Chnior( F:Chan[S],Dev[0],!chOPN );	! OPEN [ '17, Dev, 0 ] ;
    If not( !Skip! )			! If open-failure ;
     then begin "open failure"		!  then no file opened ;
	VMFree( Slot );			! Free the slot ;
	return( !Xwd( -1,-1 ) );	!  and return ;
     end "open failure";

    arrclr( File );			! Clear out unused fields ;
    File[ !RBCNT ]_ !RBLIC;		! Setup file lookup block ;
    if ( FileSpec[ S!Usr ] )
     then File[ !RBPPN ]_ location( FileSpec[ S!Usr ] );
    File[ !RBNAM ]_ FileSpec[ S!Nam ];
    File[ !RBEXT ]_ FileSpec[ S!Ext ] land (-1 lsh 18);

    If ( VM$Write neq F:Mode[S]_ Mode )	! if mode neq VM$Write, do lookup ;
     then begin "read update"

	Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
	If not( !Skip! ) and ( 0 = !rh(File[!RBEXT]) )
	 then begin "not found"		! no skip and file not found ;
	    If ( VM$Read neq Mode )	! if mode neq VM$Read, do create ;
	     then begin "update stuff"

		Chnior( F:Chan[ S ], File[ !RBCNT ], !chENT );
		if ( !Skip! )		! enter ok, so close & lookup ;
		 then begin "ok find it"
		    Chnior( F:Chan[ S ], memory[0], !chCLS );
		    Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
		 end "ok find it";

	     end "update stuff";	! if !skip! found or created file ;
	 end "not found";		!  else some other file error ;

	if not( !Skip! )		! lookups failed - not ERFNF% ;
	 then begin "huh what's up"	! unless happened 2nd time ;
	    VMFree( Slot );		! so, clear out and return ;
	    return( !Xwd( -1,!rh(File[!RBEXT]) ) );
	 end "huh what's up";

     end "read update";			! have old file, or new file ;

    If ( VM$Read neq Mode )		! for VM$Write, VM$Update, VM$Multi ;
     then Chnior( F:Chan[ S ], File[ !RBCNT ],
		   if (Mode = VM$Multi)	! if mode eql VM$Multi ;
		     then !chMEN	!  then use multiple enter ;
		     else !chENT );	!  else use normal enter ;

    If not( !Skip! )			! If lookup-enter failure ;
     then begin "no file or access"	!  then Free the slot ;
	VMFree( Slot );			!  and return error code ;
	return( !Xwd( -1,!rh(File[!RBEXT]) ) );
     end "no file or access";

    F:Size[ S ]_ File[!RBSIZ] * 5;	! File size in characters (Rounded) ;
    F:FLic[ S ]_ !rh( File[!RBLIC] );	! File license ;

    F:Time[ S ]_ (((File[!RBPRV] lsh -12) land '3777) * 60 )
	       + ((File[!RBLIC] lsh -18) land '77);
    F:Date[ S ]_ (Ldb( Point( 2,File[!RBEXT],21 ) ) lsh 12)
	       + (File[!RBPRV] land '7777);

    return( Slot );			! Return the slot number ;

end "VM File";

end "VM Package";
     2VMFILE.004   ?17-Jan-86 00:15:09  PUXMOZ    entry
	VMFile, VMFree, VMLine, VMText, VMMove,
	VMGetC, VMSetC, VMFLic, VMSetM
	define FT!InternalPages = True;
	Ifcr not FT!InternalPages thenc , VMInit endc

;

begin "VM Package"

  require "(SAILIB)SAIL.DEF"   source!file;
  require "(SAILIB)UUOSYM.DEF" source!file;

  redefine !Block(Group, Name, Size) = {
    Ifcr Length(Cvps(Size)) = 0 thenc assignc Size = 1; Endc
    Define Group}&{Name = Group;
    Redefine Group = Group + Size;};

    Define S! = 0;			! ** Filespec block offsets ** ;
    !Block( S!,Dev )			! Device ;
    !Block( S!,Usr,2 )			! Username ;
    !Block( S!,Nam )			! Name ;
    !Block( S!,Ext )			! Extension ;

    Define  VM$ = 0;			! ** Access Modes ** ;
    !Block( VM$,Read )			! Read Only ;
    !Block( VM$,Write )			! Write/Supersede ;
    !Block( VM$,Update )		! Write/Update (used for append) ;
    !Block( VM$,Multi )			! Multi-access Write/Update ;

    ReDefine  VM$ = 0;			! ** Characteristic Indicies ** ;
    !Block( VM$,Char )			! Character position ;
    !Block( VM$,Line )			! Line position ;
    !Block( VM$,Page )			! Page position ;
    !Block( VM$,Msg )			! Message position ;
    !Block( VM$,Eol )			! End of Line terminator ;
    !Block( VM$,ECR )			! End of Line CR seen ;
    !Block( VM$,Size )			! Size of file in Characters ;
    !Block( VM$,LSize )			! Size of file in Lines-1 ;
    !Block( VM$,PSize )			! Size of file in Pages-1 ;
    !Block( VM$,MSize )			! Size of file in Messages-1 ;
    !Block( VM$,Lic )			! File license ;
    !Block( VM$,Access )		! File access mode ;
    !Block( VM$,Time )			! File creation time in seconds ;
    !Block( VM$,Date )			! File creation date ;


  Define
	MinChan = 1			! lowest channel to use ;
  ,	MaxChan = 47			! highest available ;
  ,	MaxSlot = MaxChan - MinChan + 1	! number of available slots ;
  ,	MemMax  = MaxSlot * 512		! pages in words ;
  ,	CharPerPage = 512 * 5		! characters per page ;
  ,	BackByte    = '430000000001	! offset to backup a byte ;
  ,	AddaByte    = '070000000000	! offset to increment byte ;
  ;



  Record!Class F (  Integer Page;	! memory page to use ;
		    Integer File;	! file page in use ;
		    Integer Chan;	! channel for file open ;
		    Integer Mode;	! file access mode ;
		    Integer Char;	! character pointer in file ;
		    Integer Line;	! line pointer in file +/-;
		    Integer PTxt;	! text page pointer in file +/- ;
		    Integer MTxt;	! text message pointer in file +/- ;
		    Integer Last;	! last eol character ;
		    Integer CRet;	! carriage return on line ;
		    Integer Size;	! character size of file ;
		    Integer LSiz;	! lines in file (if known) ;
		    Integer PSiz;	! pages in file (if known) ;
		    Integer MSiz;	! messages in file (if known) ;
		    Integer FLic;	! file license info ;
		    Integer Time;	! file creation time in seconds ;
		    Integer Date    );	! file creation date ;

  R!P (F) S;
  Safe R!P (F) Array Files[ 1 : MaxSlot ];

  Integer VMBase, VMPage;			! virtual memory pointers  ;
  Integer MaxSlots;				! remember available slots ;

  Own Safe Integer Array FileSpec[ S!Dev : S!Ext ];

 Ifcr FT!InternalPages thenc			! selectable by feature sw ;
  Preset!with [ MemMax + 512 ] 0;		! expect to use 1 : MemMax ;
  Own Safe Integer Array VM[ 1 : MemMax+512 ];	!  entries minus page slop ;
 endc


Ifcr FT!InternalPages thenc
  Simple Procedure InitStuff;
elsec
  Internal Simple Procedure VMInit( Integer Page, Count );
endc
! ----------------------------------------------------------------------;
!									;
!	InitStuff							;
!		Routine to initialize data structures and calculate	;
!		where to put the initial cache of pages to use for	;
!		this venture.						;
!									;
!	VMInit( FirstPage, Count )					;
!		Routine to setup a cache of pages for the user to use	;
!		instead of using the preset range designated by this	;
!		package.  This is setup via the assembly parameter:	;
!		(FT!InternalPages).					;
!									;
! ----------------------------------------------------------------------;
begin "VM Init"

  Ifcr FT!InternalPages thenc		! internal definition ;
    VMPage_ (location( VM[1] ) + '777) lsh -9;
    MaxSlots_ MaxSlot;			! count of pages ;
  elsec
    VMPage_ Page;			! base page ;
    MaxSlots_ Count max MaxSlot;	! count of pages ;
  endc
    VMBase_ VMPage lsh 9;		! base memory address ;

    ArrClr( Files );			! files not open ;

end "VM Init";
Ifcr FT!InternalPages thenc
  require InitStuff initialization;
endc


Internal Simple Integer Procedure VMMaxS( Integer Count );
! ----------------------------------------------------------------------;
!									;
!	NewCount_ VMMaxS( Count )					;
!		Routine to limit the maximum number of slots to use	;
!		in this package.  Useful to insure that specifically	;
!		allocated channels between the top of SAILs channel	;
!		range and those used by VMFILE are not used.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Max Slots"

    return( MaxSlots_ Count max MaxSlot );	! count of pages ;

end "VM Max Slots";


Simple Integer Procedure MapPage( r!p (F) Rec; Integer NewPage );
! ----------------------------------------------------------------------;
!									;
!	MapPage( Rec, NewPage )						;
!		Routine to map the specified new file-page into the	;
!		page designated by F:Page[Rec] and update F:File[Rec]	;
!		to NewPage.						;
!									;
! ----------------------------------------------------------------------;
begin "Map Page"
    Own safe integer array Arg[ 0:1 ];
    Own integer Status, Err;

    If ( F:File[Rec] = NewPage )		! if the same page ;
     then begin "check protection"

	If not( F:Mode[Rec] )			! if no writing request ;
	 then return( NewPage );		! then nothing special ;
	Status_Calli(F:Page[Rec],calli!PAGSTS);	! read page protection ;
	If ( '3 = ( Status land '7 ) )		! if read/write? ;
	 then return( NewPage );		!  then nothing to do ;
	Err_ Calli( !Xwd( '6001,F:Page[Rec] ), calli!VPROT );
	If ( !skip! )				! if no problems, return! ;
	 then return( NewPage )			!  nothing else to do ;
	 else begin				! otherwise complain and ;
	    Print( "Map error: ",cvos(Err)," pagsts: ",cvos(Status),crlf );
	    return( F:File[Rec]_ 0 );		! make believe un-mapped ;
	 end;

     end "check protection";

    Calli( Arg[0]_ !Xwd('2001,F:Page[Rec]), calli!VCLEAR );
    If ( VM$Read neq F:Mode[Rec] )		! if we're writing then ;
     then Arg[0]_ !Xwd('6001,F:Page[Rec]);	!  make it .prrw not .prro ;
    Arg[1]_ NewPage;				! point at file page ;
    Chnior( F:Chan[Rec], Arg[0], !chMFP );	! map the page ;
    Start!code MOVEM '3,ERR; end;		! remember any errors ;

    If ( !Skip! )				! remember file page ;
     then F:File[Rec]_ NewPage			!  NewPage (if map ok) ;
     else begin "map failure"			! else check the fault ;
	F:File[Rec]_ 0;				! default (if map fails) ;

	If ( F:Mode[Rec] ) and ( !rh(ERR)='6 )	! if writing and FLPHP% ;
	 then begin "create page"		!  then try to create it ;

	    Chnior( F:Chan[Rec], NewPage, !chCFP );
	    If ( !Skip! )			! check success flag ;
	     then begin "try map again"		! if ok, then try map ;
		Chnior( F:Chan[Rec], Arg[0], !chMFP );
		if ( !Skip! )			! any errors? ;
		 then F:File[Rec]_ NewPage;	! no, it's ok ;
	     end "try map again";

	 end "create page";
     end "map failure";

    return( F:File[Rec] );			! return current mapping ;

end "Map Page";


Simple Integer Procedure Dbp( Reference Integer Ptr );
! ----------------------------------------------------------------------;
!									;
!	Dbp( AsciiBytePointer )						;
!		Routine to decrement a 7-bit byte pointer.  Its only	;
!		magic relies on the assumption that a negative pointer	;
!		is setup as '440700 from the point/bbpp operation that	;
!		creates a ildb pointer to the first byte of the word.	;
!		This routine fixes this to point to the last byte of	;
!		the previous word whenever this is seen.  In "this"	;
!		initial case, this works so that the pointer is never	;
!		decremented the WRONG way.				;
!									;
! ----------------------------------------------------------------------;
begin "Decrement Byte Pointer"

    If ( Ptr < 0 )			! initially '440700,,addr ;
     then Ptr_ Ptr - BackByte		! so set to prev-last byte ;
     else Ptr_ Ptr + AddaByte;		! else decrement a byte ;

    If ( Ptr < 0 )			! must now be '440700,,addr ;
     then Ptr_ Ptr - BackByte;		! so set to prev-last byte ;

    return( Ptr );			! so it can be an expression ;

end "Decrement Byte Pointer";


Simple Integer procedure GetText( Reference string Line;
				  Integer Byte, Count; String Chars );
begin "get text"
    Own integer wp;
    String Str;

    while ( length( Line ) )
     do begin "get data"

	Str_ Chars;				! copy break chars ;
	while ( length( Str ) )			! if any break chars ;
	 do if ( Line = Lop( Str ) )		!  and match a brk ;
	     then return( Line );		!  return that character ;

	if ( 0 leq count_ count - 1 )		! if room left in string ;
	 then if ( "a" leq wp_lop(Line) )	!  then check case ;
	       then idpb( wp-'100, byte )	!    lowercase to sixbit ;
	       else idpb( wp-'40, byte )	!    uppercase to sixbit ;
	 else wp_ lop( Line );			!  throw away extras ;

     end "get data";

    return( 0 );				! no line left? ;

end "get text";


Simple Boolean Procedure VMSpec( String Line );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMSpec( FileSpecification )					;
!		Routine to read a string file specification and build	;
!		the special file block used by the VMFile routine.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Spec"

    arrclr( filespec );				! clear out the array ;

    GetText( Line, point( 6,filespec[S!Nam],-1 ), 6, ":(." );

    if ( ":" = Line )				! it was a device, good! ;
     then begin
	lop( Line );				! throw away the colon and ;
	filespec[S!Dev] swap filespec[S!Nam];	! swap data to right places ;
     end
     else filespec[S!Dev]_cvsix("DSK");		!  and fill in the device ;

    if ( "(" = Line )				! if it starts with "(" ;
     then begin "get user"			!  then pick up username ;
	lop( Line );				!    eat the "(" ;
	GetText( Line, point( 6,filespec[ S!Usr ],-1 ), 12, ")" );
	lop( Line );				!    eat the ")" ;
     end "get user"
     else begin "default user"			! set default if no user ;
	filespec[ S!Usr   ]_ calli( '31, '41 );	! .GTNM1 (GFD user 1-6)  ;
	filespec[ S!Usr+1 ]_ calli( '32, '41 );	! .GTNM2 (GFD user 7-12) ;
	If not( !Skip! )			! set blank if GETTAB fails ;
	 then filespec[ S!Usr ]_ filespec[ S!Usr+1 ]_ 0;
     end "default user";

    if not( length( Line ) or filespec[S!Nam] )	! must have a name ;
     then return( false );			!  so return false ;

    if not( "." = Line or filespec[S!Nam] )
     then GetText( Line, point( 6,filespec[ S!Nam ],-1 ), 6, "." );

    if not( filespec[S!Nam] )			! seen anyone ;
     then return( false );			! no, go home ;

    if ( "." = Line )				! if dot seen ;
     then begin "get ext"
	lop( Line );				!  then chop it off ;
	GetText( Line, point( 6,filespec[ S!Ext ],-1 ), 3, " "&'11 );
     end "get ext";

    return( true );				! got here, return ok ;

end "VM Spec";


Simple Integer Procedure VMSlot;
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMSlot							;
!		Returns the next available file slot in the internal	;
!		file table.  If no slots or channels are available,	;
!		returns 0.  Array Files[slot] is setup with F:Chan,	;
!		F:Page and F:Char.					;
!									;
! ----------------------------------------------------------------------;
begin "VM Slot"
    Own Integer Slot;

    For Slot_ 1 upto MaxSlots		! check each legal slot ;
     do if not( Files[ Slot ] )		! if it's free ;
	 then begin "setup slot"	!  then make it available ;

	    S_ Files[ Slot ]_ new!record( F );	! initialize record ;
	    F:Chan[ S ]_ MaxChan - Slot + 1;	! file channel ;
	    F:Page[ S ]_ VMPage  + Slot - 1;	! memory page ;
	    F:File[ S ]_ F:Char[ S ]_ -1;	! file/char position ;

	    S_ null!record;		! free up working pointer ;

	    return( Slot );		! give caller a slot number ;

	 end "setup slot";

    return( 0 );

end "VM Slot";


Internal Simple Integer Procedure VMFLic( Integer Slot );
! ----------------------------------------------------------------------;
!									;
!	License_ VMFLic							;
!		Routine to return the license that was set on the 	;
!		file open on the specified slot.			;
!									;
! ----------------------------------------------------------------------;
begin  "VM File Lic"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    return( F:FLic[ S ] );		! return the license ;

end "VM File Lic";


Internal Simple Integer Procedure VMGetC( Integer Slot, Index(VM$Char) );
! ----------------------------------------------------------------------;
!									;
!	Position_ VMGetC( Slot, Index(VM$Char) )			;
!		Read the specified characteristic from the file table.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Get Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( -2 );			!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( -2 );			!  not this time ;

    Case Index of begin
	[VM$Char]   return( F:Char[ S ] );	! return character position ;
	[VM$Line]   return( F:Line[ S ] );	! return line position ;
	[VM$Page]   return( F:PTxt[ S ] );	! return page position ;
	[VM$Msg]    return( F:MTxt[ S ] );	! return message position ;
	[VM$Eol]    return( F:Last[ S ] );	! return last eol char ;
	[VM$ECR]    return( F:CRet[ S ] );	! return last cr on line ;
	[VM$Size]   return( F:Size[ S ] );	! return file size in chars ;
	[VM$LSize]  return( F:LSiz[ S ] );	! return file size in lines ;
	[VM$PSize]  return( F:PSiz[ S ] );	! return file size in pages ;
	[VM$MSize]  return( F:MSiz[ S ] );	! return file size in msgs ;
	[VM$Lic]    return( F:FLic[ S ] );	! return file license ;
	[VM$Access] return( F:Mode[ S ] );	! return file access mode ;
	[VM$Time]   return( F:Time[ S ] );	! return file creation time ;
	[VM$Date]   return( F:Date[ S ] );	! return file creation date ;
	[else]      return( -3 )		! illegal index ;
    end;

end "VM Get Character Pointer";



Internal Simple Integer Procedure VMSetC( Integer Slot, Position );
! ----------------------------------------------------------------------;
!									;
!	NewPosition_ VMSetC( Slot, TrialPosition )			;
!		Set the character position with the file open on the	;
!		specified slot.  All further references to the slot	;
!		will use the new file position.  If the specified	;
!		position is outside the file, the position is set to	;
!		-1.  The routine always returns the new position.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Set Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( 0 leq Position leq F:Size[S] )	! if position within range ;
     then F:Char[S]_ Position		!  then set it up ;
     else F:Char[S]_ Position_ -1;	!  else set to -1 ;

    return( Position );			! return the new position ;

end "VM Set Character Pointer";


Internal Simple Boolean Procedure VMFree( Integer Slot, Bits(0) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMFree( Slot )						;
!		Closes any open file for this slot and frees the	;
!		slot for future use.  Returns true if the slot was	;
!		in use.							;
!									;
! ----------------------------------------------------------------------;
begin "VM Free"
    preset!with 0,0,0,0;
    Own integer array delete[0:3];

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( F:Char[ S ] neq -1 )		! if file mapped, clear page ;
     then Calli( !Xwd( '2001, F:Page[ S ] ), calli!VCLEAR );

    If ( F:Mode[ S ] )			! if any writes ;
     then begin "some changes"		!  reset size & close file ;

	If ( F:Size[ S ] > 0 )		! if non-zero size ;
	 then Chniov( F:Chan[S], (F:Size[S]+4) div 5, !chFTR );
	if ( Bits = -1 )		! Special "RENAME" ;
	 then Chnior( F:Chan[S], Delete[0], !chREN );
	Chnior( F:Chan[ S ], memory[Bits], !chCLS );

     end "some changes";

    Chniov( F:Chan[ S ], 0, !chREL );	! release Slot ;
    Files[ Slot ]_ null!record;		! clear out tables ;

    return( true );			! everything is ok ;

end "VM Free";


Internal String Procedure VMLine( Integer Slot; Reference Integer More;
				  Integer Dir( 0 ) );
! ----------------------------------------------------------------------;
!									;
!	Line_ VMLine( Slot, More, Dir(0) )				;
!		Returns the next consecutive line from the file that	;
!		is connected to the specified slot.  More is set to	;
!		the line terminator (LF, FF, VT, CR or EOT) or to 0	;
!		when the end of the file is reached or the slot is 	;
!		inactive.  Dir is the direction to read the file ( 0	;
!	 	indicates forward, -1 or non-zero for backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Line"
    Integer Page, Byte, Copy, Count, Len, Last;
    Boolean Eol;
    String Str;

    More_ 0;				! Initialize for bad exits ;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( null );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( null );		!  not this time ;

    If ( Dir )				! verify proper usage of Dir ;
     then Dir_ -1			!  non-zero = backward = -1 ;
     else Dir_ +1;			!  was-zero = forward  = +1 ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then If ( Dir < 0 )		! Forward or Backward? ;
	   then F:Char[S]_ F:Size[S]	!   Set after last character ;
	   else F:Char[S]_ 0;		!   Set before first character ;

    If ( F:File[S] neq Page_ ( F:Char[S] div CharPerPage ) + 1 )
     then if not( MapPage( S, Page ) )	! Verify using right page ;
	   then return( null );		!  and page gets mapped ;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Copy_Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);
    If ( Byte < 0 )			! Means we have '440700,,x ;
     then Copy_ Byte_ Byte - BackByte;	! Point at an actual byte ;
    If ( Dir < 0 )			! If backward direction ;
     then Ibp( Copy );			!  then setup for Dbp by 1 ;

    Str_ Null;				! Initial return string ;

    If ( Dir geq 0 )			!   Fix count (# left) ;
     then If ( ( F:File[S] * CharPerPage ) > F:Size[S] )
	   then Count_ (F:Size[S] mod CharPerPage) - Count
	   else Count_ CharPerPage - Count;

    Len_ 0;				! Initialize string length ;
    F:Last[S]_ F:CRet[S]_ 0;		! Initialize break vars ;
    Last_ -1;				! Last character seen ;
    Eol_ false;				! Initialize line var ;
    While not( Eol )			! Read one line ;
     do begin "one line"

	If ( Count > 0 )		! Must have chars left ;
	 then begin "more characters"	!  to even try to read ;

	    If ( Dir < 0 )		! Forward or Backward? ;
	     then Dbp( Copy )		!  position the character ;
	     else Ibp( Copy );		!  pointer in the page ;

	    F:Char[S]_ F:Char[S] + Dir;	! Update file character count ;

	    Case More_ Ldb( Copy ) of begin	! check for end of line ;
		[#nul] begin "found eos break"
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    If ( Dir < 0 ) and		! Backing up? ;
		       not( F:Last[S] )		! First time through? ;
		     then Dbp( Byte )		!  yes, keep it this way ;
		     else Byte_ Copy;		!  no, update pointer ;
		    Len_ 0;			! Reset string length ;
		 end "found eos break";

		[#cr] begin "found return"
		    If ( Dir < 0 )
		     then if ( #LF leq Last leq #FF )
			   then F:CRet[S]_ #CR	! remember we saw this ;
			   else begin "lone cr"
			      If ( Copy = Byte )	! if first char ;
			       then F:Last[S]_ More	!  remember and go ;
			       else begin "eol cr"	! else do eol stuff ;
				 Eol_ true;		! set end of line ;
				 More_ F:Last[S];	! and get last one ;
				 F:Char[S]_ F:Char[S]+1	! bump pointer by 1 ;
			       end "eol cr";
			   end "lone cr";
		    If ( ( Dir > 0 ) and ( #CR = Last ) )
		     then Eol_ true;		! flag as end of line ;
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    Byte_ Copy;			! synchronize pointers ;
		    Len_ 0;			! Reset string length ;
		 end "found return";

		[#lf][#vt][#ff][#eot] begin "found eol break"
		    Eol_ true;			! looks like one? ;
		    if ( Dir < 0 )		! were we going backward? ;
		     then if ( Copy = Byte )	!  and the first character ;
			   then begin "not eol"
			      Eol_ false;	!  yes, not really eol ;
			      F:Last[S]_ More;	!  remember this for later ;
			      F:Line[S]_ F:Line[S] + Dir;	! each line ;
			      If ( More = #FF )			! each FF ;
			       then F:PTxt[S]_ F:PTxt[S] + Dir;	! text page ;
			      If ( More = #EOT )		! each EOT ;
			       then F:MTxt[S]_ F:MTxt[S] + Dir;	! message ;
			   end "not eol"
			   else begin "got eol"
			      F:Char[S]_ F:Char[S] + 1;		! each char ;
			      More_ F:Last[S];			! eol-brk ;
			   end "got eol"
		     else begin "forward eol"
			If ( Last = #CR ) and ( #LF leq More leq #FF )
			 then F:CRet[S]_ Last;		! mark CR before Brk ;
			If ( More = #FF )		! for each FF seen ;
			 then F:PTxt[S]_ F:PTxt[S]+Dir;	!  count a text page ;
			If ( More = #EOT )		! for each EOT seen ;
			 then F:MTxt[S]_ F:MTxt[S]+Dir;	!  count a text message ;
			F:Line[S]_ F:Line[S] + Dir;	! count each line ;
		     end "forward eol";
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		 end "found eol break";

		[else] begin "normal character"
		    If ( Last = #CR ) and ( Dir > 0 )
		     then begin "lonely cr"	! else do eol stuff ;
			Eol_ true;		! set end of line ;
			F:Char[S]_ F:Char[S]-1;	! bump pointer by 1 ;
			More_ #CR;		! set eol to CR ;
			If ( Len )		! length to concatenate? ;
			 then Str_ Str & StMake( Byte, Len );
		     end "lonely cr"
		     else Len_ Len + 1		!  increment string length ;
		 end "normal character"
	    end;

	    If ( memory[ !rh( copy ) ] land 1 )	! bit 35 set ;
	     then begin "sequence numbers"	! in this word? ;

		If ( Dir < 0 )
		 then begin "seq backward"
		    F:Char[S]_ F:Char[S] - 4;	! tab already seen backwards ;
		    Count_ Count - 4;		!  update counts by 4 chars ;
		    If ( Len > 2 )
		     then begin "add text"	!  +1 for tab after seq # ;
			Ibp( Copy );		! make string skipping tab ;
			Str_ StMake( Copy, Len-2 ) & Str;
		     end "add text"
		 end "seq backward"
		 else begin "seq forward"
		    F:Char[S]_ F:Char[S] + 5;	! include tab in count here ;
		    Count_ Count - 5;		!  update counts by 5 chars ;
		    if ( Len neq 1 )
		     then Print( "*** Bad SEQ # in text file. ***"& Crlf );
		 end "seq forward";

		Byte_ Copy_ Copy + Dir;		!  update 1 word ;
		Len_ 0;				! Reset length ;

	     end "sequence numbers";

	    If ( 0 = Count_ (Count-1) max 0 )	! If now out of characters ;
	     then begin "fake eos break"
		If ( Len )			! length to concatenate? ;
		 then if ( Dir < 0 )
		       then Str_ StMake( Dbp( Copy ), Len ) & Str
		       else Str_ Str & StMake( Byte, Len );
		Len_ 0;				! Reset string length ;
	     end "fake eos break";

	    If ( More )				! if this is not a null ;
	     then Last_ More;			! last char for next time ;

	 end "more characters"
	 else begin "need next page"		! If no-more-characters ;

	    If ( F:Char[S] geq F:Size[S] )	! Forwards at end or ;
	       or ( F:Char[S] leq 0 )		!  backwards at beginning ;
	     then begin "end of file"		! At end-of-file? ;

		Eol_ true;			! Set flags true ;
		If ( Dir < 0 )			! If backing up ;
		 then More_ F:Last[S]		!  use last break at end ;
		 else begin "save info"
		    More_ 0;			!  set flag var to 0 ;
		    F:LSiz[S]_ F:Line[S];	!  save total size in lines ;
		    F:PSiz[S]_ F:PTxt[S];	!  save total size in pages ;
		    F:MSiz[S]_ F:MTxt[S];	!  save total size in pages ;
		 end "save info";
		Done "one line";		! Finish loop ;

	     end "end of file";			! Guess, read next page ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then return( null );		! error mapping! ;

	    ! ** assume: here at the beginning of the page ** ;
	    If ( Dir < 0 )			! Forward or Backward? ;
	     then Copy_ Byte_ point( 7, memory[(F:Page[S]+1) lsh 9], -1 )
	     else Copy_ Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );

	    If ( ( Page * CharPerPage ) > F:Size[S] )
	     then Count_ F:Size[S] mod CharPerPage
	     else Count_ CharPerPage;

	 end "need next page";

     end "one line";

    return( Str );			! give 'em what they came for ;

end "VM Line";


Internal Boolean Procedure VMText( Integer Slot; String Text );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMText( Slot, Text, Dir(0) )				;
!		Writes the next consecutive line or lines to the file	;
!		that is connected to the specified slot.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Text"
    Integer Page, Byte, Char, Count;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( F:Mode[S] )			! were we writing? ;
     then return( false );		! no, don't bother! ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then F:Char[S]_ 0;			!   Set before first character ;

    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
     then begin
	Print( "Page map error: p",page,"  c",F:Char[S],"  f",F:Chan[S],crlf );
	return( false );		! if no page, error return ;
     end;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);

    Count_ CharPerPage - Count;		! Fix count (# left) ;

    while ( length( Text ) )		! Must have some text left ;
     do begin "writing line"

	If ( Count > 0 )		! Must have room left on page ;
	 then begin "more characters"	!  to even try to write ;

	    If not( Char_ Lop( Text ) )	! if char = null then try next ;
	     then continue "writing line";

	    IDpb( Char, Byte );		! deposit byte at position ;
	    F:Char[S]_ F:Char[S] + 1;	! Update file character count ;

	    Case ( Char ) of begin	! check for end of line ;
		[#cr] F:CRet[S]_ #CR;	! remember we saw this ;

		[#lf][#vt][#ff][#eot] begin "count lines"
		  F:Last[S]_ Char;		! remember eol character ;
		  F:Line[S]_ F:Line[S] + 1;	! count lines seen ;
		  If ( Char = #FF )		! for each FF seen ;
		   then F:PTxt[S]_ F:PTxt[S]+1;	!  count a text page ;
		  If ( Char = #EOT )		! for each EOT seen ;
		   then F:MTxt[S]_ F:MTxt[S]+1;	!  count a text message ;
		 end "count lines";

		[else] F:CRet[S]_ 0	! forget we saw a cr ;
	     end;

	    Count_ (Count-1) max 0;	! keep character count ;

	 end "more characters"
	 else begin "need next page"	! If no-more-characters ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then begin
		Print( "Page(2) map error: ",page," ",F:Char[S],crlf );
		return( false );	! if no page, error return ;
	     end;

	    Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );
	    Count_ CharPerPage;		! always a full page to write in ;

	 end "need next page";

     end "writing line";

    If ( F:Char[S] geq F:Size[S] )	! At or Past end of file? ;
     then begin "end of file"

	F:Size[S]_ F:Char[S];		!  save size in characters ;
	F:LSiz[S]_ F:Line[S];		!  save total size in lines ;
	F:PSiz[S]_ F:PTxt[S];		!  save total size in pages ;
	F:MSiz[S]_ F:MTxt[S];		!  save total size in pages ;

     end "end of file";			! Guess, read next page ;

    return( true );			! give 'em what they came for ;

end "VM Text";


Internal Boolean Procedure VMMove( Integer Slot, HowMany(1) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMMove( Slot, HowMany(1) )					;
!		Moves the position pointer forward or backward up to	;
!		HowMany lines in the file.  Returns true if the slot is	;
!		active and HowMany lines exist, otherwise it returns	;
!		false and leaves the pointer positioned at logical end	;
!		of file (at the beginning if direction is backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Move"
    Own Integer Brk;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( HowMany )			! we can always move ;
     then return( true );		!  a distance of 0 ;

    while ( HowMany )			! while lines to go read them ;
     do begin "moving lines"

	If not( length( VMLine( Slot, Brk, HowMany < 0 ) ) or Brk )
	 then return( false );		!  then take the cows to town ;

	If ( HowMany > 0 )		! decrement the right direction ;
	 then HowMany_ HowMany - 1	!  down to zero  ;
	 else HowMany_ HowMany + 1;	!  or up to zero ;

     end "moving lines";

    return( true );			! give 'em what they came for ;

end "VM Move";


Internal Simple Boolean Procedure VMFile( String Spec; Integer Mode(VM$Read) );
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMFile( StringSpec, AccessMode )				;
!		Opens a file for the specified access.  A positive	;
!		slot number is returned if the file is available.  A 	;
!		0 means no slots and a negative value means there was	;
!		some file error or the file is not available.		;
!									;
! ----------------------------------------------------------------------;
begin "VM File"
    Own Safe Integer Array File[ 0 : !RBLIC ];
    Preset!with '17, cvsix("DSK   "), 0;
    Own Safe Integer Array Dev[ 0 : 2 ];
    Own Integer Slot;

    If not( Slot_ VMSlot )		! If no Slots available ;
     then return( false );		!  then no file opened ;

    If not( S_ Files[ Slot ] )		! slot assigned? *Debug check* ;
     then return( false );		!  not this time *huh why not* ;

    If not( VMSpec( Spec ) )		! trouble with the spec? ;
     then return( false );		!  then don't do anything ;

    If not(VM$Read leq Mode leq VM$Multi)	! if an invalid mode ;
     then return( false );		! Read, Write, Update, Multi ;

    Dev[ 1 ]_ FileSpec[ S!Dev ];	! Setup device block ;
    Chnior( F:Chan[S],Dev[0],!chOPN );	! OPEN [ '17, Dev, 0 ] ;
    If not( !Skip! )			! If open-failure ;
     then begin "open failure"		!  then no file opened ;
	VMFree( Slot );			! Free the slot ;
	return( !Xwd( -1,-1 ) );	!  and return ;
     end "open failure";

    arrclr( File );			! Clear out unused fields ;
    File[ !RBCNT ]_ !RBLIC;		! Setup file lookup block ;
    if ( FileSpec[ S!Usr ] )
     then File[ !RBPPN ]_ location( FileSpec[ S!Usr ] );
    File[ !RBNAM ]_ FileSpec[ S!Nam ];
    File[ !RBEXT ]_ FileSpec[ S!Ext ] land (-1 lsh 18);

    If ( VM$Write neq F:Mode[S]_ Mode )	! if mode neq VM$Write, do lookup ;
     then begin "read update"

	Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
	If not( !Skip! ) and ( 0 = !rh(File[!RBEXT]) )
	 then begin "not found"		! no skip and file not found ;
	    If ( VM$Read neq Mode )	! if mode neq VM$Read, do create ;
	     then begin "update stuff"

		Chnior( F:Chan[ S ], File[ !RBCNT ], !chENT );
		if ( !Skip! )		! enter ok, so close & lookup ;
		 then begin "ok find it"
		    Chnior( F:Chan[ S ], memory[0], !chCLS );
		    Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
		 end "ok find it";

	     end "update stuff";	! if !skip! found or created file ;
	 end "not found";		!  else some other file error ;

	if not( !Skip! )		! lookups failed - not ERFNF% ;
	 then begin "huh what's up"	! unless happened 2nd time ;
	    VMFree( Slot );		! so, clear out and return ;
	    return( !Xwd( -1,!rh(File[!RBEXT]) ) );
	 end "huh what's up";

     end "read update";			! have old file, or new file ;

    If ( VM$Read neq Mode )		! for VM$Write, VM$Update, VM$Multi ;
     then Chnior( F:Chan[ S ], File[ !RBCNT ],
		   if (Mode = VM$Multi)	! if mode eql VM$Multi ;
		     then !chMEN	!  then use multiple enter ;
		     else !chENT );	!  else use normal enter ;

    If not( !Skip! )			! If lookup-enter failure ;
     then begin "no file or access"	!  then Free the slot ;
	VMFree( Slot );			!  and return error code ;
	return( !Xwd( -1,!rh(File[!RBEXT]) ) );
     end "no file or access";

    F:Size[ S ]_ File[!RBSIZ] * 5;	! File size in characters (Rounded) ;
    F:FLic[ S ]_ !rh( File[!RBLIC] );	! File license ;

    F:Time[ S ]_ (((File[!RBPRV] lsh -12) land '3777) * 60 )
	       + ((File[!RBLIC] lsh -18) land '77);
    F:Date[ S ]_ (Ldb( Point( 2,File[!RBEXT],21 ) ) lsh 12)
	       + (File[!RBPRV] land '7777);

    return( Slot );			! Return the slot number ;

end "VM File";

end "VM Package";
     2VMFILE.DOC   ?04-Jun-86 23:41:30  TOJPEP    !
!   Slot_ VMFile( StringSpec, AccessMode )
!	Opens a file for access.  A positive slot number is returned if the
!	file is available.  A value of 0 means no slots available, a negative
!	value means a file operation error or access violation occurred with
!	the RH of the value containing the TYMCOM-X lookup/enter codes.
!	A -1 value indicates an unavailable device.  Access mode is one of:
!	(0=Read !chLK, 1=Write !chENT, 2=Multi-Write !chMEN).
!
!   Ok_ VMFree( Slot, Bits(0) )
!	Closes any open file for this slot and frees the slot for future use.
!	Returns true if the slot was in use.  If any writes were performed
!	the file is actually closed, otherwise the channel is simply released.
!	If writing and Bits = -1 then delete the file, else if bits # 0 use
!	the value of Bits on the close option.
!
!   Line_ VMLine( Slot, More, Dir(0) )
!	Returns the next consecutive line from the file that is connected
!	to the specified slot.  More is set to the line terminator ( LF, FF
!	or VT ) on a normal return, to 0 when the end of the file is reached
!	or the slot is inactive.  Dir is the direction to read the file
!	(0 = forward, non-zero = backward).
!
!   Ok_ VMText( Slot, TextString )
!	Writes the next consecutive line to the file that is connected
!	to the specified slot.  Returns false for insufficient file access
!	and for any other errors while writing, otherwise returns true.
!
!   Ok_ VMMove( Slot, HowMany(1) )
!	Moves the position pointer forward or backward up to how-many lines
!	in the file.  Returns true if the slot is active and the specified
!	number of lines exist, otherwise it returns false and leaves the
!	pointer positioned at logical end of file.
!
!   Position_ VMGetC( Slot, Index )
!	Read the specified characteristic from the file table.  [0]character,
!	[1]line or [2]page position in the file, [3]eol char, [4]eol-cr-seen,
!	size in [5]characters, [6]lines or [7]pages, [8]file license.  If no
!	file is open or an invalid slot, return -2.  If the index is out of
!	range, return -3.  If the file is open, but no reads have been done,
!	return -1.
!
!   Ok_ VMSetC( Slot, CharacterPosition )
!	Set the character position with the file open on the specified slot.
!	All further references to the file will use the new position.  If the
!	specified position is outside the file, the position is set to -1.
!	The routine always returns the new position.
!
!   License_ VMFLic( Slot )
!	Returns the license of the file open on the specified slot.
;

    2VMFILE.      607-Jun-86 18:41:18  MOLZIG    entry
	VMFile, VMFree, VMChan, VMSpec,
	VMLine, VMText, VMMove,
	VMGetC, VMSetC, VMFLic, VMSetM
	define FT!InternalPages = True;
	Ifcr not FT!InternalPages thenc , VMInit endc

;

begin "VM Package"

  require "(SAILIB)SAIL.DEF"   source!file;
  require "(SAILIB)UUOSYM.DEF" source!file;
  require "(CARL)VMFILE.DEF"   source!file;

  redefine !Block(Group, Name, Size) = {
    Ifcr Length(Cvps(Size)) = 0 thenc assignc Size = 1; Endc
    Define Group}&{Name = Group;
    Redefine Group = Group + Size;};

    Define S! = 0;			! ** Filespec block offsets ** ;
    !Block( S!,Dev )			! Device ;
    !Block( S!,Usr,2 )			! Username ;
    !Block( S!,Nam )			! Name ;
    !Block( S!,Ext )			! Extension ;


  Define
	MaxSlot = 47			! number of available slots ;
  ,	MemMax  = MaxSlot * 512		! pages in words ;
  ,	CharPerPage = 512 * 5		! characters per page ;
  ,	BackByte    = '430000000001	! offset to backup a byte ;
  ,	AddaByte    = '070000000000	! offset to increment byte ;
  ;



  Record!Class F (  Integer Page;	! memory page to use ;
		    Integer File;	! file page in use ;
		    Integer Chan;	! channel for file open ;
		    Integer Mode;	! file access mode ;
		    Integer Name;	! file name in sixbit ;
		    Integer FExt;	! file extension in sixbit ;
		    Integer FPPN;	! file ppn ;
		    Integer Char;	! character pointer in file ;
		    Integer Line;	! line pointer in file +/-;
		    Integer PTxt;	! text page pointer in file +/- ;
		    Integer MTxt;	! text message pointer in file +/- ;
		    Integer Last;	! last eol character ;
		    Integer CRet;	! carriage return on line ;
		    Integer Size;	! character size of file ;
		    Integer LSiz;	! lines in file (if known) ;
		    Integer PSiz;	! pages in file (if known) ;
		    Integer MSiz;	! messages in file (if known) ;
		    Integer FLic;	! file license info ;
		    Integer Time;	! file creation time in seconds ;
		    Integer Date    );	! file creation date ;

  R!P (F) S;
  Safe R!P (F) Array Files[ 1 : MaxSlot ];

  Integer VMBase, VMPage;			! virtual memory pointers  ;
  Integer MaxSlots;				! remember available slots ;

  Own Safe Integer Array FileSpec[ S!Dev : S!Ext ];

 Ifcr FT!InternalPages thenc			! selectable by feature sw ;
  Preset!with [ MemMax + 512 ] 0;		! expect to use 1 : MemMax ;
  Own Safe Integer Array VM[ 1 : MemMax+512 ];	!  entries minus page slop ;
 endc


Ifcr FT!InternalPages thenc
  Simple Procedure InitStuff;
elsec
  Internal Simple Procedure VMInit( Integer Page, Count );
endc
! ----------------------------------------------------------------------;
!									;
!	InitStuff							;
!		Routine to initialize data structures and calculate	;
!		where to put the initial cache of pages to use for	;
!		this venture.						;
!									;
!	VMInit( FirstPage, Count )					;
!		Routine to setup a cache of pages for the user to use	;
!		instead of using the preset range designated by this	;
!		package.  This is setup via the assembly parameter:	;
!		(FT!InternalPages).					;
!									;
! ----------------------------------------------------------------------;
begin "VM Init"

  Ifcr FT!InternalPages thenc		! internal definition ;
    VMPage_ (location( VM[1] ) + '777) lsh -9;
    MaxSlots_ MaxSlot;			! count of pages ;
  elsec
    VMPage_ Page;			! base page ;
    MaxSlots_ Count max MaxSlot;	! count of pages ;
  endc
    VMBase_ VMPage lsh 9;		! base memory address ;

    ArrClr( Files );			! files not open ;

end "VM Init";
Ifcr FT!InternalPages thenc
  require InitStuff initialization;
endc


Internal Simple Integer Procedure VMMaxS( Integer Count );
! ----------------------------------------------------------------------;
!									;
!	NewCount_ VMMaxS( Count )					;
!		Routine to limit the maximum number of slots to use	;
!		in this package.  Useful to insure that specifically	;
!		allocated channels between the top of SAILs channel	;
!		range and those used by VMFILE are not used.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Max Slots"

    return( MaxSlots_ Count max MaxSlot );	! count of pages ;

end "VM Max Slots";


Simple Integer Procedure MapPage( r!p (F) Rec; Integer NewPage );
! ----------------------------------------------------------------------;
!									;
!	MapPage( Rec, NewPage )						;
!		Routine to map the specified new file-page into the	;
!		page designated by F:Page[Rec] and update F:File[Rec]	;
!		to NewPage.						;
!									;
! ----------------------------------------------------------------------;
begin "Map Page"
    Own safe integer array Arg[ 0:1 ];
    Own integer Status, Err;

    If ( F:File[Rec] = NewPage )		! if the same page ;
     then begin "check protection"

	If not( !rh( F:Mode[Rec] ) )		! if no writing request ;
	 then return( NewPage );		! then nothing special ;
	Status_Calli(F:Page[Rec],calli!PAGSTS);	! read page protection ;
	If ( '3 = ( Status land '7 ) )		! if read/write? ;
	 then return( NewPage );		!  then nothing to do ;
	Err_ Calli( !Xwd( '6001,F:Page[Rec] ), calli!VPROT );
	If ( !skip! )				! if no problems, return! ;
	 then return( NewPage )			!  nothing else to do ;
	 else begin				! otherwise complain and ;
	    Print( "Map error: ",cvos(Err)," pagsts: ",cvos(Status),crlf );
	    return( F:File[Rec]_ 0 );		! make believe un-mapped ;
	 end;

     end "check protection";

    Calli( Arg[0]_ !Xwd('2001,F:Page[Rec]), calli!VCLEAR );
    If ( VM$Read neq !rh( F:Mode[Rec] ) )	! if we're writing then ;
     then Arg[0]_ !Xwd('6001,F:Page[Rec]);	!  make it .prrw not .prro ;
    Arg[1]_ NewPage;				! point at file page ;
    Chnior( F:Chan[Rec], Arg[0], !chMFP );	! map the page ;
    Start!code MOVEM '3,ERR; end;		! remember any errors ;

    If ( !Skip! )				! remember file page ;
     then F:File[Rec]_ NewPage			!  NewPage (if map ok) ;
     else begin "map failure"			! else check the fault ;
	F:File[Rec]_ 0;				! default (if map fails) ;

	If ( !rh( F:Mode[Rec] ) ) and		! if writing and past ;
	      ( !rh(ERR)='6 )			!   highest page (FLPHP%) ;
	 then begin "create page"		!  then try to create it ;

	    Chnior( F:Chan[Rec], NewPage, !chCFP );
	    If ( !Skip! )			! check success flag ;
	     then begin "try map again"		! if ok, then try map ;
		Chnior( F:Chan[Rec], Arg[0], !chMFP );
		if ( !Skip! )			! any errors? ;
		 then F:File[Rec]_ NewPage;	! no, it's ok ;
	     end "try map again";

	 end "create page";
     end "map failure";

    return( F:File[Rec] );			! return current mapping ;

end "Map Page";


Simple Integer Procedure Dbp( Reference Integer Ptr );
! ----------------------------------------------------------------------;
!									;
!	Dbp( AsciiBytePointer )						;
!		Routine to decrement a 7-bit byte pointer.  Its only	;
!		magic relies on the assumption that a negative pointer	;
!		is setup as '440700 from the point/bbpp operation that	;
!		creates a ildb pointer to the first byte of the word.	;
!		This routine fixes this to point to the last byte of	;
!		the previous word whenever this is seen.  In "this"	;
!		initial case, this works so that the pointer is never	;
!		decremented the WRONG way.				;
!									;
! ----------------------------------------------------------------------;
begin "Decrement Byte Pointer"

    If ( Ptr < 0 )			! initially '440700,,addr ;
     then Ptr_ Ptr - BackByte		! so set to prev-last byte ;
     else Ptr_ Ptr + AddaByte;		! else decrement a byte ;

    If ( Ptr < 0 )			! must now be '440700,,addr ;
     then Ptr_ Ptr - BackByte;		! so set to prev-last byte ;

    return( Ptr );			! so it can be an expression ;

end "Decrement Byte Pointer";


Simple Integer procedure GetText( Reference string Line;
				  Integer Byte, Count; String Chars );
begin "get text"
    Own integer wp;
    String Str;

    while ( length( Line ) )
     do begin "get data"

	Str_ Chars;				! copy break chars ;
	while ( length( Str ) )			! if any break chars ;
	 do if ( Line = Lop( Str ) )		!  and match a brk ;
	     then return( Line );		!  return that character ;

	if ( 0 leq count_ count - 1 )		! if room left in string ;
	 then if ( "a" leq wp_lop(Line) )	!  then check case ;
	       then idpb( wp-'100, byte )	!    lowercase to sixbit ;
	       else idpb( wp-'40, byte )	!    uppercase to sixbit ;
	 else wp_ lop( Line );			!  throw away extras ;

     end "get data";

    return( 0 );				! no line left? ;

end "get text";


Internal Simple Boolean Procedure VMSpec(String L; Integer array Spec );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMSpec( FileSpecification, SpecificationBlock )		;
!		Routine to read a string file specification and build	;
!		the special file block used by the VMFile routine.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Spec"

    arrclr( Spec );				! clear out the array ;

    GetText( L, point( 6,Spec[S!Nam],-1 ), 6, ":(." );

    if ( ":" = L )				! it was a device, good! ;
     then begin
	lop( L );				! throw away the colon and ;
	Spec[S!Dev] swap Spec[S!Nam];		! swap data to right places ;
     end
     else Spec[S!Dev]_cvsix("DSK");		!  and fill in the device ;

    if ( "(" = L )				! if it starts with "(" ;
     then begin "get user"			!  then pick up username ;
	lop( L );				!    eat the "(" ;
	GetText( L, point( 6,Spec[ S!Usr ],-1 ), 12, ")" );
	lop( L );				!    eat the ")" ;
     end "get user"
     else begin "default user"			! set default if no user ;
	Spec[ S!Usr   ]_ calli( '31, '41 );	! .GTNM1 (GFD user 1-6)  ;
	Spec[ S!Usr+1 ]_ calli( '32, '41 );	! .GTNM2 (GFD user 7-12) ;
	If not( !Skip! )			! set blank if GETTAB fails ;
	 then Spec[ S!Usr ]_ Spec[ S!Usr+1 ]_ 0;
     end "default user";

    if not( length( L ) or Spec[S!Nam] )	! must have a name ;
     then return( false );			!  so return false ;

    if not( "." = L or Spec[S!Nam] )
     then GetText( L, point( 6,Spec[ S!Nam ],-1 ), 6, "." );

    if not( Spec[S!Nam] )			! seen anyone ;
     then return( false );			! no, go home ;

    if ( "." = L )				! if dot seen ;
     then begin "get ext"
	lop( L );				!  then chop it off ;
	GetText( L, point( 6,Spec[ S!Ext ],-1 ), 3, " "&'11 );
     end "get ext";

    return( true );				! got here, return ok ;

end "VM Spec";


Internal Simple Integer Procedure VMChan;
! ----------------------------------------------------------------------;
!									;
!	Chan_ VMChan							;
!		Returns the next available channel for this user.	;
!		If none are available, returns -1.			;
!									;
! ----------------------------------------------------------------------;
begin "VM Chan"

    start!code

	ReDefine !chNXT = '46;		! get next channel ;

	Hrloi	'1,!chNXT;		! setup [.chnxt,,-1] ;
	uuo!CHANIO '1,;			! to get next available ;
	  seto	'1;			! no channels available ;

    end;

end "VM Chan";


Simple Integer Procedure VMSlot;
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMSlot							;
!		Returns the next available file slot in the internal	;
!		file table.  If no slots or channels are available,	;
!		returns 0.  Array Files[slot] is setup with F:Chan,	;
!		F:Page and F:Char.					;
!									;
! ----------------------------------------------------------------------;
begin "VM Slot"
    Own Integer Slot, Chan;

    For Slot_ 1 upto MaxSlots		! check each legal slot ;
     do if not( Files[ Slot ] )		! if it's free ;
	 then begin "setup slot"	!  then make it available ;

	    S_ Files[ Slot ]_ new!record( F );	! initialize record ;

	    if ( 0 > Chan_ VMChan )		! is it legal ;
	     then begin "bad channel"		!  nope. ;
		Files[ Slot ]_ null!record;	!   clear slot ;
		return( 0 );			!   and return ;
	     end "bad channel";

	    F:Chan[ S ]_ Chan;			! copy the channel ;
	    F:Page[ S ]_ VMPage  + Slot - 1;	! memory page ;
	    F:File[ S ]_ F:Char[ S ]_ -1;	! file/char position ;

	    S_ null!record;		! free up working pointer ;

	    return( Slot );		! give caller a slot number ;

	 end "setup slot";

    return( 0 );

end "VM Slot";


Internal Simple Integer Procedure VMFLic( Integer Slot );
! ----------------------------------------------------------------------;
!									;
!	License_ VMFLic							;
!		Routine to return the license that was set on the 	;
!		file open on the specified slot.			;
!									;
! ----------------------------------------------------------------------;
begin  "VM File Lic"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    return( F:FLic[ S ] );		! return the license ;

end "VM File Lic";


Internal Simple Integer Procedure VMGetC( Integer Slot, Index(VM$Char) );
! ----------------------------------------------------------------------;
!									;
!	Position_ VMGetC( Slot, Index(VM$Char) )			;
!		Read the specified characteristic from the file table.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Get Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( -2 );			!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( -2 );			!  not this time ;

    Case Index of begin
	[VM$Char]   return( F:Char[ S ] );	! return character position ;
	[VM$Line]   return( F:Line[ S ] );	! return line position ;
	[VM$Page]   return( F:PTxt[ S ] );	! return page position ;
	[VM$Msg]    return( F:MTxt[ S ] );	! return message position ;
	[VM$Eol]    return( F:Last[ S ] );	! return last eol char ;
	[VM$ECR]    return( F:CRet[ S ] );	! return last cr on line ;
	[VM$Size]   return( F:Size[ S ] );	! return file size in chars ;
	[VM$LSize]  return( F:LSiz[ S ] );	! return file size in lines ;
	[VM$PSize]  return( F:PSiz[ S ] );	! return file size in pages ;
	[VM$MSize]  return( F:MSiz[ S ] );	! return file size in msgs ;
	[VM$Lic]    return( F:FLic[ S ] );	! return file license ;
	[VM$Access] return( F:Mode[ S ] );	! return file access mode ;
	[VM$Time]   return( F:Time[ S ] );	! return file creation time ;
	[VM$Date]   return( F:Date[ S ] );	! return file creation date ;
	[else]      return( -3 )		! illegal index ;
    end;

end "VM Get Character Pointer";



Internal Simple Integer Procedure VMSetC( Integer Slot, Position );
! ----------------------------------------------------------------------;
!									;
!	NewPosition_ VMSetC( Slot, TrialPosition )			;
!		Set the character position with the file open on the	;
!		specified slot.  All further references to the slot	;
!		will use the new file position.  If the specified	;
!		position is outside the file, the position is set to	;
!		-1.  The routine always returns the new position.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Set Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( 0 leq Position leq F:Size[S] )	! if position within range ;
     then F:Char[S]_ Position		!  then set it up ;
     else F:Char[S]_ Position_ -1;	!  else set to -1 ;

    return( Position );			! return the new position ;

end "VM Set Character Pointer";


Internal Simple Boolean Procedure VMFree( Integer Slot, Bits(0) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMFree( Slot )						;
!		Closes any open file for this slot and frees the	;
!		slot for future use.  Returns true if the slot was	;
!		in use.							;
!									;
! ----------------------------------------------------------------------;
begin "VM Free"
    preset!with 0,0,0,0;
    Own integer array delete[0:3];

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( F:Char[ S ] neq -1 )		! if file mapped, clear page ;
     then Calli( !Xwd( '2001, F:Page[ S ] ), calli!VCLEAR );

    If ( !rh( F:Mode[ S ] ) )		! if any writes ;
     then begin "some changes"		!  reset size & close file ;

	If ( F:Size[ S ] > 0 )		! if non-zero size ;
	 then Chniov( F:Chan[S], (F:Size[S]+4) div 5, !chFTR );
	if ( Bits = -1 )		! Special "RENAME" ;
	 then Chnior( F:Chan[S], Delete[0], !chREN );
	Chnior( F:Chan[ S ], memory[Bits], !chCLS );

     end "some changes";

    Chniov( F:Chan[ S ], 0, !chREL );	! release Slot ;
    Files[ Slot ]_ null!record;		! clear out tables ;

    return( true );			! everything is ok ;

end "VM Free";


Internal String Procedure VMLine( Integer Slot; Reference Integer More;
				  Integer Dir( 0 ) );
! ----------------------------------------------------------------------;
!									;
!	Line_ VMLine( Slot, More, Dir(0) )				;
!		Returns the next consecutive line from the file that	;
!		is connected to the specified slot.  More is set to	;
!		the line terminator (LF, FF, VT, CR or EOT) or to 0	;
!		when the end of the file is reached or the slot is 	;
!		inactive.  Dir is the direction to read the file ( 0	;
!	 	indicates forward, -1 or non-zero for backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Line"
    Integer Page, Byte, Copy, Count, Len, Last;
    Boolean Eol;
    String Str;

    More_ 0;				! Initialize for bad exits ;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( null );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( null );		!  not this time ;

    If ( Dir )				! verify proper usage of Dir ;
     then Dir_ -1			!  non-zero = backward = -1 ;
     else Dir_ +1;			!  was-zero = forward  = +1 ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then If ( Dir < 0 )		! Forward or Backward? ;
	   then F:Char[S]_ F:Size[S]	!   Set after last character ;
	   else F:Char[S]_ 0;		!   Set before first character ;

    If ( F:File[S] neq Page_ ( F:Char[S] div CharPerPage ) + 1 )
     then if not( MapPage( S, Page ) )	! Verify using right page ;
	   then return( null );		!  and page gets mapped ;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Copy_Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);
    If ( Byte < 0 )			! Means we have '440700,,x ;
     then Copy_ Byte_ Byte - BackByte;	! Point at an actual byte ;
    If ( Dir < 0 )			! If backward direction ;
     then Ibp( Copy );			!  then setup for Dbp by 1 ;

    Str_ Null;				! Initial return string ;

    If ( Dir geq 0 )			!   Fix count (# left) ;
     then If ( ( F:File[S] * CharPerPage ) > F:Size[S] )
	   then Count_ (F:Size[S] mod CharPerPage) - Count
	   else Count_ CharPerPage - Count;

    Len_ 0;				! Initialize string length ;
    F:Last[S]_ F:CRet[S]_ 0;		! Initialize break vars ;
    Last_ -1;				! Last character seen ;
    Eol_ false;				! Initialize line var ;
    While not( Eol )			! Read one line ;
     do begin "one line"

	If ( Count > 0 )		! Must have chars left ;
	 then begin "more characters"	!  to even try to read ;

	    If ( Dir < 0 )		! Forward or Backward? ;
	     then Dbp( Copy )		!  position the character ;
	     else Ibp( Copy );		!  pointer in the page ;

	    F:Char[S]_ F:Char[S] + Dir;	! Update file character count ;

	    Case More_ Ldb( Copy ) of begin	! check for end of line ;
		[#nul] begin "found eos break"
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    If ( Dir < 0 ) and		! Backing up? ;
		       not( F:Last[S] )		! First time through? ;
		     then Dbp( Byte )		!  yes, keep it this way ;
		     else Byte_ Copy;		!  no, update pointer ;
		    Len_ 0;			! Reset string length ;
		 end "found eos break";

		[#cr] begin "found return"
		    If ( Dir < 0 )
		     then if ( #LF leq Last leq #FF )
			   then F:CRet[S]_ #CR	! remember we saw this ;
			   else begin "lone cr"
			      If ( Copy = Byte )	! if first char ;
			       then F:Last[S]_ More	!  remember and go ;
			       else begin "eol cr"	! else do eol stuff ;
				 Eol_ true;		! set end of line ;
				 More_ F:Last[S];	! and get last one ;
				 F:Char[S]_ F:Char[S]+1	! bump pointer by 1 ;
			       end "eol cr";
			   end "lone cr";
		    If ( ( Dir > 0 ) and ( #CR = Last ) )
		     then Eol_ true;		! flag as end of line ;
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    Byte_ Copy;			! synchronize pointers ;
		    Len_ 0;			! Reset string length ;
		 end "found return";

		[#lf][#vt][#ff][#eot] begin "found eol break"
		    Eol_ true;			! looks like one? ;
		    if ( Dir < 0 )		! were we going backward? ;
		     then if ( Copy = Byte )	!  and the first character ;
			   then begin "not eol"
			      Eol_ false;	!  yes, not really eol ;
			      F:Last[S]_ More;	!  remember this for later ;
			      F:Line[S]_ F:Line[S] + Dir;	! each line ;
			      If ( More = #FF )			! each FF ;
			       then F:PTxt[S]_ F:PTxt[S] + Dir;	! text page ;
			      If ( More = #EOT )		! each EOT ;
			       then F:MTxt[S]_ F:MTxt[S] + Dir;	! message ;
			   end "not eol"
			   else begin "got eol"
			      F:Char[S]_ F:Char[S] + 1;		! each char ;
			      More_ F:Last[S];			! eol-brk ;
			   end "got eol"
		     else begin "forward eol"
			If ( Last = #CR ) and ( #LF leq More leq #FF )
			 then F:CRet[S]_ Last;		! mark CR before Brk ;
			If ( More = #FF )		! for each FF seen ;
			 then F:PTxt[S]_ F:PTxt[S]+Dir;	!  count a text page ;
			If ( More = #EOT )		! for each EOT seen ;
			 then F:MTxt[S]_ F:MTxt[S]+Dir;	!  count a text message ;
			F:Line[S]_ F:Line[S] + Dir;	! count each line ;
		     end "forward eol";
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		 end "found eol break";

		[else] begin "normal character"
		    If ( Last = #CR ) and ( Dir > 0 )
		     then begin "lonely cr"	! else do eol stuff ;
			Eol_ true;		! set end of line ;
			F:Char[S]_ F:Char[S]-1;	! bump pointer by 1 ;
			More_ #CR;		! set eol to CR ;
			If ( Len )		! length to concatenate? ;
			 then Str_ Str & StMake( Byte, Len );
		     end "lonely cr"
		     else Len_ Len + 1		!  increment string length ;
		 end "normal character"
	    end;

	    If ( memory[ !rh( copy ) ] land 1 )	! bit 35 set ;
	     then begin "sequence numbers"	! in this word? ;

		If ( Dir < 0 )
		 then begin "seq backward"
		    F:Char[S]_ F:Char[S] - 4;	! tab already seen backwards ;
		    Count_ Count - 4;		!  update counts by 4 chars ;
		    If ( Len > 2 )
		     then begin "add text"	!  +1 for tab after seq # ;
			Ibp( Copy );		! make string skipping tab ;
			Str_ StMake( Copy, Len-2 ) & Str;
		     end "add text"
		 end "seq backward"
		 else begin "seq forward"
		    F:Char[S]_ F:Char[S] + 5;	! include tab in count here ;
		    Count_ Count - 5;		!  update counts by 5 chars ;
		    if ( Len neq 1 )
		     then Print( "*** Bad SEQ # in text file. ***"& Crlf );
		 end "seq forward";

		Byte_ Copy_ Copy + Dir;		!  update 1 word ;
		Len_ 0;				! Reset length ;

	     end "sequence numbers";

	    If ( 0 = Count_ (Count-1) max 0 )	! If now out of characters ;
	     then begin "fake eos break"
		If ( Len )			! length to concatenate? ;
		 then if ( Dir < 0 )
		       then Str_ StMake( Dbp( Copy ), Len ) & Str
		       else Str_ Str & StMake( Byte, Len );
		Len_ 0;				! Reset string length ;
	     end "fake eos break";

	    If ( More )				! if this is not a null ;
	     then Last_ More;			! last char for next time ;

	 end "more characters"
	 else begin "need next page"		! If no-more-characters ;

	    If ( F:Char[S] geq F:Size[S] )	! Forwards at end or ;
	       or ( F:Char[S] leq 0 )		!  backwards at beginning ;
	     then begin "end of file"		! At end-of-file? ;

		Eol_ true;			! Set flags true ;
		If ( Dir < 0 )			! If backing up ;
		 then More_ F:Last[S]		!  use last break at end ;
		 else begin "save info"
		    More_ 0;			!  set flag var to 0 ;
		    F:LSiz[S]_ F:Line[S];	!  save total size in lines ;
		    F:PSiz[S]_ F:PTxt[S];	!  save total size in pages ;
		    F:MSiz[S]_ F:MTxt[S];	!  save total size in pages ;
		 end "save info";
		Done "one line";		! Finish loop ;

	     end "end of file";			! Guess, read next page ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then return( null );		! error mapping! ;

	    ! ** assume: here at the beginning of the page ** ;
	    If ( Dir < 0 )			! Forward or Backward? ;
	     then Copy_ Byte_ point( 7, memory[(F:Page[S]+1) lsh 9], -1 )
	     else Copy_ Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );

	    If ( ( Page * CharPerPage ) > F:Size[S] )
	     then Count_ F:Size[S] mod CharPerPage
	     else Count_ CharPerPage;

	 end "need next page";

     end "one line";

    return( Str );			! give 'em what they came for ;

end "VM Line";


Internal Boolean Procedure VMText( Integer Slot; String Text );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMText( Slot, Text, Dir(0) )				;
!		Writes the next consecutive line or lines to the file	;
!		that is connected to the specified slot.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Text"
    Integer Page, Byte, Char, Count;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( !rh( F:Mode[S] ) )		! were we writing? ;
     then return( false );		! no, don't bother! ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then F:Char[S]_ 0;			!   Set before first character ;

    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
     then begin
	Print( "Page map error: p",page,"  c",F:Char[S],"  f",F:Chan[S],crlf );
	return( false );		! if no page, error return ;
     end;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);

    Count_ CharPerPage - Count;		! Fix count (# left) ;

    while ( length( Text ) )		! Must have some text left ;
     do begin "writing line"

	If ( Count > 0 )		! Must have room left on page ;
	 then begin "more characters"	!  to even try to write ;

	    If not( Char_ Lop( Text ) )	! if char = null then try next ;
	     then continue "writing line";

	    IDpb( Char, Byte );		! deposit byte at position ;
	    F:Char[S]_ F:Char[S] + 1;	! Update file character count ;

	    Case ( Char ) of begin	! check for end of line ;
		[#cr] F:CRet[S]_ #CR;	! remember we saw this ;

		[#lf][#vt][#ff][#eot] begin "count lines"
		  F:Last[S]_ Char;		! remember eol character ;
		  F:Line[S]_ F:Line[S] + 1;	! count lines seen ;
		  If ( Char = #FF )		! for each FF seen ;
		   then F:PTxt[S]_ F:PTxt[S]+1;	!  count a text page ;
		  If ( Char = #EOT )		! for each EOT seen ;
		   then F:MTxt[S]_ F:MTxt[S]+1;	!  count a text message ;
		 end "count lines";

		[else] F:CRet[S]_ 0	! forget we saw a cr ;
	     end;

	    Count_ (Count-1) max 0;	! keep character count ;

	 end "more characters"
	 else begin "need next page"	! If no-more-characters ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then begin
		Print( "Page(2) map error: ",page," ",F:Char[S],crlf );
		return( false );	! if no page, error return ;
	     end;

	    Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );
	    Count_ CharPerPage;		! always a full page to write in ;

	 end "need next page";

     end "writing line";

    If ( F:Char[S] geq F:Size[S] )	! At or Past end of file? ;
     then begin "end of file"

	F:Size[S]_ F:Char[S];		!  save size in characters ;
	F:LSiz[S]_ F:Line[S];		!  save total size in lines ;
	F:PSiz[S]_ F:PTxt[S];		!  save total size in pages ;
	F:MSiz[S]_ F:MTxt[S];		!  save total size in pages ;

     end "end of file";			! Guess, read next page ;

    return( true );			! give 'em what they came for ;

end "VM Text";


Internal Boolean Procedure VMMove( Integer Slot, HowMany(1) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMMove( Slot, HowMany(1) )					;
!		Moves the position pointer forward or backward up to	;
!		HowMany lines in the file.  Returns true if the slot is	;
!		active and HowMany lines exist, otherwise it returns	;
!		false and leaves the pointer positioned at logical end	;
!		of file (at the beginning if direction is backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Move"
    Own Integer Brk;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( HowMany )			! we can always move ;
     then return( true );		!  a distance of 0 ;

    while ( HowMany )			! while lines to go read them ;
     do begin "moving lines"

	If not( length( VMLine( Slot, Brk, HowMany < 0 ) ) or Brk )
	 then return( false );		!  then take the cows to town ;

	If ( HowMany > 0 )		! decrement the right direction ;
	 then HowMany_ HowMany - 1	!  down to zero  ;
	 else HowMany_ HowMany + 1;	!  or up to zero ;

     end "moving lines";

    return( true );			! give 'em what they came for ;

end "VM Move";


Internal Simple Boolean Procedure VMFile( String Spec; Integer Mode(VM$Read) );
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMFile( StringSpec, AccessMode )				;
!		Opens a file for the specified access.  A positive	;
!		slot number is returned if the file is available.  A 	;
!		0 means no slots and a negative value means there was	;
!		some file error or the file is not available.		;
!									;
! ----------------------------------------------------------------------;
begin "VM File"
    Own Safe Integer Array File[ 0 : !RBLIC ];
    Preset!with '17, cvsix("DSK   "), 0;
    Own Safe Integer Array Dev[ 0 : 2 ];
    Own Integer Slot;

    If not( Slot_ VMSlot )		! If no Slots available ;
     then return( false );		!  then no file opened ;

    If not( S_ Files[ Slot ] )		! slot assigned? *Debug check* ;
     then return( false );		!  not this time *huh why not* ;

    If not( VMSpec( Spec, FileSpec ) )	! trouble with the spec? ;
     then return( false );		!  then don't do anything ;

    If not(VM$Read leq !rh(Mode) leq VM$Multi)	! if an invalid mode ;
     then return( false );		! Read, Write, Update, Multi ;

    Dev[ 0 ]_ Ldb( Point(6,Mode,17) );	! Set proper mode (!ioASC) ;
    Dev[ 1 ]_ FileSpec[ S!Dev ];	! Setup device block ;
    Chnior( F:Chan[S],Dev[0],!chOPN );	! OPEN [ '17, Dev, 0 ] ;
    If not( !Skip! )			! If open-failure ;
     then begin "open failure"		!  then no file opened ;
	VMFree( Slot );			! Free the slot ;
	return( !Xwd( -1,-1 ) );	!  and return ;
     end "open failure";

    Mode_ !rh( F:Mode[S]_ Mode );	! Remember this as we need to ;
    arrclr( File );			! Clear out unused fields ;
    File[ !RBCNT ]_ !RBLIC;		! Setup file lookup block ;
    if ( FileSpec[ S!Usr ] )
     then File[ !RBPPN ]_ location( FileSpec[ S!Usr ] );
    File[ !RBNAM ]_ FileSpec[ S!Nam ];
    File[ !RBEXT ]_ FileSpec[ S!Ext ] land (-1 lsh 18);

    If ( VM$Write neq Mode )		! if mode neq VM$Write ;
     then begin "read update"		!   do lookup ;

	Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
	If not( !Skip! ) and ( 0 = !rh(File[!RBEXT]) )
	 then begin "not found"		! no skip and file not found ;
	    If ( VM$Read neq Mode )	! if mode neq VM$Read, do create ;
	     then begin "update stuff"

		Chnior( F:Chan[ S ], File[ !RBCNT ], !chENT );
		if ( !Skip! )		! enter ok, so close & lookup ;
		 then begin "ok find it"
		    Chnior( F:Chan[ S ], memory[0], !chCLS );
		    Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
		 end "ok find it";

	     end "update stuff";	! if !skip! found or created file ;
	 end "not found";		!  else some other file error ;

	if not( !Skip! )		! lookups failed - not ERFNF% ;
	 then begin "huh what's up"	! unless happened 2nd time ;
	    VMFree( Slot );		! so, clear out and return ;
	    return( !Xwd( -1,!rh(File[!RBEXT]) ) );
	 end "huh what's up";

     end "read update";			! have old file, or new file ;

    If ( VM$Read neq Mode )		! for VM$Write, VM$Update, VM$Multi ;
     then Chnior( F:Chan[ S ], File[ !RBCNT ],
		   if (Mode = VM$Multi)	! if mode eql VM$Multi ;
		     then !chMEN	!  then use multiple enter ;
		     else !chENT );	!  else use normal enter ;

    If not( !Skip! )			! If lookup-enter failure ;
     then begin "no file or access"	!  then Free the slot ;
	VMFree( Slot );			!  and return error code ;
	return( !Xwd( -1,!rh(File[!RBEXT]) ) );
     end "no file or access";

    F:FPPN[ S ]_ File[!RBPPN];		! File directory ;
    F:Name[ S ]_ File[!RBNAM];		! File name ;
    F:FExt[ S ]_ File[!RBEXT];		! File extension ;
    F:Size[ S ]_ File[!RBSIZ] * 5;	! File size in characters (Rounded) ;
    F:FLic[ S ]_ !rh( File[!RBLIC] );	! File license ;

    F:Time[ S ]_ (((File[!RBPRV] lsh -12) land '3777) * 60 )
	       + ((File[!RBLIC] lsh -18) land '77);
    F:Date[ S ]_ (Ldb( Point( 2,File[!RBEXT],21 ) ) lsh 12)
	       + (File[!RBPRV] land '7777);

    if ( Mode > VM$Read ) and		! are we writing and ;
	( VM$Append land F:Mode[ S ] )	! wanting to append ;	
	and  ( F:Size[ S ] )		! must have something ;
     then begin "tack it on"
	VMMove( Slot, -1 );		! backup from the end ;
	VMMove( Slot, 1 );		! and move forward ;
     end "tack it on";
	 
    return( Slot );			! Return the slot number ;

end "VM File";

end "VM Package";
      2VMFILE.D05   07-Jun-86 18:55:35  FIQBAK    
require "  VM Mapped File Package Definitions  " message;

! the following are the access modes for the VMFile routine ;

Define	VM$Read   =  0			! Read Only ;
,	VM$Write  =  VM$Read   + 1	! Write/Supersede ;
,	VM$Update =  VM$Write  + 1	! Write/Update (used for append) ;
,	VM$Multi  =  VM$Update + 1	! Multi-access Write/Update ;

,	VM$Append = ( 1 lsh 35 )	! Append flag - Update or Multi ;
;

! The following are the offsets for the VMGetC routine ;

Define	VM$Char   =  0			! Character position ;
,	VM$Line   =  VM$Char   + 1	! Line position ;
,	VM$Page   =  VM$Line   + 1	! Page position ;
,	VM$Msg    =  VM$Page   + 1	! Message position ;
,	VM$Eol    =  VM$Msg    + 1	! End of Line terminator ;
,	VM$ECR    =  VM$Eol    + 1	! End of Line CR seen ;
,	VM$Size   =  VM$ECR    + 1	! Size of file in Characters ;
,	VM$LSize  =  VM$Size   + 1	! Size of file in Lines ;
,	VM$PSize  =  VM$LSize  + 1	! Size of file in Pages ;
,	VM$MSize  =  VM$PSize  + 1	! Size of file in Messages ;
,	VM$Lic    =  VM$MSize  + 1	! File license ;
,	VM$Access =  VM$Lic    + 1	! File access mode ;
,	VM$Time   =  VM$Access + 1	! File creation time in seconds ;
,	VM$Date   =  VM$Time   + 1	! File creation date ;
;

Define
	S!Dev     =  0			! Device ;
,	S!Usr     =  S!Dev     + 1	! Username ;
,	S!Nam     =  S!Usr     + 2	! Name ;
,	S!Ext     =  S!Nam     + 1	! Extension ;
;
        2VMFILE.005   ?30-Jun-86 13:06:14  VATTAP    entry
	VMFile, VMFree, VMChan,
	VMPMap, VMBase, VMSpec,
	VMLine, VMText, VMMove,
	VMGetC, VMSetC, VMFLic, VMSetM
	define FT!InternalPages = True;
	Ifcr not FT!InternalPages thenc , VMInit endc

;

begin "VM Package"

  require "(SAILIB)SAIL.DEF"   source!file;
  require "(SAILIB)UUOSYM.DEF" source!file;
  require "(CARL)VMFILE.DEF"   source!file;


  Define
	MaxSlot = 47			! number of available slots ;
  ,	MemMax  = MaxSlot * 512		! pages in words ;
  ,	CharPerPage = 512 * 5		! characters per page ;
  ,	BackByte    = '430000000001	! offset to backup a byte ;
  ,	AddaByte    = '070000000000	! offset to increment byte ;
  ;



  Record!Class F (  Integer Page;	! memory page to use ;
		    Integer File;	! file page in use ;
		    Integer Chan;	! channel for file open ;
		    Integer Mode;	! file access mode ;
		    Integer Name;	! file name in sixbit ;
		    Integer FExt;	! file extension in sixbit ;
		    Integer FPPN;	! file ppn ;
		    Integer Char;	! character pointer in file ;
		    Integer Line;	! line pointer in file +/-;
		    Integer PTxt;	! text page pointer in file +/- ;
		    Integer MTxt;	! text message pointer in file +/- ;
		    Integer Last;	! last eol character ;
		    Integer CRet;	! carriage return on line ;
		    Integer Size;	! character size of file ;
		    Integer LSiz;	! lines in file (if known) ;
		    Integer PSiz;	! pages in file (if known) ;
		    Integer MSiz;	! messages in file (if known) ;
		    Integer FLic;	! file license info ;
		    Integer Time;	! file creation time in seconds ;
		    Integer Date    );	! file creation date ;

  R!P (F) S;
  Safe R!P (F) Array Files[ 1 : MaxSlot ];

  Integer VMMem, VMPage;			! virtual memory pointers  ;
  Integer MaxSlots;				! remember available slots ;

  Own Safe Integer Array FileSpec[ S!Dev : S!Ext ];

 Ifcr FT!InternalPages thenc			! selectable by feature sw ;
  Preset!with [ MemMax + 512 ] 0;		! expect to use 1 : MemMax ;
  Own Safe Integer Array VM[ 1 : MemMax+512 ];	!  entries minus page slop ;
 endc


Ifcr FT!InternalPages thenc
  Simple Procedure InitStuff;
elsec
  Internal Simple Procedure VMInit( Integer Page, Count );
endc
! ----------------------------------------------------------------------;
!									;
!	InitStuff							;
!		Routine to initialize data structures and calculate	;
!		where to put the initial cache of pages to use for	;
!		this venture.						;
!									;
!	VMInit( FirstPage, Count )					;
!		Routine to setup a cache of pages for the user to use	;
!		instead of using the preset range designated by this	;
!		package.  This is setup via the assembly parameter:	;
!		(FT!InternalPages).					;
!									;
! ----------------------------------------------------------------------;
begin "VM Init"

  Ifcr FT!InternalPages thenc		! internal definition ;
    VMPage_ (location( VM[1] ) + '777) lsh -9;
    MaxSlots_ MaxSlot;			! count of pages ;
  elsec
    VMPage_ Page;			! base page ;
    MaxSlots_ Count max MaxSlot;	! count of pages ;
  endc
    VMMem_ VMPage lsh 9;		! base memory address ;

    ArrClr( Files );			! files not open ;

end "VM Init";
Ifcr FT!InternalPages thenc
  require InitStuff initialization;
endc


Internal Simple Integer Procedure VMMaxS( Integer Count );
! ----------------------------------------------------------------------;
!									;
!	NewCount_ VMMaxS( Count )					;
!		Routine to limit the maximum number of slots to use	;
!		in this package.  Useful to insure that specifically	;
!		allocated channels between the top of SAILs channel	;
!		range and those used by VMFILE are not used.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Max Slots"

    return( MaxSlots_ Count max MaxSlot );	! count of pages ;

end "VM Max Slots";


Simple Integer Procedure MapPage( r!p (F) Rec; Integer NewPage );
! ----------------------------------------------------------------------;
!									;
!	MapPage( Rec, NewPage )						;
!		Routine to map the specified new file-page into the	;
!		page designated by F:Page[Rec] and update F:File[Rec]	;
!		to NewPage.						;
!									;
! ----------------------------------------------------------------------;
begin "Map Page"
    Own safe integer array Arg[ 0:1 ];
    Own integer Status, Err;

    If ( F:File[Rec] = NewPage )		! if the same page ;
     then begin "check protection"

	If not( !rh( F:Mode[Rec] ) )		! if no writing request ;
	 then return( NewPage );		! then nothing special ;
	Status_Calli(F:Page[Rec],calli!PAGSTS);	! read page protection ;
	If ( '3 = ( Status land '7 ) )		! if read/write? ;
	 then return( NewPage );		!  then nothing to do ;
	Err_ Calli( !Xwd( '6001,F:Page[Rec] ), calli!VPROT );
	If ( !skip! )				! if no problems, return! ;
	 then return( NewPage )			!  nothing else to do ;
	 else begin				! otherwise complain and ;
	    Print( "Map error: ",cvos(Err)," pagsts: ",cvos(Status),crlf );
	    return( F:File[Rec]_ 0 );		! make believe un-mapped ;
	 end;

     end "check protection";

    Calli( Arg[0]_ !Xwd('2001,F:Page[Rec]), calli!VCLEAR );
    If ( VM$Read neq !rh( F:Mode[Rec] ) )	! if we're writing then ;
     then Arg[0]_ !Xwd('6001,F:Page[Rec]);	!  make it .prrw not .prro ;
    Arg[1]_ NewPage;				! point at file page ;
    Chnior( F:Chan[Rec], Arg[0], !chMFP );	! map the page ;
    Start!code MOVEM '3,ERR; end;		! remember any errors ;

    If ( !Skip! )				! remember file page ;
     then F:File[Rec]_ NewPage			!  NewPage (if map ok) ;
     else begin "map failure"			! else check the fault ;
	F:File[Rec]_ 0;				! default (if map fails) ;

	If ( !rh( F:Mode[Rec] ) ) and		! if writing and past ;
	      ( !rh(ERR)='6 )			!   highest page (FLPHP%) ;
	 then begin "create page"		!  then try to create it ;

	    Chnior( F:Chan[Rec], NewPage, !chCFP );
	    If ( !Skip! )			! check success flag ;
	     then begin "try map again"		! if ok, then try map ;
		Chnior( F:Chan[Rec], Arg[0], !chMFP );
		if ( !Skip! )			! any errors? ;
		 then F:File[Rec]_ NewPage;	! no, it's ok ;
	     end "try map again";

	 end "create page";
     end "map failure";

    return( F:File[Rec] );			! return current mapping ;

end "Map Page";


Integer Procedure VM!PMap( Integer Slot, NewPage );
Return( MapPage( Files[ Slot ], NewPage ) );

Internal Simple Integer Procedure VMPMap( Integer Slot, NewPage );
! ----------------------------------------------------------------------;
!									;
!	NewPage_ VMPMap( Slot, NewPage )				;
!		Routine to map the specified new page into the map	;
!		slot for this slot and return the new page on success.	;
!		Returns 0 if any errors occur, including wrong page	;
!		protection.						;
!									;
! ----------------------------------------------------------------------;
begin  "VM Page Map"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    return( VM!PMap( Slot, NewPage ) );	! return the proper page ;

end "VM Page Map";


Simple Integer Procedure Dbp( Reference Integer Ptr );
! ----------------------------------------------------------------------;
!									;
!	Dbp( AsciiBytePointer )						;
!		Routine to decrement a 7-bit byte pointer.  Its only	;
!		magic relies on the assumption that a negative pointer	;
!		is setup as '440700 from the point/bbpp operation that	;
!		creates a ildb pointer to the first byte of the word.	;
!		This routine fixes this to point to the last byte of	;
!		the previous word whenever this is seen.  In "this"	;
!		initial case, this works so that the pointer is never	;
!		decremented the WRONG way.				;
!									;
! ----------------------------------------------------------------------;
begin "Decrement Byte Pointer"

    If ( Ptr < 0 )			! initially '440700,,addr ;
     then Ptr_ Ptr - BackByte		! so set to prev-last byte ;
     else Ptr_ Ptr + AddaByte;		! else decrement a byte ;

    If ( Ptr < 0 )			! must now be '440700,,addr ;
     then Ptr_ Ptr - BackByte;		! so set to prev-last byte ;

    return( Ptr );			! so it can be an expression ;

end "Decrement Byte Pointer";


Simple Integer procedure GetText( Reference string Line;
				  Integer Byte, Count; String Chars );
begin "get text"
    Own integer wp;
    String Str;

    while ( length( Line ) )
     do begin "get data"

	Str_ Chars;				! copy break chars ;
	while ( length( Str ) )			! if any break chars ;
	 do if ( Line = Lop( Str ) )		!  and match a brk ;
	     then return( Line );		!  return that character ;

	if ( 0 leq count_ count - 1 )		! if room left in string ;
	 then if ( "a" leq wp_lop(Line) )	!  then check case ;
	       then idpb( wp-'100, byte )	!    lowercase to sixbit ;
	       else idpb( wp-'40, byte )	!    uppercase to sixbit ;
	 else wp_ lop( Line );			!  throw away extras ;

     end "get data";

    return( 0 );				! no line left? ;

end "get text";


Internal Simple Boolean Procedure VMSpec(String L; Integer array Spec );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMSpec( FileSpecification, SpecificationBlock )		;
!		Routine to read a string file specification and build	;
!		the special file block used by the VMFile routine.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Spec"

    arrclr( Spec );				! clear out the array ;

    GetText( L, point( 6,Spec[S!Nam],-1 ), 6, ":(." );

    if ( ":" = L )				! it was a device, good! ;
     then begin
	lop( L );				! throw away the colon and ;
	Spec[S!Dev] swap Spec[S!Nam];		! swap data to right places ;
     end
     else Spec[S!Dev]_cvsix("DSK");		!  and fill in the device ;

    if ( "(" = L )				! if it starts with "(" ;
     then begin "get user"			!  then pick up username ;
	lop( L );				!    eat the "(" ;
	GetText( L, point( 6,Spec[ S!Usr ],-1 ), 12, ")" );
	lop( L );				!    eat the ")" ;
     end "get user"
     else begin "default user"			! set default if no user ;
	Spec[ S!Usr   ]_ calli( '31, '41 );	! .GTNM1 (GFD user 1-6)  ;
	Spec[ S!Usr+1 ]_ calli( '32, '41 );	! .GTNM2 (GFD user 7-12) ;
	If not( !Skip! )			! set blank if GETTAB fails ;
	 then Spec[ S!Usr ]_ Spec[ S!Usr+1 ]_ 0;
     end "default user";

    if not( length( L ) or Spec[S!Nam] )	! must have a name ;
     then return( false );			!  so return false ;

    if not( "." = L or Spec[S!Nam] )
     then GetText( L, point( 6,Spec[ S!Nam ],-1 ), 6, "." );

    if not( Spec[S!Nam] )			! seen anyone ;
     then return( false );			! no, go home ;

    if ( "." = L )				! if dot seen ;
     then begin "get ext"
	lop( L );				!  then chop it off ;
	GetText( L, point( 6,Spec[ S!Ext ],-1 ), 3, " "&'11 );
     end "get ext";

    return( true );				! got here, return ok ;

end "VM Spec";


Internal Simple Integer Procedure VMChan;
! ----------------------------------------------------------------------;
!									;
!	Chan_ VMChan							;
!		Returns the next available channel for this user.	;
!		If none are available, returns -1.			;
!									;
! ----------------------------------------------------------------------;
begin "VM Chan"

    start!code

	ReDefine !chNXT = '46;		! get next channel ;

	Hrloi	'1,!chNXT;		! setup [.chnxt,,-1] ;
	uuo!CHANIO '1,;			! to get next available ;
	  seto	'1;			! no channels available ;
	skipl	'1;			! if less than zero ;
	  tlz	'1,-1;			!  skip, else zero left ;

    end;

end "VM Chan";


Simple Integer Procedure VMSlot;
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMSlot							;
!		Returns the next available file slot in the internal	;
!		file table.  If no slots or channels are available,	;
!		returns 0.  Array Files[slot] is setup with F:Chan,	;
!		F:Page and F:Char.					;
!									;
! ----------------------------------------------------------------------;
begin "VM Slot"
    Own Integer Slot, Chan;

    For Slot_ 1 upto MaxSlots		! check each legal slot ;
     do if not( Files[ Slot ] )		! if it's free ;
	 then begin "setup slot"	!  then make it available ;

	    S_ Files[ Slot ]_ new!record( F );	! initialize record ;

	    if ( 0 > Chan_ VMChan )		! is it legal ;
	     then begin "bad channel"		!  nope. ;
		Files[ Slot ]_ null!record;	!   clear slot ;
		return( 0 );			!   and return ;
	     end "bad channel";

	    F:Chan[ S ]_ Chan;			! copy the channel ;
	    F:Page[ S ]_ VMPage  + Slot - 1;	! memory page ;
	    F:File[ S ]_ F:Char[ S ]_ -1;	! file/char position ;

	    S_ null!record;		! free up working pointer ;

	    return( Slot );		! give caller a slot number ;

	 end "setup slot";

    return( 0 );

end "VM Slot";


Internal Simple Integer Procedure VMBase( Integer Slot );
! ----------------------------------------------------------------------;
!									;
!	BasePage_ VMBase						;
!		Routine to return the base memory page used for the 	;
!		mapping of the file open on the specified slot.		;
!									;
! ----------------------------------------------------------------------;
begin  "VM Base Page"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    return( F:Page[ S ] );		! return the base page ;

end "VM Base Page";


Internal Simple Integer Procedure VMFLic( Integer Slot );
! ----------------------------------------------------------------------;
!									;
!	License_ VMFLic							;
!		Routine to return the license that was set on the 	;
!		file open on the specified slot.			;
!									;
! ----------------------------------------------------------------------;
begin  "VM File Lic"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    return( F:FLic[ S ] );		! return the license ;

end "VM File Lic";


Internal Simple Integer Procedure VMGetC( Integer Slot, Index(VM$Char) );
! ----------------------------------------------------------------------;
!									;
!	Position_ VMGetC( Slot, Index(VM$Char) )			;
!		Read the specified characteristic from the file table.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Get Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( -2 );			!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( -2 );			!  not this time ;

    Case Index of begin
	[VM$Char]   return( F:Char[ S ] );	! return character position ;
	[VM$Line]   return( F:Line[ S ] );	! return line position ;
	[VM$Page]   return( F:PTxt[ S ] );	! return page position ;
	[VM$Msg]    return( F:MTxt[ S ] );	! return message position ;
	[VM$Eol]    return( F:Last[ S ] );	! return last eol char ;
	[VM$ECR]    return( F:CRet[ S ] );	! return last cr on line ;
	[VM$Size]   return( F:Size[ S ] );	! return file size in chars ;
	[VM$LSize]  return( F:LSiz[ S ] );	! return file size in lines ;
	[VM$PSize]  return( F:PSiz[ S ] );	! return file size in pages ;
	[VM$MSize]  return( F:MSiz[ S ] );	! return file size in msgs ;
	[VM$Lic]    return( F:FLic[ S ] );	! return file license ;
	[VM$Access] return( F:Mode[ S ] );	! return file access mode ;
	[VM$Time]   return( F:Time[ S ] );	! return file creation time ;
	[VM$Date]   return( F:Date[ S ] );	! return file creation date ;
	[else]      return( -3 )		! illegal index ;
    end;

end "VM Get Character Pointer";



Internal Simple Integer Procedure VMSetC( Integer Slot, Position );
! ----------------------------------------------------------------------;
!									;
!	NewPosition_ VMSetC( Slot, TrialPosition )			;
!		Set the character position with the file open on the	;
!		specified slot.  All further references to the slot	;
!		will use the new file position.  If the specified	;
!		position is outside the file, the position is set to	;
!		-1.  The routine always returns the new position.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Set Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( 0 leq Position leq F:Size[S] )	! if position within range ;
     then F:Char[S]_ Position		!  then set it up ;
     else F:Char[S]_ Position_ -1;	!  else set to -1 ;

    return( Position );			! return the new position ;

end "VM Set Character Pointer";


Internal Simple Boolean Procedure VMFree( Integer Slot, Bits(0) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMFree( Slot )						;
!		Closes any open file for this slot and frees the	;
!		slot for future use.  Returns true if the slot was	;
!		in use.							;
!									;
! ----------------------------------------------------------------------;
begin "VM Free"
    preset!with 0,0,0,0;
    Own integer array delete[0:3];

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( F:Char[ S ] neq -1 )		! if file mapped, clear page ;
     then Calli( !Xwd( '2001, F:Page[ S ] ), calli!VCLEAR );

    If ( !rh( F:Mode[ S ] ) )		! if any writes ;
     then begin "some changes"		!  reset size & close file ;

	If ( F:Size[ S ] > 0 )		! if non-zero size ;
	 then Chniov( F:Chan[S], (F:Size[S]+4) div 5, !chFTR );
	if ( Bits = -1 )		! Special "RENAME" ;
	 then Chnior( F:Chan[S], Delete[0], !chREN );
	Chnior( F:Chan[ S ], memory[Bits], !chCLS );

     end "some changes";

    Chniov( F:Chan[ S ], 0, !chREL );	! release Slot ;
    Files[ Slot ]_ null!record;		! clear out tables ;

    return( true );			! everything is ok ;

end "VM Free";


Internal String Procedure VMLine( Integer Slot; Reference Integer More;
				  Integer Dir( 0 ) );
! ----------------------------------------------------------------------;
!									;
!	Line_ VMLine( Slot, More, Dir(0) )				;
!		Returns the next consecutive line from the file that	;
!		is connected to the specified slot.  More is set to	;
!		the line terminator (LF, FF, VT, CR or EOT) or to 0	;
!		when the end of the file is reached or the slot is 	;
!		inactive.  Dir is the direction to read the file ( 0	;
!	 	indicates forward, -1 or non-zero for backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Line"
    Integer Page, Byte, Copy, Count, Len, Last;
    Boolean Eol;
    String Str;

    More_ 0;				! Initialize for bad exits ;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( null );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( null );		!  not this time ;

    If ( Dir )				! verify proper usage of Dir ;
     then Dir_ -1			!  non-zero = backward = -1 ;
     else Dir_ +1;			!  was-zero = forward  = +1 ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then If ( Dir < 0 )		! Forward or Backward? ;
	   then F:Char[S]_ F:Size[S]	!   Set after last character ;
	   else F:Char[S]_ 0;		!   Set before first character ;

    If ( F:File[S] neq Page_ ( F:Char[S] div CharPerPage ) + 1 )
     then if not( MapPage( S, Page ) )	! Verify using right page ;
	   then return( null );		!  and page gets mapped ;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Copy_Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);
    If ( Byte < 0 )			! Means we have '440700,,x ;
     then Copy_ Byte_ Byte - BackByte;	! Point at an actual byte ;
    If ( Dir < 0 )			! If backward direction ;
     then Ibp( Copy );			!  then setup for Dbp by 1 ;

    Str_ Null;				! Initial return string ;

    If ( Dir geq 0 )			!   Fix count (# left) ;
     then If ( ( F:File[S] * CharPerPage ) > F:Size[S] )
	   then Count_ (F:Size[S] mod CharPerPage) - Count
	   else Count_ CharPerPage - Count;

    Len_ 0;				! Initialize string length ;
    F:Last[S]_ F:CRet[S]_ 0;		! Initialize break vars ;
    Last_ -1;				! Last character seen ;
    Eol_ false;				! Initialize line var ;
    While not( Eol )			! Read one line ;
     do begin "one line"

	If ( Count > 0 )		! Must have chars left ;
	 then begin "more characters"	!  to even try to read ;

	    If ( Dir < 0 )		! Forward or Backward? ;
	     then Dbp( Copy )		!  position the character ;
	     else Ibp( Copy );		!  pointer in the page ;

	    F:Char[S]_ F:Char[S] + Dir;	! Update file character count ;

	    Case More_ Ldb( Copy ) of begin	! check for end of line ;
		[#nul] begin "found eos break"
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    If ( Dir < 0 ) and		! Backing up? ;
		       not( F:Last[S] )		! First time through? ;
		     then Dbp( Byte )		!  yes, keep it this way ;
		     else Byte_ Copy;		!  no, update pointer ;
		    Len_ 0;			! Reset string length ;
		 end "found eos break";

		[#cr] begin "found return"
		    If ( Dir < 0 )
		     then if ( #LF leq Last leq #FF )
			   then F:CRet[S]_ #CR	! remember we saw this ;
			   else begin "lone cr"
			      If ( Copy = Byte )	! if first char ;
			       then F:Last[S]_ More	!  remember and go ;
			       else begin "eol cr"	! else do eol stuff ;
				 Eol_ true;		! set end of line ;
				 More_ F:Last[S];	! and get last one ;
				 F:Char[S]_ F:Char[S]+1	! bump pointer by 1 ;
			       end "eol cr";
			   end "lone cr";
		    If ( ( Dir > 0 ) and ( #CR = Last ) )
		     then Eol_ true;		! flag as end of line ;
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    Byte_ Copy;			! synchronize pointers ;
		    Len_ 0;			! Reset string length ;
		 end "found return";

		[#lf][#vt][#ff][#eot] begin "found eol break"
		    Eol_ true;			! looks like one? ;
		    if ( Dir < 0 )		! were we going backward? ;
		     then if ( Copy = Byte )	!  and the first character ;
			   then begin "not eol"
			      Eol_ false;	!  yes, not really eol ;
			      F:Last[S]_ More;	!  remember this for later ;
			      F:Line[S]_ F:Line[S] + Dir;	! each line ;
			      If ( More = #FF )			! each FF ;
			       then F:PTxt[S]_ F:PTxt[S] + Dir;	! text page ;
			      If ( More = #EOT )		! each EOT ;
			       then F:MTxt[S]_ F:MTxt[S] + Dir;	! message ;
			   end "not eol"
			   else begin "got eol"
			      F:Char[S]_ F:Char[S] + 1;		! each char ;
			      More_ F:Last[S];			! eol-brk ;
			   end "got eol"
		     else begin "forward eol"
			If ( Last = #CR ) and ( #LF leq More leq #FF )
			 then F:CRet[S]_ Last;		! mark CR before Brk ;
			If ( More = #FF )		! for each FF seen ;
			 then F:PTxt[S]_ F:PTxt[S]+Dir;	!  count a text page ;
			If ( More = #EOT )		! for each EOT seen ;
			 then F:MTxt[S]_ F:MTxt[S]+Dir;	!  count a text message ;
			F:Line[S]_ F:Line[S] + Dir;	! count each line ;
		     end "forward eol";
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		 end "found eol break";

		[else] begin "normal character"
		    If ( Last = #CR ) and ( Dir > 0 )
		     then begin "lonely cr"	! else do eol stuff ;
			Eol_ true;		! set end of line ;
			F:Char[S]_ F:Char[S]-1;	! bump pointer by 1 ;
			More_ #CR;		! set eol to CR ;
			If ( Len )		! length to concatenate? ;
			 then Str_ Str & StMake( Byte, Len );
		     end "lonely cr"
		     else Len_ Len + 1		!  increment string length ;
		 end "normal character"
	    end;

	    If ( memory[ !rh( copy ) ] land 1 )	! bit 35 set ;
	     then begin "sequence numbers"	! in this word? ;

		If ( Dir < 0 )
		 then begin "seq backward"
		    F:Char[S]_ F:Char[S] - 4;	! tab already seen backwards ;
		    Count_ Count - 4;		!  update counts by 4 chars ;
		    If ( Len > 2 )
		     then begin "add text"	!  +1 for tab after seq # ;
			Ibp( Copy );		! make string skipping tab ;
			Str_ StMake( Copy, Len-2 ) & Str;
		     end "add text"
		 end "seq backward"
		 else begin "seq forward"
		    F:Char[S]_ F:Char[S] + 5;	! include tab in count here ;
		    Count_ Count - 5;		!  update counts by 5 chars ;
		    if ( Len neq 1 )
		     then Print( "*** Bad SEQ # in text file. ***"& Crlf );
		 end "seq forward";

		Byte_ Copy_ Copy + Dir;		!  update 1 word ;
		Len_ 0;				! Reset length ;

	     end "sequence numbers";

	    If ( 0 = Count_ (Count-1) max 0 )	! If now out of characters ;
	     then begin "fake eos break"
		If ( Len )			! length to concatenate? ;
		 then if ( Dir < 0 )
		       then Str_ StMake( Dbp( Copy ), Len ) & Str
		       else Str_ Str & StMake( Byte, Len );
		Len_ 0;				! Reset string length ;
	     end "fake eos break";

	    If ( More )				! if this is not a null ;
	     then Last_ More;			! last char for next time ;

	 end "more characters"
	 else begin "need next page"		! If no-more-characters ;

	    If ( F:Char[S] geq F:Size[S] )	! Forwards at end or ;
	       or ( F:Char[S] leq 0 )		!  backwards at beginning ;
	     then begin "end of file"		! At end-of-file? ;

		Eol_ true;			! Set flags true ;
		If ( Dir < 0 )			! If backing up ;
		 then More_ F:Last[S]		!  use last break at end ;
		 else begin "save info"
		    More_ 0;			!  set flag var to 0 ;
		    F:LSiz[S]_ F:Line[S];	!  save total size in lines ;
		    F:PSiz[S]_ F:PTxt[S];	!  save total size in pages ;
		    F:MSiz[S]_ F:MTxt[S];	!  save total size in pages ;
		 end "save info";
		Done "one line";		! Finish loop ;

	     end "end of file";			! Guess, read next page ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then return( null );		! error mapping! ;

	    ! ** assume: here at the beginning of the page ** ;
	    If ( Dir < 0 )			! Forward or Backward? ;
	     then Copy_ Byte_ point( 7, memory[(F:Page[S]+1) lsh 9], -1 )
	     else Copy_ Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );

	    If ( ( Page * CharPerPage ) > F:Size[S] )
	     then Count_ F:Size[S] mod CharPerPage
	     else Count_ CharPerPage;

	 end "need next page";

     end "one line";

    return( Str );			! give 'em what they came for ;

end "VM Line";


Internal Boolean Procedure VMText( Integer Slot; String Text );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMText( Slot, Text, Dir(0) )				;
!		Writes the next consecutive line or lines to the file	;
!		that is connected to the specified slot.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Text"
    Integer Page, Byte, Char, Count;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( !rh( F:Mode[S] ) )		! were we writing? ;
     then return( false );		! no, don't bother! ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then F:Char[S]_ 0;			!   Set before first character ;

    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
     then begin
	Print( "Page map error: p",page,"  c",F:Char[S],"  f",F:Chan[S],crlf );
	return( false );		! if no page, error return ;
     end;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);

    Count_ CharPerPage - Count;		! Fix count (# left) ;

    while ( length( Text ) )		! Must have some text left ;
     do begin "writing line"

	If ( Count > 0 )		! Must have room left on page ;
	 then begin "more characters"	!  to even try to write ;

	    If not( Char_ Lop( Text ) )	! if char = null then try next ;
	     then continue "writing line";

	    IDpb( Char, Byte );		! deposit byte at position ;
	    F:Char[S]_ F:Char[S] + 1;	! Update file character count ;

	    Case ( Char ) of begin	! check for end of line ;
		[#cr] F:CRet[S]_ #CR;	! remember we saw this ;

		[#lf][#vt][#ff][#eot] begin "count lines"
		  F:Last[S]_ Char;		! remember eol character ;
		  F:Line[S]_ F:Line[S] + 1;	! count lines seen ;
		  If ( Char = #FF )		! for each FF seen ;
		   then F:PTxt[S]_ F:PTxt[S]+1;	!  count a text page ;
		  If ( Char = #EOT )		! for each EOT seen ;
		   then F:MTxt[S]_ F:MTxt[S]+1;	!  count a text message ;
		 end "count lines";

		[else] F:CRet[S]_ 0	! forget we saw a cr ;
	     end;

	    Count_ (Count-1) max 0;	! keep character count ;

	 end "more characters"
	 else begin "need next page"	! If no-more-characters ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then begin
		Print( "Page(2) map error: ",page," ",F:Char[S],crlf );
		return( false );	! if no page, error return ;
	     end;

	    Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );
	    Count_ CharPerPage;		! always a full page to write in ;

	 end "need next page";

     end "writing line";

    If ( F:Char[S] geq F:Size[S] )	! At or Past end of file? ;
     then begin "end of file"

	F:Size[S]_ F:Char[S];		!  save size in characters ;
	F:LSiz[S]_ F:Line[S];		!  save total size in lines ;
	F:PSiz[S]_ F:PTxt[S];		!  save total size in pages ;
	F:MSiz[S]_ F:MTxt[S];		!  save total size in pages ;

     end "end of file";			! Guess, read next page ;

    return( true );			! give 'em what they came for ;

end "VM Text";


Internal Boolean Procedure VMMove( Integer Slot, HowMany(1) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMMove( Slot, HowMany(1) )					;
!		Moves the position pointer forward or backward up to	;
!		HowMany lines in the file.  Returns true if the slot is	;
!		active and HowMany lines exist, otherwise it returns	;
!		false and leaves the pointer positioned at logical end	;
!		of file (at the beginning if direction is backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Move"
    Own Integer Brk;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( HowMany )			! we can always move ;
     then return( true );		!  a distance of 0 ;

    while ( HowMany )			! while lines to go read them ;
     do begin "moving lines"

	If not( length( VMLine( Slot, Brk, HowMany < 0 ) ) or Brk )
	 then return( false );		!  then take the cows to town ;

	If ( HowMany > 0 )		! decrement the right direction ;
	 then HowMany_ HowMany - 1	!  down to zero  ;
	 else HowMany_ HowMany + 1;	!  or up to zero ;

     end "moving lines";

    return( true );			! give 'em what they came for ;

end "VM Move";


Internal Simple Boolean Procedure VMFile( String Spec; Integer Mode(VM$Read) );
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMFile( StringSpec, AccessMode )				;
!		Opens a file for the specified access.  A positive	;
!		slot number is returned if the file is available.  A 	;
!		0 means no slots and a negative value means there was	;
!		some file error or the file is not available.		;
!									;
! ----------------------------------------------------------------------;
begin "VM File"
    Own Safe Integer Array File[ 0 : !RBLIC ];
    Preset!with '17, cvsix("DSK   "), 0;
    Own Safe Integer Array Dev[ 0 : 2 ];
    Own Integer Slot;

    If not( Slot_ VMSlot )		! If no Slots available ;
     then return( false );		!  then no file opened ;

    If not( S_ Files[ Slot ] )		! slot assigned? *Debug check* ;
     then return( false );		!  not this time *huh why not* ;

    If not( VMSpec( Spec, FileSpec ) )	! trouble with the spec? ;
     then return( false );		!  then don't do anything ;

    If not(VM$Read leq !rh(Mode) leq VM$Multi)	! if an invalid mode ;
     then return( false );		! Read, Write, Update, Multi ;

    Dev[ 0 ]_ Ldb( Point(6,Mode,17) );	! Set proper mode (!ioASC) ;
    Dev[ 1 ]_ FileSpec[ S!Dev ];	! Setup device block ;
    Chnior( F:Chan[S],Dev[0],!chOPN );	! OPEN [ '17, Dev, 0 ] ;
    If not( !Skip! )			! If open-failure ;
     then begin "open failure"		!  then no file opened ;
	VMFree( Slot );			! Free the slot ;
	return( !Xwd( -1,-1 ) );	!  and return ;
     end "open failure";

    Mode_ !rh( F:Mode[S]_ Mode );	! Remember this as we need to ;
    arrclr( File );			! Clear out unused fields ;
    File[ !RBCNT ]_ !RBLIC;		! Setup file lookup block ;
    if ( FileSpec[ S!Usr ] )
     then File[ !RBPPN ]_ location( FileSpec[ S!Usr ] );
    File[ !RBNAM ]_ FileSpec[ S!Nam ];
    File[ !RBEXT ]_ FileSpec[ S!Ext ] land (-1 lsh 18);

    If ( VM$Write neq Mode )		! if mode neq VM$Write ;
     then begin "read update"		!   do lookup ;

	Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
	If not( !Skip! ) and ( 0 = !rh(File[!RBEXT]) )
	 then begin "not found"		! no skip and file not found ;
	    If ( VM$Read neq Mode )	! if mode neq VM$Read, do create ;
	     then begin "update stuff"

		Chnior( F:Chan[ S ], File[ !RBCNT ], !chENT );
		if ( !Skip! )		! enter ok, so close & lookup ;
		 then begin "ok find it"
		    Chnior( F:Chan[ S ], memory[0], !chCLS );
		    Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
		 end "ok find it";

	     end "update stuff";	! if !skip! found or created file ;
	 end "not found";		!  else some other file error ;

	if not( !Skip! )		! lookups failed - not ERFNF% ;
	 then begin "huh what's up"	! unless happened 2nd time ;
	    VMFree( Slot );		! so, clear out and return ;
	    return( !Xwd( -1,!rh(File[!RBEXT]) ) );
	 end "huh what's up";

     end "read update";			! have old file, or new file ;

    If ( VM$Read neq Mode )		! for VM$Write, VM$Update, VM$Multi ;
     then Chnior( F:Chan[ S ], File[ !RBCNT ],
		   if (Mode = VM$Multi)	! if mode eql VM$Multi ;
		     then !chMEN	!  then use multiple enter ;
		     else !chENT );	!  else use normal enter ;

    If not( !Skip! )			! If lookup-enter failure ;
     then begin "no file or access"	!  then Free the slot ;
	VMFree( Slot );			!  and return error code ;
	return( !Xwd( -1,!rh(File[!RBEXT]) ) );
     end "no file or access";

    F:FPPN[ S ]_ File[!RBPPN];		! File directory ;
    F:Name[ S ]_ File[!RBNAM];		! File name ;
    F:FExt[ S ]_ File[!RBEXT];		! File extension ;
    F:Size[ S ]_ File[!RBSIZ] * 5;	! File size in characters (Rounded) ;
    F:FLic[ S ]_ !rh( File[!RBLIC] );	! File license ;

    F:Time[ S ]_ (((File[!RBPRV] lsh -12) land '3777) * 60 )
	       + ((File[!RBLIC] lsh -18) land '77);
    F:Date[ S ]_ (Ldb( Point( 2,File[!RBEXT],21 ) ) lsh 12)
	       + (File[!RBPRV] land '7777);

    if ( Mode > VM$Read ) and		! are we writing and ;
	( VM$Append land F:Mode[ S ] )	! wanting to append ;	
	and  ( F:Size[ S ] )		! must have something ;
     then begin "tack it on"
	VMMove( Slot, -1 );		! backup from the end ;
	VMMove( Slot, 1 );		! and move forward ;
     end "tack it on";
	 
    return( Slot );			! Return the slot number ;

end "VM File";

end "VM Package";
    2VMFILE.006   ?30-Jun-86 23:26:48  YUVHIL    entry
	VMFile, VMFree, VMSpec,
	VMChan, VMPMap,
	VMLine, VMText, VMMove,
	VMGetC, VMSetC,
	VMGetW, VMSetW
	define FT!InternalPages = True;
	Ifcr not FT!InternalPages thenc , VMInit endc

;

begin "VM Package"

  require "(SAILIB)SAIL.DEF"   source!file;
  require "(SAILIB)UUOSYM.DEF" source!file;
  require "(CARL)VMFILE.DEF"   source!file;


  Define
	MaxSlot = 47			! number of available slots ;
  ,	MemMax  = MaxSlot * 512		! pages in words ;
  ,	CharPerPage = 512 * 5		! characters per page ;
  ,	BackByte    = '430000000001	! offset to backup a byte ;
  ,	AddaByte    = '070000000000	! offset to increment byte ;
  ;



  Record!Class F (  Integer Page;	! memory page to use ;
		    Integer File;	! file page in use ;
		    Integer Chan;	! channel for file open ;
		    Integer Mode;	! file access mode ;
		    Integer Name;	! file name in sixbit ;
		    Integer FExt;	! file extension in sixbit ;
		    Integer FPPN;	! file ppn ;
		    Integer Char;	! character pointer in file ;
		    Integer Line;	! line pointer in file +/-;
		    Integer PTxt;	! text page pointer in file +/- ;
		    Integer MTxt;	! text message pointer in file +/- ;
		    Integer Last;	! last eol character ;
		    Integer CRet;	! carriage return on line ;
		    Integer Size;	! character size of file ;
		    Integer LSiz;	! lines in file (if known) ;
		    Integer PSiz;	! pages in file (if known) ;
		    Integer MSiz;	! messages in file (if known) ;
		    Integer FLic;	! file license info ;
		    Integer Time;	! file creation time in seconds ;
		    Integer Date    );	! file creation date ;

  R!P (F) S;
  Safe R!P (F) Array Files[ 1 : MaxSlot ];

  Integer VMMem, VMPage;			! virtual memory pointers  ;
  Integer MaxSlots;				! remember available slots ;

  Own Safe Integer Array FileSpec[ S!Dev : S!Ext ];

 Ifcr FT!InternalPages thenc			! selectable by feature sw ;
  Preset!with [ MemMax + 512 ] 0;		! expect to use 1 : MemMax ;
  Own Safe Integer Array VM[ 1 : MemMax+512 ];	!  entries minus page slop ;
 endc


Ifcr FT!InternalPages thenc
  Simple Procedure InitStuff;
elsec
  Internal Simple Procedure VMInit( Integer Page, Count );
endc
! ----------------------------------------------------------------------;
!									;
!	InitStuff							;
!		Routine to initialize data structures and calculate	;
!		where to put the initial cache of pages to use for	;
!		this venture.						;
!									;
!	VMInit( FirstPage, Count )					;
!		Routine to setup a cache of pages for the user to use	;
!		instead of using the preset range designated by this	;
!		package.  This is setup via the assembly parameter:	;
!		(FT!InternalPages).					;
!									;
! ----------------------------------------------------------------------;
begin "VM Init"

  Ifcr FT!InternalPages thenc		! internal definition ;
    VMPage_ (location( VM[1] ) + '777) lsh -9;
    MaxSlots_ MaxSlot;			! count of pages ;
  elsec
    VMPage_ Page;			! base page ;
    MaxSlots_ Count max MaxSlot;	! count of pages ;
  endc
    VMMem_ VMPage lsh 9;		! base memory address ;

    ArrClr( Files );			! files not open ;

end "VM Init";
Ifcr FT!InternalPages thenc
  require InitStuff initialization;
endc


Internal Simple Integer Procedure VMMaxS( Integer Count );
! ----------------------------------------------------------------------;
!									;
!	NewCount_ VMMaxS( Count )					;
!		Routine to limit the maximum number of slots to use	;
!		in this package.  Useful to insure that specifically	;
!		allocated channels between the top of SAILs channel	;
!		range and those used by VMFILE are not used.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Max Slots"

    return( MaxSlots_ Count max MaxSlot );	! count of pages ;

end "VM Max Slots";


Simple Integer Procedure MapPage( r!p (F) Rec; Integer NewPage );
! ----------------------------------------------------------------------;
!									;
!	MapPage( Rec, NewPage )						;
!		Routine to map the specified new file-page into the	;
!		page designated by F:Page[Rec] and update F:File[Rec]	;
!		to NewPage.						;
!									;
! ----------------------------------------------------------------------;
begin "Map Page"
    Own safe integer array Arg[ 0:1 ];
    Own integer Status, Err;

    If ( F:File[Rec] = NewPage )		! if the same page ;
     then begin "check protection"

	If not( !rh( F:Mode[Rec] ) )		! if no writing request ;
	 then return( NewPage );		! then nothing special ;
	Status_Calli(F:Page[Rec],calli!PAGSTS);	! read page protection ;
	If ( '3 = ( Status land '7 ) )		! if read/write? ;
	 then return( NewPage );		!  then nothing to do ;
	Err_ Calli( !Xwd( '6001,F:Page[Rec] ), calli!VPROT );
	If ( !skip! )				! if no problems, return! ;
	 then return( NewPage )			!  nothing else to do ;
	 else begin				! otherwise complain and ;
	    Print( "Map error: ",cvos(Err)," pagsts: ",cvos(Status),crlf );
	    return( F:File[Rec]_ 0 );		! make believe un-mapped ;
	 end;

     end "check protection";

    Calli( Arg[0]_ !Xwd('2001,F:Page[Rec]), calli!VCLEAR );
    If ( VM$Read neq !rh( F:Mode[Rec] ) )	! if we're writing then ;
     then Arg[0]_ !Xwd('6001,F:Page[Rec]);	!  make it .prrw not .prro ;
    Arg[1]_ NewPage;				! point at file page ;
    Chnior( F:Chan[Rec], Arg[0], !chMFP );	! map the page ;
    Start!code MOVEM '3,ERR; end;		! remember any errors ;

    If ( !Skip! )				! remember file page ;
     then F:File[Rec]_ NewPage			!  NewPage (if map ok) ;
     else begin "map failure"			! else check the fault ;
	F:File[Rec]_ 0;				! default (if map fails) ;

	If ( !rh( F:Mode[Rec] ) ) and		! if writing and past ;
	      ( !rh(ERR)='6 )			!   highest page (FLPHP%) ;
	 then begin "create page"		!  then try to create it ;

	    Chnior( F:Chan[Rec], NewPage, !chCFP );
	    If ( !Skip! )			! check success flag ;
	     then begin "try map again"		! if ok, then try map ;
		Chnior( F:Chan[Rec], Arg[0], !chMFP );
		if ( !Skip! )			! any errors? ;
		 then F:File[Rec]_ NewPage;	! no, it's ok ;
	     end "try map again";

	 end "create page";
     end "map failure";

    return( F:File[Rec] );			! return current mapping ;

end "Map Page";


Integer Procedure VM!PMap( Integer Slot, NewPage );
Return( MapPage( Files[ Slot ], NewPage ) );

Internal Simple Integer Procedure VMPMap( Integer Slot, NewPage );
! ----------------------------------------------------------------------;
!									;
!	NewPage_ VMPMap( Slot, NewPage )				;
!		Routine to map the specified new page into the map	;
!		slot for this slot and return the new page on success.	;
!		Returns 0 if any errors occur, including wrong page	;
!		protection.						;
!									;
! ----------------------------------------------------------------------;
begin  "VM Page Map"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    return( VM!PMap( Slot, NewPage ) );	! return the proper page ;

end "VM Page Map";


Simple Integer Procedure Dbp( Reference Integer Ptr );
! ----------------------------------------------------------------------;
!									;
!	Dbp( AsciiBytePointer )						;
!		Routine to decrement a 7-bit byte pointer.  Its only	;
!		magic relies on the assumption that a negative pointer	;
!		is setup as '440700 from the point/bbpp operation that	;
!		creates a ildb pointer to the first byte of the word.	;
!		This routine fixes this to point to the last byte of	;
!		the previous word whenever this is seen.  In "this"	;
!		initial case, this works so that the pointer is never	;
!		decremented the WRONG way.				;
!									;
! ----------------------------------------------------------------------;
begin "Decrement Byte Pointer"

    If ( Ptr < 0 )			! initially '440700,,addr ;
     then Ptr_ Ptr - BackByte		! so set to prev-last byte ;
     else Ptr_ Ptr + AddaByte;		! else decrement a byte ;

    If ( Ptr < 0 )			! must now be '440700,,addr ;
     then Ptr_ Ptr - BackByte;		! so set to prev-last byte ;

    return( Ptr );			! so it can be an expression ;

end "Decrement Byte Pointer";


Simple Integer procedure GetText( Reference string Line;
				  Integer Byte, Count; String Chars );
begin "get text"
    Own integer wp;
    String Str;

    while ( length( Line ) )
     do begin "get data"

	Str_ Chars;				! copy break chars ;
	while ( length( Str ) )			! if any break chars ;
	 do if ( Line = Lop( Str ) )		!  and match a brk ;
	     then return( Line );		!  return that character ;

	if ( 0 leq count_ count - 1 )		! if room left in string ;
	 then if ( "a" leq wp_lop(Line) )	!  then check case ;
	       then idpb( wp-'100, byte )	!    lowercase to sixbit ;
	       else idpb( wp-'40, byte )	!    uppercase to sixbit ;
	 else wp_ lop( Line );			!  throw away extras ;

     end "get data";

    return( 0 );				! no line left? ;

end "get text";


Internal Simple Boolean Procedure VMSpec(String L; Integer array Spec );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMSpec( FileSpecification, SpecificationBlock )		;
!		Routine to read a string file specification and build	;
!		the special file block used by the VMFile routine.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Spec"

    arrclr( Spec );				! clear out the array ;

    GetText( L, point( 6,Spec[S!Nam],-1 ), 6, ":(." );

    if ( ":" = L )				! it was a device, good! ;
     then begin
	lop( L );				! throw away the colon and ;
	Spec[S!Dev] swap Spec[S!Nam];		! swap data to right places ;
     end
     else Spec[S!Dev]_cvsix("DSK");		!  and fill in the device ;

    if ( "(" = L )				! if it starts with "(" ;
     then begin "get user"			!  then pick up username ;
	lop( L );				!    eat the "(" ;
	GetText( L, point( 6,Spec[ S!Usr ],-1 ), 12, ")" );
	lop( L );				!    eat the ")" ;
     end "get user"
     else begin "default user"			! set default if no user ;
	Spec[ S!Usr   ]_ calli( '31, '41 );	! .GTNM1 (GFD user 1-6)  ;
	Spec[ S!Usr+1 ]_ calli( '32, '41 );	! .GTNM2 (GFD user 7-12) ;
	If not( !Skip! )			! set blank if GETTAB fails ;
	 then Spec[ S!Usr ]_ Spec[ S!Usr+1 ]_ 0;
     end "default user";

    if not( length( L ) or Spec[S!Nam] )	! must have a name ;
     then return( false );			!  so return false ;

    if not( "." = L or Spec[S!Nam] )
     then GetText( L, point( 6,Spec[ S!Nam ],-1 ), 6, "." );

    if not( Spec[S!Nam] )			! seen anyone ;
     then return( false );			! no, go home ;

    if ( "." = L )				! if dot seen ;
     then begin "get ext"
	lop( L );				!  then chop it off ;
	GetText( L, point( 6,Spec[ S!Ext ],-1 ), 3, " "&'11 );
     end "get ext";

    return( true );				! got here, return ok ;

end "VM Spec";


Internal Simple Integer Procedure VMChan;
! ----------------------------------------------------------------------;
!									;
!	Chan_ VMChan							;
!		Returns the next available channel for this user.	;
!		If none are available, returns -1.			;
!									;
! ----------------------------------------------------------------------;
begin "VM Chan"

    start!code

	ReDefine !chNXT = '46;		! get next channel ;

	Hrloi	'1,!chNXT;		! setup [.chnxt,,-1] ;
	uuo!CHANIO '1,;			! to get next available ;
	  seto	'1;			! no channels available ;
	skipl	'1;			! if less than zero ;
	  tlz	'1,-1;			!  skip, else zero left ;

    end;

end "VM Chan";


Simple Integer Procedure VMSlot;
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMSlot							;
!		Returns the next available file slot in the internal	;
!		file table.  If no slots or channels are available,	;
!		returns 0.  Array Files[slot] is setup with F:Chan,	;
!		F:Page and F:Char.					;
!									;
! ----------------------------------------------------------------------;
begin "VM Slot"
    Own Integer Slot, Chan;

    For Slot_ 1 upto MaxSlots		! check each legal slot ;
     do if not( Files[ Slot ] )		! if it's free ;
	 then begin "setup slot"	!  then make it available ;

	    S_ Files[ Slot ]_ new!record( F );	! initialize record ;

	    if ( 0 > Chan_ VMChan )		! is it legal ;
	     then begin "bad channel"		!  nope. ;
		Files[ Slot ]_ null!record;	!   clear slot ;
		return( 0 );			!   and return ;
	     end "bad channel";

	    F:Chan[ S ]_ Chan;			! copy the channel ;
	    F:Page[ S ]_ VMPage  + Slot - 1;	! memory page ;
	    F:File[ S ]_ F:Char[ S ]_ -1;	! file/char position ;

	    S_ null!record;		! free up working pointer ;

	    return( Slot );		! give caller a slot number ;

	 end "setup slot";

    return( 0 );

end "VM Slot";


Internal Simple Integer Procedure VMGetC( Integer Slot, Index(VM$Char) );
! ----------------------------------------------------------------------;
!									;
!	Position_ VMGetC( Slot, Index(VM$Char) )			;
!		Read the specified characteristic from the file table.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Get Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( -2 );			!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( -2 );			!  not this time ;

    Case Index of begin
	[VM$Char]   return( F:Char[ S ] );	! return character position ;
	[VM$Line]   return( F:Line[ S ] );	! return line position ;
	[VM$Page]   return( F:PTxt[ S ] );	! return page position ;
	[VM$Msg]    return( F:MTxt[ S ] );	! return message position ;
	[VM$Eol]    return( F:Last[ S ] );	! return last eol char ;
	[VM$ECR]    return( F:CRet[ S ] );	! return last cr on line ;
	[VM$Size]   return( F:Size[ S ] );	! return file size in chars ;
	[VM$LSize]  return( F:LSiz[ S ] );	! return file size in lines ;
	[VM$PSize]  return( F:PSiz[ S ] );	! return file size in pages ;
	[VM$MSize]  return( F:MSiz[ S ] );	! return file size in msgs ;
	[VM$Lic]    return( F:FLic[ S ] );	! return file license ;
	[VM$Access] return( F:Mode[ S ] );	! return file access mode ;
	[VM$Time]   return( F:Time[ S ] );	! return file creation time ;
	[VM$Date]   return( F:Date[ S ] );	! return file creation date ;
	[VM$Base]   return( F:Page[ S ] );	! return memory base page ;
	[VM$FPage]  return( F:File[ S ] );	! return file page on dsk ;
	[VM$Chan]   return( F:Chan[ S ] );	! return physical channel ;
	[else]      return( -3 )		! illegal index ;
    end;

end "VM Get Character Pointer";



Internal Simple Integer Procedure VMSetC( Integer Slot, Position );
! ----------------------------------------------------------------------;
!									;
!	NewPosition_ VMSetC( Slot, TrialPosition )			;
!		Set the character position with the file open on the	;
!		specified slot.  All further references to the slot	;
!		will use the new file position.  If the specified	;
!		position is outside the file, the position is set to	;
!		-1.  The routine always returns the new position.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Set Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( 0 leq Position leq F:Size[S] )	! if position within range ;
     then F:Char[S]_ Position		!  then set it up ;
     else F:Char[S]_ Position_ -1;	!  else set to -1 ;

    return( Position );			! return the new position ;

end "VM Set Character Pointer";


Internal Simple Boolean Procedure VMFree( Integer Slot, Bits(0) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMFree( Slot )						;
!		Closes any open file for this slot and frees the	;
!		slot for future use.  Returns true if the slot was	;
!		in use.							;
!									;
! ----------------------------------------------------------------------;
begin "VM Free"
    preset!with 0,0,0,0;
    Own integer array delete[0:3];

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( F:File[ S ] )			! if file mapped, clear page ;
     then Calli( !Xwd( '2001, F:Page[ S ] ), calli!VCLEAR );

    If ( Bits or !rh( F:Mode[ S ] ) )	! if any writes ;
     then begin "some changes"		!  reset size & close file ;

	If ( F:Size[ S ] > 0 )		! if non-zero size ;
	 then Chniov( F:Chan[S], (F:Size[S]+4) div 5, !chFTR );
	if ( Bits = -1 )		! Special "RENAME" ;
	 then Chnior( F:Chan[S], Delete[0], !chREN );
	Chnior( F:Chan[ S ], memory[Bits], !chCLS );

     end "some changes";

    Chniov( F:Chan[ S ], 0, !chREL );	! release Slot ;
    Files[ Slot ]_ null!record;		! clear out tables ;

    return( true );			! everything is ok ;

end "VM Free";


Internal String Procedure VMLine( Integer Slot; Reference Integer More;
				  Integer Dir( 0 ) );
! ----------------------------------------------------------------------;
!									;
!	Line_ VMLine( Slot, More, Dir(0) )				;
!		Returns the next consecutive line from the file that	;
!		is connected to the specified slot.  More is set to	;
!		the line terminator (LF, FF, VT, CR or EOT) or to 0	;
!		when the end of the file is reached or the slot is 	;
!		inactive.  Dir is the direction to read the file ( 0	;
!	 	indicates forward, -1 or non-zero for backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Line"
    Integer Page, Byte, Copy, Count, Len, Last;
    Boolean Eol;
    String Str;

    More_ 0;				! Initialize for bad exits ;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( null );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( null );		!  not this time ;

    If ( Dir )				! verify proper usage of Dir ;
     then Dir_ -1			!  non-zero = backward = -1 ;
     else Dir_ +1;			!  was-zero = forward  = +1 ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then If ( Dir < 0 )		! Forward or Backward? ;
	   then F:Char[S]_ F:Size[S]	!   Set after last character ;
	   else F:Char[S]_ 0;		!   Set before first character ;

    If ( F:File[S] neq Page_ ( F:Char[S] div CharPerPage ) + 1 )
     then if not( MapPage( S, Page ) )	! Verify using right page ;
	   then return( null );		!  and page gets mapped ;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Copy_Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);
    If ( Byte < 0 )			! Means we have '440700,,x ;
     then Copy_ Byte_ Byte - BackByte;	! Point at an actual byte ;
    If ( Dir < 0 )			! If backward direction ;
     then Ibp( Copy );			!  then setup for Dbp by 1 ;

    Str_ Null;				! Initial return string ;

    If ( Dir geq 0 )			!   Fix count (# left) ;
     then If ( ( F:File[S] * CharPerPage ) > F:Size[S] )
	   then Count_ (F:Size[S] mod CharPerPage) - Count
	   else Count_ CharPerPage - Count;

    Len_ 0;				! Initialize string length ;
    F:Last[S]_ F:CRet[S]_ 0;		! Initialize break vars ;
    Last_ -1;				! Last character seen ;
    Eol_ false;				! Initialize line var ;
    While not( Eol )			! Read one line ;
     do begin "one line"

	If ( Count > 0 )		! Must have chars left ;
	 then begin "more characters"	!  to even try to read ;

	    If ( Dir < 0 )		! Forward or Backward? ;
	     then Dbp( Copy )		!  position the character ;
	     else Ibp( Copy );		!  pointer in the page ;

	    F:Char[S]_ F:Char[S] + Dir;	! Update file character count ;

	    Case More_ Ldb( Copy ) of begin	! check for end of line ;
		[#nul] begin "found eos break"
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    If ( Dir < 0 ) and		! Backing up? ;
		       not( F:Last[S] )		! First time through? ;
		     then Dbp( Byte )		!  yes, keep it this way ;
		     else Byte_ Copy;		!  no, update pointer ;
		    Len_ 0;			! Reset string length ;
		 end "found eos break";

		[#cr] begin "found return"
		    If ( Dir < 0 )
		     then if ( #LF leq Last leq #FF )
			   then F:CRet[S]_ #CR	! remember we saw this ;
			   else begin "lone cr"
			      If ( Copy = Byte )	! if first char ;
			       then F:Last[S]_ More	!  remember and go ;
			       else begin "eol cr"	! else do eol stuff ;
				 Eol_ true;		! set end of line ;
				 More_ F:Last[S];	! and get last one ;
				 F:Char[S]_ F:Char[S]+1	! bump pointer by 1 ;
			       end "eol cr";
			   end "lone cr";
		    If ( ( Dir > 0 ) and ( #CR = Last ) )
		     then Eol_ true;		! flag as end of line ;
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    Byte_ Copy;			! synchronize pointers ;
		    Len_ 0;			! Reset string length ;
		 end "found return";

		[#lf][#vt][#ff][#eot] begin "found eol break"
		    Eol_ true;			! looks like one? ;
		    if ( Dir < 0 )		! were we going backward? ;
		     then if ( Copy = Byte )	!  and the first character ;
			   then begin "not eol"
			      Eol_ false;	!  yes, not really eol ;
			      F:Last[S]_ More;	!  remember this for later ;
			      F:Line[S]_ F:Line[S] + Dir;	! each line ;
			      If ( More = #FF )			! each FF ;
			       then F:PTxt[S]_ F:PTxt[S] + Dir;	! text page ;
			      If ( More = #EOT )		! each EOT ;
			       then F:MTxt[S]_ F:MTxt[S] + Dir;	! message ;
			   end "not eol"
			   else begin "got eol"
			      F:Char[S]_ F:Char[S] + 1;		! each char ;
			      More_ F:Last[S];			! eol-brk ;
			   end "got eol"
		     else begin "forward eol"
			If ( Last = #CR ) and ( #LF leq More leq #FF )
			 then F:CRet[S]_ Last;		! mark CR before Brk ;
			If ( More = #FF )		! for each FF seen ;
			 then F:PTxt[S]_ F:PTxt[S]+Dir;	!  count a text page ;
			If ( More = #EOT )		! for each EOT seen ;
			 then F:MTxt[S]_ F:MTxt[S]+Dir;	!  count a text message ;
			F:Line[S]_ F:Line[S] + Dir;	! count each line ;
		     end "forward eol";
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		 end "found eol break";

		[else] begin "normal character"
		    If ( Last = #CR ) and ( Dir > 0 )
		     then begin "lonely cr"	! else do eol stuff ;
			Eol_ true;		! set end of line ;
			F:Char[S]_ F:Char[S]-1;	! bump pointer by 1 ;
			More_ #CR;		! set eol to CR ;
			If ( Len )		! length to concatenate? ;
			 then Str_ Str & StMake( Byte, Len );
		     end "lonely cr"
		     else Len_ Len + 1		!  increment string length ;
		 end "normal character"
	    end;

	    If ( memory[ !rh( copy ) ] land 1 )	! bit 35 set ;
	     then begin "sequence numbers"	! in this word? ;

		If ( Dir < 0 )
		 then begin "seq backward"
		    F:Char[S]_ F:Char[S] - 4;	! tab already seen backwards ;
		    Count_ Count - 4;		!  update counts by 4 chars ;
		    If ( Len > 2 )
		     then begin "add text"	!  +1 for tab after seq # ;
			Ibp( Copy );		! make string skipping tab ;
			Str_ StMake( Copy, Len-2 ) & Str;
		     end "add text"
		 end "seq backward"
		 else begin "seq forward"
		    F:Char[S]_ F:Char[S] + 5;	! include tab in count here ;
		    Count_ Count - 5;		!  update counts by 5 chars ;
		    if ( Len neq 1 )
		     then Print( "*** Bad SEQ # in text file. ***"& Crlf );
		 end "seq forward";

		Byte_ Copy_ Copy + Dir;		!  update 1 word ;
		Len_ 0;				! Reset length ;

	     end "sequence numbers";

	    If ( 0 = Count_ (Count-1) max 0 )	! If now out of characters ;
	     then begin "fake eos break"
		If ( Len )			! length to concatenate? ;
		 then if ( Dir < 0 )
		       then Str_ StMake( Dbp( Copy ), Len ) & Str
		       else Str_ Str & StMake( Byte, Len );
		Len_ 0;				! Reset string length ;
	     end "fake eos break";

	    If ( More )				! if this is not a null ;
	     then Last_ More;			! last char for next time ;

	 end "more characters"
	 else begin "need next page"		! If no-more-characters ;

	    If ( F:Char[S] geq F:Size[S] )	! Forwards at end or ;
	       or ( F:Char[S] leq 0 )		!  backwards at beginning ;
	     then begin "end of file"		! At end-of-file? ;

		Eol_ true;			! Set flags true ;
		If ( Dir < 0 )			! If backing up ;
		 then More_ F:Last[S]		!  use last break at end ;
		 else begin "save info"
		    More_ 0;			!  set flag var to 0 ;
		    F:LSiz[S]_ F:Line[S];	!  save total size in lines ;
		    F:PSiz[S]_ F:PTxt[S];	!  save total size in pages ;
		    F:MSiz[S]_ F:MTxt[S];	!  save total size in pages ;
		 end "save info";
		Done "one line";		! Finish loop ;

	     end "end of file";			! Guess, read next page ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then return( null );		! error mapping! ;

	    ! ** assume: here at the beginning of the page ** ;
	    If ( Dir < 0 )			! Forward or Backward? ;
	     then Copy_ Byte_ point( 7, memory[(F:Page[S]+1) lsh 9], -1 )
	     else Copy_ Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );

	    If ( ( Page * CharPerPage ) > F:Size[S] )
	     then Count_ F:Size[S] mod CharPerPage
	     else Count_ CharPerPage;

	 end "need next page";

     end "one line";

    return( Str );			! give 'em what they came for ;

end "VM Line";


Internal Boolean Procedure VMText( Integer Slot; String Text );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMText( Slot, Text, Dir(0) )				;
!		Writes the next consecutive line or lines to the file	;
!		that is connected to the specified slot.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Text"
    Integer Page, Byte, Char, Count;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( !rh( F:Mode[S] ) )		! were we writing? ;
     then return( false );		! no, don't bother! ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then F:Char[S]_ 0;			!   Set before first character ;

    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
     then begin
	Print( "Page map error: p",page,"  c",F:Char[S],"  f",F:Chan[S],crlf );
	return( false );		! if no page, error return ;
     end;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);

    Count_ CharPerPage - Count;		! Fix count (# left) ;

    while ( length( Text ) )		! Must have some text left ;
     do begin "writing line"

	If ( Count > 0 )		! Must have room left on page ;
	 then begin "more characters"	!  to even try to write ;

	    If not( Char_ Lop( Text ) )	! if char = null then try next ;
	     then continue "writing line";

	    IDpb( Char, Byte );		! deposit byte at position ;
	    F:Char[S]_ F:Char[S] + 1;	! Update file character count ;

	    Case ( Char ) of begin	! check for end of line ;
		[#cr] F:CRet[S]_ #CR;	! remember we saw this ;

		[#lf][#vt][#ff][#eot] begin "count lines"
		  F:Last[S]_ Char;		! remember eol character ;
		  F:Line[S]_ F:Line[S] + 1;	! count lines seen ;
		  If ( Char = #FF )		! for each FF seen ;
		   then F:PTxt[S]_ F:PTxt[S]+1;	!  count a text page ;
		  If ( Char = #EOT )		! for each EOT seen ;
		   then F:MTxt[S]_ F:MTxt[S]+1;	!  count a text message ;
		 end "count lines";

		[else] F:CRet[S]_ 0	! forget we saw a cr ;
	     end;

	    Count_ (Count-1) max 0;	! keep character count ;

	 end "more characters"
	 else begin "need next page"	! If no-more-characters ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then begin
		Print( "Page(2) map error: ",page," ",F:Char[S],crlf );
		return( false );	! if no page, error return ;
	     end;

	    Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );
	    Count_ CharPerPage;		! always a full page to write in ;

	 end "need next page";

     end "writing line";

    If ( F:Char[S] geq F:Size[S] )	! At or Past end of file? ;
     then begin "end of file"

	F:Size[S]_ F:Char[S];		!  save size in characters ;
	F:LSiz[S]_ F:Line[S];		!  save total size in lines ;
	F:PSiz[S]_ F:PTxt[S];		!  save total size in pages ;
	F:MSiz[S]_ F:MTxt[S];		!  save total size in pages ;

     end "end of file";			! Guess, read next page ;

    return( true );			! give 'em what they came for ;

end "VM Text";


Internal Boolean Procedure VMMove( Integer Slot, HowMany(1) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMMove( Slot, HowMany(1) )					;
!		Moves the position pointer forward or backward up to	;
!		HowMany lines in the file.  Returns true if the slot is	;
!		active and HowMany lines exist, otherwise it returns	;
!		false and leaves the pointer positioned at logical end	;
!		of file (at the beginning if direction is backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Move"
    Own Integer Brk;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( HowMany )			! we can always move ;
     then return( true );		!  a distance of 0 ;

    while ( HowMany )			! while lines to go read them ;
     do begin "moving lines"

	If not( length( VMLine( Slot, Brk, HowMany < 0 ) ) or Brk )
	 then return( false );		!  then take the cows to town ;

	If ( HowMany > 0 )		! decrement the right direction ;
	 then HowMany_ HowMany - 1	!  down to zero  ;
	 else HowMany_ HowMany + 1;	!  or up to zero ;

     end "moving lines";

    return( true );			! give 'em what they came for ;

end "VM Move";


Internal Simple Boolean Procedure VMFile( String Spec; Integer Mode(VM$Read) );
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMFile( StringSpec, AccessMode )				;
!		Opens a file for the specified access.  A positive	;
!		slot number is returned if the file is available.  A 	;
!		0 means no slots and a negative value means there was	;
!		some file error or the file is not available.		;
!									;
! ----------------------------------------------------------------------;
begin "VM File"
    Own Safe Integer Array File[ 0 : !RBLIC ];
    Preset!with '17, cvsix("DSK   "), 0;
    Own Safe Integer Array Dev[ 0 : 2 ];
    Own Integer Slot;

    If not( Slot_ VMSlot )		! If no Slots available ;
     then return( false );		!  then no file opened ;

    If not( S_ Files[ Slot ] )		! slot assigned? *Debug check* ;
     then return( false );		!  not this time *huh why not* ;

    If not( VMSpec( Spec, FileSpec ) )	! trouble with the spec? ;
     then return( false );		!  then don't do anything ;

    If not(VM$Read leq !rh(Mode) leq VM$Multi)	! if an invalid mode ;
     then return( false );		! Read, Write, Update, Multi ;

    Dev[ 0 ]_ Ldb( Point(6,Mode,17) );	! Set proper mode (!ioASC) ;
    Dev[ 1 ]_ FileSpec[ S!Dev ];	! Setup device block ;
    Chnior( F:Chan[S],Dev[0],!chOPN );	! OPEN [ '17, Dev, 0 ] ;
    If not( !Skip! )			! If open-failure ;
     then begin "open failure"		!  then no file opened ;
	VMFree( Slot );			! Free the slot ;
	return( !Xwd( -1,-1 ) );	!  and return ;
     end "open failure";

    Mode_ !rh( F:Mode[S]_ Mode );	! Remember this as we need to ;
    arrclr( File );			! Clear out unused fields ;
    File[ !RBCNT ]_ !RBLIC;		! Setup file lookup block ;
    if ( FileSpec[ S!Usr ] )
     then File[ !RBPPN ]_ location( FileSpec[ S!Usr ] );
    File[ !RBNAM ]_ FileSpec[ S!Nam ];
    File[ !RBEXT ]_ FileSpec[ S!Ext ] land (-1 lsh 18);

    If ( VM$Write neq Mode )		! if mode neq VM$Write ;
     then begin "read update"		!   do lookup ;

	Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
	If not( !Skip! ) and ( 0 = !rh(File[!RBEXT]) )
	 then begin "not found"		! no skip and file not found ;
	    If ( VM$Read neq Mode )	! if mode neq VM$Read, do create ;
	     then begin "update stuff"

		Chnior( F:Chan[ S ], File[ !RBCNT ], !chENT );
		if ( !Skip! )		! enter ok, so close & lookup ;
		 then begin "ok find it"
		    Chnior( F:Chan[ S ], memory[0], !chCLS );
		    Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
		 end "ok find it";

	     end "update stuff";	! if !skip! found or created file ;
	 end "not found";		!  else some other file error ;

	if not( !Skip! )		! lookups failed - not ERFNF% ;
	 then begin "huh what's up"	! unless happened 2nd time ;
	    VMFree( Slot );		! so, clear out and return ;
	    return( !Xwd( -1,!rh(File[!RBEXT]) ) );
	 end "huh what's up";

     end "read update";			! have old file, or new file ;

    If ( VM$Read neq Mode )		! for VM$Write, VM$Update, VM$Multi ;
     then Chnior( F:Chan[ S ], File[ !RBCNT ],
		   if (Mode = VM$Multi)	! if mode eql VM$Multi ;
		     then !chMEN	!  then use multiple enter ;
		     else !chENT );	!  else use normal enter ;

    If not( !Skip! )			! If lookup-enter failure ;
     then begin "no file or access"	!  then Free the slot ;
	VMFree( Slot );			!  and return error code ;
	return( !Xwd( -1,!rh(File[!RBEXT]) ) );
     end "no file or access";

    F:FPPN[ S ]_ File[!RBPPN];		! File directory ;
    F:Name[ S ]_ File[!RBNAM];		! File name ;
    F:FExt[ S ]_ File[!RBEXT];		! File extension ;
    F:Size[ S ]_ File[!RBSIZ] * 5;	! File size in characters (Rounded) ;
    F:FLic[ S ]_ !rh( File[!RBLIC] );	! File license ;

    F:Time[ S ]_ (((File[!RBPRV] lsh -12) land '3777) * 60 )
	       + ((File[!RBLIC] lsh -18) land '77);
    F:Date[ S ]_ (Ldb( Point( 2,File[!RBEXT],21 ) ) lsh 12)
	       + (File[!RBPRV] land '7777);

    if ( Mode > VM$Read ) and		! are we writing and ;
	( VM$Append land F:Mode[ S ] )	! wanting to append ;	
	and  ( F:Size[ S ] )		! must have something ;
     then begin "tack it on"
	VMMove( Slot, -1 );		! backup from the end ;
	VMMove( Slot, 1 );		! and move forward ;
     end "tack it on";
	 
    return( Slot );			! Return the slot number ;

end "VM File";

end "VM Package";
        2VMFILE.7     ^27-Sep-86 21:38:54  DOFTIF    entry
	VMFile, VMFree, VMSpec,
	VMChan, VMPMap,
	VMLine, VMText, VMMove,
	VMGetC, VMSetC,
	VMGetW, VMSetW
	define FT!InternalPages = True;
	Ifcr not FT!InternalPages thenc , VMInit endc

;

begin "VM Package"

  require "(SAILIB)SAIL.DEF"   source!file;
  require "(SAILIB)UUOSYM.DEF" source!file;
  require "(CARL)VMFILE.DEF"   source!file;

  Define Gettab(x,y) = { calli( !xwd( (x),(y) ), calli!GETTAB ) };

  Define
	MaxSlot = 47			! number of available slots ;
  ,	MemMax  = MaxSlot * 512		! pages in words ;
  ,	CharPerPage = 512 * 5		! characters per page ;
  ,	BackByte    = '430000000001	! offset to backup a byte ;
  ,	AddaByte    = '070000000000	! offset to increment byte ;
  ;



  Record!Class F (  Integer Page;	! memory page to use ;
		    Integer File;	! file page in use ;
		    Integer Chan;	! channel for file open ;
		    Integer Mode;	! file access mode ;
		    Integer Name;	! file name in sixbit ;
		    Integer FExt;	! file extension in sixbit ;
		    Integer FPPN;	! file ppn ;
		    Integer Char;	! character pointer in file ;
		    Integer Line;	! line pointer in file +/-;
		    Integer PTxt;	! text page pointer in file +/- ;
		    Integer MTxt;	! text message pointer in file +/- ;
		    Integer Last;	! last eol character ;
		    Integer CRet;	! carriage return on line ;
		    Integer Size;	! character size of file ;
		    Integer LSiz;	! lines in file (if known) ;
		    Integer PSiz;	! pages in file (if known) ;
		    Integer MSiz;	! messages in file (if known) ;
		    Integer FLic;	! file license info ;
		    Integer Time;	! file creation time in seconds ;
		    Integer Date    );	! file creation date ;

  R!P (F) S;
  Safe R!P (F) Array Files[ 1 : MaxSlot ];

  Integer VMMem, VMPage;			! virtual memory pointers  ;
  Integer MaxSlots;				! remember available slots ;

  Own Safe Integer Array FileSpec[ S!Dev : S!Ext ];

 Ifcr FT!InternalPages thenc			! selectable by feature sw ;
  Preset!with [ MemMax + 512 ] 0;		! expect to use 1 : MemMax ;
  Own Safe Integer Array VM[ 1 : MemMax+512 ];	!  entries minus page slop ;
 endc


Ifcr FT!InternalPages thenc
  Simple Procedure InitStuff;
elsec
  Internal Simple Procedure VMInit( Integer Page, Count );
endc
! ----------------------------------------------------------------------;
!									;
!	InitStuff							;
!		Routine to initialize data structures and calculate	;
!		where to put the initial cache of pages to use for	;
!		this venture.						;
!									;
!	VMInit( FirstPage, Count )					;
!		Routine to setup a cache of pages for the user to use	;
!		instead of using the preset range designated by this	;
!		package.  This is setup via the assembly parameter:	;
!		(FT!InternalPages).					;
!									;
! ----------------------------------------------------------------------;
begin "VM Init"

  Ifcr FT!InternalPages thenc		! internal definition ;
    VMPage_ (location( VM[1] ) + '777) lsh -9;
    MaxSlots_ MaxSlot;			! count of pages ;
  elsec
    VMPage_ Page;			! base page ;
    MaxSlots_ Count max MaxSlot;	! count of pages ;
  endc
    VMMem_ VMPage lsh 9;		! base memory address ;

    ArrClr( Files );			! files not open ;

end "VM Init";
Ifcr FT!InternalPages thenc
  require InitStuff initialization;
endc


Internal Simple Integer Procedure VMMaxS( Integer Count );
! ----------------------------------------------------------------------;
!									;
!	NewCount_ VMMaxS( Count )					;
!		Routine to limit the maximum number of slots to use	;
!		in this package.  Useful to insure that specifically	;
!		allocated channels between the top of SAILs channel	;
!		range and those used by VMFILE are not used.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Max Slots"

    return( MaxSlots_ Count max MaxSlot );	! count of pages ;

end "VM Max Slots";


Simple Integer Procedure MapPage( r!p (F) Rec; Integer NewPage );
! ----------------------------------------------------------------------;
!									;
!	MapPage( Rec, NewPage )						;
!		Routine to map the specified new file-page into the	;
!		page designated by F:Page[Rec] and update F:File[Rec]	;
!		to NewPage.						;
!									;
! ----------------------------------------------------------------------;
begin "Map Page"
    Own safe integer array Arg[ 0:1 ];
    Own integer Status, Err;

    If ( F:File[Rec] = NewPage )		! if the same page ;
     then begin "check protection"

	If not( !rh( F:Mode[Rec] ) )		! if no writing request ;
	 then return( NewPage );		! then nothing special ;
	Status_Calli(F:Page[Rec],calli!PAGSTS);	! read page protection ;
	If ( '3 = ( Status land '7 ) )		! if read/write? ;
	 then return( NewPage );		!  then nothing to do ;
	Err_ Calli( !Xwd( '6001,F:Page[Rec] ), calli!VPROT );
	If ( !skip! )				! if no problems, return! ;
	 then return( NewPage )			!  nothing else to do ;
	 else begin				! otherwise complain and ;
	    Print( "Map error: ",cvos(Err)," pagsts: ",cvos(Status),crlf );
	    return( F:File[Rec]_ 0 );		! make believe un-mapped ;
	 end;

     end "check protection";

    Calli( Arg[0]_ !Xwd('2001,F:Page[Rec]), calli!VCLEAR );
    If ( VM$Read neq !rh( F:Mode[Rec] ) )	! if we're writing then ;
     then Arg[0]_ !Xwd('6001,F:Page[Rec]);	!  make it .prrw not .prro ;
    Arg[1]_ NewPage;				! point at file page ;
    Chnior( F:Chan[Rec], Arg[0], !chMFP );	! map the page ;
    Start!code MOVEM '3,ERR; end;		! remember any errors ;

    If ( !Skip! )				! remember file page ;
     then F:File[Rec]_ NewPage			!  NewPage (if map ok) ;
     else begin "map failure"			! else check the fault ;
	F:File[Rec]_ 0;				! default (if map fails) ;

	If ( !rh( F:Mode[Rec] ) ) and		! if writing and past ;
	      ( !rh(ERR)='6 )			!   highest page (FLPHP%) ;
	 then begin "create page"		!  then try to create it ;

	    Chnior( F:Chan[Rec], NewPage, !chCFP );
	    If ( !Skip! )			! check success flag ;
	     then begin "try map again"		! if ok, then try map ;
		Chnior( F:Chan[Rec], Arg[0], !chMFP );
		if ( !Skip! )			! any errors? ;
		 then F:File[Rec]_ NewPage;	! no, it's ok ;
	     end "try map again";

	 end "create page";
     end "map failure";

    return( F:File[Rec] );			! return current mapping ;

end "Map Page";


Integer Procedure VM!PMap( Integer Slot, NewPage );
Return( MapPage( Files[ Slot ], NewPage ) );

Internal Simple Integer Procedure VMPMap( Integer Slot, NewPage );
! ----------------------------------------------------------------------;
!									;
!	NewPage_ VMPMap( Slot, NewPage )				;
!		Routine to map the specified new page into the map	;
!		slot for this slot and return the new page on success.	;
!		Returns 0 if any errors occur, including wrong page	;
!		protection.						;
!									;
! ----------------------------------------------------------------------;
begin  "VM Page Map"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    return( VM!PMap( Slot, NewPage ) );	! return the proper page ;

end "VM Page Map";


Simple Integer Procedure Dbp( Reference Integer Ptr );
! ----------------------------------------------------------------------;
!									;
!	Dbp( AsciiBytePointer )						;
!		Routine to decrement a 7-bit byte pointer.  Its only	;
!		magic relies on the assumption that a negative pointer	;
!		is setup as '440700 from the point/bbpp operation that	;
!		creates a ildb pointer to the first byte of the word.	;
!		This routine fixes this to point to the last byte of	;
!		the previous word whenever this is seen.  In "this"	;
!		initial case, this works so that the pointer is never	;
!		decremented the WRONG way.				;
!									;
! ----------------------------------------------------------------------;
begin "Decrement Byte Pointer"

    If ( Ptr < 0 )			! initially '440700,,addr ;
     then Ptr_ Ptr - BackByte		! so set to prev-last byte ;
     else Ptr_ Ptr + AddaByte;		! else decrement a byte ;

    If ( Ptr < 0 )			! must now be '440700,,addr ;
     then Ptr_ Ptr - BackByte;		! so set to prev-last byte ;

    return( Ptr );			! so it can be an expression ;

end "Decrement Byte Pointer";


Simple Integer procedure GetText( Reference string Line;
				  Integer Byte, Count; String Chars );
begin "get text"
    Own integer wp;
    String Str;

    while ( length( Line ) )
     do begin "get data"

	Str_ Chars;				! copy break chars ;
	while ( length( Str ) )			! if any break chars ;
	 do if ( Line = Lop( Str ) )		!  and match a brk ;
	     then return( Line );		!  return that character ;

	if ( 0 leq count_ count - 1 )		! if room left in string ;
	 then if ( "a" leq wp_lop(Line) )	!  then check case ;
	       then idpb( wp-'100, byte )	!    lowercase to sixbit ;
	       else idpb( wp-'40, byte )	!    uppercase to sixbit ;
	 else wp_ lop( Line );			!  throw away extras ;

     end "get data";

    return( 0 );				! no line left? ;

end "get text";


Internal Simple Boolean Procedure VMSpec(String L; Integer array Spec );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMSpec( FileSpecification, SpecificationBlock )		;
!		Routine to read a string file specification and build	;
!		the special file block used by the VMFile routine.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Spec"

    arrclr( Spec );				! clear out the array ;

    GetText( L, point( 6,Spec[S!Nam],-1 ), 6, ":(." );

    if ( ":" = L )				! it was a device, good! ;
     then begin
	lop( L );				! throw away the colon and ;
	Spec[S!Dev] swap Spec[S!Nam];		! swap data to right places ;
     end
     else Spec[S!Dev]_cvsix("DSK");		!  and fill in the device ;

    if ( "(" = L )				! if it starts with "(" ;
     then begin "get user"			!  then pick up username ;
	lop( L );				!    eat the "(" ;
	GetText( L, point( 6,Spec[ S!Usr ],-1 ), 12, ")" );
	lop( L );				!    eat the ")" ;
     end "get user"
     else begin "default user"			! set default if no user ;
	Spec[ S!Usr   ]_ Gettab( -1,'31 );	! .GTNM1 (GFD user 1-6)  ;
	Spec[ S!Usr+1 ]_ Gettab( -1,'32 );	! .GTNM2 (GFD user 7-12) ;
	If not( !Skip! )			! set blank if GETTAB fails ;
	 then Spec[ S!Usr ]_ Spec[ S!Usr+1 ]_ 0;
     end "default user";

    if not( length( L ) or Spec[S!Nam] )	! must have a name ;
     then return( false );			!  so return false ;

    if not( "." = L or Spec[S!Nam] )
     then GetText( L, point( 6,Spec[ S!Nam ],-1 ), 6, "." );

    if not( Spec[S!Nam] )			! seen anyone ;
     then return( false );			! no, go home ;

    if ( "." = L )				! if dot seen ;
     then begin "get ext"
	lop( L );				!  then chop it off ;
	GetText( L, point( 6,Spec[ S!Ext ],-1 ), 3, " "&'11 );
     end "get ext";

    return( true );				! got here, return ok ;

end "VM Spec";


Internal Simple Integer Procedure VMChan;
! ----------------------------------------------------------------------;
!									;
!	Chan_ VMChan							;
!		Returns the next available channel for this user.	;
!		If none are available, returns -1.			;
!									;
! ----------------------------------------------------------------------;
begin "VM Chan"

    start!code

	ReDefine !chNXT = '46;		! get next channel ;

	Hrloi	'1,!chNXT;		! setup [.chnxt,,-1] ;
	uuo!CHANIO '1,;			! to get next available ;
	  seto	'1;			! no channels available ;
	skipl	'1;			! if less than zero ;
	  tlz	'1,-1;			!  skip, else zero left ;

    end;

end "VM Chan";


Simple Integer Procedure VMSlot;
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMSlot							;
!		Returns the next available file slot in the internal	;
!		file table.  If no slots or channels are available,	;
!		returns 0.  Array Files[slot] is setup with F:Chan,	;
!		F:Page and F:Char.					;
!									;
! ----------------------------------------------------------------------;
begin "VM Slot"
    Own Integer Slot, Chan;

    For Slot_ 1 upto MaxSlots		! check each legal slot ;
     do if not( Files[ Slot ] )		! if it's free ;
	 then begin "setup slot"	!  then make it available ;

	    S_ Files[ Slot ]_ new!record( F );	! initialize record ;

	    if ( 0 > Chan_ VMChan )		! is it legal ;
	     then begin "bad channel"		!  nope. ;
		Files[ Slot ]_ null!record;	!   clear slot ;
		return( 0 );			!   and return ;
	     end "bad channel";

	    F:Chan[ S ]_ Chan;			! copy the channel ;
	    F:Page[ S ]_ VMPage  + Slot - 1;	! memory page ;
	    F:File[ S ]_ F:Char[ S ]_ -1;	! file/char position ;

	    S_ null!record;		! free up working pointer ;

	    return( Slot );		! give caller a slot number ;

	 end "setup slot";

    return( 0 );

end "VM Slot";


Internal Simple Integer Procedure VMGetC( Integer Slot, Index(VM$Char) );
! ----------------------------------------------------------------------;
!									;
!	Position_ VMGetC( Slot, Index(VM$Char) )			;
!		Read the specified characteristic from the file table.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Get Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( -2 );			!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( -2 );			!  not this time ;

    Case Index of begin
	[VM$Char]   return( F:Char[ S ] );	! return character position ;
	[VM$Line]   return( F:Line[ S ] );	! return line position ;
	[VM$Page]   return( F:PTxt[ S ] );	! return page position ;
	[VM$Msg]    return( F:MTxt[ S ] );	! return message position ;
	[VM$Eol]    return( F:Last[ S ] );	! return last eol char ;
	[VM$ECR]    return( F:CRet[ S ] );	! return last cr on line ;
	[VM$Size]   return( F:Size[ S ] );	! return file size in chars ;
	[VM$LSize]  return( F:LSiz[ S ] );	! return file size in lines ;
	[VM$PSize]  return( F:PSiz[ S ] );	! return file size in pages ;
	[VM$MSize]  return( F:MSiz[ S ] );	! return file size in msgs ;
	[VM$Lic]    return( F:FLic[ S ] );	! return file license ;
	[VM$Access] return( F:Mode[ S ] );	! return file access mode ;
	[VM$Time]   return( F:Time[ S ] );	! return file creation time ;
	[VM$Date]   return( F:Date[ S ] );	! return file creation date ;
	[VM$Base]   return( F:Page[ S ] );	! return memory base page ;
	[VM$FPage]  return( F:File[ S ] );	! return file page on dsk ;
	[VM$Chan]   return( F:Chan[ S ] );	! return physical channel ;
	[else]      return( -3 )		! illegal index ;
    end;

end "VM Get Character Pointer";



Internal Simple Integer Procedure VMSetC( Integer Slot, Position );
! ----------------------------------------------------------------------;
!									;
!	NewPosition_ VMSetC( Slot, TrialPosition )			;
!		Set the character position with the file open on the	;
!		specified slot.  All further references to the slot	;
!		will use the new file position.  If the specified	;
!		position is outside the file, the position is set to	;
!		-1.  The routine always returns the new position.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Set Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( 0 leq Position leq F:Size[S] )	! if position within range ;
     then F:Char[S]_ Position		!  then set it up ;
     else F:Char[S]_ Position_ -1;	!  else set to -1 ;

    return( Position );			! return the new position ;

end "VM Set Character Pointer";


Internal Simple Boolean Procedure VMFree( Integer Slot, Bits(0) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMFree( Slot )						;
!		Closes any open file for this slot and frees the	;
!		slot for future use.  Returns true if the slot was	;
!		in use.							;
!									;
! ----------------------------------------------------------------------;
begin "VM Free"
    preset!with 0,0,0,0;
    Own integer array delete[0:3];
    Own integer chan;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    Calli( !Xwd( '2001, F:Page[ S ] ), calli!VCLEAR );

    Chan_ F:Chan[S];			! get a handy channel ;
    If ( Bits or !rh( F:Mode[ S ] ) )	! if any writes ;
     then begin "some changes"		!  reset size & close file ;

	If ( F:Size[ S ] > 0 )		! if non-zero size ;
	 then Chniov( Chan, (F:Size[S]+4) div 5, !chFTR );

	if ( Bits = -1 )		! Special "RENAME" ;
	 then begin "rename"
	    Chnior( Chan, Delete[0], !chREN );
	    Chnior( Chan, memory[0], !chCLS );
	    Chnior( Chan, memory[0], !chREL );
	 end "rename"
	 else begin "normal"
	    Chnior( Chan, memory[Bits], !chCLS );
	    Chnior( Chan, memory[Bits], !chREL );
	 end "normal";

     end "some changes"
     else Chnior( Chan, memory[0], !chREL );

    Files[ Slot ]_ null!record;		! clear out tables ;

    return( true );			! everything is ok ;

end "VM Free";


Internal String Procedure VMLine( Integer Slot; Reference Integer More;
				  Integer Dir( 0 ) );
! ----------------------------------------------------------------------;
!									;
!	Line_ VMLine( Slot, More, Dir(0) )				;
!		Returns the next consecutive line from the file that	;
!		is connected to the specified slot.  More is set to	;
!		the line terminator (LF, FF, VT, CR or EOT) or to 0	;
!		when the end of the file is reached or the slot is 	;
!		inactive.  Dir is the direction to read the file ( 0	;
!	 	indicates forward, -1 or non-zero for backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Line"
    Integer Page, Byte, Copy, Count, Len, Last;
    Boolean Eol;
    String Str;

    More_ 0;				! Initialize for bad exits ;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( null );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( null );		!  not this time ;

    If ( Dir )				! verify proper usage of Dir ;
     then Dir_ -1			!  non-zero = backward = -1 ;
     else Dir_ +1;			!  was-zero = forward  = +1 ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then If ( Dir < 0 )		! Forward or Backward? ;
	   then F:Char[S]_ F:Size[S]	!   Set after last character ;
	   else F:Char[S]_ 0;		!   Set before first character ;

    If ( F:File[S] neq Page_ ( F:Char[S] div CharPerPage ) + 1 )
     then if not( MapPage( S, Page ) )	! Verify using right page ;
	   then return( null );		!  and page gets mapped ;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Copy_Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);
    If ( Byte < 0 )			! Means we have '440700,,x ;
     then Copy_ Byte_ Byte - BackByte;	! Point at an actual byte ;
    If ( Dir < 0 )			! If backward direction ;
     then Ibp( Copy );			!  then setup for Dbp by 1 ;

    Str_ Null;				! Initial return string ;

    If ( Dir geq 0 )			!   Fix count (# left) ;
     then If ( ( F:File[S] * CharPerPage ) > F:Size[S] )
	   then Count_ (F:Size[S] mod CharPerPage) - Count
	   else Count_ CharPerPage - Count;

    Len_ 0;				! Initialize string length ;
    F:Last[S]_ F:CRet[S]_ 0;		! Initialize break vars ;
    Last_ -1;				! Last character seen ;
    Eol_ false;				! Initialize line var ;
    While not( Eol )			! Read one line ;
     do begin "one line"

	If ( Count > 0 )		! Must have chars left ;
	 then begin "more characters"	!  to even try to read ;

	    If ( Dir < 0 )		! Forward or Backward? ;
	     then Dbp( Copy )		!  position the character ;
	     else Ibp( Copy );		!  pointer in the page ;

	    F:Char[S]_ F:Char[S] + Dir;	! Update file character count ;

	    Case More_ Ldb( Copy ) of begin	! check for end of line ;
		[#nul] begin "found eos break"
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    If ( Dir < 0 ) and		! Backing up? ;
		       not( F:Last[S] )		! First time through? ;
		     then Dbp( Byte )		!  yes, keep it this way ;
		     else Byte_ Copy;		!  no, update pointer ;
		    Len_ 0;			! Reset string length ;
		 end "found eos break";

		[#cr] begin "found return"
		    If ( Dir < 0 )
		     then if ( #LF leq Last leq #FF )
			   then F:CRet[S]_ #CR	! remember we saw this ;
			   else begin "lone cr"
			      If ( Copy = Byte )	! if first char ;
			       then F:Last[S]_ More	!  remember and go ;
			       else begin "eol cr"	! else do eol stuff ;
				 Eol_ true;		! set end of line ;
				 More_ F:Last[S];	! and get last one ;
				 F:Char[S]_ F:Char[S]+1	! bump pointer by 1 ;
			       end "eol cr";
			   end "lone cr";
		    If ( ( Dir > 0 ) and ( #CR = Last ) )
		     then Eol_ true;		! flag as end of line ;
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    Byte_ Copy;			! synchronize pointers ;
		    Len_ 0;			! Reset string length ;
		 end "found return";

		[#lf][#vt][#ff][#eot] begin "found eol break"
		    Eol_ true;			! looks like one? ;
		    if ( Dir < 0 )		! were we going backward? ;
		     then if ( Copy = Byte )	!  and the first character ;
			   then begin "not eol"
			      Eol_ false;	!  yes, not really eol ;
			      F:Last[S]_ More;	!  remember this for later ;
			      F:Line[S]_ F:Line[S] + Dir;	! each line ;
			      If ( More = #FF )			! each FF ;
			       then F:PTxt[S]_ F:PTxt[S] + Dir;	! text page ;
			      If ( More = #EOT )		! each EOT ;
			       then F:MTxt[S]_ F:MTxt[S] + Dir;	! message ;
			   end "not eol"
			   else begin "got eol"
			      F:Char[S]_ F:Char[S] + 1;		! each char ;
			      More_ F:Last[S];			! eol-brk ;
			   end "got eol"
		     else begin "forward eol"
			If ( Last = #CR ) and ( #LF leq More leq #FF )
			 then F:CRet[S]_ Last;		! mark CR before Brk ;
			If ( More = #FF )		! for each FF seen ;
			 then F:PTxt[S]_ F:PTxt[S]+Dir;	!  count a text page ;
			If ( More = #EOT )		! for each EOT seen ;
			 then F:MTxt[S]_ F:MTxt[S]+Dir;	!  count a text message ;
			F:Line[S]_ F:Line[S] + Dir;	! count each line ;
		     end "forward eol";
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		 end "found eol break";

		[else] begin "normal character"
		    If ( Last = #CR ) and ( Dir > 0 )
		     then begin "lonely cr"	! else do eol stuff ;
			Eol_ true;		! set end of line ;
			F:Char[S]_ F:Char[S]-1;	! bump pointer by 1 ;
			More_ #CR;		! set eol to CR ;
			If ( Len )		! length to concatenate? ;
			 then Str_ Str & StMake( Byte, Len );
		     end "lonely cr"
		     else Len_ Len + 1		!  increment string length ;
		 end "normal character"
	    end;

	    If ( memory[ !rh( copy ) ] land 1 )	! bit 35 set ;
	     then begin "sequence numbers"	! in this word? ;

		If ( Dir < 0 )
		 then begin "seq backward"
		    F:Char[S]_ F:Char[S] - 4;	! tab already seen backwards ;
		    Count_ Count - 4;		!  update counts by 4 chars ;
		    If ( Len > 2 )
		     then begin "add text"	!  +1 for tab after seq # ;
			Ibp( Copy );		! make string skipping tab ;
			Str_ StMake( Copy, Len-2 ) & Str;
		     end "add text"
		 end "seq backward"
		 else begin "seq forward"
		    F:Char[S]_ F:Char[S] + 5;	! include tab in count here ;
		    Count_ Count - 5;		!  update counts by 5 chars ;
		    if ( Len neq 1 )
		     then Print( "*** Bad SEQ # in text file. ***"& Crlf );
		 end "seq forward";

		Byte_ Copy_ Copy + Dir;		!  update 1 word ;
		Len_ 0;				! Reset length ;

	     end "sequence numbers";

	    If ( 0 = Count_ (Count-1) max 0 )	! If now out of characters ;
	     then begin "fake eos break"
		If ( Len )			! length to concatenate? ;
		 then if ( Dir < 0 )
		       then Str_ StMake( Dbp( Copy ), Len ) & Str
		       else Str_ Str & StMake( Byte, Len );
		Len_ 0;				! Reset string length ;
	     end "fake eos break";

	    If ( More )				! if this is not a null ;
	     then Last_ More;			! last char for next time ;

	 end "more characters"
	 else begin "need next page"		! If no-more-characters ;

	    If ( F:Char[S] geq F:Size[S] )	! Forwards at end or ;
	       or ( F:Char[S] leq 0 )		!  backwards at beginning ;
	     then begin "end of file"		! At end-of-file? ;

		Eol_ true;			! Set flags true ;
		If ( Dir < 0 )			! If backing up ;
		 then More_ F:Last[S]		!  use last break at end ;
		 else begin "save info"
		    More_ 0;			!  set flag var to 0 ;
		    F:LSiz[S]_ F:Line[S];	!  save total size in lines ;
		    F:PSiz[S]_ F:PTxt[S];	!  save total size in pages ;
		    F:MSiz[S]_ F:MTxt[S];	!  save total size in pages ;
		 end "save info";
		Done "one line";		! Finish loop ;

	     end "end of file";			! Guess, read next page ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then return( null );		! error mapping! ;

	    ! ** assume: here at the beginning of the page ** ;
	    If ( Dir < 0 )			! Forward or Backward? ;
	     then Copy_ Byte_ point( 7, memory[(F:Page[S]+1) lsh 9], -1 )
	     else Copy_ Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );

	    If ( ( Page * CharPerPage ) > F:Size[S] )
	     then Count_ F:Size[S] mod CharPerPage
	     else Count_ CharPerPage;

	 end "need next page";

     end "one line";

    return( Str );			! give 'em what they came for ;

end "VM Line";


Internal Boolean Procedure VMText( Integer Slot; String Text );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMText( Slot, Text, Dir(0) )				;
!		Writes the next consecutive line or lines to the file	;
!		that is connected to the specified slot.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Text"
    Integer Page, Byte, Char, Count;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( !rh( F:Mode[S] ) )		! were we writing? ;
     then return( false );		! no, don't bother! ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then F:Char[S]_ 0;			!   Set before first character ;

    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
     then begin
	Print( "Page map error: p",page,"  c",F:Char[S],"  f",F:Chan[S],crlf );
	return( false );		! if no page, error return ;
     end;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);

    Count_ CharPerPage - Count;		! Fix count (# left) ;

    while ( length( Text ) )		! Must have some text left ;
     do begin "writing line"

	If ( Count > 0 )		! Must have room left on page ;
	 then begin "more characters"	!  to even try to write ;

	    If not( Char_ Lop( Text ) )	! if char = null then try next ;
	     then continue "writing line";

	    IDpb( Char, Byte );		! deposit byte at position ;
	    F:Char[S]_ F:Char[S] + 1;	! Update file character count ;

	    Case ( Char ) of begin	! check for end of line ;
		[#cr] F:CRet[S]_ #CR;	! remember we saw this ;

		[#lf][#vt][#ff][#eot] begin "count lines"
		  F:Last[S]_ Char;		! remember eol character ;
		  F:Line[S]_ F:Line[S] + 1;	! count lines seen ;
		  If ( Char = #FF )		! for each FF seen ;
		   then F:PTxt[S]_ F:PTxt[S]+1;	!  count a text page ;
		  If ( Char = #EOT )		! for each EOT seen ;
		   then F:MTxt[S]_ F:MTxt[S]+1;	!  count a text message ;
		 end "count lines";

		[else] F:CRet[S]_ 0	! forget we saw a cr ;
	     end;

	    Count_ (Count-1) max 0;	! keep character count ;

	 end "more characters"
	 else begin "need next page"	! If no-more-characters ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then begin
		Print( "Page(2) map error: ",page," ",F:Char[S],crlf );
		return( false );	! if no page, error return ;
	     end;

	    Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );
	    Count_ CharPerPage;		! always a full page to write in ;

	 end "need next page";

     end "writing line";

    If ( F:Char[S] geq F:Size[S] )	! At or Past end of file? ;
     then begin "end of file"

	F:Size[S]_ F:Char[S];		!  save size in characters ;
	F:LSiz[S]_ F:Line[S];		!  save total size in lines ;
	F:PSiz[S]_ F:PTxt[S];		!  save total size in pages ;
	F:MSiz[S]_ F:MTxt[S];		!  save total size in pages ;

     end "end of file";			! Guess, read next page ;

    return( true );			! give 'em what they came for ;

end "VM Text";


Internal Boolean Procedure VMMove( Integer Slot, HowMany(1) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMMove( Slot, HowMany(1) )					;
!		Moves the position pointer forward or backward up to	;
!		HowMany lines in the file.  Returns true if the slot is	;
!		active and HowMany lines exist, otherwise it returns	;
!		false and leaves the pointer positioned at logical end	;
!		of file (at the beginning if direction is backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Move"
    Own Integer Brk;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( HowMany )			! we can always move ;
     then return( true );		!  a distance of 0 ;

    while ( HowMany )			! while lines to go read them ;
     do begin "moving lines"

	If not( length( VMLine( Slot, Brk, HowMany < 0 ) ) or Brk )
	 then return( false );		!  then take the cows to town ;

	If ( HowMany > 0 )		! decrement the right direction ;
	 then HowMany_ HowMany - 1	!  down to zero  ;
	 else HowMany_ HowMany + 1;	!  or up to zero ;

     end "moving lines";

    return( true );			! give 'em what they came for ;

end "VM Move";


Internal Simple Boolean Procedure VMFile( String Spec; Integer Mode(VM$Read) );
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMFile( StringSpec, AccessMode )				;
!		Opens a file for the specified access.  A positive	;
!		slot number is returned if the file is available.  A 	;
!		0 means no slots and a negative value means there was	;
!		some file error or the file is not available.		;
!									;
! ----------------------------------------------------------------------;
begin "VM File"
    Own Safe Integer Array File[ 0 : !RBLIC ];
    Preset!with '17, cvsix("DSK   "), 0;
    Own Safe Integer Array Dev[ 0 : 2 ];
    Own Integer Slot;

    If not( Slot_ VMSlot )		! If no Slots available ;
     then return( false );		!  then no file opened ;

    If not( S_ Files[ Slot ] )		! slot assigned? *Debug check* ;
     then return( false );		!  not this time *huh why not* ;

    If not( VMSpec( Spec, FileSpec ) )	! trouble with the spec? ;
     then return( false );		!  then don't do anything ;

    If not(VM$Read leq !rh(Mode) leq VM$Multi)	! if an invalid mode ;
     then return( false );		! Read, Write, Update, Multi ;

    Dev[ 0 ]_ Ldb( Point(6,Mode,17) );	! Set proper mode (!ioASC) ;
    Dev[ 1 ]_ FileSpec[ S!Dev ];	! Setup device block ;
    Chnior( F:Chan[S],Dev[0],!chOPN );	! OPEN [ '17, Dev, 0 ] ;
    If not( !Skip! )			! If open-failure ;
     then begin "open failure"		!  then no file opened ;
	VMFree( Slot );			! Free the slot ;
	return( !Xwd( -1,-1 ) );	!  and return ;
     end "open failure";

    Mode_ !rh( F:Mode[S]_ Mode );	! Remember this as we need to ;
    arrclr( File );			! Clear out unused fields ;
    File[ !RBCNT ]_ !RBLIC;		! Setup file lookup block ;
    if ( FileSpec[ S!Usr ] )
     then File[ !RBPPN ]_ location( FileSpec[ S!Usr ] );
    File[ !RBNAM ]_ FileSpec[ S!Nam ];
    File[ !RBEXT ]_ FileSpec[ S!Ext ] land (-1 lsh 18);

    If ( VM$Write neq Mode )		! if mode neq VM$Write ;
     then begin "read update"		!   do lookup ;

	Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
	If not( !Skip! ) and ( 0 = !rh(File[!RBEXT]) )
	 then begin "not found"		! no skip and file not found ;
	    If ( VM$Read neq Mode )	! if mode neq VM$Read, do create ;
	     then begin "update stuff"

		Chnior( F:Chan[ S ], File[ !RBCNT ], !chENT );
		if ( !Skip! )		! enter ok, so close & lookup ;
		 then begin "ok find it"
		    Chnior( F:Chan[ S ], memory[0], !chCLS );
		    Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
		 end "ok find it";

	     end "update stuff";	! if !skip! found or created file ;
	 end "not found";		!  else some other file error ;

	if not( !Skip! )		! lookups failed - not ERFNF% ;
	 then begin "huh what's up"	! unless happened 2nd time ;
	    VMFree( Slot );		! so, clear out and return ;
	    return( !Xwd( -1,!rh(File[!RBEXT]) ) );
	 end "huh what's up";

     end "read update";			! have old file, or new file ;

    If ( VM$Read neq Mode )		! for VM$Write, VM$Update, VM$Multi ;
     then Chnior( F:Chan[ S ], File[ !RBCNT ],
		   if (Mode = VM$Multi)	! if mode eql VM$Multi ;
		     then !chMEN	!  then use multiple enter ;
		     else !chENT );	!  else use normal enter ;

    If not( !Skip! )			! If lookup-enter failure ;
     then begin "no file or access"	!  then Free the slot ;
	VMFree( Slot );			!  and return error code ;
	return( !Xwd( -1,!rh(File[!RBEXT]) ) );
     end "no file or access";

    F:FPPN[ S ]_ File[!RBPPN];		! File directory ;
    F:Name[ S ]_ File[!RBNAM];		! File name ;
    F:FExt[ S ]_ File[!RBEXT];		! File extension ;
    F:Size[ S ]_ File[!RBSIZ] * 5;	! File size in characters (Rounded) ;
    F:FLic[ S ]_ !rh( File[!RBLIC] );	! File license ;

    F:Time[ S ]_ (((File[!RBPRV] lsh -12) land '3777) * 60 )
	       + ((File[!RBLIC] lsh -18) land '77);
    F:Date[ S ]_ (Ldb( Point( 2,File[!RBEXT],21 ) ) lsh 12)
	       + (File[!RBPRV] land '7777);

    if ( Mode > VM$Read ) and		! are we writing and ;
	( VM$Append land F:Mode[ S ] )	! wanting to append ;	
	and  ( F:Size[ S ] )		! must have something ;
     then begin "tack it on"
	VMMove( Slot, -1 );		! backup from the end ;
	VMMove( Slot, 1 );		! and move forward ;
     end "tack it on";
	 
    return( Slot );			! Return the slot number ;

end "VM File";

end "VM Package";
        2VMFILE.10    18-Aug-87 14:26:34  DUZLER    entry
	VMFile, VMFree, VMSpec,
	VMChan, VMPMap,
	VMValF,
	VMLine, VMText, VMMove,
	VMGetC, VMSetC,
	VMGetW, VMSetW,
	VMRecF
	define FT!InternalPages = True;
	Ifcr not FT!InternalPages thenc , VMInit endc

;

begin "VM Package"

  require "(SAILIB)SAIL.DEF"   source!file;
  require "(SAILIB)UUOSYM.DEF" source!file;
  require "(CARL)VMFILE.DEF"   source!file;


  Define Gettab(x,y) = { calli( !xwd( (x),(y) ), calli!GETTAB ) };

  Define
	MaxSlot = 47			! number of available slots ;
  ,	MemMax  = MaxSlot * 512		! pages in words ;
  ,	CharPerPage = 512 * 5		! characters per page ;
  ,	BackByte    = '430000000001	! offset to backup a byte ;
  ,	AddaByte    = '070000000000	! offset to increment byte ;
  ;



  Record!Class F (  Integer Page;	! memory page to use ;
		    Integer File;	! file page in use ;
		    Integer Chan;	! channel for file open ;
		    Integer Mode;	! file access mode ;
		    Integer Name;	! file name in sixbit ;
		    Integer FExt;	! file extension in sixbit ;
		    Integer FPPN;	! file ppn ;
		    Integer Char;	! character pointer in file ;
		    Integer Line;	! line pointer in file +/-;
		    Integer PTxt;	! text page pointer in file +/- ;
		    Integer MTxt;	! text message pointer in file +/- ;
		    Integer Last;	! last eol character ;
		    Integer CRet;	! carriage return on line ;
		    Integer Size;	! character size of file ;
		    Integer LSiz;	! lines in file (if known) ;
		    Integer PSiz;	! pages in file (if known) ;
		    Integer MSiz;	! messages in file (if known) ;
		    Integer FLic;	! file license info ;
		    Integer Time;	! file creation time in seconds ;
		    Integer Date;	! file creation date ;
		    Integer Flag;	! file access flags (VM$APPEND) ;
		    R!P (F) Next   );	! next record - dormant only ;

  R!P (F) S;
  Safe R!P (F) Array Files[ 1 : MaxSlot ];

  Internal Boolean VMRecF;			! flag for keeping dormant ;
  R!P (F) Dormant;

  Internal Boolean VMValF;			! flag for validating rib ;

  Integer VMMem, VMPage;			! virtual memory pointers  ;
  Integer MaxSlots;				! remember available slots ;

  Own Safe Integer Array FileSpec[ S!Dev : S!Ext ];

 Ifcr FT!InternalPages thenc			! selectable by feature sw ;
  Preload!with [ MemMax + 512 ] 0;		! expect to use 1 : MemMax ;
  Own Safe Integer Array VM[ 1 : MemMax+512 ];	!  entries minus page slop ;
 endc


Ifcr FT!InternalPages thenc
  Simple Procedure InitStuff;
elsec
  Internal Simple Procedure VMInit( Integer Page, Count );
endc
! ----------------------------------------------------------------------;
!									;
!	InitStuff							;
!		Routine to initialize data structures and calculate	;
!		where to put the initial cache of pages to use for	;
!		this venture.						;
!									;
!	VMInit( FirstPage, Count )					;
!		Routine to setup a cache of pages for the user to use	;
!		instead of using the preset range designated by this	;
!		package.  This is setup via the assembly parameter:	;
!		(FT!InternalPages).					;
!									;
! ----------------------------------------------------------------------;
begin "VM Init"

  Ifcr FT!InternalPages thenc		! internal definition ;
    VMPage_ (location( VM[1] ) + '777) lsh -9;
    MaxSlots_ MaxSlot;			! count of pages ;
  elsec
    VMPage_ Page;			! base page ;
    MaxSlots_ Count max MaxSlot;	! count of pages ;
  endc
    VMMem_ VMPage lsh 9;		! base memory address ;
    VMValF_ true;			! initially validate ribs ;

    ArrClr( Files );			! files not open ;

end "VM Init";
Ifcr FT!InternalPages thenc
  require InitStuff initialization;
endc


Internal Simple Integer Procedure VMMaxS( Integer Count );
! ----------------------------------------------------------------------;
!									;
!	NewCount_ VMMaxS( Count )					;
!		Routine to limit the maximum number of slots to use	;
!		in this package.  Useful to insure that specifically	;
!		allocated channels between the top of SAILs channel	;
!		range and those used by VMFILE are not used.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Max Slots"

    return( MaxSlots_ Count max MaxSlot );	! count of pages ;

end "VM Max Slots";


Simple Integer Procedure MapPage( r!p (F) Rec; Integer NewPage );
! ----------------------------------------------------------------------;
!									;
!	MapPage( Rec, NewPage )						;
!		Routine to map the specified new file-page into the	;
!		page designated by F:Page[Rec] and update F:File[Rec]	;
!		to NewPage.						;
!									;
! ----------------------------------------------------------------------;
begin "Map Page"
    Own safe integer array Arg[ 0:1 ];
    Own integer Status, Err;

    If ( F:File[Rec] = NewPage )		! if the same page ;
     then begin "check protection"

	If not( F:Mode[Rec] )			! if no writing request ;
	 then return( NewPage );		! then nothing special ;
	Status_Calli(F:Page[Rec],calli!PAGSTS);	! read page protection ;
	If ( '3 = ( Status land '7 ) )		! if read/write? ;
	 then return( NewPage );		!  then nothing to do ;
	Err_ Calli( !Xwd( '6001,F:Page[Rec] ), calli!VPROT );
	If ( !skip! )				! if no problems, return! ;
	 then return( NewPage )			!  nothing else to do ;
	 else begin				! otherwise complain and ;
	    Print( "Map error: ",cvos(Err)," pagsts: ",cvos(Status),crlf );
	    return( F:File[Rec]_ 0 );		! make believe un-mapped ;
	 end;

     end "check protection";

    Calli( Arg[0]_ !Xwd('2001,F:Page[Rec]), calli!VCLEAR );
    if ( VM$Read neq F:Mode[Rec] )		! if we're writing then ;
     then Arg[0]_ !Xwd('6001,F:Page[Rec]);	!  make it .prrw not .prro ;
    Arg[1]_ NewPage;				! point at file page ;
    Chnior( F:Chan[Rec], Arg[0], !chMFP );	! map the page ;
    Start!code MOVEM '3,ERR; end;		! remember any errors ;

    if ( !Skip! )				! remember file page ;
     then F:File[Rec]_ NewPage			!  NewPage (if map ok) ;
     else begin "map failure"			! else check the fault ;
	F:File[Rec]_ 0;				! default (if map fails) ;

	if ( F:Mode[Rec] ) and			! if writing and past ;
	      ( !rh(ERR)='6 )			!   highest page (FLPHP%) ;
	 then begin "create page"		!  then try to create it ;

	    Chnior( F:Chan[Rec], NewPage, !chCFP );
	    If ( !Skip! )			! check success flag ;
	     then begin "try map again"		! if ok, then try map ;
		if ( VMValF )			! validate rib for page ;
		 then Chniov( F:Chan[Rec], 0, !chVRB );
		Chnior( F:Chan[Rec], Arg[0], !chMFP );
		if ( !Skip! )			! any errors? ;
		 then F:File[Rec]_ NewPage;	! no, it's ok ;
	     end "try map again";

	 end "create page";
     end "map failure";

    return( F:File[Rec] );			! return current mapping ;

end "Map Page";


Integer Procedure VM!PMap( Integer Slot, NewPage );
Return( MapPage( Files[ Slot ], NewPage ) );

Internal Simple Integer Procedure VMPMap( Integer Slot, NewPage );
! ----------------------------------------------------------------------;
!									;
!	NewPage_ VMPMap( Slot, NewPage )				;
!		Routine to map the specified new page into the map	;
!		slot for this slot and return the new page on success.	;
!		Returns 0 if any errors occur, including wrong page	;
!		protection.						;
!									;
! ----------------------------------------------------------------------;
begin  "VM Page Map"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    return( VM!PMap( Slot, NewPage ) );	! return the proper page ;

end "VM Page Map";


Simple Integer Procedure Dbp( Reference Integer Ptr );
! ----------------------------------------------------------------------;
!									;
!	Dbp( AsciiBytePointer )						;
!		Routine to decrement a 7-bit byte pointer.  Its only	;
!		magic relies on the assumption that a negative pointer	;
!		is setup as '440700 from the point/bbpp operation that	;
!		creates a ildb pointer to the first byte of the word.	;
!		This routine fixes this to point to the last byte of	;
!		the previous word whenever this is seen.  In "this"	;
!		initial case, this works so that the pointer is never	;
!		decremented the WRONG way.				;
!									;
! ----------------------------------------------------------------------;
begin "Decrement Byte Pointer"

    If ( Ptr < 0 )			! initially '440700,,addr ;
     then Ptr_ Ptr - BackByte		! so set to prev-last byte ;
     else Ptr_ Ptr + AddaByte;		! else decrement a byte ;

    If ( Ptr < 0 )			! must now be '440700,,addr ;
     then Ptr_ Ptr - BackByte;		! so set to prev-last byte ;

    return( Ptr );			! so it can be an expression ;

end "Decrement Byte Pointer";


Simple Integer procedure GetText( Reference string Line;
				  Integer Byte, Count; String Chars );
begin "get text"
    Own integer wp;
    String Str;

    while ( length( Line ) )
     do begin "get data"

	Str_ Chars;				! copy break chars ;
	while ( length( Str ) )			! if any break chars ;
	 do if ( Line = Lop( Str ) )		!  and match a brk ;
	     then return( Line );		!  return that character ;

	if ( 0 leq count_ count - 1 )		! if room left in string ;
	 then if ( "a" leq wp_lop(Line) )	!  then check case ;
	       then idpb( wp-'100, byte )	!    lowercase to sixbit ;
	       else idpb( wp-'40, byte )	!    uppercase to sixbit ;
	 else wp_ lop( Line );			!  throw away extras ;

     end "get data";

    return( 0 );				! no line left? ;

end "get text";


Internal Simple Boolean Procedure VMSpec(String L; Integer array Spec );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMSpec( FileSpecification, SpecificationBlock )		;
!		Routine to read a string file specification and build	;
!		the special file block used by the VMFile routine.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Spec"

    arrclr( Spec );				! clear out the array ;

    GetText( L, point( 6,Spec[S!Nam],-1 ), 6, ":(." );

    if ( ":" = L )				! it was a device, good! ;
     then begin
	lop( L );				! throw away the colon and ;
	Spec[S!Dev] swap Spec[S!Nam];		! swap data to right places ;
     end
     else Spec[S!Dev]_cvsix("DSK");		!  and fill in the device ;

    if ( "(" = L )				! if it starts with "(" ;
     then begin "get user"			!  then pick up username ;
	lop( L );				!    eat the "(" ;
	GetText( L, point( 6,Spec[ S!Usr ],-1 ), 12, ")" );
	lop( L );				!    eat the ")" ;
     end "get user"
     else begin "default user"			! set default if no user ;
	Spec[ S!Usr   ]_ Gettab( -1,'31 );	! .GTNM1 (GFD user 1-6)  ;
	Spec[ S!Usr+1 ]_ Gettab( -1,'32 );	! .GTNM2 (GFD user 7-12) ;
	If not( !Skip! )			! set blank if GETTAB fails ;
	 then Spec[ S!Usr ]_ Spec[ S!Usr+1 ]_ 0;
     end "default user";

    if not( length( L ) or Spec[S!Nam] )	! must have a name ;
     then return( false );			!  so return false ;

    if not( "." = L or Spec[S!Nam] )
     then GetText( L, point( 6,Spec[ S!Nam ],-1 ), 6, "." );

    if not( Spec[S!Nam] )			! seen anyone ;
     then return( false );			! no, go home ;

    if ( "." = L )				! if dot seen ;
     then begin "get ext"
	lop( L );				!  then chop it off ;
	GetText( L, point( 6,Spec[ S!Ext ],-1 ), 3, " "&'11 );
     end "get ext";

    return( true );				! got here, return ok ;

end "VM Spec";


Internal Simple Integer Procedure VMChan;
! ----------------------------------------------------------------------;
!									;
!	Chan_ VMChan							;
!		Returns the next available channel for this user.	;
!		If none are available, returns -1.			;
!									;
! ----------------------------------------------------------------------;
begin "VM Chan"

    start!code

	ReDefine !chNXT = '46;		! get next channel ;

	Hrloi	'1,!chNXT;		! setup [.chnxt,,-1] ;
	uuo!CHANIO '1,;			! to get next available ;
	  seto	'1;			! no channels available ;
	skipl	'1;			! if less than zero ;
	  tlz	'1,-1;			!  skip, else zero left ;

    end;

end "VM Chan";


R!P (F) Procedure NewRec;
! ----------------------------------------------------------------------;
!									;
!	Rec_ NewRec							;
!		Returns the next available record of class (F) from	;
!		the dormant list or the record pool.			;
!									;
! ----------------------------------------------------------------------;
begin "new record"
    r!p (F) Rec;

    if ( Dormant )
     then begin "dormant records"

	Rec_ Dormant;
	Dormant_ F:Next[ Rec ];
	F:Next[ Rec ]_ null!record;
	F:Page[ Rec ]_ F:File[ Rec ]_
	F:Chan[ Rec ]_ F:Mode[ Rec ]_
	F:Name[ Rec ]_ F:FExt[ Rec ]_ F:FPPN[ Rec ]_
	F:Char[ Rec ]_ F:Line[ Rec ]_ F:PTxt[ Rec ]_ F:MTxt[ Rec ]_
	F:Last[ Rec ]_ F:CRet[ Rec ]_
	F:Size[ Rec ]_ F:LSiz[ Rec ]_ F:PSiz[ Rec ]_ F:MSiz[ Rec ]_
	F:FLic[ Rec ]_ F:Time[ Rec ]_ F:Date[ Rec ]_
	F:Flag[ Rec ]_ 0;

     end "dormant records"
     else Rec_ new!record( F );

    return( Rec );

end "new record";


Simple Integer Procedure VMSlot;
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMSlot							;
!		Returns the next available file slot in the internal	;
!		file table.  If no slots or channels are available,	;
!		returns 0.  Array Files[slot] is setup with F:Chan,	;
!		F:Page and F:Char.					;
!									;
! ----------------------------------------------------------------------;
begin "VM Slot"
    Own Integer Slot, Chan;

    For Slot_ 1 upto MaxSlots		! check each legal slot ;
     do if not( Files[ Slot ] )		! if it's free ;
	 then begin "setup slot"	!  then make it available ;

	    S_ Files[ Slot ]_ NewRec;		! initialize record ;

	    if ( 0 > Chan_ VMChan )		! is it legal ;
	     then begin "bad channel"		!  nope. ;
		if ( VMRecF )			!   dormant records? ;
		 then begin "keep dormant"
		    F:Next[ S ]_ Dormant;	!   place at front ;
		    Dormant_ S;			!   of list ;
		 end "keep dormant";
		Files[ Slot ]_ S_ null!record;	!   clear slot ;
		return( 0 );			!   and return ;
	     end "bad channel";

	    F:Chan[ S ]_ Chan;			! copy the channel ;
	    F:Page[ S ]_ VMPage  + Slot - 1;	! memory page ;
	    F:File[ S ]_ F:Char[ S ]_ -1;	! file/char position ;

	    S_ null!record;		! free up working pointer ;

	    return( Slot );		! give caller a slot number ;

	 end "setup slot";

    return( 0 );

end "VM Slot";


Internal Simple Integer Procedure VMGetC( Integer Slot, Index(VM$Char) );
! ----------------------------------------------------------------------;
!									;
!	Position_ VMGetC( Slot, Index(VM$Char) )			;
!		Read the specified characteristic from the file table.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Get Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( -2 );			!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( -2 );			!  not this time ;

    Case Index of begin
	[VM$Char]   return( F:Char[ S ] );	! return character position ;
	[VM$Line]   return( F:Line[ S ] );	! return line position ;
	[VM$Page]   return( F:PTxt[ S ] );	! return page position ;
	[VM$Msg]    return( F:MTxt[ S ] );	! return message position ;
	[VM$Eol]    return( F:Last[ S ] );	! return last eol char ;
	[VM$ECR]    return( F:CRet[ S ] );	! return last cr on line ;
	[VM$Size]   return( F:Size[ S ] );	! return file size in chars ;
	[VM$LSize]  return( F:LSiz[ S ] );	! return file size in lines ;
	[VM$PSize]  return( F:PSiz[ S ] );	! return file size in pages ;
	[VM$MSize]  return( F:MSiz[ S ] );	! return file size in msgs ;
	[VM$Lic]    return( F:FLic[ S ] );	! return file license ;
	[VM$Access] return( F:Mode[ S ] );	! return file access mode ;
	[VM$Time]   return( F:Time[ S ] );	! return file creation time ;
	[VM$Date]   return( F:Date[ S ] );	! return file creation date ;
	[VM$Base]   return( F:Page[ S ] );	! return memory base page ;
	[VM$FPage]  return( F:File[ S ] );	! return file page on dsk ;
	[VM$Chan]   return( F:Chan[ S ] );	! return physical channel ;
	[VM$Flag]   return( F:Flag[ S ] );	! return file access flags ;
	[else]      return( -3 )		! illegal index ;
    end;

end "VM Get Character Pointer";



Internal Simple Integer Procedure VMSetC( Integer Slot, Position );
! ----------------------------------------------------------------------;
!									;
!	NewPosition_ VMSetC( Slot, TrialPosition )			;
!		Set the character position with the file open on the	;
!		specified slot.  All further references to the slot	;
!		will use the new file position.  If the specified	;
!		position is outside the file, the position is set to	;
!		-1.  The routine always returns the new position.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Set Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( 0 leq Position leq F:Size[S] )	! if position within range ;
     then F:Char[S]_ Position		!  then set it up ;
     else F:Char[S]_ Position_ -1;	!  else set to -1 ;

    return( Position );			! return the new position ;

end "VM Set Character Pointer";


Internal Simple Boolean Procedure VMFree( Integer Slot, Bits(0) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMFree( Slot )						;
!		Closes any open file for this slot and frees the	;
!		slot for future use.  Returns true if the slot was	;
!		in use.							;
!									;
! ----------------------------------------------------------------------;
begin "VM Free"
    preset!with 0,0,0,0;
    Own integer array delete[0:3];
    Own integer chan;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    Calli( !Xwd( '2001, F:Page[ S ] ), calli!VCLEAR );

    Chan_ F:Chan[S];			! get a handy channel ;
    if ( Bits or F:Mode[ S ] )		! if any writes ;
     then begin "some changes"		!  reset size & close file ;

	If ( F:Size[ S ] > 0 )		! if non-zero size ;
	 then Chniov( Chan, (F:Size[S]+4) div 5, !chFTR );

	if ( Bits = -1 )		! Special "RENAME" ;
	 then begin "rename"
	    Chnior( Chan, Delete[0], !chREN );
	    Chnior( Chan, memory[0], !chCLS );
	    Chnior( Chan, memory[0], !chREL );
	 end "rename"
	 else begin "normal"
	    Chnior( Chan, memory[Bits], !chCLS );
	    Chnior( Chan, memory[Bits], !chREL );
	 end "normal";

     end "some changes"
     else Chnior( Chan, memory[0], !chREL );

    if ( VMRecF )			!   dormant records? ;
     then begin "keep dormant"
	F:Next[ S ]_ Dormant;		!   place at front ;
	Dormant_ S;			!   of list ;
     end "keep dormant";

    Files[ Slot ]_ S_ null!record;	! clear out tables ;

    return( true );			! everything is ok ;

end "VM Free";


Internal String Procedure VMLine( Integer Slot; Reference Integer More;
				  Integer Dir( 0 ) );
! ----------------------------------------------------------------------;
!									;
!	Line_ VMLine( Slot, More, Dir(0) )				;
!		Returns the next consecutive line from the file that	;
!		is connected to the specified slot.  More is set to	;
!		the line terminator (LF, FF, VT, CR or EOT) or to 0	;
!		when the end of the file is reached or the slot is 	;
!		inactive.  Dir is the direction to read the file ( 0	;
!	 	indicates forward, -1 or non-zero for backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Line"
    Integer Page, Byte, Copy, Count, Len, Last;
    Boolean Eol;
    String Str;

    More_ 0;				! Initialize for bad exits ;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( null );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( null );		!  not this time ;

    If ( Dir )				! verify proper usage of Dir ;
     then Dir_ -1			!  non-zero = backward = -1 ;
     else Dir_ +1;			!  was-zero = forward  = +1 ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then If ( Dir < 0 )		! Forward or Backward? ;
	   then F:Char[S]_ F:Size[S]	!   Set after last character ;
	   else F:Char[S]_ 0;		!   Set before first character ;

    If ( F:File[S] neq Page_ ( F:Char[S] div CharPerPage ) + 1 )
     then if not( MapPage( S, Page ) )	! Verify using right page ;
	   then return( null );		!  and page gets mapped ;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Copy_Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);
    If ( Byte < 0 )			! Means we have '440700,,x ;
     then Copy_ Byte_ Byte - BackByte;	! Point at an actual byte ;
    If ( Dir < 0 )			! If backward direction ;
     then Ibp( Copy );			!  then setup for Dbp by 1 ;

    Str_ Null;				! Initial return string ;

    If ( Dir geq 0 )			!   Fix count (# left) ;
     then If ( ( F:File[S] * CharPerPage ) > F:Size[S] )
	   then Count_ (F:Size[S] mod CharPerPage) - Count
	   else Count_ CharPerPage - Count;

    Len_ 0;				! Initialize string length ;
    F:Last[S]_ F:CRet[S]_ 0;		! Initialize break vars ;
    Last_ -1;				! Last character seen ;
    Eol_ false;				! Initialize line var ;
    While not( Eol )			! Read one line ;
     do begin "one line"

	If ( Count > 0 )		! Must have chars left ;
	 then begin "more characters"	!  to even try to read ;

	    If ( Dir < 0 )		! Forward or Backward? ;
	     then Dbp( Copy )		!  position the character ;
	     else Ibp( Copy );		!  pointer in the page ;

	    F:Char[S]_ F:Char[S] + Dir;	! Update file character count ;

	    Case More_ Ldb( Copy ) of begin	! check for end of line ;
		[#nul] begin "found eos break"
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    If ( Dir < 0 ) and		! Backing up? ;
		       not( F:Last[S] )		! First time through? ;
		     then Dbp( Byte )		!  yes, keep it this way ;
		     else Byte_ Copy;		!  no, update pointer ;
		    Len_ 0;			! Reset string length ;
		 end "found eos break";

		[#cr] begin "found return"
		    If ( Dir < 0 )
		     then if ( #LF leq Last leq #FF )
			   then F:CRet[S]_ #CR	! remember we saw this ;
			   else begin "lone cr"
			      If ( Copy = Byte )	! if first char ;
			       then F:Last[S]_ More	!  remember and go ;
			       else begin "eol cr"	! else do eol stuff ;
				 Eol_ true;		! set end of line ;
				 More_ F:Last[S];	! and get last one ;
				 F:Char[S]_ F:Char[S]+1	! bump pointer by 1 ;
			       end "eol cr";
			   end "lone cr";
		    If ( ( Dir > 0 ) and ( #CR = Last ) )
		     then Eol_ true;		! flag as end of line ;
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    Byte_ Copy;			! synchronize pointers ;
		    Len_ 0;			! Reset string length ;
		 end "found return";

!		[#eot] ;
		[#lf][#vt][#ff] begin "found eol break"
		    Eol_ true;			! looks like one? ;
		    if ( Dir < 0 )		! were we going backward? ;
		     then if ( Copy = Byte )	!  and the first character ;
			   then begin "not eol"
			      Eol_ false;	!  yes, not really eol ;
			      F:Last[S]_ More;	!  remember this for later ;
			      F:Line[S]_ F:Line[S] + Dir;	! each line ;
			      If ( More = #FF )			! each FF ;
			       then F:PTxt[S]_ F:PTxt[S] + Dir;	! text page ;
			      If ( More = #EOT )		! each EOT ;
			       then F:MTxt[S]_ F:MTxt[S] + Dir;	! message ;
			   end "not eol"
			   else begin "got eol"
			      F:Char[S]_ F:Char[S] + 1;		! each char ;
			      More_ F:Last[S];			! eol-brk ;
			   end "got eol"
		     else begin "forward eol"
			If ( Last = #CR ) and ( #LF leq More leq #FF )
			 then F:CRet[S]_ Last;		! mark CR before Brk ;
			If ( More = #FF )		! for each FF seen ;
			 then F:PTxt[S]_ F:PTxt[S]+Dir;	!  count a text page ;
			If ( More = #EOT )		! for each EOT seen ;
			 then F:MTxt[S]_ F:MTxt[S]+Dir;	!  count a text message ;
			F:Line[S]_ F:Line[S] + Dir;	! count each line ;
		     end "forward eol";
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		 end "found eol break";

		[else] begin "normal character"
		    If ( Last = #CR ) and ( Dir > 0 )
		     then begin "lonely cr"	! else do eol stuff ;
			Eol_ true;		! set end of line ;
			F:Char[S]_ F:Char[S]-1;	! bump pointer by 1 ;
			More_ #CR;		! set eol to CR ;
			If ( Len )		! length to concatenate? ;
			 then Str_ Str & StMake( Byte, Len );
		     end "lonely cr"
		     else Len_ Len + 1		!  increment string length ;
		 end "normal character"
	    end;

	    If ( memory[ !rh( copy ) ] land 1 )	! bit 35 set ;
	     then begin "sequence numbers"	! in this word? ;

		If ( Dir < 0 )
		 then begin "seq backward"
		    F:Char[S]_ F:Char[S] - 4;	! tab already seen backwards ;
		    Count_ Count - 4;		!  update counts by 4 chars ;
		    If ( Len > 2 )
		     then begin "add text"	!  +1 for tab after seq # ;
			Ibp( Copy );		! make string skipping tab ;
			Str_ StMake( Copy, Len-2 ) & Str;
		     end "add text"
		 end "seq backward"
		 else begin "seq forward"
		    F:Char[S]_ F:Char[S] + 5;	! include tab in count here ;
		    Count_ Count - 5;		!  update counts by 5 chars ;
		    if ( Len neq 1 )
		     then Print( "*** Bad SEQ # in text file. ***"& Crlf );
		 end "seq forward";

		Byte_ Copy_ Copy + Dir;		!  update 1 word ;
		Len_ 0;				! Reset length ;

	     end "sequence numbers";

	    If ( 0 = Count_ (Count-1) max 0 )	! If now out of characters ;
	     then begin "fake eos break"
		If ( Len )			! length to concatenate? ;
		 then if ( Dir < 0 )
		       then Str_ StMake( Dbp( Copy ), Len ) & Str
		       else Str_ Str & StMake( Byte, Len );
		Len_ 0;				! Reset string length ;
	     end "fake eos break";

	    If ( More )				! if this is not a null ;
	     then Last_ More;			! last char for next time ;

	 end "more characters"
	 else begin "need next page"		! If no-more-characters ;

	    If ( F:Char[S] geq F:Size[S] )	! Forwards at end or ;
	       or ( F:Char[S] leq 0 )		!  backwards at beginning ;
	     then begin "end of file"		! At end-of-file? ;

		Eol_ true;			! Set flags true ;
		If ( Dir < 0 )			! If backing up ;
		 then More_ F:Last[S]		!  use last break at end ;
		 else begin "save info"
		    More_ 0;			!  set flag var to 0 ;
		    F:LSiz[S]_ F:Line[S];	!  save total size in lines ;
		    F:PSiz[S]_ F:PTxt[S];	!  save total size in pages ;
		    F:MSiz[S]_ F:MTxt[S];	!  save total size in pages ;
		 end "save info";
		Done "one line";		! Finish loop ;

	     end "end of file";			! Guess, read next page ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then return( null );		! error mapping! ;

	    ! ** assume: here at the beginning of the page ** ;
	    If ( Dir < 0 )			! Forward or Backward? ;
	     then Copy_ Byte_ point( 7, memory[(F:Page[S]+1) lsh 9], -1 )
	     else Copy_ Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );

	    If ( ( Page * CharPerPage ) > F:Size[S] )
	     then Count_ F:Size[S] mod CharPerPage
	     else Count_ CharPerPage;

	 end "need next page";

     end "one line";

    return( Str );			! give 'em what they came for ;

end "VM Line";


Internal Boolean Procedure VMText( Integer Slot; String Text );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMText( Slot, Text, Dir(0) )				;
!		Writes the next consecutive line or lines to the file	;
!		that is connected to the specified slot.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Text"
    Integer Page, Byte, Char, Count;

    if not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    if not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    if not( F:Mode[S] )			! were we writing? ;
     then return( false );		! no, don't bother! ;

    if ( F:Char[S] = -1 )		! we are mapped? ;
     then F:Char[S]_ 0;			!   Set before first character ;

    if not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
     then begin
	Print( "Page map error: p",page,"  c",F:Char[S],"  f",F:Chan[S],crlf );
	return( false );		! if no page, error return ;
     end;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);

    Count_ CharPerPage - Count;		! Fix count (# left) ;

    while ( length( Text ) )		! Must have some text left ;
     do begin "writing line"

	If ( Count > 0 )		! Must have room left on page ;
	 then begin "more characters"	!  to even try to write ;

	    If not( Char_ Lop( Text ) )	! if char = null then try next ;
	     then continue "writing line";

	    IDpb( Char, Byte );		! deposit byte at position ;
	    F:Char[S]_ F:Char[S] + 1;	! Update file character count ;

	    Case ( Char ) of begin	! check for end of line ;
		[#cr] F:CRet[S]_ #CR;	! remember we saw this ;

!		[#eot] ;
		[#lf][#vt][#ff] begin "count lines"
		  F:Last[S]_ Char;		! remember eol character ;
		  F:Line[S]_ F:Line[S] + 1;	! count lines seen ;
		  If ( Char = #FF )		! for each FF seen ;
		   then F:PTxt[S]_ F:PTxt[S]+1;	!  count a text page ;
		  If ( Char = #EOT )		! for each EOT seen ;
		   then F:MTxt[S]_ F:MTxt[S]+1;	!  count a text message ;
		 end "count lines";

		[else] F:CRet[S]_ 0	! forget we saw a cr ;
	     end;

	    Count_ (Count-1) max 0;	! keep character count ;

	 end "more characters"
	 else begin "need next page"	! If no-more-characters ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then begin
		Print( "Page(2) map error: ",page," ",F:Char[S],crlf );
		return( false );	! if no page, error return ;
	     end;

	    Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );
	    Count_ CharPerPage;		! always a full page to write in ;

	 end "need next page";

     end "writing line";

    If ( F:Char[S] geq F:Size[S] )	! At or Past end of file? ;
     then begin "end of file"

	F:Size[S]_ F:Char[S];		!  save size in characters ;
	F:LSiz[S]_ F:Line[S];		!  save total size in lines ;
	F:PSiz[S]_ F:PTxt[S];		!  save total size in pages ;
	F:MSiz[S]_ F:MTxt[S];		!  save total size in pages ;

     end "end of file";			! Guess, read next page ;

    return( true );			! give 'em what they came for ;

end "VM Text";


Internal Boolean Procedure VMMove( Integer Slot, HowMany(1) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMMove( Slot, HowMany(1) )					;
!		Moves the position pointer forward or backward up to	;
!		HowMany lines in the file.  Returns true if the slot is	;
!		active and HowMany lines exist, otherwise it returns	;
!		false and leaves the pointer positioned at logical end	;
!		of file (at the beginning if direction is backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Move"
    Own Integer Brk;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( HowMany )			! we can always move ;
     then return( true );		!  a distance of 0 ;

    while ( HowMany )			! while lines to go read them ;
     do begin "moving lines"

	If not( length( VMLine( Slot, Brk, HowMany < 0 ) ) or Brk )
	 then return( false );		!  then take the cows to town ;

	If ( HowMany > 0 )		! decrement the right direction ;
	 then HowMany_ HowMany - 1	!  down to zero  ;
	 else HowMany_ HowMany + 1;	!  or up to zero ;

     end "moving lines";

    return( true );			! give 'em what they came for ;

end "VM Move";


Internal Simple Boolean Procedure VMFile( String Spec; Integer Mode(VM$Read) );
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMFile( StringSpec, AccessMode )				;
!		Opens a file for the specified access.  A positive	;
!		slot number is returned if the file is available.  A 	;
!		0 means no slots and a negative value means there was	;
!		some file error or the file is not available.		;
!									;
! ----------------------------------------------------------------------;
begin "VM File"
    Own Safe Integer Array File[ 0 : !RBLIC ];
    Preset!with '17, cvsix("DSK   "), 0;
    Own Safe Integer Array Dev[ 0 : 2 ];
    Own Integer Slot, Flag, Chan;

    if not( Slot_ VMSlot )		! If no Slots available ;
     then return( false );		!  then no file opened ;

    if not( S_ Files[ Slot ] )		! slot assigned? *Debug check* ;
     then return( false );		!  not this time *huh why not* ;

    if not( VMSpec( Spec, FileSpec ) )	! trouble with the spec? ;
     then return( false );		!  then don't do anything ;

    Chan_ F:CHan[ S ];			! Save for local usage ;
    Mode_ !rh( Flag_ Mode );		! Remember flags ;

    if not( VM$Read leq Mode leq VM$Multi )	! if an invalid mode ;
     then return( false );		! Read, Write, Update, Multi ;

    Dev[ 0 ]_ Ldb( Point(6,Mode,17) );	! Set proper mode (!ioASC) ;
    Dev[ 1 ]_ FileSpec[ S!Dev ];	! Setup device block ;
    Chnior( Chan, Dev[ 0 ], !chOPN );	! OPEN [ '17, Dev, 0 ] ;
    If not( !Skip! )			! If open-failure ;
     then begin "open failure"		!  then no file opened ;
	VMFree( Slot );			! Free the slot ;
	return( !Xwd( -1,-1 ) );	!  and return ;
     end "open failure";

    arrclr( File );			! Clear out unused fields ;
    File[ !RBCNT ]_ !RBLIC;		! Setup file lookup block ;
    if ( FileSpec[ S!Usr ] )
     then File[ !RBPPN ]_ location( FileSpec[ S!Usr ] );
    File[ !RBNAM ]_ FileSpec[ S!Nam ];
    File[ !RBEXT ]_ FileSpec[ S!Ext ] land (-1 lsh 18);

    If ( VM$Write neq Mode )		! if mode neq VM$Write ;
     then begin "read update"		!   do lookup ;

	Chnior( Chan, File[ !RBCNT ], !chLK );
	If not( !Skip! ) and ( 0 = !rh(File[!RBEXT]) )
	 then begin "not found"		! no skip and file not found ;
	    If ( VM$Read neq Mode )	! if mode neq VM$Read, do create ;
	     then begin "update stuff"

		Chnior( Chan, File[ !RBCNT ], !chENT );
		if ( !Skip! )		! enter ok, so close & lookup ;
		 then begin "ok find it"
		    Chnior( Chan, memory[0], !chCLS );
		    Chnior( Chan, File[ !RBCNT ], !chLK );
		 end "ok find it";

	     end "update stuff";	! if !skip! found or created file ;
	 end "not found";		!  else some other file error ;

	if not( !Skip! )		! lookups failed - not ERFNF% ;
	 then begin "huh what's up"	! unless happened 2nd time ;
	    VMFree( Slot );		! so, clear out and return ;
	    return( !Xwd( -1,!rh(File[!RBEXT]) ) );
	 end "huh what's up";

     end "read update";			! have old file, or new file ;

    if ( VM$Read neq Mode )		! for VM$Write, VM$Update, VM$Multi ;
     then Chnior( Chan, File[ !RBCNT ],
		   if (Mode = VM$Multi)	! if mode eql VM$Multi ;
		     then !chMEN	!  then use multiple enter ;
		     else !chENT );	!  else use normal enter ;

    if not( !Skip! )			! if lookup-enter failure ;
     then begin "no file or access"	!  then Free the slot ;
	VMFree( Slot );			!  and return error code ;
	return( !Xwd( -1,!rh(File[!RBEXT]) ) );
     end "no file or access";

    F:Mode[ S ]_ Mode;			! Remember these things ;
    F:Flag[ S ]_ Flag;
    F:FPPN[ S ]_ File[!RBPPN];		! File directory ;
    F:Name[ S ]_ File[!RBNAM];		! File name ;
    F:FExt[ S ]_ File[!RBEXT];		! File extension ;
    F:Size[ S ]_ File[!RBSIZ] * 5;	! File size in characters (Rounded) ;
    F:FLic[ S ]_ !rh( File[!RBLIC] );	! File license ;

    F:Time[ S ]_ (((File[!RBPRV] lsh -12) land '3777) * 60 )
	       + ((File[!RBLIC] lsh -18) land '77);
    F:Date[ S ]_ (Ldb( Point( 2,File[!RBEXT],21 ) ) lsh 12)
	       + (File[!RBPRV] land '7777);

    if ( Mode > VM$Read ) and		! are we writing and ;
	( VM$Append land Flag )		! wanting to append ;	
	and  ( F:Size[ S ] )		! must have something ;
     then begin "tack it on"
	VMSetC( Slot, F:Size[ S ] );	! set file to last word ;
	VMMove( Slot, -1 );		! backup from the end ;
	VMMove( Slot, 1 );		! and move forward ;
     end "tack it on";
	 
    return( Slot );			! Return the slot number ;

end "VM File";

end "VM Package";
    2VMFILE.INF    ?22-Sep-87 22:15:06  FAWRIG    
comment
!
!	VM File - Mapped file package
!
!	Product usage:
!	  (SPL)MARKER		VMFILE.?
!	  (SPL)CPY		VMFILE.?
!
!	  (SAILIB)RHFILE	VMFILE.?
!
!	  (EXECX)XEXEC		VMFILE.10 ==> (EXECX)XEXFIL * private copy
!	  (EXECX)EXECX		VMFILE.10 ==> (EXECX)XEXFIL * private copy
!	  (SUBMIT)SUBMIT	VMFILE.10 ==> (EXECX)XEXFIL * private copy
!
!	Revision History
!
!
;

    2VMFILE.REQ   04-Jan-88 18:38:08  ZUCYAJ    
require "  VM Mapped File Reading Package " message;

require "(SAILIB)VMFILE.DEF" source!file;

External         Boolean           VMValF;
External         Boolean           VMIPEF;
External         Boolean           VMWait;
External Simple  Integer Procedure VMChan;
External Simple  Boolean Procedure VMFree( Integer Slot, Bits(0) );
External Simple  Boolean Procedure VMSpec( String L; Integer array Spec );
External Simple  Integer Procedure VMGetB( Integer Slot, Position(-1) );
External Simple  Integer Procedure VMSetB( Integer Slot, Byte, Pos(-1) );
External Simple  Integer Procedure VMGetC( Integer Slot, Index(VM$Pos) );
External Simple  Integer Procedure VMSetC( Integer Slot, Position );
External Simple  Integer Procedure VMPMap( Integer Slot, NewPage );
External Boolean Procedure VMMove( Integer Slot, HowMany( 1 ) );
External Boolean Procedure VMText( Integer Slot; String Text );
External String  Procedure VMLine( Integer Slot;
				   Reference Integer More;
				   Integer Dir( 0 ) );
External Simple  Boolean Procedure VMFile( String Spec;
					   Integer Mode( VM$Read );
					   Integer PageCount(1);
					   Integer MemPage(-1) );
External Simple Procedure VMInit( Integer PageCount(0), Base(0) );

require "(SAILIB)VMFILE" library;

     2VMFILE.DEF   *04-Jan-88 18:40:35  NIFYOT    
require "  VM Mapped File Package Definitions  " message;

! the following are the access modes for the VMFile routine ;

Define	VM$Read   =  0			! Read Only ;
,	VM$Write  =  VM$Read   + 1	! Write/Supersede ;
,	VM$Update =  VM$Write  + 1	! Write/Update (used for append) ;
,	VM$Multi  =  VM$Update + 1	! Multi-access Write/Update ;

,	VM$Append = ( 1 lsh 35 )	! Append flag - Update or Multi ;
;

! The following are the offsets for the VMGetC routine ;

Define	VM$Pos    =  0			! Character position ;
,	VM$LPos   =  VM$Pos    + 1	! Line position ;
,	VM$PPos   =  VM$LPos   + 1	! Page position ;
,	VM$MPos   =  VM$PPos   + 1	! Message position ;
,	VM$Eol    =  VM$MPos   + 1	! End of Line terminator ;
,	VM$ECR    =  VM$Eol    + 1	! End of Line CR seen ;
,	VM$Size   =  VM$ECR    + 1	! Size of file in Characters ;
,	VM$LSize  =  VM$Size   + 1	! Size of file in Lines ;
,	VM$PSize  =  VM$LSize  + 1	! Size of file in Pages ;
,	VM$MSize  =  VM$PSize  + 1	! Size of file in Messages ;
,	VM$Lic    =  VM$MSize  + 1	! File license ;
,	VM$Access =  VM$Lic    + 1	! File access mode ;
,	VM$Time   =  VM$Access + 1	! File creation time in seconds ;
,	VM$Date   =  VM$Time   + 1	! File creation date ;
,	VM$Base   =  VM$Date   + 1	! Base memory page for mapping ;
,	VM$Count  =  VM$Base   + 1	! Count of memory pages for mapping ;
,	VM$FPage  =  VM$Count  + 1	! File page in memory ;
,	VM$Chan   =  VM$FPage  + 1	! Physical channel number ;
,	VM$Flag   =  VM$Chan   + 1	! Flag bits on mode word ;
;

Define
	S!Dev     =  0			! Device ;
,	S!Usr     =  S!Dev     + 1	! Username ;
,	S!Nam     =  S!Usr     + 2	! Name ;
,	S!Ext     =  S!Nam     + 1	! Extension ;
;
        2VMFILE.686   ?04-Jan-88 18:52:36  CADPAR        2VMFILE.REQ    d30-Jun-86 22:56:59  MINNOW    
require "  VM Mapped File Reading Package " message;

require "(CARL)VMFILE.DEF" source!file;

External Simple  Integer Procedure VMChan;
External Simple  Boolean Procedure VMFree( Integer Slot, Bits(0) );
External Simple  Boolean Procedure VMSpec( String L; Integer array Spec );
External Simple  Integer Procedure VMGetC( Integer Slot, Index(VM$Char) );
External Simple  Integer Procedure VMSetC( Integer Slot, Position );
External Simple  Integer Procedure VMPMap( Integer Slot, NewPage );
External Simple  Integer Procedure VMBase( Integer Slot );
External Simple  Integer Procedure VMFLic( Integer Slot );
External Boolean Procedure VMMove( Integer Slot, HowMany( 1 ) );
External Boolean Procedure VMText( Integer Slot; String Text );
External String  Procedure VMLine( Integer Slot;
				   Reference Integer More;
				   Integer Dir( 0 ) );
External Simple  Boolean Procedure VMFile( String Spec;
					   Integer Mode( VM$Read ) );

require "(CARL)VMFILE" library;

        2VMFILE.DEF   30-Jun-86 23:30:37  SURMIH    
require "  VM Mapped File Package Definitions  " message;

! the following are the access modes for the VMFile routine ;

Define	VM$Read   =  0			! Read Only ;
,	VM$Write  =  VM$Read   + 1	! Write/Supersede ;
,	VM$Update =  VM$Write  + 1	! Write/Update (used for append) ;
,	VM$Multi  =  VM$Update + 1	! Multi-access Write/Update ;

,	VM$Append = ( 1 lsh 35 )	! Append flag - Update or Multi ;
;

! The following are the offsets for the VMGetC routine ;

Define	VM$Char   =  0			! Character position ;
,	VM$Line   =  VM$Char   + 1	! Line position ;
,	VM$Page   =  VM$Line   + 1	! Page position ;
,	VM$Msg    =  VM$Page   + 1	! Message position ;
,	VM$Eol    =  VM$Msg    + 1	! End of Line terminator ;
,	VM$ECR    =  VM$Eol    + 1	! End of Line CR seen ;
,	VM$Size   =  VM$ECR    + 1	! Size of file in Characters ;
,	VM$LSize  =  VM$Size   + 1	! Size of file in Lines ;
,	VM$PSize  =  VM$LSize  + 1	! Size of file in Pages ;
,	VM$MSize  =  VM$PSize  + 1	! Size of file in Messages ;
,	VM$Lic    =  VM$MSize  + 1	! File license ;
,	VM$Access =  VM$Lic    + 1	! File access mode ;
,	VM$Time   =  VM$Access + 1	! File creation time in seconds ;
,	VM$Date   =  VM$Time   + 1	! File creation date ;
,	VM$Base   =  VM$Date   + 1	! Memory page for mapping ;
,	VM$FPage  =  VM$Base   + 1	! File page in memory ;
,	VM$Chan   =  VM$FPage  + 1	! Physical channel number ;
;

Define
	S!Dev     =  0			! Device ;
,	S!Usr     =  S!Dev     + 1	! Username ;
,	S!Nam     =  S!Usr     + 2	! Name ;
,	S!Ext     =  S!Nam     + 1	! Extension ;
;
        2VMFILE.SAI   ?30-Jun-86 23:26:48  YUVHIL    entry
	VMFile, VMFree, VMSpec,
	VMChan, VMPMap,
	VMLine, VMText, VMMove,
	VMGetC, VMSetC,
	VMGetW, VMSetW
	define FT!InternalPages = True;
	Ifcr not FT!InternalPages thenc , VMInit endc

;

begin "VM Package"

  require "(SAILIB)SAIL.DEF"   source!file;
  require "(SAILIB)UUOSYM.DEF" source!file;
  require "(CARL)VMFILE.DEF"   source!file;


  Define
	MaxSlot = 47			! number of available slots ;
  ,	MemMax  = MaxSlot * 512		! pages in words ;
  ,	CharPerPage = 512 * 5		! characters per page ;
  ,	BackByte    = '430000000001	! offset to backup a byte ;
  ,	AddaByte    = '070000000000	! offset to increment byte ;
  ;



  Record!Class F (  Integer Page;	! memory page to use ;
		    Integer File;	! file page in use ;
		    Integer Chan;	! channel for file open ;
		    Integer Mode;	! file access mode ;
		    Integer Name;	! file name in sixbit ;
		    Integer FExt;	! file extension in sixbit ;
		    Integer FPPN;	! file ppn ;
		    Integer Char;	! character pointer in file ;
		    Integer Line;	! line pointer in file +/-;
		    Integer PTxt;	! text page pointer in file +/- ;
		    Integer MTxt;	! text message pointer in file +/- ;
		    Integer Last;	! last eol character ;
		    Integer CRet;	! carriage return on line ;
		    Integer Size;	! character size of file ;
		    Integer LSiz;	! lines in file (if known) ;
		    Integer PSiz;	! pages in file (if known) ;
		    Integer MSiz;	! messages in file (if known) ;
		    Integer FLic;	! file license info ;
		    Integer Time;	! file creation time in seconds ;
		    Integer Date    );	! file creation date ;

  R!P (F) S;
  Safe R!P (F) Array Files[ 1 : MaxSlot ];

  Integer VMMem, VMPage;			! virtual memory pointers  ;
  Integer MaxSlots;				! remember available slots ;

  Own Safe Integer Array FileSpec[ S!Dev : S!Ext ];

 Ifcr FT!InternalPages thenc			! selectable by feature sw ;
  Preset!with [ MemMax + 512 ] 0;		! expect to use 1 : MemMax ;
  Own Safe Integer Array VM[ 1 : MemMax+512 ];	!  entries minus page slop ;
 endc


Ifcr FT!InternalPages thenc
  Simple Procedure InitStuff;
elsec
  Internal Simple Procedure VMInit( Integer Page, Count );
endc
! ----------------------------------------------------------------------;
!									;
!	InitStuff							;
!		Routine to initialize data structures and calculate	;
!		where to put the initial cache of pages to use for	;
!		this venture.						;
!									;
!	VMInit( FirstPage, Count )					;
!		Routine to setup a cache of pages for the user to use	;
!		instead of using the preset range designated by this	;
!		package.  This is setup via the assembly parameter:	;
!		(FT!InternalPages).					;
!									;
! ----------------------------------------------------------------------;
begin "VM Init"

  Ifcr FT!InternalPages thenc		! internal definition ;
    VMPage_ (location( VM[1] ) + '777) lsh -9;
    MaxSlots_ MaxSlot;			! count of pages ;
  elsec
    VMPage_ Page;			! base page ;
    MaxSlots_ Count max MaxSlot;	! count of pages ;
  endc
    VMMem_ VMPage lsh 9;		! base memory address ;

    ArrClr( Files );			! files not open ;

end "VM Init";
Ifcr FT!InternalPages thenc
  require InitStuff initialization;
endc


Internal Simple Integer Procedure VMMaxS( Integer Count );
! ----------------------------------------------------------------------;
!									;
!	NewCount_ VMMaxS( Count )					;
!		Routine to limit the maximum number of slots to use	;
!		in this package.  Useful to insure that specifically	;
!		allocated channels between the top of SAILs channel	;
!		range and those used by VMFILE are not used.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Max Slots"

    return( MaxSlots_ Count max MaxSlot );	! count of pages ;

end "VM Max Slots";


Simple Integer Procedure MapPage( r!p (F) Rec; Integer NewPage );
! ----------------------------------------------------------------------;
!									;
!	MapPage( Rec, NewPage )						;
!		Routine to map the specified new file-page into the	;
!		page designated by F:Page[Rec] and update F:File[Rec]	;
!		to NewPage.						;
!									;
! ----------------------------------------------------------------------;
begin "Map Page"
    Own safe integer array Arg[ 0:1 ];
    Own integer Status, Err;

    If ( F:File[Rec] = NewPage )		! if the same page ;
     then begin "check protection"

	If not( !rh( F:Mode[Rec] ) )		! if no writing request ;
	 then return( NewPage );		! then nothing special ;
	Status_Calli(F:Page[Rec],calli!PAGSTS);	! read page protection ;
	If ( '3 = ( Status land '7 ) )		! if read/write? ;
	 then return( NewPage );		!  then nothing to do ;
	Err_ Calli( !Xwd( '6001,F:Page[Rec] ), calli!VPROT );
	If ( !skip! )				! if no problems, return! ;
	 then return( NewPage )			!  nothing else to do ;
	 else begin				! otherwise complain and ;
	    Print( "Map error: ",cvos(Err)," pagsts: ",cvos(Status),crlf );
	    return( F:File[Rec]_ 0 );		! make believe un-mapped ;
	 end;

     end "check protection";

    Calli( Arg[0]_ !Xwd('2001,F:Page[Rec]), calli!VCLEAR );
    If ( VM$Read neq !rh( F:Mode[Rec] ) )	! if we're writing then ;
     then Arg[0]_ !Xwd('6001,F:Page[Rec]);	!  make it .prrw not .prro ;
    Arg[1]_ NewPage;				! point at file page ;
    Chnior( F:Chan[Rec], Arg[0], !chMFP );	! map the page ;
    Start!code MOVEM '3,ERR; end;		! remember any errors ;

    If ( !Skip! )				! remember file page ;
     then F:File[Rec]_ NewPage			!  NewPage (if map ok) ;
     else begin "map failure"			! else check the fault ;
	F:File[Rec]_ 0;				! default (if map fails) ;

	If ( !rh( F:Mode[Rec] ) ) and		! if writing and past ;
	      ( !rh(ERR)='6 )			!   highest page (FLPHP%) ;
	 then begin "create page"		!  then try to create it ;

	    Chnior( F:Chan[Rec], NewPage, !chCFP );
	    If ( !Skip! )			! check success flag ;
	     then begin "try map again"		! if ok, then try map ;
		Chnior( F:Chan[Rec], Arg[0], !chMFP );
		if ( !Skip! )			! any errors? ;
		 then F:File[Rec]_ NewPage;	! no, it's ok ;
	     end "try map again";

	 end "create page";
     end "map failure";

    return( F:File[Rec] );			! return current mapping ;

end "Map Page";


Integer Procedure VM!PMap( Integer Slot, NewPage );
Return( MapPage( Files[ Slot ], NewPage ) );

Internal Simple Integer Procedure VMPMap( Integer Slot, NewPage );
! ----------------------------------------------------------------------;
!									;
!	NewPage_ VMPMap( Slot, NewPage )				;
!		Routine to map the specified new page into the map	;
!		slot for this slot and return the new page on success.	;
!		Returns 0 if any errors occur, including wrong page	;
!		protection.						;
!									;
! ----------------------------------------------------------------------;
begin  "VM Page Map"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    return( VM!PMap( Slot, NewPage ) );	! return the proper page ;

end "VM Page Map";


Simple Integer Procedure Dbp( Reference Integer Ptr );
! ----------------------------------------------------------------------;
!									;
!	Dbp( AsciiBytePointer )						;
!		Routine to decrement a 7-bit byte pointer.  Its only	;
!		magic relies on the assumption that a negative pointer	;
!		is setup as '440700 from the point/bbpp operation that	;
!		creates a ildb pointer to the first byte of the word.	;
!		This routine fixes this to point to the last byte of	;
!		the previous word whenever this is seen.  In "this"	;
!		initial case, this works so that the pointer is never	;
!		decremented the WRONG way.				;
!									;
! ----------------------------------------------------------------------;
begin "Decrement Byte Pointer"

    If ( Ptr < 0 )			! initially '440700,,addr ;
     then Ptr_ Ptr - BackByte		! so set to prev-last byte ;
     else Ptr_ Ptr + AddaByte;		! else decrement a byte ;

    If ( Ptr < 0 )			! must now be '440700,,addr ;
     then Ptr_ Ptr - BackByte;		! so set to prev-last byte ;

    return( Ptr );			! so it can be an expression ;

end "Decrement Byte Pointer";


Simple Integer procedure GetText( Reference string Line;
				  Integer Byte, Count; String Chars );
begin "get text"
    Own integer wp;
    String Str;

    while ( length( Line ) )
     do begin "get data"

	Str_ Chars;				! copy break chars ;
	while ( length( Str ) )			! if any break chars ;
	 do if ( Line = Lop( Str ) )		!  and match a brk ;
	     then return( Line );		!  return that character ;

	if ( 0 leq count_ count - 1 )		! if room left in string ;
	 then if ( "a" leq wp_lop(Line) )	!  then check case ;
	       then idpb( wp-'100, byte )	!    lowercase to sixbit ;
	       else idpb( wp-'40, byte )	!    uppercase to sixbit ;
	 else wp_ lop( Line );			!  throw away extras ;

     end "get data";

    return( 0 );				! no line left? ;

end "get text";


Internal Simple Boolean Procedure VMSpec(String L; Integer array Spec );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMSpec( FileSpecification, SpecificationBlock )		;
!		Routine to read a string file specification and build	;
!		the special file block used by the VMFile routine.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Spec"

    arrclr( Spec );				! clear out the array ;

    GetText( L, point( 6,Spec[S!Nam],-1 ), 6, ":(." );

    if ( ":" = L )				! it was a device, good! ;
     then begin
	lop( L );				! throw away the colon and ;
	Spec[S!Dev] swap Spec[S!Nam];		! swap data to right places ;
     end
     else Spec[S!Dev]_cvsix("DSK");		!  and fill in the device ;

    if ( "(" = L )				! if it starts with "(" ;
     then begin "get user"			!  then pick up username ;
	lop( L );				!    eat the "(" ;
	GetText( L, point( 6,Spec[ S!Usr ],-1 ), 12, ")" );
	lop( L );				!    eat the ")" ;
     end "get user"
     else begin "default user"			! set default if no user ;
	Spec[ S!Usr   ]_ calli( '31, '41 );	! .GTNM1 (GFD user 1-6)  ;
	Spec[ S!Usr+1 ]_ calli( '32, '41 );	! .GTNM2 (GFD user 7-12) ;
	If not( !Skip! )			! set blank if GETTAB fails ;
	 then Spec[ S!Usr ]_ Spec[ S!Usr+1 ]_ 0;
     end "default user";

    if not( length( L ) or Spec[S!Nam] )	! must have a name ;
     then return( false );			!  so return false ;

    if not( "." = L or Spec[S!Nam] )
     then GetText( L, point( 6,Spec[ S!Nam ],-1 ), 6, "." );

    if not( Spec[S!Nam] )			! seen anyone ;
     then return( false );			! no, go home ;

    if ( "." = L )				! if dot seen ;
     then begin "get ext"
	lop( L );				!  then chop it off ;
	GetText( L, point( 6,Spec[ S!Ext ],-1 ), 3, " "&'11 );
     end "get ext";

    return( true );				! got here, return ok ;

end "VM Spec";


Internal Simple Integer Procedure VMChan;
! ----------------------------------------------------------------------;
!									;
!	Chan_ VMChan							;
!		Returns the next available channel for this user.	;
!		If none are available, returns -1.			;
!									;
! ----------------------------------------------------------------------;
begin "VM Chan"

    start!code

	ReDefine !chNXT = '46;		! get next channel ;

	Hrloi	'1,!chNXT;		! setup [.chnxt,,-1] ;
	uuo!CHANIO '1,;			! to get next available ;
	  seto	'1;			! no channels available ;
	skipl	'1;			! if less than zero ;
	  tlz	'1,-1;			!  skip, else zero left ;

    end;

end "VM Chan";


Simple Integer Procedure VMSlot;
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMSlot							;
!		Returns the next available file slot in the internal	;
!		file table.  If no slots or channels are available,	;
!		returns 0.  Array Files[slot] is setup with F:Chan,	;
!		F:Page and F:Char.					;
!									;
! ----------------------------------------------------------------------;
begin "VM Slot"
    Own Integer Slot, Chan;

    For Slot_ 1 upto MaxSlots		! check each legal slot ;
     do if not( Files[ Slot ] )		! if it's free ;
	 then begin "setup slot"	!  then make it available ;

	    S_ Files[ Slot ]_ new!record( F );	! initialize record ;

	    if ( 0 > Chan_ VMChan )		! is it legal ;
	     then begin "bad channel"		!  nope. ;
		Files[ Slot ]_ null!record;	!   clear slot ;
		return( 0 );			!   and return ;
	     end "bad channel";

	    F:Chan[ S ]_ Chan;			! copy the channel ;
	    F:Page[ S ]_ VMPage  + Slot - 1;	! memory page ;
	    F:File[ S ]_ F:Char[ S ]_ -1;	! file/char position ;

	    S_ null!record;		! free up working pointer ;

	    return( Slot );		! give caller a slot number ;

	 end "setup slot";

    return( 0 );

end "VM Slot";


Internal Simple Integer Procedure VMGetC( Integer Slot, Index(VM$Char) );
! ----------------------------------------------------------------------;
!									;
!	Position_ VMGetC( Slot, Index(VM$Char) )			;
!		Read the specified characteristic from the file table.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Get Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( -2 );			!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( -2 );			!  not this time ;

    Case Index of begin
	[VM$Char]   return( F:Char[ S ] );	! return character position ;
	[VM$Line]   return( F:Line[ S ] );	! return line position ;
	[VM$Page]   return( F:PTxt[ S ] );	! return page position ;
	[VM$Msg]    return( F:MTxt[ S ] );	! return message position ;
	[VM$Eol]    return( F:Last[ S ] );	! return last eol char ;
	[VM$ECR]    return( F:CRet[ S ] );	! return last cr on line ;
	[VM$Size]   return( F:Size[ S ] );	! return file size in chars ;
	[VM$LSize]  return( F:LSiz[ S ] );	! return file size in lines ;
	[VM$PSize]  return( F:PSiz[ S ] );	! return file size in pages ;
	[VM$MSize]  return( F:MSiz[ S ] );	! return file size in msgs ;
	[VM$Lic]    return( F:FLic[ S ] );	! return file license ;
	[VM$Access] return( F:Mode[ S ] );	! return file access mode ;
	[VM$Time]   return( F:Time[ S ] );	! return file creation time ;
	[VM$Date]   return( F:Date[ S ] );	! return file creation date ;
	[VM$Base]   return( F:Page[ S ] );	! return memory base page ;
	[VM$FPage]  return( F:File[ S ] );	! return file page on dsk ;
	[VM$Chan]   return( F:Chan[ S ] );	! return physical channel ;
	[else]      return( -3 )		! illegal index ;
    end;

end "VM Get Character Pointer";



Internal Simple Integer Procedure VMSetC( Integer Slot, Position );
! ----------------------------------------------------------------------;
!									;
!	NewPosition_ VMSetC( Slot, TrialPosition )			;
!		Set the character position with the file open on the	;
!		specified slot.  All further references to the slot	;
!		will use the new file position.  If the specified	;
!		position is outside the file, the position is set to	;
!		-1.  The routine always returns the new position.	;
!									;
! ----------------------------------------------------------------------;
begin "VM Set Character Pointer"

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( 0 leq Position leq F:Size[S] )	! if position within range ;
     then F:Char[S]_ Position		!  then set it up ;
     else F:Char[S]_ Position_ -1;	!  else set to -1 ;

    return( Position );			! return the new position ;

end "VM Set Character Pointer";


Internal Simple Boolean Procedure VMFree( Integer Slot, Bits(0) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMFree( Slot )						;
!		Closes any open file for this slot and frees the	;
!		slot for future use.  Returns true if the slot was	;
!		in use.							;
!									;
! ----------------------------------------------------------------------;
begin "VM Free"
    preset!with 0,0,0,0;
    Own integer array delete[0:3];

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If ( F:File[ S ] )			! if file mapped, clear page ;
     then Calli( !Xwd( '2001, F:Page[ S ] ), calli!VCLEAR );

    If ( Bits or !rh( F:Mode[ S ] ) )	! if any writes ;
     then begin "some changes"		!  reset size & close file ;

	If ( F:Size[ S ] > 0 )		! if non-zero size ;
	 then Chniov( F:Chan[S], (F:Size[S]+4) div 5, !chFTR );
	if ( Bits = -1 )		! Special "RENAME" ;
	 then Chnior( F:Chan[S], Delete[0], !chREN );
	Chnior( F:Chan[ S ], memory[Bits], !chCLS );

     end "some changes";

    Chniov( F:Chan[ S ], 0, !chREL );	! release Slot ;
    Files[ Slot ]_ null!record;		! clear out tables ;

    return( true );			! everything is ok ;

end "VM Free";


Internal String Procedure VMLine( Integer Slot; Reference Integer More;
				  Integer Dir( 0 ) );
! ----------------------------------------------------------------------;
!									;
!	Line_ VMLine( Slot, More, Dir(0) )				;
!		Returns the next consecutive line from the file that	;
!		is connected to the specified slot.  More is set to	;
!		the line terminator (LF, FF, VT, CR or EOT) or to 0	;
!		when the end of the file is reached or the slot is 	;
!		inactive.  Dir is the direction to read the file ( 0	;
!	 	indicates forward, -1 or non-zero for backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Line"
    Integer Page, Byte, Copy, Count, Len, Last;
    Boolean Eol;
    String Str;

    More_ 0;				! Initialize for bad exits ;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( null );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( null );		!  not this time ;

    If ( Dir )				! verify proper usage of Dir ;
     then Dir_ -1			!  non-zero = backward = -1 ;
     else Dir_ +1;			!  was-zero = forward  = +1 ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then If ( Dir < 0 )		! Forward or Backward? ;
	   then F:Char[S]_ F:Size[S]	!   Set after last character ;
	   else F:Char[S]_ 0;		!   Set before first character ;

    If ( F:File[S] neq Page_ ( F:Char[S] div CharPerPage ) + 1 )
     then if not( MapPage( S, Page ) )	! Verify using right page ;
	   then return( null );		!  and page gets mapped ;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Copy_Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);
    If ( Byte < 0 )			! Means we have '440700,,x ;
     then Copy_ Byte_ Byte - BackByte;	! Point at an actual byte ;
    If ( Dir < 0 )			! If backward direction ;
     then Ibp( Copy );			!  then setup for Dbp by 1 ;

    Str_ Null;				! Initial return string ;

    If ( Dir geq 0 )			!   Fix count (# left) ;
     then If ( ( F:File[S] * CharPerPage ) > F:Size[S] )
	   then Count_ (F:Size[S] mod CharPerPage) - Count
	   else Count_ CharPerPage - Count;

    Len_ 0;				! Initialize string length ;
    F:Last[S]_ F:CRet[S]_ 0;		! Initialize break vars ;
    Last_ -1;				! Last character seen ;
    Eol_ false;				! Initialize line var ;
    While not( Eol )			! Read one line ;
     do begin "one line"

	If ( Count > 0 )		! Must have chars left ;
	 then begin "more characters"	!  to even try to read ;

	    If ( Dir < 0 )		! Forward or Backward? ;
	     then Dbp( Copy )		!  position the character ;
	     else Ibp( Copy );		!  pointer in the page ;

	    F:Char[S]_ F:Char[S] + Dir;	! Update file character count ;

	    Case More_ Ldb( Copy ) of begin	! check for end of line ;
		[#nul] begin "found eos break"
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    If ( Dir < 0 ) and		! Backing up? ;
		       not( F:Last[S] )		! First time through? ;
		     then Dbp( Byte )		!  yes, keep it this way ;
		     else Byte_ Copy;		!  no, update pointer ;
		    Len_ 0;			! Reset string length ;
		 end "found eos break";

		[#cr] begin "found return"
		    If ( Dir < 0 )
		     then if ( #LF leq Last leq #FF )
			   then F:CRet[S]_ #CR	! remember we saw this ;
			   else begin "lone cr"
			      If ( Copy = Byte )	! if first char ;
			       then F:Last[S]_ More	!  remember and go ;
			       else begin "eol cr"	! else do eol stuff ;
				 Eol_ true;		! set end of line ;
				 More_ F:Last[S];	! and get last one ;
				 F:Char[S]_ F:Char[S]+1	! bump pointer by 1 ;
			       end "eol cr";
			   end "lone cr";
		    If ( ( Dir > 0 ) and ( #CR = Last ) )
		     then Eol_ true;		! flag as end of line ;
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		    Byte_ Copy;			! synchronize pointers ;
		    Len_ 0;			! Reset string length ;
		 end "found return";

		[#lf][#vt][#ff][#eot] begin "found eol break"
		    Eol_ true;			! looks like one? ;
		    if ( Dir < 0 )		! were we going backward? ;
		     then if ( Copy = Byte )	!  and the first character ;
			   then begin "not eol"
			      Eol_ false;	!  yes, not really eol ;
			      F:Last[S]_ More;	!  remember this for later ;
			      F:Line[S]_ F:Line[S] + Dir;	! each line ;
			      If ( More = #FF )			! each FF ;
			       then F:PTxt[S]_ F:PTxt[S] + Dir;	! text page ;
			      If ( More = #EOT )		! each EOT ;
			       then F:MTxt[S]_ F:MTxt[S] + Dir;	! message ;
			   end "not eol"
			   else begin "got eol"
			      F:Char[S]_ F:Char[S] + 1;		! each char ;
			      More_ F:Last[S];			! eol-brk ;
			   end "got eol"
		     else begin "forward eol"
			If ( Last = #CR ) and ( #LF leq More leq #FF )
			 then F:CRet[S]_ Last;		! mark CR before Brk ;
			If ( More = #FF )		! for each FF seen ;
			 then F:PTxt[S]_ F:PTxt[S]+Dir;	!  count a text page ;
			If ( More = #EOT )		! for each EOT seen ;
			 then F:MTxt[S]_ F:MTxt[S]+Dir;	!  count a text message ;
			F:Line[S]_ F:Line[S] + Dir;	! count each line ;
		     end "forward eol";
		    If ( Len )			! length to concatenate? ;
		     then if ( Dir < 0 )	! yes, use right direction ;
			   then Str_ StMake( Copy, Len ) & Str
			   else Str_ Str & StMake( Byte, Len );
		 end "found eol break";

		[else] begin "normal character"
		    If ( Last = #CR ) and ( Dir > 0 )
		     then begin "lonely cr"	! else do eol stuff ;
			Eol_ true;		! set end of line ;
			F:Char[S]_ F:Char[S]-1;	! bump pointer by 1 ;
			More_ #CR;		! set eol to CR ;
			If ( Len )		! length to concatenate? ;
			 then Str_ Str & StMake( Byte, Len );
		     end "lonely cr"
		     else Len_ Len + 1		!  increment string length ;
		 end "normal character"
	    end;

	    If ( memory[ !rh( copy ) ] land 1 )	! bit 35 set ;
	     then begin "sequence numbers"	! in this word? ;

		If ( Dir < 0 )
		 then begin "seq backward"
		    F:Char[S]_ F:Char[S] - 4;	! tab already seen backwards ;
		    Count_ Count - 4;		!  update counts by 4 chars ;
		    If ( Len > 2 )
		     then begin "add text"	!  +1 for tab after seq # ;
			Ibp( Copy );		! make string skipping tab ;
			Str_ StMake( Copy, Len-2 ) & Str;
		     end "add text"
		 end "seq backward"
		 else begin "seq forward"
		    F:Char[S]_ F:Char[S] + 5;	! include tab in count here ;
		    Count_ Count - 5;		!  update counts by 5 chars ;
		    if ( Len neq 1 )
		     then Print( "*** Bad SEQ # in text file. ***"& Crlf );
		 end "seq forward";

		Byte_ Copy_ Copy + Dir;		!  update 1 word ;
		Len_ 0;				! Reset length ;

	     end "sequence numbers";

	    If ( 0 = Count_ (Count-1) max 0 )	! If now out of characters ;
	     then begin "fake eos break"
		If ( Len )			! length to concatenate? ;
		 then if ( Dir < 0 )
		       then Str_ StMake( Dbp( Copy ), Len ) & Str
		       else Str_ Str & StMake( Byte, Len );
		Len_ 0;				! Reset string length ;
	     end "fake eos break";

	    If ( More )				! if this is not a null ;
	     then Last_ More;			! last char for next time ;

	 end "more characters"
	 else begin "need next page"		! If no-more-characters ;

	    If ( F:Char[S] geq F:Size[S] )	! Forwards at end or ;
	       or ( F:Char[S] leq 0 )		!  backwards at beginning ;
	     then begin "end of file"		! At end-of-file? ;

		Eol_ true;			! Set flags true ;
		If ( Dir < 0 )			! If backing up ;
		 then More_ F:Last[S]		!  use last break at end ;
		 else begin "save info"
		    More_ 0;			!  set flag var to 0 ;
		    F:LSiz[S]_ F:Line[S];	!  save total size in lines ;
		    F:PSiz[S]_ F:PTxt[S];	!  save total size in pages ;
		    F:MSiz[S]_ F:MTxt[S];	!  save total size in pages ;
		 end "save info";
		Done "one line";		! Finish loop ;

	     end "end of file";			! Guess, read next page ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then return( null );		! error mapping! ;

	    ! ** assume: here at the beginning of the page ** ;
	    If ( Dir < 0 )			! Forward or Backward? ;
	     then Copy_ Byte_ point( 7, memory[(F:Page[S]+1) lsh 9], -1 )
	     else Copy_ Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );

	    If ( ( Page * CharPerPage ) > F:Size[S] )
	     then Count_ F:Size[S] mod CharPerPage
	     else Count_ CharPerPage;

	 end "need next page";

     end "one line";

    return( Str );			! give 'em what they came for ;

end "VM Line";


Internal Boolean Procedure VMText( Integer Slot; String Text );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMText( Slot, Text, Dir(0) )				;
!		Writes the next consecutive line or lines to the file	;
!		that is connected to the specified slot.		;
!									;
! ----------------------------------------------------------------------;
begin "VM Text"
    Integer Page, Byte, Char, Count;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( !rh( F:Mode[S] ) )		! were we writing? ;
     then return( false );		! no, don't bother! ;

    If ( F:Char[S] = -1 )		! we are mapped? ;
     then F:Char[S]_ 0;			!   Set before first character ;

    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
     then begin
	Print( "Page map error: p",page,"  c",F:Char[S],"  f",F:Chan[S],crlf );
	return( false );		! if no page, error return ;
     end;

    Count_ F:Char[S] mod CharPerPage;	! Character position in page ;
    Byte_point(7,memory[(F:Page[S] lsh 9)+(Count div 5)],((Count mod 5)*7)-1);

    Count_ CharPerPage - Count;		! Fix count (# left) ;

    while ( length( Text ) )		! Must have some text left ;
     do begin "writing line"

	If ( Count > 0 )		! Must have room left on page ;
	 then begin "more characters"	!  to even try to write ;

	    If not( Char_ Lop( Text ) )	! if char = null then try next ;
	     then continue "writing line";

	    IDpb( Char, Byte );		! deposit byte at position ;
	    F:Char[S]_ F:Char[S] + 1;	! Update file character count ;

	    Case ( Char ) of begin	! check for end of line ;
		[#cr] F:CRet[S]_ #CR;	! remember we saw this ;

		[#lf][#vt][#ff][#eot] begin "count lines"
		  F:Last[S]_ Char;		! remember eol character ;
		  F:Line[S]_ F:Line[S] + 1;	! count lines seen ;
		  If ( Char = #FF )		! for each FF seen ;
		   then F:PTxt[S]_ F:PTxt[S]+1;	!  count a text page ;
		  If ( Char = #EOT )		! for each EOT seen ;
		   then F:MTxt[S]_ F:MTxt[S]+1;	!  count a text message ;
		 end "count lines";

		[else] F:CRet[S]_ 0	! forget we saw a cr ;
	     end;

	    Count_ (Count-1) max 0;	! keep character count ;

	 end "more characters"
	 else begin "need next page"	! If no-more-characters ;

	    If not( MapPage( S, Page_ ( F:Char[S] div CharPerPage ) + 1 ) )
	     then begin
		Print( "Page(2) map error: ",page," ",F:Char[S],crlf );
		return( false );	! if no page, error return ;
	     end;

	    Byte_ point( 7, memory[F:Page[S] lsh 9], -1 );
	    Count_ CharPerPage;		! always a full page to write in ;

	 end "need next page";

     end "writing line";

    If ( F:Char[S] geq F:Size[S] )	! At or Past end of file? ;
     then begin "end of file"

	F:Size[S]_ F:Char[S];		!  save size in characters ;
	F:LSiz[S]_ F:Line[S];		!  save total size in lines ;
	F:PSiz[S]_ F:PTxt[S];		!  save total size in pages ;
	F:MSiz[S]_ F:MTxt[S];		!  save total size in pages ;

     end "end of file";			! Guess, read next page ;

    return( true );			! give 'em what they came for ;

end "VM Text";


Internal Boolean Procedure VMMove( Integer Slot, HowMany(1) );
! ----------------------------------------------------------------------;
!									;
!	Ok_ VMMove( Slot, HowMany(1) )					;
!		Moves the position pointer forward or backward up to	;
!		HowMany lines in the file.  Returns true if the slot is	;
!		active and HowMany lines exist, otherwise it returns	;
!		false and leaves the pointer positioned at logical end	;
!		of file (at the beginning if direction is backward).	;
!									;
! ----------------------------------------------------------------------;
begin "VM Move"
    Own Integer Brk;

    If not( 1 leq Slot leq MaxSlot )	! only "my" Slots are ;
     then return( false );		!  valid, else return ;

    If not( S_ Files[ Slot ] )		! slot assigned? ;
     then return( false );		!  not this time ;

    If not( HowMany )			! we can always move ;
     then return( true );		!  a distance of 0 ;

    while ( HowMany )			! while lines to go read them ;
     do begin "moving lines"

	If not( length( VMLine( Slot, Brk, HowMany < 0 ) ) or Brk )
	 then return( false );		!  then take the cows to town ;

	If ( HowMany > 0 )		! decrement the right direction ;
	 then HowMany_ HowMany - 1	!  down to zero  ;
	 else HowMany_ HowMany + 1;	!  or up to zero ;

     end "moving lines";

    return( true );			! give 'em what they came for ;

end "VM Move";


Internal Simple Boolean Procedure VMFile( String Spec; Integer Mode(VM$Read) );
! ----------------------------------------------------------------------;
!									;
!	Slot_ VMFile( StringSpec, AccessMode )				;
!		Opens a file for the specified access.  A positive	;
!		slot number is returned if the file is available.  A 	;
!		0 means no slots and a negative value means there was	;
!		some file error or the file is not available.		;
!									;
! ----------------------------------------------------------------------;
begin "VM File"
    Own Safe Integer Array File[ 0 : !RBLIC ];
    Preset!with '17, cvsix("DSK   "), 0;
    Own Safe Integer Array Dev[ 0 : 2 ];
    Own Integer Slot;

    If not( Slot_ VMSlot )		! If no Slots available ;
     then return( false );		!  then no file opened ;

    If not( S_ Files[ Slot ] )		! slot assigned? *Debug check* ;
     then return( false );		!  not this time *huh why not* ;

    If not( VMSpec( Spec, FileSpec ) )	! trouble with the spec? ;
     then return( false );		!  then don't do anything ;

    If not(VM$Read leq !rh(Mode) leq VM$Multi)	! if an invalid mode ;
     then return( false );		! Read, Write, Update, Multi ;

    Dev[ 0 ]_ Ldb( Point(6,Mode,17) );	! Set proper mode (!ioASC) ;
    Dev[ 1 ]_ FileSpec[ S!Dev ];	! Setup device block ;
    Chnior( F:Chan[S],Dev[0],!chOPN );	! OPEN [ '17, Dev, 0 ] ;
    If not( !Skip! )			! If open-failure ;
     then begin "open failure"		!  then no file opened ;
	VMFree( Slot );			! Free the slot ;
	return( !Xwd( -1,-1 ) );	!  and return ;
     end "open failure";

    Mode_ !rh( F:Mode[S]_ Mode );	! Remember this as we need to ;
    arrclr( File );			! Clear out unused fields ;
    File[ !RBCNT ]_ !RBLIC;		! Setup file lookup block ;
    if ( FileSpec[ S!Usr ] )
     then File[ !RBPPN ]_ location( FileSpec[ S!Usr ] );
    File[ !RBNAM ]_ FileSpec[ S!Nam ];
    File[ !RBEXT ]_ FileSpec[ S!Ext ] land (-1 lsh 18);

    If ( VM$Write neq Mode )		! if mode neq VM$Write ;
     then begin "read update"		!   do lookup ;

	Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
	If not( !Skip! ) and ( 0 = !rh(File[!RBEXT]) )
	 then begin "not found"		! no skip and file not found ;
	    If ( VM$Read neq Mode )	! if mode neq VM$Read, do create ;
	     then begin "update stuff"

		Chnior( F:Chan[ S ], File[ !RBCNT ], !chENT );
		if ( !Skip! )		! enter ok, so close & lookup ;
		 then begin "ok find it"
		    Chnior( F:Chan[ S ], memory[0], !chCLS );
		    Chnior( F:Chan[ S ], File[ !RBCNT ], !chLK );
		 end "ok find it";

	     end "update stuff";	! if !skip! found or created file ;
	 end "not found";		!  else some other file error ;

	if not( !Skip! )		! lookups failed - not ERFNF% ;
	 then begin "huh what's up"	! unless happened 2nd time ;
	    VMFree( Slot );		! so, clear out and return ;
	    return( !Xwd( -1,!rh(File[!RBEXT]) ) );
	 end "huh what's up";

     end "read update";			! have old file, or new file ;

    If ( VM$Read neq Mode )		! for VM$Write, VM$Update, VM$Multi ;
     then Chnior( F:Chan[ S ], File[ !RBCNT ],
		   if (Mode = VM$Multi)	! if mode eql VM$Multi ;
		     then !chMEN	!  then use multiple enter ;
		     else !chENT );	!  else use normal enter ;

    If not( !Skip! )			! If lookup-enter failure ;
     then begin "no file or access"	!  then Free the slot ;
	VMFree( Slot );			!  and return error code ;
	return( !Xwd( -1,!rh(File[!RBEXT]) ) );
     end "no file or access";

    F:FPPN[ S ]_ File[!RBPPN];		! File directory ;
    F:Name[ S ]_ File[!RBNAM];		! File name ;
    F:FExt[ S ]_ File[!RBEXT];		! File extension ;
    F:Size[ S ]_ File[!RBSIZ] * 5;	! File size in characters (Rounded) ;
    F:FLic[ S ]_ !rh( File[!RBLIC] );	! File license ;

    F:Time[ S ]_ (((File[!RBPRV] lsh -12) land '3777) * 60 )
	       + ((File[!RBLIC] lsh -18) land '77);
    F:Date[ S ]_ (Ldb( Point( 2,File[!RBEXT],21 ) ) lsh 12)
	       + (File[!RBPRV] land '7777);

    if ( Mode > VM$Read ) and		! are we writing and ;
	( VM$Append land F:Mode[ S ] )	! wanting to append ;	
	and  ( F:Size[ S ] )		! must have something ;
     then begin "tack it on"
	VMMove( Slot, -1 );		! backup from the end ;
	VMMove( Slot, 1 );		! and move forward ;
     end "tack it on";
	 
    return( Slot );			! Return the slot number ;

end "VM File";

end "VM Package";
    @?
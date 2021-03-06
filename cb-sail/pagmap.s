Own Integer Array VirtualStorage[0:'2000];
Own Integer Base, MemAdr;
Own Integer Array Arg[0:1];

simple procedure PageUp;
! ----------------------------------------------------------------------;
!									;
!	PageUp		Initialize "funny" memory array for paging.	;
!									;
! ----------------------------------------------------------------------;
begin
    Base _ ( Location( VirtualStorage[0] ) + '1000 ) lsh -9;
    Calli( !Xwd( '2001, Base ), calli!VCLEAR );
    MemAdr_ Base lsh 9;
end;
require PageUp initialization;

simple procedure PageDn;
! ----------------------------------------------------------------------;
!									;
!	PageDn		Reset "funny" memory array to zero.		;
!									;
! ----------------------------------------------------------------------;
begin
    Calli( !Xwd( '2001, Base ), calli!VCLEAR );
    Calli( !Xwd( '6001, Base ), Calli!VCREAT );
end;


internal simple boolean procedure PageMp( Integer Chan,FPage,MPage,FProt );
! ----------------------------------------------------------------------;
!									;
!	PageMp		Map the specified file page into memory.	;
!									;
! ----------------------------------------------------------------------;
begin
    Calli( !Xwd('2001, MPage), Calli!VCLEAR );	! clear memory page;
    Arg[ 0 ]_ !Xwd((FProt lsh 10) lor 1,MPage);	! prot & count,,page;
    Arg[ 1 ]_ FPage;				! file-page;
    Chnior( Chan, Arg[0], !chMFP );		! map file page;
    Return( !skip! );				! status;
end;

  
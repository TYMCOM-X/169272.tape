
begin

 require "MYSAIL.DEF" source!file;
 require "(SAILIB)SAILIB.DEF" source!file;
 get!module(EXTEND);

 require "BRKINI.REQ" source!file;
 require "CMDSCN.REQ" source!file;


!
!  Record layoyut in data-file
!
!  Field		Size	Columns
! ======================================
!
! ==== All Records ====
!
!  Record-Type		  2	  1-  2
!
!    Transaction  = 00
!    AccountDesc  = 01
!    AccountEvent = 02
!
!  AccountCode		  2	  3-  4
!
! ==== Transaction Record ====
!
!  Reference-Number	  8	  5- 12
!  Posting-Date		  6	 13- 18
!  Transaction-Date	  6	 19- 24
!  Description		 30	 25- 54
!  City-Name		 14	 55- 68
!  State-Name		  2	 69- 70
!  Amount		 10	 71- 80
!
! ==== Account Description Record ====
!
!  Account-Type		  4	  5-  8
!  Account-Number	 20	  9- 28
!  Openning-Date	  6	 29- 34
!  Closing-Date		  6	 35- 40
!  Account-Info		 10	 41- 50
!  Account-Name		 30	 51- 80
!
! ==== Account Event Record ====
!
!  Event-Code		  4	  5-  8
!
!    Comment         = 0000
!    Open-Account    = 0001
!    Close-Account   = 0002
!    Reset-Cycle     = 0010
!    Post-Interest   = 0011
!    Post-Charges    = 0012
!    Status-Change   = 0020
!    Change-Interest = 0021
!    Change-Service  = 0022
!
!  Event-Date		  6	  9- 14
!  Event-Description	 20	 15- 34
!
! ======================================
!
;

  
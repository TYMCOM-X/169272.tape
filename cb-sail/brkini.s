Own Integer Brk, BrkLin, BrkNam, BrkUsr, BrkPpn, BrkWht, BrkBrk, BrkCmd;
simple procedure BrkIni;
! ----------------------------------------------------------------------;
!									;
!	BrkIni		Define and initialize the breakset tables	;
!			to be used by various INPUT and SCAN calls	;
!			throughout the program.				;
!									;
! ----------------------------------------------------------------------;
begin
    Define ##Cmd = {";=/ "&#ht}
    ,      ##Wht = {" "&#ht&#cr}
    ,      ##Brk = {" !@#$%^&*()-_+=~`[]|\:;'<>,.?/" & '42 & '173 & '175}
    ,      ##Chr = {"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"}
    ,      ##Num = {"0123456789"}
    ,      ##Nam = {##Chr & ##Num}
    ,      ##Ppn = {"01234567,"}
    ,      ##End = {#lf&#vt&#ff&#cr&#esc};

    setbreak(BrkLin_Getbreak,#lf,         null, "SINF");  ! line;
    setbreak(BrkNam_Getbreak,##Nam,       crlf, "RXNF");  ! name or token;
    setbreak(BrkUsr_Getbreak, ")",        null, "SINK");  ! end of username;
    setbreak(BrkPpn_Getbreak,##Ppn, ##Wht&crlf, "RXNK");  ! ppn - octal;
    setbreak(BrkWht_Getbreak,#lf & ##Wht, crlf, "RXNK");  ! white space;
    setbreak(BrkBrk_Getbreak,#lf & ##Brk, #cr,  "RINK");  ! all break chars;
    setbreak(BrkCmd_Getbreak,#lf & ##Cmd, #cr,  "SINK");  ! command line;
end;
require BrkIni initialization;


   
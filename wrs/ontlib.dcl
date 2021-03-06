external record!class otm (
    string	Host;
    string	Id;
    string	Key;
    string	Addr;
    r!p(otm)	Link );
external r!p(otm) otFMap;	comment forwarding data from (MAIL)ONTYME.DAT;
external r!p(otm) otRMap;	comment reverse data from (MAIL)ONTYME.DAT;
external string otHOST;		comment current host name;
external string otID;		comment current user ID;
external integer otMsgChan;	comment msg channel, default -1;
external integer otTimeOut;	comment time limit - default 300;
external integer otPOS;		comment position on output line [0:n];
external procedure otGetMap;
external r!p(otm) procedure otRLook( string RPath,Host(null) );
external boolean procedure otSync;

define
    OKAY = true;
external boolean procedure otACmd( string CMDLINE; boolean IsOKAY(false) );
comment
    Simple command - expects reply of ACCEPTED.
;
external boolean procedure otLCmd( string CMDLINE; procedure PROC );
comment
    Simple command - expects reply of ACCEPTED.
;
external boolean procedure otConnect (
    string	HOST );
external boolean procedure otSignon (
    string	ID;
    string	KEY );
external boolean procedure otSend( r!p(mai) M );
external boolean procedure otRead (
    procedure	MsgSvc );
external boolean procedure otLogout;
 
external boolean maiNeedMailer;
external record!class mai (
    string	RCPT;
    string	Received;
    string	Return.path;
    string	Reply.to;
    string	From;
    string	Sender;
    string	Date;
    string	To;
    string	Cc;
    string	Bcc;
    string	Message.ID;
    string	Keywords;
    string	Subject;
    string	Resent.from;
    string	Resent.date;
    string	Resent.to;
    string	Resent.cc;
    string	Other;
    string	Text );
external record!class adr (
    string	User;
    string	SubHost;
    string	Host;
    string	Net );
external string procedure maiTrim( string S );
external string procedure maiCatList( reference string L; string S );
external string procedure maiDate;
comment
    Date:
	Return current local date and time in form
		WWW, DD MMM YY HH:MM:SS ZZZ
	as recommended in RFC #822.
;
external string maiName;
external string maiHost;
external string maiNet;
external r!p(adr) maiMyAddress;
external r!p(mai) procedure maiMParse( string TXT );
comment
    Mail Parse:
	Return record containing parsed message supplied in TXT.
;
external string procedure maiMMake( r!p(mai) T );
comment
    Mail Make:
	Make (or unparse) the parsed message in record T.
;
external string procedure maiAScan(
    reference string RawAddr;
    reference integer B );
comment
    Address Scan:
	Return the first address from an address or path list in RawAddr.
	Addresses are seperated by colon, semicolon or comma.
;
external string procedure maiPLop(
	reference string Path;
	reference integer B  );
comment
	Lop the first At-Domain off the front of PATH.  If none exist,
	return the mailbox and do not alter the PATH.
;
external string procedure maiFPath( r!p(mai) T );
comment
    Forward Path:
	Return the forward path in string form based on the
	To, Cc and Bcc fields in parsed message T.
;
external string procedure maiRPath( r!p(mai) M );
comment
    Return Path:
	Return the return path in string form based on the
	Return-path, From and Sender fields in parsed message T.
;
external string array maiTopDomains[1:3];
external boolean procedure maiIsTop( string DOMAIN );
external r!p(adr) procedure maiAParse( string Addr );
external string procedure maiAMake( r!p(adr) A );
external boolean procedure maiRunMailer;
comment
    Run Mailer:
	Unconditionally run the mailer program (MAIL)MAILER in a child
	frame.  Do not wait for completion, ignore errors.
;
external boolean procedure maiSend;
comment
    Send:
	Cause immediate processing of queued messages by running the
	mailer.  If no messages have been queued, no action is taken.
;
external string procedure maiQFile( string RCPT );
external procedure maiWaiting( integer AUN; string FROM(null) );
external boolean recursive procedure maiQueue( r!p(mai) T );
comment
    Queue mail for delivery:
	Parsed message in T is checked, processed and appended to the
	appropriate queue(s).  Local delivery takes place immediately.
	MaiSend may be called following one or more maiQueue calls to
	effect immediate delivery to non-local destinations (if any).
;
external recursive procedure maiRTS(
    r!p(mai) M;
    string LINE1(null), LINE2(null), LINE3(null), LINE4(null) );
comment
    Return To Sender:
	Take parsed message M and return it to its sender as
	indicated by the Return Path (maiRPath).  The returned
	message is included in the body of the return notice
	along with comments LINE1-LINE4.
;
external integer procedure maiFEMessage(
    procedure UserProc;
    string QName;
    boolean DeleteQ(false) );
comment
    For Each Message (in file QName):
	Call user procedure UserProc.  The message is passed
	unparsed as a reference string argument to UserProc.
	If DeleteQ is true, the file will be deleted.
;
  
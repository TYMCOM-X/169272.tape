
simple procedure MyText( string text; integer port(-1) );
begin

    start!code
	HRL	'1,Port;		! get port number ;
	HRRI	'1,'67;			! use .axOPC ;
	HRLI	'0,'042040;		! 'auxcal 1,' ;
	HRRI	'0,Text;		! address on stack of ptr ;
	SOJ	'0,;			! minus 1 = count ;
	XCT	'0;			! auxcal 1,block <count><ptr> ;
    end;

end;

   
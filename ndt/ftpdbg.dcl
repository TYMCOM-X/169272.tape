COMMENT the debugging routines for TYMSHARE FTP package;

EXTERNAL string  procedure chname( integer character );
EXTERNAL string  procedure cvHex( integer character );
EXTERNAL integer procedure unHex( reference string txt );
EXTERNAL string  procedure sDclass( integer data!class!byte );
EXTERNAL string  procedure sDheader( reference string dataStream );
EXTERNAL string  procedure sLinkControl( reference string dataStream ); 
EXTERNAL string  procedure sApplControl( reference string dataStream ); 
EXTERNAL	 procedure ax!packet( string packet );

 

EXTERNAL string  procedure sWhen( integer dec!date!time );
COMMENT	integer to tymftp format.
;
EXTERNAL string  procedure WhenSt( integer dec!date!time );
COMMENT	integer to human-preferred.
;
EXTERNAL integer procedure cvWhen( string when );
COMMENT	tymftp format to integer.
;
EXTERNAL integer procedure cvNumber( string when );
COMMENT	tymftp format to integer.
;
EXTERNAL string procedure cvNumStr( integer when );
COMMENT	non-negative integer to tymftp format (byte stream);
;

    

comment	byte.spec can be a standard 7-bit byte pointer, or
		-1,,location(storage!word) or location(storage!word) 

 "normal-string"_	ASZSTR( byte.spec.for.asciz.string )
 seven.bit.bytepointer_	BYPOK(  byte.spec )
 "dangerous-string"_	CONSTR( byte.spec, desired.size )
sign.and.position_	CMPSTR( "first", "second" )
 "normal-string"_	DYNSTR( byte.spec, desired.size ) 

			STRACH( string.concat.chan, character.to.append)
			STRADD( string.concat.chan, "string-to-append")
 "accumulated-string"_	STRCLS( @string.concat.chan.to.close )
 accumulated.length_	STRLEN( string.concat.chan )
 string.concat.chan_	STROPN( buffer.size.in.bytes )
 "accumulated-so-far"_	STRPEK( string.concat.chan ) 

 updated.bytptr_	STRSTF( byte.spec, "to-deposit",
				suppress.asciz.closing.null(false) )
target.position_	SUBEQU( "target", "source" )
 "normal-string"_	UPDSTR( byte.spec, updated.byte.spec )
;
forward external string  procedure ASZSTR( integer byte!spec );
forward external integer procedure BYPOK(  integer byte!spec );
forward external string  procedure CONSTR( integer byte!spec, count );
forward external integer procedure CMPSTR( string first, second );
forward external string  procedure DYNSTR( integer byte!spec, count );
forward external	 procedure STRACH( integer concat, character!to!add );
forward external	 procedure STRADD( integer concat; string to!add );
forward external string  procedure STRCLS( reference integer concat );
forward external integer procedure STRLEN( integer concat );
forward external integer procedure STROPN( integer buffer!size );
forward external string  procedure STRPEK( integer concat );
forward external integer procedure STRSTF( integer byte!spec; string str;
						boolean nonull(false) );
forward external integer procedure SUBEQU( string target, source );
forward external string  procedure UPDSTR( integer byte!spec, updated!byteptr );


    

external simple procedure IntIni(Itemvar Int;
	Integer Port, FileChan, FilePage, FileSize, ParentPrint );
external simple procedure IntCause( Integer InterruptChannel );
external integer procedure IntFin;
external simple procedure IntZap;
external simple procedure IntLog( Boolean TrueFalseValue );
require "PCOINT" library;

    
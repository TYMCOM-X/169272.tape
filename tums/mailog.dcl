external integer logChan;
external string procedure logUFD( integer PPN );
external string logModule;
external simple procedure logCTY( string MSG );
external simple procedure logDIE(
    string CODE;
    string MSG1(null),MSG2(null),MSG3(null),MSG4(null),MSG5(null) );
external procedure logExit;
external boolean logDirty;
external string logFile;
external procedure logOS( string S );
external boolean procedure logCopy( string logFile );
external procedure logClose;
external procedure logOpen;
  
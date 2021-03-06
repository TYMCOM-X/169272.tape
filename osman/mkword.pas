
PROGRAM Vocabulary;

CONST STRLENGTH=      20;   (*Number of charecter in each word*)
      FILENAMELENGTH= 10;   (*Number of charecter in file name*)
      ARRAYDIM=       1000; (*Size of array*)

TYPE  Name=          STRING[ STRLENGTH ];
      Vect=          ARRAY[ 1..ARRAYDIM ] OF Name;
      FileName=      PACKED ARRAY[ 1..FILENAMELENGTH ] OF CHAR;
      AssembledWord= PACKED ARRAY[ 1..STRLENGTH ] OF CHAR;

VAR   LowerBound:       INTEGER;
      ArrayCount:       INTEGER;
      UpperBound:       INTEGER;
      TheWord:          AssembledWord;
      UnsortedFileName: FileName;
      SortedFileName:   FileName;
      ListA:            VECT;
      AllDone:          BOOLEAN;
      ArrayFull:        BOOLEAN;
      InFile:           TEXT;
      OutFile:          TEXT;


(* *******************************************************************
   *                                                                 *
   *   GetFileName   Gets file name from TTY.                        *
   *                                                                 *
   ******************************************************************* *)


PROCEDURE GetFileName (VAR NameOfFile: FileName);

VAR
I, J: INTEGER;

BEGIN
  I:= 1;
  READLN;
  WHILE NOT EOLN DO
    BEGIN
      READ (NameOfFile[I]);
      I:= I + 1;
    END;
  FOR J:= I TO FILENAMELENGTH DO
  NameOfFile[I]:= ' ';
END;


(* *******************************************************************
   *                                                                 *
   *   UpperCase   This function converts charecter in "Ch" to       *
   *               uppercase.                                        *
   *                                                                 *
   ******************************************************************* *)


FUNCTION UpperCase (Ch: CHAR): CHAR;

BEGIN
  UpperCase:= CHR((ORD(Ch)-ORD('a')+ORD('A')))
END;


(* *******************************************************************
   *                                                                 *
   *   GetAWord   Packs characters into a PACKED ARRAY untill it     *
   *              gets a word. While packing characters it converts  *
   *              the characters into uppercase.                     *
   *                                                                 *
   ******************************************************************* *)


PROCEDURE GetAWord (VAR PackedWord: AssembledWord; VAR AllDone: BOOLEAN);

VAR
    Ch:         CHAR;
    I, J:       INTEGER;
    GotAWord:   BOOLEAN;

BEGIN
  GotAWord:= FALSE;
  I:= 1;
  REPEAT
    IF EOF(inFile) THEN
      AllDone:= TRUE
    ELSE
      BEGIN
        READ (InFIle, Ch);
        IF Ch IN['A'..'z'] THEN
          BEGIN
            IF Ch >= 'a' THEN
              PackedWord[I]:= UpperCase(Ch)
            ELSE
              PackedWord[I]:= Ch;
            I:= I + 1;
            IF NOT (InFile ^ IN['A'..'z']) THEN
              BEGIN
                FOR J:= I TO STRLENGTH DO
                    PackedWord[J]:= ' ';
                GotAWord:= TRUE;
              END;
          END;
      END;
    UNTIL AllDone OR GotAWord
END;


(* *******************************************************************
   *                                                                 *
   *   Sort   It requires three parameters, a variable parameter     *
   *          array, lower array limit and upper array limit. It     *
   *          returns variable array sorted.                         *
   *                                                                 *
   *          R= Variable vector, Lo= Low limit of the vector and    *
   *          UpIn= Upper limit of the vector.                       *
   *                                                                 *
   ******************************************************************* *)


PROCEDURE Sort(VAR R: VECT; Lo: INTEGER; UpIn: INTEGER);

VAR
    I,J,Up: INTEGER;
    TempR:  NAME;

BEGIN
  Up:= UpIn;
  WHILE Up > Lo DO
    BEGIN
      J:= Lo;
      FOR I:= Lo TO Up - 1 DO
        BEGIN
          IF R[I] > R[I + 1] THEN
            BEGIN
              TempR:= R[I];
              R[I]:= R[I + 1];
              R[I + 1]:= TempR;
              J:= I;
            END;
        END;
      Up:= J;
    END;
END;


(* *******************************************************************
   *                                                                 *
   *   GetTextFile   Assembles words into array from input text file *
   *                 untill EOF or array gets full.                  *
   *                                                                 *
   ******************************************************************* *)


PROCEDURE GetTextFile (VAR TopOfArray: INTEGER);

BEGIN
UpperBound:= 0;
AllDone:= FALSE;
ArrayFull:= FALSE;
WHILE NOT AllDone AND NOT ArrayFull DO
  BEGIN
    UpperBound:= UpperBound + 1;
    GetAWord (TheWord, AllDone);
    ListA[ UpperBound ]:= TheWord;
    IF UpperBound= ARRAYDIM THEN
      BEGIN
        WRITELN;
        WRITELN ('ARRAY FULL, will only sort ', UpperBound:4, ' items.');
        TopOfArray:= UpperBound;
        BREAK;
        ArrayFull:= TRUE;
      END
    ELSE TopOfArray:= UpperBound;
  END;
END;


(* *******************************************************************
   *                                                                 *
   *   SortIt   Sorts the array and writes the sorted array into     *
   *            output vocabulary file.                              *
   *                                                                 *
   ******************************************************************* *)


PROCEDURE SortIt (ArrayCount: INTEGER);

VAR
     I: INTEGER;
BEGIN
  I:= 1;
  UpperBound:= ArrayCount;
  WRITE ('Starting Sort...');BREAK;
  Sort (ListA,1,UpperBound);
  WRITELN (UpperBound:5,' items... sorted.');BREAK;
  REWRITE (OutFile,SortedFileName);
  FOR I:= 1 TO UpperBound DO
    IF ListA[I] <> ListA[I+1] THEN
      WRITELN (OutFile,ListA[I]);
END;


BEGIN
      (* OPEN Statement below makes terminal the INPUT and OUTPUT
	device. This PASCAL runs on DEC's PDP-10 mainframe. *)

OPEN (TTY); REWRITE (TTYOUTPUT); INPUT:=TTY; OUTPUT:=TTYOUTPUT;

WRITELN;
WRITELN;
WRITELN ('                ...DICTIONARY...');
WRITELN ('...Makes a sorted dictionary of an input file...');
WRITELN;
WRITE ('Input file = ');BREAK;
GetFileName (UnsortedFileName);
RESET (InFile, UnsortedFileName);
WRITE ('Output File = ');BREAK;
GetFileName (SortedFileName);
GetTextFile (ArrayCount);
SortIt (ArrayCount);
WRITELN;
WRITELN;
END.
   
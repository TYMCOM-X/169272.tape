ID DIVISION.
PROGRAM-ID.  SORTER.
ENVIRONMENT DIVISION.
CONFIGURATION SECTION.
OBJECT-COMPUTER.  PDP-10 MEMORY 25 MODULES.
INPUT-OUTPUT SECTION.
FILE-CONTROL.

        SELECT INPUT-FILE ASSIGN TO DSK
                RECORDING MODE IS ASCII.

        SELECT SORT-FILE ASSIGN TO DSK, DSK, DSK, DSK, DSK, DSK.

DATA DIVISION.
FILE SECTION.

FD  INPUT-FILE
    VALUE OF ID IS INPUT-FILE-NAME VALUE OF USER-NUMBER IS 011011,153520.
01  INPUT-RECORD                        PIC X(76).

SD  SORT-FILE.
01  SORT-RECORD.
        05  SORT-FIELD-1B       PIC X(5).
        05  SORT-FIELD-1A       PIC 9(5).
        05  FILLER              PIC 9(3).
        05  SORT-FIELD-4-2      PIC X(4).
        05  SORT-FIELD-4-1      PIC X(4).
        05  INPUT-CODE          PIC X(3).
        05  FILLER              PIC X(3).
        05  SORT-FIELD-2.
            10  ORIG-CHAR       PIC X
                OCCURS 6 TIMES
                INDEXED BY ORIG-IDX.
        05  FILLER              PIC X(43).
        05  SORT-TAG            PIC 9(2).
        05  SORT-FIELD-2-TAG.
            10  TAG-CHAR       PIC X
                OCCURS 5 TIMES
                INDEXED BY TAG-IDX.
        05  FILLER REDEFINES SORT-FIELD-2-TAG.
            10  SORT-1-3       PIC X(3).
            10  FILLER         PIC X(2).

WORKING-STORAGE SECTION.

77  WAIT-TIME   COMP-1 VALUE IS 5.

01  TABLE-FOR-CODE-SORT.

        05  SORTED-LIST-OF-CODES                PIC X(60) VALUE
          'BCC10BCO04BPC11BPO05BSC12BSO06SCC07SCO01SPC08SPO02SSC09SSO03'.

        05  FILLER     REDEFINES SORTED-LIST-OF-CODES.
                10  OF-THE-TABLE       OCCURS 12 TIMES
                        INDEXED BY THE-INDEX
                        ASCENDING KEY THE-CODE.
                        15  THE-CODE    PIC X(3).
                        15  THE-TAG     PIC 9(2).

01  INPUT-FILE-NAME        PIC X(9)  VALUE 'POSITN'.
01  OUTPUT-FILE-NAME       PIC X(9)  VALUE 'POSITN'.



PROCEDURE DIVISION.
DECLARATIVES.

OPEN-ERROR SECTION.

USE AFTER STANDARD ERROR PROCEDURE ON INPUT-FILE OPEN.

OPEN-RECOVERY.
        ADD 1 TO WAIT-TIME.

END DECLARATIVES.

        SORT SORT-FILE ON ASCENDING KEY
                SORT-FIELD-1B,
                SORT-FIELD-1A,
                SORT-1-3,
                SORT-TAG,
                SORT-FIELD-4-1,
                SORT-FIELD-4-2,

        INPUT PROCEDURE IS INPUT-PROCEDURE,
        GIVING INPUT-FILE.
        STOP RUN.



INPUT-PROCEDURE SECTION.

*       DISPLAY 'INPUT  FILE: ' WITH NO ADVANCING.
*       ACCEPT INPUT-FILE-NAME.
*
*       DISPLAY 'OUTPUT FILE: ' WITH NO ADVANCING.
*       ACCEPT OUTPUT-FILE-NAME.
*       IF OUTPUT-FILE-NAME IS EQUAL TO SPACES,
*               MOVE INPUT-FILE-NAME TO OUTPUT-FILE-NAME.
*
        OPEN INPUT INPUT-FILE.


LOOP-1.

        READ INPUT-FILE INTO SORT-RECORD    AT END
                CLOSE INPUT-FILE,
                GO TO END-INPUT-PROCEDURE.

        IF INPUT-RECORD IS EQUAL TO SPACES
                GO TO LOOP-1.


        SET THE-INDEX TO 1.
        SEARCH ALL OF-THE-TABLE
                AT END
                        MOVE 13 TO SORT-TAG,

                WHEN THE-CODE (THE-INDEX) = INPUT-CODE
                        MOVE THE-TAG (THE-INDEX) TO SORT-TAG.






















**************************************************************
*
*  WE WISH TO HAVE THE THIRD MOST MAJOR SORT-FIELD, 
*  'SORT-FIELD-2-TAG', SORTED BY THE TWO LEXICAL ITEMS
* CONTAINED IN SORT-FIELD-2.  THE FIRST ITEM IS MORE MAJOR THAN
* SECOND.
*
* THE FIRST ITEM IS ALWAYS PRESENT. IT CAN CONTAIN FROM 1 TO 3
* CHARACTERS.
*
* THE SECOND ITEM IS SEPARATED FROM THE FIRST BY AT LEAST ONE
* BLANK. IT MAY OR MAY NOT EXIST. IF IT DOES, IT WILL CONTAIN
* EXACTLY TWO CHARACTERS. THESE WILL APPEAR IN THE REVERSE
* ORDER REQUIRED FOR SORTING.
*
* THE SOLUTION IS TO CREATE A 5-BYTE TAG
* AT THE END OF THE SORT RECORD, AS A SUBSTITUTE SORT
* FIELD, AND TO CONSTRUCT IT BY PARSING THE FIRST LEXICAL
* ITEM INTO THE FIRST THREE BYTES, AND
* THE SECOND ITEM INTO THE LAST 2 BYTES WITH THE CHARACTERS
* REVERSED.
*
* THE FIRST ITEM IS THE STOCK CODE, THE SECOND THE OPTION-CODE.
*
*

        SET ORIG-IDX, TAG-IDX TO 1.
        MOVE SPACES TO SORT-FIELD-2-TAG.

GET-STOCK-CODE.
        IF ORIG-CHAR (ORIG-IDX) IS EQUAL TO SPACE  OR
           ORIG-IDX IS EQUAL TO 4,
*               SET ORIG-IDX DOWN BY 1,
*               SET TAG-IDX TO 5,
*               GO TO GET-OPTION-CODE.
                GO TO RELEASE-RECORD.

        MOVE ORIG-CHAR (ORIG-IDX) TO TAG-CHAR (TAG-IDX).
        SET ORIG-IDX, TAG-IDX UP BY 1.
        GO TO GET-STOCK-CODE.


*ET-OPTION-CODE.
*       SET ORIG-IDX UP BY 1.
*       IF ORIG-CHAR (ORIG-IDX) IS EQUAL TO SPACE   AND
*          ORIG-IDX IS EQUAL TO 6,
*               GO TO RELEASE-RECORD.
*
*       IF ORIG-CHAR (ORIG-IDX) IS EQUAL TO SPACE
*          GO TO GET-OPTION-CODE.
*
*       MOVE ORIG-CHAR (ORIG-IDX) TO TAG-CHAR (TAG-IDX).
*       IF ORIG-IDX = 6
*               GO TO RELEASE-RECORD.
*
*       SET TAG-IDX DOWN BY 1.
*       GO TO GET-OPTION-CODE.
*
*
*
******************************************************************




RELEASE-RECORD.



*  TAG-CHAR (4) IS THE MONTH INDICATOR.  IT IS THIS FIELD
*  THAT MUST BE ALTERED TO INSURE A PROPER MONTH SORT FOR THE
*  OPTION CODE.
*
*     HERE, IN ORDER TO INSURE THAT THE OPTIONS COME FIRST,
*  WE CHECK FOR BLANKS IN THE OPTION FIELD OF THE TAG. IF BLANK,
*  THESE ARE NOT OPTIONS, AND WE CHANGE THE BLANKS TO HIGH-VALUES
*  TO FORCE THEM TO THE BOTTOM.

*       IF TAG-CHAR (4) IS EQUAL TO SPACE     AND
*          TAG-CHAR (5) IS EQUAL TO SPACE
*               MOVE HIGH-VALUES TO TAG-CHAR (4), TAG-CHAR (5).


        RELEASE SORT-RECORD.

        GO TO LOOP-1.

END-INPUT-PROCEDURE.  EXIT.

    
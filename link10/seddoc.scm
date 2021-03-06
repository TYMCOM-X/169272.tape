File 1)	DSK:SED.DOC[14,10,DECUS0,SED]     	created: 0746 01-May-80
File 2)	DSKA:SED.DOC[14,10,DECUS0,SED,CSM]	created: 1414 14-Jun-83

1)1	              SED: A CRT EDITOR FOR TOPS-10 AND TOPS-20
1)	            WRITTEN AND DOCUMENTED BY A Christopher Hall
1)	                             April 1980
****
2)1	              SED: A CRT editor for TOPS-10 and TOPS-20
2)	            Written and documented by A Christopher Hall
2)	                             April 1980
**************
1)2	        .R SED                  or
1)	        .R SED;FILE.EXT         or
1)	        .R SED;FILE.EXT=
1)	     The first way will set up for e diting the file  (and  alternate
****
2)2	        .SED                  or
2)	        .SED FILE.EXT         or
2)	        .SED FILE.EXT=
2)	     The first way will set up for editing the file  (and  alternate
**************
1)3	             ESCAPE A B C D = ^B
1)	one key after another (with no spaces in between).  The editor  will
****
2)3	             ENTER A B C D = ^B
2)	one key after another (with no spaces in between).  The editor  will
**************
1)3	type  DELETE-SPACES (^S).  There is a whole spectrum of commands for
1)	inserting and deleting characters and lines of text,  moving  around
****
2)3	type  DELETE-SPACES (^L).  There is a whole spectrum of commands for
2)	inserting and deleting characters and lines of text,  moving  around
**************
1)4	     The ENTER key is  the  key  that  is  labeled  "ESC"  or  "ALT"
1)	(probably.   See the appendices for terminal-dependent information).
1)	A parameter is a piece of information that is  used  by  a  command.
****
2)4	     The ENTER  key is  the  key  that  is  labeled  "ENTER"  on the
2)	numeric keypad. (See appendices for terminal-dependent information).
2)	A parameter is a piece of information that is  used  by  a  command.
**************
1)7	ROLL-BACK-PAGES - ROLL-FORWARD-PAGES            ^Q ^Y
1)	        Starting nominal: 1 page
****
2)7	ROLL-BACK-PAGES - ROLL-FORWARD-PAGES            ^A ^Y
2)	        Starting nominal: 1 page
**************
1)8	SLIDE-LEFT - SLIDE-RIGHT                        ^K ^L
1)	        Starting nominal: 8 spaces
****
2)8	SLIDE-LEFT - SLIDE-RIGHT                        "8" "9"
2)	        Starting nominal: 8 spaces
**************
1)11	INSERT-SPACES - DELETE-SPACES                   ^A ^S
1)	        Starting nominal: 1 space
****
2)11	INSERT-SPACES - DELETE-SPACES                   ^L ^K
2)	        Starting nominal: 1 space
**************
File 1)	DSK:SED.DOC[14,10,DECUS0,SED]     	created: 0746 01-May-80
File 2)	DSKA:SED.DOC[14,10,DECUS0,SED,CSM]	created: 1414 14-Jun-83

1)20	RESET                                           RUB
1)	        Starting nominal: none
****
2)20	RESET                                           "." on keypad
2)	        Starting nominal: none
**************
1)23	        .R SED;FILE.EXT/NOCASE/TABS:5
1)	or
****
2)23	        .SED FILE.EXT/NOCASE/TABS:5
2)	or
**************
1)33	                              - 32 -
****
2)33	Print DOC:VIS200.SED for a VISUAL-200 terminal.
2)	Print DOC:VT100.SED for a VT100 or other ANSI mode terminal.
2)	Print DOC:CONCEP.SED for a concept-100 terminal.
2)	                              - 32 -
**************
1)35	 10     ^A       INSERT-SPACES        INSERT SPACES TO FILE
1)	 15     ^B       SET-FILE             SET UP A FILE FOR EDITING
****
2)35	  6     ^A       ROLL-BACK-PAGES      MOVE VIEWING WINDOW BACK PAGES
2)	 15     ^B       SET-FILE             SET UP A FILE FOR EDITING
**************
1)35	  2     LEFT     CURSOR-LEFT          MOVE CURSOR LEFT
1)	 24     ^I       TAB                  MOVE TO NEXT TAB STOP
1)	 20     ^J       CLEAR-LINE           CLEAR LINE BELOW CURSOR
1)	  7     ^K       SLIDE-LEFT           SLIDE VIEWING WINDOW LEFT
1)	  7     ^L       SLIDE-RIGHT          SLIDE VIEWING WINDOW RIGHT
1)	  2     ^M       CARRIAGE-RETURN      GOOD OL' ASCII CARRIAGE RETURN
****
2)35	  2     ^H       CURSOR-LEFT          MOVE CURSOR LEFT
2)	 24     ^I       TAB                  MOVE TO NEXT TAB STOP
2)	 20     ^J       CLEAR-LINE           CLEAR LINE BELOW CURSOR
2)	 10     ^K       INSERT-SPACES        INSERT SPACES TO FILE
2)	 10     ^L       DELETE-SPACES        DELETE CHARACTERS FROM FILE
2)	  2     ^M       CARRIAGE-RETURN      GOOD OL' ASCII CARRIAGE RETURN
**************
1)35	  6     ^Q       ROLL-BACK-PAGES      MOVE VIEWING WINDOW BACK PAGES
1)	 11     ^R       SEARCH-FORWARD       SEARCH FROM CURSOR TO END
1)	 10     ^S       DELETE-SPACES        DELETE CHARACTERS FROM FILE
1)	  6     ^T       ROLL-FORWARD-LINES   MOVE VIEWING WINDOW FORWARD LINES
****
2)35	        ^Q       XON                    (used by VT100 terminals)
2)	 11     ^R       SEARCH-FORWARD       SEARCH FROM CURSOR TO END
2)	        ^S       XOFF                   (used by VT100 terminals)
2)	  6     ^T       ROLL-FORWARD-LINES   MOVE VIEWING WINDOW FORWARD LINES
**************
1)35	  3     ESCAPE   ENTER                PASS A PARAMETER TO A COMMAND
1)	 19     RUB      RESET                RESET SCREEN OR PARAMETER
1)	 24     REC      RECALL               RECALL PREVIOUS PARAMETER
1)	 14     IMD      INSERT-MODE          CHARACTER INSERT/REPLACE TOGGLE
1)	 14     DCH      DELETE-CHARACTER     ERASE CHARACTER TO LEFT OF CURSOR
1)	 25     RTB      REAL-TAB             TYPE A REAL TAB IN THE FILE
1)	 25     MRK      MARK                 MARK POSITION FOR PICK OR DELETE
File 1)	DSK:SED.DOC[14,10,DECUS0,SED]     	created: 0746 01-May-80
File 2)	DSKA:SED.DOC[14,10,DECUS0,SED,CSM]	created: 1414 14-Jun-83

1)	                              - 34 -
****
2)35	 14     RUB      DELETE-CHARACTER     ERASE CHARACTER TO LEFT OF CURSOR
2)	  3     ENTER    ENTER                PASS A PARAMETER TO A COMMAND
2)	 19     "."      RESET                RESET SCREEN OR PARAMETER
2)	 24     ","      RECALL               RECALL PREVIOUS PARAMETER
2)	 14     "-"      INSERT-MODE          CHARACTER INSERT/REPLACE TOGGLE
2)	 25     "0"      REAL-TAB             TYPE A REAL TAB IN THE FILE
2)	 25     "7"      MARK                 MARK POSITION FOR PICK OR DELETE
2)	  7     "8"      SLIDE-LEFT           SLIDE VIEWING WINDOW LEFT
2)	  7     "9"      SLIDE-RIGHT          SLIDE VIEWING WINDOW RIGHT
2)	                              - 34 -
**************
  
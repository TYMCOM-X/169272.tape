010000   .PAGE "Escape Sequences -- ESCDSP - Escape Sequence Dispatch Table"
010010 ;
010020 ; The following table dispatches escape sequences by the second character
010030 ; in the sequence:
010040 ;
010050 ESCDSP  DISP  "#",STLATR ; <ESC># - set line attributes
010060    DISP  "(",SETG0 ; <ESC>( - Select G0 character set
010070    DISP  ")",SETG1 ; <ESC>) - Select G1 character set
010080    DISP  "7",SAVCSR ; <ESC>7 - Save the cursor position
010090    DISP  "8",RSTCSR ; <ESC>8 - Restore the cursor position
010100    DISP  "=",SETAPPL ; <ESC>= - Set application keypad mode
010110    DISP  ">",SETNUM ; <ESC> > - Set numeric keypad mode
010120    DISP  "D",INDEX ; <ESC>D - Index (like <LF> when not in newline mode)
010130    DISP  "E",NXTLIN ; <ESC>E - Advance to next line
010140    DISP  "H",SETHTB ; <ESC>H - Set horizontal tab
010150    DISP  "M",REVIDX ; <ESC>M - reverse index
010160    DISP  "Z",IDENT ; <ESC>Z - Identify ourselves
010170    DISP  "[",CSI ; <ESC>[ - Control sequence introducer
010180    DISP  "c",TRMRST ; <ESC>c - Reset thyself
010190   .BYTE $FF   ; End of table
010200 ;
010210   .PAGE "Escape Sequences -- SAVCSR, RSTCSR - Save and Restore the Cursor Position"
010220 ;
010230 ;     Here to save the cursor position.  This routine is called when we
010240 ; see an <ESC>7.
010250 ;
010260 ; Calling sequence:
010270 ;
010280 ;      CURX/   current cursor X position
010290 ;      CURY/   current cursor Y position
010300 ;      JSR     SAVCSR          ; Save the cursor position
010310 ;      returns here always, cursor position saved in SAVEX and SAVEY
010320 ;
010330 ; Destroys A
010340 ;
010350 SAVCSR LDA CURX ; Get the cursor X position
010360   STA SAVEX   ; Move it
010370   LDA CURY    ; Get the cursor Y position
010380   STA SAVEY   ; Store it
010390   LDA DECOM   ; Get the origin mode setting
010400   STA SAVEOM  ; Save it
010410   LDA G0SET   ; Save
010420   STA SAVEG0  ;  the
010430   LDA G1SET   ;  character
010440   STA SAVEG1  ;  sets
010450   LDA SHIFTFL ;  the shift
010460   STA SAVESF  ;  in/out flag
010470   LDA DRAW    ;  and
010480   STA SAVEDR  ;  drawing mode
010490   RTS         ; Return
010500 ;
010510 ;     Here to restore the cursor position which was probably saved by
010520 ; the above routine.
010530 ;
010540 ; Calling sequence:
010550 ;
010560 ;      SAVEX/  saved X cursor position
010570 ;      SAVEY/  saved Y cursor position
010580 ;      JSR     RSTCSR          ; Restore the cursor position
010590 ;      returns here always, old coordinates restored to CURX and CURY
010600 ;
010610 ; Destroys A
010620 ;
010630 RSTCSR LDA SAVEX ; Get the old cursor X position
010640   STA CURX    ; Restore it
010650   LDA SAVEY   ; Get the old cursor Y position
010660   STA CURY    ; Restore it too
010670   LDA SAVEOM  ; Get the saved origin mode
010680   STA DECOM   ; Restore it
010690   LDA SAVEG0  ; Restore
010700   STA G0SET   ;  the
010710   LDA SAVEG1  ;  character
010720   STA G1SET   ;  sets
010730   LDA SAVESF  ;  the shift
010740   STA SHIFTFL ;  in/out flag
010750   LDA SAVEDR  ;  and
010760   STA DRAW    ;  drawing mode
010770   RTS         ; And return
010780 ;
010790   .PAGE "Escape Sequences -- SETAPPL, SETNUM - Set Application or Numeric Keypad Mode"
010800 ;
010810 ;     Here to set application or numeric keypad mode.
010820 ;
010830 ; Calling sequence:
010840 ;
010850 ;      JSR     SETAPPL         ; Set application keypad mode
010860 ;       or
010870 ;      JSR     SETNUM          ; Set numeric keypad mode
010880 ;      returns here always
010890 ;
010900 ; Destroys A
010910 ;
010920   .LOCAL 
010930 ;
010940 SETAPPL LDA #1 ; Say we're setting application keypad mode
010950   BNE ?10     ; Continue below
010960 ;
010970 SETNUM LDA #0 ; Say we're setting numeric keypad mode
010980 ;
010990 ?10 STA KEYPAD ; Set the mode
011000   RTS         ; And return
011010 ;
011020   .PAGE "Escape Sequences -- SETG0, SETG1 - Set G0 or G1 Character Sets"
011030 ;
011040 ;     Here to set the G0 or G1 character sets.  This routine is called
011050 ; when we see <ESC>( or <ESC>) followed by a character set specifier.
011060 ; Since this is a minimal implementation, we will just implement the US
011070 ; and drawing character sets.
011080 ;
011090 ; Calling sequence
011100 ;
011110 ;      CRSBUF+1/       character set specifier (ASCII character)
011120 ;      JSR     SETG0           ; Set the G0 character set
011130 ;        or
011140 ;      JSR     SETG1           ; Set the G1 character set
011150 ;      returns here always
011160 ;
011170 ; Destroys all registers, PTR1
011180 ;
011190   .LOCAL 
011200 ;
011210 SETG0 LDX # <G0SET ; Point to the desired
011220   LDY # >G0SET ;  character set
011230   BNE ?10     ; Continue below
011240 ;
011250 SETG1 LDX # <G1SET ; Point to the desired
011260   LDY # >G1SET ;  character set
011270 ;
011280 ?10 STX PTR1  ; Store the
011290   STY PTR1+1  ;  indirect pointer
011300   LDA CRSBUF+1 ; Get the character set specifier
011310   LDX #0      ; Assume normal character set
011320   CMP #'0     ; Is it the drawing characters?
011330   BNE ?20     ; No, go on
011340   DEX         ; Yes, force magic characters
011350 ;
011360 ?20 LDY #0    ; Make for simple indirection
011370   TXA         ; Copy the option
011380   STA (PTR1),Y ; Store it
011390   LDA SHIFTFL ; Are we shifted in?
011400   BNE ?30     ; Yes, go handle
011410   JMP SHIFTO  ; No.  Shift us out
011420 ;
011430 ?30 JMP SHIFTI ; Go shift in and return
011440 ;
011450   .PAGE "Escape Sequences -- SETHTB - Set a Horizontal Tab at the Current Cursor Position"
011460 ;
011470 ;     Here when we see <ESC>H.  This routine is called to set a horizontal
011480 ; tab at the current cursor position.
011490 ;
011500 ; Calling sequence:
011510 ;
011520 ;      CURX/   cursor position for new tab stop
011530 ;      JSR     SETHTB          ; Set the horizontal tab
011540 ;      returns here always
011550 ;
011560 ; Destroys A, X
011570 ;
011580 SETHTB LDA #INT?T ; Get the tab indicator
011590   LDX CURX    ; Get the cursor X position
011600   STA TABTAB,X ; Set the tab stop
011610   RTS         ; And return
011620 ;
011630   .PAGE "Escape Sequences -- IDENT - Identify Ourselves"
011640 ;
011650 ;     Here on receipt of $Z or $[c.  Here we return our terminal ID
011660 ; string.
011670 ;
011680 ; Calling sequence:
011690 ;
011700 ;      ARGNUM/ 0
011710 ;      JSR     IDENT           ; Identify this terminal
011720 ;      returns here always
011730 ;
011740 ; Destroys PTR1, all registers
011750 ;
011760   .LOCAL 
011770 ;
011780 IDENT LDA ARGNUM ; Non-zero argument?
011790   BNE ?90     ; Yes, punt it
011800   LDA ANSI    ; Are we an ANSI terminal?
011810   BNE ?10     ; Yes
011820   LDX # <VT52ID ; No, point
011830   LDY # >VT52ID ;  to the VT-52 ident
011840   BNE ?20     ; Continue below
011850 ;
011860 ; Here if ANSI terminal:
011870 ;
011880 ?10 LDX # <VT102ID ; Point to the
011890   LDY # >VT102ID ;  VT-102 identification string
011900 ;
011910 ?20 JMP PUTSTR ; Send the string and return
011920 ;
011930 ?90 RTS       ; Return
011940 ;
011950 VT52ID .BYTE AS?ESC,"\Z",0
011960 VT102ID .BYTE AS?ESC,"[?6c",0
011970 ;
011980   .PAGE "Escape Sequences -- REVIDX - Reverse Index"
011990 ;
012000 ;     Here to do a reverse index.  This is sort of like a reverse line
012010 ; feed.  If we're outside of the scrolling region, we just stick on the
012020 ; top of the screen.  If we're at the top of the scrolling region, we
012030 ; insert a line at the top of the region.
012040 ;
012050 ; Calling sequence:
012060 ;
012070 ;      CURX/   current cursor X position
012080 ;      CURY/   current cursor Y position
012090 ;      JSR     REVIDX          ; Do a reverse index
012100 ;      returns here always
012110 ;
012120 ; Destroys all registers, TEMPA, TEMPB, LINPTR, PTR1
012130 ;
012140   .LOCAL 
012150 ;
012160 REVIDX LDY CURY ; Get the current cursor Y position
012170   CPY TOPMAR  ; Are we at the top of the scrolling region?
012180   BNE ?10     ; No, go on
012190   JMP LININS  ; Yes, just insert a new line and return
012200 ;
012210 ; Here if not at the top of the scroll region:
012220 ;
012230 ?10 CPY #0    ; Are we already at the top of the screen?
012240   BEQ ?20     ; Yes, just stay there
012250   DEY         ; No, decrement the line number
012260   STY CURY    ; Store the new line number
012270 ;
012280 ?20 RTS       ; And return
012290 ;
012300   .PAGE "Escape Sequences -- TRMRST - Reset the Terminal Parameters"
012310 ;
012320 ;     Here to reset all terminal parameters.  This should re-read the
012330 ; options file.
012340 ;
012350 ; Calling sequence:
012360 ;
012370 ;      JSR     TRMRST          ; Reset the terminal
012380 ;      returns here when done
012390 ;
012400 ; Destroys all registers
012410 ;
012420 TRMRST JMP TERMINI ; Just re-initialize and return
012430 ;
012440   .PAGE "Escape Sequences -- Misc Unimplemented Escape Sequences"
012450 ;
012460 ; Some as yet unimplemented escape sequences:
012470 ;
012480TR = *    ; Set line attributes
012490   JMP NULL    ; Just reset the terminal state and return
012500 ;
012510   .PAGE "Escape Sequences -- CTLDSP - Control Sequence Dispatch Table"
012520 ;
012530 ; This table provides the dispatch for the final character of a control
012540 ; sequence. (Control sequences are <ESC>[mumbly<TERM>).
012550 ;
012560 CTLDSP  DISP  "A",CURUP ; Cursor up one line
012570    DISP  "B",CURDN ; Cursor down one line
012580    DISP  "C",CURFW ; Cursor forward one character
012590    DISP  "D",CURBK ; Cursor back one character
012600    DISP  "H",CURPOS ; Cursor address
012610    DISP  "J",ERSCRN ; Erase in screen
012620    DISP  "K",ERSLIN ; Erase in line
012630    DISP  "L",INSLIN ; Insert line
012640    DISP  "M",DELLIN ; Delete line
012650    DISP  "P",DELCHS ; Delete a character
012660    DISP  "c",IDENT ; Device attributes request
012670    DISP  "f",CURPOS ; Cursor address
012680    DISP  "g",CLRHTB ; Clear all horizontal tabs
012690    DISP  "h",SETPRM ; Set parameter
012700    DISP  "i",MEDCPY ; Media copy control
012710    DISP  "l",RSTPRM ; Reset parameter
012720    DISP  "m",SETATR ; Set character attributes
012730    DISP  "n",DEVSTS ; Device status/report response
012740    DISP  "q",LODLED ; Clear/load keyboard leds
012750    DISP  "r",SETMAR ; Set top and bottom margins
012760    DISP  "y",INVCON ; Invoke confidence test
012770   .BYTE $FF   ; End of table
012780 ;
012790   .PAGE "Escape Sequences -- Misc Unimplemented Control Sequences"
012800 ;
012810 ; Some as yet unimplemented control sequences:
012820 ;
012830 MEDCPY = *    ; Media copy control
012840 LODLED = *    ; Load console leds
012850 INVCON = *    ; Invoke confidence test
012860   JMP NULL    ; Just reset terminal state and return
012870 ;
012880   .PAGE "Escape Sequences -- ESCREC - Received an Escape"
012890 ;
012900 ;     Here when we receive an escape character.  This flags the start
012910 ; of an escape or control sequence.  This routine will start copying
012920 ; subsequent input into the control sequence buffer until the terminator
012930 ; is seen.
012940 ;
012950 ; Calling sequence:
012960 ;
012970 ;      JSR     ESCREC          ; Received an <ESC>
012980 ;      returns here when processing is done
012990 ;
013000 ; Modifies terminal state, destroys all registers, TEMPA, TEMPB, LINPTR,PTR1
013010 ;
013020   .LOCAL 
013030 ;
013040 ESCREC LDA # <?10 ; Get the address
013050   STA TTDISP  ;  of the routine
013060   LDA # >?10  ;  to process the
013070   STA TTDISP+1 ;  first char of the sequence
013080   LDA #0      ; Get the initial index into CRSBUF
013090   STA CRSIDX  ; Store
013100   RTS         ; And return
013110 ;
013120 ; Here on the first character of the escape sequence:
013130 ;
013140 ?10 CMP #AS?SPC ; Is this a control character?
013150   BCS ?20     ; No, go on with it
013160 ;
013170 ; Here if control character in the middle of an escape sequence.  The
013180 ; action here is undefined, but we might as well go ahead and process
013190 ; it normally.
013200 ;
013210 ?18 JMP PUTS1 ; Go do normal processing here
013220 ;
013230 ?20 LDX CRSIDX ; No, it's cool.  Get the escape buffer index
013240   STA CRSBUF,X ; Store the character in the escape buffer
013250   INC CRSIDX  ; Bump the pointer
013260   CMP #$30    ; Terminating character?
013270   BPL ?27     ; Yes, go dispatch it
013280 ;
013290 ?25 RTS       ; No, return now
013300 ;
013310 ; Here if terminating character during escape sequence:
013320 ;
013330 ?27 JSR NULL  ; Reset the default per character dispatch
013340   LDA CRSBUF  ; Get the first character
013350   LDX # <ESCDSP ; Then point to
013360   LDY # >ESCDSP ;  the dispatch table
013370   JMP DSPFNC  ; Go dispatch the function
013380 ;
013390   .PAGE "Escape Sequences -- CSI - Read a Control Sequence"
013400 ;
013410 ;     Here if we read an <ESC>[.  This is an ANSI control sequence
013420 ; introducer.  Here we will read characters into the control sequence
013430 ; buffer until we run into a terminating character (ASCII $40 thru $7E
013440 ; inclusive).
013450 ;
013460 ; Calling sequence:
013470 ;
013480 ;      JSR     CSI     ; Received a Control Sequence Introducer (CSI)
013490 ;      returns here when processing done
013500 ;
013510 ; Modifies terminal state, destroys all registers, TEMPA, TEMPB, LINPTR, PTR1, PTR2
013520 ;
013530 CSI LDA # <?30 ; Reset the
013540   STA TTDISP  ;  character
013550   LDA # >?30  ;  dispatch
013560   STA TTDISP+1 ;  pointer
013570   LDA #0      ; Reset the control sequence
013580   STA CRSIDX  ;  buffer pointer
013590   STA NOTANS  ; Assume we're not DEC private
013600   RTS         ; Return for now
013610 ;
013620 ; Come with each character in the control sequence until we get to the
013630 ; terminator character.
013640 ;
013650 ?30 CMP #AS?SPC ; Is this a control character?
013660   BCC ?18     ; Yes, do normal dispatch
013670   LDX CRSIDX  ; Get the buffer index
013680   BNE ?40     ; Not first char, go on
013690 ;
013700 ;     Here with the first character in the control sequence.  See if
013710 ; this is a question mark, which flags this as a DEC private sequence.
013720 ; Theoretically, this can happen anywhere in the sequence, but we'll
013730 ; just watch for it as the first one.  If we do see one, it won't be
013740 ; stored in the buffer.
013750 ;
013760   CMP #'?     ; Is he specifying a non-ANSI sequence?
013770   BNE ?40     ; No, go on
013780   INC NOTANS  ; Yes, say he is
013790   RTS         ; And return now
013800 ;
013810 ?40 STA CRSBUF,X ; Store the control character
013820   INC CRSIDX  ; Bump the pointer
013830   CMP #$40    ; Terminating character?
013840   BMI ?25     ; No, just return
013850   PHA         ; Yes, save the character
013860   JSR NULL    ; Reset the per character dispatch
013870   JSR GETARG  ; Go get the arguments
013880   PLA         ; And restore the terminating character
013890   LDX # <CTLDSP ; Point to the
013900   LDY # >CTLDSP ;  dispatch table
013910   JMP DSPFNC  ; Dispatch the function and return
013920 ;
013930   .PAGE "Escape Sequences -- DSPFNC - Dispatch a Control Sequence"
013940 ;
013950 ;     Here to dispatch a control or escape sequence on a given character.
013960 ; This routine will search the argument dispatch table for the character,
013970 ; and on a match, will dispatch to the corresponding handler routine.
013980 ;
013990 ; Calling sequence:
014000 ;
014010 ;      A/      character to dispatch on
014020 ;      X/      table pointer low byte
014030 ;      Y/      table pointer high byte
014040 ;      JSR     DSPFNC          ; Dispatch the function
014050 ;      returns here when complete
014060 ;
014070 ; Destroys all registers, PTR1, PTR2, TEMPA, TEMPB, LINPTR
014080 ;
014090   .LOCAL 
014100 ;
014110 DSPFNC STX PTR1 ; Store the dispatch
014120   STY PTR1+1  ;  table pointer
014130   LDY #0      ; Init the index into this table
014140 ;
014150 ; Loop here for each table entry.  See if we can find a match
014160 ;
014170 ?10 CMP (PTR1),Y ; Match?
014180   BEQ ?20     ; Yes, go dispatch
014190   BCC ?15     ; No, and we've gone too far
014200   INY         ; Still room,
014210   INY         ;  bump the
014220   INY         ;  table pointer
014230   BNE ?10     ; Try next entry
014240 ;
014250 ; Here if no match in the dispatch table
014260 ;
014270 ?15 RTS       ; Just return
014280 ;
014290 ; Here if we've got a match
014300 ;
014310 ?20 INY       ; Point to the dispatch address
014320   LDA (PTR1),Y ; Get the low order part
014330   PHA         ; Save it
014340   INY         ; Point to the high order part
014350   LDA (PTR1),Y ; Get the high order part
014360   STA PTR1+1  ; Put it in the indirect pointer
014370   PLA         ; Get the low order part back
014380   STA PTR1    ; Store in the indirect pointer
014390   JMP (PTR1)  ; And go dispatch the function
014400 ;
014410   .PAGE "Escape Sequences -- GETARG - Get Arguments from the ANSI Control Sequence"
014420 ;
014430 ;     Here when we've parsed a control sequence.  This routine is called
014440 ; to decode all numeric arguments from the sequence.
014450 ;
014460 ; Calling sequence:
014470 ;
014480 ;      CRSBUF/ control sequence
014490 ;      JSR     GETARG          ; Get the arguments
014500 ;      returns here always, returns:
014510 ;
014520 ;      CRSIDX,X/       First unparsable character pointer
014530 ;      ARGNUM/ First argument number
014540 ;      ARGS/   all argument numbers
014550 ;      ARGCNT/ number of arguments read
014560 ;
014570 ; Destroys all registers, above storage
014580 ;
014590   .LOCAL 
014600 ;
014610 GETARG LDX #0 ; Get the initial buffer index
014620   STX ARGCNT  ; And initialize the argument count
014630   STX ARGS    ;   and the first argument
014640 ;
014650 ; Loop here for each parameter we find.  Convert the number and copy to the
014660 ; argument buffer.
014670 ;
014680 ?10 INC ARGCNT ; If we got here, then we've got an argument coming
014690   JSR GETNUM  ; So go get this argument
014700   LDA ARGNUM  ; Get what we read
014710   LDY ARGCNT  ; Get the current argument number
014720   STA ARGS-1,Y ; Store the current argument in the block
014730   CPY #ARGMAX ; Have we done enough yet?
014740   BCS ?20     ; Yes, exit the loop
014750   LDA CRSBUF,X ; No, get the terminating character
014760   CMP #';     ; Is it a valid argument separator?
014770   BNE ?20     ; No, exit the loop
014780   INX         ; Yes, bump past the separator
014790   BNE ?10     ; Then, do the next argument
014800 ;
014810 ; Here when we're done looking at the arguments.  Copy the first one
014820 ; to a more convenient place and return
014830 ;
014840 ?20 LDA ARGS  ; Copy the
014850   STA ARGNUM  ;  first argument
014860   RTS         ; And return
014870 ;
014880 ; End of escape sequence handler
014890 ;
    @n“
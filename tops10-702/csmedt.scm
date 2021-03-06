SUBTTL	CSM Feature-Test definitions

	SALL

;Changes to the monitor build process (00)
	CSM00$==-1	;Changes to MONGEN, assemble CSMEDT.MAC+S.CSM
;Changes to support our hardware (01-09)
    ;CSM01$ removed, Plotter is now connected to a TTY line via PTC-6.
	CSM02$==-1	;LPT changes on 2020 - LP11 controller
	CSM03$==+1	;TTY changes - LDB and SMART/MUX (Number of PDP-8 CPUs)
	CSM04$==-1	;Make the DCA look like a network
    ;CSM05$ removed, never finished implementing shared disks
	CSM06$==-1	;Raise and lower DTR on non-dataset lines
;Changes to Monitor-Level commands (10-29)
	CSM10$==-1	;Check for ambiguous versus unknown commands
	CSM11$==-1	;Improve the PJOB and DAYTIME commands
	CSM12$==-1	;Include PPN and time in SEND messages.
	CSM13$==-1	;Add erase-to-end-of-line text for other terminals
	CSM14$==-1	;Allow PF keys at monitor level.
	CSM15$==-1	;Make BYE the same as KJOB
    ;CSM16$ removed, could not output entire command table.
	CSM17$==-1	;Implement ".SET COMMAND SYS"
	CSM18$==-1	;VERSION command, EXE files
;Changes to UUOs (30-39)
	CSM30$==-1	;Add STSPL., USRLG., and USRNM. UUOs
	CSM31$==-1	;Plotter UUO changes, *.PLT in UFD, not [3,3]
;Other changes (40-49)
	CSM40$==-1	;Have MONBTS type the contents of location 30.


;Temporary changes for Field Test (50-59)
			;None
;End of Feature-Test settings




;[The file CSMEDT.SCM consists of only the first page of CSMEDT.CSM]
  
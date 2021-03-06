IN ORDER TO LOAD THE BOOTSTRAPS SO THAT THE MONITOR CAN BE RESTORED
FROM DISK, I.E. WHEN FOR SOME REASON THIS ISN'T DOSEN'T AUTOMATICALLY,
THE FOLLOWING STEPS SHOULD BE FOLLOWED:

1. Make sure power is on for the 2020, the tape drive, and the disk
units.

2. Mount the correct tape. If you are not loading another monitor,
then you should only have to mount a tape that contains the
bootstraps. If this is not available, however, then mount the
Installation tape.

3. Set the tape drive to "ONLINE".

4. On the cty type <ctrl C>. The cty will respond with "KS10>".

5. Type <ctrl \>. The cty will respond with:
	ENABLED

6. The cty prompts and the correct user responses are as follows:
	cty prompt:	oper response:		action taken:
	KS10>		ZM<ret>			Zero Memory

	KS10>		MS<ret>			Read from magtape to 
						bootstrap the system

	>>UBA?		3<ret>			Informs the system
						which Unibus Adaptor
						the tape is on

	>>RHBASE?	772440<ret>		Informs the system of
						the RH11 base address

	>>TCU?		0<ret>			Specifies the tape
						control unit being used

	>>DENS?		1600<ret>		Specifies tape density

	>>SLV?		0<ret>			Specifies slave tape
						unit

	KS10>		MT<ret>			Initiate bootstrap
						procedure

	KS10>USR MOD
	MTBOOT>

7. At this point, if a monitor already exists on disk, i.e., you do
not wish to install a new monitor version, then the following steps
should be taken. However, if you wish to install a new monitor then
follow the steps beginning at "Step 36:" of the T20 Systems Manager's
Guide".
	cty prompt:	oper response:		action taken:
	MTBOOT>		/L<ret>			Load the microcode

	MTBOOT>		Toggle the "BOOTS"	Restores the monitor
			switch on the front	from disk into memory
			pannel.

	MTBOOT>BT SW
	[PS MOUNTED]
	%%NO SETSPD
	System restarting, wait...

	ENTER CURRENT DATE AND TIME:	03/01/83 10:13	Give the day
						and time

	YOU HAVE ENTERED TUESDAY, 1-MARCH-1983 10:13AM,

	IS THIS CORRECT (Y,N)	y<ret>		Verify that you entered
						the correct day and
						time

	WHY RELOAD?	Power failure<ret>	Whatever text is typed
						into the system error
						file

	RUN CHECKD?	yes<ret>		Checks file consistency
	    .
	    .
	    .

8. The system should now print sytem summary statistics and end with
the sytem being brought up online.



	
	

   
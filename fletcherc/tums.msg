From: Osman Guven <osman@X930.Tymnet> 
Date: Mon, 22 Jun 87 15:10:28 PDT 
To: fletcherc 
Subject: Tymnet Training .. 

I have taken:

o  TTE 102  --  Tymnet Network Operation
o  TTE 330  --  Tymnet Engine Maintenance

-Osman-
From: Osman Guven <osman@X930.Tymnet> 
Date: Mon, 22 Jun 87 15:40:00 PDT 
To: Monitor Group <Osman@X930.Tymnet>, Carl A Baltrunas <carl@X930.Tymnet>, Joe
	Smith <jms@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey <dencoff@X930.Tymnet>
	
Subject: Base crashes & FTACFC STOPCD .. 

                             M E M O R A N D U M


                                                      TYMCOM-X SUPPORT



   DATE:  22 June, 1987

     TO:  Rick Daniels

   FROM:  Osman Guven

SUBJECT:  Base crashes and FTACFC STOPCD crashes on /B07

--------------------------------------------------------------------

o  Base crashes occurs at both Data Centers PDP10's.  Frequency of the
   crashes is about the same.  One of the enhancement we have in the
   que about TYMCOM-X and EBUS slot code is to eliminate some of these
   type of crashes: TTYBMT, TTYBPN, CNTPRT, ZAPBUG, BASE etc.

o  Yes, Joe is looking into FTACFC STOPCD crashes.

-Osman-
From: Joe Smith <JMS@X930> 
Date: Mon, 22 Jun 87 15:41:29 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: Created /B08 instead of /B07-1. 

As per discussion (with JMS, CARL, OSMAN, DENCOFF present), the fix system
38's FTACFC crash will not be distributed as a DDT patch.  Instead, /B08
will replace all copies of nnXB07.SAV.

The crash on F38 showed FTA3 was given a command, FTA1 interrupted while
waiting for FTA3 to finish so FTA1 was given a new command, then the unit
check on FTA3 was noticed.  Due to what appears to be a minor glitch in the
SA10 microcode, the pointer stored at memory location 300+2 implied FTA1
when the unit-check was reported for FTA3 at location 300+1.  This
inconsistancy caused the FTACFC stopcode, which is the same as KAF with
CH1's PC indicating a loop at PI channel 3 at SGPREV in FTASER.  The patch
is to set T4 to a reasonable value and return instead of getting stuck in
a very slow loop searching 256K for the bogus pointer.

File 1)	DSK:FTASER.B07	created: 1859 02-JAN-87
File 2)	DSK:FTASER.MAC	created: 1516 22-JUN-87
1)46		MOVEI	T2,UNICMD+1(T3)	;ADDR OF 1ST READ CMD.
1)		CAIGE	T1,(T2)		;T1 should point past this addr
1)		 STOPCD	(.,JOB,FTACFC,,<FTA error - Cannot Find Command>)
1)	SGPRV2:	SKIPN	(T2)		;SKIP 0
****
2)46					;T1 has pointer from RH of location 302
2)		MOVEI	T2,UNICMD+1(T3)	;Skip set-density, get addr of read cmd
2)		MOVE	T4,T2		;Use top of command list if FTACFC
2)		CAIL	T1,UNICMD(T3)	;Does it point before the command list
2)		CAILE	T1,UNIDON(T3)	; or after the end of the command list?
2)		 STOPCD	(CPOPJ,INFO,FTACFC,,<FTA error - Cannot Find Command>)
2)	SGPRV2:	SKIPN	(T2)		;SKIP 0
**************
1)52	SNEW:	HRRZ	T1,1(U)		;SET UP T4 FOR THE CMD
1)		PUSHJ	P,SGPREV	;GENERATORS TO TIC TO.
****
2)52	IF2,<PRINTX [Should use BMX pointer if async error status]>
2)	SNEW:	HRRZ	T1,1(U)		;SET UP T4 FOR THE CMD
2)	;22-Jun-87 crash dump on F38 shows that SA10 may leave garbage at 1(U)
2)		PUSHJ	P,SGPREV	;GENERATORS TO TIC TO.
**************			/JMS
Received: from F29.Tymnet by X930.Tymnet; Mon, 22 Jun 87 17:31:23 PDT
Received: from EMSTXS.Ontyme.Tymnet by F29.Tymnet; Mon, 22 Jun 87 17:23:30 PDT
Return-path: <TXS.D/COFFEY@EMSTXS.Ontyme.Tymnet> 
From: TXS.D/COFFEY@EMSTXS.Ontyme.Tymnet 
Date: 22 JUN 87 17:10:36 
To: TXS.C/FLETCHER@EMSTXS.Ontyme.Tymnet 
Cc: HRD.TRNG@Ontyme.Tymnet, TXS.C/FLETCHER@Ontyme.Tymnet 
Message-id: A73724@Ontyme.Tymnet 
Subject: "COURSE REGISTRATION FORM Your"... 

                COURSE REGISTRATION FORM

Your Last Name                   :coffey
Full First Name                  :dennis
Preferred First Name for Nametag :dennis
MDC Employee Number              :08431
Department Number (cost code)    :90842
Business Unit                    :field service co.
Division Name (please spell out) :technical operations
Department Name(please spell out):product support
Work Street Address              :39100 liberty street
Bldg.#, Suite #, or Mail Stop    :
City, State, Zip                 :fremont, ca, 94538
Work Telephone (including AC)    :415/794-2588
Your ONTYME ID                   :txs.d/coffey

Your Current Job Title                 :software specialist
Effective Date This Position           :9/86
Original Hire Date                     :11/10/80
Number of Direct Reports (Subordinates):0
Organization Level (1, 3, 5, 6, 8, 9)  :3

Your Manager's Last Name        :fletcher
Your Manager's First Name       :craig
Mgr's. Work Street Address      :39100 liberty street
Bldg.#, Suite #, or Mail Stop   :
City, State, Zip                :fremont, ca, 94538
Manager's Telephone (incl AC)   :415/794-2403
Your Manager's ONTYME ID        :txs.c/fletcher

OTHER PERSON WHO SHOULD BE NOTIFIED OF YOUR REGISTRATION STATUS
Last Name                :
First Name               :
Work Telephone (incl AC) :
ONTYME ID                :

Course Title                    :time management
Preferred Date/Location         :nov. 9-10 (or sooner) /san jose
2nd choice Date/Location        :soonest/san jose

Do you have any additional comments?
Want class sooner than nov., if possible.
stop
txs.c/fletcher
From: Joe Smith <JMS@X930> 
Date: Mon, 22 Jun 87 17:42:40 PDT 
To: FLETCHERC@X930.Tymnet 
Subject: Re: "Please tell me what Tymnet related"... 
In-reply-to: your message of Mon, 22 Jun 87 11:37:46 PDT

28-Feb-86 TTE502 Tyment Network Operations (private net)
 7-Mar-86 TTE400 Introduction to ISIS Software
 4-Apr-86 TTE235 Async CONSAT/TYMCOM and Public Outdial

I would like to take TTE430 (Assembly Language Programming) and TTE440
(TYMNET Engine Programming) which are scheduled for July 20 and July 27.
From: Osman Guven <osman@X930.Tymnet> 
Date: Tue, 23 Jun 87 9:56:41 PDT 
To: Fletcherc 
Subject: VAX 8000 .. 

Craig ..

Yes, we do have some information available on VAX 8000 in the
"Microfiche Tank". Here is a list:

o  All of Hardware Manuals

o   Diagnostics ..

    EBDNA -- Ver  1.0 -- KA820 Serial Line Unit Function Test
    EBKAX -- Ver  1.5 -- CPU Cluster Exerciser
    EBKMP -- Ver  1.0 -- Multi-Processor Test
    EBSAA -- Ver 10.4 -- Diagnostic Supervisor
    EBUCA -- Ver  2.2 -- EEPROM Config Util
    ED0AA -- Ver  9.8 -- Consule
    EDCLA -- Ver  1.0 -- SBI Exerciser
    EDK5A -- Ver  8.0 -- Array Microdiagnostic
    EDKAA -- Ver  9.5 -- CPU Kernel Exerciser
    EDKCA -- Ver  5.0 -- MBOX Test #1
    EDKHA -- Ver  7.0 -- MBOX Diag #6
    EDKIA -- Ver  1.1 -- MBOX Diag #7
    EDSAA -- Ver 10.4 -- Diagnostic Supervisor

-Osman-
From: Osman Guven <osman@X930.Tymnet> 
Date: Tue, 23 Jun 87 11:08:20 PDT 
To: Monitor Group <Osman@X930.Tymnet>, Carl A Baltrunas <carl@X930.Tymnet>, Joe
	Smith <jms@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey <dencoff@X930.Tymnet>
	
Subject: Information .. 

o  /B08 Didn't get to F29 & F33, I finished the copy.

o  Last night, F29 had some KAF crashes while restoring accouting 
   tapes from Ontyme machines just like F28 was a few months ago.  
   Asked Rick to come up with /B08 and use the same Ontyme accounting
   tape which was crashing the system to see if the fix in /B08 will
   take care  of the problem.  He will schedule the system to try it
   today or tomorow.

-Osman-
From: Joe Smith <JMS@X930> 
Date: Tue, 23 Jun 87 11:15:06 PDT 
To: Rick Daniels <OPERA.SUP@EMSTXS.Ontyme> 
Cc: Monitor Group <JMS>, Carl, Osman, FletcherC, DenCoff 
Subject: Summary of recent monitor changes. 

P035/B04 includes the ability to run with AR/ARX parity trap enabled.
         It runs on systems with 365x disks.

P035/B06 fixes the problem of bogus "search errors" on systems with 3675 disks.

P035/B07 would normally be called P035/B06-1.  It fixes the problem of THUNGs
	 on systems with 3 strings on a single 3674 and on 3652 disks.

P035/B08 would normally be called P035/B06-2.  It allows the system to continue
	 after an FTACFC stopcode, which occurs only when unrecoverable read or
	 write errors occur on one FTA while a second FTA is doing I/O.

With the possible exception of system 39, we want to be running /B08 on all
systems in the Fremont Data Center.

			/Joe Smith
Received: from F29.Tymnet by X930.Tymnet; Tue, 16 Jun 87 10:19:03 PDT
Received: from EMSTXS.Ontyme.Tymnet by F29.Tymnet; Tue, 16 Jun 87 9:29:46 PDT
From: NETS.TTE@EMSTXS.Ontyme.Tymnet 
Date: 16 JUN 87 16:49:30 
To: TXS.SUP@EMSTXS.Ontyme.Tymnet 
Message-id: I47474@Ontyme.Tymnet 
Subject: TTE Schedule Update 
Resent-from: Joe Smith <JMS@X930> 
Resent-date: Tue, 23 Jun 87 11:31:39 PDT 
Resent-to: fletcherc 
TTEScheduleUpdate: 

                            M E M O R A N D U M

                          NETWORK SYSTEMS COMPANY
                         NETWORK SYSTEMS MARKETING


DATE>      16 JUN 87  08:47

TO>        All Employees

COPIES>    

FROM>      Tymnet Training and Education


SUBJECT>   TTE Schedule Upd

-----------------------------------------------------------------------


TTE has add the following classes to the schedule-

     TTE 100 Basic Data Communication            June 17-19
     TTE 502 TYMNET Concepts                     July 8-17
     TTE 430 Assembly Language Programming       July 20-24
     TTE 440 TYMNET Engine Programming           July 27-31
     TTE 442 ISIS Slot Programming and Debugg.   September 14-25
     TTE 210 IBM Data Comm and Intro to SNA      October 12-16
     TTE 230 TYMNET 3270/CMT                     October 19-23
     TTE 240 TYMNET SNA                          October 26-30

To enroll for any TTE course through OnTyme access               
  :EXEC *** TTE.ENROLL
From: Osman Guven <osman@X930.Tymnet> 
Date: Tue, 23 Jun 87 12:40:52 PDT 
To: Monitor Group <Osman@X930.Tymnet>, Carl A Baltrunas <carl@X930.Tymnet>, Joe
	Smith <jms@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey <dencoff@X930.Tymnet>
	
Subject: Group Meeting .. 

Craig and I will be going to a meeting at Fremont D. C. 
tomorrow (6/24 at 10:30).  Our group meeting is rescheduled 
from 10:00 am to 1:00 pm.

-Osman-
From: Osman Guven <osman@X930.Tymnet> 
Date: Tue, 23 Jun 87 14:21:27 PDT 
To: Monitor Group <Osman@X930.Tymnet>, Carl A Baltrunas <carl@X930.Tymnet>, Joe
	Smith <jms@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey <dencoff@X930.Tymnet>
	
Subject: This afternoon .. 

I am going to BLDG C to test the KL Diagnostic Pakc.

-Osman-
From: Carl A Baltrunas <Carl@X930.Tymnet> 
Date: Tue, 23 Jun 87 20:43:14 PDT 
To: Monitor Group <CARL@X930>, Osman Guven <Osman@X930.Tymnet>, Joe Smith
	<JMS@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Jon Mosser <MosserJ@X930.Tymnet>,
	Dennis Coffey <dencoff@X930.Tymnet>, William R Soley <WRS@B39.Tymnet>,
	Wayne D Bartlett <BARTLETW@B39.Tymnet>, Baigent, Landa Morris
	<IPC.L/Morris@Ontyme.Tymnet>, Ed Roop <IPC.E/Roop@Ontyme.Tymnet>,
	Ingrid Lopes <IPC.I/Lopes@ontyme.tymnet>, Jan Krivanec
	<IPC.J/Krivanec@Ontyme.Tymnet>, Rick Daniels
	<IPC.R/Daniels@ontyme.tymnet> 
Subject: New SETOP requirements 

In preparation for building a test database on system X930 for the new
SETOP program I am asking each of you to send me mail containing all of
the following information:

   1. Your Name
   2. Your ISG identification number
      (This is NOT necessarily your employee number if you are part of
       MDFSCO or MDCSC.  It is the 6-digit number on your ISG badge,
       such as 212344, most probably not 008834 with leading zeros.)
   3. Your current OPER name
   4. Your current telephone number and mail stop
   5. Your TUMS or ONTYME name (or both) for security mail
   6. Your Username (or list of usernames, if you use more than one)
   7. Your opername manager (who gave you license)
   8. Your immediate supervisor's name, phone number and department
   9. Your current license

  10. Why do you need whatever licenses you have.  Please be specific on
      each and every license listed in item 9.  If you do not know why you
      have a particular license, please say so.  If you have a particular
      need for more license than you have, please say so, and why.

      If you are a manager and require license only because one of your
      subordinates requires the license to do their job, please say so
      and specify the above information for each of your subordinates so
      they may be entered into the database.

Thank you all.
From: Joe Smith <JMS@X930> 
Date: Wed, 24 Jun 87 0:48:28 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: Maximum jobs versus disks. 

Our current monitor configuration can handle only 32 jobs when 64 disks 
(8 strings) are defined.  Lowering the number of disks to 48 allows 80 jobs,
and with 32 disks 128 jobs can be handled.

These limits are based on the restriction currently in ONCE that the entire
monitor (including the symbol table) fit in 112K of unpaged core.

/Joe
From: Osman Guven <osman@X930.Tymnet> 
Date: Wed, 24 Jun 87 8:30:11 PDT 
To: Monitor Group <Osman@X930.Tymnet>, Carl A Baltrunas <carl@X930.Tymnet>, Joe
	Smith <jms@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey <dencoff@X930.Tymnet>
	
Subject: /B08 Testing of KAF .. 

---------------------------------------------------------------------

Message 218 (964 chars): New Read
Received: from F74.Tymnet by X930.Tymnet; Wed, 24 Jun 87 4:54:42 PDT
Return-path: <DANIELSR@F74.Tymnet> 
From: DANIELSR@F74.Tymnet 
Date: Wed, 24 Jun 87 4:48:36 PDT 
To: osman, danielsr 
Subject: "Brought F29 up on NEWMON manually"... 

Brought F29 up on NEWMON (P035/B08) manually to rerun HS2287 ONTYME
accounting tape.  This was done to see if the system would cacrash with the same STOPCODE that occurred on 22 Jun.

After bringing the system up, I mounted this tape of FTA2
and started the restore.  I also mounted a tape on FTA1 and started
storing the directory of UTIL to it.

The accounting tape stopped after "Creating User Information" typed
out (same place as before).  The TITO tape stopped shortly after this.
Approximately one minute later, F29 went down with same "KAK" stopcode.

(That's KAF, not KAK)

I then dismounted the tapes and brought the  system up.  I have the
hardcopy if additional information is needed.

Rick


---------------------------------------------------------------------

Thanks Rick.  This is very valuable information.  Please save the tape
that causes the crash.  We will be talking about this in our group meeting
this afternoon and come up with another patch/fix to the monitor to
fix the problem.

-Osman-
From: Osman Guven <osman@X930.Tymnet> 
Date: Wed, 24 Jun 87 16:49:31 PDT 
To: Rick Daniels <opera.sup@emstxs.ontyme.tymnet>, Monitor Group
	<Osman@X930.Tymnet>, Carl A Baltrunas <carl@X930.Tymnet>, Joe Smith
	<jms@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey <dencoff@X930.Tymnet>
	
Subject: /B08 Monitor .. 

Rick ..

o  (SYS)NEWMON.SAV on all of the PDP10's except B39 is a P035/B08 monitor.
   Please bring all the systems up with it next time they come up.  Some
   of them already running with /B08 monitor, this is to make all of them
   run with the same monitor.

o  B39, please continue to run it with P034/P-16 monitor untill we find
   out why it wouldn't run the /B06 monitor.

o  FTACFC STOPCD, we are looking into it, will let you know when we come
   up with a solution.

-Osman-
From: Joe Smith <JMS@X930> 
Date: Wed, 24 Jun 87 22:12:51 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: License disappears (sometimes) on RENAME. 

After reading Carl's message I did some testing.  I GFDed to SPL, and then,
without setting license, I tried ".RENAME COPY.S=COPY.SAV".  The file COPY.SAV
had JL and RF license before and after.  (And still after renaming back to
COPY.SAV.)  Then I tried ".RENAME (JMS)COPY.SAV=(SPL)COPY.SAV".  The license
disappeared when the file changed directories!  After reinstating JL and RF,
I tried renaming it the other direction, from my logged in directory to the
GFDed directory.  License went away.  One last test was to reset everything
and set WF only on my frame and then try renaming across directories.  This
time RF survived (since it is implied by WF) but JL did not.

Until today I did not know that license got left behind on a RENAME.  It is
not what I expected.  However the preservation of license when doing
 "RENAME (SYS)PROGRAM.OLD=(SYS)PROGRAM.SAV" is a feature worth preserving.
/Joe
From: Joe Smith <JMS@X930> 
Date: Fri, 26 Jun 87 1:14:04 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: 8 of 10 crashes on 33 are SAXINX 

Most of F33's crashes are KAF stopcodes, but the crash dumps show that a
SAXINX info stopcode had just occurred and the info hadn't gotten a chance to
type out on the CTY.  One crash implied that the SA10 stopped working the
time it was determined that the SA10 caused the interrupt and the time the
status was read to determine which channel caused the interrupt.  The
changes to COMMOD in /B09 will get more information and try to continue.
Note: This does not affect F29's problem with reading ONTYME accounting.
That problem is still under investigation.     /Joe
From: Joe Smith <JMS@X930> 
Date: Fri, 26 Jun 87 11:57:03 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: No meeting. 

The 1pm Friday meeting has been canceled due to insufficient data.
I believe /B09 will help F33's KAF stopcodes due to heavy FTA usage.
However F29's KAF stopcodes from the ONTYME accounting is a different problem,
and needs further study.  I will send another message later today.  /Joe
From: Joe Smith <JMS@X930> 
Date: Fri, 26 Jun 87 17:13:33 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: Found loop in FTASER. 

FTASER has several phases of "DC-R" recovery (DataCheck-Read).  Phase 1 is to
re-read the record forwards.  Phase 2 is to read the record backwards.  Phase 3
is to continue reading backwards if phase 2 worked but did not read the entire
record.  The calculation to determine where to resume reading misinterpreted
the command list and got into an infinite loop (causing KAF).  The check for
getting out of the loop failed if the current command list did not start at
the beginning of the area reserved for command lists.  The fix was to stop at
a zero word as well.  
File 1)	DSK:FTASER.B09	created: 1516 22-JUN-87
File 2)	DSK:FTASER.MAC	created: 1524 26-JUN-87

1)47		SOJA	T1,SDMPC2	;SEE IF CONTINUE.
****
2)47		SKIPE	-1(T1)		;Done if no previous command
2)		SOJA	T1,SDMPC2	;SEE IF CONTINUE.
**************

The system does not hang anymore.  However, the OSIRUS RESTORE program tries
to re-read the same record over and over again.  But that's its problem (or
possibly a misfeature in FOROTS).  P035/B10 will be put on F29 tonight, and
eventually all other systems in Fremont.    /Joe
From: Carl A Baltrunas <Carl@X930.Tymnet> 
Date: Fri, 26 Jun 87 18:40:45 PDT 
To: Monitor Group <CARL@X930>, Osman Guven <Osman@X930.Tymnet>, Joe Smith
	<JMS@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey
	<dencoff@X930.Tymnet>, Rick Daniels <IPC.R/Daniels@Ontyme.Tymnet> 
Subject: Hotline (type) call 

System F30 was experiencing a rise in hard device errors on BPA6.  They
took the system down to do a PAKCOP of the pack (3675's) and saw the same
hardware check problem we had with system 38 two weeks ago.

Rick called and wanted to know if it was OK to use Joe's modified PAKCOP.
I said, go... and we realized that that version was for 3650's in blocks.
We decided to run ASP version 7 to copy out the pack to tape and then do
a restore to a new pack.

We did a compare of the save prior to the restore and found 78(*) pages that
did not copy exactly.  Nothing was done to see how "off" the pages were.
We restored the tapes to a new drive/pack and I created a file with 78 pages
in it for DSKCLN to find multiply used pages and mark the files bad.

System came up with a FULL DSKCLN and reported errors as expected in RECOV.SYS
and on the console.  One UFD was affected.  Operations has the list of files
from FNDBAD to restore and the UFD name to work through the all-files and
backups.

I told them to call us if they had any more problems.

We received a verbal "thanks" from both Bob Fischer and Cheryl Eldred for
saving them a rebuild.

/Carl
From: Dennis Coffey (Tymcom-X Systems) <DenCoff@X930> 
Date: Sun, 28 Jun 87 18:18:58 PDT 
To: (Monitor Group:), Carl, Osman, Joe <JMS> 
Cc: Craig <FletcherC>, TXSSup 
Subject: Jury duty. 

The jury summons I received 3 weeks ago told me to call this weekend, to learn
if/when I have to report for actual jury duty.  My number, 51, is like such a
number was for the draft lottery:  an early choice.

I have to report to the San Jose Facility, Juror Assembly Annex, at 9:30 am,
Monday, June 26.  I'll let you know as soon as I know more about my schedule.

I hope I don't get a murder trial, like Bruce Ring did!

-D.-
Received: from F74.Tymnet by X930.Tymnet; Mon, 29 Jun 87 15:00:51 PDT
Return-path: <osman@X930.Tymnet> 
From: Osman Guven <osman@X930.Tymnet> 
Date: Mon, 29 Jun 87 14:59:39 PDT 
To: Rick Daniels <opera.sup@emstxs.ontyme.tymnet>, Monitor Group
	<Osman@X930.Tymnet>, Carl A Baltrunas <carl@X930.Tymnet>, Joe Smith
	<jms@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey <dencoff@X930.Tymnet>
	
Subject: /B10 Monitor .. 

Rick..

(SYS)NEWMON.SAV on all Fremont D. C. systems are P035/B10 monitor.
Please bring the systems up with it next time they come up.  It has
a fix so that the system won't crash (KAF) when OSIRUS RESTORE is
reading ONTYME accounting tapes.  Thank You.

-Osman-
From: Joe Smith <JMS@X930> 
Date: Mon, 29 Jun 87 21:34:19 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: TUMS distribution not complete. 

System 58 users were complaining that the MAIL command produced "Address Check
for device DSK, UUO at user PC 150".  (MAIL:58)RDMAIL.SAV was corrupted - the
GET command bombed out.  After copying over a new version, the following
discrepencies were noticed:

(MAIL:35)MAILER.SAV wrong protection.
(MAIL:58)MAILER.SAV wrong checksum
(MAIL:58)SENDMA.SAV wrong checksum
(MAIL:58)RDMAIL.SAV was causing "ADDRESS CHECK", I telecopied from 29
(MAIL:62)MAILER.SAV wrong protection, no license
(MAIL:62)RDMAIL.SAV no license

On some systems (XEXEC)*.DOC is protected ALL RD NO instead of ALL RD RD.
From: Joe Smith <JMS@X930> 
Date: Tue, 30 Jun 87 1:17:40 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: Ignore message about TUMS distribution. 

Sorry, wrong address.
From: Dennis Coffey (Tymcom-X Systems) <DenCoff@X930> 
Date: Tue, 30 Jun 87 8:33:17 PDT 
To: Carl, Osman, Joe <JMS> 
Cc: Craig <FletcherC>, TXSSup 
Subject: My jury duty. 

Today will be jury selection by judge and lawyers.  I should know today if I'm
on a jury.  Hope to see you this afternoon.

-D.-
From: Joe Smith <JMS@X930> 
Date: Tue, 30 Jun 87 14:13:52 PDT 
To: CARL, WRS 
Cc: Monitor Group <JMS>, Carl, Osman, FletcherC, DenCoff 
Subject: SETOP should clear input buffer if no DRWSPR.EPO file. 

There is a very small window between the time that PJ copies the new oper
password file to SYS and the time that it sets WC license on it.  If an MHX
job just happens to try to use "O$" during that time, SETOP complains that
there is "NO PASSWORD FILE" and exits without clearing the input buffer.
When this happenned to me today, my oper password showed up on the command
line where anyone looking over my shoulder could see.  Because of MEXEC, it
tried to run a program matching the first word of my oper password.  This
word was then made available to SYSTAT for the world to see.

This is not good.
Received: from B39.Tymnet by X930.Tymnet; Tue, 30 Jun 87 17:07:30 PDT
Return-path: <WRS@B39.Tymnet> 
From: William R. Soley <WRS@B39.Tymnet> 
Date: Tue, 30 Jun 87 16:58:18 PDT 
To: Joe Smith <JMS@X930> 
Cc: CARL, Monitor Group <JMS>, Carl, Osman, FletcherC, DenCoff 
Subject: Re: SETOP should clear input buffer if no DRWSPR.EPO file. 
In-reply-to: your message of Tue, 30 Jun 87 14:13:52 PDT

Of course PJ should be fixed to specify the license in the enter rather
than doing a rename after the fact.  Aside from that, OPER should also
always take a password, regardless of weather there is an oper password
file or if its bad or if the name specified does not exist.  This is the
same strategy we'll be releasing in the network as soon as we get a round
tuit.  [it also makes guessing harder]  -Bill
From: Joe Smith <JMS@X930> 
Date: Wed, 1 Jul 87 18:51:32 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: Memo to Ed Roop about 32 disks. 

The following is in (M33)32DISK.MEM.  Whoever is going to the meeting in 
Solar Way at 13:00 on 7/02/87 can give copies to Roop, Fischer, etc.
			/Joe

--------------------------------------------------------------------------

From the TYMCOM-X Support Group.
In reference to memo from Ed Roop dated June 4, 1987.

We are currently running a monitor with 32 disk addresses defined.  F74
has 29 active spindles disks, F38 had 28 active disks before it was
converted.  Running with 32 units of model 3675 disks is not a problem.

We have run a test monitor configured for a 3652 system with 32 addresses
and a test monitor configured for a 3652 system with 64 addresses.
Although only 1 string of 3652 disks was connected at the time, we see no
problems with using a second string of 3652 disks due to the uniformity
of disk addressing.  All 32 addresses go through the same 3674 controller.

Due to the current limitation on the size of the resident monitor, a
system can be configured for more than 32 addresses only at the expense
of the number of jobs the system can handle.

        A monitor with 32 disks can be defined with 128 jobs.
        A monitor with 48 disks can be defined with  80 jobs.
        A monitor with 64 disks can be defined with  32 jobs.

Note that each additional string of 3652 disks (with 16 addresses)
reduces the maximum number of jobs by 48.  There is an absolute maximum
of 64 units per structure.  Defining the DSKB structure with more than
32 units is not recommended.  Recovering from an HDA failure on a 48 unit
DSKB would take more than 48 hours of down-time.

Unless the sytems were to use multiple structures, we cannot recommend
attaching more than 32 disk units per CPU.
From: Carl A Baltrunas <Carl@X930.Tymnet> 
Date: Wed, 1 Jul 87 23:59:07 PDT 
To: Monitor Group <CARL@X930>, Osman Guven <Osman@X930.Tymnet>, Joe Smith
	<JMS@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey <dencoff@X930.Tymnet>
	
Subject: Host numbers!!! 

We (finally) received the host numbers we ordered back in May.  We ordered
four 2-digit host numbers for PDP-10 development use.  We received...

    14, 14, 16 and 17 for our use

We also received, in late May, four 4-digit host numbers for our use.
(I don't have these handy, but will save them away for later).

With these 8 numbers, and the ones we already have, we should be able
to configure our micronet with printer devices accessible from the real
network.

/Carl
From: Osman Guven <osman@X930.Tymnet> 
Date: Fri, 3 Jul 87 20:24:26 PDT 
To: Monitor Group <Osman@X930.Tymnet>, Carl A Baltrunas <carl@X930.Tymnet>, Joe
	Smith <jms@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey <dencoff@X930.Tymnet>
	
Subject: X930 All-Files Complete. 

Used set 'E', took 11 tapes.
Received: from B39.Tymnet by X930.Tymnet; Tue, 23 Jun 87 2:56:50 PDT
From: William R. Soley <WRS@B39.Tymnet> 
Date: Tue, 23 Jun 87 2:54:37 PDT 
To: Carl A Baltrunas <Carl@X930.Tymnet> 
Subject: Re: Modems 
Resent-from: Carl A Baltrunas <Carl@X930.Tymnet> 
Resent-date: Tue, 7 Jul 87 9:36:51 PDT 
Resent-to: Craig Fletcher <fletcherc@X930.Tymnet> 
In-reply-to: your message of Thu, 18 Jun 87 14:37:16 PDT

Paradyne seems to be the favorite around Bubbnet-land.  Mine is a mode
MP-9600 part number 836-4200-0011.  Hope this helps.  -Bill
From: Osman Guven <osman@X930.Tymnet> 
Date: Tue, 7 Jul 87 13:00:24 PDT 
To: FLETCHERC@X930.Tymnet 
Subject: Re: "Ray Donahue called me today with"... 
In-reply-to: your message of Tue, 7 Jul 87 11:59:02 PDT

No problem. If it is really urgent I could make it this Friday(7/10).
Next week would be better due to Friday's schedule.
-Osman-
From: Dennis Coffey (Tymcom-X Systems) <DenCoff@X930> 
Date: Tue, 7 Jul 87 16:15:36 PDT 
To: Craig <FletcherC> 
Subject: TUMS Enhancements. 

Craig,

  We've talked of the enhancements to TUMS which I use, but not in enough
detail for me to show you their advantages.  The enhanced TUMS is simple,
use-friendly, and allows filing of messages into accessable locations, sorted
by the user's own desired filing schema.  I believe it may meet your needs.

  Here is how my use of TUMS appears:
.MAIL		; Frequently read new mail.

 . . .
		; Frequently (maybe daily, up to weekly):
.TUMS		; (To allow reading all messages out of the MAIL file, then
		; deleting the messages, or transferring them to a selected
		; subject-related file, or transferring them to a quarterly
		; archive file, or just leaving them in the current tums
		; "main" mail file.)
*RU		; "Read all Unread messages"
*<disposition command for 1st message>		; (see list of commands)
*<disposition command for next message>		; (see list of commands)
*<disposition command for next message>		; (see list of commands)
. . .
*<disposition command for last new message>	; (see list of commands)
*EX		; delete all "disposed of" files, and exit TUMS


ALIAS "CRAIG"	"Craig <FletcherC>"				;
ALIAS "JOE"	"Joe <JMS>"					;
ALIAS "JON"	"Jon <MosserJ>"					;
ALIAS "TXS"	"TXSSup"					;
ALIAS "MONITOR"	"(Monitor Group:), Carl,Osman,Joe,CC:Craig,TXS"	; aliases for
ALIAS "BILL"	"Bill Soley <WRS@C39>"				; SEND command
ALIAS "WRS"	"Bill Soley <WRS@C39>"				;
ALIAS "JAN"	"Jan Krivanec <IPC.J/KRIVANEC@Ontyme>"		;
ALIAS "KEN"	"Ken BeDell <IOD.BEDELL@Ontyme>"		;

SEND.FROM "Dennis Coffey (Tymcom-X Systems) <DenCoff@X930>"	;

ARCHIVE.FILE "TUM<Q><Y>.ARC"		; Archive file name I.D.s the qtr.

MACRO "RU"	"READ UNREAD"		;
MACRO "RN"	"READ NEW"		;
MACRO "R"	"READ"			;
MACRO "LU"	"LIST UNREAD"		;
MACRO "LN"	"LIST NEW"		;
MACRO "L"	"LIST"			;
MACRO "^P"	"PREVIOUS"		;
MACRO "^"	"PREVIOUS"		; Macros for general commands.
MACRO "^N"	"NEXT"			;
MACRO "^J"	"NEXT"			;
MACRO "^K"	"NEXT DELETE NOARCHIVE"	;
MACRO "S"	"SEND"			;
MACRO "EX"	"EXIT"			;
MACRO "X"	"EXPUNGE"		;
MACRO "D"	"DELETE NOARCHIVE"	;
MACRO "ARC"	"DELETE"		;

MACRO "SPOOL"	"move (DCOFFEY)SPOOL.MAI"	;
MACRO "TRICKS"	"move (DCOFFEY)TRICKS.MAI"	;
MACRO "SPT"	"move (DCOFFEY)USRSPT.MAI"	;
MACRO "MICRO"	"move (DCOFFEY)MICROS.MAI"	;
MACRO "FRIEND"	"move (DCOFFEY)FRIEND.MAI"	;
MACRO "CORP"	"move (DCOFFEY)CORPCOM.MAI"	;
MACRO "SYS"	"move (DCOFFEY)SYSTEM.MAI"	;
MACRO "KEEP"	"move (DCOFFEY)KEEPME.MAI"	;
MACRO "JOBPRC"	"move (DCOFFEY)JOBPRC.MAI"	;
MACRO "PKG"	"move (DCOFFEY)PKGING.MAI"	;
MACRO "2020SPT"	"move (DCOFFEY)20SPT.MAI"	;

MACRO "oSPOOL"	"open (DCOFFEY)SPOOL.MAI"	;
MACRO "oTRICKS"	"open (DCOFFEY)TRICKS.MAI"	;
MACRO "oSPT"	"open (DCOFFEY)USRSPT.MAI"	;
MACRO "oMICRO"	"open (DCOFFEY)MICROS.MAI"	;
MACRO "oFRIEND"	"open (DCOFFEY)FRIEND.MAI"	;
MACRO "oCORP"	"open (DCOFFEY)CORPCOM.MAI"	;
MACRO "oSYS"	"open (DCOFFEY)SYSTEM.MAI"	;
MACRO "oKEEP"	"open (DCOFFEY)KEEPME.MAI"	;
MACRO "oJOBPRC"	"open (DCOFFEY)JOBPRC.MAI"	;
MACRO "oPKG"	"open (DCOFFEY)PKGING.MAI"	;
MACRO "o2020SPT" "open (DCOFFEY)20SPT.MAI"	;


  There's a lot of stuff here.  I'll be glad to explain any details, and to
help you set up your own TUMS.INI file.

  Dennis
Received: from F38.Tymnet by X930.Tymnet; Thu, 9 Jul 87 19:10:49 PDT
Return-path: <JMS@X930> 
From: Joe Smith <JMS@X930> 
Date: Thu, 9 Jul 87 19:09:44 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: EQUIP CHECK on F38's 3652. 



From: JMS
Date: JULY 9,1987 18:57
The THUNGs on BPA12 and BPB6 are a side affect of the HDEV:4 on BPA13.
I tried to read CYL:1 HEAD:22 RECORD:23 4 times to see if it would cause
an EVENT stopcode BADPAG on unit 12 page 511.  It did not.  However, it
took more than 3 seconds for the monitor to do all the retries on that page,
which caused the THUNGs.  BPA12 and BPB6 were not hung - the monitor was
ignoring them while doing the retries.  The best way to clear this disk
error is to ASSIGN and DEASSIGN an alternate track to CYL:1 HEAD:22.
Due to the way SPAGES is used, no data will be lost.   /Joe
The THUNGs on BPA12 and BPB6 are a side affect of the HDEV:4 on BPA13.
I tried to read CYL:1 HEAD:22 RECORD:23 4 times to see if it would cause
an EVENT stopcode BADPAG on unit 12 page 511.  It did not.  However, it
took more than 3 seconds for the monitor to do all the retries on that page,
which caused the THUNGs.  BPA12 and BPB6 were not hung - the monitor was
ignoring them while doing the retries.  The best way to clear this disk
error is to ASSIGN and DEASSIGN an alternate track to CYL:1 HEAD:22.
Due to the way SPAGES is used, no data will be lost.   /Joe
From: Carl A Baltrunas <Carl@X930.Tymnet> 
Date: Wed, 15 Jul 87 15:43:47 PDT 
To: Dennis Ernst <DErnst@B39.Tymnet>, Monitor Group <CARL@X930>, Osman Guven
	<Osman@X930.Tymnet>, Joe Smith <JMS@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey <dencoff@X930.Tymnet>
	
Subject: PDP-11 Diagnostics 

Dennis,
  It is my impression that the node code loaded by NODLOD in *.IMG files
is an image copy made using LINK11 of code that runs in the PDP-11.  It
is also my impression that *.BND files are also possible to be built and
then loaded with LOADII.

  The hardware FE's have some standard diagnostics for PDP-11 based systems
which (on the 11's with disks or tapes) can be loaded and run.

  Do you know if the format of either the BND or IMG files is the same or
similar to the DEC standard diagnostics, and if it is reasonable to expect
that we could load these diagnostics from a TYMCOM-X system using NODLOD or
LOADII?

  If the formats are different, it may be possible (should be, anyway) to
convert them to either IMG or BND file format, and then load them into the
LSI's to run memory or other diagnostics in order to trace some of our
intermittant faults.

  I am asking, because this may be the method to use to try and diagnose
why the micronode at TRW keeps halting... the symptoms suggest a power-
supply problem, but I am unsure, and would like to try another route...
besides, it will give us a way to trace and fix the intermittant problems
we have with two of our micronodes.

/Carl
Received: from B39.Tymnet by X930.Tymnet; Thu, 16 Jul 87 11:23:07 PDT
Return-path: <DERNST@B39.Tymnet> 
From: DERNST@B39.Tymnet 
Date: Thu, 16 Jul 87 11:08:12 PDT 
To: Carl A Baltrunas <Carl@X930.Tymnet> 
Cc: Monitor Group <CARL@X930>, Osman Guven <Osman@X930.Tymnet>, Joe Smith
	<JMS@X930.Tymnet>, Craig Fletcher <fletcherc@X930.Tymnet>, Dennis
	Coffey <dencoff@X930.Tymnet> 
Subject: Re: PDP-11 Diagnostics 
In-reply-to: your message of Wed, 15 Jul 87 15:43:47 PDT

Carl,
  Once upon a time, we had a project to get the source
for the LSI-11 diags (yes, DEC sells them) and assemble them
using our PDP-11 assembler.  They could then be converted
to BND format.  However, since the normal method used by the
field people when the want to do diags is to read them from
mag tape using a portable TU-58, the project was dropped.  They are
also available on paper tape.  

I got your stuff in the mail.  Will call you when I have had a chance to 
look it over.

Dennis
Received: from F33.Tymnet by X930.Tymnet; Mon, 20 Jul 87 10:33:51 PDT
Return-path: <JMS@X930> 
From: Joe Smith <JMS@X930> 
Date: Mon, 20 Jul 87 10:32:17 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: P035C has been built in (OSP:33) 

All of the ##035C.SAV monitors are in (OSP) on system 33 and they have
been telecopied to M33 on their respective systems.    /Joe
From: Joe Smith <JMS@X930> 
Date: Fri, 24 Jul 87 10:43:34 PDT 
To: Osman Guven <osman@X930.Tymnet> 
Cc: Carl A Baltrunas <carl@X930.Tymnet>, DENCOFF, FLETCHERC 
Subject: Re: Question ..?? 
In-reply-to: your message of Fri, 24 Jul 87 10:32:54 PDT

1.  As long as 62 and 930 are both working, we can reload the microbases from
the other CPU.  The 2020 can reload its microbase and 2346, but nothing else.
6657:	Use NODLOD on 62.  10115 and 2346 must be up.
10115:	Use NODLOD on 930.  6657 and 2346 must be up.
2346:	Use NODLOD on 62, 930, or 95.  The host's base must be up.
2770:	Use NODLOD on 62 or 930.  Intervening nodes must be up.
6760:	Use NODLOD on 95 running in CONSOLE mode.
Note:  After a complete power failure, 6657 and 10115 must be reloaded from
the network.  With host 57 gone, WE CAN'T RUN LOADII!!!!!! 

2. Out Dial information is in the INFO tree, topic OUTDIAL.
				/JOE
Received: from D23.Tymnet by X930.Tymnet; Fri, 24 Jul 87 12:15:48 PDT
Return-path: <JMS@X930> 
From: Joe Smith <JMS@X930> 
Date: Fri, 24 Jul 87 14:14:44 CDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: Info in (NETDB:23) about our nodes. 

 Node    Host Description     Mem  Customer                 Eff-date Order Site
 2770      14 TEST HOST         60 TYMNET/FIELD SUPPORT     PENDING  35763  177
 2770     118                      TYMNET/FIELD SUPPORT     07/25/85 33633  177
 2770    3984 TEST HOST            TYMNET/FIELD SUPPORT     PENDING  35334  177
 2770    4681 KERNEL HOST

 6657      15 TEST HOST         60 TYMNET/FIELD SUPPORT     PENDING  35763  177
 6657     930                      TYMNET/FIELD SUPPORT     07/25/85 13480  177
 6657    4117 TEST HOST            TYMNET/FIELD SUPPORT     PENDING  35334  177
 6657    4511 KERNEL HOST

 6760      16 TEST HOST         60 TYMNET/FIELD SUPPORT     PENDING  35763  177
 6760      95 TYMCOM               TYMNET/FIELD SUPPORT     07/02/85 12649  177
 6760     934         ???          TYMNET/FIELD SUPPORT     06/17/85 12649  177
 6760    4284 TEST HOST            TYMNET/FIELD SUPPORT     PENDING  35334  177
 6760   18813 MICRO TYMBASE        TYMNET/FIELD SUPPORT     05/01/85 12649  177
 6760    ???? KERNEL HOST (not on file, we are using 934 as kernel host)

10115      17 TEST HOST         60 TYMNET/FIELD SUPPORT     PENDING  35763  177
10115      62                      TYMNET/FIELD SUPPORT     MOVE     30761  177
10115    4525 TEST HOST            TYMNET/FIELD SUPPORT     PENDING  35334  177
10115    7964 KERNEL HOST
From: Joe Smith <JMS@X930> 
Date: Sat, 25 Jul 87 0:30:03 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: Hotline call Friday night 

24-Jul-87 22:45/Joe
Contact:  Fremont Operations, Tim, (415)498-2588, System F30.
Problem:  While doing a PAKCOPY, accidently initialized the source pack.
Fix:      Created 30XX02 on (M33:33) because it has TSTSUP in it.
	  Put BPA13CB at UNTTBL+12, rewrote HOM page on DSKB12 usin DSKB22
	  as a template.  FULL DSKCLN ran, answered at 00:24


From: Carl A Baltrunas <Carl@X930.Tymnet> 
Date: Sat, 25 Jul 87 20:03:34 PDT 
To: Monitor Group <CARL@X930>, Osman Guven <Osman@X930.Tymnet>, Joe Smith
	<JMS@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey <dencoff@X930.Tymnet>
	
Subject: Re: TSTSUP in the monitor 

Congratulations!!!  Good work.  Life will be much easier now...

/Carl
From: Carl A Baltrunas <Carl@X930.Tymnet> 
Date: Sun, 26 Jul 87 2:41:14 PDT 
To: Monitor Group <CARL@X930>, Osman Guven <Osman@X930.Tymnet>, Joe Smith
	<JMS@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey
	<dencoff@X930.Tymnet>, William R Soley <WRS@B39.Tymnet> 
Subject: PDP-10 coding trick 

  In putting together my own octal print routine for my SETOP endeavor
I chose to combine the octal and decimal print routines into one.  This
had the side effect that octal numbers with the sign bit set became
a weird set of punctuation marks (since I had an unsigned print routine).

		  OOPS!

  If you start with a standard routine such as this...

  num = 1
  rem = num+1

OCTOUT:	SKIPA	rad,[^D8]		; octal
DECOUT: MOVEI	rad,^D10		; decimal
RDXOUT: IDIV	num,rad			; divide
	HRLM	rem,(P)			; save remainder on stack
	SKIPE	num			; any more digits?
	  PUSHJ	P,RDXOUT		; yes, loop
	HLRZ	num,(P)			; get digit from stack
	MOVEI	num,"0"(num)		; convert to digit
	OUTCHR	num			; print it (with routine of choice)
	POPJ	P,			; return when done

  I came up with this interesting bit of code as a work around that I had
never encountered in any bag of PDP-10 coding tricks...

OCTOUT:	SKIPA	rad,[^D8]		; octal
DECOUT: MOVEI	rad,^D10		; decimal
; ** begin trick **
	EXCH	num,rem			; setup number in remainder word
	SETZ	num,			; for 2-word divide instead
	LSHC	num,1			; shift sign (if any) to high word
	LSH	rem,-1			; shift low word back into position
	DIV	num,rad			; first divide, results same as IDIV
	CAIA				; or JRST .+2 to skip first divide
; ** end trick **
RDXOUT: IDIV	num,rad			; divide
	HRLM	rem,(P)			; save remainder on stack
	SKIPE	num			; any more digits?
	  PUSHJ	P,RDXOUT		; yes, loop
	HLRZ	num,(P)			; get digit from stack
	MOVEI	num,"0"(num)		; convert to digit
	OUTCHR	num			; print it (with routine of choice)
	POPJ	P,			; return when done

; Have you ever seen this used anywhere before?

PS.  TYMCOM-X only...
    replace
	MOVEI	num,"0"(num)
	OUTCHR	num
    with
	OUTCHI	"0"(num)		; outchr immediate

/Carl
From: JMS@X930.Tymnet 
Date: Mon, 27 Jul 87 8:43:10 PDT 
To: FLETCHERC 
Subject: "I had 12.8 hours standby and 1"... 

I had 12.8 hours standby and 1 hotline call of 2 hours.  /Joe
From: Osman Guven <osman@X930.Tymnet> 
Date: Mon, 27 Jul 87 8:51:28 PDT 
To: Monitor Group <Osman@X930.Tymnet>, Carl A Baltrunas <carl@X930.Tymnet>, Joe
	Smith <jms@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey <dencoff@X930.Tymnet>
	
Subject: I am on call this week .. 7/27 to 8/2 


Received: from F33.Tymnet by X930.Tymnet; Mon, 27 Jul 87 10:46:49 PDT
Return-path: <JMS@F33.Tymnet> 
From: JMS@F33.Tymnet 
Date: Mon, 27 Jul 87 10:41:39 PDT 
To: fletcherc@930 
Subject: "In reference to F3's in training:"... 

In reference to F3's in training:  There is some confusion here as to how
much it costs to maintain the F3's.  One person was told $3400 per month
($40,800 per year), another person was told $30,000 per month ($360,000
per year).  One comment was "if maintenance on two F3's is more than the
maintenance on four Engines, it's not worth it."  George King needs to see
the costs specified in writing before he can commit to the project.   /Joe
Received: from F29.Tymnet by X930.Tymnet; Mon, 27 Jul 87 12:44:22 PDT
Received: from EMSTXS.Ontyme.Tymnet by F29.Tymnet; Mon, 27 Jul 87 12:32:58 PDT
Return-path: <IPC.SRAMAIL@EMSTXS.Ontyme.Tymnet> 
From: IPC.SRAMAIL@EMSTXS.Ontyme.Tymnet 
Date: 27 JUL 87 12:04:42 
To: TXS.C/FLETCHER@EMSTXS.Ontyme.Tymnet 
Cc: QSATS.G/WALKER@Ontyme.Tymnet, IPC.B/FISCHER@Ontyme.Tymnet,
	IPC.E/ROOP@Ontyme.Tymnet, TXS.C/BALTRUNAS@Ontyme.Tymnet,
	IPC.R/DANIELS@Ontyme.Tymnet, IPC.C/ELDRED@Ontyme.Tymnet,
	TXS.C/FLETCHER@Ontyme.Tymnet, IPC.JENNY@Ontyme.Tymnet,
	IPC.SRAMAIL@Ontyme.Tymnet 
Message-id: A85797@Ontyme.Tymnet 
Subject: F70 -> F33 CONSOLIDATION SCHEDULE 

SUBJ: F70 -> F33 CONSOLIDATION SCHEDULE





                         M E M O R A N D U M





DATE>      27 JUL 87  12:00

TO>        GARY WALKER

COPIES>    BILL FISCHER
           ED ROOP
           RPM GROUP
           CARL BALTRUNAS
           RICK DANIELS
           CHERYL ELDRED
           CRAIG FLETCHER

FROM>      LINDA FREITAS
           RESOURCE PLANNING AND MANAGEMENT


SUBJECT>   F70 -> F33 CONSOLIDATION SCHEDULE


-----------------------------------------------------------------------



    RPM           -ORDERED NEW 3652 STRING; ESTIMATED DATE OF ARRIVAL: WEEK
                   OF AUGUST 10.   
     
    FREMONT OPNS. -WHEN NEW STRING ARRIVES, ADD TO F33. THIS WILL OCCUR    
                   DURING A WEEKEND AND WILL BE SCHEDULED APPROXIMATELY    
                   TWO WEEKS FROM ARRIVAL OF STRING.   
     
    RPM   
    JENNY ENGLISH -BEGIN CONSOLIDATION OF USERS FROM F70 ONTO F33 BY GROUPS.    
                   THERE ARE THREE GROUPS, GROUP #1 CONSISTS OF FIELD SERVICE,  
                   NTD AND VARIOUS OTHERS AND IS SCHEDULED TO BE MOVED ON  
                   AUGUST 14, 1987 (FRIDAY). 
     
                   GROUP #2 CONSISTS OF TYMNET USERS AND IS SCHEDULED TO BE
                                                                Page  2

                   MOVED ON AUGUST 28, 1987 (FRIDAY); PROVIDED THAT THE NEW
                   DASD IS ADDED TO SYSTEM F33.   
     
                   GROUP #3 CONSISTS OF INTERNAL GROUPS AND IS SCHEDULED   
                   TO BE MOVED BY SEPTEMBER 3, 1987 (THURSDAY), HALF OF    
                   THESE USERS WILL BE MOVED BY JENNY, THE OTHER HALF 
                   WILL BE MOVED BY EACH INDIVIDUAL.   
     
                   JENNY WILL BE SENDING DETAILED MOVE PROCEDURAL MEMOS    
                   PRIOR TO EACH MOVE TO THE INVOLVED PARTIES.   
     
                   CLOSE MONITORING OF F33 USAGE AND PERFORMANCE WILL 
                   CONTINUE THROUGHOUT ENTIRE MOVE.    
     
                   ALL F70 USERS SHOULD BE UP AND RUNNING ON F33 BY   
                   FRIDAY, SEPTEMBER 3, 1987.
     
    FREMONT OPNS.   
    RICK DANIELS  -F70 WILL MAINTAIN DAILY UPDATES MADE OF USERS MOVED
                   TO F33 FOR LENGTH OF CONSOLIDATION. 
     
                   BRING F70 COMPLETELY DOWN AND CONVERT F74 FROM 30'S
                   TO 50'S TAKEN FROM F70.
From: Joe Smith <JMS@X930> 
Date: Mon, 27 Jul 87 14:08:57 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff, Dennis Ernst <DErnst@B39> 
Subject: TXS micronet *.BND files are now on F38 and D37. 

Since (NEW11:57)ND6657.BND,ND6760.BND,ND2770.BND,ND0115.BND went away when
system 57 was shut down, I went to (NEW11:39) and telecopied the files to
(NEW11:38) and (NEW11:37).  This puts the required files on 3 consecutive
systems (37,38,39) in 3 locations (Dallas, Fremont, Bubbnet).  The TXS
micronet files in (CURR11), (OLD11), (DOC11), and (TOOLS11) have also been
copied from 39 to 38 and 37.

The ND####.BND files in (NEW11) on 62, 95, and 930 might not be correct, due
to changes in the routing table (which is not stable yet).

			/Joe
From: Carl A Baltrunas <Carl@X930.Tymnet> 
Date: Mon, 27 Jul 87 14:29:49 PDT 
To: Monitor Group <CARL@X930>, Osman Guven <Osman@X930.Tymnet>, Joe Smith
	<JMS@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey
	<dencoff@X930.Tymnet>, Dennis Ernst <DErnst@B39.Tymnet> 
Subject: TXS-NET map 

Dennis,
  (CURR11:930)RUFSC.MAC  is complete, showing all host and node links
for our micronet.  We do not have a kernel host # on BNET for 2346
(or have verified that 2346 is available as a node on bubbnet) and have
not getten a host number for the KS on bubbnet yet... but that will not
be needed until late October most probably anyway.

  Let us know when the code is ready so we can start reconfiguration.

Thanks again...

/Carl
From: Joe Smith <JMS@X930> 
Date: Mon, 27 Jul 87 14:46:16 PDT 
To: Dennis Ernst <DErnst@B39>, Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: TXSBND.WHR and TXSIMG.WHR 

(JMS:930)TXSBND.WHR shows where our ND####.BND files are.
(JMS:930)TXSIMG.WHR shows where our SV####.IMG files are.
The files are sorted by file name, checksum, then directory:system.
From: Osman Guven <osman@X930.Tymnet> 
Date: Mon, 27 Jul 87 16:45:55 PDT 
To: Monitor Group <Osman@X930.Tymnet>, Carl A Baltrunas <carl@X930.Tymnet>, Joe
	Smith <jms@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey <dencoff@X930.Tymnet>
	
Subject: Running D56 with 200. ports 

Joe ..

Do you see any problem running D56 with 200 ports.??
D56-P035/C is cut with 200 ports and ready come up with it, right?
Roy R. is asking us to come up with 200 port monitor first and
after couple of days, he will have network reload the base code
which is cut for 200 port.
-Osman-
From: Joe Smith <JMS@X930> 
Date: Mon, 27 Jul 87 17:50:57 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: Re: Running D56 with 200. ports 

56XB03.SAV, 56XB04.SAV, 56XB08.SAV, 56XB10.SAV, and 56035C all have 200
ports.  56XB03.SAV is dated 6-May, we tested it, but never bothered to put
it on NEWMON.  Suggest running 56035C instead.
From: Joe Smith <JMS@X930> 
Date: Thu, 30 Jul 87 15:29:02 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: IME crashes on D37 caused by low core getting corrupted. 

The immediate cause of the IME (Illegal Memory reference from Exec) was
due to the byte pointer at UPYUWM got changed from 001200,,374670 to
401202,,354670.  Bits 0 and 16 got set and bit 22 got cleared.  Several other
words in the vicinity of UPYUWM also got mangled - see below.

I think it was caused by the "SET AUTOLOGOUT" inactivity timer going off
while the user's context pages were swapped out.  This would not show up on 930
or 95 unless a bunch of memory hogs were logged in to force the idle job out.

DSK:6000.MON (1447 30-JUL-87)	 DSK:6000.C05 (1447 30-JUL-87)
   the running monitor		   crash dump from IME
1)1 Input file: 		2)1 Input file: (SYS)CRA005     Bit 0 got set
1) $$C 6000<6777>0$N		2) $$C 6000<6777>0$N		Bit 16 got set
**************							Bit 22 cleared
1) UPYPSR/ 310300,,372701	2) UPYPSR/ 710302,,352701	400002,,020000
1) USYPSR/ 310300,,773701	2) USYPSR/ 710302,,753701	   "      "
1) UXYPSR/ 310300,,366701	2) UXYPSR/ 710302,,346701	(same for all)
1) UPYUWM/   1200,,374670 	2) UPYUWM/ 401202,,354670
1) USYUWM/   1200,,775670	2) USYUWM/ 401202,,755670
1) UXYUWM/   1200,,370670	2) UXYUWM/ 401202,,350670
1) USYSIN/ 241200,,775675	2) USYSIN/ 641202,,755675
1) USYLSP/   1200,,775675	2) USYLSP/ 401202,,755675
1) PBMMSK/      0,,177777	2) PBMMSK/ 400002,,157777
1) UPYPTM/   2200,,372414	2) UPYPTM/ 402202,,352414
1) UPYPXM/   2200,,372412	2) UPYPXM/ 402202,,352412
1) USYPTM/   2200,,773414	2) USYPTM/ 402202,,753414
1) USYPXM/   2200,,773412	2) USYPXM/ 402202,,753412
1) UXYPTM/   2200,,372414	2) UXYPTM/ 402202,,352414
1) LMYCUR/ 410212,,373521	2) LMYCUR/ 410212,,353521
1) LMYLMA/   2712,,373521	2) LMYLMA/ 402712,,353521
1) LMYHDA/   1212,,373521	2) LMYHDA/ 401212,,353521
1) LMYSPB/  42212,,373521	2) LMYSPB/ 442212,,353521
1) LMYSPO/    412,,373521	2) LMYSPO/ 400412,,353521
1) HNGTIM/ 12			2) HNGTIM/ 67
1) HNGMIN/ 16			2) HNGMIN/ 21
      CIPWT is the clock queue.  It is supposed to differ.
1) CIPWT+0/ 400012,,600004	2) CIPWT+0/ 400017,,145
1) CIPWT+1/ 410102,,42		2) CIPWT+1/ 410111,,200002
1) CIPWT+2/ 400003,,400112	2) CIPWT+2/ 410101,,103
1) CIPWT+3/ 400050,,200033	2) CIPWT+3/ 400025,,200027
1) CIPWT+4/ 400036,,600005	2) CIPWT+4/ 410120,,600003
From: Joe Smith <JMS@X930> 
Date: Thu, 30 Jul 87 16:46:38 PDT 
To: Monitor Group <JMS>, Carl, Osman 
Cc: FletcherC, DenCoff 
Subject: D37 crashes fixed. 

You can delete all the previous messages about the crashes on D37 from the
inactivity timer.  The real problem is that INTKIL.PAT was not applied to
any of the /B, /B-1, /B01, or /B04 monitors inDallas.  The only system that
had the patch was D55.  SYSTEM.SAV has been patched now.  /Joe
From: Carl A Baltrunas <Carl@X930.Tymnet> 
Date: Sun, 2 Aug 87 23:42:08 PDT 
To: Monitor Group <CARL@X930>, Osman Guven <Osman@X930.Tymnet>, Joe Smith
	<JMS@X930.Tymnet> 
Cc: Craig Fletcher <fletcherc@X930.Tymnet>, Dennis Coffey <dencoff@X930.Tymnet>
	
Subject: Agenda item(s) 


1. TrainNet connection
   a. refusal of F3s due to space and maintenance costs
   b. connection to TrainNet at Nicholson Lane
      1. Bob Grandey and George King are in favor of some arrangement
      2. What do we get out of this arrangement?

2. Review of Monitor /C release (current stage?)

3. Review of Monitor /D release
   a. What is going to be implemented
   b. Additional 1+s that have come up in the past 3 weeks
   c. What will be put off until /E or later?

4. Congratulations to Joe and Carl for successful completion of class
   (Both Joe and Carl finished at the top of their respective classes)

5. Review of D37 crash due to missing patch

6. Review of Ranier Bank problem with BOOTS-MT-Memory parity problems

7. Update status of the move to South Bay Center

8. Update on the progress of building our micronet for the move

9. Review of computing resources

 ]¤
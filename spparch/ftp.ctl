! UPD ID= 2127, SNARK:<5.ARPA-UTILITIES>FTP.CTL.3,   4-Jun-81 10:43:14 by PAETZOLD
! FTSCTL HAS GONE AWAY
!
! NAME: FTP.CTL
! DATE: 4-JUN-81
!
!THIS CONTROL FILE IS PROVIDED FOR INFORMATION PURPOSES ONLY.  THE
!PURPOSE OF THE FILE IS TO DOCUMENT THE PROCEDURES USED TO BUILD
!THE DISTRIBUTED SOFTWARE.  IT IS UNLIKELY THAT THIS CONTROL FILE
!WILL BE ABLE TO BE SUBMITTED WITHOUT MODIFICATION ON CONSUMER
!SYSTEMS.  PARTICULAR ATTENTION SHOULD BE GIVEN TO ERSATZ DEVICES
!AND STRUCTURE NAMES, PPN'S, AND OTHER SUCH PARAMETERS.  SUBMIT
!TIMES MAY VARY DEPENDING ON SYSTEM CONFIGURATION AND LOAD.  THE
!AVAILABILITY OF SUFFICIENT DISK SPACE AND CORE IS MANDATORY.
!
! FUNCTION:	THIS CONTROL FILE BUILDS FTP FROM ITS BASIC 
!		SOURCES.  THE FILES CREATED BY THIS JOB ARE:
!				FTP.EXE
!				FTPSER.EXE
!
! SUBMIT WITH THE SWITCH "/TAG:CREF" TO OBTAIN
!   A .CRF LISTING OF THE SOURCE FILE
!
@DEF FOO: NUL:
@GOTO A
!
CREF:: @DEF FOO: DSK:
!
!
A::
!
! TAKE A CHECKSUMMED DIRECTORY OF ALL THE INPUT FILES
!
@VDIRECT SYS:MACRO.EXE,SYS:LINK.EXE,SYS:CREF.EXE,FTP.MAC,FTPSER.MAC,
@CHECKSUM SEQ
@
@VDIRECT SYS:MONSYM.UNV,SYS:MACSYM.UNV,SYS:MACREL.REL,SYS:PA1050.EXE,
@CHECKSUM SEQ
@
@
@RUN SYS:MACRO
@INFORMATION VERSION
@GET SYS:LINK
@INFORMATION VERSION
@GET SYS:CREF
@INFORMATION VERSION
!
@NOERROR
@COMPILE /COMPILE /CREF FTP.MAC
!
@R CREF
*FOO:FTP.LST=FTP.CRF
!
@LOAD FTP
!
@SAVE FTP.EXE
@INFORMATION VERSION
!
@COMPILE /COMPILE /CREF FTPSER.MAC
!
@R CREF
*FOO:FTPSER.LST=FTPSER.CRF
!
@LOAD FTPSER
!
@SAVE FTPSER.EXE
@INFORMATION VERSION
!
@DIRECT FTP.EXE,FTPSER.EXE,
@CHECKSUM SEQ
@
!
@DELETE FTP.REL,FTPSER.REL
  
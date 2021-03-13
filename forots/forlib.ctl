:LOGFILE FORLIB.LOG
;	Job to build FORLIB (the FORTRAN math library) and
;	             FOROTS (the FORTRAN object time system) 5A(721)
;	and	     FORDDT version 5A(101)

TYPE FORCPU.TYM		;Show which feature tests are enabled

RUN (FTSYS)MACRO	;Compile FORLIB for KI/KL/KS
FORPRM=FORCPU.TYM,FORPRM.MAC
FORCNV=FORCNV.MAC
FORCPX=FORCPX.MAC
FORDAR=FORDAR.MAC
FORDBL=FORDBL.MAC
FORDMP=FORDMP.MAC
FORDUM=FORDUM.MAC
FORERR=FORERR.MAC
FORFUN=FORFUN.MAC
FORINI=FORINI.MAC
FORJAK=FORJAK.MAC
FORMSC=FORMSC.MAC
FOROPN=FOROPN.MAC
FOROTS=FOROTS.MAC
FORPLT=FORPLT.MAC
FORPSE=FORPSE.MAC
FORQUE=FORQUE.MAC
FORRTF=FORRTF.MAC
FORSIN=FORSIN.MAC
FORTRP=FORTRP.MAC
FORXIT=FORXIT.MAC
FORNAM=FORNAM.MAC
FORDDT=FORDDT.MAC
:ESCAPE

RUN PIP			;Combine the REL files into FORLIB.REL
FORLIB.REL=FORJAK.REL,FORINI.REL,FOROTS.REL,FORFUN.REL,FORQUE.REL,FORCNV.REL,FORTRP.REL,FORERR.REL,FOROPN.REL,FORDMP.REL,FORPSE.REL,FORPLT.REL,FORCPX.REL,FORSIN.REL,FORDBL.REL,FORDAR.REL,FORRTF.REL,FORMSC.REL,FORDUM.REL,FORXIT.REL,FORNAM.REL
:ESCAPE

RUN MAKLIB		;Index the library and remove local symbols
FORLIB.REL=FORLIB.REL/INDEX/NOLOCALS
/EXIT

R LINK		;Make FOROTS.SHR
FOROTS.MAP/MAP
FOROTS/SSAVE = FOROTS,FORLIB/SEARCH/GO

DIRECT FOROTS.*,FORLIB.*

;[End of FOROTS.CTL]
   
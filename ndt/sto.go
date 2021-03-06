list DSK:BACKUP.LOG
tape T:
interchange
rewind
sort files alphabetical
files

ssname FAIL
	;Help you get FAIL up.
save FAIL.REL, FAIL.SAV
	;switch settings, actual source
save TENEX.FAI, TOPS10.FAI, TOPS20.FAI, TYMSHR.FAI, FAIL.FAI
	;build instructions, manual (two versions)
save FAIL.INS, FAIL.DOC, FAIL.MAN


ssname BOOT
save 2OPS2.OPS, BKTBL.BKT, RUNTIM.REL, SAIL.REL


ssname SAILSOURCES

	;BAIL sources
save BAIPD9.FAI, BPDAHD.FAI, BSM1HD.FAI, LDBAIL.SAI, BAIL.SAI, BAILDD.FAI

	;other auxillary sources
save MAKBKT.SAI, MAKTAB.SAI, PROCES.DEF, RECORD.DEF

	;construction sources
save SCNCMD.SAI, PTRAN.SAI, RTRAN.SAI, SCISS.SAI, ORDER.

	;production rules, runtimes descriptions
save HEL., FOO3.T10, FOO3.

	;compiler/runtimes common definitions
save HEAD. 

	;compiler sources
save SAIL., PARSE., SYM., GEN., ARRAY., EXPRS., STATS., LEAP., TOTAL., PROCSS., COMSER.
save XTCHDR.FAI, DATA., ENDDAT., DB., RENCSW.

	;runtimes sources
save GOGOL., TRIGS., STRSER., IOSER., ARYSER., RECSER., NWORLD., LEPRUN., WRDGET., SPARES.
save LOW., UP., NOTDDT.FAI

ssname SAILSOURCESB
	;other auxillary sources
save MAKTAB.TNX 
	;productions, runtimes descriptions
save FOO3.TNX, FOO3.TYM
	;compiler/runtimes common definitions
save TENEXSW., DEFJS., JSYSES.
	;compiler sources
save CC. 
	;runtimes sources
save CALL.TNX, IOSER.TNX, TRIG1.TNX, TRIG2.TNX, WNTHED., WNTEND.


REWIND
SILENCE
SSNAME ALL
PRINT dsk:store.dir
EXIT

  
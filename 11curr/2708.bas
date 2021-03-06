5!  Eprom reformatter for 2708
10	extend
12	dim iblk%(512), oblk%(512)
14	print "Eprom formatter for the 2708"
16	print "Converts xxx.SAV => xxx.ROM  (BDV11 format)."
20	ib% = 2%
24	icnt% = 513%
26	ocnt% = 0%
28	chksum% = 0%
29	xcnt% = 1% \ xsum% = 0%
30	input "Input file ";a$ \ w% = instr(1%,a$,chr$(46%))
31	if w% = 0% or w% > 6% then v% = 6% else v% = w% - 1%
32	a$ = left(a$,v%)+".SAV"
33	print "Using file "; cvt$$(a$,32%)
34	open a$ for input as file #1 mode 1%
35	open "lda.tmp" for output as file 2%
36	print "Creating binary tmp file ... ";
38	on error goto 1000
40! output header
42	obyte% = 1% \ gosub 4000
46	obyte% = 0% \ gosub 4000
48	obyte% = 2024% and 255% \ gosub 4000
50	obyte% = swap%(2024%) and 255% \ gosub 4000
52	obyte% = 0% \ gosub 4000
54	obyte% = swap%(512%) and 255% \ gosub 4000
60! output one large data block
62	for i% = 1% to 2018%
64	  gosub 3000
66	  obyte% = ibyte%
68	  gosub 4000
70	  next i%
72! output checksum
74	obyte% = -chksum% and 255% \ gosub 4000
80! output start address block
82	chksum% = 0%
83! output header
84	obyte% = 1% \ gosub 4000
86	obyte% = 0% \ gosub 4000
88	obyte% = 6% \ gosub 4000
90	obyte% = 0% \ gosub 4000
92	obyte% = 512% and 255% \ gosub 4000
94	obyte% = swap%(512%) and 255% \ gosub 4000
96! output checksum
100	obyte% = -chksum% and 255% \ gosub 4000
110! flush output buffer and close all files
116	gosub 4000
130	close #1,#2
132	print "Done."
200! create ascii hex file for pb:
202	print "Creating ascii hex file for PB: ... ";
204	open "lda.tmp" for input as file 1%
206	open "2708a.rom" for output as file 2%
208	open "2708b.rom" for output as file 3%
210! output headers
212	print #2, "2708,1024,8,000,7FF,0,xxx"
214	print #3, "2708,1024,8,000,7FF,0,xxx"
216	ib% = 1% \ icnt% = 513%
220! convert binary data to ascii hex
222	for i% = 1% to 1024%
224	  gosub 3000
226	  print #2, fnh$(ibyte%)
228	  next i%
230	for i% = 1% to 1024%
232	  gosub 3000
234	  print #3, fnh$(ibyte%)
236	  next i%
240	close #1,#2,#3
242	print "Done."
244	kill "lda.tmp"
246	print "Files 2708a.rom, 2708b.rom created."
250	goto 32767
1000! error routine to handle short input files
1002	if err <> 11% goto 1100
1004	for j% = 1% to 512%
1006	  iblk%(j%) = 0%
1008	  next j%
1010	resume 3060
1100	print "Error number ";err;" at line ";erl
1102	goto 32767
3000! subroutine to input a byte
3020	if icnt% <= 512% goto 3080
3030	get #1%, block ib%
3040	field #1, 512% as iblk$
3050	change iblk$ to iblk%
3060	ib% = ib% + 1%
3070	icnt% = 1%
3080	ibyte% = iblk%(icnt%)
3090	icnt% = icnt% + 1%
3100	return
4000! subroutine to output a byte and acumulate checksums
4001	chksum% = (chksum% + obyte%) and 255%
4002	if xcnt% <= 254% goto 4016
4004	xbyte% = obyte%
4006	obyte% = 85%
4008	gosub 4019
4010	obyte% = -(xsum% + 85%) and 255%
4012	gosub 4019
4014	obyte% = xbyte% \ xcnt% = 1% \ xsum% = 0%
4016	xsum% = (xsum% + obyte%) and 255%
4018	xcnt% = xcnt% + 1%
4019	ocnt% = ocnt% + 1%
4020	if ocnt% <= 512% goto 4060
4025	oblk%(0%) = 512%
4030	change oblk% to xblk$
4040	field #2, 512% as oblk$
4045	lset oblk$ = xblk$
4050	put #2%
4052	ocnt% = 1%
4060	oblk%(ocnt%) = obyte%
4070	return
5000	def fnh$(t%)
5002	t$ = space$(2%) if len(t$)<>6%
5004	lset t$ = mid("0123456789ABCDEF",((t%/16%^t1%) and 15%)+1%,1%)+t$
 		for t1% = 0% to 1%
5006	fnh$ = t$
5008	fnend
32767	end
                                                                                                                                                                
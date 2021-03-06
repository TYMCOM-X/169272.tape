5! Program to convert SAV files to ROM files in 82s131 format
8	extend
 \	on error goto 7100
 \	dim blk%(512)
10	print "Rom formatter for the 82s131"
 \	print "Converts xxx.SAV => S131n.ROM"
 \	input "Type input file"; ifile$
 \	m% = instr(1%,ifile$,chr$(46%))
 \	if m%=0% or m%>6% then m%=6% else m%=m%-1%
 \	ifile$ = left(ifile$,m%)+".SAV"
 \	print "Using file "; cvt$$(ifile$,32%)
20	open ifile$ for input as file #1%
 \	input "Is this for a 9301 ";d$ \ d$=cvt$$(d$,32%)
 \	if d$ = "Y" then mask% = 254%  else mask% = 0%
 \	print "Creating ascii-hex files ... ";
 
 \! open output files and print headers
60	for n% = 2% to 5%
 \	  ofile$ = "s131" + right(fnh$(n%+8%),2%) + ".ROM"
 \	  open ofile$ for output as file n%
 \	  print #n%, "SIG82S131,512,4,000,3FF,V1.0,xxx"
 \	  next n%
100! process data blocks 2 & 8
102	for n% = 2% to 8% step 6%
104	  get #1%, block n%
106	  field #1%, 512% as blk$
108	  change blk$ to blk%
109! invert bits if for 9301
110       if mask% = 0% goto 120
112	  for k% = 1% to 512% step 2%
114         blk%(k%) = blk%(k%) xor mask%
116         blk%(k%+1%) = blk%(k%+1%) xor 1%
118	    next k%
120	  for k% = 1% to 512% step 2%
122	    a$ = fnh$(blk%(k%))
124	    b$ = fnh$(blk%(k%+1%))
130	    print #2%, right(a$,2%)
132	    print #3%, left(a$,1%)
134	    print #4%, right(b$,2%)
136	    print #5%, left(b$,1%)
140	    next k%
150	  next n%
158! all done. tell user,clean up and get out.
160	close #1,#2,#3,#4,#5
162	print "done."
164	print "Files S131A.ROM, S131B.ROM, S131C.ROM & S131D.ROM created."
170	goto 32767
7000! subroutine to fill out short files with zeros
7100	if err <> 11% goto 7200
7110	blk%(j%) = 0% for j% = 1% to 512%
7120	resume 7030
7200	print "Error number",err,"on line",erl \ resume 10
9000! subroutine to convert integers to ascii hex
9002	def fnh$(t%)
9010	t$ = space$(2%) if len(t$)<>6%
9020	lset t$ = mid("0123456789ABCDEF",((t%/16%^t1%) and 15%)+1%,1%)+t$
 		for t1% = 0% to 1%
9030	fnh$ = t$
9040	fnend
32767	end
           
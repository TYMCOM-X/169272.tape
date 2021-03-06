.xchargDef 1,!XCRSC,|read saved charges|;
.b!ex
	MOVE	ac, [-count,,addr]
	XCHARG	ac,
	  error return
	normal return
.!sag
where <addr> points to a <count>-long table of the form
	wd 0	.XCRSC	; function code
	wd 1	mask	; see {TabRef TAB64}
	wd 2+		; see below
.e!ex
If the process has not done an .XCSAV,
or if <count> less than 2,
take the error return.
If c<addr+1>=0 read the saved charge that is given when c<mask>=0 into
addr+2 and skip return.
Otherwise, for each marked bit set (as indicated by c<mask>), deposit
the saved charges beginning at addr+2 and continuing for length
<count>.  Skip return upon completion.
.
.endSec !XCRSC:
   
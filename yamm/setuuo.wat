0001?	.setuuoDef 6,!STWAT,|set WATCH bits|;
0002?	.b!ex
  0003?		MOVE	ac, [.STWAT,,watch]
  0004?		SETUUO	ac,
 0005?		  JFCL	; never taken
 0006?		normal return
   0007?	.e!ex
  0008?	Set the right half of the frame's watch word
   0009?	to <watch> and skip-return.
0010?	.
 0011?	.queueTab WATCH;
 0012?	.endSec !STWAT:
  
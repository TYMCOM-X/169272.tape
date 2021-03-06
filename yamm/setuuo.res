.setuuoDef 12,!STRES,|Read/Set RESTART bits|
.b!ex
	MOVE	ac,[!STRES,<bits>]
	SETUUO	ac,
	 error return		;license missing
	normal return

<bits>:
bit(s)	function

1B18	0-read RESTART bits into rh(AC)
	1-swap RESTART bits with bits in AC
1B19	0-write DSKCLN type to HOM blocks
	1-do not write DSKCLN type to HOM blocks
377B27	crash RESTART bits
377B35	orderly takedown RESTART bits

.!sag;
The structure of the <crash> and <hangup> fields is identical.
Numbering the bits in the field from 0 to 7 [higher to lower order],
the structure is:

bit(s)	function
1B0	the auto/manual BOOTS bit is defined
1B1	the auto/manual ONCE bit is defined
1B2	the DSKCLN type field is defined
1B3	auto/manual BOOTS bit:
	1-manual BOOTS (requests CTY input)
	0-auto BOOTS (BOOTS reads command string
	  passed to it by crash code)
1B4	auto/manual ONCE bit:
	1-manual ONCE (requests CTY input)
	0-auto ONCE restart, no CTY input
7B7	DSKCLN type field:
  0	no DSKCLN
  1	fast DSKCLN
  7	full DSKCLN
(other values of DSKCLN type currently undefined)
.e!ex

If the caller has neither {OP} or {RC} license,
take the error return.

Set AC to the current monitor RESTART bits.

If 1B18 in <bits> is 0, take the normal return.

If the caller is missing {OP} license, take
the error return.

Set the monitor RESTART bits to <bits> and
take the normal return.
.endSec !STRES:
  
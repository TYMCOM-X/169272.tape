File 1)	DSK:RDIST.103	created: 1737 04-OCT-87
File 2)	DSK:RDIST.SAI	created: 2006 02-APR-88

1)1	require '1 lsh 24 lor '103 version;	comment version 1(3);
1)	require "(SAILIB)SAIL.DEF" source!file;
****
2)1	require '1 lsh 24 lor '104 version;	comment version 1(3);
2)	require "(SAILIB)SAIL.DEF" source!file;
**************
1)9	    if length(MissingSet) and 39 = cvd(HOST) then cprint(TEL.COM,
1)		"GATEWAY 1552;MAIL:39"& crlf&
****
2)9	    if length(MissingSet) and (39 = cvd(HOST) or 39 = cvd(datum(MASTER)) ) then
2)		cprint(TEL.COM,
2)		"GATEWAY 1552;MAIL:39"& crlf&
**************
    
;rdilib.com, last modified 5/31/83, zw
;link RDILIB.REL
:
r (upl)fudge2
rdilib= run, autoru, rd00ki, rd01ki, rd02ki, infpki, rd03ki, rd04ki, dirlki,
 daytim, rd05ki, rd06ki, rd07ki, rd08ki, rd09ki, rd10ki, rd11ki,
 rd12ki, rd13ki, rd14ki, rd15ki, rd16ki, rd17ki, rd18ki, rd19ki,
 rd20ki, rd21ki, rd22ki, rd23ki, rd24ki, rd25ki, rd26ki, dtime,
 rd27ki, douuo, prgdir, rd28ki, jobnum, mflski, blioki/a
rdilib= rdilib/x

   
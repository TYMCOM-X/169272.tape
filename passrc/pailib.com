;pailib.com,  last modified 5/31/83,  zw
;link the PAILIB.REL
:
r (upl)fudge2
pailib= dmonki, dbugki, dbioki, dlexki, dbrkki, drefki, dasmki, 
 ddmpki, dscpki, dsymki, dprtki, dbolki, pmonki, renvki, dsupki,
 modfki, nfitki, mfitki, rcnvki/a
pailib= pailib, rstrki, rsetki, ioflki, iocnki, iontki, iocrki,
 iocfki, ioerki, tnioki, pdiski, buf0ki, dcodki, pppnki, iofkki,
 rmatki, rerrki, rfidki, oscaki, ramski, exctki, rparki, sfakki, instrs/a
pailib= pailib/x

 
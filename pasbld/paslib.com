;paslib.com, last modified 5/31/83, zw
;create PASLIB.REL and PAILIB.REL
:
copy debmon.mac+rtmon.mac, debtmp.mac
copy pasmon.mac+rtmon.mac, pastmp.mac
copy debmon.mac+rmonki.mac, deitmp.mac
copy pasmon.mac+rmonki.mac, paitmp.mac
:
;assemble PASLIB universals
:
r decmac
rtsym=rtsym 
iosym=iosym 
stsym=stsym 
opdefs=opdefs 
rtmth=rtmth 
passym=passym 

:
;assemble PAILIB universals
:
r decmac
rtsmki=rtsmki
iosmki=iosmki
stsmki=stsmki
opdfki=opdfki

:
;assemble PASLIB routines
:
r decmac
debmon=debtmp
debasm=debasm 
pasmon=pastmp 
rtenv=rtenv 
dbsup=dbsup 
mmmodf=mmmodf 
ncqfit=ncqfit 
mmqfit=mmqfit 
rtcnv=rtcnv 
rtstrs=rtstrs 
rtsets=rtsets 
iofile=iofile 
iocnnl=iocnnl 
iontxt=iontxt 
iochar=iochar 
iochfk=iochfk 
ioerro=ioerro 
tenio=tenio 
pasdis=pasdis 
buf0=buf0 
decode=decode 
pasppn=pasppn 
iofake=iofake 
rtmath=rtmath 
rterrs=rterrs 
rtpfid=rtpfid 
onesca=onesca 
rtamsg=rtamsg 
except=except 
rtpsar=rtpsar 
sovfak=sovfak 

:
;assemble PAILIB routines
:
r decmac
dmonki=deitmp 
dasmki=dasmki 
pmonki=paitmp 
renvki=renvki 
dsupki=dsupki 
modfki=modfki 
nfitki=nfitki 
mfitki=mfitki 
rcnvki=rcnvki 
rstrki=rstrki 
rsetki=rsetki 
ioflki=ioflki 
iocnki=iocnki 
iontki=iontki 
iocrki=iocrki 
iocfki=iocfki 
ioerki=ioerki 
tnioki=tnioki 
pdiski=pdiski 
buf0ki=buf0ki 
dcodki=dcodki 
pppnki=pppnki 
iofkki=iofkki 
rmatki=rmatki 
rerrki=rerrki 
rfidki=rfidki 
oscaki=oscaki 
ramski=ramski 
exctki=exctki 
rparki=rparki 
sfakki=sfakki 
instrs=instrs 

:
del ###tmp.*
:
;compile PASLIB routines
:
run (pasnew)pascal
/nokicode
/noquick
debbrk
debbol/quick
debdmp
debio
deblex
debprt
debref
debscp
debsym
debug
/exit
:
;compile PAILIB routines
:
run (pasnew)pascal
/kicode
/noquick
dbrkki=debbrk 
dbolki=debbol/quick 
ddmpki=debdmp 
dbioki=debio 
dlexki=deblex 
dprtki=debprt 
drefki=debref 
dscpki=debscp 
dsymki=debsym 
dbugki=debug 
/exit
:
;link PASLIB.REL
:
r (upl)fudge2
paslib= debmon, debug, debio, deblex, debbrk, debref, debasm, 
 debdmp, debscp, debsym, debprt, debbol, pasmon, rtenv, 
 dbsup, mmmodf, ncqfit, mmqfit, rtcnv/a
paslib= paslib, rtstrs, rtsets, iofile, iocnnl, iontxt, iochar,
 iochfk, ioerro, tenio, pasdis, buf0, decode, pasppn, iofake,
 rtmath, rterrs, rtpfid, onesca, rtamsg, except, rtpsar, sovfak/a
paslib= paslib/x

:
;link PAILIB.REL
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
   
;iklcrt.com, last modified 5/31/83, zw
;create PAILIB.REL on a KL10
:
run dtmpfl
ilbunv.cmd
mac
:
r link
/run:dsk:decmac[1,4]/runoff
:
copy debmon.mac+rmonki.mac, debtmp.mac
copy pasmon.mac+rmonki.mac, pastmp.mac
:
run dtmpfl
ilbmac.cmd
mac
:
r link
/run:dsk:decmac[1,4]/runoff
:
del ###tmp.*
:
run pascal
/kicode
@ilbpas
:
:com pailib.com
   
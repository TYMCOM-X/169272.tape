;nklcrt.com, last modified 5/31/83, zw
;create PASLIB.REL on a KL10
:
run dtmpfl
nlbunv.cmd
mac
:
r link
/run:dsk:decmac[1,4]/runoff
:
copy debmon.mac+rtmon.mac, debtmp.mac
copy pasmon.mac+rtmon.mac, pastmp.mac
:
run dtmpfl
nlbmac.cmd
mac
:
r link
/run:dsk:decmac[1,4]/runoff
:
del ###tmp.*
:
run pascal
@nlbpas
:
:com paslib.com
    
r decmac
pt0040=pt0040

;
r link
pt0040/save=
pt0040
<pasisrc>iochar
/s <pasnew>paslib
/s <pasnew>forlib
/go
;
ru pt0040
pt0030.dat
pt0040.rs0
;
r (upl)com;pt004y
    
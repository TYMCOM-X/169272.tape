:
r (ftsys)decmac
pt0040=pt0040
pt004i=pt004i 

:
r (ftsys)link
pt0040/save=
pt0040
<pasgsrc>iochar
/s <pasgsrc>paslib
/s <pasgsrc>forlib
/go
:
ru pt0040
pt0030.dat
pt0040.rs0
:
dif pt0030.res,pt0040.rs0
del pt0040.rel,pt0040.low,pt0040.hgh,pt0040.rs0
:
r (ftsys)link
pt004i/save=
pt004i
<pasgsrc>kiioch
/s <pasgsrc>pailib
/s <pasgsrc>forlib
/go
:
ru pt004i
pt0030.dat
pt004i.rs0
:
dif pt0030.res,pt004i.rs0
del pt004i.rel,pt004i.low,pt004i.hgh,pt004i.rs0
   
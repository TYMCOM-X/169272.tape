:
r (pasgsrc)newpas
ptd030=pt0030/debug
/exit
:
r (ftsys)link
ptd030/save=
ptd030/go
:
r (uemupl)pcom;ptd030.ot0=ptd030.com
:
r (pasgsrc)newpas
pt0030
/exit
:
:com pt003z.com
:
r (pasgsrc)newpas
pt0030/opt
/exit
:
:com pt003z.com
:
dif ptd030.out,ptd030.ot0
dif pt0030.res,ptd030.dbg
del ptd03#.*-ptd030.com-ptd030.out
:
r (pasgsrc)newpas
ptd030=pt0030/ki/debug
/exit
:
r (ftsys)link
ptd030/save=
ptd030/go
:
r (uemupl)pcom;ptd030.ot0=ptd030.com
:
r (pasgsrc)newpas
pt0030/ki
/exit
:
:com pt003z.com
:
r (pasgsrc)newpas
pt0030/opt/ki
/exit
:
:com pt003z.com
:
dif ptd030.out,ptd030.ot0
dif pt0030.res,ptd030.dbg
del ptd03#.*-ptd030.com-ptd030.out
 
:
r (pasgsrc)newpas
pt0050
/exit
:
r (ftsys)link
pt0050/save=
pt0050/go
:
ru pt0050
string_a
:
del pt0050.rel,pt0050.low,pt0050.hgh
:
r (pasgsrc)newpas
pt0050/opt
/exit
:
r (ftsys)link
pt0050/save=
pt0050/go
:
ru pt0050
string_a
:
del pt0050.rel,pt0050.low,pt0050.hgh
:
r (pasgsrc)newpas
pt0050/ki
/exit
:
r (ftsys)link
pt0050/save=
pt0050/go
:
ru pt0050
string_a
:
del pt0050.rel,pt0050.low,pt0050.hgh
:
r (pasgsrc)newpas
pt0050/opt/ki
/exit
:
r (ftsys)link
pt0050/save=
pt0050/go
:
ru pt0050
string_a
:
del pt0050.rel,pt0050.low,pt0050.hgh
 
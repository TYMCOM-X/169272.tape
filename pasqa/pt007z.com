:
:com bt0070.com
:
:com lt0070.com
:
:com dt0070.com
:
del *.tmp
:
ru pt0070
pt0030.dat
pt0070.rs0
:
ru pt0070
pt0030.da1
pt0070.rs1
:
ru pt0070
pt0030.da2
pt0070.rs2
:
ru pt0070
pt0030.da3
pt0070.rs3
:
ru pt0070
pt0030.da4
pt0070.rs4
:
dif pt0070.res,pt0070.rs0
dif pt0070.re1,pt0070.rs1
dif pt0070.re2,pt0070.rs2
dif pt0070.re3,pt0070.rs3
dif pt0070.re4,pt0070.rs4
:
del pt007#.rel,pt007#.srl,pt007#.cmd,pt0070.mdo,pt0070.mod
del pt007#.exe,pt007#.low,pt007#.shr,pt007#.rs#
 
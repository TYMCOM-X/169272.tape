;rkicrt.com, last modified 5/31/83, zw
;create RDILIB.REL on a KI10
:
r decmac
run=run 
autoru=autoru 
infpki=infpki 
dirlki=dirlki 
daytim=daytim 
dtime=dtime 
douuo=douuo 
prgdir=prgdir 
jobnum=jobnum 
mflski=mflski
blioki=blioki

:
run pascal
@rdipas
:
:com rdilib.com
 
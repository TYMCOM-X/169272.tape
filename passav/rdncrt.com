;rklcrt.com, last modified 5/31/83, zw
;create RDNLIB.REL and RDILIB.REL on a KL10
:
r decmac
run=run 
autoru=autoru 
infpac=infpac 
dirlok=dirlok 
daytim=daytim 
dtime=dtime 
douuo=douuo 
prgdir=prgdir 
jobnum=jobnum 
mmmfls=mmmfls 
blokio=blokio 

:
run pascal
@rdnpas
:
:com rdnlib.com
:
run pascal
/kicode
@rdipas
:
r decmac
infpki=infpki 
dirlki=dirlki 
mflski=mflski
blioki=blioki

:
:com rdilib.com
   
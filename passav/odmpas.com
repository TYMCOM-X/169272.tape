;odmpas.com, last modified 5/31/83, zw
;compile ODMS
:
run pascal
/check
mmmpub
/mainseg,nooverlay
mmblds/noquick
mmbldp
mmdbpr
mmdbop
mmprnt
mmpack
mmodms
mmmsym
/nomainseg,overlay
mmsym2=mmmsym
mmmdls
mmmdlp
mdlpro
/exit
 
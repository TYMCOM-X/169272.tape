;okibld.com, last modified 5/31/83, zw
;build ODMS on a KI10
:
run odms
comp odms
build resident using /define:hstrt.:#65000&
/s rdilib,pailib
build main using mmodms,mmblds,mmbldp,mmdbop,mmdbpr,mmprnt,mmpack,mmmsym&
mmtcor,mmmpub,rename
build mdlpro using mmmdls,mmmdlp,mdlpro,mmsym2
quit
    
;oklbld.com, last modified 5/31/83, zw
;build ODMS on a KL10
:
run odms
comp odms
build resident using /define:hstrt.:#65000&
/s utllib,paslib
build main using mmodms,mmblds,mmbldp,mmdbop,mmdbpr,mmprnt,mmpack,mmmsym&
mmtcor,mmmpub,rename
build mdlpro using mmmdls,mmmdlp,mdlpro,mmsym2
quit
    
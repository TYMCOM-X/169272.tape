;odmcrt.com, last modified 5/31/83, zw
;create ODMS
:
:com odmbld.com
:
rename odms.low, oldodm.low
rename odms.shr, oldodm.shr
rename mdlpro.low, oldmdl.low
rename mdlpro.shr, oldmdl.shr
rename mdlpro.exe, oldmdl.exe
:
:com odmmac.com
:
:com odmpas.com
:
:com odmlnk.com
:
:com odmmmd.com
:
:com odmlsd.com
  
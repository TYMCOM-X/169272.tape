;odmmmd.com, last modified 5/31/83, zw
;compile and link MMDEBM
:
run pascal
mmdebm/check/opt
/exit
:
r link
mmdebm/ssave=
mmdebm/go
  
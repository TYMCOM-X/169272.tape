CTEST SETPROC
CTEST ADDPROC MACRO=(FTSYS)MACRO
CTEST ADDPROC EDITOR=(SYS)PEAK
CTEST ADDPROC EDIT10=(SYS)PEAK
CTEST SETDOLIST DEFAULT,LOG,(XEXEC),(SYSMAINT),(SPL),(MPL),(FTSYS),(SYS)
CTEST MAKINI
R TC
RPG
:ESCAPE
:QUIT
  
COPY RPG.INI,RPG.BAK
CTEST SETPROC
CTEST ADDPROC MACRO=(FTSYS)MACRO
CTEST ADDPROC LOADER=(FTSYS)LINKER
CTEST SETDDT (FTSYS)DDT
CTEST ADDPROC LISTER=(MPL)TYPER
CTEST ADDPROC TECO=(FTSYS)TECO
CTEST SETDOLIST DEFAULT,LOG,(XEXEC),(SPL),(MPL),(FTSYS),(SYS)
CTEST MAKINI
R TC
RPG
:ESCAPE
      
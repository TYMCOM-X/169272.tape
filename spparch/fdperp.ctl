;[FDPERP.CTL] Control file to build PERP FDM file
:PARAMETERS FDM-NAME="PERP.FDM"
;
DELETE \FDM-NAME\
;	Create FDM file
;
R (QASYS)FDM
OPEN \FDM-NAME\
DO FDPERP.CMD
G
DIR
QUIT
;
;[End of FDPERP.CTL]
  
@TLN
 GET TO TELENET THROUGH 2162 GATEWAY
C C
FORCE DERNST:2162
FORCE D DERNST TYMNET PASSWORD:dFIN

@TLM
 LOG into TELEMAIL using 1 of 5 known addresses
TLN
FORCE 311090900162
FORCE TYMSHARE
FORCE DEFEND1
OUTPUT TLM.BOX
RESUME

@TLN2
 GET TO TELENET THROUGH 290 GATEWAY
C C
FORCE DERNST:290
FORCE D DERNST TYMNET PASSWORD:dFIN

@TLM2
 LOG into TELEMAIL using 1 of 5 known addresses
TLN2
FORCE C 909162
FORCE TYMSHARE
FORCE DEFEND1
OUTPUT TLM.BOX
RESUME

@TLC
 Copy TLM.BOX to TLMOLD.BOX
P
OUTPUT
SET SEE
FORCE
FORCE COPY TLM.BOX+TLMOLD.BOX,TLMOLD.BOX
FORCE K


@CME
 Log into ONTYME to check mail and add to CM.BOX history file.
Nest EMSM
Nest CMCOPY
Quit

@GETEMS
 Log into ONTYME and copy all messages to ONTYME.MSG file.
Set NoBlank
Output ONTYME.MSG
Creaux EMSNTD
Wait -20
Force DLogging in D NTD.D/ERNST
Wait -20
Force T2921783
Wait -20
Force :IN
Wait -20
Force :READ,ALL,FFDReadingD
Wait -20
Force :QUIT
Force
Force
Time 120



@CMCOPY
 Type ONTYME.MSG and add to CM.BOX history file.
output cm.tmp
Creaux U:S
set SEE
Force
Force
Force
Force COPY ONTYME.MSG+CM.BOX,CM.BOX
Force TYPE ONTYME.MSG
Force Exit
time 120


@TOEMS
 Send contents of file TOEMS.DOC to ONTYME, type it and then remain
 connected to ONTYME so user can enter :SEND command and :QUIT
OUTPUT ONTYME.MSG
CREAUX EMSNTD
WAIT -20
FORCE NTD.D/ERNST
WAIT -20
FORCE T2921783
WAIT -20
INPUT TOEMS.DOC
SET SEE
FORCE
FORCE :TYPE
RESUME

@EMS
 Log into ONTYME system and recorde everything on ONTYME.MSG until
 user exits ONTYME.
SET NOBLANK
OUTPUT ONTYME.MSG
CREAUX EMSNTD
WAIT -20
FORCE NTD.D/ERNST
WAIT -20
FORCE T2921783
WAIT -20
RESUME


@DIR39
CREAUX U:39
FORCE 
FORCE 
FORCE 
FORCE DIR DIR.39=
FORCE EXI
TIME 120

@DIR54
CREAUX U:54
FORCE 
FORCE 
FORCE 
FORCE DIR DIR.54=
FORCE R(MPL)COPY
FORCE DIR.54
FORCE U
FORCE 39
FORCE Y
FORCE EXI
TIME 120

@DIR56
CREAUX U:56
FORCE 
FORCE 
FORCE 
FORCE DIR DIR.56=
FORCE R(MPL)COPY
FORCE DIR.56
FORCE U
FORCE 39
FORCE Y
FORCE EXI
TIME 120

@DIR59
CREAUX U:59
FORCE 
FORCE 
FORCE 
FORCE DIR DIR.59=
FORCE R(MPL)COPY
FORCE DIR.59
FORCE U
FORCE 39
FORCE Y
FORCE EXI
TIME 120


@DIR930
CREAUX U:930
FORCE 
FORCE 
FORCE 
FORCE DIR DIR.930=
FORCE R(MPL)COPY
FORCE DIR.930
FORCE U
FORCE 39
FORCE Y
FORCE EXI
TIME 120
  
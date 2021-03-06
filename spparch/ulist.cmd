!COMMAND FILE FOR OBTAINING ALL FILES RELEVANT TO BUILDING ULIST
INFORMATION LOGICAL-NAMES

;Files required to build product
COPY FROM-SOURCE:ULIST.CMD TO-SOURCE:*.*.-1
COPY FROM-SOURCE:ULIST.CTL TO-SOURCE:*.*.-1
COPY FROM-SOURCE:ULIST.MAC TO-SOURCE:*.*.-1

;Documentation for product
COPY FROM-SOURCE:ULIST.TCO TO-DOC:*.*.-1
COPY FROM-SOURCE:ULIST.HLP TO-SUBSYS:*.*.-1
COPY FROM-SOURCE:ULIST.DOC TO-DOC:*.*.-1

;Library files used for symbols
;COPY FROM-SUBSYS:MACREL.REL TO-SUBSYS:*.*.-1
;COPY FROM-SUBSYS:MACSYM.UNV TO-SUBSYS:*.*.-1
;COPY FROM-SUBSYS:MONSYM.UNV TO-SUBSYS:*.*.-1

;Final product
COPY FROM-SOURCE:ULIST.EXE TO-SUBSYS:*.*.-1
   